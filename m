Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m6EGW164006117
	for <linux-mm@kvack.org>; Mon, 14 Jul 2008 12:32:01 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6EGW1C6144832
	for <linux-mm@kvack.org>; Mon, 14 Jul 2008 10:32:01 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6EGW0oK020832
	for <linux-mm@kvack.org>; Mon, 14 Jul 2008 10:32:00 -0600
Message-ID: <487B7F96.70305@linux.vnet.ibm.com>
Date: Mon, 14 Jul 2008 11:32:22 -0500
From: Jon Tollefson <kniht@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [patch] powerpc: hugetlb pgtable cache access cleanup
References: <20080604112939.789444496@amd.local0.net> <20080604113113.648031825@amd.local0.net>
In-Reply-To: <20080604113113.648031825@amd.local0.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, Alexey Dobriyan <adobriyan@gmail.com>, penberg@cs.helsinki.fi, mpm@selenic.com, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Cleaned up use of macro.  We now reference the pgtable_cache array directly instead of using a macro.


Signed-off-by: Jon Tollefson <kniht@linux.vnet.ibm.com>
---

 arch/powerpc/mm/hugetlbpage.c |   22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)


diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index fb42c4d..2184fc0 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -53,8 +53,7 @@ unsigned int mmu_huge_psizes[MMU_PAGE_COUNT] = { }; /* initialize all to 0 */
 
 /* Subtract one from array size because we don't need a cache for 4K since
  * is not a huge page size */
-#define huge_pgtable_cache(psize)	(pgtable_cache[HUGEPTE_CACHE_NUM \
-							+ psize-1])
+#define HUGE_PGTABLE_INDEX(psize)	(HUGEPTE_CACHE_NUM + psize - 1)
 #define HUGEPTE_CACHE_NAME(psize)	(huge_pgtable_cache_name[psize])
 
 static const char *huge_pgtable_cache_name[MMU_PAGE_COUNT] = {
@@ -113,7 +112,7 @@ static inline pte_t *hugepte_offset(hugepd_t *hpdp, unsigned long addr,
 static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
 			   unsigned long address, unsigned int psize)
 {
-	pte_t *new = kmem_cache_alloc(huge_pgtable_cache(psize),
+	pte_t *new = kmem_cache_alloc(pgtable_cache[HUGE_PGTABLE_INDEX(psize)],
 				      GFP_KERNEL|__GFP_REPEAT);
 
 	if (! new)
@@ -121,7 +120,7 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
 
 	spin_lock(&mm->page_table_lock);
 	if (!hugepd_none(*hpdp))
-		kmem_cache_free(huge_pgtable_cache(psize), new);
+		kmem_cache_free(pgtable_cache[HUGE_PGTABLE_INDEX(psize)], new);
 	else
 		hpdp->pd = (unsigned long)new | HUGEPD_OK;
 	spin_unlock(&mm->page_table_lock);
@@ -751,13 +750,14 @@ static int __init hugetlbpage_init(void)
 
 	for (psize = 0; psize < MMU_PAGE_COUNT; ++psize) {
 		if (mmu_huge_psizes[psize]) {
-			huge_pgtable_cache(psize) = kmem_cache_create(
-						HUGEPTE_CACHE_NAME(psize),
-						HUGEPTE_TABLE_SIZE(psize),
-						HUGEPTE_TABLE_SIZE(psize),
-						0,
-						zero_ctor);
-			if (!huge_pgtable_cache(psize))
+			pgtable_cache[HUGE_PGTABLE_INDEX(psize)] =
+				kmem_cache_create(
+					HUGEPTE_CACHE_NAME(psize),
+					HUGEPTE_TABLE_SIZE(psize),
+					HUGEPTE_TABLE_SIZE(psize),
+					0,
+					zero_ctor);
+			if (!pgtable_cache[HUGE_PGTABLE_INDEX(psize)])
 				panic("hugetlbpage_init(): could not create %s"\
 				      "\n", HUGEPTE_CACHE_NAME(psize));
 		}



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
