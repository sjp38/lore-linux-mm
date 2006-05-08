Received: by nz-out-0102.google.com with SMTP id 14so1075561nzn
        for <linux-mm@kvack.org>; Sun, 07 May 2006 18:18:09 -0700 (PDT)
Date: Sun, 7 May 2006 18:17:02 -0700 (PDT)
Subject: [PATCH] fix can_share_swap_page() when !CONFIG_SWAP
Message-ID: <Pine.LNX.4.64.0605071525550.2515@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
From: Hua Zhong <hzhong@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

can_share_swap_page() is used to check if the page has the last reference. This avoids allocating a new page for COW if it's the last page.

However, if CONFIG_SWAP is not set, can_share_swap_page() is defined as 0, thus always causes a copy for the last COW page. The below simple patch fixes it.

I'm not sure if it's the best fix. Maybe we should rename can_share_swap_page() and move it out of swapfile.c. Comments?

Signed-off-by: Hua Zhong <hzhong@gmail.com>

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 5b1fdf1..f03c247 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -296,7 +296,7 @@ #define swap_free(swp)				/*NOTHING*/
 #define read_swap_cache_async(swp,vma,addr)	NULL
 #define lookup_swap_cache(swp)			NULL
 #define valid_swaphandles(swp, off)		0
-#define can_share_swap_page(p)			0
+#define can_share_swap_page(p)			(page_mapcount(p) == 1)
 #define move_to_swap_cache(p, swp)		1
 #define move_from_swap_cache(p, i, m)		1
 #define __delete_from_swap_cache(p)		/*NOTHING*/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
