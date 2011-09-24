Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 13E319000BD
	for <linux-mm@kvack.org>; Sat, 24 Sep 2011 10:44:29 -0400 (EDT)
Message-ID: <4E7DECA0.5020707@parallels.com>
Date: Sat, 24 Sep 2011 11:43:44 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 1/7] Basic kernel memory functionality for the Memory
 Controller
References: <1316393805-3005-1-git-send-email-glommer@parallels.com> <1316393805-3005-2-git-send-email-glommer@parallels.com> <4E794AA2.9080008@parallels.com> <CAKTCnzmkuL+9ftD5d0Z8b5w+DUSUoLiWqSX_TgGxtRxtoPsxpA@mail.gmail.com>
In-Reply-To: <CAKTCnzmkuL+9ftD5d0Z8b5w+DUSUoLiWqSX_TgGxtRxtoPsxpA@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, Ying Han <yinghan@google.com>

On 09/22/2011 12:17 AM, Balbir Singh wrote:
> On Wed, Sep 21, 2011 at 7:53 AM, Glauber Costa<glommer@parallels.com>  wrote:
>>
>> Hi people,
>>
>> Any insights on this series?
>> Kame, is it inline with your expectations ?
>>
>> Thank you all
>>
>> On 09/18/2011 09:56 PM, Glauber Costa wrote:
>>>
>>> This patch lays down the foundation for the kernel memory component
>>> of the Memory Controller.
>>>
>>> As of today, I am only laying down the following files:
>>>
>>>   * memory.independent_kmem_limit
>>>   * memory.kmem.limit_in_bytes (currently ignored)
>>>   * memory.kmem.usage_in_bytes (always zero)
>>>
>>> Signed-off-by: Glauber Costa<glommer@parallels.com>
>>> CC: Paul Menage<paul@paulmenage.org>
>>> CC: Greg Thelen<gthelen@google.com>
>>> ---
>>>   Documentation/cgroups/memory.txt |   30 +++++++++-
>>>   init/Kconfig                     |   11 ++++
>>>   mm/memcontrol.c                  |  115 ++++++++++++++++++++++++++++++++++++--
>>>   3 files changed, 148 insertions(+), 8 deletions(-)
>>>
>>> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
>>> index 6f3c598..6f1954a 100644
>>> --- a/Documentation/cgroups/memory.txt
>>> +++ b/Documentation/cgroups/memory.txt
>>> @@ -44,8 +44,9 @@ Features:
>>>    - oom-killer disable knob and oom-notifier
>>>    - Root cgroup has no limit controls.
>>>
>>> - Kernel memory and Hugepages are not under control yet. We just manage
>>> - pages on LRU. To add more controls, we have to take care of performance.
>>> + Hugepages is not under control yet. We just manage pages on LRU. To add more
>>> + controls, we have to take care of performance. Kernel memory support is work
>>> + in progress, and the current version provides basically functionality.
>>>
>>>   Brief summary of control files.
>>>
>>> @@ -56,8 +57,11 @@ Brief summary of control files.
>>>                                  (See 5.5 for details)
>>>    memory.memsw.usage_in_bytes   # show current res_counter usage for memory+Swap
>>>                                  (See 5.5 for details)
>>> + memory.kmem.usage_in_bytes     # show current res_counter usage for kmem only.
>>> +                                (See 2.7 for details)
>>>    memory.limit_in_bytes                 # set/show limit of memory usage
>>>    memory.memsw.limit_in_bytes   # set/show limit of memory+Swap usage
>>> + memory.kmem.limit_in_bytes     # if allowed, set/show limit of kernel memory
>>>    memory.failcnt                        # show the number of memory usage hits limits
>>>    memory.memsw.failcnt          # show the number of memory+Swap hits limits
>>>    memory.max_usage_in_bytes     # show max memory usage recorded
>>> @@ -72,6 +76,9 @@ Brief summary of control files.
>>>    memory.oom_control            # set/show oom controls.
>>>    memory.numa_stat              # show the number of memory usage per numa node
>>>
>>> + memory.independent_kmem_limit  # select whether or not kernel memory limits are
>>> +                                  independent of user limits
>>> +
>>>   1. History
>>>
>>>   The memory controller has a long history. A request for comments for the memory
>>> @@ -255,6 +262,25 @@ When oom event notifier is registered, event will be delivered.
>>>     per-zone-per-cgroup LRU (cgroup's private LRU) is just guarded by
>>>     zone->lru_lock, it has no lock of its own.
>>>
>>> +2.7 Kernel Memory Extension (CONFIG_CGROUP_MEM_RES_CTLR_KMEM)
>>> +
>>> + With the Kernel memory extension, the Memory Controller is able to limit
>>> +the amount of kernel memory used by the system. Kernel memory is fundamentally
>>> +different than user memory, since it can't be swapped out, which makes it
>>> +possible to DoS the system by consuming too much of this precious resource.
>>> +Kernel memory limits are not imposed for the root cgroup.
>>> +
>>> +Memory limits as specified by the standard Memory Controller may or may not
>>> +take kernel memory into consideration. This is achieved through the file
>>> +memory.independent_kmem_limit. A Value different than 0 will allow for kernel
>>> +memory to be controlled separately.
>>> +
>>> +When kernel memory limits are not independent, the limit values set in
>>> +memory.kmem files are ignored.
>>> +
>>> +Currently no soft limit is implemented for kernel memory. It is future work
>>> +to trigger slab reclaim when those limits are reached.
>>> +
>
> Ying Han was also looking into this (cc'ing her)
>
>>>   3. User Interface
>>>
>>>   0. Configuration
>>> diff --git a/init/Kconfig b/init/Kconfig
>>> index d627783..49e5839 100644
>>> --- a/init/Kconfig
>>> +++ b/init/Kconfig
>>> @@ -689,6 +689,17 @@ config CGROUP_MEM_RES_CTLR_SWAP_ENABLED
>>>           For those who want to have the feature enabled by default should
>>>           select this option (if, for some reason, they need to disable it
>>>           then swapaccount=0 does the trick).
>>> +config CGROUP_MEM_RES_CTLR_KMEM
>>> +       bool "Memory Resource Controller Kernel Memory accounting"
>>> +       depends on CGROUP_MEM_RES_CTLR
>>> +       default y
>>> +       help
>>> +         The Kernel Memory extension for Memory Resource Controller can limit
>>> +         the amount of memory used by kernel objects in the system. Those are
>>> +         fundamentally different from the entities handled by the standard
>>> +         Memory Controller, which are page-based, and can be swapped. Users of
>>> +         the kmem extension can use it to guarantee that no group of processes
>>> +         will ever exhaust kernel resources alone.
>>>
>>>   config CGROUP_PERF
>>>         bool "Enable perf_event per-cpu per-container group (cgroup) monitoring"
>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>> index ebd1e86..d32e931 100644
>>> --- a/mm/memcontrol.c
>>> +++ b/mm/memcontrol.c
>>> @@ -73,7 +73,11 @@ static int really_do_swap_account __initdata = 0;
>>>   #define do_swap_account               (0)
>>>   #endif
>>>
>>> -
>>> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>>> +int do_kmem_account __read_mostly = 1;
>>> +#else
>>> +#define do_kmem_account                0
>>> +#endif
>>>   /*
>>>    * Statistics for memory cgroup.
>>>    */
>>> @@ -270,6 +274,10 @@ struct mem_cgroup {
>>>          */
>>>         struct res_counter memsw;
>>>         /*
>>> +        * the counter to account for kmem usage.
>>> +        */
>>> +       struct res_counter kmem;
>>> +       /*
>>>          * Per cgroup active and inactive list, similar to the
>>>          * per zone LRU lists.
>>>          */
>>> @@ -321,6 +329,11 @@ struct mem_cgroup {
>>>          */
>>>         unsigned long   move_charge_at_immigrate;
>>>         /*
>>> +        * Should kernel memory limits be stabilished independently
>>> +        * from user memory ?
>>> +        */
>>> +       int             kmem_independent;
>>> +       /*
>>>          * percpu counter.
>>>          */
>>>         struct mem_cgroup_stat_cpu *stat;
>>> @@ -388,9 +401,14 @@ enum charge_type {
>>>   };
>>>
>>>   /* for encoding cft->private value on file */
>>> -#define _MEM                   (0)
>>> -#define _MEMSWAP               (1)
>>> -#define _OOM_TYPE              (2)
>>> +
>>> +enum mem_type {
>>> +       _MEM = 0,
>>> +       _MEMSWAP,
>>> +       _OOM_TYPE,
>>> +       _KMEM,
>>> +};
>>> +
>>>   #define MEMFILE_PRIVATE(x, val)       (((x)<<    16) | (val))
>>>   #define MEMFILE_TYPE(val)     (((val)>>    16)&    0xffff)
>>>   #define MEMFILE_ATTR(val)     ((val)&    0xffff)
>>> @@ -3943,10 +3961,15 @@ static inline u64 mem_cgroup_usage(struct mem_cgroup *mem, bool swap)
>>>         u64 val;
>>>
>>>         if (!mem_cgroup_is_root(mem)) {
>>> +               val = 0;
>>> +               if (!mem->kmem_independent)
>>> +                       val = res_counter_read_u64(&mem->kmem, RES_USAGE);
>>>                 if (!swap)
>>> -                       return res_counter_read_u64(&mem->res, RES_USAGE);
>>> +                       val += res_counter_read_u64(&mem->res, RES_USAGE);
>>>                 else
>>> -                       return res_counter_read_u64(&mem->memsw, RES_USAGE);
>>> +                       val += res_counter_read_u64(&mem->memsw, RES_USAGE);
>>> +
>>> +               return val;
>>>         }
>>>
>>>         val = mem_cgroup_recursive_stat(mem, MEM_CGROUP_STAT_CACHE);
>>> @@ -3979,6 +4002,10 @@ static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
>>>                 else
>>>                         val = res_counter_read_u64(&mem->memsw, name);
>>>                 break;
>>> +       case _KMEM:
>>> +               val = res_counter_read_u64(&mem->kmem, name);
>>> +               break;
>>> +
>>>         default:
>>>                 BUG();
>>>                 break;
>>> @@ -4756,6 +4783,21 @@ static int mem_cgroup_reset_vmscan_stat(struct cgroup *cgrp,
>>>         return 0;
>>>   }
>>>
>>> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>>> +static u64 kmem_limit_independent_read(struct cgroup *cont, struct cftype *cft)
>>> +{
>>> +       return mem_cgroup_from_cont(cont)->kmem_independent;
>>> +}
>>> +
>>> +static int kmem_limit_independent_write(struct cgroup *cont, struct cftype *cft,
>>> +                                       u64 val)
>>> +{
>>> +       cgroup_lock();
>>> +       mem_cgroup_from_cont(cont)->kmem_independent = !!val;
>>> +       cgroup_unlock();
>>> +       return 0;
>>> +}
>
> I know we have a lot of pending xxx_from_cont() and struct cgroup
> *cont, can we move it to memcg notation to be more consistent with our
> usage. There is a patch to convert old usage
>

Hello Balbir, I missed this comment. What exactly do you propose in this 
patch, since I have to assume that the patch you talk about is not 
applied? Is it just a change to the parameter name that you propose?

Thank you

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
