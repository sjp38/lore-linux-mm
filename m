Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4OCDBBa016985
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:13:11 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4OCC9uR523064
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:12:09 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4OCC906025149
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:12:09 -0400
Date: Thu, 24 May 2007 08:12:08 -0400
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20070524121208.13533.24962.sendpatchset@kleikamp.austin.ibm.com>
In-Reply-To: <20070524121130.13533.32563.sendpatchset@kleikamp.austin.ibm.com>
References: <20070524121130.13533.32563.sendpatchset@kleikamp.austin.ibm.com>
Subject: [RFC:PATCH 007/012] Avoid page_to_pfn() on tail page
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Avoid page_to_pfn() on tail page

On ppc64, we don't need bounce buffers to do I/O.  This will need more work
for other architectures.

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
---

 block/ll_rw_blk.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -Nurp linux006/block/ll_rw_blk.c linux007/block/ll_rw_blk.c
--- linux006/block/ll_rw_blk.c	2007-05-21 15:14:57.000000000 -0500
+++ linux007/block/ll_rw_blk.c	2007-05-23 22:53:12.000000000 -0500
@@ -1221,7 +1221,8 @@ void blk_recount_segments(request_queue_
 		 * considered part of another segment, since that might
 		 * change with the bounce page.
 		 */
-		high = page_to_pfn(bv->bv_page) > q->bounce_pfn;
+		high = (!PageFileTail(bv->bv_page) &&
+			page_to_pfn(bv->bv_page) > q->bounce_pfn);
 		if (high || highprv)
 			goto new_hw_segment;
 		if (cluster) {

-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
