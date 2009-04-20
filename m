Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 900EA5F0001
	for <linux-mm@kvack.org>; Sun, 19 Apr 2009 21:36:37 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 4/5] add replace_page(): change the page pte is pointing to.
Date: Mon, 20 Apr 2009 04:36:05 +0300
Message-Id: <1240191366-10029-5-git-send-email-ieidus@redhat.com>
In-Reply-To: <1240191366-10029-4-git-send-email-ieidus@redhat.com>
References: <1240191366-10029-1-git-send-email-ieidus@redhat.com>
 <1240191366-10029-2-git-send-email-ieidus@redhat.com>
 <1240191366-10029-3-git-send-email-ieidus@redhat.com>
 <1240191366-10029-4-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com, Izik Eidus <ieidus@redhat.com>
List-ID: <linux-mm.kvack.org>

replace_page() allow changing the mapping of pte from one physical page
into diffrent physical page.

this function is working by removing oldpage from the rmap and calling
put_page on it, and by setting the pte to point into newpage and by
inserting it to the rmap using page_add_file_rmap().

note: newpage must be non anonymous page, the reason for this is:
replace_page() is built to allow mapping one page into more than one
virtual addresses, the mapping of this page can happen in diffrent
offsets inside each vma, and therefore we cannot trust the page->index
anymore.

the side effect of this issue is that newpage cannot be anything but
kernel allocated page that is not swappable.

Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 include/linux/mm.h |    5 +++
 mm/memory.c        |   80 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 85 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 9a34109..a0ddfb5 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1264,6 +1264,11 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
 
+#if defined(CONFIG_KSM) || defined(CONFIG_KSM_MODULE)
+int replace_page(struct vm_area_struct *vma, struct page *oldpage,
+		 struct page *newpage, pte_t orig_pte, pgprot_t prot);
+#endif
+
 struct page *follow_page(struct vm_area_struct *, unsigned long address,
 			unsigned int foll_flags);
 #define FOLL_WRITE	0x01	/* check pte is writable */
diff --git a/mm/memory.c b/mm/memory.c
index 1e1a14b..d6e53c2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1567,6 +1567,86 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 }
 EXPORT_SYMBOL(vm_insert_mixed);
 
+#if defined(CONFIG_KSM) || defined(CONFIG_KSM_MODULE)
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
+	set_pte_at_notify(mm, addr, ptep, mk_pte(newpage, prot));
+
+	page_remove_rmap(oldpage);
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
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
