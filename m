Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id AB0666B0095
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 10:29:36 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id fb10so457024pad.16
        for <linux-mm@kvack.org>; Tue, 29 Jan 2013 07:29:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <51071AA1.7000207@jp.fujitsu.com>
References: <1359198756-3752-1-git-send-email-handai.szj@taobao.com>
	<51071AA1.7000207@jp.fujitsu.com>
Date: Tue, 29 Jan 2013 23:29:35 +0800
Message-ID: <CAFj3OHXyWN+zUMAaSEOz2gCP7Bm6v4Zex=Rq=7A9CkHTp3j1UQ@mail.gmail.com>
Subject: Re: [PATCH] memcg: simplify lock of memcg page stat accounting
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, gthelen@google.com, hannes@cmpxchg.org, hughd@google.com, Sha Zhengju <handai.szj@taobao.com>

On Tue, Jan 29, 2013 at 8:41 AM, Kamezawa Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> (2013/01/26 20:12), Sha Zhengju wrote:
>> From: Sha Zhengju <handai.szj@taobao.com>
>>
>> After removing duplicated information like PCG_*
>> flags in 'struct page_cgroup'(commit 2ff76f1193), there's a problem
>> between "move" and "page stat accounting"(only FILE_MAPPED is supported
>> now but other stats will be added in future):
>> assume CPU-A does "page stat accounting" and CPU-B does "move"
>>
>> CPU-A                        CPU-B
>> TestSet PG_dirty
>> (delay)               move_lock_mem_cgroup()
>>                          if (PageDirty(page)) {
>>                               old_memcg->nr_dirty --
>>                               new_memcg->nr_dirty++
>>                          }
>>                          pc->mem_cgroup = new_memcg;
>>                          move_unlock_mem_cgroup()
>>
>> move_lock_mem_cgroup()
>> memcg = pc->mem_cgroup
>> memcg->nr_dirty++
>> move_unlock_mem_cgroup()
>>
>> while accounting information of new_memcg may be double-counted. So we
>> use a bigger lock to solve this problem:  (commit: 89c06bd52f)
>>
>>        move_lock_mem_cgroup() <-- mem_cgroup_begin_update_page_stat()
>>        TestSetPageDirty(page)
>>        update page stats (without any checks)
>>        move_unlock_mem_cgroup() <-- mem_cgroup_begin_update_page_stat()
>>
>>
>> But this method also has its pros and cons: at present we use two layers
>> of lock avoidance(memcg_moving and memcg->moving_account) then spinlock
>> on memcg (see mem_cgroup_begin_update_page_stat()), but the lock granularity
>> is a little bigger that not only the critical section but also some code
>> logic is in the range of locking which may be deadlock prone. As dirty
>> writeack stats are added, it gets into further difficulty with the page
>> cache radix tree lock and it seems that the lock requires nesting.
>> (https://lkml.org/lkml/2013/1/2/48)
>>
>> So in order to make the lock simpler and clearer and also avoid the 'nesting'
>> problem, a choice may be:
>> (CPU-A does "page stat accounting" and CPU-B does "move")
>>
>>         CPU-A                        CPU-B
>>
>> move_lock_mem_cgroup()
>> memcg = pc->mem_cgroup
>> TestSetPageDirty(page)
>> move_unlock_mem_cgroup()
>>                               move_lock_mem_cgroup()
>>                               if (PageDirty) {
>>                                    old_memcg->nr_dirty --;
>>                                    new_memcg->nr_dirty ++;
>>                               }
>>                               pc->mem_cgroup = new_memcg
>>                               move_unlock_mem_cgroup()
>>
>> memcg->nr_dirty ++
>>
>
> Hmm. no race with file truncate ?
>

Do you mean "dirty page accounting" racing with truncate?  Yes, if
another one do truncate and set page->mapping=NULL just before CPU-A's
'memcg->nr_dirty ++', then it'll have no change to correct the figure
back. So my rough idea now is to have some small changes to
__set_page_dirty/__set_page_dirty_nobuffers that do SetDirtyPage
inside ->tree_lock.

But, in current codes, is there any chance that
mem_cgroup_move_account() racing with truncate that PageAnon is
false(since page->mapping is cleared) but later in page_remove_rmap()
the new memcg stats is over decrement...? Call me silly...but I really
get dizzy by those locks now, need to have a run to refresh my head...
 : (


>
>>
>> For CPU-A, we save pc->mem_cgroup in a temporary variable just before
>> TestSetPageDirty inside move_lock and then update stats if the page is set
>> PG_dirty successfully. But CPU-B may do "moving" in advance that
>> "old_memcg->nr_dirty --" will make old_memcg->nr_dirty incorrect but
>> soon CPU-A will do "memcg->nr_dirty ++" finally that amend the stats.
>>
>> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
>> ---
>>   include/linux/memcontrol.h |   14 +++++------
>>   mm/memcontrol.c            |    8 ++-----
>>   mm/rmap.c                  |   55 +++++++++++++++++++++++++++++++++-----------
>>   3 files changed, 51 insertions(+), 26 deletions(-)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 0108a56..12de53b 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -164,20 +164,20 @@ static inline void mem_cgroup_end_update_page_stat(struct page *page,
>>       rcu_read_unlock();
>>   }
>>
>> -void mem_cgroup_update_page_stat(struct page *page,
>> +void mem_cgroup_update_page_stat(struct mem_cgroup *memcg,
>>                                enum mem_cgroup_page_stat_item idx,
>>                                int val);
>>
>> -static inline void mem_cgroup_inc_page_stat(struct page *page,
>> +static inline void mem_cgroup_inc_page_stat(struct mem_cgroup *memcg,
>>                                           enum mem_cgroup_page_stat_item idx)
>>   {
>> -     mem_cgroup_update_page_stat(page, idx, 1);
>> +     mem_cgroup_update_page_stat(memcg, idx, 1);
>>   }
>>
>> -static inline void mem_cgroup_dec_page_stat(struct page *page,
>> +static inline void mem_cgroup_dec_page_stat(struct mem_cgroup *memcg,
>>                                           enum mem_cgroup_page_stat_item idx)
>>   {
>> -     mem_cgroup_update_page_stat(page, idx, -1);
>> +     mem_cgroup_update_page_stat(memcg, idx, -1);
>>   }
>>
>>   unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>> @@ -354,12 +354,12 @@ static inline void mem_cgroup_end_update_page_stat(struct page *page,
>>   {
>>   }
>>
>> -static inline void mem_cgroup_inc_page_stat(struct page *page,
>> +static inline void mem_cgroup_inc_page_stat(struct mem_cgroup *memcg,
>>                                           enum mem_cgroup_page_stat_item idx)
>>   {
>>   }
>>
>> -static inline void mem_cgroup_dec_page_stat(struct page *page,
>> +static inline void mem_cgroup_dec_page_stat(struct mem_cgroup *memcg,
>>                                           enum mem_cgroup_page_stat_item idx)
>>   {
>>   }
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 3817460..1b13e43 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -2259,18 +2259,14 @@ void __mem_cgroup_end_update_page_stat(struct page *page, unsigned long *flags)
>>       move_unlock_mem_cgroup(pc->mem_cgroup, flags);
>>   }
>>
>> -void mem_cgroup_update_page_stat(struct page *page,
>> +void mem_cgroup_update_page_stat(struct mem_cgroup *memcg,
>>                                enum mem_cgroup_page_stat_item idx, int val)
>>   {
>> -     struct mem_cgroup *memcg;
>> -     struct page_cgroup *pc = lookup_page_cgroup(page);
>> -     unsigned long uninitialized_var(flags);
>>
>>       if (mem_cgroup_disabled())
>>               return;
>>
>> -     memcg = pc->mem_cgroup;
>> -     if (unlikely(!memcg || !PageCgroupUsed(pc)))
>> +     if (unlikely(!memcg))
>>               return;
>
> I can't catch why you can do accounting without checking PCG_USED.
> Could you add comments like
>
>   * while accounting ops, mapping->tree_lock() or lock_page() is held
>     and we have any race with truncation
>   etc...

Yeah...considering stat updates and uncharge, PCG_USED should be checked here.
But anther problem raising out of my mind that the three: page stat
accounting, move_account and uncharge may need synchronization....

>
>>
>>       switch (idx) {
>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index 59b0dca..0d74c48 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -1112,13 +1112,25 @@ void page_add_file_rmap(struct page *page)
>>   {
>>       bool locked;
>>       unsigned long flags;
>> +     bool ret;
>> +     struct mem_cgroup *memcg = NULL;
>> +     struct cgroup_subsys_state *css = NULL;
>>
>>       mem_cgroup_begin_update_page_stat(page, &locked, &flags);
>> -     if (atomic_inc_and_test(&page->_mapcount)) {
>> +     memcg = try_get_mem_cgroup_from_page(page);
>
> Toooooo heavy ! I can say NACK to this patch only because of this try_get().
>
> To hold memcg alive, rcu_read_lock() will work (as current code does).
>
OK, next version will return to its correct path.

> BTW, does this patch fixes the nested-lock problem ?
>

Yes, the lock only protects 'get old memcg' and 'modify page status',
so page_remove_rmap can call set_dirty_page out of memcg stat lock.


Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
