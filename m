Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C96C69000BD
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 19:08:25 -0400 (EDT)
Received: by fxh17 with SMTP id 17so4276590fxh.14
        for <linux-mm@kvack.org>; Thu, 22 Sep 2011 16:08:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1316393805-3005-7-git-send-email-glommer@parallels.com>
References: <1316393805-3005-1-git-send-email-glommer@parallels.com>
	<1316393805-3005-7-git-send-email-glommer@parallels.com>
Date: Fri, 23 Sep 2011 04:38:22 +0530
Message-ID: <CAKTCnzm8C4RFOxZT7Yh=Cjm8Mby1=9PXQC6c8zpzX6o-vL0EiQ@mail.gmail.com>
Subject: Re: [PATCH v3 6/7] tcp buffer limitation: per-cgroup limit
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name

On Mon, Sep 19, 2011 at 6:26 AM, Glauber Costa <glommer@parallels.com> wrot=
e:
> This patch uses the "tcp_max_mem" field of the kmem_cgroup to
> effectively control the amount of kernel memory pinned by a cgroup.
>
> We have to make sure that none of the memory pressure thresholds
> specified in the namespace are bigger than the current cgroup.
>
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Eric W. Biederman <ebiederm@xmission.com>
> ---
> =A0Documentation/cgroups/memory.txt | =A0 =A01 +
> =A0include/linux/memcontrol.h =A0 =A0 =A0 | =A0 10 ++++
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 89 ++++++++++=
+++++++++++++++++++++++++---
> =A0net/ipv4/sysctl_net_ipv4.c =A0 =A0 =A0 | =A0 20 ++++++++
> =A04 files changed, 113 insertions(+), 7 deletions(-)
>
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/mem=
ory.txt
> index 6f1954a..1ffde3e 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -78,6 +78,7 @@ Brief summary of control files.
>
> =A0memory.independent_kmem_limit =A0# select whether or not kernel memory=
 limits are
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 indep=
endent of user limits
> + memory.kmem.tcp.max_memory =A0 =A0 =A0# set/show hard limit for tcp buf=
 memory
>
> =A01. History
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 6b8c0c0..2df6db8 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -416,6 +416,9 @@ int tcp_init_cgroup_fill(struct proto *prot, struct c=
group *cgrp,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup_subsys *ss)=
;
> =A0void tcp_destroy_cgroup(struct proto *prot, struct cgroup *cgrp,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgroup_subsys *ss);
> +
> +unsigned long tcp_max_memory(struct mem_cgroup *cg);
> +void tcp_prot_mem(struct mem_cgroup *cg, long val, int idx);
> =A0#else
> =A0/* memcontrol includes sockets.h, that includes memcontrol.h ... */
> =A0static inline void memcg_sock_mem_alloc(struct mem_cgroup *mem,
> @@ -441,6 +444,13 @@ static inline void sock_update_memcg(struct sock *sk=
)
> =A0static inline void sock_release_memcg(struct sock *sk)
> =A0{
> =A0}
> +static inline unsigned long tcp_max_memory(struct mem_cgroup *cg)
> +{
> + =A0 =A0 =A0 return 0;
> +}
> +static inline void tcp_prot_mem(struct mem_cgroup *cg, long val, int idx=
)
> +{
> +}
> =A0#endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
> =A0#endif /* CONFIG_INET */
> =A0#endif /* _LINUX_MEMCONTROL_H */
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 5e9b2c7..be5ab89 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -345,6 +345,7 @@ struct mem_cgroup {
> =A0 =A0 =A0 =A0spinlock_t pcp_counter_lock;
>
> =A0 =A0 =A0 =A0/* per-cgroup tcp memory pressure knobs */
> + =A0 =A0 =A0 int tcp_max_memory;

Aren't we better of abstracting this in a different structure?
Including all the tcp parameters in that abstraction and adding that
structure here?

> =A0 =A0 =A0 =A0atomic_long_t tcp_memory_allocated;
> =A0 =A0 =A0 =A0struct percpu_counter tcp_sockets_allocated;
> =A0 =A0 =A0 =A0/* those two are read-mostly, leave them at the end */
> @@ -352,6 +353,11 @@ struct mem_cgroup {
> =A0 =A0 =A0 =A0int tcp_memory_pressure;
> =A0};
>
> +static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
> +{
> + =A0 =A0 =A0 return (mem =3D=3D root_mem_cgroup);
> +}
> +
> =A0static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
> =A0/* Writing them here to avoid exposing memcg's inner layout */
> =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> @@ -466,6 +472,56 @@ struct percpu_counter *sockets_allocated_tcp(struct =
mem_cgroup *sg)
> =A0 =A0 =A0 =A0return &sg->tcp_sockets_allocated;
> =A0}
>
> +static int tcp_write_maxmem(struct cgroup *cgrp, struct cftype *cft, u64=
 val)
> +{
> + =A0 =A0 =A0 struct mem_cgroup *sg =3D mem_cgroup_from_cont(cgrp);

sg, I'd prefer memcg, does sg stand for socket group?

> + =A0 =A0 =A0 struct mem_cgroup *parent =3D parent_mem_cgroup(sg);
> + =A0 =A0 =A0 struct net *net =3D current->nsproxy->net_ns;
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 if (!cgroup_lock_live_group(cgrp))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* We can't allow more memory than our parents. Since thi=
s
> + =A0 =A0 =A0 =A0* will be tested for all calls, by induction, there is n=
o need
> + =A0 =A0 =A0 =A0* to test any parent other than our own
> + =A0 =A0 =A0 =A0* */
> + =A0 =A0 =A0 if (parent && (val > parent->tcp_max_memory))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 val =3D parent->tcp_max_memory;
> +
> + =A0 =A0 =A0 sg->tcp_max_memory =3D val;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < 3; i++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sg->tcp_prot_mem[i] =A0=3D min_t(long, val,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0net->ipv4.sysctl_tcp_mem[i]);
> +
> + =A0 =A0 =A0 cgroup_unlock();
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static u64 tcp_read_maxmem(struct cgroup *cgrp, struct cftype *cft)
> +{
> + =A0 =A0 =A0 struct mem_cgroup *sg =3D mem_cgroup_from_cont(cgrp);

sg? We generally use memcg as a convention

> + =A0 =A0 =A0 u64 ret;
> +
> + =A0 =A0 =A0 if (!cgroup_lock_live_group(cgrp))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> + =A0 =A0 =A0 ret =3D sg->tcp_max_memory;
> +
> + =A0 =A0 =A0 cgroup_unlock();
> + =A0 =A0 =A0 return ret;
> +}
> +
> +static struct cftype tcp_files[] =3D {
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "kmem.tcp.max_memory",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .write_u64 =3D tcp_write_maxmem,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .read_u64 =3D tcp_read_maxmem,
> + =A0 =A0 =A0 },
> +};
> +
> =A0/*
> =A0* For ipv6, we only need to fill in the function pointers (can't initi=
alize
> =A0* things twice). So keep it separated
> @@ -487,8 +543,10 @@ int tcp_init_cgroup(struct proto *prot, struct cgrou=
p *cgrp,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgroup_subsys *ss)
> =A0{
> =A0 =A0 =A0 =A0struct mem_cgroup *cg =3D mem_cgroup_from_cont(cgrp);
> + =A0 =A0 =A0 struct mem_cgroup *parent =3D parent_mem_cgroup(cg);
> =A0 =A0 =A0 =A0unsigned long limit;
> =A0 =A0 =A0 =A0struct net *net =3D current->nsproxy->net_ns;
> + =A0 =A0 =A0 int ret =3D 0;
>
> =A0 =A0 =A0 =A0cg->tcp_memory_pressure =3D 0;
> =A0 =A0 =A0 =A0atomic_long_set(&cg->tcp_memory_allocated, 0);
> @@ -497,12 +555,25 @@ int tcp_init_cgroup(struct proto *prot, struct cgro=
up *cgrp,
> =A0 =A0 =A0 =A0limit =3D nr_free_buffer_pages() / 8;
> =A0 =A0 =A0 =A0limit =3D max(limit, 128UL);
>
> + =A0 =A0 =A0 if (parent)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cg->tcp_max_memory =3D parent->tcp_max_memo=
ry;
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cg->tcp_max_memory =3D limit * 2;
> +
> =A0 =A0 =A0 =A0cg->tcp_prot_mem[0] =3D net->ipv4.sysctl_tcp_mem[0];
> =A0 =A0 =A0 =A0cg->tcp_prot_mem[1] =3D net->ipv4.sysctl_tcp_mem[1];
> =A0 =A0 =A0 =A0cg->tcp_prot_mem[2] =3D net->ipv4.sysctl_tcp_mem[2];
>
> =A0 =A0 =A0 =A0tcp_init_cgroup_fill(prot, cgrp, ss);
> - =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* For non-root cgroup, we need to set up all tcp-related=
 variables,
> + =A0 =A0 =A0 =A0* but to be consistent with the rest of kmem management,=
 we don't
> + =A0 =A0 =A0 =A0* expose any of the controls
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (!mem_cgroup_is_root(cg))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D cgroup_add_files(cgrp, ss, tcp_file=
s,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0ARRAY_SIZE(tcp_files));
> + =A0 =A0 =A0 return ret;
> =A0}
> =A0EXPORT_SYMBOL(tcp_init_cgroup);
>
> @@ -514,6 +585,16 @@ void tcp_destroy_cgroup(struct proto *prot, struct c=
group *cgrp,
> =A0 =A0 =A0 =A0percpu_counter_destroy(&cg->tcp_sockets_allocated);
> =A0}
> =A0EXPORT_SYMBOL(tcp_destroy_cgroup);
> +
> +unsigned long tcp_max_memory(struct mem_cgroup *cg)
> +{
> + =A0 =A0 =A0 return cg->tcp_max_memory;
> +}
> +
> +void tcp_prot_mem(struct mem_cgroup *cg, long val, int idx)
> +{
> + =A0 =A0 =A0 cg->tcp_prot_mem[idx] =3D val;
> +}
> =A0#endif /* CONFIG_INET */
> =A0#endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
>
> @@ -1092,12 +1173,6 @@ static struct mem_cgroup *mem_cgroup_get_next(stru=
ct mem_cgroup *iter,
> =A0#define for_each_mem_cgroup_all(iter) \
> =A0 =A0 =A0 =A0for_each_mem_cgroup_tree_cond(iter, NULL, true)
>
> -
> -static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
> -{
> - =A0 =A0 =A0 return (mem =3D=3D root_mem_cgroup);
> -}
> -
> =A0void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_ite=
m idx)
> =A0{
> =A0 =A0 =A0 =A0struct mem_cgroup *mem;
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index bbd67ab..cdc35f6 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -14,6 +14,7 @@
> =A0#include <linux/init.h>
> =A0#include <linux/slab.h>
> =A0#include <linux/nsproxy.h>
> +#include <linux/memcontrol.h>
> =A0#include <linux/swap.h>
> =A0#include <net/snmp.h>
> =A0#include <net/icmp.h>
> @@ -182,6 +183,10 @@ static int ipv4_tcp_mem(ctl_table *ctl, int write,
> =A0 =A0 =A0 =A0int ret;
> =A0 =A0 =A0 =A0unsigned long vec[3];
> =A0 =A0 =A0 =A0struct net *net =3D current->nsproxy->net_ns;
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> + =A0 =A0 =A0 int i;
> + =A0 =A0 =A0 struct mem_cgroup *cg;
> +#endif
>
> =A0 =A0 =A0 =A0ctl_table tmp =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.data =3D &vec,
> @@ -198,6 +203,21 @@ static int ipv4_tcp_mem(ctl_table *ctl, int write,
> =A0 =A0 =A0 =A0if (ret)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ret;
>
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 cg =3D mem_cgroup_from_task(current);
> + =A0 =A0 =A0 for (i =3D 0; i < 3; i++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (vec[i] > tcp_max_memory(cg)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 tcp_prot_mem(cg, vec[0], 0);
> + =A0 =A0 =A0 tcp_prot_mem(cg, vec[1], 1);
> + =A0 =A0 =A0 tcp_prot_mem(cg, vec[2], 2);
> + =A0 =A0 =A0 rcu_read_unlock();
> +#endif
> +
> =A0 =A0 =A0 =A0net->ipv4.sysctl_tcp_mem[0] =3D vec[0];
> =A0 =A0 =A0 =A0net->ipv4.sysctl_tcp_mem[1] =3D vec[1];
> =A0 =A0 =A0 =A0net->ipv4.sysctl_tcp_mem[2] =3D vec[2];

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
