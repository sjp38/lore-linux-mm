Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 43AAD6B0047
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 17:02:31 -0500 (EST)
Date: Mon, 1 Mar 2010 17:02:08 -0500
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH -mmotm 3/3] memcg: dirty pages instrumentation
Message-ID: <20100301220208.GH3109@redhat.com>
References: <1267478620-5276-1-git-send-email-arighi@develer.com> <1267478620-5276-4-git-send-email-arighi@develer.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1267478620-5276-4-git-send-email-arighi@develer.com>
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <arighi@develer.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 01, 2010 at 10:23:40PM +0100, Andrea Righi wrote:
> Apply the cgroup dirty pages accounting and limiting infrastructure to
> the opportune kernel functions.
> 
> Signed-off-by: Andrea Righi <arighi@develer.com>
> ---
>  fs/fuse/file.c      |    5 +++
>  fs/nfs/write.c      |    4 ++
>  fs/nilfs2/segment.c |   10 +++++-
>  mm/filemap.c        |    1 +
>  mm/page-writeback.c |   84 ++++++++++++++++++++++++++++++++------------------
>  mm/rmap.c           |    4 +-
>  mm/truncate.c       |    2 +
>  7 files changed, 76 insertions(+), 34 deletions(-)
> 
> diff --git a/fs/fuse/file.c b/fs/fuse/file.c
> index a9f5e13..dbbdd53 100644
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
> +	mem_cgroup_update_stat(req->pages[0],
> +			MEM_CGROUP_STAT_WRITEBACK_TEMP, -1);
>  	dec_zone_page_state(req->pages[0], NR_WRITEBACK_TEMP);
>  	bdi_writeout_inc(bdi);
>  	wake_up(&fi->page_waitq);
> @@ -1240,6 +1243,8 @@ static int fuse_writepage_locked(struct page *page)
>  	req->inode = inode;
>  
>  	inc_bdi_stat(mapping->backing_dev_info, BDI_WRITEBACK);
> +	mem_cgroup_update_stat(tmp_page,
> +			MEM_CGROUP_STAT_WRITEBACK_TEMP, 1);
>  	inc_zone_page_state(tmp_page, NR_WRITEBACK_TEMP);
>  	end_page_writeback(page);
>  
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index b753242..7316f7a 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -439,6 +439,7 @@ nfs_mark_request_commit(struct nfs_page *req)
>  			req->wb_index,
>  			NFS_PAGE_TAG_COMMIT);
>  	spin_unlock(&inode->i_lock);
> +	mem_cgroup_update_stat(req->wb_page, MEM_CGROUP_STAT_UNSTABLE_NFS, 1);
>  	inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
>  	inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_UNSTABLE);
>  	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
> @@ -450,6 +451,7 @@ nfs_clear_request_commit(struct nfs_page *req)
>  	struct page *page = req->wb_page;
>  
>  	if (test_and_clear_bit(PG_CLEAN, &(req)->wb_flags)) {
> +		mem_cgroup_update_stat(page, MEM_CGROUP_STAT_UNSTABLE_NFS, -1);
>  		dec_zone_page_state(page, NR_UNSTABLE_NFS);
>  		dec_bdi_stat(page->mapping->backing_dev_info, BDI_UNSTABLE);
>  		return 1;
> @@ -1273,6 +1275,8 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how)
>  		req = nfs_list_entry(head->next);
>  		nfs_list_remove_request(req);
>  		nfs_mark_request_commit(req);
> +		mem_cgroup_update_stat(req->wb_page,
> +				MEM_CGROUP_STAT_UNSTABLE_NFS, -1);
>  		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
>  		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
>  				BDI_UNSTABLE);
> diff --git a/fs/nilfs2/segment.c b/fs/nilfs2/segment.c
> index ada2f1b..aef6d13 100644
> --- a/fs/nilfs2/segment.c
> +++ b/fs/nilfs2/segment.c
> @@ -1660,8 +1660,11 @@ nilfs_copy_replace_page_buffers(struct page *page, struct list_head *out)
>  	} while (bh = bh->b_this_page, bh2 = bh2->b_this_page, bh != head);
>  	kunmap_atomic(kaddr, KM_USER0);
>  
> -	if (!TestSetPageWriteback(clone_page))
> +	if (!TestSetPageWriteback(clone_page)) {
> +		mem_cgroup_update_stat(clone_page,
> +				MEM_CGROUP_STAT_WRITEBACK, 1);
>  		inc_zone_page_state(clone_page, NR_WRITEBACK);
> +	}
>  	unlock_page(clone_page);
>  
>  	return 0;
> @@ -1783,8 +1786,11 @@ static void __nilfs_end_page_io(struct page *page, int err)
>  	}
>  
>  	if (buffer_nilfs_allocated(page_buffers(page))) {
> -		if (TestClearPageWriteback(page))
> +		if (TestClearPageWriteback(page)) {
> +			mem_cgroup_update_stat(clone_page,
> +					MEM_CGROUP_STAT_WRITEBACK, -1);
>  			dec_zone_page_state(page, NR_WRITEBACK);
> +		}
>  	} else
>  		end_page_writeback(page);
>  }
> diff --git a/mm/filemap.c b/mm/filemap.c
> index fe09e51..f85acae 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -135,6 +135,7 @@ void __remove_from_page_cache(struct page *page)
>  	 * having removed the page entirely.
>  	 */
>  	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
> +		mem_cgroup_update_stat(page, MEM_CGROUP_STAT_FILE_DIRTY, -1);
>  		dec_zone_page_state(page, NR_FILE_DIRTY);
>  		dec_bdi_stat(mapping->backing_dev_info, BDI_DIRTY);
>  	}
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 5a0f8f3..d83f41c 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -137,13 +137,14 @@ static struct prop_descriptor vm_dirties;
>   */
>  static int calc_period_shift(void)
>  {
> -	unsigned long dirty_total;
> +	unsigned long dirty_total, dirty_bytes;
>  
> -	if (vm_dirty_bytes)
> -		dirty_total = vm_dirty_bytes / PAGE_SIZE;
> +	dirty_bytes = mem_cgroup_dirty_bytes();
> +	if (dirty_bytes)
> +		dirty_total = dirty_bytes / PAGE_SIZE;
>  	else
> -		dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) /
> -				100;
> +		dirty_total = (mem_cgroup_dirty_ratio() *
> +				determine_dirtyable_memory()) / 100;
>  	return 2 + ilog2(dirty_total - 1);
>  }
>  
> @@ -408,14 +409,16 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
>   */
>  unsigned long determine_dirtyable_memory(void)
>  {
> -	unsigned long x;
> -
> -	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
> +	unsigned long memory;
> +	s64 memcg_memory;
>  
> +	memory = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
>  	if (!vm_highmem_is_dirtyable)
> -		x -= highmem_dirtyable_memory(x);
> -
> -	return x + 1;	/* Ensure that we never return 0 */
> +		memory -= highmem_dirtyable_memory(memory);
> +	memcg_memory = mem_cgroup_page_stat(MEMCG_NR_DIRTYABLE_PAGES);
> +	if (memcg_memory < 0)
> +		return memory + 1;
> +	return min((unsigned long)memcg_memory, memory + 1);
>  }
>  
>  void
> @@ -423,26 +426,28 @@ get_dirty_limits(unsigned long *pbackground, unsigned long *pdirty,
>  		 unsigned long *pbdi_dirty, struct backing_dev_info *bdi)
>  {
>  	unsigned long background;
> -	unsigned long dirty;
> +	unsigned long dirty, dirty_bytes, dirty_background;
>  	unsigned long available_memory = determine_dirtyable_memory();
>  	struct task_struct *tsk;
>  
> -	if (vm_dirty_bytes)
> -		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
> +	dirty_bytes = mem_cgroup_dirty_bytes();
> +	if (dirty_bytes)
> +		dirty = DIV_ROUND_UP(dirty_bytes, PAGE_SIZE);
>  	else {
>  		int dirty_ratio;
>  
> -		dirty_ratio = vm_dirty_ratio;
> +		dirty_ratio = mem_cgroup_dirty_ratio();
>  		if (dirty_ratio < 5)
>  			dirty_ratio = 5;
>  		dirty = (dirty_ratio * available_memory) / 100;
>  	}
>  
> -	if (dirty_background_bytes)
> -		background = DIV_ROUND_UP(dirty_background_bytes, PAGE_SIZE);
> +	dirty_background = mem_cgroup_dirty_background_bytes();
> +	if (dirty_background)
> +		background = DIV_ROUND_UP(dirty_background, PAGE_SIZE);
>  	else
> -		background = (dirty_background_ratio * available_memory) / 100;
> -
> +		background = (mem_cgroup_dirty_background_ratio() *
> +					available_memory) / 100;
>  	if (background >= dirty)
>  		background = dirty / 2;
>  	tsk = current;
> @@ -508,9 +513,13 @@ static void balance_dirty_pages(struct address_space *mapping,
>  		get_dirty_limits(&background_thresh, &dirty_thresh,
>  				&bdi_thresh, bdi);
>  
> -		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
> +		nr_reclaimable = mem_cgroup_page_stat(MEMCG_NR_RECLAIM_PAGES);
> +		nr_writeback = mem_cgroup_page_stat(MEMCG_NR_WRITEBACK);
> +		if ((nr_reclaimable < 0) || (nr_writeback < 0)) {
> +			nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
>  					global_page_state(NR_UNSTABLE_NFS);
> -		nr_writeback = global_page_state(NR_WRITEBACK);
> +			nr_writeback = global_page_state(NR_WRITEBACK);
> +		}
>  
>  		bdi_nr_reclaimable = bdi_stat(bdi, BDI_DIRTY);
>  		if (bdi_cap_account_unstable(bdi)) {
> @@ -611,10 +620,12 @@ static void balance_dirty_pages(struct address_space *mapping,
>  	 * In normal mode, we start background writeout at the lower
>  	 * background_thresh, to keep the amount of dirty memory low.
>  	 */
> +	nr_reclaimable = mem_cgroup_page_stat(MEMCG_NR_RECLAIM_PAGES);
> +	if (nr_reclaimable < 0)
> +		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
> +				global_page_state(NR_UNSTABLE_NFS);
>  	if ((laptop_mode && pages_written) ||
> -	    (!laptop_mode && ((global_page_state(NR_FILE_DIRTY)
> -			       + global_page_state(NR_UNSTABLE_NFS))
> -					  > background_thresh)))
> +	    (!laptop_mode && (nr_reclaimable > background_thresh)))
>  		bdi_start_writeback(bdi, NULL, 0);
>  }
>  
> @@ -678,6 +689,8 @@ void throttle_vm_writeout(gfp_t gfp_mask)
>  	unsigned long dirty_thresh;
>  
>          for ( ; ; ) {
> +		unsigned long dirty;
> +
>  		get_dirty_limits(&background_thresh, &dirty_thresh, NULL, NULL);
>  
>                  /*
> @@ -686,10 +699,14 @@ void throttle_vm_writeout(gfp_t gfp_mask)
>                   */
>                  dirty_thresh += dirty_thresh / 10;      /* wheeee... */
>  
> -                if (global_page_state(NR_UNSTABLE_NFS) +
> -			global_page_state(NR_WRITEBACK) <= dirty_thresh)
> -                        	break;
> -                congestion_wait(BLK_RW_ASYNC, HZ/10);
> +
> +		dirty = mem_cgroup_page_stat(MEMCG_NR_DIRTY_WRITEBACK_PAGES);
> +		if (dirty < 0)
> +			dirty = global_page_state(NR_UNSTABLE_NFS) +
> +				global_page_state(NR_WRITEBACK);

dirty is unsigned long. As mentioned last time, above will never be true?
In general these patches look ok to me. I will do some testing with these.

Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
