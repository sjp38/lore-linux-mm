From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20060126184545.8550.7404.sendpatchset@skynet.csn.ul.ie>
In-Reply-To: <20060126184305.8550.94358.sendpatchset@skynet.csn.ul.ie>
References: <20060126184305.8550.94358.sendpatchset@skynet.csn.ul.ie>
Subject: [PATCH 8/9] ForTesting - Prevent OOM killer firing for high-order allocations
Date: Thu, 26 Jan 2006 18:45:45 +0000 (GMT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Stop going OOM for high-order allocations. During testing of high order
allocations, we do not want the OOM killing everything in sight.

For comparison between kernels during the high order allocatioon stress
test, this patch is applied to both the stock -mm kernel and the kernel
using ZONE_EASYRCLM.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.16-rc1-mm3-108_docs/mm/page_alloc.c linux-2.6.16-rc1-mm3-902_highorderoom/mm/page_alloc.c
--- linux-2.6.16-rc1-mm3-108_docs/mm/page_alloc.c	2006-01-26 18:10:29.000000000 +0000
+++ linux-2.6.16-rc1-mm3-902_highorderoom/mm/page_alloc.c	2006-01-26 18:15:07.000000000 +0000
@@ -1095,8 +1095,11 @@ rebalance:
 		if (page)
 			goto got_pg;
 
-		out_of_memory(gfp_mask, order);
-		goto restart;
+		/* Only go OOM for low-order allocations */
+		if (order <= 3) {
+			out_of_memory(gfp_mask, order);
+			goto restart;
+		}
 	}
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
