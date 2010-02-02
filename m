Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 944F96B0071
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 10:21:48 -0500 (EST)
Date: Tue, 2 Feb 2010 09:21:42 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [RFP-V2 0/3] Make mmu_notifier_invalidate_range_start able to
 sleep.
Message-ID: <20100202152142.GQ6653@sgi.com>
References: <20100202040145.555474000@alcatraz.americas.sgi.com>
 <20100202080947.GA28736@infradead.org>
 <20100202125943.GH4135@random.random>
 <20100202131341.GI4135@random.random>
 <20100202132919.GO6653@sgi.com>
 <20100202134047.GJ4135@random.random>
 <20100202135141.GH6616@sgi.com>
 <20100202141036.GL4135@random.random>
 <20100202142130.GI6616@sgi.com>
 <20100202145911.GM4135@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100202145911.GM4135@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Robin Holt <holt@sgi.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 02, 2010 at 03:59:11PM +0100, Andrea Arcangeli wrote:
> > I think you missed my correction to an earlier statement.  This patcheset
> > does not have any data corruption or userland inconsistency.  I had mistakenly
> > spoken of a patchset I am working up as a lesser alternative to this one.
> 
> If there is never data corruption or userland inconsistency when I do
> mmap(MAP_SHARED) truncate(0) then I've to wonder why at all you need
> any modification if you already can handle remote spte invalidation
> through atomic sections. That is ridiculous that you can handle it
> through atomic-section truncate without sleepability, and you still
> ask sleepability for mmu notifier in the first place...

In the truncate(0) example you provide, the sequence would be as follows:

On the first call from unmap_vmas into _inv_range_start(atomic==1),
XPMEM would scan the segment's PFN table.  If there were pages in that
range which have been exported, we would return !0 without doing any
invalidation.

The unmap_vmas code would see the non-zero return and return start_addr
back to zap_page_range and further to unmap_mapping_range_vma where
need_unlocked_invalidate would be set.

unmap_mapping_range_vma would then unlock the i_mmap_lock, call
_inv_range_start(atomic==0) which would clear all the remote page tables
and TLBs.  It would then reaquire the i_mmap_lock and retry.

This time unmap_vmas would call _inv_range_start(atomic==1).  XPMEM would
scan the segment's PFN table and find there were no pages exported and
return 0.

Things would proceed as normal from there.

No corruption.  No intrusive locking additions that negatively affect
the vast majority of users.  A compromise.  The only downside I can see
at all in the CONFIG_MMU_NOTIFIER=n case is unmap_mapping_range_vma is
slightly larger.

Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
