Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id E9EF76B018A
	for <linux-mm@kvack.org>; Fri,  8 Nov 2013 04:50:17 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id w10so1918928pde.3
        for <linux-mm@kvack.org>; Fri, 08 Nov 2013 01:50:16 -0800 (PST)
Received: from psmtp.com ([74.125.245.118])
        by mx.google.com with SMTP id z1si5903854pbn.211.2013.11.08.01.50.15
        for <linux-mm@kvack.org>;
        Fri, 08 Nov 2013 01:50:16 -0800 (PST)
Received: by mail-pd0-f181.google.com with SMTP id x10so1895494pdj.40
        for <linux-mm@kvack.org>; Fri, 08 Nov 2013 01:50:13 -0800 (PST)
Message-ID: <1383904203.2715.2.camel@ubuntu>
Subject: [Patch 3.11.7 1/1]mm: remove and free expired data in time in zswap
From: "changkun.li" <xfishcoder@gmail.com>
Date: Fri, 08 Nov 2013 17:50:03 +0800
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@linux.vnet.ibm.com, linux-mm@kvack.org
Cc: luyi@360.cn, lichangkun@360.cn, linux-kernel@vger.kernel.org

In zswap, store page A to zbud if the compression ratio is high, insert
its entry into rbtree. if there is a entry B which has the same offset
in the rbtree.Remove and free B before insert the entry of A.

case:
if the compression ratio of page A is not high, return without checking
the same offset one in rbtree.

if there is a entry B which has the same offset in the rbtree. Now, we
make sure B is invalid or expired. But the entry and compressed memory
of B are not freed in time.

Because zswap spaces data in memory, it makes the utilization of memory
lower. the other valid data in zbud is writeback to swap device more
possibility, when zswap is full.

So if we make sure a entry is expired, free it in time.

Signed-off-by: changkun.li<xfishcoder@gmail.com>
---
 mm/zswap.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index cbd9578..90a2813 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -596,6 +596,7 @@ fail:
 	return ret;
 }
 
+static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t
offset);
 /*********************************
 * frontswap hooks
 **********************************/
@@ -614,7 +615,7 @@ static int zswap_frontswap_store(unsigned type,
pgoff_t offset,
 
 	if (!tree) {
 		ret = -ENODEV;
-		goto reject;
+		goto nodev;
 	}
 
 	/* reclaim space if needed */
@@ -695,6 +696,8 @@ freepage:
 	put_cpu_var(zswap_dstmem);
 	zswap_entry_cache_free(entry);
 reject:
+	zswap_frontswap_invalidate_page(type, offset);
+nodev:
 	return ret;
 }
 
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
