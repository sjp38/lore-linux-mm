Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8814A28034A
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 14:53:39 -0400 (EDT)
Received: by iehx8 with SMTP id x8so2775509ieh.3
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 11:53:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id np5si5174991igb.48.2015.07.17.11.53.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 11:53:37 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 06/15] HMM: add HMM page table v3.
Date: Fri, 17 Jul 2015 14:52:16 -0400
Message-Id: <1437159145-6548-7-git-send-email-jglisse@redhat.com>
In-Reply-To: <1437159145-6548-1-git-send-email-jglisse@redhat.com>
References: <1437159145-6548-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>

Heterogeneous memory management main purpose is to mirror a process
address. To do so it must maintain a secondary page table that is
use by the device driver to program the device or build a device
specific page table.

Radix tree can't be use to create this secondary page table because
HMM needs more flags than RADIX_TREE_MAX_TAGS (while this can be
increase we believe HMM will require so much flags that cost will
becomes prohibitive to others users of radix tree).

Moreover radix tree is built around long but for HMM we need to
store dma address and on some platform sizeof(dma_addr_t) is bigger
than sizeof(long). Thus radix tree is unsuitable to fulfill HMM
requirement hence why we introduce this code which allows to create
page table that can grow and shrink dynamicly.

The design is very close to CPU page table as it reuse some of the
feature such as spinlock embedded in struct page.

Changed since v1:
  - Use PAGE_SHIFT as shift value to reserve low bit for private
    device specific flags. This is to allow device driver to use
    and some of the lower bits for their own device specific purpose.
  - Add set of helper for atomically clear, setting and testing bit
    on dma_addr_t pointer. Atomicity being useful only for dirty bit.
  - Differentiate btw DMA mapped entry and non mapped entry (pfn).
  - Split page directory entry and page table entry helpers.

Changed since v2:
  - Rename hmm_pt_iter_update() -> hmm_pt_iter_lookup().
  - Rename hmm_pt_iter_fault() -> hmm_pt_iter_populate().
  - Add hmm_pt_iter_walk()
  - Remove hmm_pt_iter_next() (useless now).
  - Code simplification and improved comments.
  - Fix hmm_pt_fini_directory().

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
---
 MAINTAINERS            |   2 +
 include/linux/hmm_pt.h | 342 ++++++++++++++++++++++++++++
 mm/Makefile            |   2 +-
 mm/hmm_pt.c            | 602 +++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 947 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/hmm_pt.h
 create mode 100644 mm/hmm_pt.c

diff --git a/MAINTAINERS b/MAINTAINERS
index 8ebdc17..f0ffd4c 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4876,6 +4876,8 @@ L:	linux-mm@kvack.org
 S:	Maintained
 F:	mm/hmm.c
 F:	include/linux/hmm.h
+F:	mm/hmm_pt.c
+F:	include/linux/hmm_pt.h
 
 HOST AP DRIVER
 M:	Jouni Malinen <j@w1.fi>
diff --git a/include/linux/hmm_pt.h b/include/linux/hmm_pt.h
new file mode 100644
index 0000000..4a8beb1
--- /dev/null
+++ b/include/linux/hmm_pt.h
@@ -0,0 +1,342 @@
+/*
+ * Copyright 2014 Red Hat Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * Authors: JA(C)rA'me Glisse <jglisse@redhat.com>
+ */
+/*
+ * This provide a set of helpers for HMM page table. See include/linux/hmm.h
+ * for a description of what HMM is.
+ *
+ * HMM page table rely on a locking mecanism similar to CPU page table for page
+ * table update. It use the spinlock embedded inside the struct page to protect
+ * change to page table directory which should minimize lock contention for
+ * concurrent update.
+ *
+ * It does also provide a directory tree protection mechanism. Unlike CPU page
+ * table there is no mmap semaphore to protect directory tree from removal and
+ * this is done intentionaly so that concurrent removal/insertion of directory
+ * inside the tree can happen.
+ *
+ * So anyone walking down the page table must protect directory it traverses so
+ * they are not free by some other thread. This is done by using a reference
+ * counter for each directory. Before traversing a directory a reference is
+ * taken and once traversal is done the reference is drop.
+ *
+ * A directory entry dereference and refcount increment of sub-directory page
+ * must happen in a critical rcu section so that directory page removal can
+ * gracefully wait for all possible other threads that might have dereferenced
+ * the directory.
+ */
+#ifndef _HMM_PT_H
+#define _HMM_PT_H
+
+/*
+ * The HMM page table entry does not reflect any specific hardware. It is just
+ * a common entry format use by HMM internal and expose to HMM user so they can
+ * extract information out of HMM page table.
+ *
+ * Device driver should only rely on the helpers and should not traverse the
+ * page table themself.
+ */
+#define HMM_PT_MAX_LEVEL	6
+
+#define HMM_PDE_VALID_BIT	0
+#define HMM_PDE_VALID		(1 << HMM_PDE_VALID_BIT)
+#define HMM_PDE_PFN_MASK	(~((dma_addr_t)((1 << PAGE_SHIFT) - 1)))
+
+static inline dma_addr_t hmm_pde_from_pfn(dma_addr_t pfn)
+{
+	return (pfn << PAGE_SHIFT) | HMM_PDE_VALID;
+}
+
+static inline unsigned long hmm_pde_pfn(dma_addr_t pde)
+{
+	return (pde & HMM_PDE_VALID) ? pde >> PAGE_SHIFT : 0;
+}
+
+
+/*
+ * The HMM_PTE_VALID_DMA_BIT is set for valid DMA mapped entry, while for pfn
+ * entry the HMM_PTE_VALID_PFN_BIT is set. If the hmm_device is associated with
+ * a valid struct device than device driver will be supplied with DMA mapped
+ * entry otherwise it will be supplied with pfn entry.
+ *
+ * In the first case the device driver must ignore any pfn entry as they might
+ * show as transient state while HMM is mapping the page.
+ */
+#define HMM_PTE_VALID_DMA_BIT	0
+#define HMM_PTE_VALID_PFN_BIT	1
+#define HMM_PTE_WRITE_BIT	2
+#define HMM_PTE_DIRTY_BIT	3
+/*
+ * Reserve some bits for device driver private flags. Note that thus can only
+ * be manipulated using the hmm_pte_*_bit() sets of helpers.
+ *
+ * WARNING ONLY SET/CLEAR THOSE FLAG ON PTE ENTRY THAT HAVE THE VALID BIT SET
+ * AS OTHERWISE ANY BIT SET BY THE DRIVER WILL BE OVERWRITTEN BY HMM.
+ */
+#define HMM_PTE_HW_SHIFT	4
+
+#define HMM_PTE_PFN_MASK	(~((dma_addr_t)((1 << PAGE_SHIFT) - 1)))
+#define HMM_PTE_DMA_MASK	(~((dma_addr_t)((1 << PAGE_SHIFT) - 1)))
+
+
+#ifdef __BIG_ENDIAN
+/*
+ * The dma_addr_t casting we do on little endian do not work on big endian. It
+ * would require some macro trickery to adjust the bit value depending on the
+ * number of bit unsigned long have in comparison to dma_addr_t. This is just
+ * low on the todo list for now.
+ */
+#error "HMM not supported on BIG_ENDIAN architecture.\n"
+#else /* __BIG_ENDIAN */
+static inline void hmm_pte_clear_bit(dma_addr_t *ptep, unsigned char bit)
+{
+	clear_bit(bit, (unsigned long *)ptep);
+}
+
+static inline void hmm_pte_set_bit(dma_addr_t *ptep, unsigned char bit)
+{
+	set_bit(bit, (unsigned long *)ptep);
+}
+
+static inline bool hmm_pte_test_bit(dma_addr_t *ptep, unsigned char bit)
+{
+	return !!test_bit(bit, (unsigned long *)ptep);
+}
+
+static inline bool hmm_pte_test_and_clear_bit(dma_addr_t *ptep,
+					      unsigned char bit)
+{
+	return !!test_and_clear_bit(bit, (unsigned long *)ptep);
+}
+
+static inline bool hmm_pte_test_and_set_bit(dma_addr_t *ptep,
+					    unsigned char bit)
+{
+	return !!test_and_set_bit(bit, (unsigned long *)ptep);
+}
+#endif /* __BIG_ENDIAN */
+
+
+#define HMM_PTE_CLEAR_BIT(name, bit)\
+	static inline void hmm_pte_clear_##name(dma_addr_t *ptep)\
+	{\
+		return hmm_pte_clear_bit(ptep, bit);\
+	}
+
+#define HMM_PTE_SET_BIT(name, bit)\
+	static inline void hmm_pte_set_##name(dma_addr_t *ptep)\
+	{\
+		return hmm_pte_set_bit(ptep, bit);\
+	}
+
+#define HMM_PTE_TEST_BIT(name, bit)\
+	static inline bool hmm_pte_test_##name(dma_addr_t *ptep)\
+	{\
+		return hmm_pte_test_bit(ptep, bit);\
+	}
+
+#define HMM_PTE_TEST_AND_CLEAR_BIT(name, bit)\
+	static inline bool hmm_pte_test_and_clear_##name(dma_addr_t *ptep)\
+	{\
+		return hmm_pte_test_and_clear_bit(ptep, bit);\
+	}
+
+#define HMM_PTE_TEST_AND_SET_BIT(name, bit)\
+	static inline bool hmm_pte_test_and_set_##name(dma_addr_t *ptep)\
+	{\
+		return hmm_pte_test_and_set_bit(ptep, bit);\
+	}
+
+#define HMM_PTE_BIT_HELPER(name, bit)\
+	HMM_PTE_CLEAR_BIT(name, bit)\
+	HMM_PTE_SET_BIT(name, bit)\
+	HMM_PTE_TEST_BIT(name, bit)\
+	HMM_PTE_TEST_AND_CLEAR_BIT(name, bit)\
+	HMM_PTE_TEST_AND_SET_BIT(name, bit)
+
+HMM_PTE_BIT_HELPER(valid_dma, HMM_PTE_VALID_DMA_BIT)
+HMM_PTE_BIT_HELPER(valid_pfn, HMM_PTE_VALID_PFN_BIT)
+HMM_PTE_BIT_HELPER(dirty, HMM_PTE_DIRTY_BIT)
+HMM_PTE_BIT_HELPER(write, HMM_PTE_WRITE_BIT)
+
+static inline dma_addr_t hmm_pte_from_pfn(dma_addr_t pfn)
+{
+	return (pfn << PAGE_SHIFT) | (1 << HMM_PTE_VALID_PFN_BIT);
+}
+
+static inline unsigned long hmm_pte_pfn(dma_addr_t pte)
+{
+	return hmm_pte_test_valid_pfn(&pte) ? pte >> PAGE_SHIFT : 0;
+}
+
+
+/* struct hmm_pt - HMM page table structure.
+ *
+ * @mask: Array of address mask value of each level.
+ * @directory_mask: Mask for directory index (see below).
+ * @last: Last valid address (inclusive).
+ * @pgd: page global directory (top first level of the directory tree).
+ * @lock: Share lock if spinlock_t does not fit in struct page.
+ * @shift: Array of address shift value of each level.
+ * @llevel: Last level.
+ *
+ * The index into each directory for a given address and level is :
+ *   (address >> shift[level]) & directory_mask
+ *
+ * Only hmm_pt.last field needs to be set before calling hmm_pt_init().
+ */
+struct hmm_pt {
+	unsigned long		mask[HMM_PT_MAX_LEVEL];
+	unsigned long		directory_mask;
+	unsigned long		last;
+	dma_addr_t		*pgd;
+	spinlock_t		lock;
+	unsigned char		shift[HMM_PT_MAX_LEVEL];
+	unsigned char		llevel;
+};
+
+int hmm_pt_init(struct hmm_pt *pt);
+void hmm_pt_fini(struct hmm_pt *pt);
+
+static inline unsigned hmm_pt_index(struct hmm_pt *pt,
+				    unsigned long addr,
+				    unsigned level)
+{
+	return (addr >> pt->shift[level]) & pt->directory_mask;
+}
+
+#if USE_SPLIT_PTE_PTLOCKS && !ALLOC_SPLIT_PTLOCKS
+static inline void hmm_pt_directory_lock(struct hmm_pt *pt,
+					 struct page *ptd,
+					 unsigned level)
+{
+	if (level)
+		spin_lock(&ptd->ptl);
+	else
+		spin_lock(&pt->lock);
+}
+
+static inline void hmm_pt_directory_unlock(struct hmm_pt *pt,
+					   struct page *ptd,
+					   unsigned level)
+{
+	if (level)
+		spin_unlock(&ptd->ptl);
+	else
+		spin_unlock(&pt->lock);
+}
+#else /* USE_SPLIT_PTE_PTLOCKS && !ALLOC_SPLIT_PTLOCKS */
+static inline void hmm_pt_directory_lock(struct hmm_pt *pt,
+					 struct page *ptd,
+					 unsigned level)
+{
+	spin_lock(&pt->lock);
+}
+
+static inline void hmm_pt_directory_unlock(struct hmm_pt *pt,
+					   struct page *ptd,
+					   unsigned level)
+{
+	spin_unlock(&pt->lock);
+}
+#endif
+
+static inline void hmm_pt_directory_ref(struct hmm_pt *pt,
+					struct page *ptd)
+{
+	if (!atomic_inc_not_zero(&ptd->_mapcount))
+		/* Illegal this should not happen. */
+		BUG();
+}
+
+static inline void hmm_pt_directory_unref(struct hmm_pt *pt,
+					  struct page *ptd)
+{
+	if (atomic_dec_and_test(&ptd->_mapcount))
+		/* Illegal this should not happen. */
+		BUG();
+
+}
+
+
+/* struct hmm_pt_iter - page table iterator states.
+ *
+ * @ptd: Array of directory struct page pointer for each levels.
+ * @ptdp: Array of pointer to mapped directory levels.
+ * @dead_directories: List of directories that died while walking page table.
+ * @cur: Current address.
+ */
+struct hmm_pt_iter {
+	struct page		*ptd[HMM_PT_MAX_LEVEL - 1];
+	dma_addr_t		*ptdp[HMM_PT_MAX_LEVEL - 1];
+	struct hmm_pt		*pt;
+	struct list_head	dead_directories;
+	unsigned long		cur;
+};
+
+void hmm_pt_iter_init(struct hmm_pt_iter *iter, struct hmm_pt *pt);
+void hmm_pt_iter_fini(struct hmm_pt_iter *iter);
+dma_addr_t *hmm_pt_iter_walk(struct hmm_pt_iter *iter,
+			     unsigned long *addr,
+			     unsigned long *next);
+dma_addr_t *hmm_pt_iter_lookup(struct hmm_pt_iter *iter,
+			       unsigned long addr,
+			       unsigned long *next);
+dma_addr_t *hmm_pt_iter_populate(struct hmm_pt_iter *iter,
+				 unsigned long addr,
+				 unsigned long *next);
+
+/* hmm_pt_protect_directory_ref() - reference current entry directory.
+ *
+ * @iter: Iterator states that currently protect the entry directory.
+ *
+ * This function will reference the current entry directory. Call this when
+ * you add a new valid entry to the entry directory.
+ */
+static inline void hmm_pt_iter_directory_ref(struct hmm_pt_iter *iter)
+{
+	BUG_ON(!iter->ptd[iter->pt->llevel - 1]);
+	hmm_pt_directory_ref(iter->pt, iter->ptd[iter->pt->llevel - 1]);
+}
+
+/* hmm_pt_protect_directory_unref() - unreference current entry directory.
+ *
+ * @iter: Iterator states that currently protect the entry directory.
+ *
+ * This function will unreference the current entry directory. Call this when
+ * you remove a valid entry from the entry directory.
+ */
+static inline void hmm_pt_iter_directory_unref(struct hmm_pt_iter *iter)
+{
+	BUG_ON(!iter->ptd[iter->pt->llevel - 1]);
+	hmm_pt_directory_unref(iter->pt, iter->ptd[iter->pt->llevel - 1]);
+}
+
+static inline void hmm_pt_iter_directory_lock(struct hmm_pt_iter *iter)
+{
+	struct hmm_pt *pt = iter->pt;
+
+	hmm_pt_directory_lock(pt, iter->ptd[pt->llevel - 1], pt->llevel);
+}
+
+static inline void hmm_pt_iter_directory_unlock(struct hmm_pt_iter *iter)
+{
+	struct hmm_pt *pt = iter->pt;
+
+	hmm_pt_directory_unlock(pt, iter->ptd[pt->llevel - 1], pt->llevel);
+}
+
+
+#endif /* _HMM_PT_H */
diff --git a/mm/Makefile b/mm/Makefile
index 90ca9c4..04d7d45 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -78,4 +78,4 @@ obj-$(CONFIG_CMA)	+= cma.o
 obj-$(CONFIG_MEMORY_BALLOON) += balloon_compaction.o
 obj-$(CONFIG_PAGE_EXTENSION) += page_ext.o
 obj-$(CONFIG_CMA_DEBUGFS) += cma_debug.o
-obj-$(CONFIG_HMM) += hmm.o
+obj-$(CONFIG_HMM) += hmm.o hmm_pt.o
diff --git a/mm/hmm_pt.c b/mm/hmm_pt.c
new file mode 100644
index 0000000..9511ce5
--- /dev/null
+++ b/mm/hmm_pt.c
@@ -0,0 +1,602 @@
+/*
+ * Copyright 2014 Red Hat Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * Authors: JA(C)rA'me Glisse <jglisse@redhat.com>
+ */
+/*
+ * This provide a set of helpers for HMM page table. See include/linux/hmm.h
+ * for a description of what HMM is and include/linux/hmm_pt.h.
+ */
+#include <linux/highmem.h>
+#include <linux/slab.h>
+#include <linux/hmm_pt.h>
+
+/* hmm_pt_init() - initialize HMM page table.
+ *
+ * @pt: HMM page table to initialize.
+ *
+ * This function will initialize HMM page table and allocate memory for global
+ * directory. Only the hmm_pt.last fields need to be set prior to calling this
+ * function.
+ */
+int hmm_pt_init(struct hmm_pt *pt)
+{
+	unsigned directory_shift, i = 0, npgd;
+
+	/* Align end address with end of page for current arch. */
+	pt->last |= (PAGE_SIZE - 1);
+	spin_lock_init(&pt->lock);
+	/*
+	 * Directory shift is the number of bits that a single directory level
+	 * represent. For instance if PAGE_SIZE is 4096 and each entry takes 8
+	 * bytes (sizeof(dma_addr_t) == 8) then directory_shift = 9.
+	 */
+	directory_shift = PAGE_SHIFT - ilog2(sizeof(dma_addr_t));
+	/*
+	 * Level 0 is the root level of the page table. It might use less
+	 * bits than directory_shift but all sub-directory level will use all
+	 * directory_shift bits.
+	 *
+	 * For instance if hmm_pt.last == (1 << 48) - 1, PAGE_SHIFT == 12 and
+	 * sizeof(dma_addr_t) == 8 then :
+	 *   directory_shift = 9
+	 *   shift[0] = 39
+	 *   shift[1] = 30
+	 *   shift[2] = 21
+	 *   shift[3] = 12
+	 *   llevel = 3
+	 *
+	 * Note that shift[llevel] == PAGE_SHIFT because the last level
+	 * correspond to the page table entry level (ignoring the case of huge
+	 * page).
+	 */
+	pt->shift[0] = ((__fls(pt->last >> PAGE_SHIFT) / directory_shift) *
+			directory_shift) + PAGE_SHIFT;
+	while (pt->shift[i++] > PAGE_SHIFT)
+		pt->shift[i] = pt->shift[i - 1] - directory_shift;
+	pt->llevel = i - 1;
+	pt->directory_mask = (1 << directory_shift) - 1;
+
+	for (i = 0; i <= pt->llevel; ++i)
+		pt->mask[i] = ~((1UL << pt->shift[i]) - 1);
+
+	npgd = (pt->last >> pt->shift[0]) + 1;
+	pt->pgd = kcalloc(npgd, sizeof(dma_addr_t), GFP_KERNEL);
+	if (!pt->pgd)
+		return -ENOMEM;
+
+	return 0;
+}
+EXPORT_SYMBOL(hmm_pt_init);
+
+static void hmm_pt_fini_directory(struct hmm_pt *pt,
+				  struct page *ptd,
+				  unsigned level)
+{
+	dma_addr_t *ptdp;
+	unsigned i;
+
+	if (level == pt->llevel)
+		return;
+
+	ptdp = kmap(ptd);
+	for (i = 0; i <= pt->directory_mask; ++i) {
+		struct page *lptd;
+
+		if (!(ptdp[i] & HMM_PDE_VALID))
+			continue;
+		lptd = pfn_to_page(hmm_pde_pfn(ptdp[i]));
+		ptdp[i] = 0;
+		hmm_pt_fini_directory(pt, lptd, level + 1);
+		atomic_set(&lptd->_mapcount, -1);
+		__free_page(lptd);
+	}
+	kunmap(ptd);
+}
+
+/* hmm_pt_fini() - finalize HMM page table.
+ *
+ * @pt: HMM page table to finalize.
+ *
+ * This function will free all resources of a directory page table.
+ */
+void hmm_pt_fini(struct hmm_pt *pt)
+{
+	unsigned i;
+
+	/* Free all directory. */
+	for (i = 0; i <= (pt->last >> pt->shift[0]); ++i) {
+		struct page *ptd;
+
+		if (!(pt->pgd[i] & HMM_PDE_VALID))
+			continue;
+		ptd = pfn_to_page(hmm_pde_pfn(pt->pgd[i]));
+		pt->pgd[i] = 0;
+		hmm_pt_fini_directory(pt, ptd, 1);
+		atomic_set(&ptd->_mapcount, -1);
+		__free_page(ptd);
+	}
+
+	kfree(pt->pgd);
+	pt->pgd = NULL;
+}
+EXPORT_SYMBOL(hmm_pt_fini);
+
+/* hmm_pt_level_start() - Start (inclusive) address of directory at given level
+ *
+ * @pt: HMM page table.
+ * @addr: Address for which to get the directory start address.
+ * @level: Directory level.
+ *
+ * This return the start address of directory at given level for a given
+ * address. So using usual x86-64 example with :
+ *   (hmm_pt.last == (1 << 48) - 1, PAGE_SHIFT == 12, sizeof(dma_addr_t) == 8)
+ * We have :
+ *   llevel = 3 (which is the page table entry level)
+ *   shift[0] = 39  mask[0] = ~((1 << 39) - 1)
+ *   shift[1] = 30  mask[1] = ~((1 << 30) - 1)
+ *   shift[2] = 21  mask[2] = ~((1 << 21) - 1)
+ *   shift[3] = 12  mask[3] = ~((1 << 12) - 1)
+ * Which gives :
+ *   start = hmm_pt_level_start(pt, addr, 3)
+ *         = addr & pt->mask[3 - 1]
+ *         = addr & ~((1 << 21) - 1)
+ */
+static inline unsigned long hmm_pt_level_start(struct hmm_pt *pt,
+					       unsigned long addr,
+					       unsigned level)
+{
+	return level ? addr & pt->mask[level - 1] : 0;
+}
+
+/* hmm_pt_level_end() - End address (inclusive) of directory at given level.
+ *
+ * @pt: HMM page table.
+ * @addr: Address for which to get the directory end address.
+ * @level: Directory level.
+ *
+ * This return the start address of directory at given level for a given
+ * address. So using usual x86-64 example with :
+ *   (hmm_pt.last == (1 << 48) - 1, PAGE_SHIFT == 12, sizeof(dma_addr_t) == 8)
+ * We have :
+ *   llevel = 3 (which is the page table entry level)
+ *   shift[0] = 39  mask[0] = ~((1 << 39) - 1)
+ *   shift[1] = 30  mask[1] = ~((1 << 30) - 1)
+ *   shift[2] = 21  mask[2] = ~((1 << 21) - 1)
+ *   shift[3] = 12  mask[3] = ~((1 << 12) - 1)
+ * Which gives :
+ *   start = hmm_pt_level_end(pt, addr, 3)
+ *         = addr | ~pt->mask[3 - 1]
+ *         = addr | ((1 << 21) - 1)
+ */
+static inline unsigned long hmm_pt_level_end(struct hmm_pt *pt,
+					     unsigned long addr,
+					     unsigned level)
+{
+	return level ? (addr | (~pt->mask[level - 1])) : pt->last;
+}
+
+static inline dma_addr_t *hmm_pt_iter_ptdp(struct hmm_pt_iter *iter,
+					   unsigned long addr)
+{
+	struct hmm_pt *pt = iter->pt;
+
+	BUG_ON(!iter->ptd[pt->llevel - 1] ||
+	       addr < hmm_pt_level_start(pt, iter->cur, pt->llevel) ||
+	       addr > hmm_pt_level_end(pt, iter->cur, pt->llevel));
+	return &iter->ptdp[pt->llevel - 1][hmm_pt_index(pt, addr, pt->llevel)];
+}
+
+/* hmm_pt_iter_init() - initialize iterator states.
+ *
+ * @iter: Iterator states.
+ *
+ * This function will initialize iterator states. It must always be pair with a
+ * call to hmm_pt_iter_fini().
+ */
+void hmm_pt_iter_init(struct hmm_pt_iter *iter, struct hmm_pt *pt)
+{
+	iter->pt = pt;
+	memset(iter->ptd, 0, sizeof(iter->ptd));
+	memset(iter->ptdp, 0, sizeof(iter->ptdp));
+	INIT_LIST_HEAD(&iter->dead_directories);
+}
+EXPORT_SYMBOL(hmm_pt_iter_init);
+
+/* hmm_pt_iter_directory_unref_safe() - unref a directory that is safe to free.
+ *
+ * @iter: Iterator states.
+ * @pt: HMM page table.
+ * @level: Level of the directory to unref.
+ *
+ * This function will unreference a directory and add it to dead list if
+ * directory no longer have any reference. It will also clear the entry to
+ * that directory into the upper level directory as well as dropping ref
+ * on the upper directory.
+ */
+static void hmm_pt_iter_directory_unref_safe(struct hmm_pt_iter *iter,
+					     unsigned level)
+{
+	struct page *upper_ptd;
+	dma_addr_t *upper_ptdp;
+
+	/* Nothing to do for root level. */
+	if (!level)
+		return;
+
+	if (!atomic_dec_and_test(&iter->ptd[level - 1]->_mapcount))
+		return;
+
+	upper_ptd = level > 1 ? iter->ptd[level - 2] : NULL;
+	upper_ptdp = level > 1 ? iter->ptdp[level - 2] : iter->pt->pgd;
+	upper_ptdp = &upper_ptdp[hmm_pt_index(iter->pt, iter->cur, level - 1)];
+	hmm_pt_directory_lock(iter->pt, upper_ptd, level - 1);
+	/*
+	 * There might be race btw decrementing reference count on a directory
+	 * and another thread trying to fault in a new directory. To avoid
+	 * erasing the new directory entry we need to check that the entry
+	 * still correspond to the directory we are removing.
+	 */
+	if (hmm_pde_pfn(*upper_ptdp) == page_to_pfn(iter->ptd[level - 1]))
+		*upper_ptdp = 0;
+	hmm_pt_directory_unlock(iter->pt, upper_ptd, level - 1);
+
+	/* Add it to delayed free list. */
+	list_add_tail(&iter->ptd[level - 1]->lru, &iter->dead_directories);
+
+	/*
+	 * The upper directory is now safe to unref as we have an extra ref and
+	 * thus refcount should not reach 0.
+	 */
+	hmm_pt_directory_unref(iter->pt, iter->ptd[level - 2]);
+}
+
+static void hmm_pt_iter_unprotect_directory(struct hmm_pt_iter *iter,
+					    unsigned level)
+{
+	if (!iter->ptd[level - 1])
+		return;
+	kunmap(iter->ptd[level - 1]);
+	hmm_pt_iter_directory_unref_safe(iter, level);
+	iter->ptd[level - 1] = NULL;
+}
+
+/* hmm_pt_iter_protect_directory() - protect a directory.
+ *
+ * @iter: Iterator states.
+ * @ptd: directory struct page to protect.
+ * @addr: Address of the directory.
+ * @level: Level of this directory (> 0).
+ * Returns -EINVAL on error, 1 if protection succeeded, 0 otherwise.
+ *
+ * This function will proctect a directory by taking a reference. It will also
+ * map the directory to allow cpu access.
+ *
+ * Call to this function must be made from inside the rcu read critical section
+ * that convert the table entry to the directory struct page. Doing so allow to
+ * support concurrent removal of directory because this function will take the
+ * reference inside the rcu critical section and thus rcu synchronization will
+ * garanty that we can safely free directory.
+ */
+static int hmm_pt_iter_protect_directory(struct hmm_pt_iter *iter,
+					 struct page *ptd,
+					 unsigned long addr,
+					 unsigned level)
+{
+	/* This must be call inside rcu read section. */
+	BUG_ON(!rcu_read_lock_held());
+
+	if (!level || iter->ptd[level - 1]) {
+		rcu_read_unlock();
+		return -EINVAL;
+	}
+
+	if (!atomic_inc_not_zero(&ptd->_mapcount)) {
+		rcu_read_unlock();
+		return 0;
+	}
+
+	rcu_read_unlock();
+
+	iter->ptd[level - 1] = ptd;
+	iter->ptdp[level - 1] = kmap(ptd);
+	iter->cur = addr;
+
+	return 1;
+}
+
+/* hmm_pt_iter_walk() - Walk page table for a valid entry directory.
+ *
+ * @iter: Iterator states.
+ * @addr: Start address of the range, return address of the entry directory.
+ * @next: End address of the range, return address of next directory.
+ * Returns Entry directory pointer and associated address if a valid entry
+ * directory exist in the range, or NULL and empty (*addr=*next) range
+ * otherwise.
+ *
+ * This function will return the first valid entry directory over a range of
+ * address. It update the addr parameter with the entry address and the next
+ * parameter with the address of the end of that directory. So device driver
+ * can do :
+ *
+ * for (addr = start; addr < end;) {
+ *   unsigned long next = end;
+ *
+ *   for (ptep=hmm_pt_iter_walk(iter, &addr, &next); ptep; addr + PAGE_SIZE) {
+ *     // Use ptep
+ *     ptep++;
+ *   }
+ * }
+ */
+dma_addr_t *hmm_pt_iter_walk(struct hmm_pt_iter *iter,
+			     unsigned long *addr,
+			     unsigned long *next)
+{
+	struct hmm_pt *pt = iter->pt;
+	int i;
+
+	*addr &= PAGE_MASK;
+
+	if (iter->ptd[pt->llevel - 1] &&
+	    *addr >= hmm_pt_level_start(pt, iter->cur, pt->llevel) &&
+	    *addr <= hmm_pt_level_end(pt, iter->cur, pt->llevel)) {
+		*next = min(*next, hmm_pt_level_end(pt, *addr, pt->llevel)+1);
+		return hmm_pt_iter_ptdp(iter, *addr);
+	}
+
+again:
+	/* First unprotect any directory that do not cover the address. */
+	for (i = pt->llevel; i >= 1; --i) {
+		if (!iter->ptd[i - 1])
+			continue;
+		if (*addr >= hmm_pt_level_start(pt, iter->cur, i) &&
+		    *addr <= hmm_pt_level_end(pt, iter->cur, i))
+			break;
+		hmm_pt_iter_unprotect_directory(iter, i);
+	}
+
+	/* Walk down to last level of the directory tree. */
+	for (; i < pt->llevel; ++i) {
+		struct page *ptd;
+		dma_addr_t pte, *ptdp;
+
+		rcu_read_lock();
+		ptdp = i ? iter->ptdp[i - 1] : pt->pgd;
+		pte = ACCESS_ONCE(ptdp[hmm_pt_index(pt, *addr, i)]);
+		if (!(pte & HMM_PDE_VALID)) {
+			rcu_read_unlock();
+			*addr = hmm_pt_level_end(pt, iter->cur, i) + 1;
+			if (*addr > *next) {
+				*addr = *next;
+				return NULL;
+			}
+			goto again;
+		}
+		ptd = pfn_to_page(hmm_pde_pfn(pte));
+		/* RCU read unlock inside hmm_pt_iter_protect_directory(). */
+		if (hmm_pt_iter_protect_directory(iter, ptd,
+						  *addr, i + 1) != 1) {
+			if (*addr > *next) {
+				*addr = *next;
+				return NULL;
+			}
+			goto again;
+		}
+	}
+
+	*next = min(*next, hmm_pt_level_end(pt, *addr, pt->llevel) + 1);
+	return hmm_pt_iter_ptdp(iter, *addr);
+}
+EXPORT_SYMBOL(hmm_pt_iter_walk);
+
+/* hmm_pt_iter_lookup() - Lookup entry directory for an address.
+ *
+ * @iter: Iterator states.
+ * @addr: Address of the entry directory to lookup.
+ * @next: End address up to which the entry directory is valid.
+ * Returns Entry directory pointer and its end address.
+ *
+ * This function will return the entry directory pointer for a given address as
+ * well as the end address of that directory (address of the next directory).
+ * Use patern is :
+ *
+ * for (addr = start; addr < end;) {
+ *   unsigned long next;
+ *
+ *   for (ptep=hmm_pt_iter_lookup(iter, addr, &next); ptep; addr+=PAGE_SIZE) {
+ *     // Use ptep
+ *     ptep++;
+ *   }
+ * }
+ */
+dma_addr_t *hmm_pt_iter_lookup(struct hmm_pt_iter *iter,
+			       unsigned long addr,
+			       unsigned long *next)
+{
+	struct hmm_pt *pt = iter->pt;
+	int i;
+
+	addr &= PAGE_MASK;
+
+	if (iter->ptd[pt->llevel - 1] &&
+	    addr >= hmm_pt_level_start(pt, iter->cur, pt->llevel) &&
+	    addr <= hmm_pt_level_end(pt, iter->cur, pt->llevel)) {
+		*next = min(*next, hmm_pt_level_end(pt, addr, pt->llevel) + 1);
+		return hmm_pt_iter_ptdp(iter, addr);
+	}
+
+	/* First unprotect any directory that do not cover the address. */
+	for (i = pt->llevel; i >= 1; --i) {
+		if (!iter->ptd[i - 1])
+			continue;
+		if (addr >= hmm_pt_level_start(pt, iter->cur, i) &&
+		    addr <= hmm_pt_level_end(pt, iter->cur, i))
+			break;
+		hmm_pt_iter_unprotect_directory(iter, i);
+	}
+
+	/* Walk down to last level of the directory tree. */
+	for (; i < pt->llevel; ++i) {
+		struct page *ptd;
+		dma_addr_t pte, *ptdp;
+
+		rcu_read_lock();
+		ptdp = i ? iter->ptdp[i - 1] : pt->pgd;
+		pte = ACCESS_ONCE(ptdp[hmm_pt_index(pt, addr, i)]);
+		if (!(pte & HMM_PDE_VALID)) {
+			rcu_read_unlock();
+			*next = min(*next,
+				    hmm_pt_level_end(pt, iter->cur, i) + 1);
+			return NULL;
+		}
+		ptd = pfn_to_page(hmm_pde_pfn(pte));
+		/* RCU read unlock inside hmm_pt_iter_protect_directory(). */
+		if (hmm_pt_iter_protect_directory(iter, ptd, addr, i + 1) != 1) {
+			*next = min(*next,
+				    hmm_pt_level_end(pt, iter->cur, i) + 1);
+			return NULL;
+		}
+	}
+
+	*next = min(*next, hmm_pt_level_end(pt, addr, pt->llevel) + 1);
+	return hmm_pt_iter_ptdp(iter, addr);
+}
+EXPORT_SYMBOL(hmm_pt_iter_lookup);
+
+/* hmm_pt_iter_populate() - Allocate entry directory for an address.
+ *
+ * @iter: Iterator states.
+ * @addr: Address of the entry directory to lookup.
+ * @next: End address up to which the entry directory is valid.
+ * Returns Entry directory pointer and its end address.
+ *
+ * This function will return the entry directory pointer (and allocate a new
+ * one if none exist) for a given address as well as the end address of that
+ * directory (address of the next directory). Use patern is :
+ *
+ * for (addr = start; addr < end;) {
+ *   unsigned long next;
+ *
+ *   ptep = hmm_pt_iter_populate(iter,addr,&next);
+ *   if (!ptep) {
+ *     // error handling.
+ *   }
+ *   for (; addr < next; addr += PAGE_SIZE, ptep++) {
+ *     // Use ptep
+ *   }
+ * }
+ */
+dma_addr_t *hmm_pt_iter_populate(struct hmm_pt_iter *iter,
+				 unsigned long addr,
+				 unsigned long *next)
+{
+	dma_addr_t *ptdp = hmm_pt_iter_lookup(iter, addr, next);
+	struct hmm_pt *pt = iter->pt;
+	struct page *new = NULL;
+	int i;
+
+	if (ptdp)
+		return ptdp;
+
+	/* Populate directory tree structures. */
+	for (i = 1, iter->cur = addr; i <= pt->llevel; ++i) {
+		struct page *upper_ptd;
+		dma_addr_t *upper_ptdp;
+
+		if (iter->ptd[i - 1])
+			continue;
+
+		new = new ? new : alloc_page(GFP_HIGHUSER | __GFP_ZERO);
+		if (!new)
+			return NULL;
+
+		upper_ptd = i > 1 ? iter->ptd[i - 2] : NULL;
+		upper_ptdp = i > 1 ? iter->ptdp[i - 2] : pt->pgd;
+		upper_ptdp = &upper_ptdp[hmm_pt_index(pt, addr, i - 1)];
+		hmm_pt_directory_lock(pt, upper_ptd, i - 1);
+		if (((*upper_ptdp) & HMM_PDE_VALID)) {
+			struct page *ptd;
+
+			ptd = pfn_to_page(hmm_pde_pfn(*upper_ptdp));
+			if (atomic_inc_not_zero(&ptd->_mapcount)) {
+				/* Already allocated by another thread. */
+				iter->ptd[i - 1] = ptd;
+				hmm_pt_directory_unlock(pt, upper_ptd, i - 1);
+				iter->ptdp[i - 1] = kmap(ptd);
+				continue;
+			}
+			/*
+			 * Means we raced with removal of dead directory it is
+			 * safe to overwritte *upper_ptdp entry with new entry.
+			 */
+		}
+		/* Initialize struct page field for the directory. */
+		atomic_set(&new->_mapcount, 1);
+#if USE_SPLIT_PTE_PTLOCKS && !ALLOC_SPLIT_PTLOCKS
+		spin_lock_init(&new->ptl);
+#endif
+		*upper_ptdp = hmm_pde_from_pfn(page_to_pfn(new));
+		/* The pgd level is not refcounted. */
+		if (i > 1)
+			hmm_pt_directory_ref(pt, iter->ptd[i - 2]);
+		/* Unlock upper directory and map the new directory. */
+		hmm_pt_directory_unlock(pt, upper_ptd, i - 1);
+		iter->ptd[i - 1] = new;
+		iter->ptdp[i - 1] = kmap(new);
+		new = NULL;
+	}
+	if (new)
+		__free_page(new);
+	*next = min(*next, hmm_pt_level_end(pt, addr, pt->llevel) + 1);
+	return hmm_pt_iter_ptdp(iter, addr);
+}
+EXPORT_SYMBOL(hmm_pt_iter_populate);
+
+/* hmm_pt_iter_fini() - finalize iterator.
+ *
+ * @iter: Iterator states.
+ * @pt: HMM page table.
+ *
+ * This function will cleanup iterator by unmapping and unreferencing any
+ * directory still mapped and referenced. It will also free any dead directory.
+ */
+void hmm_pt_iter_fini(struct hmm_pt_iter *iter)
+{
+	struct page *ptd, *tmp;
+	unsigned i;
+
+	for (i = iter->pt->llevel; i >= 1; --i) {
+		if (!iter->ptd[i - 1])
+			continue;
+		hmm_pt_iter_unprotect_directory(iter, i);
+	}
+
+	/* Avoid useless synchronize_rcu() if there is no directory to free. */
+	if (list_empty(&iter->dead_directories))
+		return;
+
+	/*
+	 * Some iterator may have dereferenced a dead directory entry and looked
+	 * up the struct page but haven't check yet the reference count. As all
+	 * the above happen in rcu read critical section we know that we need
+	 * to wait for grace period before being able to free any of the dead
+	 * directory page.
+	 */
+	synchronize_rcu();
+	list_for_each_entry_safe(ptd, tmp, &iter->dead_directories, lru) {
+		list_del(&ptd->lru);
+		atomic_set(&ptd->_mapcount, -1);
+		__free_page(ptd);
+	}
+}
+EXPORT_SYMBOL(hmm_pt_iter_fini);
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
