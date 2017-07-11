Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9E8AB6B04D7
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 05:29:38 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g46so30346987wrd.3
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 02:29:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h82si8780781wmh.91.2017.07.11.02.29.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Jul 2017 02:29:37 -0700 (PDT)
Date: Tue, 11 Jul 2017 10:29:35 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170711092935.bogdb4oja6v7kilq@suse.de>
References: <69BBEB97-1B10-4229-9AEF-DE19C26D8DFF@gmail.com>
 <20170711064149.bg63nvi54ycynxw4@suse.de>
 <D810A11D-1827-48C7-BA74-C1A6DCD80862@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <D810A11D-1827-48C7-BA74-C1A6DCD80862@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Tue, Jul 11, 2017 at 12:30:28AM -0700, Nadav Amit wrote:
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > On Mon, Jul 10, 2017 at 05:52:25PM -0700, Nadav Amit wrote:
> >> Something bothers me about the TLB flushes batching mechanism that Linux
> >> uses on x86 and I would appreciate your opinion regarding it.
> >> 
> >> As you know, try_to_unmap_one() can batch TLB invalidations. While doing so,
> >> however, the page-table lock(s) are not held, and I see no indication of the
> >> pending flush saved (and regarded) in the relevant mm-structs.
> >> 
> >> So, my question: what prevents, at least in theory, the following scenario:
> >> 
> >> 	CPU0 				CPU1
> >> 	----				----
> >> 					user accesses memory using RW PTE 
> >> 					[PTE now cached in TLB]
> >> 	try_to_unmap_one()
> >> 	==> ptep_get_and_clear()
> >> 	==> set_tlb_ubc_flush_pending()
> >> 					mprotect(addr, PROT_READ)
> >> 					==> change_pte_range()
> >> 					==> [ PTE non-present - no flush ]
> >> 
> >> 					user writes using cached RW PTE
> >> 	...
> >> 
> >> 	try_to_unmap_flush()
> >> 
> >> 
> >> As you see CPU1 write should have failed, but may succeed. 
> >> 
> >> Now I don???t have a PoC since in practice it seems hard to create such a
> >> scenario: try_to_unmap_one() is likely to find the PTE accessed and the PTE
> >> would not be reclaimed.
> > 
> > That is the same to a race whereby there is no batching mechanism and the
> > racing operation happens between a pte clear and a flush as ptep_clear_flush
> > is not atomic. All that differs is that the race window is a different size.
> > The application on CPU1 is buggy in that it may or may not succeed the write
> > but it is buggy regardless of whether a batching mechanism is used or not.
> 
> Thanks for your quick and detailed response, but I fail to see how it can
> happen without batching. Indeed, the PTE clear and flush are not ???atomic???,
> but without batching they are both performed under the page table lock
> (which is acquired in page_vma_mapped_walk and released in
> page_vma_mapped_walk_done). Since the lock is taken, other cores should not
> be able to inspect/modify the PTE. Relevant functions, e.g., zap_pte_range
> and change_pte_range, acquire the lock before accessing the PTEs.
> 

I was primarily thinking in terms of memory corruption or data loss.
However, we are still protected although it's not particularly obvious why.

On the reclaim side, we are either reclaiming clean pages (which ignore
the accessed bit) or normal reclaim. If it's clean pages then any parallel
write must update the dirty bit at minimum. If it's normal reclaim then
the accessed bit is checked and if cleared in try_to_unmap_one, it uses a
ptep_clear_flush_young_notify so the TLB gets flushed. We don't reclaim
the page in either as part of page_referenced or try_to_unmap_one but
clearing the accessed bit flushes the TLB.

On the mprotect side then, as the page was first accessed, clearing the
accessed bit incurs a TLB flush on the reclaim side before the second write.
That means any TLB entry that exists cannot have the accessed bit set so
a second write needs to update it.

While it's not clearly documented, I checked with hardware engineers
at the time that an update of the accessed or dirty bit even with a TLB
entry will check the underlying page tables and trap if it's not present
and the subsequent fault will then fail on sigsegv if the VMA protections
no longer allow the write.

So, on one side if ignoring the accessed bit during reclaim, the pages
are clean so any access will set the dirty bit and trap if unmapped in
parallel. On the other side, the accessed bit if set cleared the TLB and
if not set, then the hardware needs to update and again will trap if
unmapped in parallel.

If this guarantee from hardware was every shown to be wrong or another
architecture wanted to add batching without the same guarantee then mprotect
would need to do a local_flush_tlb if no pages were updated by the mprotect
but right now, this should not be necessary.

> Can you please explain why you consider the application to be buggy?

I considered it a bit dumb to mprotect for READ/NONE and then try writing
the same mapping. However, it will behave as expected.

> AFAIU
> an application can wish to trap certain memory accesses using userfaultfd or
> SIGSEGV. For example, it may do it for garbage collection or sandboxing. To
> do so, it can use mprotect with PROT_NONE and expect to be able to trap
> future accesses to that memory. This use-case is described in usefaultfd
> documentation.
> 

Such applications are safe due to how the accessed bit is handled by the
software (flushes TLB if clearing young) and hardware (traps if updating
the accessed or dirty bit and the underlying PTE was unmapped even if
there is a TLB entry).

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
