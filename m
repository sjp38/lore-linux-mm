From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20060119190911.16909.76842.sendpatchset@skynet.csn.ul.ie>
In-Reply-To: <20060119190846.16909.14133.sendpatchset@skynet.csn.ul.ie>
References: <20060119190846.16909.14133.sendpatchset@skynet.csn.ul.ie>
Subject: [PATCH 5/5] ForTesting - Prevent OOM killer firing for high-order allocations
Date: Thu, 19 Jan 2006 19:09:11 +0000 (GMT)
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
diff -rup -X /usr/src/patchset-0.5/bin//dontdiff linux-2.6.16-rc1-mm1-104_ppc64coremem/mm/page_alloc.c linux-2.6.16-rc1-mm1-902_highorderoom/mm/page_alloc.c
--- linux-2.6.16-rc1-mm1-104_ppc64coremem/mm/page_alloc.c	2006-01-19 16:43:20.000000000 +0000
+++ linux-2.6.16-rc1-mm1-902_highorderoom/mm/page_alloc.c	2006-01-19 16:44:03.000000000 +0000
@@ -1080,8 +1080,11 @@ rebalance:
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
