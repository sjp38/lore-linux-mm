Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 0997A6B0078
	for <linux-mm@kvack.org>; Tue, 14 May 2013 05:03:45 -0400 (EDT)
Received: by mail-bk0-f48.google.com with SMTP id jf3so151102bkc.35
        for <linux-mm@kvack.org>; Tue, 14 May 2013 02:03:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <51918221.6090402@jp.fujitsu.com>
References: <1368421410-4795-1-git-send-email-handai.szj@taobao.com>
	<1368421524-4937-1-git-send-email-handai.szj@taobao.com>
	<51918221.6090402@jp.fujitsu.com>
Date: Tue, 14 May 2013 17:03:44 +0800
Message-ID: <CAFj3OHVGXrt+MjDJZfzumjf=vj5KtwePmssoqN+KwE3yc_U2FA@mail.gmail.com>
Subject: Re: [PATCH V2 2/3] memcg: alter mem_cgroup_{update,inc,dec}_page_stat()
 args to memcg pointer
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Sha Zhengju <handai.szj@taobao.com>

Hi Kame,

On Tue, May 14, 2013 at 8:15 AM, Kamezawa Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> (2013/05/13 14:05), Sha Zhengju wrote:
>> From: Sha Zhengju <handai.szj@taobao.com>
>>
>> Change the first argument of mem_cgroup_{update,inc,dec}_page_stat() from
>> 'struct page *' to 'struct mem_cgroup *', and so move PageCgroupUsed(pc)
>> checking out of mem_cgroup_update_page_stat(). This is a prepare patch for
>> the following memcg page stat lock simplifying.
>>
>> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
>
> Why we need to find page_cgroup and memcg and check pc->flags bit
> even if memcg is unused ? I think it's too slow.
>
> Sorry, NAK.

Yeah, it's my fault... my brain filter the !CONFIG_MEMCG automatically.
Sorry for the stupid mistake and thank you for reviewing!


Thanks,
Sha

>
>
>
>> ---
>>   include/linux/memcontrol.h |   14 +++++++-------
>>   mm/memcontrol.c            |    9 ++-------
>>   mm/rmap.c                  |   28 +++++++++++++++++++++++++---
>>   3 files changed, 34 insertions(+), 17 deletions(-)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index d6183f0..7af3ed3 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -163,20 +163,20 @@ static inline void mem_cgroup_end_update_page_stat(struct page *page,
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
>> @@ -347,12 +347,12 @@ static inline void mem_cgroup_end_update_page_stat(struct page *page,
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
>> index b31513e..a394ba4 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -2367,18 +2367,13 @@ void __mem_cgroup_end_update_page_stat(struct page *page, unsigned long *flags)
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
>> -
>>       if (mem_cgroup_disabled())
>>               return;
>>
>> -     memcg = pc->mem_cgroup;
>> -     if (unlikely(!memcg || !PageCgroupUsed(pc)))
>> +     if (unlikely(!memcg))
>>               return;
>>
>>       switch (idx) {
>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index 6280da8..a03c2a9 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -1109,12 +1109,24 @@ void page_add_file_rmap(struct page *page)
>>   {
>>       bool locked;
>>       unsigned long flags;
>> +     struct page_cgroup *pc;
>> +     struct mem_cgroup *memcg = NULL;
>>
>>       mem_cgroup_begin_update_page_stat(page, &locked, &flags);
>> +     pc = lookup_page_cgroup(page);
>> +
>> +     rcu_read_lock();
>> +     memcg = pc->mem_cgroup;
>> +     if (unlikely(!PageCgroupUsed(pc)))
>> +             memcg = NULL;
>> +
>>       if (atomic_inc_and_test(&page->_mapcount)) {
>>               __inc_zone_page_state(page, NR_FILE_MAPPED);
>> -             mem_cgroup_inc_page_stat(page, MEMCG_NR_FILE_MAPPED);
>> +             if (memcg)
>> +                     mem_cgroup_inc_page_stat(memcg, MEMCG_NR_FILE_MAPPED);
>>       }
>> +     rcu_read_unlock();
>> +
>>       mem_cgroup_end_update_page_stat(page, &locked, &flags);
>>   }
>>
>> @@ -1129,14 +1141,22 @@ void page_remove_rmap(struct page *page)
>>       bool anon = PageAnon(page);
>>       bool locked;
>>       unsigned long flags;
>> +     struct page_cgroup *pc;
>> +     struct mem_cgroup *memcg = NULL;
>>
>>       /*
>>        * The anon case has no mem_cgroup page_stat to update; but may
>>        * uncharge_page() below, where the lock ordering can deadlock if
>>        * we hold the lock against page_stat move: so avoid it on anon.
>>        */
>> -     if (!anon)
>> +     if (!anon) {
>>               mem_cgroup_begin_update_page_stat(page, &locked, &flags);
>> +             pc = lookup_page_cgroup(page);
>> +             rcu_read_lock();
>> +             memcg = pc->mem_cgroup;
>> +             if (unlikely(!PageCgroupUsed(pc)))
>> +                     memcg = NULL;
>> +     }
>>
>>       /* page still mapped by someone else? */
>>       if (!atomic_add_negative(-1, &page->_mapcount))
>> @@ -1157,7 +1177,9 @@ void page_remove_rmap(struct page *page)
>>                                             NR_ANON_TRANSPARENT_HUGEPAGES);
>>       } else {
>>               __dec_zone_page_state(page, NR_FILE_MAPPED);
>> -             mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_MAPPED);
>> +             if (memcg)
>> +                     mem_cgroup_dec_page_stat(memcg, MEMCG_NR_FILE_MAPPED);
>> +             rcu_read_unlock();
>>               mem_cgroup_end_update_page_stat(page, &locked, &flags);
>>       }
>>       if (unlikely(PageMlocked(page)))
>>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
