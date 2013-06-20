Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 6783A6B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 14:34:51 -0400 (EDT)
Message-ID: <1371753290.2146.35.camel@joe-AO722>
Subject: [PATCH] mm: remove unused VM_<READfoo> macros and expand other
 in-place
From: Joe Perches <joe@perches.com>
Date: Thu, 20 Jun 2013 11:34:50 -0700
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>

These VM_<READfoo> macros aren't used very often and
three of them aren't used at all.

Expand the ones that are used in-place, and remove
all the now unused #define VM_<foo> macros.

VM_READHINTMASK, VM_NormalReadHint and VM_ClearReadHint
were added just before 2.4 and appears have never been used.

Signed-off-by: Joe Perches <joe@perches.com>
---
Found by looking for CamelCase variable name exceptions

 include/linux/mm.h | 6 ------
 mm/filemap.c       | 6 +++---
 mm/memory.c        | 2 +-
 mm/rmap.c          | 2 +-
 4 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index b87681a..f022460 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -151,12 +151,6 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_STACK_FLAGS	(VM_GROWSDOWN | VM_STACK_DEFAULT_FLAGS | VM_ACCOUNT)
 #endif
 
-#define VM_READHINTMASK			(VM_SEQ_READ | VM_RAND_READ)
-#define VM_ClearReadHint(v)		(v)->vm_flags &= ~VM_READHINTMASK
-#define VM_NormalReadHint(v)		(!((v)->vm_flags & VM_READHINTMASK))
-#define VM_SequentialReadHint(v)	((v)->vm_flags & VM_SEQ_READ)
-#define VM_RandomReadHint(v)		((v)->vm_flags & VM_RAND_READ)
-
 /*
  * Special vmas that are non-mergable, non-mlock()able.
  * Note: mm/huge_memory.c VM_NO_THP depends on this definition.
diff --git a/mm/filemap.c b/mm/filemap.c
index 7905fe7..4b51ac1 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1539,12 +1539,12 @@ static void do_sync_mmap_readahead(struct vm_area_struct *vma,
 	struct address_space *mapping = file->f_mapping;
 
 	/* If we don't want any read-ahead, don't bother */
-	if (VM_RandomReadHint(vma))
+	if (vma->vm_flags & VM_RAND_READ)
 		return;
 	if (!ra->ra_pages)
 		return;
 
-	if (VM_SequentialReadHint(vma)) {
+	if (vma->vm_flags & VM_SEQ_READ) {
 		page_cache_sync_readahead(mapping, ra, file, offset,
 					  ra->ra_pages);
 		return;
@@ -1584,7 +1584,7 @@ static void do_async_mmap_readahead(struct vm_area_struct *vma,
 	struct address_space *mapping = file->f_mapping;
 
 	/* If we don't want any read-ahead, don't bother */
-	if (VM_RandomReadHint(vma))
+	if (vma->vm_flags & VM_RAND_READ)
 		return;
 	if (ra->mmap_miss > 0)
 		ra->mmap_miss--;
diff --git a/mm/memory.c b/mm/memory.c
index 8580f0a..af74e0c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1150,7 +1150,7 @@ again:
 				if (pte_dirty(ptent))
 					set_page_dirty(page);
 				if (pte_young(ptent) &&
-				    likely(!VM_SequentialReadHint(vma)))
+				    likely(!(vma->vm_flags & VM_SEQ_READ)))
 					mark_page_accessed(page);
 				rss[MM_FILEPAGES]--;
 			}
diff --git a/mm/rmap.c b/mm/rmap.c
index e22ceeb..cd356df 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -720,7 +720,7 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 			 * mapping is already gone, the unmap path will have
 			 * set PG_referenced or activated the page.
 			 */
-			if (likely(!VM_SequentialReadHint(vma)))
+			if (likely(!(vma->vm_flags & VM_SEQ_READ)))
 				referenced++;
 		}
 		pte_unmap_unlock(pte, ptl);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
