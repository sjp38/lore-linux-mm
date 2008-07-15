Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m6FMnARZ027865
	for <linux-mm@kvack.org>; Tue, 15 Jul 2008 18:49:10 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6FMnAnU228360
	for <linux-mm@kvack.org>; Tue, 15 Jul 2008 18:49:10 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6FMnAuC031425
	for <linux-mm@kvack.org>; Tue, 15 Jul 2008 18:49:10 -0400
Message-ID: <487D2982.90109@linux.vnet.ibm.com>
Date: Tue, 15 Jul 2008 17:49:38 -0500
From: Jon Tollefson <kniht@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [patch v2] powerpc: hugetlb pgtable cache access cleanup
References: <20080604112939.789444496@amd.local0.net> <20080604113113.648031825@amd.local0.net> <487B7F96.70305@linux.vnet.ibm.com> <20080714155659.b4fab697.akpm@linux-foundation.org>
In-Reply-To: <20080714155659.b4fab697.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: npiggin@suse.de, adobriyan@gmail.com, penberg@cs.helsinki.fi, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Mon, 14 Jul 2008 11:32:22 -0500
> Jon Tollefson <kniht@linux.vnet.ibm.com> wrote:
>
>   
>> Cleaned up use of macro.  We now reference the pgtable_cache array directly instead of using a macro.
>>     
>
> This clashes rather a lot with all the other hugetlb things which we
> have queued.
>
>   
oops.  new version below here should be based on mmotm.
---


Cleaned up use of macro.  We now reference the pgtable_cache array directly instead of using a macro.


Signed-off-by: Jon Tollefson <kniht@linux.vnet.ibm.com>
---

 arch/powerpc/mm/hugetlbpage.c |   22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)


--- a/arch/powerpc/mm/hugetlbpage.c	2008-07-15 17:17:42.741035616 -0500
+++ b/arch/powerpc/mm/hugetlbpage.c	2008-07-15 17:36:48.959015872 -0500
@@ -53,8 +53,7 @@
 
 /* Subtract one from array size because we don't need a cache for 4K since
  * is not a huge page size */
-#define huge_pgtable_cache(psize)	(pgtable_cache[HUGEPTE_CACHE_NUM \
-							+ psize-1])
+#define HUGE_PGTABLE_INDEX(psize)	(HUGEPTE_CACHE_NUM + psize - 1)
 #define HUGEPTE_CACHE_NAME(psize)	(huge_pgtable_cache_name[psize])
 
 static const char *huge_pgtable_cache_name[MMU_PAGE_COUNT] = {
@@ -113,7 +112,7 @@
 static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
 			   unsigned long address, unsigned int psize)
 {
-	pte_t *new = kmem_cache_zalloc(huge_pgtable_cache(psize),
+	pte_t *new = kmem_cache_zalloc(pgtable_cache[HUGE_PGTABLE_INDEX(psize)],
 				      GFP_KERNEL|__GFP_REPEAT);
 
 	if (! new)
@@ -121,7 +120,7 @@
 
 	spin_lock(&mm->page_table_lock);
 	if (!hugepd_none(*hpdp))
-		kmem_cache_free(huge_pgtable_cache(psize), new);
+		kmem_cache_free(pgtable_cache[HUGE_PGTABLE_INDEX(psize)], new);
 	else
 		hpdp->pd = (unsigned long)new | HUGEPD_OK;
 	spin_unlock(&mm->page_table_lock);
@@ -746,13 +745,14 @@
 
 	for (psize = 0; psize < MMU_PAGE_COUNT; ++psize) {
 		if (mmu_huge_psizes[psize]) {
-			huge_pgtable_cache(psize) = kmem_cache_create(
-						HUGEPTE_CACHE_NAME(psize),
-						HUGEPTE_TABLE_SIZE(psize),
-						HUGEPTE_TABLE_SIZE(psize),
-						0,
-						NULL);
-			if (!huge_pgtable_cache(psize))
+			pgtable_cache[HUGE_PGTABLE_INDEX(psize)] =
+				kmem_cache_create(
+					HUGEPTE_CACHE_NAME(psize),
+					HUGEPTE_TABLE_SIZE(psize),
+					HUGEPTE_TABLE_SIZE(psize),
+					0,
+					NULL);
+			if (!pgtable_cache[HUGE_PGTABLE_INDEX(psize)])
 				panic("hugetlbpage_init(): could not create %s"\
 				      "\n", HUGEPTE_CACHE_NAME(psize));
 		}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
