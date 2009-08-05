Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id ECFEF6B008C
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 05:36:41 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <200908051136.682859934@firstfloor.org>
In-Reply-To: <200908051136.682859934@firstfloor.org>
Subject: [PATCH] [12/19] HWPOISON: Add invalidate_inode_page
Message-Id: <20090805093639.D5FBEB15D8@basil.firstfloor.org>
Date: Wed,  5 Aug 2009 11:36:39 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.com, akpm@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.orgfengguang.wu@intel.com, hidehiro.kawai.ez@hitachi.com
List-ID: <linux-mm.kvack.org>


From: Wu Fengguang <fengguang.wu@intel.com>

Add a simple way to invalidate a single page
This is just a refactoring of the truncate.c code.
Originally from Fengguang, modified by Andi Kleen.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 include/linux/mm.h |    2 ++
 mm/truncate.c      |   26 ++++++++++++++++++++------
 2 files changed, 22 insertions(+), 6 deletions(-)

Index: linux/include/linux/mm.h
===================================================================
--- linux.orig/include/linux/mm.h
+++ linux/include/linux/mm.h
@@ -811,6 +811,8 @@ extern int vmtruncate_range(struct inode
 
 int truncate_inode_page(struct address_space *mapping, struct page *page);
 
+int invalidate_inode_page(struct page *page);
+
 #ifdef CONFIG_MMU
 extern int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, unsigned int flags);
Index: linux/mm/truncate.c
===================================================================
--- linux.orig/mm/truncate.c
+++ linux/mm/truncate.c
@@ -146,6 +146,24 @@ int truncate_inode_page(struct address_s
 	return truncate_complete_page(mapping, page);
 }
 
+/*
+ * Safely invalidate one page from its pagecache mapping.
+ * It only drops clean, unused pages. The page must be locked.
+ *
+ * Returns 1 if the page is successfully invalidated, otherwise 0.
+ */
+int invalidate_inode_page(struct page *page)
+{
+	struct address_space *mapping = page_mapping(page);
+	if (!mapping)
+		return 0;
+	if (PageDirty(page) || PageWriteback(page))
+		return 0;
+	if (page_mapped(page))
+		return 0;
+	return invalidate_complete_page(mapping, page);
+}
+
 /**
  * truncate_inode_pages - truncate range of pages specified by start & end byte offsets
  * @mapping: mapping to truncate
@@ -312,12 +330,8 @@ unsigned long invalidate_mapping_pages(s
 			if (lock_failed)
 				continue;
 
-			if (PageDirty(page) || PageWriteback(page))
-				goto unlock;
-			if (page_mapped(page))
-				goto unlock;
-			ret += invalidate_complete_page(mapping, page);
-unlock:
+			ret += invalidate_inode_page(page);
+
 			unlock_page(page);
 			if (next > end)
 				break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
