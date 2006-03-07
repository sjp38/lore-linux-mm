From: Con Kolivas <kernel@kolivas.org>
Subject: [PATCH] mm: yield during swap prefetching
Date: Wed, 8 Mar 2006 10:13:44 +1100
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200603081013.44678.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, ck@vds.kolivas.org
List-ID: <linux-mm.kvack.org>

Swap prefetching doesn't use very much cpu but spends a lot of time waiting on 
disk in uninterruptible sleep. This means it won't get preempted often even at 
a low nice level since it is seen as sleeping most of the time. We want to 
minimise its cpu impact so yield where possible.

Signed-off-by: Con Kolivas <kernel@kolivas.org>
---
 mm/swap_prefetch.c |    1 +
 1 file changed, 1 insertion(+)

Index: linux-2.6.15-ck5/mm/swap_prefetch.c
===================================================================
--- linux-2.6.15-ck5.orig/mm/swap_prefetch.c	2006-03-02 14:00:46.000000000 +1100
+++ linux-2.6.15-ck5/mm/swap_prefetch.c	2006-03-08 08:49:32.000000000 +1100
@@ -421,6 +421,7 @@ static enum trickle_return trickle_swap(
 
 		if (trickle_swap_cache_async(swp_entry, node) == TRICKLE_DELAY)
 			break;
+		yield();
 	}
 
 	if (sp_stat.prefetched_pages) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
