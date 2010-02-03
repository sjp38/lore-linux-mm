Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E0F686B0078
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 19:48:36 -0500 (EST)
Date: Tue, 2 Feb 2010 18:48:33 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [RFP-V2 0/3] Make mmu_notifier_invalidate_range_start able to
 sleep.
Message-ID: <20100203004833.GS6653@sgi.com>
References: <20100202135141.GH6616@sgi.com>
 <20100202141036.GL4135@random.random>
 <20100202142130.GI6616@sgi.com>
 <20100202145911.GM4135@random.random>
 <20100202152142.GQ6653@sgi.com>
 <20100202160146.GO4135@random.random>
 <20100202163930.GR6653@sgi.com>
 <20100202165224.GP4135@random.random>
 <20100202165903.GN6616@sgi.com>
 <20100202201718.GQ4135@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100202201718.GQ4135@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Robin Holt <holt@sgi.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Yes with mm_count it's better and this way it should be safe. I think
> it's an ok tradeoff, hopefully then nobody will ask to schedule in
> ->invalidate_page. Still it'd be interesting (back to Andrew's
> argument) to understand what is fundamentally different that you are
> ok not to schedule in ->invalidate_page but you absolutely need it
> here. And yes this will break also my transparent hugepage patch that

In the _invalidate_page case, it is called by the kernel from sites where
the kernel is relying upon the reference count to eliminate the page from
use while maintaining the page's data as clean and ready to be released.
If the page is marked as dirty, etc. then the kernel will "do the right
thing" with the page to maintain data consistency.

The _invalidate_range_start/end pairs are used in places where the
caller's address space is being modified.  If we allow the attachers
to continue to use the old pages from the old mapping even for a short
time after the process has started to use the new pages, there would be
silent data corruption.

A difference is the kernel's expectations.  The truncate case is the one
place where the kernel's expectation for _invalidate_range_start/end
more closely matches those of _invalidate_page.  When I was babbling
about a new version of the patch, it basically adds that concept to the
_invalidate_range_start callout as a parameter.  Essentially changing
the bool atomic into a flag indicating the kernel does not expect this
step to be complete prior finishing this callout.

I don't like that second patch which is why I have not posted it.
It relies upon the fuzzy quantity of an "adequate" period of time between
when the file is truncated down before it may be extended again to ensure
data consistency.  Shrink and extend too quickly and problems will ensue.

> can't schedule inside the anon_vma->lock and uses the range calls to
> be safer (then maybe we can require the mmu notifier users to check
> PageTransHuge against the pages and handle the invalidate through
> ->invalidate_page or we can add ->invalidate_transhuge_page.

I don't think that is a problem.  I don't think the GRU has any issues
at all.  I believe that the invalidate even of a standard page size will
eliminate the entire TLB.  Jack was going to verify that the last time
I talked with him.  If it behaved any differently, I would be surprised
as it would be inconsistent with nearly every other TLB out there.

XPMEM will currently not work, but I believe I can get it to work quite
easily as I can walk the segment's PFN table without acquiring any
sleeping locks and decide to expand the page size for any invalidation
within that range.  With that, at the time of the callout, I can schedule
an invalidation of the appropriate size.


As for the transparent huge page patches, I have just skimmed them
lightly as I really don't have much time to understand your intention.
I do think I am agreeing with Christoph Lameter that using the migration
style mechanism is probably better in that it handles the invalidate_page
callouts, follows the page reference counts, and allows my asynchronous
invalidation expectation to persist.

If I read it correctly, your patch would now require invalidate_page
to be complete and have reference counts pushed back down upon return.
I probably missed a key portion of that patch and would welcome the
chance to be informed.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
