Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0CCD36B0047
	for <linux-mm@kvack.org>; Sun,  7 Mar 2010 21:35:19 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o282Z9aK016774
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 8 Mar 2010 11:35:09 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C93D145DE55
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 11:35:08 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 751B845DE56
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 11:35:08 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E8C61DB805D
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 11:35:08 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 946561DB8066
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 11:35:07 +0900 (JST)
Date: Mon, 8 Mar 2010 11:31:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 4/4] memcg: dirty pages instrumentation
Message-Id: <20100308113129.3c217951.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1267995474-9117-5-git-send-email-arighi@develer.com>
References: <1267995474-9117-1-git-send-email-arighi@develer.com>
	<1267995474-9117-5-git-send-email-arighi@develer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <arighi@develer.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun,  7 Mar 2010 21:57:54 +0100
Andrea Righi <arighi@develer.com> wrote:

> Apply the cgroup dirty pages accounting and limiting infrastructure to
> the opportune kernel functions.
> 
> As a bonus, make determine_dirtyable_memory() static again: this
> function isn't used anymore outside page writeback.
> 
> Signed-off-by: Andrea Righi <arighi@develer.com>

I'm sorry if I misunderstand..almost all this kind of accounting is done
under lock_page()...then...


> ---
>  fs/fuse/file.c            |    5 +
>  fs/nfs/write.c            |    6 +
>  fs/nilfs2/segment.c       |   11 ++-
>  include/linux/writeback.h |    2 -
>  mm/filemap.c              |    1 +
>  mm/page-writeback.c       |  224 ++++++++++++++++++++++++++++-----------------
>  mm/rmap.c                 |    4 +-
>  mm/truncate.c             |    2 +
>  8 files changed, 165 insertions(+), 90 deletions(-)
> 
> diff --git a/fs/fuse/file.c b/fs/fuse/file.c
> index a9f5e13..9a542e5 100644
> --- a/fs/fuse/file.c
> +++ b/fs/fuse/file.c
> @@ -11,6 +11,7 @@
>  #include <linux/pagemap.h>
>  #include <linux/slab.h>
>  #include <linux/kernel.h>
> +#include <linux/memcontrol.h>
>  #include <linux/sched.h>
>  #include <linux/module.h>
>  
> @@ -1129,6 +1130,8 @@ static void fuse_writepage_finish(struct fuse_conn *fc, struct fuse_req *req)
>  
>  	list_del(&req->writepages_entry);
>  	dec_bdi_stat(bdi, BDI_WRITEBACK);
> +	mem_cgroup_dec_page_stat_unlocked(req->pages[0],
> +			MEMCG_NR_FILE_WRITEBACK_TEMP);
>  	dec_zone_page_state(req->pages[0], NR_WRITEBACK_TEMP);

Hmm. IIUC, this req->pages[0] is "tmp_page", which works as bounce_buffer for FUSE.
Then, this req->pages[] is not under any memcg.
So, this accounting never work.


>  	bdi_writeout_inc(bdi);
>  	wake_up(&fi->page_waitq);
> @@ -1240,6 +1243,8 @@ static int fuse_writepage_locked(struct page *page)
>  	req->inode = inode;
>  
>  	inc_bdi_stat(mapping->backing_dev_info, BDI_WRITEBACK);
> +	mem_cgroup_inc_page_stat_unlocked(tmp_page,
> +			MEMCG_NR_FILE_WRITEBACK_TEMP);
>  	inc_zone_page_state(tmp_page, NR_WRITEBACK_TEMP);
>  	end_page_writeback(page);
ditto.


>  
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 53ff70e..a35e3c0 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -440,6 +440,8 @@ nfs_mark_request_commit(struct nfs_page *req)
>  			NFS_PAGE_TAG_COMMIT);
>  	nfsi->ncommit++;
>  	spin_unlock(&inode->i_lock);
> +	mem_cgroup_inc_page_stat_unlocked(req->wb_page,
> +			MEMCG_NR_FILE_UNSTABLE_NFS);
>  	inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);

Here, if the page is locked (by lock_page()), it will never be uncharged.
Then, _locked() version stat accounting can be used.


>  	inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_RECLAIMABLE);
>  	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
> @@ -451,6 +453,8 @@ nfs_clear_request_commit(struct nfs_page *req)
>  	struct page *page = req->wb_page;
>  
>  	if (test_and_clear_bit(PG_CLEAN, &(req)->wb_flags)) {
> +		mem_cgroup_dec_page_stat_unlocked(page,
> +				MEMCG_NR_FILE_UNSTABLE_NFS);
ditto.


>  		dec_zone_page_state(page, NR_UNSTABLE_NFS);
>  		dec_bdi_stat(page->mapping->backing_dev_info, BDI_RECLAIMABLE);
>  		return 1;
> @@ -1277,6 +1281,8 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how)
>  		req = nfs_list_entry(head->next);
>  		nfs_list_remove_request(req);
>  		nfs_mark_request_commit(req);
> +		mem_cgroup_dec_page_stat_unlocked(req->wb_page,
> +				MEMCG_NR_FILE_UNSTABLE_NFS);

ditto.

>  		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
>  		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
>  				BDI_RECLAIMABLE);
> diff --git a/fs/nilfs2/segment.c b/fs/nilfs2/segment.c
> index ada2f1b..fb79558 100644
> --- a/fs/nilfs2/segment.c
> +++ b/fs/nilfs2/segment.c
> @@ -24,6 +24,7 @@
>  #include <linux/pagemap.h>
>  #include <linux/buffer_head.h>
>  #include <linux/writeback.h>
> +#include <linux/memcontrol.h>
>  #include <linux/bio.h>
>  #include <linux/completion.h>
>  #include <linux/blkdev.h>
> @@ -1660,8 +1661,11 @@ nilfs_copy_replace_page_buffers(struct page *page, struct list_head *out)
>  	} while (bh = bh->b_this_page, bh2 = bh2->b_this_page, bh != head);
>  	kunmap_atomic(kaddr, KM_USER0);
>  
> -	if (!TestSetPageWriteback(clone_page))
> +	if (!TestSetPageWriteback(clone_page)) {
> +		mem_cgroup_inc_page_stat_unlocked(clone_page,
> +				MEMCG_NR_FILE_WRITEBACK);
>  		inc_zone_page_state(clone_page, NR_WRITEBACK);
> +	}
>  	unlock_page(clone_page);
>  
IIUC, this clone_page is not under memcg, too. Then, it can't be handled. (now)




>  	return 0;
> @@ -1783,8 +1787,11 @@ static void __nilfs_end_page_io(struct page *page, int err)
>  	}
>  
>  	if (buffer_nilfs_allocated(page_buffers(page))) {
> -		if (TestClearPageWriteback(page))
> +		if (TestClearPageWriteback(page)) {
> +			mem_cgroup_dec_page_stat_unlocked(page,
> +					MEMCG_NR_FILE_WRITEBACK);
>  			dec_zone_page_state(page, NR_WRITEBACK);
> +		}

Hmm...isn't this a clone_page in above ? If so, this should be avoided.

IMHO, at 1st version, NILFS and FUSE's bounce page should be skipped.
If we want to limit this, we have to charge against bounce page.
I'm not sure it's difficult or not...but...




>  	} else
>  		end_page_writeback(page);
>  }
> diff --git a/include/linux/writeback.h b/include/linux/writeback.h
> index dd9512d..39e4cb2 100644
> --- a/include/linux/writeback.h
> +++ b/include/linux/writeback.h
> @@ -117,8 +117,6 @@ extern int vm_highmem_is_dirtyable;
>  extern int block_dump;
>  extern int laptop_mode;
>  
> -extern unsigned long determine_dirtyable_memory(void);
> -
>  extern int dirty_background_ratio_handler(struct ctl_table *table, int write,
>  		void __user *buffer, size_t *lenp,
>  		loff_t *ppos);
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 62cbac0..37f89d1 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -135,6 +135,7 @@ void __remove_from_page_cache(struct page *page)
>  	 * having removed the page entirely.
>  	 */
>  	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
> +		mem_cgroup_dec_page_stat_locked(page, MEMCG_NR_FILE_DIRTY);
>  		dec_zone_page_state(page, NR_FILE_DIRTY);
>  		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
>  	}
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index ab84693..9d4503a 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -131,6 +131,111 @@ static struct prop_descriptor vm_completions;
>  static struct prop_descriptor vm_dirties;
>  
>  /*
> + * Work out the current dirty-memory clamping and background writeout
> + * thresholds.
> + *
> + * The main aim here is to lower them aggressively if there is a lot of mapped
> + * memory around.  To avoid stressing page reclaim with lots of unreclaimable
> + * pages.  It is better to clamp down on writers than to start swapping, and
> + * performing lots of scanning.
> + *
> + * We only allow 1/2 of the currently-unmapped memory to be dirtied.
> + *
> + * We don't permit the clamping level to fall below 5% - that is getting rather
> + * excessive.
> + *
> + * We make sure that the background writeout level is below the adjusted
> + * clamping level.
> + */
> +
> +static unsigned long highmem_dirtyable_memory(unsigned long total)
> +{
> +#ifdef CONFIG_HIGHMEM
> +	int node;
> +	unsigned long x = 0;
> +
> +	for_each_node_state(node, N_HIGH_MEMORY) {
> +		struct zone *z =
> +			&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
> +
> +		x += zone_page_state(z, NR_FREE_PAGES) +
> +		     zone_reclaimable_pages(z);
> +	}
> +	/*
> +	 * Make sure that the number of highmem pages is never larger
> +	 * than the number of the total dirtyable memory. This can only
> +	 * occur in very strange VM situations but we want to make sure
> +	 * that this does not occur.
> +	 */
> +	return min(x, total);
> +#else
> +	return 0;
> +#endif
> +}
> +
> +static unsigned long get_global_dirtyable_memory(void)
> +{
> +	unsigned long memory;
> +
> +	memory = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
> +	if (!vm_highmem_is_dirtyable)
> +		memory -= highmem_dirtyable_memory(memory);
> +	return memory + 1;
> +}
> +
> +static unsigned long get_dirtyable_memory(void)
> +{
> +	unsigned long memory;
> +	s64 memcg_memory;
> +
> +	memory = get_global_dirtyable_memory();
> +	if (!mem_cgroup_has_dirty_limit())
> +		return memory;
> +	memcg_memory = mem_cgroup_page_stat(MEMCG_NR_DIRTYABLE_PAGES);
> +	BUG_ON(memcg_memory < 0);
> +
> +	return min((unsigned long)memcg_memory, memory);
> +}
> +
> +static long get_reclaimable_pages(void)
> +{
> +	s64 ret;
> +
> +	if (!mem_cgroup_has_dirty_limit())
> +		return global_page_state(NR_FILE_DIRTY) +
> +			global_page_state(NR_UNSTABLE_NFS);
> +	ret = mem_cgroup_page_stat(MEMCG_NR_RECLAIM_PAGES);
> +	BUG_ON(ret < 0);
> +
> +	return ret;
> +}
> +
> +static long get_writeback_pages(void)
> +{
> +	s64 ret;
> +
> +	if (!mem_cgroup_has_dirty_limit())
> +		return global_page_state(NR_WRITEBACK);
> +	ret = mem_cgroup_page_stat(MEMCG_NR_WRITEBACK);
> +	BUG_ON(ret < 0);
> +
> +	return ret;
> +}
> +
> +static unsigned long get_dirty_writeback_pages(void)
> +{
> +	s64 ret;
> +
> +	if (!mem_cgroup_has_dirty_limit())
> +		return global_page_state(NR_UNSTABLE_NFS) +
> +			global_page_state(NR_WRITEBACK);
> +	ret = mem_cgroup_page_stat(MEMCG_NR_DIRTY_WRITEBACK_PAGES);
> +	BUG_ON(ret < 0);
> +
> +	return ret;
> +}
> +
> +/*
>   * couple the period to the dirty_ratio:
>   *
>   *   period/2 ~ roundup_pow_of_two(dirty limit)
> @@ -142,7 +247,7 @@ static int calc_period_shift(void)
>  	if (vm_dirty_bytes)
>  		dirty_total = vm_dirty_bytes / PAGE_SIZE;
>  	else
> -		dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) /
> +		dirty_total = (vm_dirty_ratio * get_global_dirtyable_memory()) /
>  				100;
>  	return 2 + ilog2(dirty_total - 1);
>  }
> @@ -355,92 +460,34 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned max_ratio)
>  }
>  EXPORT_SYMBOL(bdi_set_max_ratio);
>  
> -/*
> - * Work out the current dirty-memory clamping and background writeout
> - * thresholds.
> - *
> - * The main aim here is to lower them aggressively if there is a lot of mapped
> - * memory around.  To avoid stressing page reclaim with lots of unreclaimable
> - * pages.  It is better to clamp down on writers than to start swapping, and
> - * performing lots of scanning.
> - *
> - * We only allow 1/2 of the currently-unmapped memory to be dirtied.
> - *
> - * We don't permit the clamping level to fall below 5% - that is getting rather
> - * excessive.
> - *
> - * We make sure that the background writeout level is below the adjusted
> - * clamping level.
> - */
> -
> -static unsigned long highmem_dirtyable_memory(unsigned long total)
> -{
> -#ifdef CONFIG_HIGHMEM
> -	int node;
> -	unsigned long x = 0;
> -
> -	for_each_node_state(node, N_HIGH_MEMORY) {
> -		struct zone *z =
> -			&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
> -
> -		x += zone_page_state(z, NR_FREE_PAGES) +
> -		     zone_reclaimable_pages(z);
> -	}
> -	/*
> -	 * Make sure that the number of highmem pages is never larger
> -	 * than the number of the total dirtyable memory. This can only
> -	 * occur in very strange VM situations but we want to make sure
> -	 * that this does not occur.
> -	 */
> -	return min(x, total);
> -#else
> -	return 0;
> -#endif
> -}
> -
> -/**
> - * determine_dirtyable_memory - amount of memory that may be used
> - *
> - * Returns the numebr of pages that can currently be freed and used
> - * by the kernel for direct mappings.
> - */
> -unsigned long determine_dirtyable_memory(void)
> -{
> -	unsigned long x;
> -
> -	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
> -
> -	if (!vm_highmem_is_dirtyable)
> -		x -= highmem_dirtyable_memory(x);
> -
> -	return x + 1;	/* Ensure that we never return 0 */
> -}
> -
>  void
>  get_dirty_limits(unsigned long *pbackground, unsigned long *pdirty,
>  		 unsigned long *pbdi_dirty, struct backing_dev_info *bdi)
>  {
> -	unsigned long background;
> -	unsigned long dirty;
> -	unsigned long available_memory = determine_dirtyable_memory();
> +	unsigned long dirty, background;
> +	unsigned long available_memory = get_dirtyable_memory();
>  	struct task_struct *tsk;
> +	struct vm_dirty_param dirty_param;
>  
> -	if (vm_dirty_bytes)
> -		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
> +	get_vm_dirty_param(&dirty_param);
> +
> +	if (dirty_param.dirty_bytes)
> +		dirty = DIV_ROUND_UP(dirty_param.dirty_bytes, PAGE_SIZE);
>  	else {
>  		int dirty_ratio;
>  
> -		dirty_ratio = vm_dirty_ratio;
> +		dirty_ratio = dirty_param.dirty_ratio;
>  		if (dirty_ratio < 5)
>  			dirty_ratio = 5;
>  		dirty = (dirty_ratio * available_memory) / 100;
>  	}
>  
> -	if (dirty_background_bytes)
> -		background = DIV_ROUND_UP(dirty_background_bytes, PAGE_SIZE);
> +	if (dirty_param.dirty_background_bytes)
> +		background = DIV_ROUND_UP(dirty_param.dirty_background_bytes,
> +						PAGE_SIZE);
>  	else
> -		background = (dirty_background_ratio * available_memory) / 100;
> -
> +		background = (dirty_param.dirty_background_ratio *
> +						available_memory) / 100;
>  	if (background >= dirty)
>  		background = dirty / 2;
>  	tsk = current;
> @@ -505,9 +552,8 @@ static void balance_dirty_pages(struct address_space *mapping,
>  		get_dirty_limits(&background_thresh, &dirty_thresh,
>  				&bdi_thresh, bdi);
>  
> -		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
> -					global_page_state(NR_UNSTABLE_NFS);
> -		nr_writeback = global_page_state(NR_WRITEBACK);
> +		nr_reclaimable = get_reclaimable_pages();
> +		nr_writeback = get_writeback_pages();
>  
>  		bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
>  		bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
> @@ -593,10 +639,9 @@ static void balance_dirty_pages(struct address_space *mapping,
>  	 * In normal mode, we start background writeout at the lower
>  	 * background_thresh, to keep the amount of dirty memory low.
>  	 */
> +	nr_reclaimable = get_reclaimable_pages();
>  	if ((laptop_mode && pages_written) ||
> -	    (!laptop_mode && ((global_page_state(NR_FILE_DIRTY)
> -			       + global_page_state(NR_UNSTABLE_NFS))
> -					  > background_thresh)))
> +	    (!laptop_mode && (nr_reclaimable > background_thresh)))
>  		bdi_start_writeback(bdi, NULL, 0);
>  }
>  
> @@ -660,6 +705,8 @@ void throttle_vm_writeout(gfp_t gfp_mask)
>  	unsigned long dirty_thresh;
>  
>          for ( ; ; ) {
> +		unsigned long dirty;
> +
>  		get_dirty_limits(&background_thresh, &dirty_thresh, NULL, NULL);
>  
>                  /*
> @@ -668,10 +715,10 @@ void throttle_vm_writeout(gfp_t gfp_mask)
>                   */
>                  dirty_thresh += dirty_thresh / 10;      /* wheeee... */
>  
> -                if (global_page_state(NR_UNSTABLE_NFS) +
> -			global_page_state(NR_WRITEBACK) <= dirty_thresh)
> -                        	break;
> -                congestion_wait(BLK_RW_ASYNC, HZ/10);
> +		dirty = get_dirty_writeback_pages();
> +		if (dirty <= dirty_thresh)
> +			break;
> +		congestion_wait(BLK_RW_ASYNC, HZ/10);
>  
>  		/*
>  		 * The caller might hold locks which can prevent IO completion
> @@ -1078,6 +1125,7 @@ int __set_page_dirty_no_writeback(struct page *page)
>  void account_page_dirtied(struct page *page, struct address_space *mapping)
>  {
>  	if (mapping_cap_account_dirty(mapping)) {
> +		mem_cgroup_inc_page_stat_locked(page, MEMCG_NR_FILE_DIRTY);
>  		__inc_zone_page_state(page, NR_FILE_DIRTY);
>  		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
>  		task_dirty_inc(current);
> @@ -1279,6 +1327,8 @@ int clear_page_dirty_for_io(struct page *page)
>  		 * for more comments.
>  		 */
>  		if (TestClearPageDirty(page)) {
> +			mem_cgroup_dec_page_stat_unlocked(page,
> +					MEMCG_NR_FILE_DIRTY);
>  			dec_zone_page_state(page, NR_FILE_DIRTY);
>  			dec_bdi_stat(mapping->backing_dev_info,
>  					BDI_RECLAIMABLE);

This is called under lock_page(). Then, the page is stable under us.
locked version can be used.


> @@ -1314,8 +1364,11 @@ int test_clear_page_writeback(struct page *page)
>  	} else {
>  		ret = TestClearPageWriteback(page);
>  	}
> -	if (ret)
> +	if (ret) {
> +		mem_cgroup_dec_page_stat_unlocked(page,
> +				MEMCG_NR_FILE_WRITEBACK);
>  		dec_zone_page_state(page, NR_WRITEBACK);
> +	}
Can this be moved up to under tree_lock ?


>  	return ret;
>  }
>  
> @@ -1345,8 +1398,11 @@ int test_set_page_writeback(struct page *page)
>  	} else {
>  		ret = TestSetPageWriteback(page);
>  	}
> -	if (!ret)
> +	if (!ret) {
> +		mem_cgroup_inc_page_stat_unlocked(page,
> +				MEMCG_NR_FILE_WRITEBACK);
>  		inc_zone_page_state(page, NR_WRITEBACK);
> +	}
>  	return ret;
>  
Maybe moving this to under tree_lock and using unloked version is better.



>  }
> diff --git a/mm/rmap.c b/mm/rmap.c
> index fcd593c..61f07cc 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -828,8 +828,8 @@ void page_add_new_anon_rmap(struct page *page,
>  void page_add_file_rmap(struct page *page)
>  {
>  	if (atomic_inc_and_test(&page->_mapcount)) {
> +		mem_cgroup_inc_page_stat_unlocked(page, MEMCG_NR_FILE_MAPPED);
>  		__inc_zone_page_state(page, NR_FILE_MAPPED);
> -		mem_cgroup_update_file_mapped(page, 1);
>  	}
>  }
>  
> @@ -860,8 +860,8 @@ void page_remove_rmap(struct page *page)
>  		mem_cgroup_uncharge_page(page);
>  		__dec_zone_page_state(page, NR_ANON_PAGES);
>  	} else {
> +		mem_cgroup_dec_page_stat_unlocked(page, MEMCG_NR_FILE_MAPPED);
>  		__dec_zone_page_state(page, NR_FILE_MAPPED);
> -		mem_cgroup_update_file_mapped(page, -1);
>  	}
>  	/*
>  	 * It would be tidy to reset the PageAnon mapping here,
> diff --git a/mm/truncate.c b/mm/truncate.c
> index e87e372..1613632 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -73,6 +73,8 @@ void cancel_dirty_page(struct page *page, unsigned int account_size)
>  	if (TestClearPageDirty(page)) {
>  		struct address_space *mapping = page->mapping;
>  		if (mapping && mapping_cap_account_dirty(mapping)) {
> +			mem_cgroup_dec_page_stat_unlocked(page,
> +					MEMCG_NR_FILE_DIRTY);
>  			dec_zone_page_state(page, NR_FILE_DIRTY);
>  			dec_bdi_stat(mapping->backing_dev_info,
>  					BDI_RECLAIMABLE);

cancel_dirty_page() is called after do_invalidatepage() but before
remove_from_pagecache(), it's all done under lock_page().

Then, we can use "locked" accounting here.

If you feel locked/unlocked accounting is toooo complex, simply adding
irq_enable/disable around lock_page_cgroup() is a choice.
But please measure performance before doing that.


Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
