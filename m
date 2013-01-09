Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 3C41E6B0062
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 04:45:23 -0500 (EST)
Received: by mail-oa0-f45.google.com with SMTP id i18so767078oag.18
        for <linux-mm@kvack.org>; Wed, 09 Jan 2013 01:45:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <xr93obh2krcr.fsf@gthelen.mtv.corp.google.com>
References: <1356455919-14445-1-git-send-email-handai.szj@taobao.com>
	<1356456367-14660-1-git-send-email-handai.szj@taobao.com>
	<xr93obh2krcr.fsf@gthelen.mtv.corp.google.com>
Date: Wed, 9 Jan 2013 17:45:22 +0800
Message-ID: <CAFj3OHWYM3ZX1wQNvnj36-ztu9qAQrgsojAXMgmhVg7EONJ83A@mail.gmail.com>
Subject: Re: [PATCH V3 4/8] memcg: add per cgroup dirty pages accounting
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, mhocko@suse.cz, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, fengguang.wu@intel.com, glommer@parallels.com, dchinner@redhat.com, Sha Zhengju <handai.szj@taobao.com>

On Mon, Jan 7, 2013 at 4:07 AM, Greg Thelen <gthelen@google.com> wrote:
> On Tue, Dec 25 2012, Sha Zhengju wrote:
>
>> From: Sha Zhengju <handai.szj@taobao.com>
>>
>> This patch adds memcg routines to count dirty pages, which allows memory controller
>> to maintain an accurate view of the amount of its dirty memory and can provide some
>> info for users while cgroup's direct reclaim is working.
>>
>> After Kame's commit 89c06bd5(memcg: use new logic for page stat accounting), we can
>> use 'struct page' flag to test page state instead of per page_cgroup flag. But memcg
>> has a feature to move a page from a cgroup to another one and may have race between
>> "move" and "page stat accounting". So in order to avoid the race we have designed a
>> bigger lock:
>>
>>          mem_cgroup_begin_update_page_stat()
>>          modify page information        -->(a)
>>          mem_cgroup_update_page_stat()  -->(b)
>>          mem_cgroup_end_update_page_stat()
>> It requires (a) and (b)(dirty pages accounting) can stay close enough.
>> In the previous two prepare patches, we have reworked the vfs set page dirty routines
>> and now the interfaces are more explicit:
>>         incrementing (2):
>>                 __set_page_dirty
>>                 __set_page_dirty_nobuffers
>>         decrementing (2):
>>                 clear_page_dirty_for_io
>>                 cancel_dirty_page
>>
>> To prevent AB/BA deadlock mentioned by Greg Thelen in previous version
>> (https://lkml.org/lkml/2012/7/30/227), we adjust the lock order:
>> ->private_lock --> mapping->tree_lock --> memcg->move_lock.
>> So we need to make mapping->tree_lock ahead of TestSetPageDirty in __set_page_dirty()
>> and __set_page_dirty_nobuffers(). But in order to avoiding useless spinlock contention,
>> a prepare PageDirty() checking is added.
>>
>>
>> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
>> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>
>> Acked-by: Fengguang Wu <fengguang.wu@intel.com>
>> ---
>>  fs/buffer.c                |   14 +++++++++++++-
>>  include/linux/memcontrol.h |    1 +
>>  mm/filemap.c               |   10 ++++++++++
>>  mm/memcontrol.c            |   29 ++++++++++++++++++++++-------
>>  mm/page-writeback.c        |   39 ++++++++++++++++++++++++++++++++-------
>>  mm/truncate.c              |    6 ++++++
>>  6 files changed, 84 insertions(+), 15 deletions(-)
>
> __nilfs_clear_page_dirty() clears PageDirty, does it need modification
> for this patch series?

It doesn't need to do so.
mem_cgroup_dec/inc_page_stat() is accompany with
dec/inc_zone_page_state() to account memcg page stat.  IMHO we only
have to do some modification while SetPageDirty and
dec/inc_zone_page_state() occur together.
__nilfs_clear_page_dirty() will call clear_page_dirty_for_io(page)
later where the accounting is done.

>> diff --git a/fs/buffer.c b/fs/buffer.c
>> index 762168a..53402d2 100644
>> --- a/fs/buffer.c
>> +++ b/fs/buffer.c
>> @@ -612,19 +612,31 @@ EXPORT_SYMBOL(mark_buffer_dirty_inode);
>>  int __set_page_dirty(struct page *page,
>>               struct address_space *mapping, int warn)
>>  {
>> +     bool locked;
>> +     unsigned long flags;
>> +
>>       if (unlikely(!mapping))
>>               return !TestSetPageDirty(page);
>>
>> -     if (TestSetPageDirty(page))
>> +     if (PageDirty(page))
>>               return 0;
>>
>>       spin_lock_irq(&mapping->tree_lock);
>> +     mem_cgroup_begin_update_page_stat(page, &locked, &flags);
>> +
>> +     if (TestSetPageDirty(page)) {
>> +             mem_cgroup_end_update_page_stat(page, &locked, &flags);
>> +             spin_unlock_irq(&mapping->tree_lock);
>> +             return 0;
>> +     }
>> +
>>       if (page->mapping) {    /* Race with truncate? */
>>               WARN_ON_ONCE(warn && !PageUptodate(page));
>>               account_page_dirtied(page, mapping);
>>               radix_tree_tag_set(&mapping->page_tree,
>>                               page_index(page), PAGECACHE_TAG_DIRTY);
>>       }
>> +     mem_cgroup_end_update_page_stat(page, &locked, &flags);
>>       spin_unlock_irq(&mapping->tree_lock);
>>       __mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 5421b8a..2685d8a 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -44,6 +44,7 @@ enum mem_cgroup_stat_index {
>>       MEM_CGROUP_STAT_RSS,       /* # of pages charged as anon rss */
>>       MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
>>       MEM_CGROUP_STAT_SWAP, /* # of pages, swapped out */
>> +     MEM_CGROUP_STAT_FILE_DIRTY,  /* # of dirty pages in page cache */
>>       MEM_CGROUP_STAT_NSTATS,
>>  };
>>
>> diff --git a/mm/filemap.c b/mm/filemap.c
>> index 83efee7..b589be5 100644
>> --- a/mm/filemap.c
>> +++ b/mm/filemap.c
>> @@ -62,6 +62,11 @@
>>   *      ->swap_lock          (exclusive_swap_page, others)
>>   *        ->mapping->tree_lock
>>   *
>> + *    ->private_lock         (__set_page_dirty_buffers)
>> + *      ->mapping->tree_lock
>> + *        ->memcg->move_lock (mem_cgroup_begin_update_page_stat->
>> + *                                                   move_lock_mem_cgroup)
>> + *
>>   *  ->i_mutex
>>   *    ->i_mmap_mutex         (truncate->unmap_mapping_range)
>>   *
>> @@ -112,6 +117,8 @@
>>  void __delete_from_page_cache(struct page *page)
>>  {
>>       struct address_space *mapping = page->mapping;
>> +     bool locked;
>> +     unsigned long flags;
>>
>>       /*
>>        * if we're uptodate, flush out into the cleancache, otherwise
>> @@ -139,10 +146,13 @@ void __delete_from_page_cache(struct page *page)
>>        * Fix it up by doing a final dirty accounting check after
>>        * having removed the page entirely.
>>        */
>> +     mem_cgroup_begin_update_page_stat(page, &locked, &flags);
>>       if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
>> +             mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_DIRTY);
>>               dec_zone_page_state(page, NR_FILE_DIRTY);
>>               dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
>>       }
>> +     mem_cgroup_end_update_page_stat(page, &locked, &flags);
>>  }
>>
>>  /**
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index d450c04..c884640 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -95,6 +95,7 @@ static const char * const mem_cgroup_stat_names[] = {
>>       "rss",
>>       "mapped_file",
>>       "swap",
>> +     "dirty",
>>  };
>>
>>  enum mem_cgroup_events_index {
>> @@ -3609,6 +3610,19 @@ void mem_cgroup_split_huge_fixup(struct page *head)
>>  }
>>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>>
>> +static inline
>> +void mem_cgroup_move_account_page_stat(struct mem_cgroup *from,
>> +                                     struct mem_cgroup *to,
>> +                                     unsigned int nr_pages,
>> +                                     enum mem_cgroup_stat_index idx)
>> +{
>> +     /* Update stat data for mem_cgroup */
>> +     preempt_disable();
>> +     __this_cpu_add(from->stat->count[idx], -nr_pages);
>
> What you do think about adding a WARN_ON_ONCE() here to check for
> underflow?  A check might help catch:
> a) unresolved races between move accounting vs setting/clearing
>    dirtying.
> b) future modifications that mess with PageDirty/Writeback flags without
>    considering memcg.
To prevent the current memcg deadlock and lock nesting, I'm thinking
about another synchronization proposal for memcg page stat &
move_account. The counter may be minus in a very short periods. Now
I'm not sure whether it's okay... maybe I'll send it out in another
thread later...

>
>> +     __this_cpu_add(to->stat->count[idx], nr_pages);
>> +     preempt_enable();
>> +}
>> +
>>  /**
>>   * mem_cgroup_move_account - move account of the page
>>   * @page: the page
>> @@ -3654,13 +3668,14 @@ static int mem_cgroup_move_account(struct page *page,
>>
>>       move_lock_mem_cgroup(from, &flags);
>>
>> -     if (!anon && page_mapped(page)) {
>> -             /* Update mapped_file data for mem_cgroup */
>> -             preempt_disable();
>> -             __this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
>> -             __this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
>> -             preempt_enable();
>> -     }
>> +     if (!anon && page_mapped(page))
>> +             mem_cgroup_move_account_page_stat(from, to, nr_pages,
>> +                     MEM_CGROUP_STAT_FILE_MAPPED);
>> +
>> +     if (PageDirty(page))
>
> Is (!anon && PageDirty(page)) better?  If dirty anon pages are moved
> between memcg M1 and M2 I think that we'd mistakenly underflow M1 if it
> was not previously accounting for the dirty anon page.
Yeah... A page can be PageAnon and PageDirty simultaneously but we only
account dirty file-page. Will be updated next version.


-- 
Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
