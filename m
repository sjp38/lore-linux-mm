Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C65076B0102
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:47:14 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <20090603846.816684333@firstfloor.org>
In-Reply-To: <20090603846.816684333@firstfloor.org>
Subject: [PATCH] [12/16] Refactor truncate to allow direct truncating of page
Message-Id: <20090603184646.B915B1D0292@basil.firstfloor.org>
Date: Wed,  3 Jun 2009 20:46:46 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: npiggin@suse.de, akpm@linux-foundation.orgnpiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>


From: Nick Piggin <npiggin@suse.de>

Extract out truncate_inode_page() out of the truncate path so that
it can be used by memory-failure.c

[AK: description, headers, fix typos]

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 include/linux/mm.h |    2 ++
 mm/truncate.c      |   24 ++++++++++++------------
 2 files changed, 14 insertions(+), 12 deletions(-)

Index: linux/mm/truncate.c
===================================================================
--- linux.orig/mm/truncate.c	2009-06-03 19:37:38.000000000 +0200
+++ linux/mm/truncate.c	2009-06-03 20:13:43.000000000 +0200
@@ -135,6 +135,16 @@
 	return ret;
 }
 
+void truncate_inode_page(struct address_space *mapping, struct page *page)
+{
+	if (page_mapped(page)) {
+		unmap_mapping_range(mapping,
+		  (loff_t)page->index<<PAGE_CACHE_SHIFT,
+		  PAGE_CACHE_SIZE, 0);
+	}
+	truncate_complete_page(mapping, page);
+}
+
 /**
  * truncate_inode_pages - truncate range of pages specified by start & end byte offsets
  * @mapping: mapping to truncate
@@ -196,12 +206,7 @@
 				unlock_page(page);
 				continue;
 			}
-			if (page_mapped(page)) {
-				unmap_mapping_range(mapping,
-				  (loff_t)page_index<<PAGE_CACHE_SHIFT,
-				  PAGE_CACHE_SIZE, 0);
-			}
-			truncate_complete_page(mapping, page);
+			truncate_inode_page(mapping, page);
 			unlock_page(page);
 		}
 		pagevec_release(&pvec);
@@ -238,15 +243,10 @@
 				break;
 			lock_page(page);
 			wait_on_page_writeback(page);
-			if (page_mapped(page)) {
-				unmap_mapping_range(mapping,
-				  (loff_t)page->index<<PAGE_CACHE_SHIFT,
-				  PAGE_CACHE_SIZE, 0);
-			}
+			truncate_inode_page(mapping, page);
 			if (page->index > next)
 				next = page->index;
 			next++;
-			truncate_complete_page(mapping, page);
 			unlock_page(page);
 		}
 		pagevec_release(&pvec);
Index: linux/include/linux/mm.h
===================================================================
--- linux.orig/include/linux/mm.h	2009-06-03 19:37:38.000000000 +0200
+++ linux/include/linux/mm.h	2009-06-03 20:39:49.000000000 +0200
@@ -811,6 +811,8 @@
 extern int vmtruncate(struct inode * inode, loff_t offset);
 extern int vmtruncate_range(struct inode * inode, loff_t offset, loff_t end);
 
+void truncate_inode_page(struct address_space *mapping, struct page *page);
+
 #ifdef CONFIG_MMU
 extern int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, int write_access);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
