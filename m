Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DAAC36B0093
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 15:17:27 -0500 (EST)
Date: Tue, 2 Feb 2010 21:17:19 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFP-V2 0/3] Make mmu_notifier_invalidate_range_start able to
 sleep.
Message-ID: <20100202201718.GQ4135@random.random>
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
To: Robin Holt <holt@sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 02, 2010 at 10:59:03AM -0600, Robin Holt wrote:
> But we don't use the vma for anything.  The _invalidate_range_start/end
> is using the mm.  XPMEM and GRU don't use the vma.  Does KVM?  Since it
> isn't passed in, I would expect that anybody trying to use the vma is
> going to have to do a find_vma themselves.  Did I miss something?

No sorry, we are passing down the mm not the vma so it should be ok already.

> Is this better?
> 
> static int unmap_mapping_range_vma(struct vm_area_struct *vma,
> ...
> 	if (need_unlocked_invalidate) {
> 		mm = vma->vm_mm;
> 		atomic_inc(&mm->mm_count);
> 	}
> 	spin_unlock(details->i_mmap_lock);
> 	if (need_unlocked_invalidate) {
> 		/*
> 		 * zap_page_range failed to make any progress because the
> 		 * mmu_notifier_invalidate_range_start was called atomically
> 		 * while the callee needed to sleep.  In that event, we
> 		 * make the callout while the i_mmap_lock is released.
> 		 */
> 		mmu_notifier_invalidate_range_start(mm, start_addr, end_addr, 0);
> 		mmu_notifier_invalidate_range_end(mm, start_addr, end_addr);
> 		mmdrop(mm);
> 	}

Yes with mm_count it's better and this way it should be safe. I think
it's an ok tradeoff, hopefully then nobody will ask to schedule in
->invalidate_page. Still it'd be interesting (back to Andrew's
argument) to understand what is fundamentally different that you are
ok not to schedule in ->invalidate_page but you absolutely need it
here. And yes this will break also my transparent hugepage patch that
can't schedule inside the anon_vma->lock and uses the range calls to
be safer (then maybe we can require the mmu notifier users to check
PageTransHuge against the pages and handle the invalidate through
->invalidate_page or we can add ->invalidate_transhuge_page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
