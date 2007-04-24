Message-ID: <462D713D.6050401@redhat.com>
Date: Mon, 23 Apr 2007 22:53:49 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE
References: <46247427.6000902@redhat.com>	<20070420135715.f6e8e091.akpm@linux-foundation.org>	<462932BE.4020005@redhat.com> <20070420150618.179d31a4.akpm@linux-foundation.org> <4629524C.5040302@redhat.com> <462ACA40.8070407@yahoo.com.au> <462B0156.9020407@redhat.com> <462BFAF3.4040509@yahoo.com.au> <462C2DC7.5070709@redhat.com> <462C2F33.8090508@redhat.com> <462C7A6F.9030905@redhat.com> <462C88B1.8080906@yahoo.com.au> <462C8B0A.8060801@redhat.com> <462C8BFF.2050405@yahoo.com.au>
In-Reply-To: <462C8BFF.2050405@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------060905040101000808040608"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, shak <dshaks@redhat.com>, jakub@redhat.com, drepper@redhat.com
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------060905040101000808040608
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Nick Piggin wrote:

> What the tlb flush used to be able to assume is that the page
> has been removed from the pagetables when they are put in the
> tlb flush batch.

I think this is still the case, to a degree.  There should be
no harm in removing the TLB entries after the page table has
been unlocked, right?

Or is something like the attached really needed?

 From what I can see, the page table lock should be enough
synchronization between unmap_mapping_range, MADV_FREE and
MADV_DONTNEED.

I don't see why we need the attached, but in case you find
a good reason, here's my signed-off-by line for Andrew :)

Signed-off-by: Rik van Riel <riel@redhat.com>

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--------------060905040101000808040608
Content-Type: text/x-patch;
 name="linux-2.6-madv_free-flushme.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6-madv_free-flushme.patch"

--- linux-2.6.20.x86_64/mm/memory.c.flushme	2007-04-23 22:26:06.000000000 -0400
+++ linux-2.6.20.x86_64/mm/memory.c	2007-04-23 22:42:06.000000000 -0400
@@ -628,6 +628,7 @@ static unsigned long zap_pte_range(struc
 				long *zap_work, struct zap_details *details)
 {
 	struct mm_struct *mm = tlb->mm;
+	unsigned long start_addr = addr;
 	pte_t *pte;
 	spinlock_t *ptl;
 	int file_rss = 0;
@@ -726,6 +727,11 @@ static unsigned long zap_pte_range(struc
 
 	add_mm_rss(mm, file_rss, anon_rss);
 	arch_leave_lazy_mmu_mode();
+	if (details && details->madv_free) {
+		/* Protect against MADV_DONTNEED or unmap_mapping_range */
+		tlb_finish_mmu(tlb, start_addr, addr);
+		tlb = tlb_gather_mmu(mm, 0);
+	}
 	pte_unmap_unlock(pte - 1, ptl);
 
 	return addr;

--------------060905040101000808040608--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
