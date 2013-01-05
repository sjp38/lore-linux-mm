Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id DD30F6B005D
	for <linux-mm@kvack.org>; Sat,  5 Jan 2013 05:52:12 -0500 (EST)
Received: by mail-ia0-f179.google.com with SMTP id o25so14523349iad.24
        for <linux-mm@kvack.org>; Sat, 05 Jan 2013 02:52:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20130102122712.GE22160@dhcp22.suse.cz>
References: <1356455919-14445-1-git-send-email-handai.szj@taobao.com>
	<1356456447-14740-1-git-send-email-handai.szj@taobao.com>
	<20130102122712.GE22160@dhcp22.suse.cz>
Date: Sat, 5 Jan 2013 18:52:12 +0800
Message-ID: <CAFj3OHWBtu9-7SdVJnMnUytjL9i3i2xEfoB=y_zA_5HXir9o0g@mail.gmail.com>
Subject: Re: [PATCH V3 6/8] memcg: Don't account root_mem_cgroup page statistics
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, gthelen@google.com, fengguang.wu@intel.com, glommer@parallels.com, Sha Zhengju <handai.szj@taobao.com>

On Wed, Jan 2, 2013 at 8:27 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Wed 26-12-12 01:27:27, Sha Zhengju wrote:
>> From: Sha Zhengju <handai.szj@taobao.com>
>>
>> If memcg is enabled and no non-root memcg exists, all allocated pages
>> belongs to root_mem_cgroup and go through root memcg statistics routines
>> which brings some overheads. So for the sake of performance, we can give
>> up accounting stats of root memcg for MEM_CGROUP_STAT_FILE_MAPPED/FILE_DIRTY
>> /WRITEBACK
>
> I do not like this selective approach. We should handle all the stat
> types in the same way. SWAP is not a hot path but RSS and CACHE should
> be optimized as well. It seems that thresholds events might be a
> complication here but it shouldn't be that a big deal (mem_cgroup_usage
> would need some treat).
>

The three MEM_CGROUP_STAT_FILE_{MAPPED, DIRTY, WRITEBACK} stat
are accounted in the similar way: all of them are embedded in original global
accounting routine and have mem_cgroup_update_page_stat() as the unified
accounting entry. But RSS/CACHE/SWAP are counted in memcg charging periods
and may extend the patch larger... so I just want to send this out to
collect opinion.
Now from the feedback, I think I can continue the remaining in next round.


>> and instead we pay special attention while showing root
>> memcg numbers in memcg_stat_show(): as we don't account root memcg stats
>> anymore, the root_mem_cgroup->stat numbers are actually 0.
>
> Yes, this is reasonable.
>
>> But because of hierachy, figures of root_mem_cgroup may just represent
>> numbers of pages used by its own tasks(not belonging to any other
>> child cgroup).
>
> I am not sure what the above means. root might have use_hierarchy set to
> 1 as well.
>

Yes, my fault for not clear here. What I mean is we can not simply set numbers
of root memcg to global state. Whether root.use_hierarchy is 1 or 0, the figures
of root memcg are behalf of its local page stat (the difference exists
in total_* stat).
So we can fake these root numbers out by using stats of global state and
all other memcg.

>> So here we fake these root numbers by using stats of global state and
>> all other memcg.  That is for root memcg:
>>       nr(MEM_CGROUP_STAT_FILE_MAPPED) = global_page_state(NR_FILE_MAPPED) -
>>                               sum_of_all_memcg(MEM_CGROUP_STAT_FILE_MAPPED);
>> Dirty/Writeback pages accounting are in the similar way.
>>
>> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
>
> I like the approach but I do not like the implementation. See details
> bellow.
>
>> ---
>>  mm/memcontrol.c |   70 +++++++++++++++++++++++++++++++++++++++++++++++++++++--
>>  1 file changed, 68 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index fc20ac9..728349d 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
> [...]
>> @@ -5396,18 +5406,70 @@ static inline void mem_cgroup_lru_names_not_uptodate(void)
>>       BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_lru_names) != NR_LRU_LISTS);
>>  }
>>
>> +long long root_memcg_local_stat(unsigned int i, long long val,
>> +                                     long long nstat[])
>
> Function should be static
> also
> nstat parameter is ugly because this can be done by the caller
> and also expecting that the caller already calculated val is not
> nice (and undocumented). This approach is really hackish and error
> prone. Why should we define a specific function rather than hooking into
> mem_cgroup_read_stat and doing all the stuff there? I think that would
> be much more maintainable.
>

IMHO, hooking into mem_cgroup_read_stat may be also improper because
of the for_each_mem_cgroup traversal. I prefer to make mem_cgroup_read_stat
as the base func unit. But I'll repeal the function base on your opinion in next
version.  Thanks for the advice!

>> +{
>> +     long long res = 0;
>> +
>> +     switch (i) {
>> +     case MEM_CGROUP_STAT_FILE_MAPPED:
>> +             res = global_page_state(NR_FILE_MAPPED);
>> +             break;
>> +     case MEM_CGROUP_STAT_FILE_DIRTY:
>> +             res = global_page_state(NR_FILE_DIRTY);
>> +             break;
>> +     case MEM_CGROUP_STAT_WRITEBACK:
>> +             res = global_page_state(NR_WRITEBACK);
>> +             break;
>> +     default:
>> +             break;
>> +     }
>> +
>> +     res = (res <= val) ? 0 : (res - val) * PAGE_SIZE;
>> +     nstat[i] = res;
>> +
>> +     return res;
>> +}
>> +
>>  static int memcg_stat_show(struct cgroup *cont, struct cftype *cft,
>>                                struct seq_file *m)
>>  {
>>       struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
>>       struct mem_cgroup *mi;
>>       unsigned int i;
>> +     long long nstat[MEM_CGROUP_STAT_NSTATS] = {0};
>
> s/nstat/root_stat/
>
>>
>>       for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
>> +             long long val = 0, res = 0;
>> +
>>               if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
>>                       continue;
>> -             seq_printf(m, "%s %ld\n", mem_cgroup_stat_names[i],
>> -                        mem_cgroup_read_stat(memcg, i) * PAGE_SIZE);
>> +             if (i == MEM_CGROUP_STAT_SWAP || i == MEM_CGROUP_STAT_CACHE ||
>> +                     i == MEM_CGROUP_STAT_RSS) {
>
> This is plain ugly. If nothing else it asks for a comment why those are
> special.

Okay, more comments will be added.


Thanks,
Sha

>
>> +                     seq_printf(m, "%s %ld\n", mem_cgroup_stat_names[i],
>> +                                mem_cgroup_read_stat(memcg, i) * PAGE_SIZE);
>> +                     continue;
>> +             }
>> +
>> +             /* As we don't account root memcg stats anymore, the
>> +              * root_mem_cgroup->stat numbers are actually 0. But because of
>> +              * hierachy, figures of root_mem_cgroup may just represent
>> +              * numbers of pages used by its own tasks(not belonging to any
>> +              * other child cgroup). So here we fake these root numbers by
>> +              * using stats of global state and all other memcg. That is for
>> +              * root memcg:
>> +              * nr(MEM_CGROUP_STAT_FILE_MAPPED) = global_page_state(NR_FILE_
>> +              *      MAPPED) - sum_of_all_memcg(MEM_CGROUP_STAT_FILE_MAPPED)
>> +              * Dirty/Writeback pages accounting are in the similar way.
>> +              */
>> +             if (memcg == root_mem_cgroup) {
>> +                     for_each_mem_cgroup(mi)
>> +                             val += mem_cgroup_read_stat(mi, i);
>> +                     res = root_memcg_local_stat(i, val, nstat);
>> +             } else
>> +                     res = mem_cgroup_read_stat(memcg, i) * PAGE_SIZE;
>> +
>> +             seq_printf(m, "%s %lld\n", mem_cgroup_stat_names[i], res);
>>       }
>>
>>       for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++)
>> @@ -5435,6 +5497,10 @@ static int memcg_stat_show(struct cgroup *cont, struct cftype *cft,
>>                       continue;
>>               for_each_mem_cgroup_tree(mi, memcg)
>>                       val += mem_cgroup_read_stat(mi, i) * PAGE_SIZE;
>> +
>> +             /* Adding local stats of root memcg */
>> +             if (memcg == root_mem_cgroup)
>> +                     val += nstat[i];
>>               seq_printf(m, "total_%s %lld\n", mem_cgroup_stat_names[i], val);
>>       }
>>
>> --
>> 1.7.9.5
>>
>
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
