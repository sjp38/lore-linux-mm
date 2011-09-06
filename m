Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4013D6B016A
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 12:17:31 -0400 (EDT)
Message-ID: <4E664766.40200@parallels.com>
Date: Tue, 6 Sep 2011 13:16:38 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] per-cgroup tcp buffer limitation
References: <1315276556-10970-1-git-send-email-glommer@parallels.com> <CAHH2K0aJxjinSu0Ek6jzsZ5dBmm5mEU-typuwYWYWEudF2F3Qg@mail.gmail.com>
In-Reply-To: <CAHH2K0aJxjinSu0Ek6jzsZ5dBmm5mEU-typuwYWYWEudF2F3Qg@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, "David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>

On 09/06/2011 01:08 PM, Greg Thelen wrote:
> On Mon, Sep 5, 2011 at 7:35 PM, Glauber Costa<glommer@parallels.com>  wrote:
>> This patch introduces per-cgroup tcp buffers limitation. This allows
>> sysadmins to specify a maximum amount of kernel memory that
>> tcp connections can use at any point in time. TCP is the main interest
>> in this work, but extending it to other protocols would be easy.

Hello Greg,

> With this approach we would be giving admins the ability to
> independently limit user memory with memcg and kernel memory with this
> new kmem cgroup.
>
> At least in some situations admins prefer to give a particular
> container X bytes without thinking about the kernel vs user split.
> Sometimes the admin would prefer the kernel to keep the total
> user+kernel memory below a certain threshold.  To achieve this with
> this approach would we need a user space agent to monitor both kernel
> and user usage for a container and grow/shrink memcg/kmem limits?
Yes, I believe so. And this is not only valid for containers: the 
information we expose in proc, sys, cgroups, etc, is always much more 
fine grained than a considerable part of the users want. Tools come to 
fill this gap.

>
> Do you foresee the kmem cgroup growing to include reclaimable slab,
> where freeing one type of memory allows for reclaim of the other?
Yes, absolutely.

>
>> It piggybacks in the memory control mechanism already present in
>> /proc/sys/net/ipv4/tcp_mem. There is a soft limit, and a hard limit,
>> that will suppress allocation when reached. For each cgroup, however,
>> the file kmem.tcp_maxmem will be used to cap those values.
>>
>> The usage I have in mind here is containers. Each container will
>> define its own values for soft and hard limits, but none of them will
>> be possibly bigger than the value the box' sysadmin specified from
>> the outside.
>>
>> To test for any performance impacts of this patch, I used netperf's
>> TCP_RR benchmark on localhost, so we can have both recv and snd in action.
>>
>> Command line used was ./src/netperf -t TCP_RR -H localhost, and the
>> results:
>>
>> Without the patch
>> =================
>>
>> Socket Size   Request  Resp.   Elapsed  Trans.
>> Send   Recv   Size     Size    Time     Rate
>> bytes  Bytes  bytes    bytes   secs.    per sec
>>
>> 16384  87380  1        1       10.00    26996.35
>> 16384  87380
>>
>> With the patch
>> ===============
>>
>> Local /Remote
>> Socket Size   Request  Resp.   Elapsed  Trans.
>> Send   Recv   Size     Size    Time     Rate
>> bytes  Bytes  bytes    bytes   secs.    per sec
>>
>> 16384  87380  1        1       10.00    27291.86
>> 16384  87380
>>
>> The difference is within a one-percent range.
>>
>> Nesting cgroups doesn't seem to be the dominating factor as well,
>> with nestings up to 10 levels not showing a significant performance
>> difference.
>>
>> Signed-off-by: Glauber Costa<glommer@parallels.com>
>> CC: David S. Miller<davem@davemloft.net>
>> CC: Hiroyouki Kamezawa<kamezawa.hiroyu@jp.fujitsu.com>
>> CC: Eric W. Biederman<ebiederm@xmission.com>
>> ---
>>   crypto/af_alg.c               |    7 ++-
>>   include/linux/cgroup_subsys.h |    4 +
>>   include/net/netns/ipv4.h      |    1 +
>>   include/net/sock.h            |   66 +++++++++++++++-
>>   include/net/tcp.h             |   12 ++-
>>   include/net/udp.h             |    3 +-
>>   include/trace/events/sock.h   |   10 +-
>>   init/Kconfig                  |   11 +++
>>   mm/Makefile                   |    1 +
>>   net/core/sock.c               |  136 +++++++++++++++++++++++++++-------
>>   net/decnet/af_decnet.c        |   21 +++++-
>>   net/ipv4/proc.c               |    8 +-
>>   net/ipv4/sysctl_net_ipv4.c    |   59 +++++++++++++--
>>   net/ipv4/tcp.c                |  164 +++++++++++++++++++++++++++++++++++-----
>>   net/ipv4/tcp_input.c          |   17 ++--
>>   net/ipv4/tcp_ipv4.c           |   27 +++++--
>>   net/ipv4/tcp_output.c         |    2 +-
>>   net/ipv4/tcp_timer.c          |    2 +-
>>   net/ipv4/udp.c                |   20 ++++-
>>   net/ipv6/tcp_ipv6.c           |   16 +++-
>>   net/ipv6/udp.c                |    4 +-
>>   net/sctp/socket.c             |   35 +++++++--
>>   22 files changed, 514 insertions(+), 112 deletions(-)
>>
>> diff --git a/crypto/af_alg.c b/crypto/af_alg.c
>> index ac33d5f..df168d8 100644
>> --- a/crypto/af_alg.c
>> +++ b/crypto/af_alg.c
>> @@ -29,10 +29,15 @@ struct alg_type_list {
>>
>>   static atomic_long_t alg_memory_allocated;
>>
>> +static atomic_long_t *memory_allocated_alg(struct kmem_cgroup *sg)
>> +{
>> +       return&alg_memory_allocated;
>> +}
>> +
>>   static struct proto alg_proto = {
>>         .name                   = "ALG",
>>         .owner                  = THIS_MODULE,
>> -       .memory_allocated       =&alg_memory_allocated,
>> +       .memory_allocated       = memory_allocated_alg,
>>         .obj_size               = sizeof(struct alg_sock),
>>   };
>>
>> diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
>> index ac663c1..363b8e8 100644
>> --- a/include/linux/cgroup_subsys.h
>> +++ b/include/linux/cgroup_subsys.h
>> @@ -35,6 +35,10 @@ SUBSYS(cpuacct)
>>   SUBSYS(mem_cgroup)
>>   #endif
>>
>> +#ifdef CONFIG_CGROUP_KMEM
>> +SUBSYS(kmem)
>> +#endif
>> +
>>   /* */
>>
>>   #ifdef CONFIG_CGROUP_DEVICE
>> diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
>> index d786b4f..bbd023a 100644
>> --- a/include/net/netns/ipv4.h
>> +++ b/include/net/netns/ipv4.h
>> @@ -55,6 +55,7 @@ struct netns_ipv4 {
>>         int current_rt_cache_rebuild_count;
>>
>>         unsigned int sysctl_ping_group_range[2];
>> +       long sysctl_tcp_mem[3];
>>
>>         atomic_t rt_genid;
>>         atomic_t dev_addr_genid;
>> diff --git a/include/net/sock.h b/include/net/sock.h
>> index 8e4062f..e085148 100644
>> --- a/include/net/sock.h
>> +++ b/include/net/sock.h
>> @@ -62,7 +62,9 @@
>>   #include<linux/atomic.h>
>>   #include<net/dst.h>
>>   #include<net/checksum.h>
>> +#include<linux/kmem_cgroup.h>
>>
>> +int sockets_populate(struct cgroup_subsys *ss, struct cgroup *cgrp);
>>   /*
>>   * This structure really needs to be cleaned up.
>>   * Most of it is for TCP, and not used by any of
>> @@ -339,6 +341,7 @@ struct sock {
>>   #endif
>>         __u32                   sk_mark;
>>         u32                     sk_classid;
>> +       struct kmem_cgroup      *sk_cgrp;
>>         void                    (*sk_state_change)(struct sock *sk);
>>         void                    (*sk_data_ready)(struct sock *sk, int bytes);
>>         void                    (*sk_write_space)(struct sock *sk);
>> @@ -786,16 +789,21 @@ struct proto {
>>
>>         /* Memory pressure */
>>         void                    (*enter_memory_pressure)(struct sock *sk);
>> -       atomic_long_t           *memory_allocated;      /* Current allocated memory. */
>> -       struct percpu_counter   *sockets_allocated;     /* Current number of sockets. */
>> +       /* Current allocated memory. */
>> +       atomic_long_t           *(*memory_allocated)(struct kmem_cgroup *sg);
>> +       /* Current number of sockets. */
>> +       struct percpu_counter   *(*sockets_allocated)(struct kmem_cgroup *sg);
>> +
>> +       int                     (*init_cgroup)(struct cgroup *cgrp,
>> +                                              struct cgroup_subsys *ss);
>>         /*
>>          * Pressure flag: try to collapse.
>>          * Technical note: it is used by multiple contexts non atomically.
>>          * All the __sk_mem_schedule() is of this nature: accounting
>>          * is strict, actions are advisory and have some latency.
>>          */
>> -       int                     *memory_pressure;
>> -       long                    *sysctl_mem;
>> +       int                     *(*memory_pressure)(struct kmem_cgroup *sg);
>> +       long                    *(*prot_mem)(struct kmem_cgroup *sg);
>>         int                     *sysctl_wmem;
>>         int                     *sysctl_rmem;
>>         int                     max_header;
>> @@ -826,6 +834,56 @@ struct proto {
>>   #endif
>>   };
>>
>> +#define sk_memory_pressure(sk)                                         \
>> +({                                                                     \
>> +       int *__ret = NULL;                                              \
>> +       if ((sk)->sk_prot->memory_pressure)                             \
>> +               __ret = (sk)->sk_prot->memory_pressure(sk->sk_cgrp);    \
>> +       __ret;                                                          \
>> +})
>> +
>> +#define sk_sockets_allocated(sk)                               \
>> +({                                                             \
>> +       struct percpu_counter *__p;                             \
>> +       __p = (sk)->sk_prot->sockets_allocated(sk->sk_cgrp);    \
>> +       __p;                                                    \
>> +})
>> +
>> +#define sk_memory_allocated(sk)                                        \
>> +({                                                             \
>> +       atomic_long_t *__mem;                                   \
>> +       __mem = (sk)->sk_prot->memory_allocated(sk->sk_cgrp);   \
>> +       __mem;                                                  \
>> +})
>> +
>> +#define sk_prot_mem(sk)                                                \
>> +({                                                             \
>> +       long *__mem = (sk)->sk_prot->prot_mem(sk->sk_cgrp);     \
>> +       __mem;                                                  \
>> +})
>> +
>> +#define sg_memory_pressure(prot, sg)                           \
>> +({                                                             \
>> +       int *__ret = NULL;                                      \
>> +       if (prot->memory_pressure)                              \
>> +               __ret = (prot)->memory_pressure(sg);            \
>> +       __ret;                                                  \
>> +})
>> +
>> +#define sg_memory_allocated(prot, sg)                          \
>> +({                                                             \
>> +       atomic_long_t *__mem;                                   \
>> +       __mem = (prot)->memory_allocated(sg);                   \
>> +       __mem;                                                  \
>> +})
>> +
>> +#define sg_sockets_allocated(prot, sg)                         \
>> +({                                                             \
>> +       struct percpu_counter *__p;                             \
>> +       __p = (prot)->sockets_allocated(sg);                    \
>> +       __p;                                                    \
>> +})
>> +
>>   extern int proto_register(struct proto *prot, int alloc_slab);
>>   extern void proto_unregister(struct proto *prot);
>>
>> diff --git a/include/net/tcp.h b/include/net/tcp.h
>> index 149a415..8e1ec4a 100644
>> --- a/include/net/tcp.h
>> +++ b/include/net/tcp.h
>> @@ -230,7 +230,6 @@ extern int sysctl_tcp_fack;
>>   extern int sysctl_tcp_reordering;
>>   extern int sysctl_tcp_ecn;
>>   extern int sysctl_tcp_dsack;
>> -extern long sysctl_tcp_mem[3];
>>   extern int sysctl_tcp_wmem[3];
>>   extern int sysctl_tcp_rmem[3];
>>   extern int sysctl_tcp_app_win;
>> @@ -253,9 +252,12 @@ extern int sysctl_tcp_cookie_size;
>>   extern int sysctl_tcp_thin_linear_timeouts;
>>   extern int sysctl_tcp_thin_dupack;
>>
>> -extern atomic_long_t tcp_memory_allocated;
>> -extern struct percpu_counter tcp_sockets_allocated;
>> -extern int tcp_memory_pressure;
>> +struct kmem_cgroup;
>> +extern long *tcp_sysctl_mem(struct kmem_cgroup *sg);
>> +struct percpu_counter *sockets_allocated_tcp(struct kmem_cgroup *sg);
>> +int *memory_pressure_tcp(struct kmem_cgroup *sg);
>> +int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss);
>> +atomic_long_t *memory_allocated_tcp(struct kmem_cgroup *sg);
>>
>>   /*
>>   * The next routines deal with comparing 32 bit unsigned ints
>> @@ -286,7 +288,7 @@ static inline bool tcp_too_many_orphans(struct sock *sk, int shift)
>>         }
>>
>>         if (sk->sk_wmem_queued>  SOCK_MIN_SNDBUF&&
>> -           atomic_long_read(&tcp_memory_allocated)>  sysctl_tcp_mem[2])
>> +           atomic_long_read(sk_memory_allocated(sk))>  sk_prot_mem(sk)[2])
>>                 return true;
>>         return false;
>>   }
>> diff --git a/include/net/udp.h b/include/net/udp.h
>> index 67ea6fc..0e27388 100644
>> --- a/include/net/udp.h
>> +++ b/include/net/udp.h
>> @@ -105,7 +105,8 @@ static inline struct udp_hslot *udp_hashslot2(struct udp_table *table,
>>
>>   extern struct proto udp_prot;
>>
>> -extern atomic_long_t udp_memory_allocated;
>> +atomic_long_t *memory_allocated_udp(struct kmem_cgroup *sg);
>> +long *udp_sysctl_mem(struct kmem_cgroup *sg);
>>
>>   /* sysctl variables for udp */
>>   extern long sysctl_udp_mem[3];
>> diff --git a/include/trace/events/sock.h b/include/trace/events/sock.h
>> index 779abb9..12a6083 100644
>> --- a/include/trace/events/sock.h
>> +++ b/include/trace/events/sock.h
>> @@ -37,7 +37,7 @@ TRACE_EVENT(sock_exceed_buf_limit,
>>
>>         TP_STRUCT__entry(
>>                 __array(char, name, 32)
>> -               __field(long *, sysctl_mem)
>> +               __field(long *, prot_mem)
>>                 __field(long, allocated)
>>                 __field(int, sysctl_rmem)
>>                 __field(int, rmem_alloc)
>> @@ -45,7 +45,7 @@ TRACE_EVENT(sock_exceed_buf_limit,
>>
>>         TP_fast_assign(
>>                 strncpy(__entry->name, prot->name, 32);
>> -               __entry->sysctl_mem = prot->sysctl_mem;
>> +               __entry->prot_mem = sk->sk_prot->prot_mem(sk->sk_cgrp);
>>                 __entry->allocated = allocated;
>>                 __entry->sysctl_rmem = prot->sysctl_rmem[0];
>>                 __entry->rmem_alloc = atomic_read(&sk->sk_rmem_alloc);
>> @@ -54,9 +54,9 @@ TRACE_EVENT(sock_exceed_buf_limit,
>>         TP_printk("proto:%s sysctl_mem=%ld,%ld,%ld allocated=%ld "
>>                 "sysctl_rmem=%d rmem_alloc=%d",
>>                 __entry->name,
>> -               __entry->sysctl_mem[0],
>> -               __entry->sysctl_mem[1],
>> -               __entry->sysctl_mem[2],
>> +               __entry->prot_mem[0],
>> +               __entry->prot_mem[1],
>> +               __entry->prot_mem[2],
>>                 __entry->allocated,
>>                 __entry->sysctl_rmem,
>>                 __entry->rmem_alloc)
>> diff --git a/init/Kconfig b/init/Kconfig
>> index d627783..5955ac2 100644
>> --- a/init/Kconfig
>> +++ b/init/Kconfig
>> @@ -690,6 +690,17 @@ config CGROUP_MEM_RES_CTLR_SWAP_ENABLED
>>           select this option (if, for some reason, they need to disable it
>>           then swapaccount=0 does the trick).
>>
>> +config CGROUP_KMEM
>> +       bool "Kernel Memory Resource Controller for Control Groups"
>> +       depends on CGROUPS
>> +       help
>> +         The Kernel Memory cgroup can limit the amount of memory used by
>> +         certain kernel objects in the system. Those are fundamentally
>> +         different from the entities handled by the Memory Controller,
>> +         which are page-based, and can be swapped. Users of the kmem
>> +         cgroup can use it to guarantee that no group of processes will
>> +         ever exhaust kernel resources alone.
>> +
>>   config CGROUP_PERF
>>         bool "Enable perf_event per-cpu per-container group (cgroup) monitoring"
>>         depends on PERF_EVENTS&&  CGROUPS
>> diff --git a/mm/Makefile b/mm/Makefile
>> index 836e416..1b1aa24 100644
>> --- a/mm/Makefile
>> +++ b/mm/Makefile
>> @@ -45,6 +45,7 @@ obj-$(CONFIG_MIGRATION) += migrate.o
>>   obj-$(CONFIG_QUICKLIST) += quicklist.o
>>   obj-$(CONFIG_TRANSPARENT_HUGEPAGE) += huge_memory.o
>>   obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
>> +obj-$(CONFIG_CGROUP_KMEM) += kmem_cgroup.o
>>   obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
>>   obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
>>   obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
>> diff --git a/net/core/sock.c b/net/core/sock.c
>> index 3449df8..2d968ea 100644
>> --- a/net/core/sock.c
>> +++ b/net/core/sock.c
>> @@ -134,6 +134,24 @@
>>   #include<net/tcp.h>
>>   #endif
>>
>> +static DEFINE_RWLOCK(proto_list_lock);
>> +static LIST_HEAD(proto_list);
>> +
>> +int sockets_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
>> +{
>> +       struct proto *proto;
>> +       int ret = 0;
>> +
>> +       read_lock(&proto_list_lock);
>> +       list_for_each_entry(proto,&proto_list, node) {
>> +               if (proto->init_cgroup)
>> +                       ret |= proto->init_cgroup(cgrp, ss);
>> +       }
>> +       read_unlock(&proto_list_lock);
>> +
>> +       return ret;
>> +}
>> +
>>   /*
>>   * Each address family might have different locking rules, so we have
>>   * one slock key per address family:
>> @@ -1114,6 +1132,31 @@ void sock_update_classid(struct sock *sk)
>>   EXPORT_SYMBOL(sock_update_classid);
>>   #endif
>>
>> +void sock_update_kmem_cgrp(struct sock *sk)
>> +{
>> +#ifdef CONFIG_CGROUP_KMEM
>> +       sk->sk_cgrp = kcg_from_task(current);
>> +
>> +       /*
>> +        * We don't need to protect against anything task-related, because
>> +        * we are basically stuck with the sock pointer that won't change,
>> +        * even if the task that originated the socket changes cgroups.
>> +        *
>> +        * What we do have to guarantee, is that the chain leading us to
>> +        * the top level won't change under our noses. Incrementing the
>> +        * reference count via cgroup_exclude_rmdir guarantees that.
>> +        */
>> +       cgroup_exclude_rmdir(&sk->sk_cgrp->css);
>> +#endif
>> +}
>> +
>> +void sock_release_kmem_cgrp(struct sock *sk)
>> +{
>> +#ifdef CONFIG_CGROUP_KMEM
>> +       cgroup_release_and_wakeup_rmdir(&sk->sk_cgrp->css);
>> +#endif
>> +}
>> +
>>   /**
>>   *     sk_alloc - All socket objects are allocated here
>>   *     @net: the applicable net namespace
>> @@ -1139,6 +1182,7 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
>>                 atomic_set(&sk->sk_wmem_alloc, 1);
>>
>>                 sock_update_classid(sk);
>> +               sock_update_kmem_cgrp(sk);
>>         }
>>
>>         return sk;
>> @@ -1170,6 +1214,7 @@ static void __sk_free(struct sock *sk)
>>                 put_cred(sk->sk_peer_cred);
>>         put_pid(sk->sk_peer_pid);
>>         put_net(sock_net(sk));
>> +       sock_release_kmem_cgrp(sk);
>>         sk_prot_free(sk->sk_prot_creator, sk);
>>   }
>>
>> @@ -1287,8 +1332,8 @@ struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
>>                 sk_set_socket(newsk, NULL);
>>                 newsk->sk_wq = NULL;
>>
>> -               if (newsk->sk_prot->sockets_allocated)
>> -                       percpu_counter_inc(newsk->sk_prot->sockets_allocated);
>> +               if (sk_sockets_allocated(sk))
>> +                       percpu_counter_inc(sk_sockets_allocated(sk));
>>
>>                 if (sock_flag(newsk, SOCK_TIMESTAMP) ||
>>                     sock_flag(newsk, SOCK_TIMESTAMPING_RX_SOFTWARE))
>> @@ -1676,29 +1721,51 @@ EXPORT_SYMBOL(sk_wait_data);
>>   */
>>   int __sk_mem_schedule(struct sock *sk, int size, int kind)
>>   {
>> -       struct proto *prot = sk->sk_prot;
>>         int amt = sk_mem_pages(size);
>> +       struct proto *prot = sk->sk_prot;
>>         long allocated;
>> +       int *memory_pressure;
>> +       long *prot_mem;
>> +       int parent_failure = 0;
>> +       struct kmem_cgroup *sg;
>>
>>         sk->sk_forward_alloc += amt * SK_MEM_QUANTUM;
>> -       allocated = atomic_long_add_return(amt, prot->memory_allocated);
>> +
>> +       memory_pressure = sk_memory_pressure(sk);
>> +       prot_mem = sk_prot_mem(sk);
>> +
>> +       allocated = atomic_long_add_return(amt, sk_memory_allocated(sk));
>> +
>> +#ifdef CONFIG_CGROUP_KMEM
>> +       for (sg = sk->sk_cgrp->parent; sg != NULL; sg = sg->parent) {
>> +               long alloc;
>> +               /*
>> +                * Large nestings are not the common case, and stopping in the
>> +                * middle would be complicated enough, that we bill it all the
>> +                * way through the root, and if needed, unbill everything later
>> +                */
>> +               alloc = atomic_long_add_return(amt,
>> +                                              sg_memory_allocated(prot, sg));
>> +               parent_failure |= (alloc>  sk_prot_mem(sk)[2]);
>> +       }
>> +#endif
>> +
>> +       /* Over hard limit (we, or our parents) */
>> +       if (parent_failure || (allocated>  prot_mem[2]))
>> +               goto suppress_allocation;
>>
>>         /* Under limit. */
>> -       if (allocated<= prot->sysctl_mem[0]) {
>> -               if (prot->memory_pressure&&  *prot->memory_pressure)
>> -                       *prot->memory_pressure = 0;
>> +       if (allocated<= prot_mem[0]) {
>> +               if (memory_pressure&&  *memory_pressure)
>> +                       *memory_pressure = 0;
>>                 return 1;
>>         }
>>
>>         /* Under pressure. */
>> -       if (allocated>  prot->sysctl_mem[1])
>> +       if (allocated>  prot_mem[1])
>>                 if (prot->enter_memory_pressure)
>>                         prot->enter_memory_pressure(sk);
>>
>> -       /* Over hard limit. */
>> -       if (allocated>  prot->sysctl_mem[2])
>> -               goto suppress_allocation;
>> -
>>         /* guarantee minimum buffer size under pressure */
>>         if (kind == SK_MEM_RECV) {
>>                 if (atomic_read(&sk->sk_rmem_alloc)<  prot->sysctl_rmem[0])
>> @@ -1712,13 +1779,13 @@ int __sk_mem_schedule(struct sock *sk, int size, int kind)
>>                                 return 1;
>>         }
>>
>> -       if (prot->memory_pressure) {
>> +       if (memory_pressure) {
>>                 int alloc;
>>
>> -               if (!*prot->memory_pressure)
>> +               if (!*memory_pressure)
>>                         return 1;
>> -               alloc = percpu_counter_read_positive(prot->sockets_allocated);
>> -               if (prot->sysctl_mem[2]>  alloc *
>> +               alloc = percpu_counter_read_positive(sk_sockets_allocated(sk));
>> +               if (prot_mem[2]>  alloc *
>>                     sk_mem_pages(sk->sk_wmem_queued +
>>                                  atomic_read(&sk->sk_rmem_alloc) +
>>                                  sk->sk_forward_alloc))
>> @@ -1741,7 +1808,13 @@ suppress_allocation:
>>
>>         /* Alas. Undo changes. */
>>         sk->sk_forward_alloc -= amt * SK_MEM_QUANTUM;
>> -       atomic_long_sub(amt, prot->memory_allocated);
>> +
>> +       atomic_long_sub(amt, sk_memory_allocated(sk));
>> +
>> +#ifdef CONFIG_CGROUP_KMEM
>> +       for (sg = sk->sk_cgrp->parent; sg != NULL; sg = sg->parent)
>> +               atomic_long_sub(amt, sg_memory_allocated(prot, sg));
>> +#endif
>>         return 0;
>>   }
>>   EXPORT_SYMBOL(__sk_mem_schedule);
>> @@ -1753,14 +1826,24 @@ EXPORT_SYMBOL(__sk_mem_schedule);
>>   void __sk_mem_reclaim(struct sock *sk)
>>   {
>>         struct proto *prot = sk->sk_prot;
>> +       struct kmem_cgroup *sg = sk->sk_cgrp;
>> +       int *memory_pressure = sk_memory_pressure(sk);
>>
>>         atomic_long_sub(sk->sk_forward_alloc>>  SK_MEM_QUANTUM_SHIFT,
>> -                  prot->memory_allocated);
>> +                  sk_memory_allocated(sk));
>> +
>> +#ifdef CONFIG_CGROUP_KMEM
>> +       for (sg = sk->sk_cgrp->parent; sg != NULL; sg = sg->parent) {
>> +               atomic_long_sub(sk->sk_forward_alloc>>  SK_MEM_QUANTUM_SHIFT,
>> +                                               sg_memory_allocated(prot, sg));
>> +       }
>> +#endif
>> +
>>         sk->sk_forward_alloc&= SK_MEM_QUANTUM - 1;
>>
>> -       if (prot->memory_pressure&&  *prot->memory_pressure&&
>> -           (atomic_long_read(prot->memory_allocated)<  prot->sysctl_mem[0]))
>> -               *prot->memory_pressure = 0;
>> +       if (memory_pressure&&  *memory_pressure&&
>> +           (atomic_long_read(sk_memory_allocated(sk))<  sk_prot_mem(sk)[0]))
>> +               *memory_pressure = 0;
>>   }
>>   EXPORT_SYMBOL(__sk_mem_reclaim);
>>
>> @@ -2252,9 +2335,6 @@ void sk_common_release(struct sock *sk)
>>   }
>>   EXPORT_SYMBOL(sk_common_release);
>>
>> -static DEFINE_RWLOCK(proto_list_lock);
>> -static LIST_HEAD(proto_list);
>> -
>>   #ifdef CONFIG_PROC_FS
>>   #define PROTO_INUSE_NR 64      /* should be enough for the first time */
>>   struct prot_inuse {
>> @@ -2479,13 +2559,17 @@ static char proto_method_implemented(const void *method)
>>
>>   static void proto_seq_printf(struct seq_file *seq, struct proto *proto)
>>   {
>> +       struct kmem_cgroup *sg = kcg_from_task(current);
>> +
>>         seq_printf(seq, "%-9s %4u %6d  %6ld   %-3s %6u   %-3s  %-10s "
>>                         "%2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c\n",
>>                    proto->name,
>>                    proto->obj_size,
>>                    sock_prot_inuse_get(seq_file_net(seq), proto),
>> -                  proto->memory_allocated != NULL ? atomic_long_read(proto->memory_allocated) : -1L,
>> -                  proto->memory_pressure != NULL ? *proto->memory_pressure ? "yes" : "no" : "NI",
>> +                  proto->memory_allocated != NULL ?
>> +                       atomic_long_read(sg_memory_allocated(proto, sg)) : -1L,
>> +                  proto->memory_pressure != NULL ?
>> +                       *sg_memory_pressure(proto, sg) ? "yes" : "no" : "NI",
>>                    proto->max_header,
>>                    proto->slab == NULL ? "no" : "yes",
>>                    module_name(proto->owner),
>> diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
>> index 19acd00..463b299 100644
>> --- a/net/decnet/af_decnet.c
>> +++ b/net/decnet/af_decnet.c
>> @@ -458,13 +458,28 @@ static void dn_enter_memory_pressure(struct sock *sk)
>>         }
>>   }
>>
>> +static atomic_long_t *memory_allocated_dn(struct kmem_cgroup *sg)
>> +{
>> +       return&decnet_memory_allocated;
>> +}
>> +
>> +static int *memory_pressure_dn(struct kmem_cgroup *sg)
>> +{
>> +       return&dn_memory_pressure;
>> +}
>> +
>> +static long *dn_sysctl_mem(struct kmem_cgroup *sg)
>> +{
>> +       return sysctl_decnet_mem;
>> +}
>> +
>>   static struct proto dn_proto = {
>>         .name                   = "NSP",
>>         .owner                  = THIS_MODULE,
>>         .enter_memory_pressure  = dn_enter_memory_pressure,
>> -       .memory_pressure        =&dn_memory_pressure,
>> -       .memory_allocated       =&decnet_memory_allocated,
>> -       .sysctl_mem             = sysctl_decnet_mem,
>> +       .memory_pressure        = memory_pressure_dn,
>> +       .memory_allocated       = memory_allocated_dn,
>> +       .prot_mem               = dn_sysctl_mem,
>>         .sysctl_wmem            = sysctl_decnet_wmem,
>>         .sysctl_rmem            = sysctl_decnet_rmem,
>>         .max_header             = DN_MAX_NSP_DATA_HEADER + 64,
>> diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
>> index b14ec7d..9c80acf 100644
>> --- a/net/ipv4/proc.c
>> +++ b/net/ipv4/proc.c
>> @@ -52,20 +52,22 @@ static int sockstat_seq_show(struct seq_file *seq, void *v)
>>   {
>>         struct net *net = seq->private;
>>         int orphans, sockets;
>> +       struct kmem_cgroup *sg = kcg_from_task(current);
>> +       struct percpu_counter *allocated = sg_sockets_allocated(&tcp_prot, sg);
>>
>>         local_bh_disable();
>>         orphans = percpu_counter_sum_positive(&tcp_orphan_count);
>> -       sockets = percpu_counter_sum_positive(&tcp_sockets_allocated);
>> +       sockets = percpu_counter_sum_positive(allocated);
>>         local_bh_enable();
>>
>>         socket_seq_show(seq);
>>         seq_printf(seq, "TCP: inuse %d orphan %d tw %d alloc %d mem %ld\n",
>>                    sock_prot_inuse_get(net,&tcp_prot), orphans,
>>                    tcp_death_row.tw_count, sockets,
>> -                  atomic_long_read(&tcp_memory_allocated));
>> +                  atomic_long_read(sg_memory_allocated((&tcp_prot), sg)));
>>         seq_printf(seq, "UDP: inuse %d mem %ld\n",
>>                    sock_prot_inuse_get(net,&udp_prot),
>> -                  atomic_long_read(&udp_memory_allocated));
>> +                  atomic_long_read(sg_memory_allocated((&udp_prot), sg)));
>>         seq_printf(seq, "UDPLITE: inuse %d\n",
>>                    sock_prot_inuse_get(net,&udplite_prot));
>>         seq_printf(seq, "RAW: inuse %d\n",
>> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
>> index 69fd720..5e89480 100644
>> --- a/net/ipv4/sysctl_net_ipv4.c
>> +++ b/net/ipv4/sysctl_net_ipv4.c
>> @@ -14,6 +14,8 @@
>>   #include<linux/init.h>
>>   #include<linux/slab.h>
>>   #include<linux/nsproxy.h>
>> +#include<linux/kmem_cgroup.h>
>> +#include<linux/swap.h>
>>   #include<net/snmp.h>
>>   #include<net/icmp.h>
>>   #include<net/ip.h>
>> @@ -174,6 +176,43 @@ static int proc_allowed_congestion_control(ctl_table *ctl,
>>         return ret;
>>   }
>>
>> +static int ipv4_tcp_mem(ctl_table *ctl, int write,
>> +                          void __user *buffer, size_t *lenp,
>> +                          loff_t *ppos)
>> +{
>> +       int ret;
>> +       unsigned long vec[3];
>> +       struct kmem_cgroup *kmem = kcg_from_task(current);
>> +       struct net *net = current->nsproxy->net_ns;
>> +       int i;
>> +
>> +       ctl_table tmp = {
>> +               .data =&vec,
>> +               .maxlen = sizeof(vec),
>> +               .mode = ctl->mode,
>> +       };
>> +
>> +       if (!write) {
>> +               ctl->data =&net->ipv4.sysctl_tcp_mem;
>> +               return proc_doulongvec_minmax(ctl, write, buffer, lenp, ppos);
>> +       }
>> +
>> +       ret = proc_doulongvec_minmax(&tmp, write, buffer, lenp, ppos);
>> +       if (ret)
>> +               return ret;
>> +
>> +       for (i = 0; i<  3; i++)
>> +               if (vec[i]>  kmem->tcp_max_memory)
>> +                       return -EINVAL;
>> +
>> +       for (i = 0; i<  3; i++) {
>> +               net->ipv4.sysctl_tcp_mem[i] = vec[i];
>> +               kmem->tcp_prot_mem[i] = net->ipv4.sysctl_tcp_mem[i];
>> +       }
>> +
>> +       return 0;
>> +}
>> +
>>   static struct ctl_table ipv4_table[] = {
>>         {
>>                 .procname       = "tcp_timestamps",
>> @@ -433,13 +472,6 @@ static struct ctl_table ipv4_table[] = {
>>                 .proc_handler   = proc_dointvec
>>         },
>>         {
>> -               .procname       = "tcp_mem",
>> -               .data           =&sysctl_tcp_mem,
>> -               .maxlen         = sizeof(sysctl_tcp_mem),
>> -               .mode           = 0644,
>> -               .proc_handler   = proc_doulongvec_minmax
>> -       },
>> -       {
>>                 .procname       = "tcp_wmem",
>>                 .data           =&sysctl_tcp_wmem,
>>                 .maxlen         = sizeof(sysctl_tcp_wmem),
>> @@ -721,6 +753,12 @@ static struct ctl_table ipv4_net_table[] = {
>>                 .mode           = 0644,
>>                 .proc_handler   = ipv4_ping_group_range,
>>         },
>> +       {
>> +               .procname       = "tcp_mem",
>> +               .maxlen         = sizeof(init_net.ipv4.sysctl_tcp_mem),
>> +               .mode           = 0644,
>> +               .proc_handler   = ipv4_tcp_mem,
>> +       },
>>         { }
>>   };
>>
>> @@ -734,6 +772,7 @@ EXPORT_SYMBOL_GPL(net_ipv4_ctl_path);
>>   static __net_init int ipv4_sysctl_init_net(struct net *net)
>>   {
>>         struct ctl_table *table;
>> +       unsigned long limit;
>>
>>         table = ipv4_net_table;
>>         if (!net_eq(net,&init_net)) {
>> @@ -769,6 +808,12 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
>>
>>         net->ipv4.sysctl_rt_cache_rebuild_count = 4;
>>
>> +       limit = nr_free_buffer_pages() / 8;
>> +       limit = max(limit, 128UL);
>> +       net->ipv4.sysctl_tcp_mem[0] = limit / 4 * 3;
>> +       net->ipv4.sysctl_tcp_mem[1] = limit;
>> +       net->ipv4.sysctl_tcp_mem[2] = net->ipv4.sysctl_tcp_mem[0] * 2;
>> +
>>         net->ipv4.ipv4_hdr = register_net_sysctl_table(net,
>>                         net_ipv4_ctl_path, table);
>>         if (net->ipv4.ipv4_hdr == NULL)
>> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
>> index 46febca..e1918fa 100644
>> --- a/net/ipv4/tcp.c
>> +++ b/net/ipv4/tcp.c
>> @@ -266,6 +266,7 @@
>>   #include<linux/crypto.h>
>>   #include<linux/time.h>
>>   #include<linux/slab.h>
>> +#include<linux/nsproxy.h>
>>
>>   #include<net/icmp.h>
>>   #include<net/tcp.h>
>> @@ -282,23 +283,12 @@ int sysctl_tcp_fin_timeout __read_mostly = TCP_FIN_TIMEOUT;
>>   struct percpu_counter tcp_orphan_count;
>>   EXPORT_SYMBOL_GPL(tcp_orphan_count);
>>
>> -long sysctl_tcp_mem[3] __read_mostly;
>>   int sysctl_tcp_wmem[3] __read_mostly;
>>   int sysctl_tcp_rmem[3] __read_mostly;
>>
>> -EXPORT_SYMBOL(sysctl_tcp_mem);
>>   EXPORT_SYMBOL(sysctl_tcp_rmem);
>>   EXPORT_SYMBOL(sysctl_tcp_wmem);
>>
>> -atomic_long_t tcp_memory_allocated;    /* Current allocated memory. */
>> -EXPORT_SYMBOL(tcp_memory_allocated);
>> -
>> -/*
>> - * Current number of TCP sockets.
>> - */
>> -struct percpu_counter tcp_sockets_allocated;
>> -EXPORT_SYMBOL(tcp_sockets_allocated);
>> -
>>   /*
>>   * TCP splice context
>>   */
>> @@ -308,23 +298,157 @@ struct tcp_splice_state {
>>         unsigned int flags;
>>   };
>>
>> +#ifdef CONFIG_CGROUP_KMEM
>>   /*
>>   * Pressure flag: try to collapse.
>>   * Technical note: it is used by multiple contexts non atomically.
>>   * All the __sk_mem_schedule() is of this nature: accounting
>>   * is strict, actions are advisory and have some latency.
>>   */
>> -int tcp_memory_pressure __read_mostly;
>> -EXPORT_SYMBOL(tcp_memory_pressure);
>> -
>>   void tcp_enter_memory_pressure(struct sock *sk)
>>   {
>> +       struct kmem_cgroup *sg = sk->sk_cgrp;
>> +       if (!sg->tcp_memory_pressure) {
>> +               NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPMEMORYPRESSURES);
>> +               sg->tcp_memory_pressure = 1;
>> +       }
>> +}
>> +
>> +long *tcp_sysctl_mem(struct kmem_cgroup *sg)
>> +{
>> +       return sg->tcp_prot_mem;
>> +}
>> +
>> +atomic_long_t *memory_allocated_tcp(struct kmem_cgroup *sg)
>> +{
>> +       return&(sg->tcp_memory_allocated);
>> +}
>> +
>> +static int tcp_write_maxmem(struct cgroup *cgrp, struct cftype *cft, u64 val)
>> +{
>> +       struct kmem_cgroup *sg = kcg_from_cgroup(cgrp);
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
>> +       if (sg->parent&&  (val>  sg->parent->tcp_max_memory))
>> +               val = sg->parent->tcp_max_memory;
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
>> +       struct kmem_cgroup *sg = kcg_from_cgroup(cgrp);
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
>> +               .name = "tcp_maxmem",
>> +               .write_u64 = tcp_write_maxmem,
>> +               .read_u64 = tcp_read_maxmem,
>> +       },
>> +};
>> +
>> +int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss)
>> +{
>> +       struct kmem_cgroup *sg = kcg_from_cgroup(cgrp);
>> +       unsigned long limit;
>> +       struct net *net = current->nsproxy->net_ns;
>> +
>> +       sg->tcp_memory_pressure = 0;
>> +       atomic_long_set(&sg->tcp_memory_allocated, 0);
>> +       percpu_counter_init(&sg->tcp_sockets_allocated, 0);
>> +
>> +       limit = nr_free_buffer_pages() / 8;
>> +       limit = max(limit, 128UL);
>> +
>> +       if (sg->parent)
>> +               sg->tcp_max_memory = sg->parent->tcp_max_memory;
>> +       else
>> +               sg->tcp_max_memory = limit * 2;
>> +
>> +       sg->tcp_prot_mem[0] = net->ipv4.sysctl_tcp_mem[0];
>> +       sg->tcp_prot_mem[1] = net->ipv4.sysctl_tcp_mem[1];
>> +       sg->tcp_prot_mem[2] = net->ipv4.sysctl_tcp_mem[2];
>> +
>> +       return cgroup_add_files(cgrp, ss, tcp_files, ARRAY_SIZE(tcp_files));
>> +}
>> +EXPORT_SYMBOL(tcp_init_cgroup);
>> +
>> +int *memory_pressure_tcp(struct kmem_cgroup *sg)
>> +{
>> +       return&sg->tcp_memory_pressure;
>> +}
>> +
>> +struct percpu_counter *sockets_allocated_tcp(struct kmem_cgroup *sg)
>> +{
>> +       return&sg->tcp_sockets_allocated;
>> +}
>> +#else
>> +
>> +/* Current number of TCP sockets. */
>> +struct percpu_counter tcp_sockets_allocated;
>> +atomic_long_t tcp_memory_allocated;    /* Current allocated memory. */
>> +int tcp_memory_pressure;
>> +
>> +int *memory_pressure_tcp(struct kmem_cgroup *sg)
>> +{
>> +       return&tcp_memory_pressure;
>> +}
>> +
>> +struct percpu_counter *sockets_allocated_tcp(struct kmem_cgroup *sg)
>> +{
>> +       return&tcp_sockets_allocated;
>> +}
>> +
>> +void tcp_enter_memory_pressure(struct sock *sock)
>> +{
>>         if (!tcp_memory_pressure) {
>>                 NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPMEMORYPRESSURES);
>>                 tcp_memory_pressure = 1;
>>         }
>>   }
>> +
>> +long *tcp_sysctl_mem(struct kmem_cgroup *sg)
>> +{
>> +       return init_net.ipv4.sysctl_tcp_mem;
>> +}
>> +
>> +atomic_long_t *memory_allocated_tcp(struct kmem_cgroup *sg)
>> +{
>> +       return&tcp_memory_allocated;
>> +}
>> +#endif /* CONFIG_CGROUP_KMEM */
>> +
>> +EXPORT_SYMBOL(memory_pressure_tcp);
>> +EXPORT_SYMBOL(sockets_allocated_tcp);
>>   EXPORT_SYMBOL(tcp_enter_memory_pressure);
>> +EXPORT_SYMBOL(tcp_sysctl_mem);
>> +EXPORT_SYMBOL(memory_allocated_tcp);
>>
>>   /* Convert seconds to retransmits based on initial and max timeout */
>>   static u8 secs_to_retrans(int seconds, int timeout, int rto_max)
>> @@ -3226,7 +3350,9 @@ void __init tcp_init(void)
>>
>>         BUILD_BUG_ON(sizeof(struct tcp_skb_cb)>  sizeof(skb->cb));
>>
>> +#ifndef CONFIG_CGROUP_KMEM
>>         percpu_counter_init(&tcp_sockets_allocated, 0);
>> +#endif
>>         percpu_counter_init(&tcp_orphan_count, 0);
>>         tcp_hashinfo.bind_bucket_cachep =
>>                 kmem_cache_create("tcp_bind_bucket",
>> @@ -3277,14 +3403,10 @@ void __init tcp_init(void)
>>         sysctl_tcp_max_orphans = cnt / 2;
>>         sysctl_max_syn_backlog = max(128, cnt / 256);
>>
>> -       limit = nr_free_buffer_pages() / 8;
>> -       limit = max(limit, 128UL);
>> -       sysctl_tcp_mem[0] = limit / 4 * 3;
>> -       sysctl_tcp_mem[1] = limit;
>> -       sysctl_tcp_mem[2] = sysctl_tcp_mem[0] * 2;
>> -
>>         /* Set per-socket limits to no more than 1/128 the pressure threshold */
>> -       limit = ((unsigned long)sysctl_tcp_mem[1])<<  (PAGE_SHIFT - 7);
>> +       limit = (unsigned long)init_net.ipv4.sysctl_tcp_mem[1];
>> +       limit<<= (PAGE_SHIFT - 7);
>> +
>>         max_share = min(4UL*1024*1024, limit);
>>
>>         sysctl_tcp_wmem[0] = SK_MEM_QUANTUM;
>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> index ea0d218..c44e830 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
>> @@ -316,7 +316,7 @@ static void tcp_grow_window(struct sock *sk, struct sk_buff *skb)
>>         /* Check #1 */
>>         if (tp->rcv_ssthresh<  tp->window_clamp&&
>>             (int)tp->rcv_ssthresh<  tcp_space(sk)&&
>> -           !tcp_memory_pressure) {
>> +           !sk_memory_pressure(sk)) {
>>                 int incr;
>>
>>                 /* Check #2. Increase window, if skb with such overhead
>> @@ -393,15 +393,16 @@ static void tcp_clamp_window(struct sock *sk)
>>   {
>>         struct tcp_sock *tp = tcp_sk(sk);
>>         struct inet_connection_sock *icsk = inet_csk(sk);
>> +       struct proto *prot = sk->sk_prot;
>>
>>         icsk->icsk_ack.quick = 0;
>>
>> -       if (sk->sk_rcvbuf<  sysctl_tcp_rmem[2]&&
>> +       if (sk->sk_rcvbuf<  prot->sysctl_rmem[2]&&
>>             !(sk->sk_userlocks&  SOCK_RCVBUF_LOCK)&&
>> -           !tcp_memory_pressure&&
>> -           atomic_long_read(&tcp_memory_allocated)<  sysctl_tcp_mem[0]) {
>> +           !sk_memory_pressure(sk)&&
>> +           atomic_long_read(sk_memory_allocated(sk))<  sk_prot_mem(sk)[0]) {
>>                 sk->sk_rcvbuf = min(atomic_read(&sk->sk_rmem_alloc),
>> -                                   sysctl_tcp_rmem[2]);
>> +                                   prot->sysctl_rmem[2]);
>>         }
>>         if (atomic_read(&sk->sk_rmem_alloc)>  sk->sk_rcvbuf)
>>                 tp->rcv_ssthresh = min(tp->window_clamp, 2U * tp->advmss);
>> @@ -4806,7 +4807,7 @@ static int tcp_prune_queue(struct sock *sk)
>>
>>         if (atomic_read(&sk->sk_rmem_alloc)>= sk->sk_rcvbuf)
>>                 tcp_clamp_window(sk);
>> -       else if (tcp_memory_pressure)
>> +       else if (sk_memory_pressure(sk))
>>                 tp->rcv_ssthresh = min(tp->rcv_ssthresh, 4U * tp->advmss);
>>
>>         tcp_collapse_ofo_queue(sk);
>> @@ -4872,11 +4873,11 @@ static int tcp_should_expand_sndbuf(struct sock *sk)
>>                 return 0;
>>
>>         /* If we are under global TCP memory pressure, do not expand.  */
>> -       if (tcp_memory_pressure)
>> +       if (sk_memory_pressure(sk))
>>                 return 0;
>>
>>         /* If we are under soft global TCP memory pressure, do not expand.  */
>> -       if (atomic_long_read(&tcp_memory_allocated)>= sysctl_tcp_mem[0])
>> +       if (atomic_long_read(sk_memory_allocated(sk))>= sk_prot_mem(sk)[0])
>>                 return 0;
>>
>>         /* If we filled the congestion window, do not expand.  */
>> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
>> index 1c12b8e..af6c095 100644
>> --- a/net/ipv4/tcp_ipv4.c
>> +++ b/net/ipv4/tcp_ipv4.c
>> @@ -1848,6 +1848,7 @@ static int tcp_v4_init_sock(struct sock *sk)
>>   {
>>         struct inet_connection_sock *icsk = inet_csk(sk);
>>         struct tcp_sock *tp = tcp_sk(sk);
>> +       struct kmem_cgroup *sg;
>>
>>         skb_queue_head_init(&tp->out_of_order_queue);
>>         tcp_init_xmit_timers(sk);
>> @@ -1901,7 +1902,13 @@ static int tcp_v4_init_sock(struct sock *sk)
>>         sk->sk_rcvbuf = sysctl_tcp_rmem[1];
>>
>>         local_bh_disable();
>> -       percpu_counter_inc(&tcp_sockets_allocated);
>> +       percpu_counter_inc(sk_sockets_allocated(sk));
>> +
>> +#ifdef CONFIG_CGROUP_KMEM
>> +       for (sg = sk->sk_cgrp->parent; sg; sg = sg->parent)
>> +               percpu_counter_inc(sg_sockets_allocated(sk->sk_prot, sg));
>> +#endif
>> +
>>         local_bh_enable();
>>
>>         return 0;
>> @@ -1910,6 +1917,7 @@ static int tcp_v4_init_sock(struct sock *sk)
>>   void tcp_v4_destroy_sock(struct sock *sk)
>>   {
>>         struct tcp_sock *tp = tcp_sk(sk);
>> +       struct kmem_cgroup *sg;
>>
>>         tcp_clear_xmit_timers(sk);
>>
>> @@ -1957,7 +1965,11 @@ void tcp_v4_destroy_sock(struct sock *sk)
>>                 tp->cookie_values = NULL;
>>         }
>>
>> -       percpu_counter_dec(&tcp_sockets_allocated);
>> +       percpu_counter_dec(sk_sockets_allocated(sk));
>> +#ifdef CONFIG_CGROUP_KMEM
>> +       for (sg = sk->sk_cgrp->parent; sg; sg = sg->parent)
>> +               percpu_counter_dec(sg_sockets_allocated(sk->sk_prot, sg));
>> +#endif
>>   }
>>   EXPORT_SYMBOL(tcp_v4_destroy_sock);
>>
>> @@ -2598,11 +2610,14 @@ struct proto tcp_prot = {
>>         .unhash                 = inet_unhash,
>>         .get_port               = inet_csk_get_port,
>>         .enter_memory_pressure  = tcp_enter_memory_pressure,
>> -       .sockets_allocated      =&tcp_sockets_allocated,
>> +       .memory_pressure        = memory_pressure_tcp,
>> +       .sockets_allocated      = sockets_allocated_tcp,
>>         .orphan_count           =&tcp_orphan_count,
>> -       .memory_allocated       =&tcp_memory_allocated,
>> -       .memory_pressure        =&tcp_memory_pressure,
>> -       .sysctl_mem             = sysctl_tcp_mem,
>> +       .memory_allocated       = memory_allocated_tcp,
>> +#ifdef CONFIG_CGROUP_KMEM
>> +       .init_cgroup            = tcp_init_cgroup,
>> +#endif
>> +       .prot_mem               = tcp_sysctl_mem,
>>         .sysctl_wmem            = sysctl_tcp_wmem,
>>         .sysctl_rmem            = sysctl_tcp_rmem,
>>         .max_header             = MAX_TCP_HEADER,
>> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
>> index 882e0b0..06aeb31 100644
>> --- a/net/ipv4/tcp_output.c
>> +++ b/net/ipv4/tcp_output.c
>> @@ -1912,7 +1912,7 @@ u32 __tcp_select_window(struct sock *sk)
>>         if (free_space<  (full_space>>  1)) {
>>                 icsk->icsk_ack.quick = 0;
>>
>> -               if (tcp_memory_pressure)
>> +               if (sk_memory_pressure(sk))
>>                         tp->rcv_ssthresh = min(tp->rcv_ssthresh,
>>                                                4U * tp->advmss);
>>
>> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
>> index ecd44b0..2c67617 100644
>> --- a/net/ipv4/tcp_timer.c
>> +++ b/net/ipv4/tcp_timer.c
>> @@ -261,7 +261,7 @@ static void tcp_delack_timer(unsigned long data)
>>         }
>>
>>   out:
>> -       if (tcp_memory_pressure)
>> +       if (sk_memory_pressure(sk))
>>                 sk_mem_reclaim(sk);
>>   out_unlock:
>>         bh_unlock_sock(sk);
>> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
>> index 1b5a193..6c08c65 100644
>> --- a/net/ipv4/udp.c
>> +++ b/net/ipv4/udp.c
>> @@ -120,9 +120,6 @@ EXPORT_SYMBOL(sysctl_udp_rmem_min);
>>   int sysctl_udp_wmem_min __read_mostly;
>>   EXPORT_SYMBOL(sysctl_udp_wmem_min);
>>
>> -atomic_long_t udp_memory_allocated;
>> -EXPORT_SYMBOL(udp_memory_allocated);
>> -
>>   #define MAX_UDP_PORTS 65536
>>   #define PORTS_PER_CHAIN (MAX_UDP_PORTS / UDP_HTABLE_SIZE_MIN)
>>
>> @@ -1918,6 +1915,19 @@ unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait)
>>   }
>>   EXPORT_SYMBOL(udp_poll);
>>
>> +static atomic_long_t udp_memory_allocated;
>> +atomic_long_t *memory_allocated_udp(struct kmem_cgroup *sg)
>> +{
>> +       return&udp_memory_allocated;
>> +}
>> +EXPORT_SYMBOL(memory_allocated_udp);
>> +
>> +long *udp_sysctl_mem(struct kmem_cgroup *sg)
>> +{
>> +       return sysctl_udp_mem;
>> +}
>> +EXPORT_SYMBOL(udp_sysctl_mem);
>> +
>>   struct proto udp_prot = {
>>         .name              = "UDP",
>>         .owner             = THIS_MODULE,
>> @@ -1936,8 +1946,8 @@ struct proto udp_prot = {
>>         .unhash            = udp_lib_unhash,
>>         .rehash            = udp_v4_rehash,
>>         .get_port          = udp_v4_get_port,
>> -       .memory_allocated  =&udp_memory_allocated,
>> -       .sysctl_mem        = sysctl_udp_mem,
>> +       .memory_allocated  =&memory_allocated_udp,
>> +       .prot_mem          = udp_sysctl_mem,
>>         .sysctl_wmem       =&sysctl_udp_wmem_min,
>>         .sysctl_rmem       =&sysctl_udp_rmem_min,
>>         .obj_size          = sizeof(struct udp_sock),
>> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
>> index d1fb63f..0762e68 100644
>> --- a/net/ipv6/tcp_ipv6.c
>> +++ b/net/ipv6/tcp_ipv6.c
>> @@ -1959,6 +1959,7 @@ static int tcp_v6_init_sock(struct sock *sk)
>>   {
>>         struct inet_connection_sock *icsk = inet_csk(sk);
>>         struct tcp_sock *tp = tcp_sk(sk);
>> +       struct kmem_cgroup *sg;
>>
>>         skb_queue_head_init(&tp->out_of_order_queue);
>>         tcp_init_xmit_timers(sk);
>> @@ -2012,7 +2013,12 @@ static int tcp_v6_init_sock(struct sock *sk)
>>         sk->sk_rcvbuf = sysctl_tcp_rmem[1];
>>
>>         local_bh_disable();
>> -       percpu_counter_inc(&tcp_sockets_allocated);
>> +       percpu_counter_inc(sk_sockets_allocated(sk));
>> +#ifdef CONFIG_CGROUP_KMEM
>> +       for (sg = sk->sk_cgrp->parent; sg; sg = sg->parent)
>> +               percpu_counter_dec(sg_sockets_allocated(sk->sk_prot, sg));
>> +#endif
>> +
>>         local_bh_enable();
>>
>>         return 0;
>> @@ -2221,11 +2227,11 @@ struct proto tcpv6_prot = {
>>         .unhash                 = inet_unhash,
>>         .get_port               = inet_csk_get_port,
>>         .enter_memory_pressure  = tcp_enter_memory_pressure,
>> -       .sockets_allocated      =&tcp_sockets_allocated,
>> -       .memory_allocated       =&tcp_memory_allocated,
>> -       .memory_pressure        =&tcp_memory_pressure,
>> +       .sockets_allocated      = sockets_allocated_tcp,
>> +       .memory_allocated       = memory_allocated_tcp,
>> +       .memory_pressure        = memory_pressure_tcp,
>>         .orphan_count           =&tcp_orphan_count,
>> -       .sysctl_mem             = sysctl_tcp_mem,
>> +       .prot_mem               = tcp_sysctl_mem,
>>         .sysctl_wmem            = sysctl_tcp_wmem,
>>         .sysctl_rmem            = sysctl_tcp_rmem,
>>         .max_header             = MAX_TCP_HEADER,
>> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
>> index 29213b5..ef4b5b3 100644
>> --- a/net/ipv6/udp.c
>> +++ b/net/ipv6/udp.c
>> @@ -1465,8 +1465,8 @@ struct proto udpv6_prot = {
>>         .unhash            = udp_lib_unhash,
>>         .rehash            = udp_v6_rehash,
>>         .get_port          = udp_v6_get_port,
>> -       .memory_allocated  =&udp_memory_allocated,
>> -       .sysctl_mem        = sysctl_udp_mem,
>> +       .memory_allocated  = memory_allocated_udp,
>> +       .prot_mem          = udp_sysctl_mem,
>>         .sysctl_wmem       =&sysctl_udp_wmem_min,
>>         .sysctl_rmem       =&sysctl_udp_rmem_min,
>>         .obj_size          = sizeof(struct udp6_sock),
>> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
>> index 836aa63..1b0300d 100644
>> --- a/net/sctp/socket.c
>> +++ b/net/sctp/socket.c
>> @@ -119,11 +119,30 @@ static int sctp_memory_pressure;
>>   static atomic_long_t sctp_memory_allocated;
>>   struct percpu_counter sctp_sockets_allocated;
>>
>> +static long *sctp_sysctl_mem(struct kmem_cgroup *sg)
>> +{
>> +       return sysctl_sctp_mem;
>> +}
>> +
>>   static void sctp_enter_memory_pressure(struct sock *sk)
>>   {
>>         sctp_memory_pressure = 1;
>>   }
>>
>> +static int *memory_pressure_sctp(struct kmem_cgroup *sg)
>> +{
>> +       return&sctp_memory_pressure;
>> +}
>> +
>> +static atomic_long_t *memory_allocated_sctp(struct kmem_cgroup *sg)
>> +{
>> +       return&sctp_memory_allocated;
>> +}
>> +
>> +static struct percpu_counter *sockets_allocated_sctp(struct kmem_cgroup *sg)
>> +{
>> +       return&sctp_sockets_allocated;
>> +}
>>
>>   /* Get the sndbuf space available at the time on the association.  */
>>   static inline int sctp_wspace(struct sctp_association *asoc)
>> @@ -6831,13 +6850,13 @@ struct proto sctp_prot = {
>>         .unhash      =  sctp_unhash,
>>         .get_port    =  sctp_get_port,
>>         .obj_size    =  sizeof(struct sctp_sock),
>> -       .sysctl_mem  =  sysctl_sctp_mem,
>> +       .prot_mem    =  sctp_sysctl_mem,
>>         .sysctl_rmem =  sysctl_sctp_rmem,
>>         .sysctl_wmem =  sysctl_sctp_wmem,
>> -       .memory_pressure =&sctp_memory_pressure,
>> +       .memory_pressure = memory_pressure_sctp,
>>         .enter_memory_pressure = sctp_enter_memory_pressure,
>> -       .memory_allocated =&sctp_memory_allocated,
>> -       .sockets_allocated =&sctp_sockets_allocated,
>> +       .memory_allocated = memory_allocated_sctp,
>> +       .sockets_allocated = sockets_allocated_sctp,
>>   };
>>
>>   #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
>> @@ -6863,12 +6882,12 @@ struct proto sctpv6_prot = {
>>         .unhash         = sctp_unhash,
>>         .get_port       = sctp_get_port,
>>         .obj_size       = sizeof(struct sctp6_sock),
>> -       .sysctl_mem     = sysctl_sctp_mem,
>> +       .prot_mem       = sctp_sysctl_mem,
>>         .sysctl_rmem    = sysctl_sctp_rmem,
>>         .sysctl_wmem    = sysctl_sctp_wmem,
>> -       .memory_pressure =&sctp_memory_pressure,
>> +       .memory_pressure = memory_pressure_sctp,
>>         .enter_memory_pressure = sctp_enter_memory_pressure,
>> -       .memory_allocated =&sctp_memory_allocated,
>> -       .sockets_allocated =&sctp_sockets_allocated,
>> +       .memory_allocated = memory_allocated_sctp,
>> +       .sockets_allocated = sockets_allocated_sctp,
>>   };
>>   #endif /* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
>> --
>> 1.7.6
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
>> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
