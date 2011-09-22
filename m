Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B60559000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 23:17:32 -0400 (EDT)
Received: by fxh17 with SMTP id 17so3079200fxh.14
        for <linux-mm@kvack.org>; Wed, 21 Sep 2011 20:17:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4E794AA2.9080008@parallels.com>
References: <1316393805-3005-1-git-send-email-glommer@parallels.com>
	<1316393805-3005-2-git-send-email-glommer@parallels.com>
	<4E794AA2.9080008@parallels.com>
Date: Thu, 22 Sep 2011 08:47:28 +0530
Message-ID: <CAKTCnzmkuL+9ftD5d0Z8b5w+DUSUoLiWqSX_TgGxtRxtoPsxpA@mail.gmail.com>
Subject: Re: [PATCH v3 1/7] Basic kernel memory functionality for the Memory Controller
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, Ying Han <yinghan@google.com>

On Wed, Sep 21, 2011 at 7:53 AM, Glauber Costa <glommer@parallels.com> wrot=
e:
>
> Hi people,
>
> Any insights on this series?
> Kame, is it inline with your expectations ?
>
> Thank you all
>
> On 09/18/2011 09:56 PM, Glauber Costa wrote:
>>
>> This patch lays down the foundation for the kernel memory component
>> of the Memory Controller.
>>
>> As of today, I am only laying down the following files:
>>
>> =A0* memory.independent_kmem_limit
>> =A0* memory.kmem.limit_in_bytes (currently ignored)
>> =A0* memory.kmem.usage_in_bytes (always zero)
>>
>> Signed-off-by: Glauber Costa<glommer@parallels.com>
>> CC: Paul Menage<paul@paulmenage.org>
>> CC: Greg Thelen<gthelen@google.com>
>> ---
>> =A0Documentation/cgroups/memory.txt | =A0 30 +++++++++-
>> =A0init/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 11 ++++
>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0115 +++++++++=
+++++++++++++++++++++++++++--
>> =A03 files changed, 148 insertions(+), 8 deletions(-)
>>
>> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/me=
mory.txt
>> index 6f3c598..6f1954a 100644
>> --- a/Documentation/cgroups/memory.txt
>> +++ b/Documentation/cgroups/memory.txt
>> @@ -44,8 +44,9 @@ Features:
>> =A0 - oom-killer disable knob and oom-notifier
>> =A0 - Root cgroup has no limit controls.
>>
>> - Kernel memory and Hugepages are not under control yet. We just manage
>> - pages on LRU. To add more controls, we have to take care of performanc=
e.
>> + Hugepages is not under control yet. We just manage pages on LRU. To ad=
d more
>> + controls, we have to take care of performance. Kernel memory support i=
s work
>> + in progress, and the current version provides basically functionality.
>>
>> =A0Brief summary of control files.
>>
>> @@ -56,8 +57,11 @@ Brief summary of control files.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (See 5.5=
 for details)
>> =A0 memory.memsw.usage_in_bytes =A0 # show current res_counter usage for=
 memory+Swap
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (See 5.5=
 for details)
>> + memory.kmem.usage_in_bytes =A0 =A0 # show current res_counter usage fo=
r kmem only.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(See 2.=
7 for details)
>> =A0 memory.limit_in_bytes =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 # set/show lim=
it of memory usage
>> =A0 memory.memsw.limit_in_bytes =A0 # set/show limit of memory+Swap usag=
e
>> + memory.kmem.limit_in_bytes =A0 =A0 # if allowed, set/show limit of ker=
nel memory
>> =A0 memory.failcnt =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0# show=
 the number of memory usage hits limits
>> =A0 memory.memsw.failcnt =A0 =A0 =A0 =A0 =A0# show the number of memory+=
Swap hits limits
>> =A0 memory.max_usage_in_bytes =A0 =A0 # show max memory usage recorded
>> @@ -72,6 +76,9 @@ Brief summary of control files.
>> =A0 memory.oom_control =A0 =A0 =A0 =A0 =A0 =A0# set/show oom controls.
>> =A0 memory.numa_stat =A0 =A0 =A0 =A0 =A0 =A0 =A0# show the number of mem=
ory usage per numa node
>>
>> + memory.independent_kmem_limit =A0# select whether or not kernel memory=
 limits are
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ind=
ependent of user limits
>> +
>> =A01. History
>>
>> =A0The memory controller has a long history. A request for comments for =
the memory
>> @@ -255,6 +262,25 @@ When oom event notifier is registered, event will b=
e delivered.
>> =A0 =A0per-zone-per-cgroup LRU (cgroup's private LRU) is just guarded by
>> =A0 =A0zone->lru_lock, it has no lock of its own.
>>
>> +2.7 Kernel Memory Extension (CONFIG_CGROUP_MEM_RES_CTLR_KMEM)
>> +
>> + With the Kernel memory extension, the Memory Controller is able to lim=
it
>> +the amount of kernel memory used by the system. Kernel memory is fundam=
entally
>> +different than user memory, since it can't be swapped out, which makes =
it
>> +possible to DoS the system by consuming too much of this precious resou=
rce.
>> +Kernel memory limits are not imposed for the root cgroup.
>> +
>> +Memory limits as specified by the standard Memory Controller may or may=
 not
>> +take kernel memory into consideration. This is achieved through the fil=
e
>> +memory.independent_kmem_limit. A Value different than 0 will allow for =
kernel
>> +memory to be controlled separately.
>> +
>> +When kernel memory limits are not independent, the limit values set in
>> +memory.kmem files are ignored.
>> +
>> +Currently no soft limit is implemented for kernel memory. It is future =
work
>> +to trigger slab reclaim when those limits are reached.
>> +

Ying Han was also looking into this (cc'ing her)

>> =A03. User Interface
>>
>> =A00. Configuration
>> diff --git a/init/Kconfig b/init/Kconfig
>> index d627783..49e5839 100644
>> --- a/init/Kconfig
>> +++ b/init/Kconfig
>> @@ -689,6 +689,17 @@ config CGROUP_MEM_RES_CTLR_SWAP_ENABLED
>> =A0 =A0 =A0 =A0 =A0For those who want to have the feature enabled by def=
ault should
>> =A0 =A0 =A0 =A0 =A0select this option (if, for some reason, they need to=
 disable it
>> =A0 =A0 =A0 =A0 =A0then swapaccount=3D0 does the trick).
>> +config CGROUP_MEM_RES_CTLR_KMEM
>> + =A0 =A0 =A0 bool "Memory Resource Controller Kernel Memory accounting"
>> + =A0 =A0 =A0 depends on CGROUP_MEM_RES_CTLR
>> + =A0 =A0 =A0 default y
>> + =A0 =A0 =A0 help
>> + =A0 =A0 =A0 =A0 The Kernel Memory extension for Memory Resource Contro=
ller can limit
>> + =A0 =A0 =A0 =A0 the amount of memory used by kernel objects in the sys=
tem. Those are
>> + =A0 =A0 =A0 =A0 fundamentally different from the entities handled by t=
he standard
>> + =A0 =A0 =A0 =A0 Memory Controller, which are page-based, and can be sw=
apped. Users of
>> + =A0 =A0 =A0 =A0 the kmem extension can use it to guarantee that no gro=
up of processes
>> + =A0 =A0 =A0 =A0 will ever exhaust kernel resources alone.
>>
>> =A0config CGROUP_PERF
>> =A0 =A0 =A0 =A0bool "Enable perf_event per-cpu per-container group (cgro=
up) monitoring"
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index ebd1e86..d32e931 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -73,7 +73,11 @@ static int really_do_swap_account __initdata =3D 0;
>> =A0#define do_swap_account =A0 =A0 =A0 =A0 =A0 =A0 =A0 (0)
>> =A0#endif
>>
>> -
>> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>> +int do_kmem_account __read_mostly =3D 1;
>> +#else
>> +#define do_kmem_account =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00
>> +#endif
>> =A0/*
>> =A0 * Statistics for memory cgroup.
>> =A0 */
>> @@ -270,6 +274,10 @@ struct mem_cgroup {
>> =A0 =A0 =A0 =A0 */
>> =A0 =A0 =A0 =A0struct res_counter memsw;
>> =A0 =A0 =A0 =A0/*
>> + =A0 =A0 =A0 =A0* the counter to account for kmem usage.
>> + =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 struct res_counter kmem;
>> + =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 * Per cgroup active and inactive list, similar to the
>> =A0 =A0 =A0 =A0 * per zone LRU lists.
>> =A0 =A0 =A0 =A0 */
>> @@ -321,6 +329,11 @@ struct mem_cgroup {
>> =A0 =A0 =A0 =A0 */
>> =A0 =A0 =A0 =A0unsigned long =A0 move_charge_at_immigrate;
>> =A0 =A0 =A0 =A0/*
>> + =A0 =A0 =A0 =A0* Should kernel memory limits be stabilished independen=
tly
>> + =A0 =A0 =A0 =A0* from user memory ?
>> + =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 kmem_independent;
>> + =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 * percpu counter.
>> =A0 =A0 =A0 =A0 */
>> =A0 =A0 =A0 =A0struct mem_cgroup_stat_cpu *stat;
>> @@ -388,9 +401,14 @@ enum charge_type {
>> =A0};
>>
>> =A0/* for encoding cft->private value on file */
>> -#define _MEM =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (0)
>> -#define _MEMSWAP =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1)
>> -#define _OOM_TYPE =A0 =A0 =A0 =A0 =A0 =A0 =A0(2)
>> +
>> +enum mem_type {
>> + =A0 =A0 =A0 _MEM =3D 0,
>> + =A0 =A0 =A0 _MEMSWAP,
>> + =A0 =A0 =A0 _OOM_TYPE,
>> + =A0 =A0 =A0 _KMEM,
>> +};
>> +
>> =A0#define MEMFILE_PRIVATE(x, val) =A0 =A0 =A0 (((x)<< =A016) | (val))
>> =A0#define MEMFILE_TYPE(val) =A0 =A0 (((val)>> =A016)& =A00xffff)
>> =A0#define MEMFILE_ATTR(val) =A0 =A0 ((val)& =A00xffff)
>> @@ -3943,10 +3961,15 @@ static inline u64 mem_cgroup_usage(struct mem_cg=
roup *mem, bool swap)
>> =A0 =A0 =A0 =A0u64 val;
>>
>> =A0 =A0 =A0 =A0if (!mem_cgroup_is_root(mem)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 val =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mem->kmem_independent)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 val =3D res_counter_read_u=
64(&mem->kmem, RES_USAGE);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!swap)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return res_counter_read_u6=
4(&mem->res, RES_USAGE);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 val +=3D res_counter_read_=
u64(&mem->res, RES_USAGE);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return res_counter_read_u6=
4(&mem->memsw, RES_USAGE);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 val +=3D res_counter_read_=
u64(&mem->memsw, RES_USAGE);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return val;
>> =A0 =A0 =A0 =A0}
>>
>> =A0 =A0 =A0 =A0val =3D mem_cgroup_recursive_stat(mem, MEM_CGROUP_STAT_CA=
CHE);
>> @@ -3979,6 +4002,10 @@ static u64 mem_cgroup_read(struct cgroup *cont, s=
truct cftype *cft)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0val =3D res_counter_read_=
u64(&mem->memsw, name);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>> + =A0 =A0 =A0 case _KMEM:
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 val =3D res_counter_read_u64(&mem->kmem, n=
ame);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> +
>> =A0 =A0 =A0 =A0default:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG();
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>> @@ -4756,6 +4783,21 @@ static int mem_cgroup_reset_vmscan_stat(struct cg=
roup *cgrp,
>> =A0 =A0 =A0 =A0return 0;
>> =A0}
>>
>> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>> +static u64 kmem_limit_independent_read(struct cgroup *cont, struct cfty=
pe *cft)
>> +{
>> + =A0 =A0 =A0 return mem_cgroup_from_cont(cont)->kmem_independent;
>> +}
>> +
>> +static int kmem_limit_independent_write(struct cgroup *cont, struct cft=
ype *cft,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 u64 val)
>> +{
>> + =A0 =A0 =A0 cgroup_lock();
>> + =A0 =A0 =A0 mem_cgroup_from_cont(cont)->kmem_independent =3D !!val;
>> + =A0 =A0 =A0 cgroup_unlock();
>> + =A0 =A0 =A0 return 0;
>> +}

I know we have a lot of pending xxx_from_cont() and struct cgroup
*cont, can we move it to memcg notation to be more consistent with our
usage. There is a patch to convert old usage

>> +#endif
>>
>> =A0static struct cftype mem_cgroup_files[] =3D {
>> =A0 =A0 =A0 =A0{
>> @@ -4877,6 +4919,47 @@ static int register_memsw_files(struct cgroup *co=
nt, struct cgroup_subsys *ss)
>> =A0}
>> =A0#endif
>>
>> +
>> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>> +static struct cftype kmem_cgroup_files[] =3D {
>> + =A0 =A0 =A0 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "independent_kmem_limit",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .read_u64 =3D kmem_limit_independent_read,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .write_u64 =3D kmem_limit_independent_writ=
e,
>> + =A0 =A0 =A0 },
>> + =A0 =A0 =A0 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "kmem.usage_in_bytes",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .private =3D MEMFILE_PRIVATE(_KMEM, RES_US=
AGE),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .read_u64 =3D mem_cgroup_read,
>> + =A0 =A0 =A0 },
>> + =A0 =A0 =A0 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "kmem.limit_in_bytes",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .private =3D MEMFILE_PRIVATE(_KMEM, RES_LI=
MIT),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .read_u64 =3D mem_cgroup_read,
>> + =A0 =A0 =A0 },
>> +};
>> +
>> +static int register_kmem_files(struct cgroup *cont, struct cgroup_subsy=
s *ss)
>> +{
>> + =A0 =A0 =A0 struct mem_cgroup *mem =3D mem_cgroup_from_cont(cont);
>> + =A0 =A0 =A0 int ret =3D 0;
>> +
>> + =A0 =A0 =A0 if (!do_kmem_account)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> +
>> + =A0 =A0 =A0 if (!mem_cgroup_is_root(mem))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D cgroup_add_files(cont, ss, kmem_cg=
roup_files,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 ARRAY_SIZE(kmem_cgroup_files));
>> + =A0 =A0 =A0 return ret;
>> +};
>> +
>> +#else
>> +static int register_kmem_files(struct cgroup *cont, struct cgroup_subsy=
s *ss)
>> +{
>> + =A0 =A0 =A0 return 0;
>> +}
>> +#endif
>> +
>> =A0static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int=
 node)
>> =A0{
>> =A0 =A0 =A0 =A0struct mem_cgroup_per_node *pn;
>> @@ -5075,6 +5158,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct=
 cgroup *cont)
>> =A0 =A0 =A0 =A0if (parent&& =A0parent->use_hierarchy) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0res_counter_init(&mem->res,&parent->res);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0res_counter_init(&mem->memsw,&parent->mem=
sw);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_init(&mem->kmem,&parent->kmem)=
;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * We increment refcnt of the parent to e=
nsure that we can
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * safely access it on res_counter_charge=
/uncharge.
>> @@ -5085,6 +5169,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct=
 cgroup *cont)
>> =A0 =A0 =A0 =A0} else {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0res_counter_init(&mem->res, NULL);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0res_counter_init(&mem->memsw, NULL);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_init(&mem->kmem, NULL);
>> =A0 =A0 =A0 =A0}
>> =A0 =A0 =A0 =A0mem->last_scanned_child =3D 0;
>> =A0 =A0 =A0 =A0mem->last_scanned_node =3D MAX_NUMNODES;
>> @@ -5129,6 +5214,10 @@ static int mem_cgroup_populate(struct cgroup_subs=
ys *ss,
>>
>> =A0 =A0 =A0 =A0if (!ret)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D register_memsw_files(cont, ss);
>> +
>> + =A0 =A0 =A0 if (!ret)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D register_kmem_files(cont, ss);
>> +
>> =A0 =A0 =A0 =A0return ret;
>> =A0}
>>
>> @@ -5665,3 +5754,17 @@ static int __init enable_swap_account(char *s)
>> =A0__setup("swapaccount=3D", enable_swap_account);
>>
>> =A0#endif
>> +
>> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>> +static int __init disable_kmem_account(char *s)
>> +{
>> + =A0 =A0 =A0 /* consider enabled if no parameter or 1 is given */
>> + =A0 =A0 =A0 if (!strcmp(s, "1"))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_kmem_account =3D 1;
>> + =A0 =A0 =A0 else if (!strcmp(s, "0"))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_kmem_account =3D 0;
>> + =A0 =A0 =A0 return 1;
>> +}
>> +__setup("kmemaccount=3D", disable_kmem_account);
>> +
>> +#endif

The infrastructure looks OK, we need better integration with
statistics for kmem usage.

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
