Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 950856B0098
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 12:32:02 -0500 (EST)
Date: Tue, 2 Feb 2010 11:31:58 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [RFP-V2 0/3] Make mmu_notifier_invalidate_range_start able to
 sleep.
Message-ID: <20100202173158.GO6616@sgi.com>
References: <20100202134047.GJ4135@random.random>
 <20100202135141.GH6616@sgi.com>
 <20100202141036.GL4135@random.random>
 <20100202142130.GI6616@sgi.com>
 <20100202145911.GM4135@random.random>
 <20100202152142.GQ6653@sgi.com>
 <20100202160146.GO4135@random.random>
 <20100202163930.GR6653@sgi.com>
 <20100202165224.GP4135@random.random>
 <20100202165903.GN6616@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100202165903.GN6616@sgi.com>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Robin Holt <holt@sgi.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 02, 2010 at 10:59:03AM -0600, Robin Holt wrote:
> On Tue, Feb 02, 2010 at 05:52:24PM +0100, Andrea Arcangeli wrote:
> > On Tue, Feb 02, 2010 at 10:39:30AM -0600, Robin Holt wrote:
> > > On Tue, Feb 02, 2010 at 05:01:46PM +0100, Andrea Arcangeli wrote:
> > > > On Tue, Feb 02, 2010 at 09:21:42AM -0600, Robin Holt wrote:
> > > > > unmap_mapping_range_vma would then unlock the i_mmap_lock, call
> > > > > _inv_range_start(atomic==0) which would clear all the remote page tables
> > > > > and TLBs.  It would then reaquire the i_mmap_lock and retry.
> > > > 
> > > > I guess you missed why we hold the i_mmap_lock there... it's not like
> > > > gratuitous locking complication there's an actual reason why it's
> > > > taken, and it's to avoid the vma to be freed from under you:
> > > 
> > > Oversight on my part.  Sorry.
> > > 
> > > Will this work?
> > 
> > No, it still corrupts memory as before. You need to re-run find_vma
> > under mmap_sem. Then it could work...
> 
> But we don't use the vma for anything.  The _invalidate_range_start/end
> is using the mm.  XPMEM and GRU don't use the vma.  Does KVM?  Since it
> isn't passed in, I would expect that anybody trying to use the vma is
> going to have to do a find_vma themselves.  Did I miss something?
> 
> > Also it's wrong to pin mm_users, you only need mm_count here, as you
> > only need to run find_vma, you don't need to prevent exit to free the
> > pages indefinitely while you're blocked.
> 
> Is this better?

Not better.  Still need to grab the mmap_sem.  How about this?

static int unmap_mapping_range_vma(struct vm_area_struct *vma,
...
	if (need_unlocked_invalidate) {
		mm = vma->vm_mm;
		atomic_inc(&mm->mm_count);
	}
	spin_unlock(details->i_mmap_lock);
	if (need_unlocked_invalidate) {
		/*
		 * zap_page_range failed to make any progress because the
		 * mmu_notifier_invalidate_range_start was called atomically
		 * while the callee needed to sleep.  In that event, we
		 * make the callout while the i_mmap_lock is released.
		 */
		down_read(&mm->mmap_sem);
		mmu_notifier_invalidate_range_start(mm, start_addr, end_addr, 0);
		mmu_notifier_invalidate_range_end(mm, start_addr, end_addr);
		up_read(&mm->mmap_sem);
		mmdrop(mm);
	}


Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
