Received: from m5.gw.fujitsu.co.jp ([10.0.50.75]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7L2VqwH008656 for <linux-mm@kvack.org>; Sat, 21 Aug 2004 11:31:52 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s2.gw.fujitsu.co.jp by m5.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7L2VqmZ009239 for <linux-mm@kvack.org>; Sat, 21 Aug 2004 11:31:52 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail501.fjmail.jp.fujitsu.com (fjmail501-0.fjmail.jp.fujitsu.com [10.59.80.96]) by s2.gw.fujitsu.co.jp (8.12.10)
	id i7L2Vpcr019232 for <linux-mm@kvack.org>; Sat, 21 Aug 2004 11:31:51 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan502-0.fjmail.jp.fujitsu.com [10.59.80.122]) by
 fjmail501.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I2R007QCZ12IT@fjmail501.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Sat, 21 Aug 2004 11:31:51 +0900 (JST)
Date: Sat, 21 Aug 2004 11:36:58 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] free_area[] bitmap elimination [1/3]
Message-id: <4126B54A.9000206@jp.fujitsu.com>
MIME-version: 1.0
Content-type: multipart/mixed; boundary="------------080600010704020100080309"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: LHMS <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------080600010704020100080309
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

This patch removes bitmap initialization.


-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--------------080600010704020100080309
Content-Type: text/x-patch;
 name="eliminate-bitmap-p02.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="eliminate-bitmap-p02.patch"


Remove bitmap initialization in free_area_init_core()


---

 linux-2.6.8.1-kame-kamezawa/mm/page_alloc.c |   36 ----------------------------
 1 files changed, 1 insertion(+), 35 deletions(-)

diff -puN mm/page_alloc.c~eliminate-bitmap-p02 mm/page_alloc.c
--- linux-2.6.8.1-kame/mm/page_alloc.c~eliminate-bitmap-p02	2004-08-21 08:53:20.026423144 +0900
+++ linux-2.6.8.1-kame-kamezawa/mm/page_alloc.c	2004-08-21 08:53:20.033422080 +0900
@@ -1514,42 +1514,8 @@ static void __init free_area_init_core(s
 		zone_start_pfn += size;
 		lmem_map += size;
 
-		for (i = 0; ; i++) {
-			unsigned long bitmap_size;
-
+		for (i = 0; i < MAX_ORDER ; i++) {
 			INIT_LIST_HEAD(&zone->free_area[i].free_list);
-			if (i == MAX_ORDER-1) {
-				zone->free_area[i].map = NULL;
-				break;
-			}
-
-			/*
-			 * Page buddy system uses "index >> (i+1)",
-			 * where "index" is at most "size-1".
-			 *
-			 * The extra "+3" is to round down to byte
-			 * size (8 bits per byte assumption). Thus
-			 * we get "(size-1) >> (i+4)" as the last byte
-			 * we can access.
-			 *
-			 * The "+1" is because we want to round the
-			 * byte allocation up rather than down. So
-			 * we should have had a "+7" before we shifted
-			 * down by three. Also, we have to add one as
-			 * we actually _use_ the last bit (it's [0,n]
-			 * inclusive, not [0,n[).
-			 *
-			 * So we actually had +7+1 before we shift
-			 * down by 3. But (n+8) >> 3 == (n >> 3) + 1
-			 * (modulo overflows, which we do not have).
-			 *
-			 * Finally, we LONG_ALIGN because all bitmap
-			 * operations are on longs.
-			 */
-			bitmap_size = (size-1) >> (i+4);
-			bitmap_size = LONG_ALIGN(bitmap_size+1);
-			zone->free_area[i].map = 
-			  (unsigned long *) alloc_bootmem_node(pgdat, bitmap_size);
 		}
 	}
 }

_

--------------080600010704020100080309--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
