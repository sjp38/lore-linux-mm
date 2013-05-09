Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 72CB66B0062
	for <linux-mm@kvack.org>; Thu,  9 May 2013 05:51:10 -0400 (EDT)
Received: by mail-oa0-f46.google.com with SMTP id h2so3166511oag.5
        for <linux-mm@kvack.org>; Thu, 09 May 2013 02:51:09 -0700 (PDT)
From: wenchaolinux@gmail.com
Subject: [RFC PATCH V1 2/6] mm : allow copy between different addresses for copy_one_pte()
Date: Thu,  9 May 2013 17:50:07 +0800
Message-Id: <1368093011-4867-3-git-send-email-wenchaolinux@gmail.com>
In-Reply-To: <1368093011-4867-1-git-send-email-wenchaolinux@gmail.com>
References: <1368093011-4867-1-git-send-email-wenchaolinux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mgorman@suse.de, hughd@google.com, walken@google.com, viro@zeniv.linux.org.uk, kirill.shutemov@linux.intel.com, xiaoguangrong@linux.vnet.ibm.com, anthony@codemonkey.ws, stefanha@gmail.com, Wenchao Xia <wenchaolinux@gmail.com>

From: Wenchao Xia <wenchaolinux@gmail.com>

This function now can be used in pte copy in same process with
different addresses. It is also exported.

Signed-off-by: Wenchao Xia <wenchaolinux@gmail.com>
---
 include/linux/mm.h |    4 ++++
 mm/memory.c        |   27 ++++++++++++++-------------
 2 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7acc9dc..68f52bc 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -963,6 +963,10 @@ int walk_page_range(unsigned long addr, unsigned long end,
 		struct mm_walk *walk);
 void free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 		unsigned long end, unsigned long floor, unsigned long ceiling);
+unsigned long copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+			   pte_t *dst_pte, pte_t *src_pte,
+			   unsigned long dst_addr, unsigned long src_addr,
+			   struct vm_area_struct *vma, int *rss);
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma);
 void unmap_mapping_range(struct address_space *mapping,
diff --git a/mm/memory.c b/mm/memory.c
index 494526a..0357cf1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -824,15 +824,15 @@ out:
 }
 
 /*
- * copy one vm_area from one task to the other. Assumes the page tables
- * already present in the new task to be cleared in the whole range
- * covered by this vma.
+ * copy one pte from @src_addr to @dst_addr. Assumes the page tables and vma
+ * already present in the @dst_addr, @src_addr and @src_pte is covered by
+ * @vma, @rss is a array of size NR_MM_COUNTERS used by caller to sync. dst_mm
+ * may be equal to src_mm. Return 0 or swap entry value.
  */
-
-static inline unsigned long
-copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		pte_t *dst_pte, pte_t *src_pte, struct vm_area_struct *vma,
-		unsigned long addr, int *rss)
+unsigned long copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+			   pte_t *dst_pte, pte_t *src_pte,
+			   unsigned long dst_addr, unsigned long src_addr,
+			   struct vm_area_struct *vma, int *rss)
 {
 	unsigned long vm_flags = vma->vm_flags;
 	pte_t pte = *src_pte;
@@ -872,7 +872,8 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 					 */
 					make_migration_entry_read(&entry);
 					pte = swp_entry_to_pte(entry);
-					set_pte_at(src_mm, addr, src_pte, pte);
+					set_pte_at(src_mm, src_addr,
+						   src_pte, pte);
 				}
 			}
 		}
@@ -884,7 +885,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	 * in the parent and the child
 	 */
 	if (is_cow_mapping(vm_flags)) {
-		ptep_set_wrprotect(src_mm, addr, src_pte);
+		ptep_set_wrprotect(src_mm, src_addr, src_pte);
 		pte = pte_wrprotect(pte);
 	}
 
@@ -896,7 +897,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		pte = pte_mkclean(pte);
 	pte = pte_mkold(pte);
 
-	page = vm_normal_page(vma, addr, pte);
+	page = vm_normal_page(vma, src_addr, pte);
 	if (page) {
 		get_page(page);
 		page_dup_rmap(page);
@@ -907,7 +908,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	}
 
 out_set_pte:
-	set_pte_at(dst_mm, addr, dst_pte, pte);
+	set_pte_at(dst_mm, dst_addr, dst_pte, pte);
 	return 0;
 }
 
@@ -951,7 +952,7 @@ again:
 			continue;
 		}
 		entry.val = copy_one_pte(dst_mm, src_mm, dst_pte, src_pte,
-							vma, addr, rss);
+						addr, addr, vma, rss);
 		if (entry.val)
 			break;
 		progress += 8;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
