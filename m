From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 11/22] HWPOISON: Refactor truncate to allow direct truncating of page v3
Date: Mon, 15 Jun 2009 10:45:31 +0800
Message-ID: <20090615031253.870957338@intel.com>
References: <20090615024520.786814520@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 273E76B0095
	for <linux-mm@kvack.org>; Sun, 14 Jun 2009 23:14:41 -0400 (EDT)
Content-Disposition: inline; filename=truncate-refactor
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Andi Kleen <ak@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, "Wu, Fengguang" <fengguang.wu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

From: Nick Piggin <npiggin@suse.de>

Extract out truncate_inode_page() out of the truncate path so that
it can be used by memory-failure.c

[AK: description, headers, fix typos]
v2: Some white space changes from Fengguang Wu
v3: add comments

Signed-off-by: Nick Piggin <npiggin@suse.de>
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 include/linux/mm.h |    2 ++
 mm/truncate.c      |   34 ++++++++++++++++++++++------------
 2 files changed, 24 insertions(+), 12 deletions(-)

--- sound-2.6.orig/mm/truncate.c
+++ sound-2.6/mm/truncate.c
@@ -135,6 +135,26 @@ invalidate_complete_page(struct address_
 	return ret;
 }
 
+/*
+ * Remove one page from its pagecache mapping. The page must be locked.
+ * This does not truncate the file on disk, it performs the pagecache
+ * side of the truncate operation. Dirty data will be discarded, and
+ * concurrent page references are ignored.
+ *
+ * Generic mm/fs code cannot call this on filesystem metadata mappings
+ * because those can assume that a page reference is enough to pin the
+ * page to its mapping.
+ */
+void truncate_inode_page(struct address_space *mapping, struct page *page)
+{
+	if (page_mapped(page)) {
+		unmap_mapping_range(mapping,
+				   (loff_t)page->index << PAGE_CACHE_SHIFT,
+				   PAGE_CACHE_SIZE, 0);
+	}
+	truncate_complete_page(mapping, page);
+}
+
 /**
  * truncate_inode_pages - truncate range of pages specified by start & end byte offsets
  * @mapping: mapping to truncate
@@ -196,12 +216,7 @@ void truncate_inode_pages_range(struct a
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
@@ -238,15 +253,10 @@ void truncate_inode_pages_range(struct a
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
--- sound-2.6.orig/include/linux/mm.h
+++ sound-2.6/include/linux/mm.h
@@ -814,6 +814,8 @@ static inline void unmap_shared_mapping_
 extern int vmtruncate(struct inode * inode, loff_t offset);
 extern int vmtruncate_range(struct inode * inode, loff_t offset, loff_t end);
 
+void truncate_inode_page(struct address_space *mapping, struct page *page);
+
 #ifdef CONFIG_MMU
 extern int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, int write_access);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
