From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 2/4] Add replace_page(): change the page pte is pointing to.
Date: Mon, 17 Nov 2008 04:20:30 +0200
Message-Id: <1226888432-3662-3-git-send-email-ieidus@redhat.com>
In-Reply-To: <1226888432-3662-2-git-send-email-ieidus@redhat.com>
References: <1226888432-3662-1-git-send-email-ieidus@redhat.com>
 <1226888432-3662-2-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, dlaor@redhat.com, kamezawa.hiroyu@jp.fujitsu.com, cl@linux-foundation.org, corbet@lwn.net, ieidus@redhat.com
List-ID: <linux-mm.kvack.org>

replace_page() allow changing the mapping of pte from one physical page
into diffrent physical page.

This function is working by removing oldpage from the rmap and calling
put_page on it, and by setting the pte to point into newpage and by
inserting it to the rmap using page_add_file_rmap().

Note: newpage must be non anonymous page, the reason for this is:
replace_page() is built to allow mapping one page into more than one
virtual addresses, the mapping of this page can happen in diffrent
offsets inside each vma, and therefore we cannot trust the page->index
anymore.

The side effect of this issue is that newpage cannot be anything but
kernel allocated page that is not swappable.

Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 include/linux/mm.h |    5 +++
 mm/memory.c        |   80 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 85 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ffee2f7..9e32564 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1207,6 +1207,11 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
 
+#ifdef CONFIG_PAGE_SHARING
+int replace_page(struct vm_area_struct *vma, struct page *oldpage,
+		 struct page *newpage, pte_t orig_pte, pgprot_t prot);
+#endif
+
 struct page *follow_page(struct vm_area_struct *, unsigned long address,
 			unsigned int foll_flags);
 #define FOLL_WRITE	0x01	/* check pte is writable */
diff --git a/mm/memory.c b/mm/memory.c
index 164951c..ac5de33 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1472,6 +1472,86 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 }
 EXPORT_SYMBOL(vm_insert_mixed);
 
+#ifdef CONFIG_PAGE_SHARING
+
+/**
+ * replace_page - replace page in vma with new page
+ * @vma:      vma that hold the pte oldpage is pointed by.
+ * @oldpage:  the page we are replacing with newpage
+ * @newpage:  the page we replace oldpage with
+ * @orig_pte: the original value of the pte
+ * @prot: page protection bits
+ *
+ * Returns 0 on success, -EFAULT on failure.
+ *
+ * Note: @newpage must not be an anonymous page because replace_page() does
+ * not change the mapping of @newpage to have the same values as @oldpage.
+ * @newpage can be mapped in several vmas at different offsets (page->index).
+ */
+int replace_page(struct vm_area_struct *vma, struct page *oldpage,
+		 struct page *newpage, pte_t orig_pte, pgprot_t prot)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *ptep;
+	spinlock_t *ptl;
+	unsigned long addr;
+	int ret;
+
+	BUG_ON(PageAnon(newpage));
+
+	ret = -EFAULT;
+	addr = page_address_in_vma(oldpage, vma);
+	if (addr == -EFAULT)
+		goto out;
+
+	pgd = pgd_offset(mm, addr);
+	if (!pgd_present(*pgd))
+		goto out;
+
+	pud = pud_offset(pgd, addr);
+	if (!pud_present(*pud))
+		goto out;
+
+	pmd = pmd_offset(pud, addr);
+	if (!pmd_present(*pmd))
+		goto out;
+
+	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
+	if (!ptep)
+		goto out;
+
+	if (!pte_same(*ptep, orig_pte)) {
+		pte_unmap_unlock(ptep, ptl);
+		goto out;
+	}
+
+	ret = 0;
+	get_page(newpage);
+	page_add_file_rmap(newpage);
+
+	flush_cache_page(vma, addr, pte_pfn(*ptep));
+	ptep_clear_flush(vma, addr, ptep);
+	set_pte_at(mm, addr, ptep, mk_pte(newpage, prot));
+
+	page_remove_rmap(oldpage, vma);
+	if (PageAnon(oldpage)) {
+		dec_mm_counter(mm, anon_rss);
+		inc_mm_counter(mm, file_rss);
+	}
+	put_page(oldpage);
+
+	pte_unmap_unlock(ptep, ptl);
+
+out:
+	return ret;
+}
+EXPORT_SYMBOL_GPL(replace_page);
+
+#endif
+
 /*
  * maps a range of physical memory into the requested pages. the old
  * mappings are removed. any references to nonexistent pages results
-- 
1.6.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
