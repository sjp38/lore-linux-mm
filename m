Date: Thu, 3 Aug 2006 17:04:44 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch][rfc] possible lock_page fix for Andrea's nopage vs
 invalidate race?
In-Reply-To: <44CF3CB7.7030009@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0608031526400.15351@blonde.wat.veritas.com>
References: <44CF3CB7.7030009@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrea Arcangeli <andrea@suse.de>, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

(David, I've added you to CC because way down below
there's an issue of interaction with page_mkwrite.)

On Tue, 1 Aug 2006, Nick Piggin wrote:
> 
> Just like to get some thoughts on another possible approach to this
> problem, and whether my changelog and implementation actually capture

Good changelog, promising implementation.

> the problem. This fix is actually something Andrea had proposed, so
> credit really goes to him.
> 
> I suppose we should think about fixing it some day?

Certainly we should fix it, and I've failed to come up with anything
better than this, despite mulling over it from time to time.

I believe I was the one who most strongly resisted (even ridiculed)
this approach, others liked it; and it's grown more attractive
since Christoph (Mr Scalability) approved the idea at OLS.

Though I'm still not entirely convinced.

> Fix the race between invalidate_inode_pages and do_no_page.
> 
> Andrea Arcangeli identified a subtle race between invalidation of
> pages from pagecache with userspace mappings, and do_no_page.
> 
> The issue is that invalidation has to shoot down all mappings to the
> page, before it can be discarded from the pagecache. Between shooting
> down ptes to a particular page, and actually dropping the struct page
> from the pagecache, do_no_page from any process might fault on that
> page and establish a new mapping to the page just before it gets
> discarded from the pagecache.
> 
> The most common case where such invalidation is used is in file
> truncation. This case was catered for by doing a sort of open-coded
> seqlock between the file's i_size, and its truncate_count.
> 
> Truncation will decrease i_size, then increment truncate_count before
> unmapping userspace pages; do_no_page will read truncate_count, then
> find the page if it is within i_size, and then check truncate_count
> under the page table lock and back out and retry if it had
> subsequently been changed (ptl will serialise against unmapping, and
> ensure a potentially updated truncate_count is actually visible).
> 
> Complexity and documentation issues aside, the locking protocol fails
> in the case where we would like to invalidate pagecache inside i_size.
> do_no_page can come in anytime and filemap_nopage is not aware of the
> invalidation in progress (as it is when it is outside i_size). The
> end result is that dangling (->mapping == NULL) pages that appear to
> be from a particular file may be mapped into userspace with nonsense
> data. Valid mappings to the same place will see a different page.

I think it was some NFS or cluster FS case that showed the problem,
Andrea would know.  But Badari's MADV_REMOVE, punching a hole within
a file, has added another case which the i_size/truncate_count
technique cannot properly guard against.

> Andrea implemented two working fixes, one using a real seqlock,
> another using a page->flags bit. He also proposed using the page lock
> in do_no_page, but that was initially considered too heavyweight.
> However, it is not a global or per-file lock, and the page cacheline
> is modified in do_no_page to increment _count and _mapcount anyway, so
> a further modification should not be a large performance hit.
> Scalability is not an issue.

Scalability is not an issue, that's nice - but I don't see how you
arrive at that certainty.  Obviously the per-page lock means it's
less of a scalability issue than global or per-file; and the fact
that tmpfs' shmem_getpage has always taken page lock internally
adds good evidence that it can't be too bad.

But I worry a little about shared libraries, and suspect that there
will be cases degraded by the additional locking - perhaps benchmarks
(with processes falling into lockstep) rather than real-life loads.  I
think it's fair to say "Scalability is unlikely to be much of an issue".

> This patch implements this latter approach. ->nopage implementations
> return with the page locked if it is possible for their underlying
> file to be invalidated (in that case, they must set a special vm_flags
> bit to indicate so). do_no_page only unlocks the page after setting
> up the mapping completely. invalidation is excluded because it holds
> the page lock during invalidation of each page.
> 
> This allows significant simplifications in do_no_page.
> 
> kbuild performance is, surprisingly, maybe slightly improved:

Emphasis on maybe.  It would be surprising, and your ext3 system
times go the other way, and I find the reverse of what you find:
slightly regressed, say ~0.5%, on kbuilds and some lmbenchs.

Perhaps because my kbuilds or machines are different; or perhaps
it's all just in the noise, and an accident of text moving into or
out of different cachelines.

Nothing too alarming, anyway, and I don't really trust myself for
performance numbers.  Let's wait to hear from Martin and co.

> 2xP4 Xeon 3.6GHz with HT:
> kbuild -j8 in shmfs
> original:
> 505.16user 28.59system 2:15.87elapsed 392%CPU
> 505.08user 28.28system 2:15.81elapsed 392%CPU
> 504.16user 29.28system 2:15.85elapsed 392%CPU
> 
> patched:
> 502.35user 26.86system 2:14.77elapsed 392%CPU
> 501.89user 27.15system 2:14.86elapsed 392%CPU
> 502.22user 27.01system 2:14.87elapsed 392%CPU
> 
> kbuild -j8 in ext3
> original:
> 505.65user 27.72system 2:15.75elapsed 392%CPU
> 506.38user 26.73system 2:16.38elapsed 390%CPU
> 507.00user 26.21system 2:15.76elapsed 392%CPU
> 
> patched:
> 501.03user 28.67system 2:14.98elapsed 392%CPU
> 500.84user 29.34system 2:14.99elapsed 392%CPU
> 501.18user 28.76system 2:15.05elapsed 392%CPU
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> 
> Index: linux-2.6/include/linux/mm.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mm.h	2006-07-26 18:00:47.000000000 +1000
> +++ linux-2.6/include/linux/mm.h	2006-07-31 15:37:45.000000000 +1000
> @@ -166,6 +166,11 @@ extern unsigned int kobjsize(const void 
>  #define VM_NONLINEAR	0x00800000	/* Is non-linear (remap_file_pages) */
>  #define VM_MAPPED_COPY	0x01000000	/* T if mapped copy of data (nommu mmap) */
>  #define VM_INSERTPAGE	0x02000000	/* The vma has had "vm_insert_page()" done on it */
> +#define VM_CAN_INVLD	0x04000000	/* The mapping may be invalidated,
> +					 * eg. truncate or invalidate_inode_*.
> +					 * In this case, do_no_page must
> +					 * return with the page locked.
> +					 */

I didn't care for "INVLD", and gather now that it's being changed to
"INVALIDATE" (I'd have suggested "INVAL").  But actually, I'd rather
a name that says what's actually being assumed: VM_NOPAGE_LOCKED?

With "revoke" in the air, I suspect that we're going to want to be
able to invalidate the pages of _any_ mapping, whether the driver
locks them in its nopage or not.  (Or am I thereby just encouraging
the idea of a racy revoke?)

>  
>  #ifndef VM_STACK_DEFAULT_FLAGS		/* arch can override this */
>  #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS
> @@ -205,6 +210,7 @@ struct vm_operations_struct {
>  	struct mempolicy *(*get_policy)(struct vm_area_struct *vma,
>  					unsigned long addr);
>  #endif
> +	unsigned long vm_flags; /* vm_flags to copy into any mapping vmas */
>  };

I suppose this is quite efficient, but I find it confusing.
We have lots and lots of drivers already setting vm_flags in their
mmap methods, now you add an alternative way of doing the same thing.
Can't you just set VM_NOPAGE_LOCKED in the relevant mmap methods?
Or did you try it that way and it worked out messy?

>  struct mmu_gather;
> Index: linux-2.6/mm/filemap.c
> ===================================================================
> --- linux-2.6.orig/mm/filemap.c	2006-07-31 15:37:42.000000000 +1000
> +++ linux-2.6/mm/filemap.c	2006-07-31 16:06:04.000000000 +1000
> @@ -1279,6 +1279,8 @@ struct page *filemap_nopage(struct vm_ar
>  	unsigned long size, pgoff;
>  	int did_readaround = 0, majmin = VM_FAULT_MINOR;
>  
> +	BUG_ON(!(area->vm_flags & VM_CAN_INVLD));
> +
>  	pgoff = ((address-area->vm_start) >> PAGE_CACHE_SHIFT) + area->vm_pgoff;
>  
>  retry_all:
> @@ -1303,7 +1305,7 @@ retry_all:
>  	 * Do we have something in the page cache already?
>  	 */
>  retry_find:
> -	page = find_get_page(mapping, pgoff);
> +	page = find_lock_page(mapping, pgoff);
>  	if (!page) {
>  		unsigned long ra_pages;
>  
> @@ -1337,7 +1339,7 @@ retry_find:
>  				start = pgoff - ra_pages / 2;
>  			do_page_cache_readahead(mapping, file, start, ra_pages);
>  		}
> -		page = find_get_page(mapping, pgoff);
> +		page = find_lock_page(mapping, pgoff);
>  		if (!page)
>  			goto no_cached_page;
>  	}
> @@ -1399,30 +1401,6 @@ page_not_uptodate:
>  		majmin = VM_FAULT_MAJOR;
>  		inc_page_state(pgmajfault);
>  	}
> -	lock_page(page);
> -
> -	/* Did it get unhashed while we waited for it? */
> -	if (!page->mapping) {
> -		unlock_page(page);
> -		page_cache_release(page);
> -		goto retry_all;
> -	}
> -
> -	/* Did somebody else get it up-to-date? */
> -	if (PageUptodate(page)) {
> -		unlock_page(page);
> -		goto success;
> -	}
> -
> -	error = mapping->a_ops->readpage(file, page);
> -	if (!error) {
> -		wait_on_page_locked(page);
> -		if (PageUptodate(page))
> -			goto success;
> -	} else if (error == AOP_TRUNCATED_PAGE) {
> -		page_cache_release(page);
> -		goto retry_find;
> -	}

This is a delicious piece of clutter removal: I think you're correct.

>  
>  	/*
>  	 * Umm, take care of errors if the page isn't up-to-date.
> @@ -1430,20 +1408,6 @@ page_not_uptodate:
>  	 * because there really aren't any performance issues here
>  	 * and we need to check for errors.
>  	 */
> -	lock_page(page);
> -
> -	/* Somebody truncated the page on us? */
> -	if (!page->mapping) {
> -		unlock_page(page);
> -		page_cache_release(page);
> -		goto retry_all;
> -	}
> -
> -	/* Somebody else successfully read it in? */
> -	if (PageUptodate(page)) {
> -		unlock_page(page);
> -		goto success;
> -	}

Ditto.

>  	ClearPageError(page);
>  	error = mapping->a_ops->readpage(file, page);
>  	if (!error) {
> @@ -1462,7 +1426,6 @@ page_not_uptodate:
>  	page_cache_release(page);
>  	return NULL;

But here I think you're missing something: the wait_on_page_locked
after ->readpage needs to become a lock_page before going to success?
with unlock_page if it doesn't.

>  }
> -
>  EXPORT_SYMBOL(filemap_nopage);
>  
>  static struct page * filemap_getpage(struct file *file, unsigned long pgoff,
> @@ -1641,6 +1604,7 @@ EXPORT_SYMBOL(filemap_populate);
>  struct vm_operations_struct generic_file_vm_ops = {
>  	.nopage		= filemap_nopage,
>  	.populate	= filemap_populate,
> +	.vm_flags	= VM_CAN_INVLD,
>  };
>  
>  /* This is used for a general mmap of a disk file */
> Index: linux-2.6/mm/memory.c
> ===================================================================
> --- linux-2.6.orig/mm/memory.c	2006-07-26 18:00:47.000000000 +1000
> +++ linux-2.6/mm/memory.c	2006-07-31 16:06:40.000000000 +1000
> @@ -1577,6 +1577,13 @@ static int unmap_mapping_range_vma(struc
>  	unsigned long restart_addr;
>  	int need_break;
>  
> +	/*
> +	 * files that support invalidating or truncating portions of the
> +	 * file from under mmaped areas must set the VM_CAN_INVLD flag, and
> +	 * have their .nopage function return the page locked.
> +	 */
> +	BUG_ON(!(vma->vm_flags & VM_CAN_INVLD));
> +

I think we shall end up wanting to apply unmap_mapping_range even
to "unlocked nopage" vmas (the revoke idea) - unless we decide we
have to make every nopage vma do the locking.  

Would the BUG_ON be better as a WARN_ON, or nothing at all?  It'll
give trouble until out-of-tree filesystems/drivers are updated; or
do we want to give them active trouble there, I'm not sure?

>  again:
>  	restart_addr = vma->vm_truncate_count;
>  	if (is_restart_addr(restart_addr) && start_addr < restart_addr) {
> @@ -1707,17 +1714,8 @@ void unmap_mapping_range(struct address_
>  
>  	spin_lock(&mapping->i_mmap_lock);
>  
> -	/* serialize i_size write against truncate_count write */
> -	smp_wmb();
> -	/* Protect against page faults, and endless unmapping loops */
> +	/* Protect against endless unmapping loops */
>  	mapping->truncate_count++;
> -	/*
> -	 * For archs where spin_lock has inclusive semantics like ia64
> -	 * this smp_mb() will prevent to read pagetable contents
> -	 * before the truncate_count increment is visible to
> -	 * other cpus.
> -	 */
> -	smp_mb();

Yes, that's right, leave truncate_count itself for prio_tree restart,
but it's grand to be deleting all those barriers and their comments.

>  	if (unlikely(is_restart_addr(mapping->truncate_count))) {
>  		if (mapping->truncate_count == 0)
>  			reset_vma_truncate_counts(mapping);
> @@ -1729,6 +1727,7 @@ void unmap_mapping_range(struct address_
>  		unmap_mapping_range_tree(&mapping->i_mmap, &details);
>  	if (unlikely(!list_empty(&mapping->i_mmap_nonlinear)))
>  		unmap_mapping_range_list(&mapping->i_mmap_nonlinear, &details);
> +
>  	spin_unlock(&mapping->i_mmap_lock);
>  }
>  EXPORT_SYMBOL(unmap_mapping_range);
> @@ -2040,36 +2039,23 @@ static int do_no_page(struct mm_struct *
>  		int write_access)
>  {
>  	spinlock_t *ptl;
> -	struct page *new_page;
> -	struct address_space *mapping = NULL;
> +	struct page *new_page, *old_page;

I think it's much clearer to call it "locked_page" than "old_page",
particularly when you see it alonside Peter's "dirty_page".

>  	pte_t entry;
> -	unsigned int sequence = 0;
>  	int ret = VM_FAULT_MINOR;
>  	int anon = 0;
>  
>  	pte_unmap(page_table);
>  	BUG_ON(vma->vm_flags & VM_PFNMAP);
>  
> -	if (vma->vm_file) {
> -		mapping = vma->vm_file->f_mapping;
> -		sequence = mapping->truncate_count;
> -		smp_rmb(); /* serializes i_size against truncate_count */
> -	}
> -retry:
>  	new_page = vma->vm_ops->nopage(vma, address & PAGE_MASK, &ret);
> -	/*
> -	 * No smp_rmb is needed here as long as there's a full
> -	 * spin_lock/unlock sequence inside the ->nopage callback
> -	 * (for the pagecache lookup) that acts as an implicit
> -	 * smp_mb() and prevents the i_size read to happen
> -	 * after the next truncate_count read.
> -	 */
> -

More great removals.

>  	/* no page was available -- either SIGBUS or OOM */
>  	if (new_page == NOPAGE_SIGBUS)
>  		return VM_FAULT_SIGBUS;
>  	if (new_page == NOPAGE_OOM)
>  		return VM_FAULT_OOM;
> +	old_page = new_page;
> +
> +	BUG_ON(vma->vm_flags & VM_CAN_INVLD && !PageLocked(new_page));

Maybe
	if (vma->vm_flags & VM_NOPAGE_LOCKED) {
		locked_page = new_page;
		BUG_ON(!PageLocked(locked_page));
	} else
		locked_page = NULL;

But what I hate about this do_no_page is that sometimes we're going
through it with the page locked, and sometimes we're going through it
with the page not locked.  Now I've not noticed any actual problem
from that (aside from where page_mkwrite fails), and it is well-defined
which case is which, but it is confusing and does make do_no_page harder
to audit at any time.

(I did toy with a separate do_no_page_locked, and nopage_locked
methods for the filesystems; but duplicating so much code doesn't
really solve anything.)

And when you factor in Peter's dirty_page stuff, it's a nuisance:
because he has had to get_page(dirty_page) then put_page(dirty_page),
in case page already got freed by vmscan after ptl dropped: which is
redundant if the page is locked throughout, but you can't rely on that
because (for a while at least) some fs'es won't set VM_NOPAGE_LOCKED.

How about
	if (vma->vm_flags & VM_NOPAGE_LOCKED)
		BUG_ON(!PageLocked(new_page));
	else
		lock_page(new_page);
	locked_page = new_page;
?

And then proceed through the rest of do_no_page sure in the knowledge
that we have the page locked, simplifying whatever might be simplified
by that (removing Peter's get_page,put_page at least).  I can see this
adds a little overhead to some less important cases, but it does make
the rules much easier to grasp.

>  
>  	/*
>  	 * Should we do an early C-O-W break?

Somewhere below here you're missing a hunk to deal with a failed
page_mkwrite, needing to unlock_page(locked_page).  We don't have
an example of a page_mkwrite in tree at present, but it seems
reasonable to suppose that we not it should unlock the page.

Hmm, David Howells has an afs_file_page_mkwrite which sits waiting
for an FsMisc page flag to be cleared: might that deadlock with the
page lock held?  If so, it may need to unlock and relock the page,
rechecking for truncation.

Hmmm, page_mkwrite when called from do_wp_page would not expect to
be holding page lock: we don't want it called with in one case and
without in the other.  Maybe do_no_page needs to unlock_page before
calling page_mkwrite, lock_page after, and check page->mapping when
VM_NOPAGE_LOCKED??

> @@ -2089,19 +2075,6 @@ retry:
>  	}
>  
>  	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
> -	/*
> -	 * For a file-backed vma, someone could have truncated or otherwise
> -	 * invalidated this page.  If unmap_mapping_range got called,
> -	 * retry getting the page.
> -	 */
> -	if (mapping && unlikely(sequence != mapping->truncate_count)) {
> -		pte_unmap_unlock(page_table, ptl);
> -		page_cache_release(new_page);
> -		cond_resched();
> -		sequence = mapping->truncate_count;
> -		smp_rmb();
> -		goto retry;
> -	}

More pleasure.

>  
>  	/*
>  	 * This silly early PAGE_DIRTY setting removes a race
> @@ -2139,10 +2112,15 @@ retry:
>  	lazy_mmu_prot_update(entry);
>  unlock:
>  	pte_unmap_unlock(page_table, ptl);
> +out:
> +	if (likely(vma->vm_flags & VM_CAN_INVLD))
> +		unlock_page(old_page);

If you agree above, that becomes unconditional unlock_page(locked_page);

>  	return ret;
> +
>  oom:
>  	page_cache_release(new_page);
> -	return VM_FAULT_OOM;
> +	ret = VM_FAULT_OOM;
> +	goto out;
>  }
>  
>  /*
> Index: linux-2.6/mm/shmem.c
> ===================================================================
> --- linux-2.6.orig/mm/shmem.c	2006-07-26 18:00:47.000000000 +1000
> +++ linux-2.6/mm/shmem.c	2006-07-31 16:54:48.000000000 +1000
> @@ -80,6 +80,7 @@ enum sgp_type {
>  	SGP_READ,	/* don't exceed i_size, don't allocate page */
>  	SGP_CACHE,	/* don't exceed i_size, may allocate page */
>  	SGP_WRITE,	/* may exceed i_size, may allocate page */
> +	SGP_NOPAGE,	/* same as SGP_CACHE, return with page locked */
>  };

I don't think you need to add another type for this, SGP_CACHE should do.

Perhaps you avoided that because it's also used by shmem_populate.
But another point I want to make is that you do need to update
filemap_populate, shmem_populate, install_page and whatever to
make use the same locked page fix: they've been relying on the
i_size and page->mapping checks, which are not quite enough,
isn't that right? (now my grasp of the race has fallen out of my
left ear, and I'd better finish this mail before regrasping it)

(If you think those checks are enough, then wouldn't it follow that
we don't need to hold page locked in do_no_page at all, just have a
vm_flag to say NULL page->mapping in do_no_page means invalidated?
I think we've all played with that in the past and found it wanting.)

Not as sigificant as the do_no_page fix, but necessary to plug the hole.

>  
>  static int shmem_getpage(struct inode *inode, unsigned long idx,
> @@ -1211,8 +1212,10 @@ repeat:
>  	}
>  done:
>  	if (*pagep != filepage) {
> -		unlock_page(filepage);
>  		*pagep = filepage;
> +		if (sgp != SGP_NOPAGE)
> +			unlock_page(filepage);
> +

You've inserted that blank line just to upset me.

>  	}
>  	return 0;
>  
> @@ -1231,13 +1234,15 @@ struct page *shmem_nopage(struct vm_area
>  	unsigned long idx;
>  	int error;
>  
> +	BUG_ON(!(vma->vm_flags & VM_CAN_INVLD));
> +

We've separately observed that you need to add VM_CAN_INVLD or
VM_CAN_INVALIDATE or VM_NOPAGE_LOCKED into ipc/shm.c too.

>  	idx = (address - vma->vm_start) >> PAGE_SHIFT;
>  	idx += vma->vm_pgoff;
>  	idx >>= PAGE_CACHE_SHIFT - PAGE_SHIFT;
>  	if (((loff_t) idx << PAGE_CACHE_SHIFT) >= i_size_read(inode))
>  		return NOPAGE_SIGBUS;
>  
> -	error = shmem_getpage(inode, idx, &page, SGP_CACHE, type);
> +	error = shmem_getpage(inode, idx, &page, SGP_NOPAGE, type);
>  	if (error)
>  		return (error == -ENOMEM)? NOPAGE_OOM: NOPAGE_SIGBUS;
>  
> @@ -2230,6 +2235,7 @@ static struct vm_operations_struct shmem
>  	.set_policy     = shmem_set_policy,
>  	.get_policy     = shmem_get_policy,
>  #endif
> +	.vm_flags	= VM_CAN_INVLD,
>  };
>  
>  
> Index: linux-2.6/fs/ncpfs/mmap.c
> ===================================================================
> --- linux-2.6.orig/fs/ncpfs/mmap.c	2004-10-19 17:20:33.000000000 +1000
> +++ linux-2.6/fs/ncpfs/mmap.c	2006-07-31 15:39:23.000000000 +1000
> @@ -100,6 +100,7 @@ static struct page* ncp_file_mmap_nopage
>  static struct vm_operations_struct ncp_file_mmap =
>  {
>  	.nopage	= ncp_file_mmap_nopage,
> +	.vm_flags = VM_CAN_INVLD,
>  };
>  
>  
> Index: linux-2.6/fs/ocfs2/mmap.c
> ===================================================================
> --- linux-2.6.orig/fs/ocfs2/mmap.c	2006-02-09 18:04:58.000000000 +1100
> +++ linux-2.6/fs/ocfs2/mmap.c	2006-07-31 15:39:56.000000000 +1000
> @@ -78,6 +78,7 @@ out:
>  
>  static struct vm_operations_struct ocfs2_file_vm_ops = {
>  	.nopage = ocfs2_nopage,
> +	.vm_flags = VM_CAN_INVLD,
>  };
>  
>  int ocfs2_mmap(struct file *file, struct vm_area_struct *vma)
> Index: linux-2.6/fs/xfs/linux-2.6/xfs_file.c
> ===================================================================
> --- linux-2.6.orig/fs/xfs/linux-2.6/xfs_file.c	2006-04-20 18:55:03.000000000 +1000
> +++ linux-2.6/fs/xfs/linux-2.6/xfs_file.c	2006-07-31 15:39:47.000000000 +1000
> @@ -634,6 +634,7 @@ const struct file_operations xfs_dir_fil
>  static struct vm_operations_struct xfs_file_vm_ops = {
>  	.nopage		= filemap_nopage,
>  	.populate	= filemap_populate,
> +	.vm_flags	= VM_CAN_INVLD,
>  };
>  
>  #ifdef CONFIG_XFS_DMAPI
> @@ -643,5 +644,6 @@ static struct vm_operations_struct xfs_d
>  #ifdef HAVE_VMOP_MPROTECT
>  	.mprotect	= xfs_vm_mprotect,
>  #endif
> +	.vm_flags	= VM_CAN_INVLD,
>  };
>  #endif /* CONFIG_XFS_DMAPI */
> Index: linux-2.6/mm/mmap.c
> ===================================================================
> --- linux-2.6.orig/mm/mmap.c	2006-07-26 18:00:47.000000000 +1000
> +++ linux-2.6/mm/mmap.c	2006-07-31 16:03:58.000000000 +1000
> @@ -1089,6 +1089,9 @@ munmap_back:
>  			goto free_vma;
>  	}
>  
> +	if (vma->vm_ops)
> +		vma->vm_flags |= vma->vm_ops->vm_flags;
> +

Mmm, I'd prefer not to have this additional way of setting vm_flags.

>  	/* We set VM_ACCOUNT in a shared mapping's vm_flags, to inform
>  	 * shmem_zero_setup (perhaps called through /dev/zero's ->mmap)
>  	 * that memory reservation must be checked; but that reservation

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
