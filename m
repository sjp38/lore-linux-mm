Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 65C056B0078
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 15:06:49 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id p10so936525pdj.12
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 12:06:49 -0800 (PST)
Received: from psmtp.com ([74.125.245.108])
        by mx.google.com with SMTP id rz1si830158pab.101.2013.11.19.12.06.47
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 12:06:48 -0800 (PST)
From: Thomas Hellstrom <thellstrom@vmware.com>
Subject: [PATCH RFC 3/3] mm: Add mkclean_mapping_range()
Date: Tue, 19 Nov 2013 12:06:16 -0800
Message-Id: <1384891576-7851-4-git-send-email-thellstrom@vmware.com>
In-Reply-To: <1384891576-7851-1-git-send-email-thellstrom@vmware.com>
References: <1384891576-7851-1-git-send-email-thellstrom@vmware.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: linux-graphics-maintainer@vmware.com, Thomas Hellstrom <thellstrom@vmware.com>

A general function to clean (Mark non-writeable and non-dirty) all ptes
pointing to a certain range in an address space.
Although it is primarily intended for PFNMAP and MIXEDMAP vmas, AFAICT
it should work on address spaces backed by normal pages as well.
It will not clean COW'd pages and it will not work with nonlinear VMAs.

Signed-off-by: Thomas Hellstrom <thellstrom@vmware.com>
---
 include/linux/mm.h |    3 ++
 mm/memory.c        |  108 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 111 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 23d1791..e6bf5b3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -982,6 +982,9 @@ int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma);
 void unmap_mapping_range(struct address_space *mapping,
 		loff_t const holebegin, loff_t const holelen, int even_cows);
+void mkclean_mapping_range(struct address_space *mapping,
+			   pgoff_t pg_clean_begin,
+			   pgoff_t pg_len);
 int follow_pfn(struct vm_area_struct *vma, unsigned long address,
 	unsigned long *pfn);
 int follow_phys(struct vm_area_struct *vma, unsigned long address,
diff --git a/mm/memory.c b/mm/memory.c
index 79178c2..f7a48f5 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4395,3 +4395,111 @@ void copy_user_huge_page(struct page *dst, struct page *src,
 	}
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */
+
+struct mkclean_data {
+	struct mmu_gather tlb;
+	struct vm_area_struct *vma;
+};
+
+static int mkclean_mapping_pte(pte_t *pte, pgtable_t token, unsigned long addr,
+			       void *data)
+{
+	struct mkclean_data *md = data;
+	struct mm_struct *mm = md->vma->vm_mm;
+
+	pte_t ptent = *pte;
+
+	if (pte_none(ptent) || !pte_present(ptent))
+		return 0;
+
+	if (pte_dirty(ptent) || pte_write(ptent)) {
+		struct page *page = vm_normal_page(md->vma, addr, ptent);
+
+		/*
+		 * Don't clean COW'ed pages
+		 */
+		if (page && PageAnon(page))
+			return 0;
+
+		tlb_remove_tlb_entry((&md->tlb), pte, addr);
+		ptent = pte_wrprotect(ptent);
+		ptent = pte_mkclean(ptent);
+		set_pte_at(mm, addr, pte, ptent);
+	}
+
+	return 0;
+}
+
+static void mkclean_mapping_range_tree(struct rb_root *root,
+				       pgoff_t first,
+				       pgoff_t last)
+{
+	struct vm_area_struct *vma;
+
+	vma_interval_tree_foreach(vma, root, first, last) {
+		struct mkclean_data md;
+		pgoff_t vba, vea, zba, zea;
+		struct mm_struct *mm;
+		unsigned long addr, end;
+
+		BUG_ON(vma->vm_flags & VM_NONLINEAR);
+
+		if (!(vma->vm_flags & VM_SHARED))
+			continue;
+
+		mm = vma->vm_mm;
+		vba = vma->vm_pgoff;
+		vea = vba + vma_pages(vma) - 1;
+		zba = (first < vba) ? vba : first;
+		zea = (last > vea) ? vea : last;
+
+		addr = ((zba - vba) << PAGE_SHIFT) + vma->vm_start;
+		end = ((zea - vba + 1) << PAGE_SHIFT) + vma->vm_start;
+
+		tlb_gather_mmu(&md.tlb, mm, addr, end);
+		md.vma = vma;
+
+		mmu_notifier_invalidate_range_start(mm, addr, end);
+		tlb_start_vma(&md.tlb, vma);
+
+		(void) apply_to_pt_range(mm, addr, end - addr,
+					 mkclean_mapping_pte,
+					 &md, false);
+
+		tlb_end_vma(&md.tlb, vma);
+		mmu_notifier_invalidate_range_end(mm, addr, end);
+
+		tlb_finish_mmu(&md.tlb, addr, end);
+	}
+}
+
+/*
+ * mkclean_mapping_range - Clean all PTEs pointing to a given range of an
+ * address space.
+ *
+ * @mapping: Pointer to the address space
+ * @pg_clean_begin: Page offset into the address space where cleaning should
+ * start
+ * @pg_len: Length of the range to be cleaned
+ *
+ * This function walks all vmas pointing to a given range of an address space,
+ * marking PTEs clean, unless they are COW'ed. This implies that we only
+ * touch VMAs with the flag VM_SHARED set. This interface also doesn't
+ * support VM_NONLINEAR vmas since there is no general way for us to
+ * make sure a pte is actually pointing into the given address space range
+ * for such VMAs.
+ */
+void mkclean_mapping_range(struct address_space *mapping,
+			   pgoff_t pg_clean_begin,
+			   pgoff_t pg_len)
+{
+	pgoff_t last = pg_clean_begin + pg_len - 1UL;
+
+	mutex_lock(&mapping->i_mmap_mutex);
+	WARN_ON(!list_empty(&mapping->i_mmap_nonlinear));
+	if (!RB_EMPTY_ROOT(&mapping->i_mmap))
+		mkclean_mapping_range_tree(&mapping->i_mmap, pg_clean_begin,
+					   last);
+	mutex_unlock(&mapping->i_mmap_mutex);
+}
+EXPORT_SYMBOL_GPL(mkclean_mapping_range);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
