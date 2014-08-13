Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id C46846B0037
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 08:11:41 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id l18so11009049wgh.26
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 05:11:41 -0700 (PDT)
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
        by mx.google.com with ESMTPS id pz1si1985707wjc.19.2014.08.13.05.11.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 13 Aug 2014 05:11:40 -0700 (PDT)
Received: by mail-we0-f173.google.com with SMTP id q58so11332161wes.18
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 05:11:40 -0700 (PDT)
Message-ID: <53EB55FA.3090904@plexistor.com>
Date: Wed, 13 Aug 2014 15:11:38 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [RFC 2/9] prd: add support for rw_page()
References: <53EB5536.8020702@gmail.com>
In-Reply-To: <53EB5536.8020702@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

From: Ross Zwisler <ross.zwisler@linux.intel.com>

Based on commit a72132c31d58 brd: add support for rw_page()

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 drivers/block/prd.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/block/prd.c b/drivers/block/prd.c
index 7684197..4cfc4f8 100644
--- a/drivers/block/prd.c
+++ b/drivers/block/prd.c
@@ -185,6 +185,16 @@ out:
 	bio_endio(bio, err);
 }
 
+static int prd_rw_page(struct block_device *bdev, sector_t sector,
+		       struct page *page, int rw)
+{
+	struct prd_device *prd = bdev->bd_disk->private_data;
+
+	prd_do_bvec(prd, page, PAGE_CACHE_SIZE, 0, rw, sector);
+	page_endio(page, rw & WRITE, 0);
+	return 0;
+}
+
 static long prd_direct_access(struct block_device *bdev, sector_t sector,
 			      void **kaddr, unsigned long *pfn, long size)
 {
@@ -201,6 +211,7 @@ static long prd_direct_access(struct block_device *bdev, sector_t sector,
 
 static const struct block_device_operations prd_fops = {
 	.owner =		THIS_MODULE,
+	.rw_page =		prd_rw_page,
 	.direct_access =	prd_direct_access,
 };
 
-- 
1.9.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
