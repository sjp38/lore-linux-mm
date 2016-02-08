Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8CB85830C6
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:21:17 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id ba1so145045935obb.3
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 01:21:17 -0800 (PST)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id sw6si1287823obc.72.2016.02.08.01.21.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 01:21:16 -0800 (PST)
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 8 Feb 2016 02:21:15 -0700
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 23B373E4003F
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 02:21:13 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08026.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u189LDfS27197660
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 02:21:13 -0700
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u189LCfV007574
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 02:21:12 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 09/29] powerpc/mm: Hugetlbfs is book3s_64 and fsl_book3e (32 or 64)
Date: Mon,  8 Feb 2016 14:50:21 +0530
Message-Id: <1454923241-6681-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We move large part of fsl related code to hugetlbpage-book3e.c.
Only code movement. This also avoid #ifdef in the code.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/hugetlb.h   |   1 +
 arch/powerpc/mm/hugetlbpage-book3e.c | 293 +++++++++++++++++++++++++
 arch/powerpc/mm/hugetlbpage-hash64.c | 121 +++++++++++
 arch/powerpc/mm/hugetlbpage.c        | 401 +----------------------------------
 4 files changed, 416 insertions(+), 400 deletions(-)

diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
index 7eac89b9f02e..0525f1c29afb 100644
--- a/arch/powerpc/include/asm/hugetlb.h
+++ b/arch/powerpc/include/asm/hugetlb.h
@@ -47,6 +47,7 @@ static inline unsigned int hugepd_shift(hugepd_t hpd)
 
 #endif /* CONFIG_PPC_BOOK3S_64 */
 
+#define hugepd_none(hpd)	((hpd).pd == 0)
 
 static inline pte_t *hugepte_offset(hugepd_t hpd, unsigned long addr,
 				    unsigned pdshift)
diff --git a/arch/powerpc/mm/hugetlbpage-book3e.c b/arch/powerpc/mm/hugetlbpage-book3e.c
index 7e6d0880813f..4c43a104e35c 100644
--- a/arch/powerpc/mm/hugetlbpage-book3e.c
+++ b/arch/powerpc/mm/hugetlbpage-book3e.c
@@ -7,6 +7,39 @@
  */
 #include <linux/mm.h>
 #include <linux/hugetlb.h>
+#include <linux/bootmem.h>
+#include <linux/moduleparam.h>
+#include <linux/memblock.h>
+#include <asm/tlb.h>
+#include <asm/setup.h>
+
+/*
+ * Tracks gpages after the device tree is scanned and before the
+ * huge_boot_pages list is ready.  On non-Freescale implementations, this is
+ * just used to track 16G pages and so is a single array.  FSL-based
+ * implementations may have more than one gpage size, so we need multiple
+ * arrays
+ */
+#ifdef CONFIG_PPC_FSL_BOOK3E
+#define MAX_NUMBER_GPAGES	128
+struct psize_gpages {
+	u64 gpage_list[MAX_NUMBER_GPAGES];
+	unsigned int nr_gpages;
+};
+static struct psize_gpages gpage_freearray[MMU_PAGE_COUNT];
+#endif
+
+/*
+ * These macros define how to determine which level of the page table holds
+ * the hpdp.
+ */
+#ifdef CONFIG_PPC_FSL_BOOK3E
+#define HUGEPD_PGD_SHIFT PGDIR_SHIFT
+#define HUGEPD_PUD_SHIFT PUD_SHIFT
+#else
+#define HUGEPD_PGD_SHIFT PUD_SHIFT
+#define HUGEPD_PUD_SHIFT PMD_SHIFT
+#endif
 
 #ifdef CONFIG_PPC_FSL_BOOK3E
 #ifdef CONFIG_PPC64
@@ -197,3 +230,263 @@ void flush_hugetlb_page(struct vm_area_struct *vma, unsigned long vmaddr)
 
 	__flush_tlb_page(vma->vm_mm, vmaddr, tsize, 0);
 }
+
+static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
+			   unsigned long address, unsigned pdshift, unsigned pshift)
+{
+	struct kmem_cache *cachep;
+	pte_t *new;
+
+	int i;
+	int num_hugepd = 1 << (pshift - pdshift);
+	cachep = hugepte_cache;
+
+	new = kmem_cache_zalloc(cachep, GFP_KERNEL|__GFP_REPEAT);
+
+	BUG_ON(pshift > HUGEPD_SHIFT_MASK);
+	BUG_ON((unsigned long)new & HUGEPD_SHIFT_MASK);
+
+	if (! new)
+		return -ENOMEM;
+
+	spin_lock(&mm->page_table_lock);
+	/*
+	 * We have multiple higher-level entries that point to the same
+	 * actual pte location.  Fill in each as we go and backtrack on error.
+	 * We need all of these so the DTLB pgtable walk code can find the
+	 * right higher-level entry without knowing if it's a hugepage or not.
+	 */
+	for (i = 0; i < num_hugepd; i++, hpdp++) {
+		if (unlikely(!hugepd_none(*hpdp)))
+			break;
+		else
+			/* We use the old format for PPC_FSL_BOOK3E */
+			hpdp->pd = ((unsigned long)new & ~PD_HUGE) | pshift;
+	}
+	/* If we bailed from the for loop early, an error occurred, clean up */
+	if (i < num_hugepd) {
+		for (i = i - 1 ; i >= 0; i--, hpdp--)
+			hpdp->pd = 0;
+		kmem_cache_free(cachep, new);
+	}
+	spin_unlock(&mm->page_table_lock);
+	return 0;
+}
+
+pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)
+{
+	pgd_t *pg;
+	pud_t *pu;
+	pmd_t *pm;
+	hugepd_t *hpdp = NULL;
+	unsigned pshift = __ffs(sz);
+	unsigned pdshift = PGDIR_SHIFT;
+
+	addr &= ~(sz-1);
+
+	pg = pgd_offset(mm, addr);
+
+	if (pshift >= HUGEPD_PGD_SHIFT) {
+		hpdp = (hugepd_t *)pg;
+	} else {
+		pdshift = PUD_SHIFT;
+		pu = pud_alloc(mm, pg, addr);
+		if (pshift >= HUGEPD_PUD_SHIFT) {
+			hpdp = (hugepd_t *)pu;
+		} else {
+			pdshift = PMD_SHIFT;
+			pm = pmd_alloc(mm, pu, addr);
+			hpdp = (hugepd_t *)pm;
+		}
+	}
+
+	if (!hpdp)
+		return NULL;
+
+	BUG_ON(!hugepd_none(*hpdp) && !hugepd_ok(*hpdp));
+
+	if (hugepd_none(*hpdp) && __hugepte_alloc(mm, hpdp, addr, pdshift, pshift))
+		return NULL;
+
+	return hugepte_offset(*hpdp, addr, pdshift);
+}
+
+#ifdef CONFIG_PPC_FSL_BOOK3E
+/* Build list of addresses of gigantic pages.  This function is used in early
+ * boot before the buddy allocator is setup.
+ */
+void add_gpage(u64 addr, u64 page_size, unsigned long number_of_pages)
+{
+	unsigned int idx = shift_to_mmu_psize(__ffs(page_size));
+	int i;
+
+	if (addr == 0)
+		return;
+
+	gpage_freearray[idx].nr_gpages = number_of_pages;
+
+	for (i = 0; i < number_of_pages; i++) {
+		gpage_freearray[idx].gpage_list[i] = addr;
+		addr += page_size;
+	}
+}
+
+/*
+ * Moves the gigantic page addresses from the temporary list to the
+ * huge_boot_pages list.
+ */
+int alloc_bootmem_huge_page(struct hstate *hstate)
+{
+	struct huge_bootmem_page *m;
+	int idx = shift_to_mmu_psize(huge_page_shift(hstate));
+	int nr_gpages = gpage_freearray[idx].nr_gpages;
+
+	if (nr_gpages == 0)
+		return 0;
+
+#ifdef CONFIG_HIGHMEM
+	/*
+	 * If gpages can be in highmem we can't use the trick of storing the
+	 * data structure in the page; allocate space for this
+	 */
+	m = memblock_virt_alloc(sizeof(struct huge_bootmem_page), 0);
+	m->phys = gpage_freearray[idx].gpage_list[--nr_gpages];
+#else
+	m = phys_to_virt(gpage_freearray[idx].gpage_list[--nr_gpages]);
+#endif
+
+	list_add(&m->list, &huge_boot_pages);
+	gpage_freearray[idx].nr_gpages = nr_gpages;
+	gpage_freearray[idx].gpage_list[nr_gpages] = 0;
+	m->hstate = hstate;
+
+	return 1;
+}
+/*
+ * Scan the command line hugepagesz= options for gigantic pages; store those in
+ * a list that we use to allocate the memory once all options are parsed.
+ */
+
+unsigned long gpage_npages[MMU_PAGE_COUNT];
+
+static int __init do_gpage_early_setup(char *param, char *val,
+				       const char *unused, void *arg)
+{
+	static phys_addr_t size;
+	unsigned long npages;
+
+	/*
+	 * The hugepagesz and hugepages cmdline options are interleaved.  We
+	 * use the size variable to keep track of whether or not this was done
+	 * properly and skip over instances where it is incorrect.  Other
+	 * command-line parsing code will issue warnings, so we don't need to.
+	 *
+	 */
+	if ((strcmp(param, "default_hugepagesz") == 0) ||
+	    (strcmp(param, "hugepagesz") == 0)) {
+		size = memparse(val, NULL);
+	} else if (strcmp(param, "hugepages") == 0) {
+		if (size != 0) {
+			if (sscanf(val, "%lu", &npages) <= 0)
+				npages = 0;
+			if (npages > MAX_NUMBER_GPAGES) {
+				pr_warn("MMU: %lu pages requested for page "
+					"size %llu KB, limiting to "
+					__stringify(MAX_NUMBER_GPAGES) "\n",
+					npages, size / 1024);
+				npages = MAX_NUMBER_GPAGES;
+			}
+			gpage_npages[shift_to_mmu_psize(__ffs(size))] = npages;
+			size = 0;
+		}
+	}
+	return 0;
+}
+
+
+/*
+ * This function allocates physical space for pages that are larger than the
+ * buddy allocator can handle.  We want to allocate these in highmem because
+ * the amount of lowmem is limited.  This means that this function MUST be
+ * called before lowmem_end_addr is set up in MMU_init() in order for the lmb
+ * allocate to grab highmem.
+ */
+void __init reserve_hugetlb_gpages(void)
+{
+	static __initdata char cmdline[COMMAND_LINE_SIZE];
+	phys_addr_t size, base;
+	int i;
+
+	strlcpy(cmdline, boot_command_line, COMMAND_LINE_SIZE);
+	parse_args("hugetlb gpages", cmdline, NULL, 0, 0, 0,
+			NULL, &do_gpage_early_setup);
+
+	/*
+	 * Walk gpage list in reverse, allocating larger page sizes first.
+	 * Skip over unsupported sizes, or sizes that have 0 gpages allocated.
+	 * When we reach the point in the list where pages are no longer
+	 * considered gpages, we're done.
+	 */
+	for (i = MMU_PAGE_COUNT-1; i >= 0; i--) {
+		if (mmu_psize_defs[i].shift == 0 || gpage_npages[i] == 0)
+			continue;
+		else if (mmu_psize_to_shift(i) < (MAX_ORDER + PAGE_SHIFT))
+			break;
+
+		size = (phys_addr_t)(1ULL << mmu_psize_to_shift(i));
+		base = memblock_alloc_base(size * gpage_npages[i], size,
+					   MEMBLOCK_ALLOC_ANYWHERE);
+		add_gpage(base, size, gpage_npages[i]);
+	}
+}
+
+#define HUGEPD_FREELIST_SIZE \
+	((PAGE_SIZE - sizeof(struct hugepd_freelist)) / sizeof(pte_t))
+
+struct hugepd_freelist {
+	struct rcu_head	rcu;
+	unsigned int index;
+	void *ptes[0];
+};
+
+static DEFINE_PER_CPU(struct hugepd_freelist *, hugepd_freelist_cur);
+
+static void hugepd_free_rcu_callback(struct rcu_head *head)
+{
+	struct hugepd_freelist *batch =
+		container_of(head, struct hugepd_freelist, rcu);
+	unsigned int i;
+
+	for (i = 0; i < batch->index; i++)
+		kmem_cache_free(hugepte_cache, batch->ptes[i]);
+
+	free_page((unsigned long)batch);
+}
+
+void hugepd_free(struct mmu_gather *tlb, void *hugepte)
+{
+	struct hugepd_freelist **batchp;
+
+	batchp = this_cpu_ptr(&hugepd_freelist_cur);
+
+	if (atomic_read(&tlb->mm->mm_users) < 2 ||
+	    cpumask_equal(mm_cpumask(tlb->mm),
+			  cpumask_of(smp_processor_id()))) {
+		kmem_cache_free(hugepte_cache, hugepte);
+        put_cpu_var(hugepd_freelist_cur);
+		return;
+	}
+
+	if (*batchp == NULL) {
+		*batchp = (struct hugepd_freelist *)__get_free_page(GFP_ATOMIC);
+		(*batchp)->index = 0;
+	}
+
+	(*batchp)->ptes[(*batchp)->index++] = hugepte;
+	if ((*batchp)->index == HUGEPD_FREELIST_SIZE) {
+		call_rcu_sched(&(*batchp)->rcu, hugepd_free_rcu_callback);
+		*batchp = NULL;
+	}
+	put_cpu_var(hugepd_freelist_cur);
+}
+#endif
diff --git a/arch/powerpc/mm/hugetlbpage-hash64.c b/arch/powerpc/mm/hugetlbpage-hash64.c
index 9c224b012d62..9e457c83626b 100644
--- a/arch/powerpc/mm/hugetlbpage-hash64.c
+++ b/arch/powerpc/mm/hugetlbpage-hash64.c
@@ -14,6 +14,17 @@
 #include <asm/cacheflush.h>
 #include <asm/machdep.h>
 
+/*
+ * Tracks gpages after the device tree is scanned and before the
+ * huge_boot_pages list is ready.  On non-Freescale implementations, this is
+ * just used to track 16G pages and so is a single array.  FSL-based
+ * implementations may have more than one gpage size, so we need multiple
+ * arrays
+ */
+#define MAX_NUMBER_GPAGES	1024
+static u64 gpage_freearray[MAX_NUMBER_GPAGES];
+static unsigned nr_gpages;
+
 extern long hpte_insert_repeating(unsigned long hash, unsigned long vpn,
 				  unsigned long pa, unsigned long rlags,
 				  unsigned long vflags, int psize, int ssize);
@@ -132,3 +143,113 @@ int hugepd_ok(hugepd_t hpd)
 	return 0;
 }
 #endif
+
+static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
+			   unsigned long address, unsigned pdshift, unsigned pshift)
+{
+	struct kmem_cache *cachep;
+	pte_t *new;
+
+	cachep = PGT_CACHE(pdshift - pshift);
+
+	new = kmem_cache_zalloc(cachep, GFP_KERNEL|__GFP_REPEAT);
+
+	BUG_ON(pshift > HUGEPD_SHIFT_MASK);
+	BUG_ON((unsigned long)new & HUGEPD_SHIFT_MASK);
+
+	if (! new)
+		return -ENOMEM;
+
+	spin_lock(&mm->page_table_lock);
+	if (!hugepd_none(*hpdp))
+		kmem_cache_free(cachep, new);
+	else {
+		hpdp->pd = (unsigned long)new |
+			    (shift_to_mmu_psize(pshift) << 2);
+	}
+	spin_unlock(&mm->page_table_lock);
+	return 0;
+}
+
+/*
+ * At this point we do the placement change only for BOOK3S 64. This would
+ * possibly work on other subarchs.
+ */
+pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)
+{
+	pgd_t *pg;
+	pud_t *pu;
+	pmd_t *pm;
+	hugepd_t *hpdp = NULL;
+	unsigned pshift = __ffs(sz);
+	unsigned pdshift = PGDIR_SHIFT;
+
+	addr &= ~(sz-1);
+	pg = pgd_offset(mm, addr);
+
+	if (pshift == PGDIR_SHIFT)
+		/* 16GB huge page */
+		return (pte_t *) pg;
+	else if (pshift > PUD_SHIFT)
+		/*
+		 * We need to use hugepd table
+		 */
+		hpdp = (hugepd_t *)pg;
+	else {
+		pdshift = PUD_SHIFT;
+		pu = pud_alloc(mm, pg, addr);
+		if (pshift == PUD_SHIFT)
+			return (pte_t *)pu;
+		else if (pshift > PMD_SHIFT)
+			hpdp = (hugepd_t *)pu;
+		else {
+			pdshift = PMD_SHIFT;
+			pm = pmd_alloc(mm, pu, addr);
+			if (pshift == PMD_SHIFT)
+				/* 16MB hugepage */
+				return (pte_t *)pm;
+			else
+				hpdp = (hugepd_t *)pm;
+		}
+	}
+	if (!hpdp)
+		return NULL;
+
+	BUG_ON(!hugepd_none(*hpdp) && !hugepd_ok(*hpdp));
+
+	if (hugepd_none(*hpdp) && __hugepte_alloc(mm, hpdp, addr, pdshift, pshift))
+		return NULL;
+
+	return hugepte_offset(*hpdp, addr, pdshift);
+}
+
+
+/* Build list of addresses of gigantic pages.  This function is used in early
+ * boot before the buddy allocator is setup.
+ */
+void add_gpage(u64 addr, u64 page_size, unsigned long number_of_pages)
+{
+	if (!addr)
+		return;
+	while (number_of_pages > 0) {
+		gpage_freearray[nr_gpages] = addr;
+		nr_gpages++;
+		number_of_pages--;
+		addr += page_size;
+	}
+}
+
+/* Moves the gigantic page addresses from the temporary list to the
+ * huge_boot_pages list.
+ */
+int alloc_bootmem_huge_page(struct hstate *hstate)
+{
+	struct huge_bootmem_page *m;
+	if (nr_gpages == 0)
+		return 0;
+	m = phys_to_virt(gpage_freearray[--nr_gpages]);
+	gpage_freearray[nr_gpages] = 0;
+	list_add(&m->list, &huge_boot_pages);
+	m->hstate = hstate;
+	return 1;
+}
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 744e24bcb85c..c94502899e94 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -31,413 +31,14 @@
 
 unsigned int HPAGE_SHIFT;
 
-/*
- * Tracks gpages after the device tree is scanned and before the
- * huge_boot_pages list is ready.  On non-Freescale implementations, this is
- * just used to track 16G pages and so is a single array.  FSL-based
- * implementations may have more than one gpage size, so we need multiple
- * arrays
- */
-#ifdef CONFIG_PPC_FSL_BOOK3E
-#define MAX_NUMBER_GPAGES	128
-struct psize_gpages {
-	u64 gpage_list[MAX_NUMBER_GPAGES];
-	unsigned int nr_gpages;
-};
-static struct psize_gpages gpage_freearray[MMU_PAGE_COUNT];
-#else
-#define MAX_NUMBER_GPAGES	1024
-static u64 gpage_freearray[MAX_NUMBER_GPAGES];
-static unsigned nr_gpages;
-#endif
-
-#define hugepd_none(hpd)	((hpd).pd == 0)
-
 pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 {
 	/* Only called for hugetlbfs pages, hence can ignore THP */
 	return __find_linux_pte_or_hugepte(mm->pgd, addr, NULL, NULL);
 }
 
-static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
-			   unsigned long address, unsigned pdshift, unsigned pshift)
-{
-	struct kmem_cache *cachep;
-	pte_t *new;
-
-#ifdef CONFIG_PPC_FSL_BOOK3E
-	int i;
-	int num_hugepd = 1 << (pshift - pdshift);
-	cachep = hugepte_cache;
-#else
-	cachep = PGT_CACHE(pdshift - pshift);
-#endif
-
-	new = kmem_cache_zalloc(cachep, GFP_KERNEL|__GFP_REPEAT);
-
-	BUG_ON(pshift > HUGEPD_SHIFT_MASK);
-	BUG_ON((unsigned long)new & HUGEPD_SHIFT_MASK);
-
-	if (! new)
-		return -ENOMEM;
-
-	spin_lock(&mm->page_table_lock);
-#ifdef CONFIG_PPC_FSL_BOOK3E
-	/*
-	 * We have multiple higher-level entries that point to the same
-	 * actual pte location.  Fill in each as we go and backtrack on error.
-	 * We need all of these so the DTLB pgtable walk code can find the
-	 * right higher-level entry without knowing if it's a hugepage or not.
-	 */
-	for (i = 0; i < num_hugepd; i++, hpdp++) {
-		if (unlikely(!hugepd_none(*hpdp)))
-			break;
-		else
-			/* We use the old format for PPC_FSL_BOOK3E */
-			hpdp->pd = ((unsigned long)new & ~PD_HUGE) | pshift;
-	}
-	/* If we bailed from the for loop early, an error occurred, clean up */
-	if (i < num_hugepd) {
-		for (i = i - 1 ; i >= 0; i--, hpdp--)
-			hpdp->pd = 0;
-		kmem_cache_free(cachep, new);
-	}
-#else
-	if (!hugepd_none(*hpdp))
-		kmem_cache_free(cachep, new);
-	else {
-#ifdef CONFIG_PPC_BOOK3S_64
-		hpdp->pd = (unsigned long)new |
-			    (shift_to_mmu_psize(pshift) << 2);
-#else
-		hpdp->pd = ((unsigned long)new & ~PD_HUGE) | pshift;
-#endif
-	}
-#endif
-	spin_unlock(&mm->page_table_lock);
-	return 0;
-}
-
-/*
- * These macros define how to determine which level of the page table holds
- * the hpdp.
- */
-#ifdef CONFIG_PPC_FSL_BOOK3E
-#define HUGEPD_PGD_SHIFT PGDIR_SHIFT
-#define HUGEPD_PUD_SHIFT PUD_SHIFT
-#else
-#define HUGEPD_PGD_SHIFT PUD_SHIFT
-#define HUGEPD_PUD_SHIFT PMD_SHIFT
-#endif
-
-#ifdef CONFIG_PPC_BOOK3S_64
-/*
- * At this point we do the placement change only for BOOK3S 64. This would
- * possibly work on other subarchs.
- */
-pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)
-{
-	pgd_t *pg;
-	pud_t *pu;
-	pmd_t *pm;
-	hugepd_t *hpdp = NULL;
-	unsigned pshift = __ffs(sz);
-	unsigned pdshift = PGDIR_SHIFT;
-
-	addr &= ~(sz-1);
-	pg = pgd_offset(mm, addr);
-
-	if (pshift == PGDIR_SHIFT)
-		/* 16GB huge page */
-		return (pte_t *) pg;
-	else if (pshift > PUD_SHIFT)
-		/*
-		 * We need to use hugepd table
-		 */
-		hpdp = (hugepd_t *)pg;
-	else {
-		pdshift = PUD_SHIFT;
-		pu = pud_alloc(mm, pg, addr);
-		if (pshift == PUD_SHIFT)
-			return (pte_t *)pu;
-		else if (pshift > PMD_SHIFT)
-			hpdp = (hugepd_t *)pu;
-		else {
-			pdshift = PMD_SHIFT;
-			pm = pmd_alloc(mm, pu, addr);
-			if (pshift == PMD_SHIFT)
-				/* 16MB hugepage */
-				return (pte_t *)pm;
-			else
-				hpdp = (hugepd_t *)pm;
-		}
-	}
-	if (!hpdp)
-		return NULL;
-
-	BUG_ON(!hugepd_none(*hpdp) && !hugepd_ok(*hpdp));
-
-	if (hugepd_none(*hpdp) && __hugepte_alloc(mm, hpdp, addr, pdshift, pshift))
-		return NULL;
-
-	return hugepte_offset(*hpdp, addr, pdshift);
-}
-
-#else
-
-pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)
-{
-	pgd_t *pg;
-	pud_t *pu;
-	pmd_t *pm;
-	hugepd_t *hpdp = NULL;
-	unsigned pshift = __ffs(sz);
-	unsigned pdshift = PGDIR_SHIFT;
-
-	addr &= ~(sz-1);
-
-	pg = pgd_offset(mm, addr);
-
-	if (pshift >= HUGEPD_PGD_SHIFT) {
-		hpdp = (hugepd_t *)pg;
-	} else {
-		pdshift = PUD_SHIFT;
-		pu = pud_alloc(mm, pg, addr);
-		if (pshift >= HUGEPD_PUD_SHIFT) {
-			hpdp = (hugepd_t *)pu;
-		} else {
-			pdshift = PMD_SHIFT;
-			pm = pmd_alloc(mm, pu, addr);
-			hpdp = (hugepd_t *)pm;
-		}
-	}
-
-	if (!hpdp)
-		return NULL;
-
-	BUG_ON(!hugepd_none(*hpdp) && !hugepd_ok(*hpdp));
-
-	if (hugepd_none(*hpdp) && __hugepte_alloc(mm, hpdp, addr, pdshift, pshift))
-		return NULL;
-
-	return hugepte_offset(*hpdp, addr, pdshift);
-}
-#endif
-
-#ifdef CONFIG_PPC_FSL_BOOK3E
-/* Build list of addresses of gigantic pages.  This function is used in early
- * boot before the buddy allocator is setup.
- */
-void add_gpage(u64 addr, u64 page_size, unsigned long number_of_pages)
-{
-	unsigned int idx = shift_to_mmu_psize(__ffs(page_size));
-	int i;
-
-	if (addr == 0)
-		return;
-
-	gpage_freearray[idx].nr_gpages = number_of_pages;
-
-	for (i = 0; i < number_of_pages; i++) {
-		gpage_freearray[idx].gpage_list[i] = addr;
-		addr += page_size;
-	}
-}
-
-/*
- * Moves the gigantic page addresses from the temporary list to the
- * huge_boot_pages list.
- */
-int alloc_bootmem_huge_page(struct hstate *hstate)
-{
-	struct huge_bootmem_page *m;
-	int idx = shift_to_mmu_psize(huge_page_shift(hstate));
-	int nr_gpages = gpage_freearray[idx].nr_gpages;
-
-	if (nr_gpages == 0)
-		return 0;
-
-#ifdef CONFIG_HIGHMEM
-	/*
-	 * If gpages can be in highmem we can't use the trick of storing the
-	 * data structure in the page; allocate space for this
-	 */
-	m = memblock_virt_alloc(sizeof(struct huge_bootmem_page), 0);
-	m->phys = gpage_freearray[idx].gpage_list[--nr_gpages];
-#else
-	m = phys_to_virt(gpage_freearray[idx].gpage_list[--nr_gpages]);
-#endif
-
-	list_add(&m->list, &huge_boot_pages);
-	gpage_freearray[idx].nr_gpages = nr_gpages;
-	gpage_freearray[idx].gpage_list[nr_gpages] = 0;
-	m->hstate = hstate;
-
-	return 1;
-}
-/*
- * Scan the command line hugepagesz= options for gigantic pages; store those in
- * a list that we use to allocate the memory once all options are parsed.
- */
-
-unsigned long gpage_npages[MMU_PAGE_COUNT];
-
-static int __init do_gpage_early_setup(char *param, char *val,
-				       const char *unused, void *arg)
-{
-	static phys_addr_t size;
-	unsigned long npages;
-
-	/*
-	 * The hugepagesz and hugepages cmdline options are interleaved.  We
-	 * use the size variable to keep track of whether or not this was done
-	 * properly and skip over instances where it is incorrect.  Other
-	 * command-line parsing code will issue warnings, so we don't need to.
-	 *
-	 */
-	if ((strcmp(param, "default_hugepagesz") == 0) ||
-	    (strcmp(param, "hugepagesz") == 0)) {
-		size = memparse(val, NULL);
-	} else if (strcmp(param, "hugepages") == 0) {
-		if (size != 0) {
-			if (sscanf(val, "%lu", &npages) <= 0)
-				npages = 0;
-			if (npages > MAX_NUMBER_GPAGES) {
-				pr_warn("MMU: %lu pages requested for page "
-					"size %llu KB, limiting to "
-					__stringify(MAX_NUMBER_GPAGES) "\n",
-					npages, size / 1024);
-				npages = MAX_NUMBER_GPAGES;
-			}
-			gpage_npages[shift_to_mmu_psize(__ffs(size))] = npages;
-			size = 0;
-		}
-	}
-	return 0;
-}
-
-
-/*
- * This function allocates physical space for pages that are larger than the
- * buddy allocator can handle.  We want to allocate these in highmem because
- * the amount of lowmem is limited.  This means that this function MUST be
- * called before lowmem_end_addr is set up in MMU_init() in order for the lmb
- * allocate to grab highmem.
- */
-void __init reserve_hugetlb_gpages(void)
-{
-	static __initdata char cmdline[COMMAND_LINE_SIZE];
-	phys_addr_t size, base;
-	int i;
-
-	strlcpy(cmdline, boot_command_line, COMMAND_LINE_SIZE);
-	parse_args("hugetlb gpages", cmdline, NULL, 0, 0, 0,
-			NULL, &do_gpage_early_setup);
-
-	/*
-	 * Walk gpage list in reverse, allocating larger page sizes first.
-	 * Skip over unsupported sizes, or sizes that have 0 gpages allocated.
-	 * When we reach the point in the list where pages are no longer
-	 * considered gpages, we're done.
-	 */
-	for (i = MMU_PAGE_COUNT-1; i >= 0; i--) {
-		if (mmu_psize_defs[i].shift == 0 || gpage_npages[i] == 0)
-			continue;
-		else if (mmu_psize_to_shift(i) < (MAX_ORDER + PAGE_SHIFT))
-			break;
-
-		size = (phys_addr_t)(1ULL << mmu_psize_to_shift(i));
-		base = memblock_alloc_base(size * gpage_npages[i], size,
-					   MEMBLOCK_ALLOC_ANYWHERE);
-		add_gpage(base, size, gpage_npages[i]);
-	}
-}
-
-#else /* !PPC_FSL_BOOK3E */
-
-/* Build list of addresses of gigantic pages.  This function is used in early
- * boot before the buddy allocator is setup.
- */
-void add_gpage(u64 addr, u64 page_size, unsigned long number_of_pages)
-{
-	if (!addr)
-		return;
-	while (number_of_pages > 0) {
-		gpage_freearray[nr_gpages] = addr;
-		nr_gpages++;
-		number_of_pages--;
-		addr += page_size;
-	}
-}
-
-/* Moves the gigantic page addresses from the temporary list to the
- * huge_boot_pages list.
- */
-int alloc_bootmem_huge_page(struct hstate *hstate)
-{
-	struct huge_bootmem_page *m;
-	if (nr_gpages == 0)
-		return 0;
-	m = phys_to_virt(gpage_freearray[--nr_gpages]);
-	gpage_freearray[nr_gpages] = 0;
-	list_add(&m->list, &huge_boot_pages);
-	m->hstate = hstate;
-	return 1;
-}
-#endif
-
-#ifdef CONFIG_PPC_FSL_BOOK3E
-#define HUGEPD_FREELIST_SIZE \
-	((PAGE_SIZE - sizeof(struct hugepd_freelist)) / sizeof(pte_t))
-
-struct hugepd_freelist {
-	struct rcu_head	rcu;
-	unsigned int index;
-	void *ptes[0];
-};
-
-static DEFINE_PER_CPU(struct hugepd_freelist *, hugepd_freelist_cur);
-
-static void hugepd_free_rcu_callback(struct rcu_head *head)
-{
-	struct hugepd_freelist *batch =
-		container_of(head, struct hugepd_freelist, rcu);
-	unsigned int i;
-
-	for (i = 0; i < batch->index; i++)
-		kmem_cache_free(hugepte_cache, batch->ptes[i]);
-
-	free_page((unsigned long)batch);
-}
-
-static void hugepd_free(struct mmu_gather *tlb, void *hugepte)
-{
-	struct hugepd_freelist **batchp;
-
-	batchp = this_cpu_ptr(&hugepd_freelist_cur);
-
-	if (atomic_read(&tlb->mm->mm_users) < 2 ||
-	    cpumask_equal(mm_cpumask(tlb->mm),
-			  cpumask_of(smp_processor_id()))) {
-		kmem_cache_free(hugepte_cache, hugepte);
-        put_cpu_var(hugepd_freelist_cur);
-		return;
-	}
-
-	if (*batchp == NULL) {
-		*batchp = (struct hugepd_freelist *)__get_free_page(GFP_ATOMIC);
-		(*batchp)->index = 0;
-	}
-
-	(*batchp)->ptes[(*batchp)->index++] = hugepte;
-	if ((*batchp)->index == HUGEPD_FREELIST_SIZE) {
-		call_rcu_sched(&(*batchp)->rcu, hugepd_free_rcu_callback);
-		*batchp = NULL;
-	}
-	put_cpu_var(hugepd_freelist_cur);
-}
-#endif
 
+extern void hugepd_free(struct mmu_gather *tlb, void *hugepte);
 static void free_hugepd_range(struct mmu_gather *tlb, hugepd_t *hpdp, int pdshift,
 			      unsigned long start, unsigned long end,
 			      unsigned long floor, unsigned long ceiling)
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
