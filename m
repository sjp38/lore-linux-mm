Received: from m2.gw.fujitsu.co.jp ([10.0.50.72]) by fgwmail5.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i827oh9B010325 for <linux-mm@kvack.org>; Thu, 2 Sep 2004 16:50:43 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s5.gw.fujitsu.co.jp by m2.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i827ogti027667 for <linux-mm@kvack.org>; Thu, 2 Sep 2004 16:50:42 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail506.fjmail.jp.fujitsu.com (fjmail506-0.fjmail.jp.fujitsu.com [10.59.80.106]) by s5.gw.fujitsu.co.jp (8.12.11)
	id i827ogBo019326 for <linux-mm@kvack.org>; Thu, 2 Sep 2004 16:50:42 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan503-0.fjmail.jp.fujitsu.com [10.59.80.124]) by
 fjmail506.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I3E009XZLSHHB@fjmail506.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Thu,  2 Sep 2004 16:50:42 +0900 (JST)
Date: Thu, 02 Sep 2004 16:55:55 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] buddy allocator without bitmap(3) [0/3]
Message-id: <4136D20B.1020108@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel ML <linux-kernel@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, LHMS <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Hi, this is new patch for removing bitmaps from the buddy allocator.

In previous version, I used new additional PG_xxx flag. But in this, I don't
use any additional new flag.

For dealing with a special case of unaligned discontiguous mem_map,
I removed some troublesome pages from the system instead of using PG_xxx flag.
Note:: If memmap is aligned, no pages are removed.

"What pages are removed ?" is explained in patch[1/3].
Please draw a picture of the buddy system when you read calculate_aligned_end(),
which finds pages to be removed.

(Special Case Example)
Results of calculate_aligned_end() on Tiger4
(Itanium2, 8GB Memory, discontiguous, virtual mem_map)
is here. There are 5 mem_maps for 2 zones and 19 pages are removed.

mem_map(1) from  36e    length 1fb6d  --- ZONE_DMA
mem_map(2) from  1fedc  length   124  --- ZONE_DMA
mem_map(3) from  40000  length 40000  --- ZONE_NORMAL (this mem_map is aligned)
mem_map(4) from  a0000  length 20000  --- ZONE_NORMAL
mem_map(5) from  bfedc  length   124  --- ZONE_NORMAL

ZONE_NORMAL has a memory hole of 2 Gbytes.

==================
Sep  2 15:23:35 casares kernel: calculate_aligned_end() 36e 1fb6d
Sep  2 15:23:35 casares kernel: victim top page 36e
Sep  2 15:23:35 casares kernel: victim top page 370
Sep  2 15:23:35 casares kernel: victim top page 380
Sep  2 15:23:35 casares kernel: victim top page 400
Sep  2 15:23:35 casares kernel: victim top page 800
Sep  2 15:23:35 casares kernel: victim top page 1000
Sep  2 15:23:35 casares kernel: victim top page 2000
Sep  2 15:23:35 casares kernel: victim top page 4000
Sep  2 15:23:35 casares kernel: victim top page 8000
Sep  2 15:23:36 casares kernel: victim top page 10000
Sep  2 15:23:36 casares kernel: victim end page 1feda

Sep  2 15:23:36 casares kernel: calculate_aligned_end() 1fedc 124
Sep  2 15:23:36 casares kernel: victim top page 1fedc
Sep  2 15:23:36 casares kernel: victim top page 1fee0
Sep  2 15:23:36 casares kernel: victim top page 1ff00
Sep  2 15:23:36 casares kernel: victim end page 1ffff

Sep  2 15:23:36 casares kernel: calculate_aligned_end() 40000 40000

Sep  2 15:23:36 casares kernel: calculate_aligned_end() a0000 20000
Sep  2 15:23:36 casares kernel: victim top page a0000

Sep  2 15:23:36 casares kernel: calculate_aligned_end() bfedc 124
Sep  2 15:23:36 casares kernel: victim top page bfedc
Sep  2 15:23:36 casares kernel: victim top page bfee0
Sep  2 15:23:36 casares kernel: victim top page bff00
Sep  2 15:23:36 casares kernel: Built 1 zonelists
==========================================================


This is the 1st.

page's order means size of contiguous free pages.
if a free page[x] 's order is Y, there are contiguous free pages
from page[X] to page[X + 2^(Y) - 1]

In this patch, when A page is a head of contiguous free pages of order X,
it is marked with PG_private and set page->private to X.
A page's buddy in order X is simply calculated by

buddy_idx = page_idx ^ (1 << X).

We can coalece 2 contiguous pages if
(page_is_free(buddy) && PagePrivate(buddy) && page_order(buddy) == 'X')

-- Kame


---

 test-kernel-kamezawa/include/linux/gfp.h    |    2 ++
 test-kernel-kamezawa/include/linux/mm.h     |   26 ++++++++++++++++++++++++++
 test-kernel-kamezawa/include/linux/mmzone.h |    1 -
 3 files changed, 28 insertions(+), 1 deletion(-)

diff -puN include/linux/mm.h~eliminate-bitmap-includes include/linux/mm.h
--- test-kernel/include/linux/mm.h~eliminate-bitmap-includes	2004-09-02 13:36:08.439416296 +0900
+++ test-kernel-kamezawa/include/linux/mm.h	2004-09-02 15:18:37.887558080 +0900
@@ -209,6 +209,9 @@ struct page {
 					 * usually used for buffer_heads
 					 * if PagePrivate set; used for
 					 * swp_entry_t if PageSwapCache
+					 * When page is free:
+					 * this indicates order of page
+					 * in buddy allocator.
 					 */
 	struct address_space *mapping;	/* If low bit clear, points to
 					 * inode address_space, or NULL.
@@ -322,6 +325,29 @@ static inline void put_page(struct page
 #endif		/* CONFIG_HUGETLB_PAGE */

 /*
+ * These functions are used in alloc_pages()/free_pages(), buddy allocator.
+ * page_order(page) returns an order of a free page in buddy allocator.
+ *
+ * this is used with PG_private flag
+ *
+ * Note : all PG_private operations used in buddy system is done while
+ * zone->lock is acquired. So set and clear PG_private bit operation
+ * does not need to be atomic.
+ */
+
+#define PAGE_INVALID_ORDER (~0UL)
+
+static inline unsigned long page_order(struct page *page)
+{
+	return page->private;
+}
+
+static inline void set_page_order(struct page *page,unsigned long order)
+{
+	page->private = order;
+}
+
+/*
  * Multiple processes may "see" the same page. E.g. for untouched
  * mappings of /dev/null, all processes see the same page full of
  * zeroes, and text pages of executables and shared libraries have
diff -puN include/linux/mmzone.h~eliminate-bitmap-includes include/linux/mmzone.h
--- test-kernel/include/linux/mmzone.h~eliminate-bitmap-includes	2004-09-02 13:36:08.441415992 +0900
+++ test-kernel-kamezawa/include/linux/mmzone.h	2004-09-02 13:36:08.446415232 +0900
@@ -22,7 +22,6 @@

 struct free_area {
 	struct list_head	free_list;
-	unsigned long		*map;
 };

 struct pglist_data;
diff -puN include/linux/gfp.h~eliminate-bitmap-includes include/linux/gfp.h
--- test-kernel/include/linux/gfp.h~eliminate-bitmap-includes	2004-09-02 13:41:14.054955672 +0900
+++ test-kernel-kamezawa/include/linux/gfp.h	2004-09-02 15:18:00.821193024 +0900
@@ -5,6 +5,7 @@
 #include <linux/stddef.h>
 #include <linux/linkage.h>
 #include <linux/config.h>
+#include <linux/init.h>

 struct vm_area_struct;

@@ -124,6 +125,7 @@ extern void FASTCALL(__free_pages(struct
 extern void FASTCALL(free_pages(unsigned long addr, unsigned int order));
 extern void FASTCALL(free_hot_page(struct page *page));
 extern void FASTCALL(free_cold_page(struct page *page));
+extern int __init free_pages_at_init(struct page *base, unsigned int order);

 #define __free_page(page) __free_pages((page), 0)
 #define free_page(addr) free_pages((addr),0)

_






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
