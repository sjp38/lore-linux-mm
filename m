Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAS53CAW019982
	for <linux-mm@kvack.org>; Wed, 28 Nov 2007 00:03:12 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lAS53CVx111228
	for <linux-mm@kvack.org>; Tue, 27 Nov 2007 22:03:12 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAS53CPq017685
	for <linux-mm@kvack.org>; Tue, 27 Nov 2007 22:03:12 -0700
Message-ID: <474CF68E.1040709@us.ibm.com>
Date: Tue, 27 Nov 2007 23:03:10 -0600
From: Jon Tollefson <kniht@us.ibm.com>
Reply-To: kniht@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: [PATCH 1/2] powerpc: add hugepagesz boot-time parameter
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linuxppc-dev <linuxppc-dev@ozlabs.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This patch adds the hugepagesz boot-time parameter for ppc64 that lets 
you pick the size for your huge pages.  The choices available are 64K 
and 16M.  It defaults to 16M (previously the only choice) if nothing or 
an invalid choice is specified.  Tested 64K huge pages with the 
libhugetlbfs 1.2 release with its 'make func' and 'make stress' test 
invocations.

This patch requires the patch posted by Mel Gorman that adds 
HUGETLB_PAGE_SIZE_VARIABLE; "[PATCH] Fix boot problem with iSeries 
lacking hugepage support" on 2007-11-15.

Signed-off-by: Jon Tollefson <kniht@linux.vnet.ibm.com>
---

 Documentation/kernel-parameters.txt |    1 
 arch/powerpc/mm/hash_utils_64.c     |   11 +--------
 arch/powerpc/mm/hugetlbpage.c       |   41 ++++++++++++++++++++++++++++++++++++
 include/asm-powerpc/mmu-hash64.h    |    1 
 mm/hugetlb.c                        |    1 
 5 files changed, 46 insertions(+), 9 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 33121d6..2fc1fb8 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -685,6 +685,7 @@ and is between 256 and 4096 characters. It is defined in the file
 			See Documentation/isdn/README.HiSax.
 
 	hugepages=	[HW,X86-32,IA-64] Maximal number of HugeTLB pages.
+	hugepagesz=	[HW,IA-64,PPC] The size of the HugeTLB pages.
 
 	i8042.direct	[HW] Put keyboard port into non-translated mode
 	i8042.dumbkbd	[HW] Pretend that controller can only read data from
diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index f09730b..afc044c 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -368,18 +368,11 @@ static void __init htab_init_page_sizes(void)
 	 * on what is available
 	 */
 	if (mmu_psize_defs[MMU_PAGE_16M].shift)
-		mmu_huge_psize = MMU_PAGE_16M;
+		set_huge_psize(MMU_PAGE_16M);
 	/* With 4k/4level pagetables, we can't (for now) cope with a
 	 * huge page size < PMD_SIZE */
 	else if (mmu_psize_defs[MMU_PAGE_1M].shift)
-		mmu_huge_psize = MMU_PAGE_1M;
-
-	/* Calculate HPAGE_SHIFT and sanity check it */
-	if (mmu_psize_defs[mmu_huge_psize].shift > MIN_HUGEPTE_SHIFT &&
-	    mmu_psize_defs[mmu_huge_psize].shift < SID_SHIFT)
-		HPAGE_SHIFT = mmu_psize_defs[mmu_huge_psize].shift;
-	else
-		HPAGE_SHIFT = 0; /* No huge pages dude ! */
+		set_huge_psize(MMU_PAGE_1M);
 #endif /* CONFIG_HUGETLB_PAGE */
 }
 
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 71efb38..f4632ad 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -24,6 +24,9 @@
 #include <asm/cputable.h>
 #include <asm/spu.h>
 
+#define HPAGE_SHIFT_64K	16
+#define HPAGE_SHIFT_16M	24
+
 #define NUM_LOW_AREAS	(0x100000000UL >> SID_SHIFT)
 #define NUM_HIGH_AREAS	(PGTABLE_RANGE >> HTLB_AREA_SHIFT)
 
@@ -526,6 +529,44 @@ repeat:
 	return err;
 }
 
+void set_huge_psize(int psize)
+{
+	/* Check that it is a page size supported by the hardware and
+	 * that it fits within pagetable limits. */
+	if (mmu_psize_defs[psize].shift && mmu_psize_defs[psize].shift < SID_SHIFT &&
+		(mmu_psize_defs[psize].shift > MIN_HUGEPTE_SHIFT ||
+			mmu_psize_defs[psize].shift == HPAGE_SHIFT_64K)) {
+		HPAGE_SHIFT = mmu_psize_defs[psize].shift;
+		mmu_huge_psize = psize;
+	} else
+		HPAGE_SHIFT = 0;
+}
+
+static int __init hugepage_setup_sz(char *str)
+{
+	unsigned long long size;
+
+	size = memparse(str, &str);
+
+	int shift = __ffs(size);
+	int mmu_psize = -1;
+	switch (shift) {
+	case HPAGE_SHIFT_64K:
+		mmu_psize = MMU_PAGE_64K;
+		break;
+	case HPAGE_SHIFT_16M:
+		mmu_psize = MMU_PAGE_16M;
+		break;
+	}
+	if (mmu_psize >= 0 && mmu_psize_defs[mmu_psize].shift)
+		set_huge_psize(mmu_psize);
+	else
+		printk(KERN_WARNING "Invalid huge page size specified(%i)\n", size);
+
+	return 1;
+}
+__setup("hugepagesz=", hugepage_setup_sz);
+
 static void zero_ctor(struct kmem_cache *cache, void *addr)
 {
 	memset(addr, 0, kmem_cache_size(cache));
diff --git a/include/asm-powerpc/mmu-hash64.h b/include/asm-powerpc/mmu-hash64.h
index 82328de..f35c945 100644
--- a/include/asm-powerpc/mmu-hash64.h
+++ b/include/asm-powerpc/mmu-hash64.h
@@ -277,6 +277,7 @@ extern int hash_huge_page(struct mm_struct *mm, unsigned long access,
 extern int htab_bolt_mapping(unsigned long vstart, unsigned long vend,
 			     unsigned long pstart, unsigned long mode,
 			     int psize, int ssize);
+extern void set_huge_psize(int psize);
 
 extern void htab_initialize(void);
 extern void htab_initialize_secondary(void);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 6121b57..055d232 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -422,6 +422,7 @@ static int __init hugetlb_init(void)
 			break;
 	}
 	max_huge_pages = free_huge_pages = nr_huge_pages = i;
+	printk(KERN_INFO "HugeTLB page size: %ld bytes\n", HPAGE_SIZE);
 	printk("Total HugeTLB memory allocated, %ld\n", free_huge_pages);
 	return 0;
 }



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
