From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200004082111.OAA73647@google.engr.sgi.com>
Subject: Re: zap_page_range(): TLB flush race
Date: Sat, 8 Apr 2000 14:11:05 -0700 (PDT)
In-Reply-To: <38EF9135.2A42DC6E@colorfullife.com> from "Manfred Spraul" at Apr 08, 2000 10:06:13 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfreds@colorfullife.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> it seems we have a smp race in zap_page_range():
> 
> When we remove a page from the page tables, we must call:
> 
> 	flush_cache_page();
> 	pte_clear();
> 	flush_tlb_page();
> 	free_page();
> 
> We must not free the page before we have called flush_tlb_xy(),
> otherwise the second cpu could access memory that already freed.
> 
> but zap_page_range() calls free_page() before the flush_tlb() call.
> 
> Is that really a bug, has anyone a good idea how to fix that?

Why do you think this is a bug? After the pte_clear, we need to flush
tlb, so that if anyone wants to drag in the mapping (by accessing the
virtual address), he will fault (since translation is not in tlb) and 
wait on mmap_sem. After that, when zap_page_range has freed the page, 
and released the mmap_sem, the faulter will find he was trying to access 
what is now invalid memory and get a signal/killed.

But a race does exist in establish_pte(), when the flush_tlb happens
_before_ the set_pte(), another thread might drag in the old translation
on a different cpu.

> 
> filemap_sync() calls flush_tlb_page() for each page, but IMHO this is a
> really bad idea, the performance will suck with multi-threaded apps on
> SMP.

The best you can do probably is a flush_tlb_range?

Kanoj

> 
> Perhaps build a linked list, and free later?
> We could abuse the next pointer from "struct page".
> --
> 	Manfred
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
