Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8A9EE6B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 08:12:45 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id f8so7290672wiw.6
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 05:12:44 -0700 (PDT)
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
        by mx.google.com with ESMTPS id b2si2334173wie.27.2014.08.13.05.12.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 13 Aug 2014 05:12:44 -0700 (PDT)
Received: by mail-we0-f173.google.com with SMTP id q58so11333354wes.18
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 05:12:43 -0700 (PDT)
Message-ID: <53EB563A.5030805@plexistor.com>
Date: Wed, 13 Aug 2014 15:12:42 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [RFC 3/9] prd: Add getgeo to block ops
References: <53EB5536.8020702@gmail.com>
In-Reply-To: <53EB5536.8020702@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

From: Ross Zwisler <ross.zwisler@linux.intel.com>

Some programs require HDIO_GETGEO work, which requires we implement
getgeo.  Based off of the work done to the NVMe driver in this commit:

4cc09e2dc4cb NVMe: Add getgeo to block ops

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 drivers/block/prd.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/block/prd.c b/drivers/block/prd.c
index 4cfc4f8..cc0aabf 100644
--- a/drivers/block/prd.c
+++ b/drivers/block/prd.c
@@ -19,6 +19,7 @@
 #include <linux/bio.h>
 #include <linux/blkdev.h>
 #include <linux/fs.h>
+#include <linux/hdreg.h>
 #include <linux/highmem.h>
 #include <linux/init.h>
 #include <linux/major.h>
@@ -52,6 +53,15 @@ struct prd_device {
 	size_t			size;
 };
 
+static int prd_getgeo(struct block_device *bd, struct hd_geometry *geo)
+{
+	/* some standard values */
+	geo->heads = 1 << 6;
+	geo->sectors = 1 << 5;
+	geo->cylinders = get_capacity(bd->bd_disk) >> 11;
+	return 0;
+}
+
 /*
  * direct translation from (prd,sector) => void*
  * We do not require that sector be page aligned.
@@ -213,6 +223,7 @@ static const struct block_device_operations prd_fops = {
 	.owner =		THIS_MODULE,
 	.rw_page =		prd_rw_page,
 	.direct_access =	prd_direct_access,
+	.getgeo =		prd_getgeo,
 };
 
 /* Kernel module stuff */
-- 
1.9.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
