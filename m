Received: from m6.gw.fujitsu.co.jp ([10.0.50.76]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7OCGUwH010182 for <linux-mm@kvack.org>; Tue, 24 Aug 2004 21:16:30 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s4.gw.fujitsu.co.jp by m6.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7OCGUqA011600 for <linux-mm@kvack.org>; Tue, 24 Aug 2004 21:16:30 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail505.fjmail.jp.fujitsu.com (fjmail505-0.fjmail.jp.fujitsu.com [10.59.80.104]) by s4.gw.fujitsu.co.jp (8.12.11)
	id i7OCGUmV003247 for <linux-mm@kvack.org>; Tue, 24 Aug 2004 21:16:30 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan503-0.fjmail.jp.fujitsu.com [10.59.80.124]) by
 fjmail505.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I2Y00DK0A3G9P@fjmail505.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Tue, 24 Aug 2004 21:16:29 +0900 (JST)
Date: Tue, 24 Aug 2004 21:21:37 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC/PATCH] free_area[] bitmap elimination[0/3]
Message-id: <412B32D1.10005@jp.fujitsu.com>
MIME-version: 1.0
Content-type: multipart/mixed; boundary="------------020201060005010808000006"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, LHMS <lhms-devel@lists.sourceforge.net>
Cc: William Lee Irwin III <wli@holomorphy.com>, Dave Hansen <haveblue@us.ibm.com>, Hirokazu Takahashi <taka@valinux.co.jp>, ncunningham@linuxmail.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------020201060005010808000006
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Thanks for many comments on previous RFC.

This is an updated version of free_area[] bitmap elimination patch.
Many advices are reflected.
I tested this on Xeon x 2 server and Itanium2 x 2 server.

This removes bitmaps from the buddy allocator.
Instead of using bitmap, this patch records a free page's order to
page struct itself.

Most important point I changed in this version is that tricky usage of
page->private is removed.Instead of doing so,I use PG_private bit now.

If a page is page_count(page)== 0 && PagePrivate(page), it is a head of
contiguous free page on the buddy allocator and its order is page->private.

Propriety of using PG_private is guaranteed by these facts:
(1) Before calling free_pages(), PG_private must be cleared.(see free_pages_check())
(2) Swap calls, which directly call put_page_testzero(), does not uses PG_private bit.
    Because they calls free_hot_cold_page() directly, PG_private bit is not set when
    page_count(page) becomes zero.
(3) All operation of set and clear PG_private bit of a free page for buddy allocator
    is done only while zone->lock() is acquired.

I added zone->aligned_order member in zone struct for avoiding range check to some extent.
This member guarantees a page has a buddy in an order <= zone->aligned_order and
we can skip some checks.

In this version, a problem of pfn_valid() for ia64 is not fixed.
I think I'll need some different kind of patch to fix this.

I added detailed description but complexity is unchaned.

How to patch :
1) patch -p1 < eliminate-bitmap-includes.patch
2) patch -p1 < eliminate-bitmap-init.patch
3) patch -p1 < eliminate-bitmap-alloc.patch
4) patch -p1 < eliminate-bitmap-free.patch


Thanks
--Kame

-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--------------020201060005010808000006
Content-Type: text/x-patch;
 name="eliminate-bitmap-includes.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="eliminate-bitmap-includes.patch"


This patch removes bitmap from buddy allocator, 
removes free_area_t's bitmap in include/linux/mmzone.h
and adds some definition in include/linux/mm.h

Currently,Linux's page allocator uses buddy algorithm and codes for buddy 
allocator uses bitmap. For what is bitmap is used ?

(*) for recording "a page is free" and its order.

If a page is free and is a head of contiguous free pages of order 'X',
we can record it by
set_bit(free_area[X]->bitmap, index_of_page)

For coalescing, when there is a chunk of free pages of order 'X', 
we can test whether we can coalesce or not by, 
test_bit(free_aera[X]->bitmap,index_of_buddy) 
index_of_buddy can be calculated by (index_of_page ^ (1 << order))

This patch removes bitmap and recording a free page's order 
in its page->private field. If a page is free and it is a head of a free
memory chunk, page->private indicates the order of the page.
and PG_private bit is used to show propriety of information.

For coalescing, when there is a page which is a chunk of free pages of order 'X',
we can test whether we can coalesce or not by
(page_is_free(buddy) && PagePrivate(buddy) && page_order(buddy) == 'X')
address of buddy can be calculated by the same way in bitmap case.

If page is free and on the buddy system, PG_private bit is set and has its order 
in page->private. This scheme is safe because...
(a) when page is being freed, PG_private is not set. (see free_pages_check())
(b) when page is free and on the buddy system, PG_private is set.
These facts are guaranteed by zone->lock.
Only one thread can change a free page's PG_private bit and private field 
at anytime.

in mmzone.h, zone->aligned_order is added. this is explained in next patch.

-- Kame


---

 linux-2.6.8.1-mm4-kame-kamezawa/include/linux/mm.h     |   20 +++++++++++++++++
 linux-2.6.8.1-mm4-kame-kamezawa/include/linux/mmzone.h |    4 ++-
 2 files changed, 23 insertions(+), 1 deletion(-)

diff -puN include/linux/mm.h~eliminate-bitmap-includes include/linux/mm.h
--- linux-2.6.8.1-mm4-kame/include/linux/mm.h~eliminate-bitmap-includes	2004-08-23 11:06:43.000000000 +0900
+++ linux-2.6.8.1-mm4-kame-kamezawa/include/linux/mm.h	2004-08-24 18:25:03.351544872 +0900
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
@@ -322,6 +325,23 @@ static inline void put_page(struct page 
 #endif		/* CONFIG_HUGETLB_PAGE */
 
 /*
+ * These macros are used in alloc_pages()/free_pages(), buddy allocator.
+ * page_order(page) returns an order of a free page in buddy allocator.
+ * set_page_order(page, order) sets an order of a free page in buddy allocator.
+ * Invalidate_page_order() invalidates order information for avoiding
+ * conflicts of pages in transition state.
+ *
+ * this is used with PG_private flag
+ */ 
+#define set_page_order(page,order)\
+        do {\
+            (page)->private = (order);\
+            SetPagePrivate((page));\
+        } while(0)
+#define invalidate_page_order(page) ClearPagePrivate((page))
+#define page_order(page) ((page)->private)
+
+/*
  * Multiple processes may "see" the same page. E.g. for untouched
  * mappings of /dev/null, all processes see the same page full of
  * zeroes, and text pages of executables and shared libraries have
diff -puN include/linux/mmzone.h~eliminate-bitmap-includes include/linux/mmzone.h
--- linux-2.6.8.1-mm4-kame/include/linux/mmzone.h~eliminate-bitmap-includes	2004-08-23 11:47:01.000000000 +0900
+++ linux-2.6.8.1-mm4-kame-kamezawa/include/linux/mmzone.h	2004-08-24 13:07:28.000000000 +0900
@@ -22,7 +22,6 @@
 
 struct free_area {
 	struct list_head	free_list;
-	unsigned long		*map;
 };
 
 struct pglist_data;
@@ -163,7 +162,10 @@ struct zone {
 
 	/*
 	 * free areas of different sizes
+	 * aligned_order shows the upper bound of aligned order,
+	 * aligned_order means every page below it has a buddy.
 	 */
+	int			aligned_order; 
 	struct free_area	free_area[MAX_ORDER];
 
 	/*

_

--------------020201060005010808000006--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
