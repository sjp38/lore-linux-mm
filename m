Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 70FA16B0338
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 10:21:36 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id n18so8675055wra.11
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 07:21:36 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 12si1799265wmk.139.2017.06.09.07.21.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Jun 2017 07:21:35 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v59EIcLQ077147
	for <linux-mm@kvack.org>; Fri, 9 Jun 2017 10:21:33 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2ayw2y8whg-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 09 Jun 2017 10:21:33 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 9 Jun 2017 15:21:31 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v4 07/20] mm/spf: Try spin lock in speculative path
Date: Fri,  9 Jun 2017 16:20:56 +0200
In-Reply-To: <1497018069-17790-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1497018069-17790-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1497018069-17790-8-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

There is a deadlock when a CPU is doing a speculative page fault and
another one is calling do_unmap().

The deadlock occurred because the speculative path try to spinlock the
pte while the interrupt are disabled. When the other CPU in the
unmap's path has locked the pte then is waiting for all the CPU to
invalidate the TLB. As the CPU doing the speculative fault have the
interrupt disable it can't invalidate the TLB, and can't get the lock.

Since we are in a speculative path, we can race with other mm action.
So let assume that the lock may not get acquired and fail the
speculative page fault.

Here are the stack captured during the deadlock:

CPU 0
native_flush_tlb_others+0x7c/0x260
flush_tlb_mm_range+0x6a/0x220
tlb_flush_mmu_tlbonly+0x63/0xc0
unmap_page_range+0x897/0x9d0
? unmap_single_vma+0x7d/0xe0
? release_pages+0x2b3/0x360
unmap_single_vma+0x7d/0xe0
unmap_vmas+0x51/0xa0
unmap_region+0xbd/0x130
do_munmap+0x279/0x460
SyS_munmap+0x53/0x70

CPU 1
do_raw_spin_lock+0x14e/0x160
_raw_spin_lock+0x5d/0x80
? pte_map_lock+0x169/0x1b0
pte_map_lock+0x169/0x1b0
handle_pte_fault+0xbf2/0xd80
? trace_hardirqs_on+0xd/0x10
handle_speculative_fault+0x272/0x280
handle_speculative_fault+0x5/0x280
__do_page_fault+0x187/0x580
trace_do_page_fault+0x52/0x260
do_async_page_fault+0x19/0x70
async_page_fault+0x28/0x30

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/memory.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 8c43895e9310..9de741554e15 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2258,7 +2258,8 @@ static bool pte_spinlock(struct vm_fault *vmf)
 		goto out;
 
 	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
-	spin_lock(vmf->ptl);
+	if (unlikely(!spin_trylock(vmf->ptl)))
+		goto out;
 
 	if (vma_has_changed(vmf->vma, vmf->sequence)) {
 		spin_unlock(vmf->ptl);
@@ -2292,8 +2293,18 @@ static bool pte_map_lock(struct vm_fault *vmf)
 	if (vma_has_changed(vmf->vma, vmf->sequence))
 		goto out;
 
-	vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd,
-				       vmf->address, &vmf->ptl);
+	/* Same as pte_offset_map_lock() except that we call
+	 * spin_trylock() in place of spin_lock() to avoid race with
+	 * unmap path which may have the lock and wait for this CPU
+	 * to invalidate TLB but this CPU has irq disabled.
+	 * Since we are in a speculative patch, accept it could fail
+	 */
+	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
+	vmf->pte = pte_offset_map(vmf->pmd, vmf->address);
+	if (unlikely(!spin_trylock(vmf->ptl))) {
+		pte_unmap(vmf->pte);
+		goto out;
+	}
 
 	if (vma_has_changed(vmf->vma, vmf->sequence)) {
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
