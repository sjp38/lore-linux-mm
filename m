Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4B8F36B04C0
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 02:41:52 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g46so29356922wrd.3
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 23:41:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a21si8448641wme.115.2017.07.10.23.41.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Jul 2017 23:41:51 -0700 (PDT)
Date: Tue, 11 Jul 2017 07:41:49 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170711064149.bg63nvi54ycynxw4@suse.de>
References: <69BBEB97-1B10-4229-9AEF-DE19C26D8DFF@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <69BBEB97-1B10-4229-9AEF-DE19C26D8DFF@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Mon, Jul 10, 2017 at 05:52:25PM -0700, Nadav Amit wrote:
> Something bothers me about the TLB flushes batching mechanism that Linux
> uses on x86 and I would appreciate your opinion regarding it.
> 
> As you know, try_to_unmap_one() can batch TLB invalidations. While doing so,
> however, the page-table lock(s) are not held, and I see no indication of the
> pending flush saved (and regarded) in the relevant mm-structs.
> 
> So, my question: what prevents, at least in theory, the following scenario:
> 
> 	CPU0 				CPU1
> 	----				----
> 					user accesses memory using RW PTE 
> 					[PTE now cached in TLB]
> 	try_to_unmap_one()
> 	==> ptep_get_and_clear()
> 	==> set_tlb_ubc_flush_pending()
> 					mprotect(addr, PROT_READ)
> 					==> change_pte_range()
> 					==> [ PTE non-present - no flush ]
> 
> 					user writes using cached RW PTE
> 	...
> 
> 	try_to_unmap_flush()
> 
> 
> As you see CPU1 write should have failed, but may succeed. 
> 
> Now I don???t have a PoC since in practice it seems hard to create such a
> scenario: try_to_unmap_one() is likely to find the PTE accessed and the PTE
> would not be reclaimed.
> 

That is the same to a race whereby there is no batching mechanism and the
racing operation happens between a pte clear and a flush as ptep_clear_flush
is not atomic. All that differs is that the race window is a different size.
The application on CPU1 is buggy in that it may or may not succeed the write
but it is buggy regardless of whether a batching mechanism is used or not.

The user accessed the PTE before the mprotect so, at the time of mprotect,
the PTE is either clean or dirty. If it is clean then any subsequent write
would transition the PTE from clean to dirty and an architecture enabling
the batching mechanism must trap a clean->dirty transition for unmapped
entries as commented upon in try_to_unmap_one (and was checked that this
is true for x86 at least). This avoids data corruption due to a lost update.

If the previous access was a write then the batching flushes the page if
any IO is required to avoid any writes after the IO has been initiated
using try_to_unmap_flush_dirty so again there is no data corruption. There
is a window where the TLB entry exists after the unmapping but this exists
regardless of whether we batch or not.

In either case, before a page is freed and potentially allocated to another
process, the TLB is flushed.

> Yet, isn???t it a problem? Am I missing something?
> 

It's not a problem as such as it's basically a buggy application that
can only hurt itself.  I cannot see a path whereby the cached PTE can be
used to corrupt data by either accessing it after IO has been initiated
(lost data update) or access a physical page that has been allocated to
another process (arbitrary corruption).

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
