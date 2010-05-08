Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3DCF06B026A
	for <linux-mm@kvack.org>; Sat,  8 May 2010 17:35:18 -0400 (EDT)
Received: by pzk28 with SMTP id 28so1125139pzk.11
        for <linux-mm@kvack.org>; Sat, 08 May 2010 14:35:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <p2l6599ad831005071407yaa994357s1261317cc7f552b@mail.gmail.com>
References: <l2pcc557aab1005070446y1f9c8169v58a3f7847676eaa@mail.gmail.com>
	 <p2l6599ad831005071407yaa994357s1261317cc7f552b@mail.gmail.com>
Date: Sun, 9 May 2010 00:35:15 +0300
Message-ID: <i2mcc557aab1005081435g3cd209fbg4eedd0791c2fb358@mail.gmail.com>
Subject: Re: [PATCH] cgroups: make cftype.unregister_event() void-returning
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: linux-mm@kvack.org, containers@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, Phil Carmody <ext-phil.2.carmody@nokia.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, May 8, 2010 at 12:07 AM, Paul Menage <menage@google.com> wrote:
> I like the principle. I think this patch leaks arrays, though.
>
> I think the sequence:
>
> register;register;unregister;unregister
>
> will leak the array of size 2. Using the notation Ax, Bx, Cx, etc to
> represent distinct buffers of size x, we have:
>
> initially: size =3D 0, thresholds =3D NULL, spare =3D NULL
> register: size =3D 1, thresholds =3D A1, spare =3D NULL
> register: size =3D 2, thresholds =3D B2, spare =3D A1
> unregister: size =3D 1, thresholds =3D A1, spare =3D B2
> unregister: size =3D 0, thresholds =3D NULL, spare =3D A1 (B2 is leaked)
>
> In the case when you're unregistering and the size goes down to 0, you
> need to free the spare before doing the swap.

Nice catch!

> Maybe get rid of the
> thresholds_new local variable, and instead in the if(!size) {} branch
> just free and the spare buffer and set its pointer to NULL? Then at
> swap_buffers:, unconditionally swap the two.

Good idea. Thanks.

> Also, I think the code would be cleaner if you created a structure to
> hold a primary threshold and its spare; then you could have one for
> each threshold set, and just pass that to the register/unregister
> functions, rather than them having to be aware of how the type maps to
> the primary and backup array pointers.

Ok. I'll try to implement it in separate patch.

Thank you for reviewing.

>
> Paul
>
> On Fri, May 7, 2010 at 4:46 AM, Kirill A. Shutemov <kirill@shutemov.name>=
 wrote:
>> Since we unable to handle error returned by cftype.unregister_event()
>> properly, let's make the callback void-returning.
>>
>> mem_cgroup_unregister_event() has been rewritten to be "never fail"
>> function. On mem_cgroup_usage_register_event() we save old buffer
>> for thresholds array and reuse it in mem_cgroup_usage_unregister_event()
>> to avoid allocation.
>>
>> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
>> ---
>> =C2=A0include/linux/cgroup.h | =C2=A0 =C2=A02 +-
>> =C2=A0kernel/cgroup.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A01 -
>> =C2=A0mm/memcontrol.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 64 +++++++++++=
+++++++++++++++++++------------------
>> =C2=A03 files changed, 41 insertions(+), 26 deletions(-)
>>
>> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
>> index 8f78073..0c62160 100644
>> --- a/include/linux/cgroup.h
>> +++ b/include/linux/cgroup.h
>> @@ -397,7 +397,7 @@ struct cftype {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * This callback must be implemented, if you =
want provide
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * notification functionality.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
>> - =C2=A0 =C2=A0 =C2=A0 int (*unregister_event)(struct cgroup *cgrp, stru=
ct cftype *cft,
>> + =C2=A0 =C2=A0 =C2=A0 void (*unregister_event)(struct cgroup *cgrp, str=
uct cftype *cft,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0struct eventfd_ctx *eventfd);
>> =C2=A0};
>>
>> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
>> index 06dbf97..6675e8c 100644
>> --- a/kernel/cgroup.c
>> +++ b/kernel/cgroup.c
>> @@ -2988,7 +2988,6 @@ static void cgroup_event_remove(struct work_struct=
 *work)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0remove);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct cgroup *cgrp =3D event->cgrp;
>>
>> - =C2=A0 =C2=A0 =C2=A0 /* TODO: check return code */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0event->cft->unregister_event(cgrp, event->cft=
, event->eventfd);
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0eventfd_ctx_put(event->eventfd);
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 8cb2722..0a37b5d 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -226,9 +226,19 @@ struct mem_cgroup {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* thresholds for memory usage. RCU-protected=
 */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup_threshold_ary *thresholds;
>>
>> + =C2=A0 =C2=A0 =C2=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Preallocated buffer to be used in mem_cgr=
oup_unregister_event()
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* to make it "never fail".
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* It must be able to store at least thresho=
lds->size - 1 entries.
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup_threshold_ary *__thresholds;
>> +
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* thresholds for mem+swap usage. RCU-protect=
ed */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup_threshold_ary *memsw_thresh=
olds;
>>
>> + =C2=A0 =C2=A0 =C2=A0 /* the same as __thresholds, but for memsw_thresh=
olds */
>> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup_threshold_ary *__memsw_threshol=
ds;
>> +
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* For oom notifier event fd */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct list_head oom_notify;
>>
>> @@ -3575,17 +3585,27 @@ static int
>> mem_cgroup_usage_register_event(struct cgroup *cgrp,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0else
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_assign_pointe=
r(memcg->memsw_thresholds, thresholds_new);
>>
>> - =C2=A0 =C2=A0 =C2=A0 /* To be sure that nobody uses thresholds before =
freeing it */
>> + =C2=A0 =C2=A0 =C2=A0 /* To be sure that nobody uses thresholds */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0synchronize_rcu();
>>
>> - =C2=A0 =C2=A0 =C2=A0 kfree(thresholds);
>> + =C2=A0 =C2=A0 =C2=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Free old preallocated buffer and use thre=
sholds as new
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* preallocated buffer.
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 =C2=A0 if (type =3D=3D _MEM) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 kfree(memcg->__thresh=
olds);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg->__thresholds =
=3D thresholds;
>> + =C2=A0 =C2=A0 =C2=A0 } else {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 kfree(memcg->__memsw_=
thresholds);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg->__memsw_thresh=
olds =3D thresholds;
>> + =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0unlock:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0mutex_unlock(&memcg->thresholds_lock);
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
>> =C2=A0}
>>
>> -static int mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
>> +static void mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct cftype *cft, struct eventfd_ctx *event=
fd)
>> =C2=A0{
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup *memcg =3D mem_cgroup_from_=
cont(cgrp);
>> @@ -3593,7 +3613,7 @@ static int
>> mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0int type =3D MEMFILE_TYPE(cft->private);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0u64 usage;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0int size =3D 0;
>> - =C2=A0 =C2=A0 =C2=A0 int i, j, ret =3D 0;
>> + =C2=A0 =C2=A0 =C2=A0 int i, j;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0mutex_lock(&memcg->thresholds_lock);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (type =3D=3D _MEM)
>> @@ -3623,17 +3643,15 @@ static int
>> mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Set thresholds array to NULL if we don't h=
ave thresholds */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!size) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0thresholds_new =
=3D NULL;
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto assign;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto swap_buffers;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>>
>> - =C2=A0 =C2=A0 =C2=A0 /* Allocate memory for new array of thresholds */
>> - =C2=A0 =C2=A0 =C2=A0 thresholds_new =3D kmalloc(sizeof(*thresholds_new=
) +
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 size * sizeof(struct mem_cgroup_threshold),
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 GFP_KERNEL);
>> - =C2=A0 =C2=A0 =C2=A0 if (!thresholds_new) {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D -ENOMEM;
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto unlock;
>> - =C2=A0 =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 =C2=A0 /* Use preallocated buffer for new array of thres=
holds */
>> + =C2=A0 =C2=A0 =C2=A0 if (type =3D=3D _MEM)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 thresholds_new =3D me=
mcg->__thresholds;
>> + =C2=A0 =C2=A0 =C2=A0 else
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 thresholds_new =3D me=
mcg->__memsw_thresholds;
>> +
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0thresholds_new->size =3D size;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Copy thresholds and find current threshold=
 */
>> @@ -3654,20 +3672,20 @@ static int
>> mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0j++;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>>
>> -assign:
>> - =C2=A0 =C2=A0 =C2=A0 if (type =3D=3D _MEM)
>> +swap_buffers:
>> + =C2=A0 =C2=A0 =C2=A0 /* Swap thresholds array and preallocated buffer =
*/
>> + =C2=A0 =C2=A0 =C2=A0 if (type =3D=3D _MEM) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg->__thresholds =
=3D thresholds;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_assign_pointe=
r(memcg->thresholds, thresholds_new);
>> - =C2=A0 =C2=A0 =C2=A0 else
>> + =C2=A0 =C2=A0 =C2=A0 } else {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg->__memsw_thresh=
olds =3D thresholds;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_assign_pointe=
r(memcg->memsw_thresholds, thresholds_new);
>> + =C2=A0 =C2=A0 =C2=A0 }
>>
>> - =C2=A0 =C2=A0 =C2=A0 /* To be sure that nobody uses thresholds before =
freeing it */
>> + =C2=A0 =C2=A0 =C2=A0 /* To be sure that nobody uses thresholds */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0synchronize_rcu();
>>
>> - =C2=A0 =C2=A0 =C2=A0 kfree(thresholds);
>> -unlock:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0mutex_unlock(&memcg->thresholds_lock);
>> -
>> - =C2=A0 =C2=A0 =C2=A0 return ret;
>> =C2=A0}
>>
>> =C2=A0static int mem_cgroup_oom_register_event(struct cgroup *cgrp,
>> @@ -3695,7 +3713,7 @@ static int mem_cgroup_oom_register_event(struct
>> cgroup *cgrp,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
>> =C2=A0}
>>
>> -static int mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
>> +static void mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct cftype *cft, struct eventfd_ctx *event=
fd)
>> =C2=A0{
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup *mem =3D mem_cgroup_from_co=
nt(cgrp);
>> @@ -3714,8 +3732,6 @@ static int
>> mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0mutex_unlock(&memcg_oom_mutex);
>> -
>> - =C2=A0 =C2=A0 =C2=A0 return 0;
>> =C2=A0}
>>
>> =C2=A0static int mem_cgroup_oom_control_read(struct cgroup *cgrp,
>> --
>> 1.7.0.4
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
