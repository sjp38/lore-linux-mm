Message-ID: <4181EF80.3030709@yahoo.com.au>
Date: Fri, 29 Oct 2004 17:21:36 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH 3/7] abstract pagetable locking and pte updates
References: <4181EF2D.5000407@yahoo.com.au> <4181EF54.6080308@yahoo.com.au> <4181EF69.4070201@yahoo.com.au>
In-Reply-To: <4181EF69.4070201@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------090206090802060305000907"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------090206090802060305000907
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

3/7

--------------090206090802060305000907
Content-Type: text/x-patch;
 name="vm-hugh-cleanup-gup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm-hugh-cleanup-gup.patch"



Another small cleanup. This one from Hugh Dickins.


---

 linux-2.6-npiggin/mm/memory.c |   37 +++++++------------------------------
 1 files changed, 7 insertions(+), 30 deletions(-)

diff -puN mm/memory.c~vm-hugh-cleanup-gup mm/memory.c
--- linux-2.6/mm/memory.c~vm-hugh-cleanup-gup	2004-10-27 12:31:21.000000000 +1000
+++ linux-2.6-npiggin/mm/memory.c	2004-10-27 12:35:36.000000000 +1000
@@ -692,20 +692,6 @@ out:
 	return NULL;
 }
 
-/* 
- * Given a physical address, is there a useful struct page pointing to
- * it?  This may become more complex in the future if we start dealing
- * with IO-aperture pages for direct-IO.
- */
-
-static inline struct page *get_page_map(struct page *page)
-{
-	if (!pfn_valid(page_to_pfn(page)))
-		return NULL;
-	return page;
-}
-
-
 static inline int
 untouched_anonymous_page(struct mm_struct* mm, struct vm_area_struct *vma,
 			 unsigned long address)
@@ -731,7 +717,6 @@ untouched_anonymous_page(struct mm_struc
 	return 0;
 }
 
-
 int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long start, int len, int write, int force,
 		struct page **pages, struct vm_area_struct **vmas)
@@ -796,9 +781,9 @@ int get_user_pages(struct task_struct *t
 		}
 		spin_lock(&mm->page_table_lock);
 		do {
-			struct page *map;
+			struct page *page;
 			int lookup_write = write;
-			while (!(map = follow_page(mm, start, lookup_write))) {
+			while (!(page = follow_page(mm, start, lookup_write))) {
 				/*
 				 * Shortcut for anonymous pages. We don't want
 				 * to force the creation of pages tables for
@@ -808,7 +793,7 @@ int get_user_pages(struct task_struct *t
 				 */
 				if (!lookup_write &&
 				    untouched_anonymous_page(mm,vma,start)) {
-					map = ZERO_PAGE(start);
+					page = ZERO_PAGE(start);
 					break;
 				}
 				spin_unlock(&mm->page_table_lock);
@@ -837,17 +822,10 @@ int get_user_pages(struct task_struct *t
 				spin_lock(&mm->page_table_lock);
 			}
 			if (pages) {
-				pages[i] = get_page_map(map);
-				if (!pages[i]) {
-					spin_unlock(&mm->page_table_lock);
-					while (i--)
-						page_cache_release(pages[i]);
-					i = -EFAULT;
-					goto out;
-				}
-				flush_dcache_page(pages[i]);
-				if (!PageReserved(pages[i]))
-					page_cache_get(pages[i]);
+				pages[i] = page;
+				flush_dcache_page(page);
+				if (!PageReserved(page))
+					page_cache_get(page);
 			}
 			if (vmas)
 				vmas[i] = vma;
@@ -857,7 +835,6 @@ int get_user_pages(struct task_struct *t
 		} while(len && start < vma->vm_end);
 		spin_unlock(&mm->page_table_lock);
 	} while(len);
-out:
 	return i;
 }
 

_

--------------090206090802060305000907--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
