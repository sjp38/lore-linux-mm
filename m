Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 217406B004D
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 08:51:44 -0500 (EST)
Date: Tue, 2 Feb 2010 07:51:41 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [RFP-V2 0/3] Make mmu_notifier_invalidate_range_start able to
 sleep.
Message-ID: <20100202135141.GH6616@sgi.com>
References: <20100202040145.555474000@alcatraz.americas.sgi.com>
 <20100202080947.GA28736@infradead.org>
 <20100202125943.GH4135@random.random>
 <20100202131341.GI4135@random.random>
 <20100202132919.GO6653@sgi.com>
 <20100202134047.GJ4135@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100202134047.GJ4135@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Robin Holt <holt@sgi.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 02, 2010 at 02:40:47PM +0100, Andrea Arcangeli wrote:
> On Tue, Feb 02, 2010 at 07:29:20AM -0600, Robin Holt wrote:
> > The atomic==1 case is only for the truncate case, correct?  XPMEM is
> 
> Correct.
> 
> > holding reference counts on the pages it exports (get_user_pages) so
> > they are not freed even when the zap_page_range has completed.  What I
> > think we are dealing with is an inconsistent appearance to userland.
> > The one task would SIG_BUS if it touches the memory.  The other would
> > be able to read/write it just fine until the ascynchronous zap of the
> > attachment completed.
> 
> Ok, thanks to the page pin it won't randomly corrupt memory, but it
> can still screw the runtime of an unmodified unaware program. I think
> you've to figure out how important it is that you won't deadlock if
> luser modifies userland because this isn't a complete approach and as
> much as I care about your workload that is ok with this, I cannot
> exclude it might materialize an usage in the future where sigbus while
> other thread still access the remote pages is not ok and may screw
> userland in a more subtle way than a visible kernel deadlock. Now we
> can do this now and undo it later, nothing very problematic, but
> considering this isn't a full transparent solution, I don't see the
> big deal in just scheduling in atomic if user does what it can't do
> (there will be unexpected behavior to his app anyway if he does that).

I am sorry.  I slipped implementations.  I had worked late into the
evening on an alternative to this patch which did not require the unlock
of the i_mmap_lock, _inv_range_start, lock, return -EINTR.  That approach
would have had the caveats as above.

The approach we are discussing here does not have any difference in
userland behavior.  When called with atomic==1, XPMEM will detect that
we have exported pages in that address range and return !0 indicating we
need to sleep to satisfy this call.  The i_mmap_lock would be released
and _inv_range_start would be called again with atomic==0.  This time, the
pages would be cleared from the attachments, the unmap_mapping_range_vma
would then retry.  Hopefully the call this time with atomic==1 would
return 0 indicating it did not need to sleep.

> I don't see a problem in applying srcu and the tlb gather patch in
> distro kernels, those won't even prevent the upstream modules to build
> against those kernels and there will be no change of API. In general
> making the methods sleepable doesn't need to alter the API at
> all... reason of this change of API is because we're not actually
> making them sleepable but only a few.

I don't see the change in API with this method either.

Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
