Date: Tue, 6 Mar 2007 13:48:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC} memory unplug patchset prep [6/16]
 alloc_zeroed_user_high_movable
Message-Id: <20070306134851.119fdac5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@skynet.ie, clameter@engr.sgi.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Add function alloc_zeroed_user_highmovable() for allocating user pages
from ZONE_MOVABLE.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/highmem.h |   25 +++++++++++++++++++++----
 1 file changed, 21 insertions(+), 4 deletions(-)

Index: devel-tree-2.6.20-mm2/include/linux/highmem.h
===================================================================
--- devel-tree-2.6.20-mm2.orig/include/linux/highmem.h
+++ devel-tree-2.6.20-mm2/include/linux/highmem.h
@@ -66,10 +66,11 @@ static inline void clear_user_highpage(s
 
 #ifdef CONFIG_ARCH_HAS_PREZERO_USERPAGE
 static inline struct page *
-alloc_zeroed_user_highpage(struct vm_area_struct *vma, unsigned long vaddr)
+__alloc_zeroed_user_highpage(gfp_t movable,
+			struct vm_area_struct *vma, unsigned long vaddr)
 {
 	struct page *page;
-	page = alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO, vma, vaddr);
+	page = alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO | movable, vma, vaddr);
 	if (page)
 		flush_user_newzeropage(page);
 	return page;
@@ -77,9 +78,10 @@ alloc_zeroed_user_highpage(struct vm_are
 
 #else
 static inline struct page *
-alloc_zeroed_user_highpage(struct vm_area_struct *vma, unsigned long vaddr)
+__alloc_zeroed_user_highpage(gfp_t movable,
+		struct vm_area_struct *vma, unsigned long vaddr)
 {
-	struct page *page = alloc_page_vma(GFP_HIGHUSER, vma, vaddr);
+	struct page *page = alloc_page_vma(GFP_HIGHUSER | movable, vma, vaddr);
 
 	if (page)
 		clear_user_highpage(page, vaddr);
@@ -88,6 +90,21 @@ alloc_zeroed_user_highpage(struct vm_are
 }
 #endif
 
+
+static inline struct page *
+alloc_zeroed_user_highpage(struct vm_area_struct *vma, unsigned long vaddr)
+{
+	return __alloc_zeroed_user_highpage(0, vma, vaddr);
+}
+
+static inline struct page *
+alloc_zeroed_user_highmovable(struct vm_area_struct *vma, unsigned long vaddr)
+{
+	return __alloc_zeroed_user_highpage(__GFP_MOVABLE, vma, vaddr);
+}
+
+
+
 static inline void clear_highpage(struct page *page)
 {
 	void *kaddr = kmap_atomic(page, KM_USER0);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
