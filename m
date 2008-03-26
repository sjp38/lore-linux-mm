Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2QLTUuu022577
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 17:29:30 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2QLTUvH309564
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 17:29:30 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2QLTTXu001489
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 17:29:30 -0400
Message-ID: <47EAC048.30006@linux.vnet.ibm.com>
Date: Wed, 26 Mar 2008 16:29:44 -0500
From: Jon Tollefson <kniht@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 4/4] powerpc: define page support for 16G pages
References: <47EABE2D.7080400@linux.vnet.ibm.com>
In-Reply-To: <47EABE2D.7080400@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@ozlabs.org>
Cc: Adam Litke <agl@linux.vnet.ibm.com>, Andi Kleen <andi@firstfloor.org>, Paul Mackerras <paulus@samba.org>
List-ID: <linux-mm.kvack.org>

The huge page size is setup for 16G pages if that size is specified at boot-time.  The support for
multiple huge page sizes is not being utilized yet.  That will be in a future patch.


Signed-off-by: Jon Tollefson <kniht@linux.vnet.ibm.com>
---

 hugetlbpage.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)


diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 44d3d55..b6a02b7 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -26,6 +26,7 @@
 
 #define HPAGE_SHIFT_64K	16
 #define HPAGE_SHIFT_16M	24
+#define HPAGE_SHIFT_16G	34
 
 #define NUM_LOW_AREAS	(0x100000000UL >> SID_SHIFT)
 #define NUM_HIGH_AREAS	(PGTABLE_RANGE >> HTLB_AREA_SHIFT)
@@ -589,9 +590,11 @@ void set_huge_psize(int psize)
 {
 	/* Check that it is a page size supported by the hardware and
 	 * that it fits within pagetable limits. */
-	if (mmu_psize_defs[psize].shift && mmu_psize_defs[psize].shift < SID_SHIFT &&
+	if (mmu_psize_defs[psize].shift &&
+		mmu_psize_defs[psize].shift < SID_SHIFT_1T &&
 		(mmu_psize_defs[psize].shift > MIN_HUGEPTE_SHIFT ||
-			mmu_psize_defs[psize].shift == HPAGE_SHIFT_64K)) {
+		 mmu_psize_defs[psize].shift == HPAGE_SHIFT_64K ||
+		 mmu_psize_defs[psize].shift == HPAGE_SHIFT_16G)) {
 		HPAGE_SHIFT = mmu_psize_defs[psize].shift;
 		mmu_huge_psize = psize;
 #ifdef CONFIG_PPC_64K_PAGES
@@ -599,6 +602,8 @@ void set_huge_psize(int psize)
 #else
 		if (HPAGE_SHIFT == HPAGE_SHIFT_64K)
 			hugepte_shift = (PMD_SHIFT-HPAGE_SHIFT);
+		else if (HPAGE_SHIFT == HPAGE_SHIFT_16G)
+			hugepte_shift = (PGDIR_SHIFT-HPAGE_SHIFT);
 		else
 			hugepte_shift = (PUD_SHIFT-HPAGE_SHIFT);
 #endif
@@ -625,6 +630,9 @@ static int __init hugepage_setup_sz(char *str)
 	case HPAGE_SHIFT_16M:
 		mmu_psize = MMU_PAGE_16M;
 		break;
+	case HPAGE_SHIFT_16G:
+		mmu_psize = MMU_PAGE_16G;
+		break;
 	}
 
 	if (mmu_psize >=0 && mmu_psize_defs[mmu_psize].shift)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
