Received: from zeus-fddi.americas.sgi.com (128-162-8-103.americas.sgi.com [128.162.8.103])
	by sgi.com (980327.SGI.8.8.8-aspam/980304.SGI-aspam:
       SGI does not authorize the use of its proprietary
       systems or networks for unsolicited or bulk email
       from the Internet.)
	via ESMTP id JAA09858
	for <linux-mm@kvack.org>; Fri, 25 May 2001 09:40:41 -0700 (PDT)
	mail_from (steiner@sgi.com)
Received: from daisy-e185.americas.sgi.com (daisy.americas.sgi.com [128.162.185.214]) by zeus-fddi.americas.sgi.com (8.9.3/americas-smart-nospam1.1) with ESMTP id LAA1949384 for <linux-mm@kvack.org>; Fri, 25 May 2001 11:40:40 -0500 (CDT)
Received: from fsgi056.americas.sgi.com (fsgi056.americas.sgi.com [128.162.184.62]) by daisy-e185.americas.sgi.com (SGI-8.9.3/SGI-server-1.7) with ESMTP id LAA41248 for <linux-mm@kvack.org>; Fri, 25 May 2001 11:40:40 -0500 (CDT)
From: Jack Steiner <steiner@sgi.com>
Message-Id: <200105251640.LAA50840@fsgi056.americas.sgi.com>
Subject: Possible bug in tlb shootdown patch (IA64)
Date: Fri, 25 May 2001 11:40:39 -0500 (CDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We hit a problem that looks like it is related to the tlb
shootdown patch. 

We are running on an IA64. The application does frequent
mmap/munmap operations. The initial symptom was that although the 
the application normally ran fine, it would fail intermittently 
when a "ps -efl" was run. The cause of the failure was stale
TLB entries from a prior mmap mapping.

The problem appears to be caused by the following sequence in
the tlb_remove_page/tlb_finish_mmu macros that are called as
part of do_munmap->zap_page_range->zap_pmd_range->zap_pte_range:


	- tlb_gather_mmu is called while "ps" is also looking
	  at the address space (ie., mm->mm_users >1)

	- tlb_remove_page is called. "address" is not the user virtual
	  being unmapped - it is a relative offset into a page table. 
	  This address gets stashed in the free_pte_ctx struct.

	- tlb_finish_mmu calls flush_tlb_range & passes the stashed 
	  address (ctx->start_addr) to flush_tlb_range. Since this
	  is not the user virtual address being unmapped, it causes 
	  the TLB shootdown to fail.

	
Does this make sense and is this a known problem. Perhap I am just running
with an old patch.


-- 
Thanks

Jack Steiner    (651-683-5302)        steiner@sgi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
