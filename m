Received: from m3.gw.fujitsu.co.jp ([10.0.50.73]) by fgwmail5.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7L2QEJB011842 for <linux-mm@kvack.org>; Sat, 21 Aug 2004 11:26:14 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s4.gw.fujitsu.co.jp by m3.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7L2QE0B025498 for <linux-mm@kvack.org>; Sat, 21 Aug 2004 11:26:14 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail504.fjmail.jp.fujitsu.com (fjmail504-0.fjmail.jp.fujitsu.com [10.59.80.102]) by s4.gw.fujitsu.co.jp (8.12.11)
	id i7L2QDVp031101 for <linux-mm@kvack.org>; Sat, 21 Aug 2004 11:26:13 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan503-0.fjmail.jp.fujitsu.com [10.59.80.124]) by
 fjmail504.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I2R002LRYROD5@fjmail504.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Sat, 21 Aug 2004 11:26:13 +0900 (JST)
Date: Sat, 21 Aug 2004 11:31:21 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC]  free_area[]  bitmap elimination [0/3]
Message-id: <4126B3F9.90706@jp.fujitsu.com>
MIME-version: 1.0
Content-type: multipart/mixed; boundary="------------090503020609060008060205"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: LHMS <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------090503020609060008060205
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi

This patch removes bitmap from buddy allocator used in
alloc_pages()/free_pages() in the kernel 2.6.8.1.

Currently, Linux's page allocator uses bitmaps to record an order
of a free page.
This patch removes bitmap from buddy allocator, and uses
page->private field to record an order of a page.

My purpose is to reduce complexity of buddy allocator, when we want to
hotplug memory. For memory hotplug, we have to resize memory management
structures. Major two of them are mem_map and bitmap.If this patch removes
bitmap from buddy allocator, resizeing bitmap will be needless.

I tested this patch on my small PC box(Celeron900MHz,256MB memory)
and a server machine(Xeon x 2, 4GB memory).

Patch is divided into 4 parts
p01 .....  for include files
p02 .....  for initialization of zone
p03 .....  for alloc_pages()
p04 .....  for free_pages()

Note:
This patch records an order of a page in page->private field, in
page->private = ~order manner.
This is because there are pages which is not in buddy allocator and is its
page_count(page)==0.

I'm not convinced that page->private is not used while page_count(page) == 0.
If used, this patch will have a problem.

Thanks
KAME

-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--------------090503020609060008060205
Content-Type: text/x-patch;
 name="eliminate-bitmap-p01.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="eliminate-bitmap-p01.patch"


Eliminate free_area_t bitmap patches.
p01 is for include files.


---

 linux-2.6.8.1-kame-kamezawa/include/linux/mm.h     |   16 ++++++++++++++--
 linux-2.6.8.1-kame-kamezawa/include/linux/mmzone.h |    1 -
 2 files changed, 14 insertions(+), 3 deletions(-)

diff -puN include/linux/mmzone.h~eliminate-bitmap-p01 include/linux/mmzone.h
--- linux-2.6.8.1-kame/include/linux/mmzone.h~eliminate-bitmap-p01	2004-08-19 13:16:05.000000000 +0900
+++ linux-2.6.8.1-kame-kamezawa/include/linux/mmzone.h	2004-08-19 13:34:34.000000000 +0900
@@ -34,7 +34,6 @@
 
 struct free_area {
 	struct list_head	free_list;
-	unsigned long		*map;
 };
 
 struct pglist_data;
diff -puN include/linux/mm.h~eliminate-bitmap-p01 include/linux/mm.h
--- linux-2.6.8.1-kame/include/linux/mm.h~eliminate-bitmap-p01	2004-08-19 13:22:24.000000000 +0900
+++ linux-2.6.8.1-kame-kamezawa/include/linux/mm.h	2004-08-21 08:52:59.137598728 +0900
@@ -203,8 +203,9 @@ struct page {
 	unsigned long private;		/* Mapping-private opaque data:
 					 * usually used for buffer_heads
 					 * if PagePrivate set; used for
-					 * swp_entry_t if PageSwapCache
-					 */
+					 * swp_entry_t if PageSwapCache.
+					 * when page is free, this field
+					 * keeps order of page. */
 	struct address_space *mapping;	/* If PG_anon clear, points to
 					 * inode address_space, or NULL.
 					 * If page mapped as anonymous
@@ -313,9 +314,20 @@ static inline void put_page(struct page 
 		__page_cache_release(page);
 }
 
+
+
+
 #endif		/* CONFIG_HUGETLB_PAGE */
 
 /*
+ *	indicates page's order in freelist
+ *      order is recorded in inveterd manner.
+ */
+#define page_order(page)	(~((page)->private))
+#define set_page_order(page,order)	((page)->private = ~order)
+#define invalidate_page_order(page) ((page)->private = 0)
+
+/*
  * Multiple processes may "see" the same page. E.g. for untouched
  * mappings of /dev/null, all processes see the same page full of
  * zeroes, and text pages of executables and shared libraries have

_

--------------090503020609060008060205--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
