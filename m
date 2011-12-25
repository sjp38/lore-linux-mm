Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id A69D96B004F
	for <linux-mm@kvack.org>; Sun, 25 Dec 2011 15:46:03 -0500 (EST)
Message-ID: <4EF78B85.6070909@parallels.com>
Date: Mon, 26 Dec 2011 00:45:57 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH 1/3] mincore: Introduce named constant for existing bit
References: <4EF78B6A.8020904@parallels.com>
In-Reply-To: <4EF78B6A.8020904@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>


Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/mman.h |    2 ++
 mm/huge_memory.c     |    2 +-
 mm/mincore.c         |   10 +++++-----
 3 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/linux/mman.h b/include/linux/mman.h
index 8b74e9b..e4fda1e 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -10,6 +10,8 @@
 #define OVERCOMMIT_ALWAYS		1
 #define OVERCOMMIT_NEVER		2
 
+#define MINCORE_RESIDENT	0x1
+
 #ifdef __KERNEL__
 #include <linux/mm.h>
 #include <linux/percpu_counter.h>
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 36b3d98..4f87067 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1045,7 +1045,7 @@ int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			 * All logical pages in the range are present
 			 * if backed by a huge page.
 			 */
-			memset(vec, 1, (end - addr) >> PAGE_SHIFT);
+			memset(vec, MINCORE_RESIDENT, (end - addr) >> PAGE_SHIFT);
 		}
 	} else
 		spin_unlock(&vma->vm_mm->page_table_lock);
diff --git a/mm/mincore.c b/mm/mincore.c
index 636a868..b719cdd 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -38,7 +38,7 @@ static void mincore_hugetlb_page_range(struct vm_area_struct *vma,
 				       addr & huge_page_mask(h));
 		present = ptep && !huge_pte_none(huge_ptep_get(ptep));
 		while (1) {
-			*vec = present;
+			*vec = (present ? MINCORE_RESIDENT : 0);
 			vec++;
 			addr += PAGE_SIZE;
 			if (addr == end)
@@ -83,7 +83,7 @@ static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
 		page_cache_release(page);
 	}
 
-	return present;
+	return present ? MINCORE_RESIDENT : 0;
 }
 
 static void mincore_unmapped_range(struct vm_area_struct *vma,
@@ -122,7 +122,7 @@ static void mincore_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		if (pte_none(pte))
 			mincore_unmapped_range(vma, addr, next, vec);
 		else if (pte_present(pte))
-			*vec = 1;
+			*vec = MINCORE_RESIDENT;
 		else if (pte_file(pte)) {
 			pgoff = pte_to_pgoff(pte);
 			*vec = mincore_page(vma->vm_file->f_mapping, pgoff);
@@ -131,14 +131,14 @@ static void mincore_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 
 			if (is_migration_entry(entry)) {
 				/* migration entries are always uptodate */
-				*vec = 1;
+				*vec = MINCORE_RESIDENT;
 			} else {
 #ifdef CONFIG_SWAP
 				pgoff = entry.val;
 				*vec = mincore_page(&swapper_space, pgoff);
 #else
 				WARN_ON(1);
-				*vec = 1;
+				*vec = MINCORE_RESIDENT;
 #endif
 			}
 		}
-- 
1.5.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
