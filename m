Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3EB0C6B0033
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 13:37:12 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 134so5618349ioo.22
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 10:37:12 -0700 (PDT)
Received: from BJEXCAS005.didichuxing.com ([36.110.17.22])
        by mx.google.com with ESMTPS id a134si4005285ioe.41.2017.10.26.10.37.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 26 Oct 2017 10:37:11 -0700 (PDT)
Date: Fri, 27 Oct 2017 01:36:42 +0800
From: weiping zhang <zhangweiping@didichuxing.com>
Subject: [PATCH 4/4] block: add WARN_ON if bdi register fail
Message-ID: <413b04ba6a2a0b03b0cb3c578865d71b2ef97921.1509038624.git.zhangweiping@didichuxing.com>
References: <cover.1509038624.git.zhangweiping@didichuxing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <cover.1509038624.git.zhangweiping@didichuxing.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, jack@suse.cz
Cc: linux-block@vger.kernel.org, linux-mm@kvack.org

device_add_disk need do more safety error handle, so this patch just
add WARN_ON.

Signed-off-by: weiping zhang <zhangweiping@didichuxing.com>
---
 block/genhd.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/block/genhd.c b/block/genhd.c
index dd305c65ffb0..cb55eea821eb 100644
--- a/block/genhd.c
+++ b/block/genhd.c
@@ -660,7 +660,9 @@ void device_add_disk(struct device *parent, struct gendisk *disk)
 
 	/* Register BDI before referencing it from bdev */
 	bdi = disk->queue->backing_dev_info;
-	bdi_register_owner(bdi, disk_to_dev(disk));
+	retval = bdi_register_owner(bdi, disk_to_dev(disk));
+	if (retval)
+		WARN_ON(1);
 
 	blk_register_region(disk_devt(disk), disk->minors, NULL,
 			    exact_match, exact_lock, disk);
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
