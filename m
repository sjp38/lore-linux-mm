Message-ID: <38EF9135.2A42DC6E@colorfullife.com>
Date: Sat, 08 Apr 2000 22:06:13 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
MIME-Version: 1.0
Subject: zap_page_range(): TLB flush race
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

it seems we have a smp race in zap_page_range():

When we remove a page from the page tables, we must call:

	flush_cache_page();
	pte_clear();
	flush_tlb_page();
	free_page();

We must not free the page before we have called flush_tlb_xy(),
otherwise the second cpu could access memory that already freed.

but zap_page_range() calls free_page() before the flush_tlb() call.

Is that really a bug, has anyone a good idea how to fix that?

filemap_sync() calls flush_tlb_page() for each page, but IMHO this is a
really bad idea, the performance will suck with multi-threaded apps on
SMP.

Perhaps build a linked list, and free later?
We could abuse the next pointer from "struct page".
--
	Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
