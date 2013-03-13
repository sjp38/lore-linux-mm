Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 53E086B0038
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 03:06:30 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 13 Mar 2013 12:32:10 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 6700E1258051
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 12:37:28 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2D76KOX31850528
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 12:36:20 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2D76Mau026714
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 18:06:24 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH] zram: fix zram_bvec_read duplicate dump failure message and stat accumulation
Date: Wed, 13 Mar 2013 15:06:16 +0800
Message-Id: <1363158376-20954-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

When zram decompress fails, the code unnecessarily dumps failure messages and
does stat accumulation in function zram_decompress_page(), this work is already 
done in function zram_decompress_page, the patch skips the redundant work.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 drivers/staging/zram/zram_drv.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
index 5918fd7..e34e3fe 100644
--- a/drivers/staging/zram/zram_drv.c
+++ b/drivers/staging/zram/zram_drv.c
@@ -207,11 +207,8 @@ static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
 
 	ret = zram_decompress_page(zram, uncmem, index);
 	/* Should NEVER happen. Return bio error if it does. */
-	if (unlikely(ret != LZO_E_OK)) {
-		pr_err("Decompression failed! err=%d, page=%u\n", ret, index);
-		zram_stat64_inc(zram, &zram->stats.failed_reads);
+	if (unlikely(ret != LZO_E_OK))
 		goto out_cleanup;
-	}
 
 	if (is_partial_io(bvec))
 		memcpy(user_mem + bvec->bv_offset, uncmem + offset,
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
