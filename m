Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id DCD956B006C
	for <linux-mm@kvack.org>; Thu, 11 Dec 2014 08:21:02 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id r10so3009122pdi.21
        for <linux-mm@kvack.org>; Thu, 11 Dec 2014 05:21:02 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id pc1si1855649pdb.16.2014.12.11.05.21.00
        for <linux-mm@kvack.org>;
        Thu, 11 Dec 2014 05:21:01 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: add fields for compound destructor and order into struct page
Date: Thu, 11 Dec 2014 15:20:27 +0200
Message-Id: <1418304027-154173-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, jmarchan@redhat.com, aneesh.kumar@linux.vnet.ibm.com, dave.hansen@intel.com, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Currently, we use lru.next/lru.prev plus cast to access or set
destructor and order of compound page.

Let's replace it with explicit fields in struct page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h       | 9 ++++-----
 include/linux/mm_types.h | 8 ++++++++
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5bfd9b9756fa..a8de6fe11d0a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -525,29 +525,28 @@ int split_free_page(struct page *page);
  * prototype for that function and accessor functions.
  * These are _only_ valid on the head of a PG_compound page.
  */
-typedef void compound_page_dtor(struct page *);
 
 static inline void set_compound_page_dtor(struct page *page,
 						compound_page_dtor *dtor)
 {
-	page[1].lru.next = (void *)dtor;
+	page[1].compound_dtor = dtor;
 }
 
 static inline compound_page_dtor *get_compound_page_dtor(struct page *page)
 {
-	return (compound_page_dtor *)page[1].lru.next;
+	return page[1].compound_dtor;
 }
 
 static inline int compound_order(struct page *page)
 {
 	if (!PageHead(page))
 		return 0;
-	return (unsigned long)page[1].lru.prev;
+	return page[1].compound_order;
 }
 
 static inline void set_compound_order(struct page *page, unsigned long order)
 {
-	page[1].lru.prev = (void *)order;
+	page[1].compound_order = order;
 }
 
 #ifdef CONFIG_MMU
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 03945eef1350..cbc71f32a53c 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -28,6 +28,8 @@ struct mem_cgroup;
 		IS_ENABLED(CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK))
 #define ALLOC_SPLIT_PTLOCKS	(SPINLOCK_SIZE > BITS_PER_LONG/8)
 
+typedef void compound_page_dtor(struct page *);
+
 /*
  * Each physical page in the system has a struct page associated with
  * it to keep track of whatever it is we are using the page for at the
@@ -131,6 +133,12 @@ struct page {
 		struct rcu_head rcu_head;	/* Used by SLAB
 						 * when destroying via RCU
 						 */
+		/* First tail page of compound page */
+		struct {
+			compound_page_dtor *compound_dtor;
+			unsigned long compound_order;
+		};
+
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && USE_SPLIT_PMD_PTLOCKS
 		pgtable_t pmd_huge_pte; /* protected by page->ptl */
 #endif
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
