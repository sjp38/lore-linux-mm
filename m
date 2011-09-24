Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8DB899000BD
	for <linux-mm@kvack.org>; Sat, 24 Sep 2011 09:36:43 -0400 (EDT)
Message-ID: <4E7DDC94.1030801@parallels.com>
Date: Sat, 24 Sep 2011 10:35:16 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 6/7] tcp buffer limitation: per-cgroup limit
References: <1316393805-3005-1-git-send-email-glommer@parallels.com> <1316393805-3005-7-git-send-email-glommer@parallels.com> <CAKTCnzm8C4RFOxZT7Yh=Cjm8Mby1=9PXQC6c8zpzX6o-vL0EiQ@mail.gmail.com>
In-Reply-To: <CAKTCnzm8C4RFOxZT7Yh=Cjm8Mby1=9PXQC6c8zpzX6o-vL0EiQ@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name

On 09/22/2011 08:08 PM, Balbir Singh wrote:
> On Mon, Sep 19, 2011 at 6:26 AM, Glauber Costa<glommer@parallels.com>  wrote:
>> This patch uses the "tcp_max_mem" field of the kmem_cgroup to
>> effectively control the amount of kernel memory pinned by a cgroup.
>>
>> We have to make sure that none of the memory pressure thresholds
>> specified in the namespace are bigger than the current cgroup.
>>
>> Signed-off-by: Glauber Costa<glommer@parallels.com>
>> CC: David S. Miller<davem@davemloft.net>
>> CC: Hiroyouki Kamezawa<kamezawa.hiroyu@jp.fujitsu.com>
>> CC: Eric W. Biederman<ebiederm@xmission.com>
>> ---
>>   Documentation/cgroups/memory.txt |    1 +
>>   include/linux/memcontrol.h       |   10 ++++
>>   mm/memcontrol.c                  |   89 +++++++++++++++++++++++++++++++++++---
>>   net/ipv4/sysctl_net_ipv4.c       |   20 ++++++++
>>   4 files changed, 113 insertions(+), 7 deletions(-)
>>
>> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
>> index 6f1954a..1ffde3e 100644
>> --- a/Documentation/cgroups/memory.txt
>> +++ b/Documentation/cgroups/memory.txt
>> @@ -78,6 +78,7 @@ Brief summary of control files.
>>
>>   memory.independent_kmem_limit  # select whether or not kernel memory limits are
>>                                    independent of user limits
>> + memory.kmem.tcp.max_memory      # set/show hard limit for tcp buf memory
>>
>>   1. History
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 6b8c0c0..2df6db8 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -416,6 +416,9 @@ int tcp_init_cgroup_fill(struct proto *prot, struct cgroup *cgrp,
>>                          struct cgroup_subsys *ss);
>>   void tcp_destroy_cgroup(struct proto *prot, struct cgroup *cgrp,
>>                         struct cgroup_subsys *ss);
>> +
>> +unsigned long tcp_max_memory(struct mem_cgroup *cg);
>> +void tcp_prot_mem(struct mem_cgroup *cg, long val, int idx);
>>   #else
>>   /* memcontrol includes sockets.h, that includes memcontrol.h ... */
>>   static inline void memcg_sock_mem_alloc(struct mem_cgroup *mem,
>> @@ -441,6 +444,13 @@ static inline void sock_update_memcg(struct sock *sk)
>>   static inline void sock_release_memcg(struct sock *sk)
>>   {
>>   }
>> +static inline unsigned long tcp_max_memory(struct mem_cgroup *cg)
>> +{
>> +       return 0;
>> +}
>> +static inline void tcp_prot_mem(struct mem_cgroup *cg, long val, int idx)
>> +{
>> +}
>>   #endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
>>   #endif /* CONFIG_INET */
>>   #endif /* _LINUX_MEMCONTROL_H */
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 5e9b2c7..be5ab89 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -345,6 +345,7 @@ struct mem_cgroup {
>>         spinlock_t pcp_counter_lock;
>>
>>         /* per-cgroup tcp memory pressure knobs */
>> +       int tcp_max_memory;
>
> Aren't we better of abstracting this in a different structure?
> Including all the tcp parameters in that abstraction and adding that
> structure here?

Humm, I think so, yes.


>>         atomic_long_t tcp_memory_allocated;
>>         struct percpu_counter tcp_sockets_allocated;
>>         /* those two are read-mostly, leave them at the end */
>> @@ -352,6 +353,11 @@ struct mem_cgroup {
>>         int tcp_memory_pressure;
>>   };
>>
>> +static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
>> +{
>> +       return (mem == root_mem_cgroup);
>> +}
>> +
>>   static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
>>   /* Writing them here to avoid exposing memcg's inner layout */
>>   #ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>> @@ -466,6 +472,56 @@ struct percpu_counter *sockets_allocated_tcp(struct mem_cgroup *sg)
>>         return&sg->tcp_sockets_allocated;
>>   }
>>
>> +static int tcp_write_maxmem(struct cgroup *cgrp, struct cftype *cft, u64 val)
>> +{
>> +       struct mem_cgroup *sg = mem_cgroup_from_cont(cgrp);
>
> sg, I'd prefer memcg, does sg stand for socket group?
>
>> +       struct mem_cgroup *parent = parent_mem_cgroup(sg);
>> +       struct net *net = current->nsproxy->net_ns;
>> +       int i;
>> +
>> +       if (!cgroup_lock_live_group(cgrp))
>> +               return -ENODEV;
>> +
>> +       /*
>> +        * We can't allow more memory than our parents. Since this
>> +        * will be tested for all calls, by induction, there is no need
>> +        * to test any parent other than our own
>> +        * */
>> +       if (parent&&  (val>  parent->tcp_max_memory))
>> +               val = parent->tcp_max_memory;
>> +
>> +       sg->tcp_max_memory = val;
>> +
>> +       for (i = 0; i<  3; i++)
>> +               sg->tcp_prot_mem[i]  = min_t(long, val,
>> +                                            net->ipv4.sysctl_tcp_mem[i]);
>> +
>> +       cgroup_unlock();
>> +
>> +       return 0;
>> +}
>> +
>> +static u64 tcp_read_maxmem(struct cgroup *cgrp, struct cftype *cft)
>> +{
>> +       struct mem_cgroup *sg = mem_cgroup_from_cont(cgrp);
>
> sg? We generally use memcg as a convention
>
>> +       u64 ret;
>> +
>> +       if (!cgroup_lock_live_group(cgrp))
>> +               return -ENODEV;
>> +       ret = sg->tcp_max_memory;
>> +
>> +       cgroup_unlock();
>> +       return ret;
>> +}
>> +
>> +static struct cftype tcp_files[] = {
>> +       {
>> +               .name = "kmem.tcp.max_memory",
>> +               .write_u64 = tcp_write_maxmem,
>> +               .read_u64 = tcp_read_maxmem,
>> +       },
>> +};
>> +
>>   /*
>>   * For ipv6, we only need to fill in the function pointers (can't initialize
>>   * things twice). So keep it separated
>> @@ -487,8 +543,10 @@ int tcp_init_cgroup(struct proto *prot, struct cgroup *cgrp,
>>                     struct cgroup_subsys *ss)
>>   {
>>         struct mem_cgroup *cg = mem_cgroup_from_cont(cgrp);
>> +       struct mem_cgroup *parent = parent_mem_cgroup(cg);
>>         unsigned long limit;
>>         struct net *net = current->nsproxy->net_ns;
>> +       int ret = 0;
>>
>>         cg->tcp_memory_pressure = 0;
>>         atomic_long_set(&cg->tcp_memory_allocated, 0);
>> @@ -497,12 +555,25 @@ int tcp_init_cgroup(struct proto *prot, struct cgroup *cgrp,
>>         limit = nr_free_buffer_pages() / 8;
>>         limit = max(limit, 128UL);
>>
>> +       if (parent)
>> +               cg->tcp_max_memory = parent->tcp_max_memory;
>> +       else
>> +               cg->tcp_max_memory = limit * 2;
>> +
>>         cg->tcp_prot_mem[0] = net->ipv4.sysctl_tcp_mem[0];
>>         cg->tcp_prot_mem[1] = net->ipv4.sysctl_tcp_mem[1];
>>         cg->tcp_prot_mem[2] = net->ipv4.sysctl_tcp_mem[2];
>>
>>         tcp_init_cgroup_fill(prot, cgrp, ss);
>> -       return 0;
>> +       /*
>> +        * For non-root cgroup, we need to set up all tcp-related variables,
>> +        * but to be consistent with the rest of kmem management, we don't
>> +        * expose any of the controls
>> +        */
>> +       if (!mem_cgroup_is_root(cg))
>> +               ret = cgroup_add_files(cgrp, ss, tcp_files,
>> +                                      ARRAY_SIZE(tcp_files));
>> +       return ret;
>>   }
>>   EXPORT_SYMBOL(tcp_init_cgroup);
>>
>> @@ -514,6 +585,16 @@ void tcp_destroy_cgroup(struct proto *prot, struct cgroup *cgrp,
>>         percpu_counter_destroy(&cg->tcp_sockets_allocated);
>>   }
>>   EXPORT_SYMBOL(tcp_destroy_cgroup);
>> +
>> +unsigned long tcp_max_memory(struct mem_cgroup *cg)
>> +{
>> +       return cg->tcp_max_memory;
>> +}
>> +
>> +void tcp_prot_mem(struct mem_cgroup *cg, long val, int idx)
>> +{
>> +       cg->tcp_prot_mem[idx] = val;
>> +}
>>   #endif /* CONFIG_INET */
>>   #endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
>>
>> @@ -1092,12 +1173,6 @@ static struct mem_cgroup *mem_cgroup_get_next(struct mem_cgroup *iter,
>>   #define for_each_mem_cgroup_all(iter) \
>>         for_each_mem_cgroup_tree_cond(iter, NULL, true)
>>
>> -
>> -static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
>> -{
>> -       return (mem == root_mem_cgroup);
>> -}
>> -
>>   void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
>>   {
>>         struct mem_cgroup *mem;
>> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
>> index bbd67ab..cdc35f6 100644
>> --- a/net/ipv4/sysctl_net_ipv4.c
>> +++ b/net/ipv4/sysctl_net_ipv4.c
>> @@ -14,6 +14,7 @@
>>   #include<linux/init.h>
>>   #include<linux/slab.h>
>>   #include<linux/nsproxy.h>
>> +#include<linux/memcontrol.h>
>>   #include<linux/swap.h>
>>   #include<net/snmp.h>
>>   #include<net/icmp.h>
>> @@ -182,6 +183,10 @@ static int ipv4_tcp_mem(ctl_table *ctl, int write,
>>         int ret;
>>         unsigned long vec[3];
>>         struct net *net = current->nsproxy->net_ns;
>> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>> +       int i;
>> +       struct mem_cgroup *cg;
>> +#endif
>>
>>         ctl_table tmp = {
>>                 .data =&vec,
>> @@ -198,6 +203,21 @@ static int ipv4_tcp_mem(ctl_table *ctl, int write,
>>         if (ret)
>>                 return ret;
>>
>> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>> +       rcu_read_lock();
>> +       cg = mem_cgroup_from_task(current);
>> +       for (i = 0; i<  3; i++)
>> +               if (vec[i]>  tcp_max_memory(cg)) {
>> +                       rcu_read_unlock();
>> +                       return -EINVAL;
>> +               }
>> +
>> +       tcp_prot_mem(cg, vec[0], 0);
>> +       tcp_prot_mem(cg, vec[1], 1);
>> +       tcp_prot_mem(cg, vec[2], 2);
>> +       rcu_read_unlock();
>> +#endif
>> +
>>         net->ipv4.sysctl_tcp_mem[0] = vec[0];
>>         net->ipv4.sysctl_tcp_mem[1] = vec[1];
>>         net->ipv4.sysctl_tcp_mem[2] = vec[2];
>
> Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
