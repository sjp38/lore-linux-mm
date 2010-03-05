Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 22AD96B0047
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 17:55:09 -0500 (EST)
Date: Fri, 5 Mar 2010 23:55:01 +0100
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH -mmotm 4/4] memcg: dirty pages instrumentation
Message-ID: <20100305225501.GD1578@linux>
References: <1267699215-4101-1-git-send-email-arighi@develer.com>
 <1267699215-4101-5-git-send-email-arighi@develer.com>
 <20100305063843.GI3073@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100305063843.GI3073@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 05, 2010 at 12:08:43PM +0530, Balbir Singh wrote:
> * Andrea Righi <arighi@develer.com> [2010-03-04 11:40:15]:
> 
> > Apply the cgroup dirty pages accounting and limiting infrastructure
> > to the opportune kernel functions.
> > 
> > Signed-off-by: Andrea Righi <arighi@develer.com>
> > ---
> >  fs/fuse/file.c      |    5 +++
> >  fs/nfs/write.c      |    4 ++
> >  fs/nilfs2/segment.c |   11 +++++-
> >  mm/filemap.c        |    1 +
> >  mm/page-writeback.c |   91 ++++++++++++++++++++++++++++++++++-----------------
> >  mm/rmap.c           |    4 +-
> >  mm/truncate.c       |    2 +
> >  7 files changed, 84 insertions(+), 34 deletions(-)
> > 
> > diff --git a/fs/fuse/file.c b/fs/fuse/file.c
> > index a9f5e13..dbbdd53 100644
> > --- a/fs/fuse/file.c
> > +++ b/fs/fuse/file.c
> > @@ -11,6 +11,7 @@
> >  #include <linux/pagemap.h>
> >  #include <linux/slab.h>
> >  #include <linux/kernel.h>
> > +#include <linux/memcontrol.h>
> >  #include <linux/sched.h>
> >  #include <linux/module.h>
> > 
> > @@ -1129,6 +1130,8 @@ static void fuse_writepage_finish(struct fuse_conn *fc, struct fuse_req *req)
> > 
> >  	list_del(&req->writepages_entry);
> >  	dec_bdi_stat(bdi, BDI_WRITEBACK);
> > +	mem_cgroup_update_stat(req->pages[0],
> > +			MEM_CGROUP_STAT_WRITEBACK_TEMP, -1);
> >  	dec_zone_page_state(req->pages[0], NR_WRITEBACK_TEMP);
> >  	bdi_writeout_inc(bdi);
> >  	wake_up(&fi->page_waitq);
> > @@ -1240,6 +1243,8 @@ static int fuse_writepage_locked(struct page *page)
> >  	req->inode = inode;
> > 
> >  	inc_bdi_stat(mapping->backing_dev_info, BDI_WRITEBACK);
> > +	mem_cgroup_update_stat(tmp_page,
> > +			MEM_CGROUP_STAT_WRITEBACK_TEMP, 1);
> >  	inc_zone_page_state(tmp_page, NR_WRITEBACK_TEMP);
> >  	end_page_writeback(page);
> > 
> > diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> > index b753242..7316f7a 100644
> > --- a/fs/nfs/write.c
> > +++ b/fs/nfs/write.c
> > @@ -439,6 +439,7 @@ nfs_mark_request_commit(struct nfs_page *req)
> >  			req->wb_index,
> >  			NFS_PAGE_TAG_COMMIT);
> >  	spin_unlock(&inode->i_lock);
> > +	mem_cgroup_update_stat(req->wb_page, MEM_CGROUP_STAT_UNSTABLE_NFS, 1);
> >  	inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
> >  	inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_UNSTABLE);
> >  	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
> > @@ -450,6 +451,7 @@ nfs_clear_request_commit(struct nfs_page *req)
> >  	struct page *page = req->wb_page;
> > 
> >  	if (test_and_clear_bit(PG_CLEAN, &(req)->wb_flags)) {
> > +		mem_cgroup_update_stat(page, MEM_CGROUP_STAT_UNSTABLE_NFS, -1);
> >  		dec_zone_page_state(page, NR_UNSTABLE_NFS);
> >  		dec_bdi_stat(page->mapping->backing_dev_info, BDI_UNSTABLE);
> >  		return 1;
> > @@ -1273,6 +1275,8 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how)
> >  		req = nfs_list_entry(head->next);
> >  		nfs_list_remove_request(req);
> >  		nfs_mark_request_commit(req);
> > +		mem_cgroup_update_stat(req->wb_page,
> > +				MEM_CGROUP_STAT_UNSTABLE_NFS, -1);
> >  		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
> >  		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
> >  				BDI_UNSTABLE);
> > diff --git a/fs/nilfs2/segment.c b/fs/nilfs2/segment.c
> > index ada2f1b..27a01b1 100644
> > --- a/fs/nilfs2/segment.c
> > +++ b/fs/nilfs2/segment.c
> > @@ -24,6 +24,7 @@
> >  #include <linux/pagemap.h>
> >  #include <linux/buffer_head.h>
> >  #include <linux/writeback.h>
> > +#include <linux/memcontrol.h>
> >  #include <linux/bio.h>
> >  #include <linux/completion.h>
> >  #include <linux/blkdev.h>
> > @@ -1660,8 +1661,11 @@ nilfs_copy_replace_page_buffers(struct page *page, struct list_head *out)
> >  	} while (bh = bh->b_this_page, bh2 = bh2->b_this_page, bh != head);
> >  	kunmap_atomic(kaddr, KM_USER0);
> > 
> > -	if (!TestSetPageWriteback(clone_page))
> > +	if (!TestSetPageWriteback(clone_page)) {
> > +		mem_cgroup_update_stat(clone_page,
> > +				MEM_CGROUP_STAT_WRITEBACK, 1);
> 
> I wonder if we should start implementing inc and dec to avoid passing
> the +1 and -1 parameters. It should make the code easier to read.

OK, it's always +1/-1, and I don't see any case where we should use
different numbers. So, better to move to the inc/dec naming.

> 
> >  		inc_zone_page_state(clone_page, NR_WRITEBACK);
> > +	}
> >  	unlock_page(clone_page);
> > 
> >  	return 0;
> > @@ -1783,8 +1787,11 @@ static void __nilfs_end_page_io(struct page *page, int err)
> >  	}
> > 
> >  	if (buffer_nilfs_allocated(page_buffers(page))) {
> > -		if (TestClearPageWriteback(page))
> > +		if (TestClearPageWriteback(page)) {
> > +			mem_cgroup_update_stat(page,
> > +					MEM_CGROUP_STAT_WRITEBACK, -1);
> >  			dec_zone_page_state(page, NR_WRITEBACK);
> > +		}
> >  	} else
> >  		end_page_writeback(page);
> >  }
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index fe09e51..f85acae 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -135,6 +135,7 @@ void __remove_from_page_cache(struct page *page)
> >  	 * having removed the page entirely.
> >  	 */
> >  	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
> > +		mem_cgroup_update_stat(page, MEM_CGROUP_STAT_FILE_DIRTY, -1);
> >  		dec_zone_page_state(page, NR_FILE_DIRTY);
> >  		dec_bdi_stat(mapping->backing_dev_info, BDI_DIRTY);
> >  	}
> > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> > index 5a0f8f3..c5d14ea 100644
> > --- a/mm/page-writeback.c
> > +++ b/mm/page-writeback.c
> > @@ -137,13 +137,16 @@ static struct prop_descriptor vm_dirties;
> >   */
> >  static int calc_period_shift(void)
> >  {
> > +	struct dirty_param dirty_param;
> 
> vm_dirty_param?

Agreed.

> 
> >  	unsigned long dirty_total;
> > 
> > -	if (vm_dirty_bytes)
> > -		dirty_total = vm_dirty_bytes / PAGE_SIZE;
> > +	get_dirty_param(&dirty_param);
> 
> get_vm_dirty_param() is a nicer name.

Agreed.

> 
> > +
> > +	if (dirty_param.dirty_bytes)
> > +		dirty_total = dirty_param.dirty_bytes / PAGE_SIZE;
> >  	else
> > -		dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) /
> > -				100;
> > +		dirty_total = (dirty_param.dirty_ratio *
> > +				determine_dirtyable_memory()) / 100;
> >  	return 2 + ilog2(dirty_total - 1);
> >  }
> > 
> > @@ -408,41 +411,46 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
> >   */
> >  unsigned long determine_dirtyable_memory(void)
> >  {
> > -	unsigned long x;
> > -
> > -	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
> > +	unsigned long memory;
> > +	s64 memcg_memory;
> > 
> > +	memory = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
> >  	if (!vm_highmem_is_dirtyable)
> > -		x -= highmem_dirtyable_memory(x);
> > -
> > -	return x + 1;	/* Ensure that we never return 0 */
> > +		memory -= highmem_dirtyable_memory(memory);
> > +	if (mem_cgroup_has_dirty_limit())
> > +		return memory + 1;
> 
> Vivek already pointed out this issue I suppose. Should be *not*

Right. Will be fixed in the next version of the patch.

> 
> > +	memcg_memory = mem_cgroup_page_stat(MEMCG_NR_DIRTYABLE_PAGES);
> 
> Can memcg_memory be 0?

No LRU file pages, no swappable pages, and RES_USAGE == RES_LIMIT? this
would trigger an OOM before memcg_memory == 0 can happen, I think.

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
