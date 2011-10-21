Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id EBC196B0031
	for <linux-mm@kvack.org>; Fri, 21 Oct 2011 04:40:05 -0400 (EDT)
Message-ID: <4EA12FBA.7090700@parallels.com>
Date: Fri, 21 Oct 2011 12:39:22 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFD] Isolated memory cgroups again
References: <20111020013305.GD21703@tiehlicka.suse.cz> <CALWz4ixxeFveibvqYa4cQR1a4fEBrTrTUFwm2iajk9mV0MEiTw@mail.gmail.com>
In-Reply-To: <CALWz4ixxeFveibvqYa4cQR1a4fEBrTrTUFwm2iajk9mV0MEiTw@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Kir Kolyshkin <kir@parallels.com>, Pavel Emelianov <xemul@parallels.com>, GregThelen <gthelen@google.com>, "pjt@google.com" <pjt@google.com>, Tim Hockin <thockin@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Paul Menage <paul@paulmenage.org>, James Bottomley <James.Bottomley@hansenpartnership.com>

On 10/21/2011 03:41 AM, Ying Han wrote:
> On Wed, Oct 19, 2011 at 6:33 PM, Michal Hocko<mhocko@suse.cz>  wrote:
>> Hi all,
>> this is a request for discussion (I hope we can touch this during memcg
>> meeting during the upcoming KS). I have brought this up earlier this
>> year before LSF (http://thread.gmane.org/gmane.linux.kernel.mm/60464).
>> The patch got much smaller since then due to excellent Johannes' memcg
>> naturalization work (http://thread.gmane.org/gmane.linux.kernel.mm/68724)
>> which this is based on.
>> I realize that this will be controversial but I would like to hear
>> whether this is strictly no-go or whether we can go that direction (the
>> implementation might differ of course).
>>
>> The patch is still half baked but I guess it should be sufficient to
>> show what I am trying to achieve.
>> The basic idea is that memcgs would get a new attribute (isolated) which
>> would control whether that group should be considered during global
>> reclaim.
>> This means that we could achieve a certain memory isolation for
>> processes in the group from the rest of the system activity which has
>> been traditionally done by mlocking the important parts of memory.
>> This approach, however, has some advantages. First of all, it is a kind
>> of all or nothing type of approach. Either the memory is important and
>> mlocked or you have no guarantee that it keeps resident.
>> Secondly it is much more prone to OOM situation.
>> Let's consider a case where a memory is evictable in theory but you
>> would pay quite much if you have to get it back resident (pre calculated
>> data from database - e.g. reports). The memory wouldn't be used very
>> often so it would be a number one candidate to evict after some time.
>> We would want to have something like a clever mlock in such a case which
>> would evict that memory only if the cgroup itself gets under memory
>> pressure (e.g. peak workload). This is not hard to do if we are not
>> over committing the memory but things get tricky otherwise.
>> With the isolated memcgs we get exactly such a guarantee because we would
>> reclaim such a memory only from the hard limit reclaim paths or if the
>> soft limit reclaim if it is set up.
>>
>> Any thoughts comments?
>>
>> ---
>> From: Michal Hocko<mhocko@suse.cz>
>> Subject: Implement isolated cgroups
>>
>> This patch adds a new per-cgroup knob (isolated) which controls whether
>> pages charged for the group should be considered for the global reclaim
>> or they are reclaimed only during soft reclaim and under per-cgroup
>> memory pressure.
>>
>> The value can be modified by GROUP/memory.isolated knob.
>>
>> The primary idea behind isolated cgroups is in a better isolation of a group
>> from the global system activity. At the moment, memory cgroups are mainly
>> used to throttle processes in a group by placing a cap on their memory
>> usage. However, mem. cgroups don't protect their (charged) memory from being
>> evicted by the global reclaim as groups are considered during global
>> reclaim.
>>
>> The feature will provide an easy way to setup a mission critical workload in
>> the memory isolated environment without necessity of mlock. Due to
>> per-cgroup reclaim we can even handle memory usage spikes much more
>> gracefully because a part of the working set can get reclaimed (unlike OOM
>> killed as if mlock has been used). So we can look at the feature as an
>> intelligent mlock (protect from external memory pressure and reclaim on
>> internal pressure).
>>
>> The implementation ignores isolated group status for the soft reclaim which
>> means that every isolated group can configure how much memory it can
>> sacrifice under global memory pressure. Soft unlimited groups are isolated
>> from the global memory pressure completely.
>>
>> Please note that the feature has to be used with caution because isolated
>> groups will make a bigger reclaim pressure to non-isolated cgroups.
>>
>> Implementation is really simple because we just have to hook into shrink_zone
>> and exclude isolated groups if we are doing the global reclaiming.
>>
>> Signed-off-by: Michal Hocko<mhocko@suse.cz>
>>
>> TODO
>> - consider hierarchies - I am not sure whether we want to have
>>   non-consistent isolated status in the hierarchy - probably not
>> - handle root cgroup
>> - Do we want some checks whether the current setting is safe?
>> - is bool sufficient. Don't we rather want something like priority
>>   instead?
>>
>>
>>   include/linux/memcontrol.h |    7 +++++++
>>   mm/memcontrol.c            |   44 ++++++++++++++++++++++++++++++++++++++++++++
>>   mm/vmscan.c                |    8 +++++++-
>>   3 files changed, 58 insertions(+), 1 deletion(-)
>>
>> Index: linux-3.1-rc4-next-20110831-mmotm-isolated-memcg/mm/memcontrol.c
>> ===================================================================
>> --- linux-3.1-rc4-next-20110831-mmotm-isolated-memcg.orig/mm/memcontrol.c
>> +++ linux-3.1-rc4-next-20110831-mmotm-isolated-memcg/mm/memcontrol.c
>> @@ -258,6 +258,9 @@ struct mem_cgroup {
>>         /* set when res.limit == memsw.limit */
>>         bool            memsw_is_minimum;
>>
>> +       /* is the group isolated from the global memory pressure? */
>> +       bool            isolated;
>> +
>>         /* protect arrays of thresholds */
>>         struct mutex thresholds_lock;
>>
>> @@ -287,6 +290,11 @@ struct mem_cgroup {
>>         spinlock_t pcp_counter_lock;
>>   };
>>
>> +bool mem_cgroup_isolated(struct mem_cgroup *mem)
>> +{
>> +       return mem->isolated;
>> +}
>> +
>>   /* Stuffs for move charges at task migration. */
>>   /*
>>   * Types of charges to be moved. "move_charge_at_immitgrate" is treated as a
>> @@ -4561,6 +4569,37 @@ static int mem_control_numa_stat_open(st
>>   }
>>   #endif /* CONFIG_NUMA */
>>
>> +static int mem_cgroup_isolated_write(struct cgroup *cgrp, struct cftype *cft,
>> +               const char *buffer)
>> +{
>> +       int ret = -EINVAL;
>> +       struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
>> +
>> +       if (mem_cgroup_is_root(mem))
>> +               goto out;
>> +
>> +       if (!strcasecmp(buffer, "true"))
>> +               mem->isolated = true;
>> +       else if (!strcasecmp(buffer, "false"))
>> +               mem->isolated = false;
>> +       else
>> +               goto out;
>> +
>> +       ret = 0;
>> +out:
>> +       return ret;
>> +}
>> +
>> +static int mem_cgroup_isolated_read(struct cgroup *cgrp, struct cftype *cft,
>> +               struct seq_file *seq)
>> +{
>> +       struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
>> +
>> +       seq_puts(seq, (mem->isolated)?"true":"false");
>> +
>> +       return 0;
>> +}
>> +
>>   static struct cftype mem_cgroup_files[] = {
>>         {
>>                 .name = "usage_in_bytes",
>> @@ -4624,6 +4663,11 @@ static struct cftype mem_cgroup_files[]
>>                 .unregister_event = mem_cgroup_oom_unregister_event,
>>                 .private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
>>         },
>> +       {
>> +               .name = "isolated",
>> +               .write_string = mem_cgroup_isolated_write,
>> +               .read_seq_string = mem_cgroup_isolated_read,
>> +       },
>>   #ifdef CONFIG_NUMA
>>         {
>>                 .name = "numa_stat",
>> Index: linux-3.1-rc4-next-20110831-mmotm-isolated-memcg/include/linux/memcontrol.h
>> ===================================================================
>> --- linux-3.1-rc4-next-20110831-mmotm-isolated-memcg.orig/include/linux/memcontrol.h
>> +++ linux-3.1-rc4-next-20110831-mmotm-isolated-memcg/include/linux/memcontrol.h
>> @@ -165,6 +165,9 @@ void mem_cgroup_split_huge_fixup(struct
>>   bool mem_cgroup_bad_page_check(struct page *page);
>>   void mem_cgroup_print_bad_page(struct page *page);
>>   #endif
>> +
>> +bool mem_cgroup_isolated(struct mem_cgroup *mem);
>> +
>>   #else /* CONFIG_CGROUP_MEM_RES_CTLR */
>>   struct mem_cgroup;
>>
>> @@ -382,6 +385,10 @@ static inline
>>   void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
>>   {
>>   }
>> +bool mem_cgroup_isolated(struct mem_cgroup *mem)
>> +{
>> +       return false;
>> +}
>>   #endif /* CONFIG_CGROUP_MEM_CONT */
>>
>>   #if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
>> Index: linux-3.1-rc4-next-20110831-mmotm-isolated-memcg/mm/vmscan.c
>> ===================================================================
>> --- linux-3.1-rc4-next-20110831-mmotm-isolated-memcg.orig/mm/vmscan.c
>> +++ linux-3.1-rc4-next-20110831-mmotm-isolated-memcg/mm/vmscan.c
>> @@ -2109,7 +2109,13 @@ static void shrink_zone(int priority, st
>>                         .zone = zone,
>>                 };
>>
>> -               shrink_mem_cgroup_zone(priority,&mz, sc);
>> +               /*
>> +                * Do not reclaim from an isolated group if we are in
>> +                * the global reclaim.
>> +                */
>> +               if (!(mem_cgroup_isolated(mem)&&  global_reclaim(sc)))
>> +                       shrink_mem_cgroup_zone(priority,&mz, sc);
>> +
>>                 /*
>>                  * Limit reclaim has historically picked one memcg and
>>                  * scanned it with decreasing priority levels until
>> --
>> Michal Hocko
>> SUSE Labs
>> SUSE LINUX s.r.o.
>> Lihovarska 1060/12
>> 190 00 Praha 9
>> Czech Republic
>>
>
> Hi Michal:
>
> I didn't read through the patch itself but only the description. If we
> wanna protect a memcg being reclaimed from under global memory
> pressure, I think we can approach it by making change on soft_limit
> reclaim.
>
> I have a soft_limit change built on top of Johannes's patchset, which
> does basically soft_limit aware reclaim under global memory pressure.
> The implementation is simple, and I am looking forward to discuss more
> with you guys in the conference.
>
> --Ying
I don't think soft limits will help his case, if I know understand it 
correctly. Global reclaim can be triggered regardless of any soft limits 
we may set.

Now, there are two things I still don't like about it:
* The definition of a "main workload", "main cgroup", or anything like 
that. I'd prefer to rank them according to some parameter, something 
akin to swapiness. This would allow for other people to use it in a 
different way, while still making you capable of reaching your goals 
through parameter settings (i.e. one cgroup has a high value of reclaim, 
all others, a much lower one)

* The fact that you seem to want to *skip* reclaim altogether for a 
cgroup. That's a dangerous condition, IMHO. What I think we should try 
to achieve, is "skip it for practical purposes on sane workloads". 
Again, a parameter that when set to a very high mark, has the effect of 
disallowing reclaim for a cgroup under most sane circumstances.

What do you think of the above, Michal ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
