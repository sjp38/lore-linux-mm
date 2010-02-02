Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4BF1D6B009C
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 11:01:56 -0500 (EST)
Date: Tue, 2 Feb 2010 17:01:46 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFP-V2 0/3] Make mmu_notifier_invalidate_range_start able to
 sleep.
Message-ID: <20100202160146.GO4135@random.random>
References: <20100202080947.GA28736@infradead.org>
 <20100202125943.GH4135@random.random>
 <20100202131341.GI4135@random.random>
 <20100202132919.GO6653@sgi.com>
 <20100202134047.GJ4135@random.random>
 <20100202135141.GH6616@sgi.com>
 <20100202141036.GL4135@random.random>
 <20100202142130.GI6616@sgi.com>
 <20100202145911.GM4135@random.random>
 <20100202152142.GQ6653@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100202152142.GQ6653@sgi.com>
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 02, 2010 at 09:21:42AM -0600, Robin Holt wrote:
> unmap_mapping_range_vma would then unlock the i_mmap_lock, call
> _inv_range_start(atomic==0) which would clear all the remote page tables
> and TLBs.  It would then reaquire the i_mmap_lock and retry.

I guess you missed why we hold the i_mmap_lock there... it's not like
gratuitous locking complication there's an actual reason why it's
taken, and it's to avoid the vma to be freed from under you:

+       if (need_unlocked_invalidate) {
+               /*
+                * If zap_page_range failed to make any progress
because the
+                * mmu_notifier_invalidate_range_start was called
atomically
+                * while the callee needed to sleep.  In that event,
we
+                * make the callout while the i_mmap_lock is released.
+                */
+               mmu_notifier_invalidate_range_start(vma->vm_mm, start_addr, end_addr, 0);
+               mmu_notifier_invalidate_range_end(vma->vm_mm, start_addr, end_addr);

The above runs with vma being a dangling pointer, it'll corrupt memory
randomly and crash.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
