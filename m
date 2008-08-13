Message-Id: <6.0.0.20.2.20080813111835.03d345b0@172.19.0.2>
Date: Wed, 13 Aug 2008 11:21:16 +0900
From: Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>
Subject: [PATCH] vmscan: set try_to_release_page's gfp_mask to 0
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi.

shrink_page_list passes gfp_mask to try_to_release_page.
When shrink_page_list is called from kswapd or buddy system, gfp_mask is set
and (gfp_mask & __GFP_WAIT) and (gfp_mask & __GFP_FS) check is positive.
releasepage of jbd/jbd2(ext3/4, ocfs2) and XFS use this parameter. 
If try_to_free_page fails due to bh busy in jbd/jbd2, jbd/jbd2 lets a thread wait for 
committing transaction. I think this has big performance impacts for vmscan.
So I modified shrink_page_list not to pass gfp_mask to try_to_release_page
in ordered to improve vmscan performance.

Thanks.

Signed-off-by: Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>

diff -Nrup linux-2.6.27-rc2.org/mm/vmscan.c linux-2.6.27-rc2.vmscan/mm/vmscan.c
--- linux-2.6.27-rc2.org/mm/vmscan.c	2008-08-11 14:33:24.000000000 +0900
+++ linux-2.6.27-rc2.vmscan/mm/vmscan.c	2008-08-12 18:57:05.000000000 +0900
@@ -614,7 +614,7 @@ static unsigned long shrink_page_list(st
 		* Otherwise, leave the page on the LRU so it is swappable.
 		*/
 		if (PagePrivate(page)) {
-			if (!try_to_release_page(page, sc->gfp_mask))
+			if (!try_to_release_page(page, 0))
 				goto activate_locked;
 			if (!mapping && page_count(page) == 1) {
 				unlock_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
