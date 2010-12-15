Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D79406B008A
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 21:46:22 -0500 (EST)
From: "Ricardo M. Correia" <ricardo.correia@oracle.com>
Subject: [PATCH] Fix unconditional GFP_KERNEL allocations in __vmalloc().
Date: Wed, 15 Dec 2010 03:45:26 +0100
Message-Id: <1292381126-5710-1-git-send-email-ricardo.correia@oracle.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-arch@vger.kernel.org, ricardo.correia@oracle.com, andreas.dilger@oracle.com, behlendorf1@llnl.gov
List-ID: <linux-mm.kvack.org>

(Patch based on 2.6.36 tag).

These GFP_KERNEL allocations could happen even though the caller of __vmalloc()
requested a stricter gfp mask (such as GFP_NOFS or GFP_ATOMIC).

This was first noticed in Lustre, where it led to deadlocks due to a filesystem
thread which requested a GFP_NOFS __vmalloc() allocation ended up calling down
to Lustre itself to free memory, despite this not being allowed by GFP_NOFS.

Further analysis showed that some in-tree filesystems (namely GFS, Ceph and XFS)
were vulnerable to the same bug due to calling __vmalloc() or vm_map_ram() in
contexts where __GFP_FS allocations are not allowed.

Fixing this bug required changing a few mm interfaces to accept gfp flags.
This needed to be done in all architectures, thus the large number of changes.
---
 arch/alpha/include/asm/pgalloc.h         |   10 +++---
 arch/arm/include/asm/pgalloc.h           |   12 +++---
 arch/avr32/include/asm/pgalloc.h         |    4 +-
 arch/cris/include/asm/pgalloc.h          |    7 ++--
 arch/frv/include/asm/pgalloc.h           |    4 +-
 arch/frv/include/asm/pgtable.h           |    2 +-
 arch/frv/mm/pgalloc.c                    |    5 ++-
 arch/ia64/include/asm/pgalloc.h          |   14 ++++---
 arch/m32r/include/asm/pgalloc.h          |    6 ++--
 arch/m68k/include/asm/motorola_pgalloc.h |   14 ++++---
 arch/m68k/include/asm/sun3_pgalloc.h     |    6 ++--
 arch/m68k/mm/memory.c                    |    4 +-
 arch/microblaze/include/asm/pgalloc.h    |    7 ++--
 arch/microblaze/mm/pgtable.c             |    4 +-
 arch/mips/include/asm/pgalloc.h          |    9 +++--
 arch/mn10300/include/asm/pgalloc.h       |    2 +-
 arch/mn10300/mm/pgtable.c                |    5 ++-
 arch/parisc/include/asm/pgalloc.h        |   11 +++---
 arch/powerpc/include/asm/pgalloc-32.h    |    3 +-
 arch/powerpc/include/asm/pgalloc-64.h    |   16 +++++----
 arch/powerpc/mm/pgtable_32.c             |    5 ++-
 arch/s390/include/asm/pgalloc.h          |   28 +++++++++-------
 arch/s390/mm/pgtable.c                   |   12 +++---
 arch/s390/mm/vmem.c                      |    2 +-
 arch/score/include/asm/pgalloc.h         |    4 +-
 arch/sh/include/asm/pgalloc.h            |    7 ++--
 arch/sh/mm/pgtable.c                     |    8 ++--
 arch/sparc/include/asm/pgalloc_32.h      |    9 +++--
 arch/sparc/include/asm/pgalloc_64.h      |    9 +++--
 arch/sparc/mm/srmmu.c                    |    9 +++--
 arch/sparc/mm/sun4c.c                    |   10 +++--
 arch/tile/include/asm/pgalloc.h          |   14 +++++---
 arch/tile/kernel/module.c                |    2 +-
 arch/tile/mm/pgtable.c                   |    7 ++--
 arch/um/include/asm/pgalloc.h            |    2 +-
 arch/um/include/asm/pgtable-3level.h     |    3 +-
 arch/um/kernel/mem.c                     |   10 +++--
 arch/x86/include/asm/pgalloc.h           |   12 ++++---
 arch/x86/mm/pgtable.c                    |   13 ++++---
 arch/xtensa/include/asm/pgalloc.h        |    8 ++--
 arch/xtensa/mm/pgtable.c                 |    5 ++-
 drivers/lguest/core.c                    |    2 +-
 fs/xfs/linux-2.6/xfs_buf.c               |    2 +-
 include/asm-generic/4level-fixup.h       |    9 +++--
 include/asm-generic/pgtable-nopmd.h      |    2 +-
 include/asm-generic/pgtable-nopud.h      |    2 +-
 include/linux/mm.h                       |   52 ++++++++++++++++++++++-------
 include/linux/vmalloc.h                  |    8 ++--
 mm/memory.c                              |   14 ++++---
 mm/nommu.c                               |    3 +-
 mm/vmalloc.c                             |   53 ++++++++++++++++-------------
 51 files changed, 274 insertions(+), 197 deletions(-)

diff --git a/arch/alpha/include/asm/pgalloc.h b/arch/alpha/include/asm/pgalloc.h
index bc2a0da..3fb3a51 100644
--- a/arch/alpha/include/asm/pgalloc.h
+++ b/arch/alpha/include/asm/pgalloc.h
@@ -38,9 +38,9 @@ pgd_free(struct mm_struct *mm, pgd_t *pgd)
 }
 
 static inline pmd_t *
-pmd_alloc_one(struct mm_struct *mm, unsigned long address)
+pmd_alloc_one(struct mm_struct *mm, unsigned long address, gfp_t gfp_mask)
 {
-	pmd_t *ret = (pmd_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+	pmd_t *ret = (pmd_t *)__get_free_page(gfp_mask|__GFP_REPEAT|__GFP_ZERO);
 	return ret;
 }
 
@@ -51,9 +51,9 @@ pmd_free(struct mm_struct *mm, pmd_t *pmd)
 }
 
 static inline pte_t *
-pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address, gfp_t gfp_mask)
 {
-	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+	pte_t *pte = (pte_t *)__get_free_page(gfp_mask|__GFP_REPEAT|__GFP_ZERO);
 	return pte;
 }
 
@@ -66,7 +66,7 @@ pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 static inline pgtable_t
 pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
-	pte_t *pte = pte_alloc_one_kernel(mm, address);
+	pte_t *pte = pte_alloc_one_kernel(mm, address, GFP_KERNEL);
 	struct page *page;
 
 	if (!pte)
diff --git a/arch/arm/include/asm/pgalloc.h b/arch/arm/include/asm/pgalloc.h
index b12cc98..89c5711 100644
--- a/arch/arm/include/asm/pgalloc.h
+++ b/arch/arm/include/asm/pgalloc.h
@@ -26,7 +26,7 @@
 /*
  * Since we have only two-level page tables, these are trivial
  */
-#define pmd_alloc_one(mm,addr)		({ BUG(); ((pmd_t *)2); })
+#define pmd_alloc_one(mm,addr,gfp)	({ BUG(); ((pmd_t *)2); })
 #define pmd_free(mm, pmd)		do { } while (0)
 #define pgd_populate(mm,pmd,pte)	BUG()
 
@@ -36,7 +36,7 @@ extern void free_pgd_slow(struct mm_struct *mm, pgd_t *pgd);
 #define pgd_alloc(mm)			get_pgd_slow(mm)
 #define pgd_free(mm, pgd)		free_pgd_slow(mm, pgd)
 
-#define PGALLOC_GFP	(GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO)
+#define PGALLOC_GFP	(__GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO)
 
 /*
  * Allocate one PTE table.
@@ -55,11 +55,11 @@ extern void free_pgd_slow(struct mm_struct *mm, pgd_t *pgd);
  *  +------------+
  */
 static inline pte_t *
-pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr)
+pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr, gfp_t gfp_mask)
 {
 	pte_t *pte;
 
-	pte = (pte_t *)__get_free_page(PGALLOC_GFP);
+	pte = (pte_t *)__get_free_page(gfp_mask | PGALLOC_GFP);
 	if (pte) {
 		clean_dcache_area(pte, sizeof(pte_t) * PTRS_PER_PTE);
 		pte += PTRS_PER_PTE;
@@ -74,9 +74,9 @@ pte_alloc_one(struct mm_struct *mm, unsigned long addr)
 	struct page *pte;
 
 #ifdef CONFIG_HIGHPTE
-	pte = alloc_pages(PGALLOC_GFP | __GFP_HIGHMEM, 0);
+	pte = alloc_pages(GFP_KERNEL | PGALLOC_GFP | __GFP_HIGHMEM, 0);
 #else
-	pte = alloc_pages(PGALLOC_GFP, 0);
+	pte = alloc_pages(GFP_KERNEL | PGALLOC_GFP, 0);
 #endif
 	if (pte) {
 		if (!PageHighMem(pte)) {
diff --git a/arch/avr32/include/asm/pgalloc.h b/arch/avr32/include/asm/pgalloc.h
index 92ecd84..fde4a21 100644
--- a/arch/avr32/include/asm/pgalloc.h
+++ b/arch/avr32/include/asm/pgalloc.h
@@ -51,9 +51,9 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 }
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-					  unsigned long address)
+					  unsigned long address, gfp_t gfp_mask)
 {
-	return quicklist_alloc(QUICK_PT, GFP_KERNEL | __GFP_REPEAT, NULL);
+	return quicklist_alloc(QUICK_PT, gfp_mask | __GFP_REPEAT, NULL);
 }
 
 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
diff --git a/arch/cris/include/asm/pgalloc.h b/arch/cris/include/asm/pgalloc.h
index 6da975d..cf2a363 100644
--- a/arch/cris/include/asm/pgalloc.h
+++ b/arch/cris/include/asm/pgalloc.h
@@ -22,10 +22,11 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 	free_page((unsigned long)pgd);
 }
 
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
+					unsigned long address, gfp_t gfp_mask)
 {
-  	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
- 	return pte;
+	pte_t *pte = (pte_t *)__get_free_page(gfp_mask|__GFP_REPEAT|__GFP_ZERO);
+	return pte;
 }
 
 static inline pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
diff --git a/arch/frv/include/asm/pgalloc.h b/arch/frv/include/asm/pgalloc.h
index 416d19a..77e9299 100644
--- a/arch/frv/include/asm/pgalloc.h
+++ b/arch/frv/include/asm/pgalloc.h
@@ -34,7 +34,7 @@ do {										\
 extern pgd_t *pgd_alloc(struct mm_struct *);
 extern void pgd_free(struct mm_struct *mm, pgd_t *);
 
-extern pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long);
+extern pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long, gfp_t);
 
 extern pgtable_t pte_alloc_one(struct mm_struct *, unsigned long);
 
@@ -60,7 +60,7 @@ do {							\
  * inside the pgd, so has no extra memory associated with it.
  * (In the PAE case we free the pmds as part of the pgd.)
  */
-#define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *) 2); })
+#define pmd_alloc_one(mm, addr, gfp)	({ BUG(); ((pmd_t *) 2); })
 #define pmd_free(mm, x)			do { } while (0)
 #define __pmd_free_tlb(tlb,x,a)		do { } while (0)
 
diff --git a/arch/frv/include/asm/pgtable.h b/arch/frv/include/asm/pgtable.h
index c18b0d3..49a1df8 100644
--- a/arch/frv/include/asm/pgtable.h
+++ b/arch/frv/include/asm/pgtable.h
@@ -223,7 +223,7 @@ static inline pud_t *pud_offset(pgd_t *pgd, unsigned long address)
  * allocating and freeing a pud is trivial: the 1-entry pud is
  * inside the pgd, so has no extra memory associated with it.
  */
-#define pud_alloc_one(mm, address)		NULL
+#define pud_alloc_one(mm, address, gfp)		NULL
 #define pud_free(mm, x)				do { } while (0)
 #define __pud_free_tlb(tlb, x, address)		do { } while (0)
 
diff --git a/arch/frv/mm/pgalloc.c b/arch/frv/mm/pgalloc.c
index c42c83d..b024059 100644
--- a/arch/frv/mm/pgalloc.c
+++ b/arch/frv/mm/pgalloc.c
@@ -20,9 +20,10 @@
 
 pgd_t swapper_pg_dir[PTRS_PER_PGD] __attribute__((aligned(PAGE_SIZE)));
 
-pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
+								gfp_t gfp_mask)
 {
-	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
+	pte_t *pte = (pte_t *)__get_free_page(gfp_mask|__GFP_REPEAT);
 	if (pte)
 		clear_page(pte);
 	return pte;
diff --git a/arch/ia64/include/asm/pgalloc.h b/arch/ia64/include/asm/pgalloc.h
index 96a8d92..efd4b44 100644
--- a/arch/ia64/include/asm/pgalloc.h
+++ b/arch/ia64/include/asm/pgalloc.h
@@ -39,9 +39,10 @@ pgd_populate(struct mm_struct *mm, pgd_t * pgd_entry, pud_t * pud)
 	pgd_val(*pgd_entry) = __pa(pud);
 }
 
-static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
+static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr,
+								gfp_t gfp_mask)
 {
-	return quicklist_alloc(0, GFP_KERNEL, NULL);
+	return quicklist_alloc(0, gfp_mask, NULL);
 }
 
 static inline void pud_free(struct mm_struct *mm, pud_t *pud)
@@ -57,9 +58,10 @@ pud_populate(struct mm_struct *mm, pud_t * pud_entry, pmd_t * pmd)
 	pud_val(*pud_entry) = __pa(pmd);
 }
 
-static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
+static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr,
+								gfp_t gfp_mask)
 {
-	return quicklist_alloc(0, GFP_KERNEL, NULL);
+	return quicklist_alloc(0, gfp_mask, NULL);
 }
 
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
@@ -96,9 +98,9 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long addr)
 }
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-					  unsigned long addr)
+					  unsigned long addr, gfp_t gfp_mask)
 {
-	return quicklist_alloc(0, GFP_KERNEL, NULL);
+	return quicklist_alloc(0, gfp_mask, NULL);
 }
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
diff --git a/arch/m32r/include/asm/pgalloc.h b/arch/m32r/include/asm/pgalloc.h
index 0fc7361..17cc97e 100644
--- a/arch/m32r/include/asm/pgalloc.h
+++ b/arch/m32r/include/asm/pgalloc.h
@@ -31,9 +31,9 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 }
 
 static __inline__ pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-	unsigned long address)
+					unsigned long address, gfp_t gfp_mask)
 {
-	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
+	pte_t *pte = (pte_t *)__get_free_page(gfp_mask|__GFP_ZERO);
 
 	return pte;
 }
@@ -66,7 +66,7 @@ static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
  * (In the PAE case we free the pmds as part of the pgd.)
  */
 
-#define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *)2); })
+#define pmd_alloc_one(mm, addr, gfp)	({ BUG(); ((pmd_t *)2); })
 #define pmd_free(mm, x)			do { } while (0)
 #define __pmd_free_tlb(tlb, x, addr)	do { } while (0)
 #define pgd_populate(mm, pmd, pte)	BUG()
diff --git a/arch/m68k/include/asm/motorola_pgalloc.h b/arch/m68k/include/asm/motorola_pgalloc.h
index 2f02f26..e9507b5 100644
--- a/arch/m68k/include/asm/motorola_pgalloc.h
+++ b/arch/m68k/include/asm/motorola_pgalloc.h
@@ -4,14 +4,15 @@
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
 
-extern pmd_t *get_pointer_table(void);
+extern pmd_t *get_pointer_table(gfp_t);
 extern int free_pointer_table(pmd_t *);
 
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
+					unsigned long address, gfp_t gfp_mask)
 {
 	pte_t *pte;
 
-	pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+	pte = (pte_t *)__get_free_page(gfp_mask|__GFP_REPEAT|__GFP_ZERO);
 	if (pte) {
 		__flush_page_to_ram(pte);
 		flush_tlb_kernel_page(pte);
@@ -62,9 +63,10 @@ static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t page,
 }
 
 
-static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
+static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address,
+								gfp_t gfp_mask)
 {
-	return get_pointer_table();
+	return get_pointer_table(gfp_mask);
 }
 
 static inline int pmd_free(struct mm_struct *mm, pmd_t *pmd)
@@ -86,7 +88,7 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 
 static inline pgd_t *pgd_alloc(struct mm_struct *mm)
 {
-	return (pgd_t *)get_pointer_table();
+	return (pgd_t *)get_pointer_table(GFP_KERNEL);
 }
 
 
diff --git a/arch/m68k/include/asm/sun3_pgalloc.h b/arch/m68k/include/asm/sun3_pgalloc.h
index 48d80d5..ac41f20 100644
--- a/arch/m68k/include/asm/sun3_pgalloc.h
+++ b/arch/m68k/include/asm/sun3_pgalloc.h
@@ -18,7 +18,7 @@
 
 extern const char bad_pmd_string[];
 
-#define pmd_alloc_one(mm,address)       ({ BUG(); ((pmd_t *)2); })
+#define pmd_alloc_one(mm,address,gfp)   ({ BUG(); ((pmd_t *)2); })
 
 
 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
@@ -39,9 +39,9 @@ do {							\
 } while (0)
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-					  unsigned long address)
+					  unsigned long address, gfp_t gfp_mask)
 {
-	unsigned long page = __get_free_page(GFP_KERNEL|__GFP_REPEAT);
+	unsigned long page = __get_free_page(gfp_mask|__GFP_REPEAT);
 
 	if (!page)
 		return NULL;
diff --git a/arch/m68k/mm/memory.c b/arch/m68k/mm/memory.c
index 34c77ce..7822291 100644
--- a/arch/m68k/mm/memory.c
+++ b/arch/m68k/mm/memory.c
@@ -59,7 +59,7 @@ void __init init_pointer_table(unsigned long ptable)
 	return;
 }
 
-pmd_t *get_pointer_table (void)
+pmd_t *get_pointer_table (gfp_t gfp_mask)
 {
 	ptable_desc *dp = ptable_list.next;
 	unsigned char mask = PD_MARKBITS (dp);
@@ -76,7 +76,7 @@ pmd_t *get_pointer_table (void)
 		void *page;
 		ptable_desc *new;
 
-		if (!(page = (void *)get_zeroed_page(GFP_KERNEL)))
+		if (!(page = (void *)get_zeroed_page(gfp_mask)))
 			return NULL;
 
 		flush_tlb_kernel_page(page);
diff --git a/arch/microblaze/include/asm/pgalloc.h b/arch/microblaze/include/asm/pgalloc.h
index c614a89..e5e9d9f 100644
--- a/arch/microblaze/include/asm/pgalloc.h
+++ b/arch/microblaze/include/asm/pgalloc.h
@@ -106,9 +106,10 @@ extern inline void free_pgd_slow(pgd_t *pgd)
  * the pgd will always be present..
  */
 #define pmd_alloc_one_fast(mm, address)	({ BUG(); ((pmd_t *)1); })
-#define pmd_alloc_one(mm, address)	({ BUG(); ((pmd_t *)2); })
+#define pmd_alloc_one(mm, address, gfp)	({ BUG(); ((pmd_t *)2); })
 
-extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr);
+extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr,
+								gfp_t gfp_mask);
 
 static inline struct page *pte_alloc_one(struct mm_struct *mm,
 		unsigned long address)
@@ -174,7 +175,7 @@ extern inline void pte_free(struct mm_struct *mm, struct page *ptepage)
  * We don't have any real pmd's, and this code never triggers because
  * the pgd will always be present..
  */
-#define pmd_alloc_one(mm, address)	({ BUG(); ((pmd_t *)2); })
+#define pmd_alloc_one(mm, address, gfp)	({ BUG(); ((pmd_t *)2); })
 #define pmd_free(mm, x)			do { } while (0)
 #define __pmd_free_tlb(tlb, x, addr)	pmd_free((tlb)->mm, x)
 #define pgd_populate(mm, pmd, pte)	BUG()
diff --git a/arch/microblaze/mm/pgtable.c b/arch/microblaze/mm/pgtable.c
index 59bf233..a85bac3 100644
--- a/arch/microblaze/mm/pgtable.c
+++ b/arch/microblaze/mm/pgtable.c
@@ -241,11 +241,11 @@ unsigned long iopa(unsigned long addr)
 }
 
 __init_refok pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-		unsigned long address)
+					unsigned long address, gfp_t gfp_mask)
 {
 	pte_t *pte;
 	if (mem_init_done) {
-		pte = (pte_t *)__get_free_page(GFP_KERNEL |
+		pte = (pte_t *)__get_free_page(gfp_mask |
 					__GFP_REPEAT | __GFP_ZERO);
 	} else {
 		pte = (pte_t *)early_get_page();
diff --git a/arch/mips/include/asm/pgalloc.h b/arch/mips/include/asm/pgalloc.h
index 881d18b..ebdc607 100644
--- a/arch/mips/include/asm/pgalloc.h
+++ b/arch/mips/include/asm/pgalloc.h
@@ -65,11 +65,11 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 }
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-	unsigned long address)
+					unsigned long address, gfp_t gfp_mask)
 {
 	pte_t *pte;
 
-	pte = (pte_t *) __get_free_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, PTE_ORDER);
+	pte = (pte_t *) __get_free_pages(gfp_mask|__GFP_REPEAT|__GFP_ZERO, PTE_ORDER);
 
 	return pte;
 }
@@ -106,11 +106,12 @@ do {							\
 
 #ifndef __PAGETABLE_PMD_FOLDED
 
-static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
+static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address,
+								gfp_t gfp_mask)
 {
 	pmd_t *pmd;
 
-	pmd = (pmd_t *) __get_free_pages(GFP_KERNEL|__GFP_REPEAT, PMD_ORDER);
+	pmd = (pmd_t *) __get_free_pages(gfp_mask|__GFP_REPEAT, PMD_ORDER);
 	if (pmd)
 		pmd_init((unsigned long)pmd, (unsigned long)invalid_pte_table);
 	return pmd;
diff --git a/arch/mn10300/include/asm/pgalloc.h b/arch/mn10300/include/asm/pgalloc.h
index a19f113..c434fb2 100644
--- a/arch/mn10300/include/asm/pgalloc.h
+++ b/arch/mn10300/include/asm/pgalloc.h
@@ -37,7 +37,7 @@ void pmd_populate(struct mm_struct *mm, pmd_t *pmd, struct page *pte)
 extern pgd_t *pgd_alloc(struct mm_struct *);
 extern void pgd_free(struct mm_struct *, pgd_t *);
 
-extern pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long);
+extern pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long, gfp_t);
 extern struct page *pte_alloc_one(struct mm_struct *, unsigned long);
 
 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
diff --git a/arch/mn10300/mm/pgtable.c b/arch/mn10300/mm/pgtable.c
index 9c1624c..f8498b8 100644
--- a/arch/mn10300/mm/pgtable.c
+++ b/arch/mn10300/mm/pgtable.c
@@ -62,9 +62,10 @@ void set_pmd_pfn(unsigned long vaddr, unsigned long pfn, pgprot_t flags)
 	__flush_tlb_one(vaddr);
 }
 
-pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
+								gfp_t gfp_mask)
 {
-	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
+	pte_t *pte = (pte_t *)__get_free_page(gfp_mask|__GFP_REPEAT);
 	if (pte)
 		clear_page(pte);
 	return pte;
diff --git a/arch/parisc/include/asm/pgalloc.h b/arch/parisc/include/asm/pgalloc.h
index fc987a1..1865e9f 100644
--- a/arch/parisc/include/asm/pgalloc.h
+++ b/arch/parisc/include/asm/pgalloc.h
@@ -61,9 +61,10 @@ static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgd, pmd_t *pmd)
 		        (__u32)(__pa((unsigned long)pmd) >> PxD_VALUE_SHIFT));
 }
 
-static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
+static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address,
+								gfp_t gfp_mask)
 {
-	pmd_t *pmd = (pmd_t *)__get_free_pages(GFP_KERNEL|__GFP_REPEAT,
+	pmd_t *pmd = (pmd_t *)__get_free_pages(gfp_mask|__GFP_REPEAT,
 					       PMD_ORDER);
 	if (pmd)
 		memset(pmd, 0, PAGE_SIZE<<PMD_ORDER);
@@ -90,7 +91,7 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
  * inside the pgd, so has no extra memory associated with it.
  */
 
-#define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *)2); })
+#define pmd_alloc_one(mm, addr, gfp)	({ BUG(); ((pmd_t *)2); })
 #define pmd_free(mm, x)			do { } while (0)
 #define pgd_populate(mm, pmd, pte)	BUG()
 
@@ -127,9 +128,9 @@ pte_alloc_one(struct mm_struct *mm, unsigned long address)
 }
 
 static inline pte_t *
-pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr)
+pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr, gfp_t gfp_mask)
 {
-	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+	pte_t *pte = (pte_t *)__get_free_page(gfp_mask|__GFP_REPEAT|__GFP_ZERO);
 	return pte;
 }
 
diff --git a/arch/powerpc/include/asm/pgalloc-32.h b/arch/powerpc/include/asm/pgalloc-32.h
index 580cf73..3755544 100644
--- a/arch/powerpc/include/asm/pgalloc-32.h
+++ b/arch/powerpc/include/asm/pgalloc-32.h
@@ -34,7 +34,8 @@ extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
 #define pmd_pgtable(pmd) pmd_page(pmd)
 #endif
 
-extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr);
+extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr,
+								gfp_t gfp_mask);
 extern pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long addr);
 
 static inline void pgtable_free(void *table, unsigned index_size)
diff --git a/arch/powerpc/include/asm/pgalloc-64.h b/arch/powerpc/include/asm/pgalloc-64.h
index 292725c..13c4999 100644
--- a/arch/powerpc/include/asm/pgalloc-64.h
+++ b/arch/powerpc/include/asm/pgalloc-64.h
@@ -51,10 +51,11 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 
 #define pgd_populate(MM, PGD, PUD)	pgd_set(PGD, PUD)
 
-static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
+static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr,
+								gfp_t gfp_mask)
 {
 	return kmem_cache_alloc(PGT_CACHE(PUD_INDEX_SIZE),
-				GFP_KERNEL|__GFP_REPEAT);
+				gfp_mask|__GFP_REPEAT);
 }
 
 static inline void pud_free(struct mm_struct *mm, pud_t *pud)
@@ -89,10 +90,11 @@ static inline void pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd,
 
 #endif /* CONFIG_PPC_64K_PAGES */
 
-static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
+static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr,
+								gfp_t gfp_mask)
 {
 	return kmem_cache_alloc(PGT_CACHE(PMD_INDEX_SIZE),
-				GFP_KERNEL|__GFP_REPEAT);
+				gfp_mask|__GFP_REPEAT);
 }
 
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
@@ -101,9 +103,9 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 }
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-					  unsigned long address)
+					  unsigned long address, gfp_t gfp_mask)
 {
-        return (pte_t *)__get_free_page(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO);
+        return (pte_t *)__get_free_page(gfp_mask | __GFP_REPEAT | __GFP_ZERO);
 }
 
 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
@@ -112,7 +114,7 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
 	struct page *page;
 	pte_t *pte;
 
-	pte = pte_alloc_one_kernel(mm, address);
+	pte = pte_alloc_one_kernel(mm, address, GFP_KERNEL);
 	if (!pte)
 		return NULL;
 	page = virt_to_page(pte);
diff --git a/arch/powerpc/mm/pgtable_32.c b/arch/powerpc/mm/pgtable_32.c
index a87ead0..d7f8ace 100644
--- a/arch/powerpc/mm/pgtable_32.c
+++ b/arch/powerpc/mm/pgtable_32.c
@@ -95,14 +95,15 @@ void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 #endif
 }
 
-__init_refok pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+__init_refok pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
+					unsigned long address, gfp_t gfp_mask)
 {
 	pte_t *pte;
 	extern int mem_init_done;
 	extern void *early_get_page(void);
 
 	if (mem_init_done) {
-		pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+		pte = (pte_t *)__get_free_page(gfp_mask|__GFP_REPEAT|__GFP_ZERO);
 	} else {
 		pte = (pte_t *)early_get_page();
 		if (pte)
diff --git a/arch/s390/include/asm/pgalloc.h b/arch/s390/include/asm/pgalloc.h
index 68940d0..802e2ae 100644
--- a/arch/s390/include/asm/pgalloc.h
+++ b/arch/s390/include/asm/pgalloc.h
@@ -19,10 +19,10 @@
 
 #define check_pgt_cache()	do {} while (0)
 
-unsigned long *crst_table_alloc(struct mm_struct *, int);
+unsigned long *crst_table_alloc(struct mm_struct *, int, gfp_t);
 void crst_table_free(struct mm_struct *, unsigned long *);
 
-unsigned long *page_table_alloc(struct mm_struct *);
+unsigned long *page_table_alloc(struct mm_struct *, gfp_t);
 void page_table_free(struct mm_struct *, unsigned long *);
 void disable_noexec(struct mm_struct *, struct task_struct *);
 
@@ -60,10 +60,10 @@ static inline unsigned long pgd_entry_type(struct mm_struct *mm)
 	return _SEGMENT_ENTRY_EMPTY;
 }
 
-#define pud_alloc_one(mm,address)		({ BUG(); ((pud_t *)2); })
+#define pud_alloc_one(mm,address,gfp)		({ BUG(); ((pud_t *)2); })
 #define pud_free(mm, x)				do { } while (0)
 
-#define pmd_alloc_one(mm,address)		({ BUG(); ((pmd_t *)2); })
+#define pmd_alloc_one(mm,address,gfp)		({ BUG(); ((pmd_t *)2); })
 #define pmd_free(mm, x)				do { } while (0)
 
 #define pgd_populate(mm, pgd, pud)		BUG()
@@ -86,18 +86,22 @@ static inline unsigned long pgd_entry_type(struct mm_struct *mm)
 int crst_table_upgrade(struct mm_struct *, unsigned long limit);
 void crst_table_downgrade(struct mm_struct *, unsigned long limit);
 
-static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long address)
+static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long address,
+								gfp_t gfp_mask)
 {
-	unsigned long *table = crst_table_alloc(mm, mm->context.noexec);
+	unsigned long *table = crst_table_alloc(mm, mm->context.noexec,
+								gfp_mask);
 	if (table)
 		crst_table_init(table, _REGION3_ENTRY_EMPTY);
 	return (pud_t *) table;
 }
 #define pud_free(mm, pud) crst_table_free(mm, (unsigned long *) pud)
 
-static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long vmaddr)
+static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long vmaddr,
+								gfp_t gfp_mask)
 {
-	unsigned long *table = crst_table_alloc(mm, mm->context.noexec);
+	unsigned long *table = crst_table_alloc(mm, mm->context.noexec,
+								gfp_mask);
 	if (table)
 		crst_table_init(table, _SEGMENT_ENTRY_EMPTY);
 	return (pmd_t *) table;
@@ -143,8 +147,8 @@ static inline pgd_t *pgd_alloc(struct mm_struct *mm)
 	spin_lock_init(&mm->context.list_lock);
 	INIT_LIST_HEAD(&mm->context.crst_list);
 	INIT_LIST_HEAD(&mm->context.pgtable_list);
-	return (pgd_t *)
-		crst_table_alloc(mm, user_mode == SECONDARY_SPACE_MODE);
+	return (pgd_t *) crst_table_alloc(mm, user_mode == SECONDARY_SPACE_MODE,
+								GFP_KERNEL);
 }
 #define pgd_free(mm, pgd) crst_table_free(mm, (unsigned long *) pgd)
 
@@ -170,8 +174,8 @@ static inline void pmd_populate(struct mm_struct *mm,
 /*
  * page table entry allocation/free routines.
  */
-#define pte_alloc_one_kernel(mm, vmaddr) ((pte_t *) page_table_alloc(mm))
-#define pte_alloc_one(mm, vmaddr) ((pte_t *) page_table_alloc(mm))
+#define pte_alloc_one_kernel(mm, vmaddr, gfp) ((pte_t *) page_table_alloc(mm, gfp))
+#define pte_alloc_one(mm, vmaddr) ((pte_t *) page_table_alloc(mm, GFP_KERNEL))
 
 #define pte_free_kernel(mm, pte) page_table_free(mm, (unsigned long *) pte)
 #define pte_free(mm, pte) page_table_free(mm, (unsigned long *) pte)
diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index 8d99924..3a23e51 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -63,15 +63,15 @@ static int __init parse_vmalloc(char *arg)
 }
 early_param("vmalloc", parse_vmalloc);
 
-unsigned long *crst_table_alloc(struct mm_struct *mm, int noexec)
+unsigned long *crst_table_alloc(struct mm_struct *mm, int noexec, gfp_t gfp_mask)
 {
-	struct page *page = alloc_pages(GFP_KERNEL, ALLOC_ORDER);
+	struct page *page = alloc_pages(gfp_mask, ALLOC_ORDER);
 
 	if (!page)
 		return NULL;
 	page->index = 0;
 	if (noexec) {
-		struct page *shadow = alloc_pages(GFP_KERNEL, ALLOC_ORDER);
+		struct page *shadow = alloc_pages(gfp_mask, ALLOC_ORDER);
 		if (!shadow) {
 			__free_pages(page, ALLOC_ORDER);
 			return NULL;
@@ -105,7 +105,7 @@ int crst_table_upgrade(struct mm_struct *mm, unsigned long limit)
 
 	BUG_ON(limit > (1UL << 53));
 repeat:
-	table = crst_table_alloc(mm, mm->context.noexec);
+	table = crst_table_alloc(mm, mm->context.noexec, GFP_KERNEL);
 	if (!table)
 		return -ENOMEM;
 	spin_lock(&mm->page_table_lock);
@@ -175,7 +175,7 @@ void crst_table_downgrade(struct mm_struct *mm, unsigned long limit)
 /*
  * page table entry allocation/free routines.
  */
-unsigned long *page_table_alloc(struct mm_struct *mm)
+unsigned long *page_table_alloc(struct mm_struct *mm, gfp_t gfp_mask)
 {
 	struct page *page;
 	unsigned long *table;
@@ -192,7 +192,7 @@ unsigned long *page_table_alloc(struct mm_struct *mm)
 	}
 	if (!page) {
 		spin_unlock(&mm->context.list_lock);
-		page = alloc_page(GFP_KERNEL|__GFP_REPEAT);
+		page = alloc_page(gfp_mask|__GFP_REPEAT);
 		if (!page)
 			return NULL;
 		pgtable_page_ctor(page);
diff --git a/arch/s390/mm/vmem.c b/arch/s390/mm/vmem.c
index 34c43f2..8541f00 100644
--- a/arch/s390/mm/vmem.c
+++ b/arch/s390/mm/vmem.c
@@ -66,7 +66,7 @@ static pte_t __ref *vmem_pte_alloc(void)
 	pte_t *pte;
 
 	if (slab_is_available())
-		pte = (pte_t *) page_table_alloc(&init_mm);
+		pte = (pte_t *) page_table_alloc(&init_mm, GFP_KERNEL);
 	else
 		pte = alloc_bootmem(PTRS_PER_PTE * sizeof(pte_t));
 	if (!pte)
diff --git a/arch/score/include/asm/pgalloc.h b/arch/score/include/asm/pgalloc.h
index 059a61b..7d85784 100644
--- a/arch/score/include/asm/pgalloc.h
+++ b/arch/score/include/asm/pgalloc.h
@@ -38,11 +38,11 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 }
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-	unsigned long address)
+					unsigned long address, gfp_t gfp_mask)
 {
 	pte_t *pte;
 
-	pte = (pte_t *) __get_free_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO,
+	pte = (pte_t *) __get_free_pages(gfp_mask|__GFP_REPEAT|__GFP_ZERO,
 					PTE_ORDER);
 
 	return pte;
diff --git a/arch/sh/include/asm/pgalloc.h b/arch/sh/include/asm/pgalloc.h
index 8c00785..dcdb7f7 100644
--- a/arch/sh/include/asm/pgalloc.h
+++ b/arch/sh/include/asm/pgalloc.h
@@ -11,7 +11,8 @@ extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
 
 #if PAGETABLE_LEVELS > 2
 extern void pud_populate(struct mm_struct *mm, pud_t *pudp, pmd_t *pmd);
-extern pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address);
+extern pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address,
+							gfp_t gfp_mask);
 extern void pmd_free(struct mm_struct *mm, pmd_t *pmd);
 #endif
 
@@ -32,9 +33,9 @@ static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
  * Allocate and free page tables.
  */
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-					  unsigned long address)
+					  unsigned long address, gfp_t gfp_mask)
 {
-	return quicklist_alloc(QUICK_PT, GFP_KERNEL | __GFP_REPEAT, NULL);
+	return quicklist_alloc(QUICK_PT, gfp_mask | __GFP_REPEAT, NULL);
 }
 
 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
diff --git a/arch/sh/mm/pgtable.c b/arch/sh/mm/pgtable.c
index 26e03a1..95f4348 100644
--- a/arch/sh/mm/pgtable.c
+++ b/arch/sh/mm/pgtable.c
@@ -1,7 +1,7 @@
 #include <linux/mm.h>
 #include <linux/slab.h>
 
-#define PGALLOC_GFP GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO
+#define PGALLOC_GFP __GFP_REPEAT | __GFP_ZERO
 
 static struct kmem_cache *pgd_cachep;
 #if PAGETABLE_LEVELS > 2
@@ -31,7 +31,7 @@ void pgtable_cache_init(void)
 
 pgd_t *pgd_alloc(struct mm_struct *mm)
 {
-	return kmem_cache_alloc(pgd_cachep, PGALLOC_GFP);
+	return kmem_cache_alloc(pgd_cachep, GFP_KERNEL | PGALLOC_GFP);
 }
 
 void pgd_free(struct mm_struct *mm, pgd_t *pgd)
@@ -45,9 +45,9 @@ void pud_populate(struct mm_struct *mm, pud_t *pud, pmd_t *pmd)
 	set_pud(pud, __pud((unsigned long)pmd));
 }
 
-pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
+pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address, gfp_t gfp_mask)
 {
-	return kmem_cache_alloc(pmd_cachep, PGALLOC_GFP);
+	return kmem_cache_alloc(pmd_cachep, gfp_mask | PGALLOC_GFP);
 }
 
 void pmd_free(struct mm_struct *mm, pmd_t *pmd)
diff --git a/arch/sparc/include/asm/pgalloc_32.h b/arch/sparc/include/asm/pgalloc_32.h
index ca2b344..a9a1e86 100644
--- a/arch/sparc/include/asm/pgalloc_32.h
+++ b/arch/sparc/include/asm/pgalloc_32.h
@@ -38,8 +38,8 @@ BTFIXUPDEF_CALL(void, pgd_set, pgd_t *, pmd_t *)
 #define pgd_set(pgdp,pmdp) BTFIXUP_CALL(pgd_set)(pgdp,pmdp)
 #define pgd_populate(MM, PGD, PMD)      pgd_set(PGD, PMD)
 
-BTFIXUPDEF_CALL(pmd_t *, pmd_alloc_one, struct mm_struct *, unsigned long)
-#define pmd_alloc_one(mm, address)	BTFIXUP_CALL(pmd_alloc_one)(mm, address)
+BTFIXUPDEF_CALL(pmd_t *, pmd_alloc_one, struct mm_struct *, unsigned long, gfp_t)
+#define pmd_alloc_one(mm, address, gfp)	BTFIXUP_CALL(pmd_alloc_one)(mm, address, gfp)
 
 BTFIXUPDEF_CALL(void, free_pmd_fast, pmd_t *)
 #define free_pmd_fast(pmd)	BTFIXUP_CALL(free_pmd_fast)(pmd)
@@ -55,8 +55,9 @@ BTFIXUPDEF_CALL(void, pmd_set, pmd_t *, pte_t *)
 
 BTFIXUPDEF_CALL(pgtable_t , pte_alloc_one, struct mm_struct *, unsigned long)
 #define pte_alloc_one(mm, address)	BTFIXUP_CALL(pte_alloc_one)(mm, address)
-BTFIXUPDEF_CALL(pte_t *, pte_alloc_one_kernel, struct mm_struct *, unsigned long)
-#define pte_alloc_one_kernel(mm, addr)	BTFIXUP_CALL(pte_alloc_one_kernel)(mm, addr)
+BTFIXUPDEF_CALL(pte_t *, pte_alloc_one_kernel, struct mm_struct *, unsigned long, gfp_t)
+#define pte_alloc_one_kernel(mm, addr, gfp)	\
+			BTFIXUP_CALL(pte_alloc_one_kernel)(mm, addr, gfp)
 
 BTFIXUPDEF_CALL(void, free_pte_fast, pte_t *)
 #define pte_free_kernel(mm, pte)	BTFIXUP_CALL(free_pte_fast)(pte)
diff --git a/arch/sparc/include/asm/pgalloc_64.h b/arch/sparc/include/asm/pgalloc_64.h
index 5bdfa2c..7ea974f 100644
--- a/arch/sparc/include/asm/pgalloc_64.h
+++ b/arch/sparc/include/asm/pgalloc_64.h
@@ -26,9 +26,10 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 
 #define pud_populate(MM, PUD, PMD)	pud_set(PUD, PMD)
 
-static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
+static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr,
+								gfp_t gfp_mask)
 {
-	return quicklist_alloc(0, GFP_KERNEL, NULL);
+	return quicklist_alloc(0, gfp_mask, NULL);
 }
 
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
@@ -37,9 +38,9 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 }
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-					  unsigned long address)
+					  unsigned long address, gfp_t gfp_mask)
 {
-	return quicklist_alloc(0, GFP_KERNEL, NULL);
+	return quicklist_alloc(0, gfp_mask, NULL);
 }
 
 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
diff --git a/arch/sparc/mm/srmmu.c b/arch/sparc/mm/srmmu.c
index b0b43aa..e6339a3 100644
--- a/arch/sparc/mm/srmmu.c
+++ b/arch/sparc/mm/srmmu.c
@@ -467,7 +467,8 @@ static void srmmu_free_pgd_fast(pgd_t *pgd)
 	srmmu_free_nocache((unsigned long)pgd, SRMMU_PGD_TABLE_SIZE);
 }
 
-static pmd_t *srmmu_pmd_alloc_one(struct mm_struct *mm, unsigned long address)
+static pmd_t *srmmu_pmd_alloc_one(struct mm_struct *mm, unsigned long address,
+								gfp_t gfp_mask)
 {
 	return (pmd_t *)srmmu_get_nocache(SRMMU_PMD_TABLE_SIZE, SRMMU_PMD_TABLE_SIZE);
 }
@@ -486,7 +487,8 @@ static void srmmu_pmd_free(pmd_t * pmd)
  * addresses of the nocache area.
  */
 static pte_t *
-srmmu_pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+srmmu_pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
+							gfp_t gfp_mask)
 {
 	return (pte_t *)srmmu_get_nocache(PTE_SIZE, PTE_SIZE);
 }
@@ -497,7 +499,8 @@ srmmu_pte_alloc_one(struct mm_struct *mm, unsigned long address)
 	unsigned long pte;
 	struct page *page;
 
-	if ((pte = (unsigned long)srmmu_pte_alloc_one_kernel(mm, address)) == 0)
+	pte = (unsigned long) srmmu_pte_alloc_one_kernel(mm, address, GFP_KERNEL);
+	if (pte == 0)
 		return NULL;
 	page = pfn_to_page( __nocache_pa(pte) >> PAGE_SHIFT );
 	pgtable_page_ctor(page);
diff --git a/arch/sparc/mm/sun4c.c b/arch/sparc/mm/sun4c.c
index 4289f90..8861156 100644
--- a/arch/sparc/mm/sun4c.c
+++ b/arch/sparc/mm/sun4c.c
@@ -1824,14 +1824,15 @@ sun4c_pte_alloc_one_fast(struct mm_struct *mm, unsigned long address)
 	return (pte_t *)ret;
 }
 
-static pte_t *sun4c_pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+static pte_t *sun4c_pte_alloc_one_kernel(struct mm_struct *mm,
+					unsigned long address, gfp_t gfp_mask)
 {
 	pte_t *pte;
 
 	if ((pte = sun4c_pte_alloc_one_fast(mm, address)) != NULL)
 		return pte;
 
-	pte = (pte_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+	pte = (pte_t *)get_zeroed_page(gfp_mask|__GFP_REPEAT);
 	return pte;
 }
 
@@ -1840,7 +1841,7 @@ static pgtable_t sun4c_pte_alloc_one(struct mm_struct *mm, unsigned long address
 	pte_t *pte;
 	struct page *page;
 
-	pte = sun4c_pte_alloc_one_kernel(mm, address);
+	pte = sun4c_pte_alloc_one_kernel(mm, address, GFP_KERNEL);
 	if (pte == NULL)
 		return NULL;
 	page = virt_to_page(pte);
@@ -1865,7 +1866,8 @@ static void sun4c_pte_free(pgtable_t pte)
  * allocating and freeing a pmd is trivial: the 1-entry pmd is
  * inside the pgd, so has no extra memory associated with it.
  */
-static pmd_t *sun4c_pmd_alloc_one(struct mm_struct *mm, unsigned long address)
+static pmd_t *sun4c_pmd_alloc_one(struct mm_struct *mm, unsigned long address,
+								gfp_t gfp_mask)
 {
 	BUG();
 	return NULL;
diff --git a/arch/tile/include/asm/pgalloc.h b/arch/tile/include/asm/pgalloc.h
index cf52791..b608571 100644
--- a/arch/tile/include/asm/pgalloc.h
+++ b/arch/tile/include/asm/pgalloc.h
@@ -68,15 +68,19 @@ static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
 extern pgd_t *pgd_alloc(struct mm_struct *mm);
 extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
 
-extern pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address);
+extern pgtable_t pte_alloc_one_gfp(struct mm_struct *mm, unsigned long address,
+								gfp_t gfp_mask);
+
+#define pte_alloc_one(mm, address) pte_alloc_one_gfp((mm), (address), GFP_KERNEL)
+
 extern void pte_free(struct mm_struct *mm, struct page *pte);
 
 #define pmd_pgtable(pmd) pmd_page(pmd)
 
 static inline pte_t *
-pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address, gfp_t gfp)
 {
-	return pfn_to_kaddr(page_to_pfn(pte_alloc_one(mm, address)));
+	return pfn_to_kaddr(page_to_pfn(pte_alloc_one_gfp(mm, address, gfp)));
 }
 
 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
@@ -108,8 +112,8 @@ void shatter_pmd(pmd_t *pmd);
 #define L1_USER_PGTABLE_ORDER L2_USER_PGTABLE_ORDER
 #define pud_populate(mm, pud, pmd) \
   pmd_populate_kernel((mm), (pmd_t *)(pud), (pte_t *)(pmd))
-#define pmd_alloc_one(mm, addr) \
-  ((pmd_t *)page_to_virt(pte_alloc_one((mm), (addr))))
+#define pmd_alloc_one(mm, addr, gfp) \
+  ((pmd_t *)page_to_virt(pte_alloc_one_gfp((mm), (addr), (gfp))))
 #define pmd_free(mm, pmdp) \
   pte_free((mm), virt_to_page(pmdp))
 #define __pmd_free_tlb(tlb, pmdp, address) \
diff --git a/arch/tile/kernel/module.c b/arch/tile/kernel/module.c
index e2ab82b..83196da 100644
--- a/arch/tile/kernel/module.c
+++ b/arch/tile/kernel/module.c
@@ -67,7 +67,7 @@ void *module_alloc(unsigned long size)
 	if (!area)
 		goto error;
 
-	if (map_vm_area(area, prot_rwx, &pages)) {
+	if (map_vm_area(area, GFP_KERNEL, prot_rwx, &pages)) {
 		vunmap(area->addr);
 		goto error;
 	}
diff --git a/arch/tile/mm/pgtable.c b/arch/tile/mm/pgtable.c
index 335c246..3baffd2 100644
--- a/arch/tile/mm/pgtable.c
+++ b/arch/tile/mm/pgtable.c
@@ -218,9 +218,10 @@ void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 
 #define L2_USER_PGTABLE_PAGES (1 << L2_USER_PGTABLE_ORDER)
 
-struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
+struct page *pte_alloc_one_gfp(struct mm_struct *mm, unsigned long address,
+								gfp_t gfp_mask)
 {
-	gfp_t flags = GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO|__GFP_COMP;
+	gfp_t flags = gfp_mask|__GFP_REPEAT|__GFP_ZERO|__GFP_COMP;
 	struct page *p;
 
 #ifdef CONFIG_HIGHPTE
@@ -237,7 +238,7 @@ struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
 
 /*
  * Free page immediately (used in __pte_alloc if we raced with another
- * process).  We have to correct whatever pte_alloc_one() did before
+ * process).  We have to correct whatever pte_alloc_one_gfp() did before
  * returning the pages to the allocator.
  */
 void pte_free(struct mm_struct *mm, struct page *p)
diff --git a/arch/um/include/asm/pgalloc.h b/arch/um/include/asm/pgalloc.h
index 32c8ce4..c51a768 100644
--- a/arch/um/include/asm/pgalloc.h
+++ b/arch/um/include/asm/pgalloc.h
@@ -26,7 +26,7 @@
 extern pgd_t *pgd_alloc(struct mm_struct *);
 extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
 
-extern pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long);
+extern pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long, gfp_t);
 extern pgtable_t pte_alloc_one(struct mm_struct *, unsigned long);
 
 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
diff --git a/arch/um/include/asm/pgtable-3level.h b/arch/um/include/asm/pgtable-3level.h
index 0032f92..442f8f9 100644
--- a/arch/um/include/asm/pgtable-3level.h
+++ b/arch/um/include/asm/pgtable-3level.h
@@ -79,7 +79,8 @@ static inline void pgd_mkuptodate(pgd_t pgd) { pgd_val(pgd) &= ~_PAGE_NEWPAGE; }
 #endif
 
 struct mm_struct;
-extern pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address);
+extern pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address,
+							gfp_t gfp_mask);
 
 static inline void pud_clear (pud_t *pud)
 {
diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
index 8137ccc..e28702f 100644
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -284,11 +284,12 @@ void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 	free_page((unsigned long) pgd);
 }
 
-pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
+								gfp_t gfp_mask)
 {
 	pte_t *pte;
 
-	pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+	pte = (pte_t *)__get_free_page(gfp_mask|__GFP_REPEAT|__GFP_ZERO);
 	return pte;
 }
 
@@ -303,9 +304,10 @@ pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
 }
 
 #ifdef CONFIG_3_LEVEL_PGTABLES
-pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
+pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address,
+							gfp_t gfp_mask)
 {
-	pmd_t *pmd = (pmd_t *) __get_free_page(GFP_KERNEL);
+	pmd_t *pmd = (pmd_t *) __get_free_page(gfp_mask);
 
 	if (pmd)
 		memset(pmd, 0, PAGE_SIZE);
diff --git a/arch/x86/include/asm/pgalloc.h b/arch/x86/include/asm/pgalloc.h
index 271de94..2534741 100644
--- a/arch/x86/include/asm/pgalloc.h
+++ b/arch/x86/include/asm/pgalloc.h
@@ -33,7 +33,7 @@ extern gfp_t __userpte_alloc_gfp;
 extern pgd_t *pgd_alloc(struct mm_struct *);
 extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
 
-extern pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long);
+extern pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long, gfp_t);
 extern pgtable_t pte_alloc_one(struct mm_struct *, unsigned long);
 
 /* Should really implement gc for free page table pages. This could be
@@ -78,9 +78,10 @@ static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
 #define pmd_pgtable(pmd) pmd_page(pmd)
 
 #if PAGETABLE_LEVELS > 2
-static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
+static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr,
+								gfp_t gfp_mask)
 {
-	return (pmd_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+	return (pmd_t *)get_zeroed_page(gfp_mask|__GFP_REPEAT);
 }
 
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
@@ -114,9 +115,10 @@ static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgd, pud_t *pud)
 	set_pgd(pgd, __pgd(_PAGE_TABLE | __pa(pud)));
 }
 
-static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
+static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr,
+								gfp_t gfp_mask)
 {
-	return (pud_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+	return (pud_t *)get_zeroed_page(gfp_mask|__GFP_REPEAT);
 }
 
 static inline void pud_free(struct mm_struct *mm, pud_t *pud)
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 5c4ee42..13001ca 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -5,7 +5,7 @@
 #include <asm/tlb.h>
 #include <asm/fixmap.h>
 
-#define PGALLOC_GFP GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO
+#define PGALLOC_GFP __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO
 
 #ifdef CONFIG_HIGHPTE
 #define PGALLOC_USER_GFP __GFP_HIGHMEM
@@ -13,11 +13,12 @@
 #define PGALLOC_USER_GFP 0
 #endif
 
-gfp_t __userpte_alloc_gfp = PGALLOC_GFP | PGALLOC_USER_GFP;
+gfp_t __userpte_alloc_gfp = GFP_KERNEL | PGALLOC_GFP | PGALLOC_USER_GFP;
 
-pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
+								gfp_t gfp_mask)
 {
-	return (pte_t *)__get_free_page(PGALLOC_GFP);
+	return (pte_t *)__get_free_page(gfp_mask | PGALLOC_GFP);
 }
 
 pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
@@ -185,7 +186,7 @@ static int preallocate_pmds(pmd_t *pmds[])
 	bool failed = false;
 
 	for(i = 0; i < PREALLOCATED_PMDS; i++) {
-		pmd_t *pmd = (pmd_t *)__get_free_page(PGALLOC_GFP);
+		pmd_t *pmd = (pmd_t *)__get_free_page(GFP_KERNEL | PGALLOC_GFP);
 		if (pmd == NULL)
 			failed = true;
 		pmds[i] = pmd;
@@ -252,7 +253,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 	pmd_t *pmds[PREALLOCATED_PMDS];
 	unsigned long flags;
 
-	pgd = (pgd_t *)__get_free_page(PGALLOC_GFP);
+	pgd = (pgd_t *)__get_free_page(GFP_KERNEL | PGALLOC_GFP);
 
 	if (pgd == NULL)
 		goto out;
diff --git a/arch/xtensa/include/asm/pgalloc.h b/arch/xtensa/include/asm/pgalloc.h
index 40cf9bc..7dd2ed0 100644
--- a/arch/xtensa/include/asm/pgalloc.h
+++ b/arch/xtensa/include/asm/pgalloc.h
@@ -42,10 +42,10 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 
 extern struct kmem_cache *pgtable_cache;
 
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm, 
-					 unsigned long address)
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
+					 unsigned long address, gfp_t gfp_mask)
 {
-	return kmem_cache_alloc(pgtable_cache, GFP_KERNEL|__GFP_REPEAT);
+	return kmem_cache_alloc(pgtable_cache, gfp_mask|__GFP_REPEAT);
 }
 
 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
@@ -53,7 +53,7 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
 {
 	struct page *page;
 
-	page = virt_to_page(pte_alloc_one_kernel(mm, addr));
+	page = virt_to_page(pte_alloc_one_kernel(mm, addr, GFP_KERNEL));
 	pgtable_page_ctor(page);
 	return page;
 }
diff --git a/arch/xtensa/mm/pgtable.c b/arch/xtensa/mm/pgtable.c
index 6979927..7634432 100644
--- a/arch/xtensa/mm/pgtable.c
+++ b/arch/xtensa/mm/pgtable.c
@@ -12,13 +12,14 @@
 
 #if (DCACHE_SIZE > PAGE_SIZE)
 
-pte_t* pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+pte_t* pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
+								gfp_t gfp_mask)
 {
 	pte_t *pte = NULL, *p;
 	int color = ADDR_COLOR(address);
 	int i;
 
-	p = (pte_t*) __get_free_pages(GFP_KERNEL|__GFP_REPEAT, COLOR_ORDER);
+	p = (pte_t*) __get_free_pages(gfp_mask|__GFP_REPEAT, COLOR_ORDER);
 
 	if (likely(p)) {
 		split_page(virt_to_page(p), COLOR_ORDER);
diff --git a/drivers/lguest/core.c b/drivers/lguest/core.c
index efa2024..fbec648 100644
--- a/drivers/lguest/core.c
+++ b/drivers/lguest/core.c
@@ -109,7 +109,7 @@ static __init int map_switcher(void)
 	 * care.
 	 */
 	pagep = switcher_page;
-	err = map_vm_area(switcher_vma, PAGE_KERNEL_EXEC, &pagep);
+	err = map_vm_area(switcher_vma, GFP_KERNEL, PAGE_KERNEL_EXEC, &pagep);
 	if (err) {
 		printk("lguest: map_vm_area failed: %i\n", err);
 		goto free_vma;
diff --git a/fs/xfs/linux-2.6/xfs_buf.c b/fs/xfs/linux-2.6/xfs_buf.c
index 286e36e..beb5d17 100644
--- a/fs/xfs/linux-2.6/xfs_buf.c
+++ b/fs/xfs/linux-2.6/xfs_buf.c
@@ -390,7 +390,7 @@ _xfs_buf_map_pages(
 		bp->b_flags |= XBF_MAPPED;
 	} else if (flags & XBF_MAPPED) {
 		bp->b_addr = vm_map_ram(bp->b_pages, bp->b_page_count,
-					-1, PAGE_KERNEL);
+					-1, GFP_NOFS, PAGE_KERNEL);
 		if (unlikely(bp->b_addr == NULL))
 			return -ENOMEM;
 		bp->b_addr += bp->b_offset;
diff --git a/include/asm-generic/4level-fixup.h b/include/asm-generic/4level-fixup.h
index 77ff547..f2e0978 100644
--- a/include/asm-generic/4level-fixup.h
+++ b/include/asm-generic/4level-fixup.h
@@ -10,10 +10,13 @@
 
 #define pud_t				pgd_t
 
-#define pmd_alloc(mm, pud, address) \
-	((unlikely(pgd_none(*(pud))) && __pmd_alloc(mm, pud, address))? \
- 		NULL: pmd_offset(pud, address))
+#define pmd_alloc_gfp(mm, pud, address, gfp) \
+	((unlikely(pgd_none(*(pud))) && __pmd_alloc(mm, pud, address, gfp))? \
+		NULL: pmd_offset(pud, address))
 
+#define pmd_alloc(mm, pud, addr) pmd_alloc_gfp((mm), (pud), (addr), GFP_KERNEL)
+
+#define pud_alloc_gfp(mm,pgd,addr,gfp)	(pgd)
 #define pud_alloc(mm, pgd, address)	(pgd)
 #define pud_offset(pgd, start)		(pgd)
 #define pud_none(pud)			0
diff --git a/include/asm-generic/pgtable-nopmd.h b/include/asm-generic/pgtable-nopmd.h
index 725612b..b80d12a 100644
--- a/include/asm-generic/pgtable-nopmd.h
+++ b/include/asm-generic/pgtable-nopmd.h
@@ -55,7 +55,7 @@ static inline pmd_t * pmd_offset(pud_t * pud, unsigned long address)
  * allocating and freeing a pmd is trivial: the 1-entry pmd is
  * inside the pud, so has no extra memory associated with it.
  */
-#define pmd_alloc_one(mm, address)		NULL
+#define pmd_alloc_one(mm, address, gfp)		NULL
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 }
diff --git a/include/asm-generic/pgtable-nopud.h b/include/asm-generic/pgtable-nopud.h
index 810431d..df2a7a2 100644
--- a/include/asm-generic/pgtable-nopud.h
+++ b/include/asm-generic/pgtable-nopud.h
@@ -50,7 +50,7 @@ static inline pud_t * pud_offset(pgd_t * pgd, unsigned long address)
  * allocating and freeing a pud is trivial: the 1-entry pud is
  * inside the pgd, so has no extra memory associated with it.
  */
-#define pud_alloc_one(mm, address)		NULL
+#define pud_alloc_one(mm, address, gfp)		NULL
 #define pud_free(mm, x)				do { } while (0)
 #define __pud_free_tlb(tlb, x, a)		do { } while (0)
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 74949fb..40e917e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1027,42 +1027,60 @@ extern pte_t *get_locked_pte(struct mm_struct *mm, unsigned long addr, spinlock_
 
 #ifdef __PAGETABLE_PUD_FOLDED
 static inline int __pud_alloc(struct mm_struct *mm, pgd_t *pgd,
-						unsigned long address)
+					unsigned long address, gfp_t gfp_mask)
 {
 	return 0;
 }
 #else
-int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address);
+int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address,
+								gfp_t gfp_mask);
 #endif
 
 #ifdef __PAGETABLE_PMD_FOLDED
 static inline int __pmd_alloc(struct mm_struct *mm, pud_t *pud,
-						unsigned long address)
+					unsigned long address, gfp_t gfp_mask)
 {
 	return 0;
 }
 #else
-int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address);
+int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address,
+								gfp_t gfp_mask);
 #endif
 
 int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address);
-int __pte_alloc_kernel(pmd_t *pmd, unsigned long address);
+int __pte_alloc_kernel(pmd_t *pmd, unsigned long address, gfp_t gfp_mask);
 
 /*
  * The following ifdef needed to get the 4level-fixup.h header to work.
  * Remove it when 4level-fixup.h has been removed.
  */
 #if defined(CONFIG_MMU) && !defined(__ARCH_HAS_4LEVEL_HACK)
+static inline pud_t *pud_alloc_gfp(struct mm_struct *mm, pgd_t *pgd,
+					unsigned long address, gfp_t gfp_mask)
+{
+	if (unlikely(pgd_none(*pgd)) && __pud_alloc(mm, pgd, address, gfp_mask))
+		return NULL;
+
+	return pud_offset(pgd, address);
+}
+
 static inline pud_t *pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
 {
-	return (unlikely(pgd_none(*pgd)) && __pud_alloc(mm, pgd, address))?
-		NULL: pud_offset(pgd, address);
+	return pud_alloc_gfp(mm, pgd, address, GFP_KERNEL);
+}
+
+static inline pmd_t *pmd_alloc_gfp(struct mm_struct *mm, pud_t *pud,
+					unsigned long address, gfp_t gfp_mask)
+{
+	if (unlikely(pud_none(*pud)) && __pmd_alloc(mm, pud, address, gfp_mask))
+		return NULL;
+
+	return pmd_offset(pud, address);
 }
 
 static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
 {
-	return (unlikely(pud_none(*pud)) && __pmd_alloc(mm, pud, address))?
-		NULL: pmd_offset(pud, address);
+	return pmd_alloc_gfp(mm, pud, address, GFP_KERNEL);
 }
 #endif /* CONFIG_MMU && !__ARCH_HAS_4LEVEL_HACK */
 
@@ -1122,9 +1140,19 @@ static inline void pgtable_page_dtor(struct page *page)
 	((unlikely(!pmd_present(*(pmd))) && __pte_alloc(mm, pmd, address))? \
 		NULL: pte_offset_map_lock(mm, pmd, address, ptlp))
 
-#define pte_alloc_kernel(pmd, address)			\
-	((unlikely(!pmd_present(*(pmd))) && __pte_alloc_kernel(pmd, address))? \
-		NULL: pte_offset_kernel(pmd, address))
+static inline pte_t *pte_alloc_kernel_gfp(pmd_t *pmd, unsigned long addr,
+								gfp_t gfp)
+{
+	if (unlikely(!pmd_present(*pmd)) && __pte_alloc_kernel(pmd, addr, gfp))
+		return NULL;
+
+	return pte_offset_kernel(pmd, address);
+}
+
+static inline pte_t *pte_alloc_kernel(pmd_t *pmd, unsigned long addr)
+{
+	return pte_alloc_kernel_gfp(pmd, addr, GFP_KERNEL);
+}
 
 extern void free_area_init(unsigned long * zones_size);
 extern void free_area_init_node(int nid, unsigned long * zones_size,
diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 01c2145..1096f88 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -40,8 +40,8 @@ struct vm_struct {
  *	Highlevel APIs for driver use
  */
 extern void vm_unmap_ram(const void *mem, unsigned int count);
-extern void *vm_map_ram(struct page **pages, unsigned int count,
-				int node, pgprot_t prot);
+extern void *vm_map_ram(struct page **pages, unsigned int count, int node,
+				gfp_t gfp_mask, pgprot_t prot);
 extern void vm_unmap_aliases(void);
 
 #ifdef CONFIG_MMU
@@ -95,8 +95,8 @@ extern struct vm_struct *get_vm_area_node(unsigned long size,
 					  gfp_t gfp_mask);
 extern struct vm_struct *remove_vm_area(const void *addr);
 
-extern int map_vm_area(struct vm_struct *area, pgprot_t prot,
-			struct page ***pages);
+extern int map_vm_area(struct vm_struct *area, gfp_t gfp_mask, pgprot_t prot,
+							struct page ***pages);
 extern int map_kernel_range_noflush(unsigned long start, unsigned long size,
 				    pgprot_t prot, struct page **pages);
 extern void unmap_kernel_range_noflush(unsigned long addr, unsigned long size);
diff --git a/mm/memory.c b/mm/memory.c
index 0e18b4d..7d2e48c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -427,9 +427,9 @@ int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address)
 	return 0;
 }
 
-int __pte_alloc_kernel(pmd_t *pmd, unsigned long address)
+int __pte_alloc_kernel(pmd_t *pmd, unsigned long address, gfp_t gfp_mask)
 {
-	pte_t *new = pte_alloc_one_kernel(&init_mm, address);
+	pte_t *new = pte_alloc_one_kernel(&init_mm, address, gfp_mask);
 	if (!new)
 		return -ENOMEM;
 
@@ -3232,9 +3232,10 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
  * Allocate page upper directory.
  * We've already handled the fast-path in-line.
  */
-int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
+int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address,
+								gfp_t gfp_mask)
 {
-	pud_t *new = pud_alloc_one(mm, address);
+	pud_t *new = pud_alloc_one(mm, address, gfp_mask);
 	if (!new)
 		return -ENOMEM;
 
@@ -3255,9 +3256,10 @@ int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
  * Allocate page middle directory.
  * We've already handled the fast-path in-line.
  */
-int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
+int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address,
+								gfp_t gfp_mask)
 {
-	pmd_t *new = pmd_alloc_one(mm, address);
+	pmd_t *new = pmd_alloc_one(mm, address, gfp_mask);
 	if (!new)
 		return -ENOMEM;
 
diff --git a/mm/nommu.c b/mm/nommu.c
index 88ff091..cfdb86d 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -366,7 +366,8 @@ void vunmap(const void *addr)
 }
 EXPORT_SYMBOL(vunmap);
 
-void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t prot)
+void *vm_map_ram(struct page **pages, unsigned int count, int node, gfp_t mask,
+								pgprot_t prot)
 {
 	BUG();
 	return NULL;
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 6b8889d..b2e9932 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -89,8 +89,8 @@ static void vunmap_page_range(unsigned long addr, unsigned long end)
 	} while (pgd++, addr = next, addr != end);
 }
 
-static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
-		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
+static int vmap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
+		gfp_t gfp_mask, pgprot_t prot, struct page **pages, int *nr)
 {
 	pte_t *pte;
 
@@ -99,7 +99,7 @@ static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
 	 * callers keep track of where we're up to.
 	 */
 
-	pte = pte_alloc_kernel(pmd, addr);
+	pte = pte_alloc_kernel_gfp(pmd, addr, gfp_mask);
 	if (!pte)
 		return -ENOMEM;
 	do {
@@ -115,35 +115,35 @@ static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
 	return 0;
 }
 
-static int vmap_pmd_range(pud_t *pud, unsigned long addr,
-		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
+static int vmap_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
+		gfp_t gfp_mask, pgprot_t prot, struct page **pages, int *nr)
 {
 	pmd_t *pmd;
 	unsigned long next;
 
-	pmd = pmd_alloc(&init_mm, pud, addr);
+	pmd = pmd_alloc_gfp(&init_mm, pud, addr, gfp_mask);
 	if (!pmd)
 		return -ENOMEM;
 	do {
 		next = pmd_addr_end(addr, end);
-		if (vmap_pte_range(pmd, addr, next, prot, pages, nr))
+		if (vmap_pte_range(pmd, addr, next, gfp_mask, prot, pages, nr))
 			return -ENOMEM;
 	} while (pmd++, addr = next, addr != end);
 	return 0;
 }
 
-static int vmap_pud_range(pgd_t *pgd, unsigned long addr,
-		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
+static int vmap_pud_range(pgd_t *pgd, unsigned long addr, unsigned long end,
+		gfp_t gfp_mask, pgprot_t prot, struct page **pages, int *nr)
 {
 	pud_t *pud;
 	unsigned long next;
 
-	pud = pud_alloc(&init_mm, pgd, addr);
+	pud = pud_alloc_gfp(&init_mm, pgd, addr, gfp_mask);
 	if (!pud)
 		return -ENOMEM;
 	do {
 		next = pud_addr_end(addr, end);
-		if (vmap_pmd_range(pud, addr, next, prot, pages, nr))
+		if (vmap_pmd_range(pud, addr, next, gfp_mask, prot, pages, nr))
 			return -ENOMEM;
 	} while (pud++, addr = next, addr != end);
 	return 0;
@@ -156,7 +156,8 @@ static int vmap_pud_range(pgd_t *pgd, unsigned long addr,
  * Ie. pte at addr+N*PAGE_SIZE shall point to pfn corresponding to pages[N]
  */
 static int vmap_page_range_noflush(unsigned long start, unsigned long end,
-				   pgprot_t prot, struct page **pages)
+				   gfp_t gfp_mask, pgprot_t prot,
+				   struct page **pages)
 {
 	pgd_t *pgd;
 	unsigned long next;
@@ -168,7 +169,8 @@ static int vmap_page_range_noflush(unsigned long start, unsigned long end,
 	pgd = pgd_offset_k(addr);
 	do {
 		next = pgd_addr_end(addr, end);
-		err = vmap_pud_range(pgd, addr, next, prot, pages, &nr);
+		err = vmap_pud_range(pgd, addr, next, gfp_mask, prot, pages,
+									&nr);
 		if (err)
 			return err;
 	} while (pgd++, addr = next, addr != end);
@@ -177,11 +179,11 @@ static int vmap_page_range_noflush(unsigned long start, unsigned long end,
 }
 
 static int vmap_page_range(unsigned long start, unsigned long end,
-			   pgprot_t prot, struct page **pages)
+			   gfp_t gfp_mask, pgprot_t prot, struct page **pages)
 {
 	int ret;
 
-	ret = vmap_page_range_noflush(start, end, prot, pages);
+	ret = vmap_page_range_noflush(start, end, gfp_mask, prot, pages);
 	flush_cache_vmap(start, end);
 	return ret;
 }
@@ -1034,28 +1036,29 @@ EXPORT_SYMBOL(vm_unmap_ram);
  *
  * Returns: a pointer to the address that has been mapped, or %NULL on failure
  */
-void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t prot)
+void *vm_map_ram(struct page **pages, unsigned int count, int node,
+					gfp_t gfp_mask, pgprot_t prot)
 {
 	unsigned long size = count << PAGE_SHIFT;
 	unsigned long addr;
 	void *mem;
 
 	if (likely(count <= VMAP_MAX_ALLOC)) {
-		mem = vb_alloc(size, GFP_KERNEL);
+		mem = vb_alloc(size, gfp_mask);
 		if (IS_ERR(mem))
 			return NULL;
 		addr = (unsigned long)mem;
 	} else {
 		struct vmap_area *va;
 		va = alloc_vmap_area(size, PAGE_SIZE,
-				VMALLOC_START, VMALLOC_END, node, GFP_KERNEL);
+				VMALLOC_START, VMALLOC_END, node, gfp_mask);
 		if (IS_ERR(va))
 			return NULL;
 
 		addr = va->va_start;
 		mem = (void *)addr;
 	}
-	if (vmap_page_range(addr, addr + size, prot, pages) < 0) {
+	if (vmap_page_range(addr, addr + size, gfp_mask, prot, pages) < 0) {
 		vm_unmap_ram(mem, count);
 		return NULL;
 	}
@@ -1139,7 +1142,8 @@ void __init vmalloc_init(void)
 int map_kernel_range_noflush(unsigned long addr, unsigned long size,
 			     pgprot_t prot, struct page **pages)
 {
-	return vmap_page_range_noflush(addr, addr + size, prot, pages);
+	return vmap_page_range_noflush(addr, addr + size, GFP_KERNEL, prot,
+									pages);
 }
 
 /**
@@ -1178,13 +1182,14 @@ void unmap_kernel_range(unsigned long addr, unsigned long size)
 	flush_tlb_kernel_range(addr, end);
 }
 
-int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page ***pages)
+int map_vm_area(struct vm_struct *area, gfp_t gfp_mask, pgprot_t prot,
+						struct page ***pages)
 {
 	unsigned long addr = (unsigned long)area->addr;
 	unsigned long end = addr + area->size - PAGE_SIZE;
 	int err;
 
-	err = vmap_page_range(addr, end, prot, *pages);
+	err = vmap_page_range(addr, end, gfp_mask, prot, *pages);
 	if (err > 0) {
 		*pages += err;
 		err = 0;
@@ -1458,7 +1463,7 @@ void *vmap(struct page **pages, unsigned int count,
 	if (!area)
 		return NULL;
 
-	if (map_vm_area(area, prot, &pages)) {
+	if (map_vm_area(area, GFP_KERNEL, prot, &pages)) {
 		vunmap(area->addr);
 		return NULL;
 	}
@@ -1513,7 +1518,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 		area->pages[i] = page;
 	}
 
-	if (map_vm_area(area, prot, &pages))
+	if (map_vm_area(area, gfp_mask, prot, &pages))
 		goto fail;
 	return area->addr;
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
