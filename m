Received: from m1.gw.fujitsu.co.jp ([10.0.50.71]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i98BstR6024448 for <linux-mm@kvack.org>; Fri, 8 Oct 2004 20:54:55 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s0.gw.fujitsu.co.jp by m1.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i98BssND009853 for <linux-mm@kvack.org>; Fri, 8 Oct 2004 20:54:54 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s0.gw.fujitsu.co.jp (s0 [127.0.0.1])
	by s0.gw.fujitsu.co.jp (Postfix) with ESMTP id 4130EA7CEB
	for <linux-mm@kvack.org>; Fri,  8 Oct 2004 20:54:54 +0900 (JST)
Received: from fjmail506.fjmail.jp.fujitsu.com (fjmail506-0.fjmail.jp.fujitsu.com [10.59.80.106])
	by s0.gw.fujitsu.co.jp (Postfix) with ESMTP id CCDD9A7CF1
	for <linux-mm@kvack.org>; Fri,  8 Oct 2004 20:54:53 +0900 (JST)
Received: from jp.fujitsu.com
 (fjscan503-0.fjmail.jp.fujitsu.com [10.59.80.124]) by
 fjmail506.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I590000SL3GDD@fjmail506.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Fri,  8 Oct 2004 20:54:53 +0900 (JST)
Date: Fri, 08 Oct 2004 21:00:27 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] no buddy bitmap patch revist : intro and includes [0/2]
Message-id: <4166815B.8030001@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel ML <linux-kernel@vger.kernel.org>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm <linux-mm@kvack.org>, LHMS <lhms-devel@lists.sourceforge.net>, Andrew Morton <akpm@osdl.org>, Tony Luck <tony.luck@intel.com>, Dave Hansen <haveblue@us.ibm.com>, Hirokazu Takahashi <taka@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

Hi

Followings are patches for removing bitmaps from the buddy allocator,
against 2.6.9-rc3.
This is  benefical to memory-hot-plug stuffs, because this removes
a data structure which must meet to a host's physical memory layout.

Difference from one I posted yesterday is using CONFIG_HOLES_IN_ZONE
instead of HOLES_IN_ZONE and some fixes on comments.

This patch removes bitmaps in zone->free_area[] used in the buddy system.
Instead of using bitmaps, this patch records a free page's order in a page
struct itself using page->private field.

I removed "#define HOLES_IN_ZONE in asm/page.h" and added CONFIG_HOLES_IN_ZONE
to Kconfig. An architecuture which has memory holes in a zone has to set this CONFIG.
As far as I know, only ia64 with virtual memmap has to set this now.

In my performance test on ia64 SMP, there is no performance influence of this patch.

Kame <kamezawa.hiroyu@jp.fujitsu.com>
============= patches for include files ==================


This patch set removes bitmaps from the page allocator.

Purpose:
This is one step to manage physical memory in nonlinear / discontiguous way
and will reduce some amounts of codes to implement memory-hot-plug.

About this part:
This patch removes bitmaps from zone->free_area[] in include/linux/mmzone.h,
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
--- test-kernel/include/linux/mm.h~eliminate-bitmap-includes	2004-10-07 17:18:34.000000000 +0900
+++ test-kernel-kamezawa/include/linux/mm.h	2004-10-07 17:18:34.000000000 +0900
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
--- test-kernel/include/linux/mmzone.h~eliminate-bitmap-includes	2004-10-07 17:18:34.000000000 +0900
+++ test-kernel-kamezawa/include/linux/mmzone.h	2004-10-07 17:18:34.000000000 +0900
@@ -22,7 +22,6 @@

 struct free_area {
 	struct list_head	free_list;
-	unsigned long		*map;
 };

 struct pglist_data;
diff -puN include/linux/page-flags.h~eliminate-bitmap-includes include/linux/page-flags.h
--- test-kernel/include/linux/page-flags.h~eliminate-bitmap-includes	2004-10-07 17:18:34.000000000 +0900
+++ test-kernel-kamezawa/include/linux/page-flags.h	2004-10-07 17:18:34.000000000 +0900
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
