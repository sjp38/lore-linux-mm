Received: by ug-out-1314.google.com with SMTP id s2so1539171uge
        for <linux-mm@kvack.org>; Mon, 18 Dec 2006 19:01:36 -0800 (PST)
Message-ID: <6d6a94c50612181901m1bfd9d1bsc2d9496ab24eb3f8@mail.gmail.com>
Date: Tue, 19 Dec 2006 11:01:36 +0800
From: Aubrey <aubreylee@gmail.com>
Subject: [RFC][PATCH] Fix area->nr_free-- went (-1) issue in buddy system
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

When I setup two zones (NORMAL and DMA) in my system, I got the
following wired result from /proc/buddyinfo.
-----------------------------------------------------------------------------------------
root:~> cat /proc/buddyinfo
Node 0, zone      DMA      2      1      2      1      1      0      0
     1      1      2      2      0      0      0
Node 0, zone   Normal      1      1      1      1      1      1      0
     0 4294967295      0 4294967295      2      0      0
-----------------------------------------------------------------------------------------

As you see, two area->nr_free went -1.

After dig into the code, I found the problem is in the fun
__free_one_page() when the kernel boot up call free_all_bootmem(). If
two zones setup, it's possible NORMAL zone merged a block whose order
=8 at the first time(this time zone[NORMA]->free_area[8].nr_free = 0)
and found its buddy in the DMA zone. So the two blocks will be merged
and area->nr_free went to -1.

My proposed patch is as follows:


Signed-off-by: Aubrey Li <aubreylee@gmail.com>
---------------------------------------------------------------------------------------------------
--- page_alloc.c.orig	2006-12-19 10:45:25.000000000 +0800
+++ page_alloc.c	2006-12-19 10:44:48.000000000 +0800
@@ -407,7 +407,8 @@ static inline void __free_one_page(struc

 		list_del(&buddy->lru);
 		area = zone->free_area + order;
-		area->nr_free--;
+		if (area->nr_free > 0)
+			area->nr_free--;
 		rmv_page_order(buddy);
 		combined_idx = __find_combined_index(page_idx, order);
 		page = page + (combined_idx - page_idx);
----------------------------------------------------------------------------------------------------
Any comments?

Thanks,
-Aubrey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
