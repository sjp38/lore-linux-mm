Received: from m2.gw.fujitsu.co.jp ([10.0.50.72]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i97CH9R6023480 for <linux-mm@kvack.org>; Thu, 7 Oct 2004 21:17:09 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s2.gw.fujitsu.co.jp by m2.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i97CH9f1014166 for <linux-mm@kvack.org>; Thu, 7 Oct 2004 21:17:09 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s2.gw.fujitsu.co.jp (s2 [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DE5981F723B
	for <linux-mm@kvack.org>; Thu,  7 Oct 2004 21:17:08 +0900 (JST)
Received: from fjmail503.fjmail.jp.fujitsu.com (fjmail503-0.fjmail.jp.fujitsu.com [10.59.80.100])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 793211F723E
	for <linux-mm@kvack.org>; Thu,  7 Oct 2004 21:17:08 +0900 (JST)
Received: from jp.fujitsu.com
 (fjscan501-0.fjmail.jp.fujitsu.com [10.59.80.120]) by
 fjmail503.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I57009LARGI7W@fjmail503.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Thu,  7 Oct 2004 21:17:08 +0900 (JST)
Date: Thu, 07 Oct 2004 21:22:41 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH]  no buddy bitmap patch : intro and includes [0/2]
Message-id: <41653511.60905@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel ML <linux-kernel@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, LHMS <lhms-devel@lists.sourceforge.net>, Andrew Morton <akpm@osdl.org>, William Lee Irwin III <wli@holomorphy.com>, "Luck, Tony" <tony.luck@intel.com>, Dave Hansen <haveblue@us.ibm.com>, Hirokazu Takahashi <taka@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

Hi,

Followings are patches for removing bitmaps from buddy allocator, against 2.6.9-rc3.
I think this version is much clearer than ones I posted a month ago.

The problem I was worried about was how to deal with memmap's holes in a zone.
and I decided to use pfn_valid() simply. Now, there is no messy codes :)

pfn_valid() is used when macro "HOLES_IN_ZONE" is defined.
It is defined only in ia64 now.

Here is kernbench result on my tiger4 (Itanium2 1.3GHz x2, 8 Gbytes memory)

Average Optimal -j 8 Load Run (Perfroming 5 run of make -j 8 on linux-2.6.8 source tree):

                Elapsed Time  User Time  System Time Percent CPU  Context Switches   Sleeps
2.6.9-rc3         699.906      1322.01     39.336       194            64390         74416.8
no-bitmap         698.334      1321.79     38.58        194.2          64435.4       74622.2

If there is unclear point, please tell me.

Thanks.
Kame <kamezawa.hiroyu@jp.fujitsu.com>

=== patch for include files ===

This patch removes bitmap from zone->free_area[] in include/linux/mmzone.h,
and adds some comments on page->private field in include/linux/mm.h.

non-atomic ops for changing PG_private bit is added in include/page-flags.h.
zone->lock is always acquired when PG_private of "a free page" is changed.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---

 test-kernel-kamezawa/include/linux/mm.h         |    2 ++
 test-kernel-kamezawa/include/linux/mmzone.h     |    1 -
 test-kernel-kamezawa/include/linux/page-flags.h |    2 ++
 3 files changed, 4 insertions(+), 1 deletion(-)

diff -puN include/linux/mm.h~eliminate-bitmap-includes include/linux/mm.h
--- test-kernel/include/linux/mm.h~eliminate-bitmap-includes	2004-10-07 17:18:34.062982800 +0900
+++ test-kernel-kamezawa/include/linux/mm.h	2004-10-07 17:18:34.070981584 +0900
@@ -209,6 +209,8 @@ struct page {
 					 * usually used for buffer_heads
 					 * if PagePrivate set; used for
 					 * swp_entry_t if PageSwapCache
+					 * When page is free, this indicates
+					 * order in the buddy system.
 					 */
 	struct address_space *mapping;	/* If low bit clear, points to
 					 * inode address_space, or NULL.
diff -puN include/linux/mmzone.h~eliminate-bitmap-includes include/linux/mmzone.h
--- test-kernel/include/linux/mmzone.h~eliminate-bitmap-includes	2004-10-07 17:18:34.065982344 +0900
+++ test-kernel-kamezawa/include/linux/mmzone.h	2004-10-07 17:18:34.071981432 +0900
@@ -22,7 +22,6 @@

 struct free_area {
 	struct list_head	free_list;
-	unsigned long		*map;
 };

 struct pglist_data;
diff -puN include/linux/page-flags.h~eliminate-bitmap-includes include/linux/page-flags.h
--- test-kernel/include/linux/page-flags.h~eliminate-bitmap-includes	2004-10-07 17:18:34.067982040 +0900
+++ test-kernel-kamezawa/include/linux/page-flags.h	2004-10-07 17:18:34.071981432 +0900
@@ -238,6 +238,8 @@ extern unsigned long __read_page_state(u
 #define SetPagePrivate(page)	set_bit(PG_private, &(page)->flags)
 #define ClearPagePrivate(page)	clear_bit(PG_private, &(page)->flags)
 #define PagePrivate(page)	test_bit(PG_private, &(page)->flags)
+#define __SetPagePrivate(page)  __set_bit(PG_private, &(page)->flags)
+#define __ClearPagePrivate(page) __clear_bit(PG_private, &(page)->flags)

 #define PageWriteback(page)	test_bit(PG_writeback, &(page)->flags)
 #define SetPageWriteback(page)						\

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
