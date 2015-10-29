Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5EC2F82F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 16:12:42 -0400 (EDT)
Received: by iodd200 with SMTP id d200so58500782iod.0
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 13:12:42 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id x8si4630009igg.87.2015.10.29.13.12.34
        for <linux-mm@kvack.org>;
        Thu, 29 Oct 2015 13:12:34 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [RFC 06/11] mm: add pgoff_mkclean()
Date: Thu, 29 Oct 2015 14:12:10 -0600
Message-Id: <1446149535-16200-7-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1446149535-16200-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1446149535-16200-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>

Introduce pgoff_mkclean() which conceptually is similar to page_mkclean()
except it works in the absence of struct page and it can also be used to
clean PMDs.  This is needed for DAX's dirty page handling.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 include/linux/rmap.h |  5 +++++
 mm/rmap.c            | 53 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 58 insertions(+)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 29446ae..627875f9 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -223,6 +223,11 @@ unsigned long page_address_in_vma(struct page *, struct vm_area_struct *);
 int page_mkclean(struct page *);
 
 /*
+ * Cleans and write protects the PTEs of shared mappings.
+ */
+int pgoff_mkclean(pgoff_t, struct address_space *);
+
+/*
  * called in munlock()/munmap() path to check for other vmas holding
  * the page mlocked.
  */
diff --git a/mm/rmap.c b/mm/rmap.c
index f5b5c1f..0ce16ab 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -586,6 +586,16 @@ vma_address(struct page *page, struct vm_area_struct *vma)
 	return address;
 }
 
+static inline unsigned long
+pgoff_address(pgoff_t pgoff, struct vm_area_struct *vma)
+{
+	unsigned long address;
+
+	address = vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
+	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
+	return address;
+}
+
 #ifdef CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH
 static void percpu_flush_tlb_batch_pages(void *data)
 {
@@ -1040,6 +1050,49 @@ int page_mkclean(struct page *page)
 }
 EXPORT_SYMBOL_GPL(page_mkclean);
 
+int pgoff_mkclean(pgoff_t pgoff, struct address_space *mapping)
+{
+	struct vm_area_struct *vma;
+	int ret = 0;
+
+	i_mmap_lock_read(mapping);
+	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
+		struct mm_struct *mm = vma->vm_mm;
+		pmd_t pmd, *pmdp = NULL;
+		pte_t pte, *ptep = NULL;
+		unsigned long address;
+		spinlock_t *ptl;
+
+		address = pgoff_address(pgoff, vma);
+
+		ret = follow_pte_pmd(mm, address, &ptep, &pmdp, &ptl);
+		if (ret)
+			goto out;
+
+		if (pmdp) {
+			flush_cache_page(vma, address, pmd_pfn(*pmdp));
+			pmd = pmdp_huge_clear_flush(vma, address, pmdp);
+			pmd = pmd_wrprotect(pmd);
+			pmd = pmd_mkclean(pmd);
+			set_pmd_at(mm, address, pmdp, pmd);
+			spin_unlock(ptl);
+		} else {
+			BUG_ON(!ptep);
+			flush_cache_page(vma, address, pte_pfn(*ptep));
+			pte = ptep_clear_flush(vma, address, ptep);
+			pte = pte_wrprotect(pte);
+			pte = pte_mkclean(pte);
+			set_pte_at(mm, address, ptep, pte);
+			pte_unmap_unlock(ptep, ptl);
+		}
+	}
+
+ out:
+	i_mmap_unlock_read(mapping);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(pgoff_mkclean);
+
 /**
  * page_move_anon_rmap - move a page to our anon_vma
  * @page:	the page to move to our anon_vma
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
