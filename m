Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 551076B0074
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 01:59:48 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 944793EE0BC
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 14:59:46 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 714CD45DE51
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 14:59:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 596E045DE4F
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 14:59:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 45BDA1DB802F
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 14:59:46 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EB079E08004
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 14:59:45 +0900 (JST)
Message-ID: <4FF289B4.3060706@jp.fujitsu.com>
Date: Tue, 03 Jul 2012 14:57:08 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/7] memcg: add per cgroup dirty pages accounting
References: <1340880885-5427-1-git-send-email-handai.szj@taobao.com> <1340881486-5770-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1340881486-5770-1-git-send-email-handai.szj@taobao.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, gthelen@google.com, yinghan@google.com, akpm@linux-foundation.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

(2012/06/28 20:04), Sha Zhengju wrote:
> From: Sha Zhengju <handai.szj@taobao.com>
> 
> This patch adds memcg routines to count dirty pages, which allows memory controller
> to maintain an accurate view of the amount of its dirty memory and can provide some
> info for users while group's direct reclaim is working.
> 
> After Kame's commit 89c06bd5(memcg: use new logic for page stat accounting), we can
> use 'struct page' flag to test page state instead of per page_cgroup flag. But memcg
> has a feature to move a page from a cgroup to another one and may have race between
> "move" and "page stat accounting". So in order to avoid the race we have designed a
> bigger lock:
> 
>           mem_cgroup_begin_update_page_stat()
>           modify page information	-->(a)
>           mem_cgroup_update_page_stat()  -->(b)
>           mem_cgroup_end_update_page_stat()
> 
> It requires (a) and (b)(dirty pages accounting) can stay close enough.
> 
> In the previous two prepare patches, we have reworked the vfs set page dirty routines
> and now the interfaces are more explicit:
> 	incrementing (2):
> 		__set_page_dirty
> 		__set_page_dirty_nobuffers
> 	decrementing (2):
> 		clear_page_dirty_for_io
> 		cancel_dirty_page
> 
> 
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>

Thank you. This seems much cleaner than expected ! very good.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>



> ---
>   fs/buffer.c                |   17 ++++++++++++++---
>   include/linux/memcontrol.h |    1 +
>   mm/filemap.c               |    5 +++++
>   mm/memcontrol.c            |   28 +++++++++++++++++++++-------
>   mm/page-writeback.c        |   30 ++++++++++++++++++++++++------
>   mm/truncate.c              |    6 ++++++
>   6 files changed, 71 insertions(+), 16 deletions(-)
> 
> diff --git a/fs/buffer.c b/fs/buffer.c
> index 55522dd..d3714cc 100644
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -613,11 +613,19 @@ EXPORT_SYMBOL(mark_buffer_dirty_inode);
>   int __set_page_dirty(struct page *page,
>   		struct address_space *mapping, int warn)
>   {
> +	bool locked;
> +	unsigned long flags;
> +	int ret = 0;
> +
>   	if (unlikely(!mapping))
>   		return !TestSetPageDirty(page);
>   
> -	if (TestSetPageDirty(page))
> -		return 0;
> +	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
> +
> +	if (TestSetPageDirty(page)) {
> +		ret = 0;
> +		goto out;
> +	}
>   
>   	spin_lock_irq(&mapping->tree_lock);
>   	if (page->mapping) {	/* Race with truncate? */
> @@ -629,7 +637,10 @@ int __set_page_dirty(struct page *page,
>   	spin_unlock_irq(&mapping->tree_lock);
>   	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
>   
> -	return 1;
> +	ret = 1;
> +out:
> +	mem_cgroup_end_update_page_stat(page, &locked, &flags);
> +	return ret;
>   }
>   
>   /*
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 20b0f2d..ad37b59 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -38,6 +38,7 @@ enum mem_cgroup_stat_index {
>   	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
>   	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
>   	MEM_CGROUP_STAT_SWAP, /* # of pages, swapped out */
> +	MEM_CGROUP_STAT_FILE_DIRTY,  /* # of dirty pages in page cache */
>   	MEM_CGROUP_STAT_NSTATS,
>   };
>   
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 1f19ec3..5159a49 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -140,6 +140,11 @@ void __delete_from_page_cache(struct page *page)
>   	 * having removed the page entirely.
>   	 */
>   	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
> +		/*
> +		 * Do not change page state, so no need to use mem_cgroup_
> +		 * {begin, end}_update_page_stat to get lock.
> +		 */
> +		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_DIRTY);
>   		dec_zone_page_state(page, NR_FILE_DIRTY);
>   		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
>   	}
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ebed1ca..90e2946 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -82,6 +82,7 @@ static const char * const mem_cgroup_stat_names[] = {
>   	"rss",
>   	"mapped_file",
>   	"swap",
> +	"dirty",
>   };
>   
>   enum mem_cgroup_events_index {
> @@ -2538,6 +2539,18 @@ void mem_cgroup_split_huge_fixup(struct page *head)
>   }
>   #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>   
> +static inline
> +void mem_cgroup_move_account_page_stat(struct mem_cgroup *from,
> +					struct mem_cgroup *to,
> +					enum mem_cgroup_stat_index idx)
> +{
> +	/* Update stat data for mem_cgroup */
> +	preempt_disable();
> +	__this_cpu_dec(from->stat->count[idx]);
> +	__this_cpu_inc(to->stat->count[idx]);
> +	preempt_enable();
> +}
> +
>   /**
>    * mem_cgroup_move_account - move account of the page
>    * @page: the page
> @@ -2583,13 +2596,14 @@ static int mem_cgroup_move_account(struct page *page,
>   
>   	move_lock_mem_cgroup(from, &flags);
>   
> -	if (!anon && page_mapped(page)) {
> -		/* Update mapped_file data for mem_cgroup */
> -		preempt_disable();
> -		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> -		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> -		preempt_enable();
> -	}
> +	if (!anon && page_mapped(page))
> +		mem_cgroup_move_account_page_stat(from, to,
> +				MEM_CGROUP_STAT_FILE_MAPPED);
> +
> +	if (PageDirty(page))
> +		mem_cgroup_move_account_page_stat(from, to,
> +				MEM_CGROUP_STAT_FILE_DIRTY);
> +
>   	mem_cgroup_charge_statistics(from, anon, -nr_pages);
>   
>   	/* caller should have done css_get */
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index e5363f3..e79a2f7 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1962,6 +1962,7 @@ int __set_page_dirty_no_writeback(struct page *page)
>   void account_page_dirtied(struct page *page, struct address_space *mapping)
>   {
>   	if (mapping_cap_account_dirty(mapping)) {
> +		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_FILE_DIRTY);
>   		__inc_zone_page_state(page, NR_FILE_DIRTY);
>   		__inc_zone_page_state(page, NR_DIRTIED);
>   		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
> @@ -2001,12 +2002,20 @@ EXPORT_SYMBOL(account_page_writeback);
>    */
>   int __set_page_dirty_nobuffers(struct page *page)
>   {
> +	bool locked;
> +	unsigned long flags;
> +	int ret = 0;
> +
> +	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
> +
>   	if (!TestSetPageDirty(page)) {
>   		struct address_space *mapping = page_mapping(page);
>   		struct address_space *mapping2;
>   
> -		if (!mapping)
> -			return 1;
> +		if (!mapping) {
> +			ret = 1;
> +			goto out;
> +		}
>   
>   		spin_lock_irq(&mapping->tree_lock);
>   		mapping2 = page_mapping(page);
> @@ -2022,9 +2031,12 @@ int __set_page_dirty_nobuffers(struct page *page)
>   			/* !PageAnon && !swapper_space */
>   			__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
>   		}
> -		return 1;
> +		ret = 1;
>   	}
> -	return 0;
> +
> +out:
> +	mem_cgroup_end_update_page_stat(page, &locked, &flags);
> +	return ret;
>   }
>   EXPORT_SYMBOL(__set_page_dirty_nobuffers);
>   
> @@ -2139,6 +2151,9 @@ EXPORT_SYMBOL(set_page_dirty_lock);
>   int clear_page_dirty_for_io(struct page *page)
>   {
>   	struct address_space *mapping = page_mapping(page);
> +	bool locked;
> +	unsigned long flags;
> +	int ret = 0;
>   
>   	BUG_ON(!PageLocked(page));
>   
> @@ -2180,13 +2195,16 @@ int clear_page_dirty_for_io(struct page *page)
>   		 * the desired exclusion. See mm/memory.c:do_wp_page()
>   		 * for more comments.
>   		 */
> +		mem_cgroup_begin_update_page_stat(page, &locked, &flags);
>   		if (TestClearPageDirty(page)) {
> +			mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_DIRTY);
>   			dec_zone_page_state(page, NR_FILE_DIRTY);
>   			dec_bdi_stat(mapping->backing_dev_info,
>   					BDI_RECLAIMABLE);
> -			return 1;
> +			ret = 1;
>   		}
> -		return 0;
> +		mem_cgroup_end_update_page_stat(page, &locked, &flags);
> +		return ret;
>   	}
>   	return TestClearPageDirty(page);
>   }
> diff --git a/mm/truncate.c b/mm/truncate.c
> index 75801ac..052016a 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -73,9 +73,14 @@ static inline void truncate_partial_page(struct page *page, unsigned partial)
>    */
>   void cancel_dirty_page(struct page *page, unsigned int account_size)
>   {
> +	bool locked;
> +	unsigned long flags;
> +
> +	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
>   	if (TestClearPageDirty(page)) {
>   		struct address_space *mapping = page->mapping;
>   		if (mapping && mapping_cap_account_dirty(mapping)) {
> +			mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_DIRTY);
>   			dec_zone_page_state(page, NR_FILE_DIRTY);
>   			dec_bdi_stat(mapping->backing_dev_info,
>   					BDI_RECLAIMABLE);
> @@ -83,6 +88,7 @@ void cancel_dirty_page(struct page *page, unsigned int account_size)
>   				task_io_account_cancelled_write(account_size);
>   		}
>   	}
> +	mem_cgroup_end_update_page_stat(page, &locked, &flags);
>   }
>   EXPORT_SYMBOL(cancel_dirty_page);
>   
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
