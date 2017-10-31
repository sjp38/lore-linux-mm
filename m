Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0CDD56B026D
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 06:38:32 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id a192so16543734pge.1
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 03:38:32 -0700 (PDT)
Received: from BJEXMBX012.didichuxing.com (mx1.didichuxing.com. [111.202.154.82])
        by mx.google.com with ESMTPS id 204si1302891pga.183.2017.10.31.03.38.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 31 Oct 2017 03:38:30 -0700 (PDT)
Date: Tue, 31 Oct 2017 18:38:24 +0800
From: weiping zhang <zhangweiping@didichuxing.com>
Subject: [PATCH v2 2/3] bdi: add error handle for bdi_debug_register
Message-ID: <100ecef9a09dc2a95feb5f6fac21c8bfa26be4eb.1509415695.git.zhangweiping@didichuxing.com>
References: <cover.1509415695.git.zhangweiping@didichuxing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <cover.1509415695.git.zhangweiping@didichuxing.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, jack@suse.cz
Cc: linux-block@vger.kernel.org, linux-mm@kvack.org

In order to make error handle more cleaner we call bdi_debug_register
before set state to WB_registered, that we can avoid call bdi_unregister
in release_bdi().

Signed-off-by: weiping zhang <zhangweiping@didichuxing.com>
---
 mm/backing-dev.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index b5f940ce0143..84b2dc76f140 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -882,10 +882,13 @@ int bdi_register_va(struct backing_dev_info *bdi, const char *fmt, va_list args)
 	if (IS_ERR(dev))
 		return PTR_ERR(dev);
 
+	if (bdi_debug_register(bdi, dev_name(dev))) {
+		device_destroy(bdi_class, dev->devt);
+		return -ENOMEM;
+	}
 	cgwb_bdi_register(bdi);
 	bdi->dev = dev;
 
-	bdi_debug_register(bdi, dev_name(dev));
 	set_bit(WB_registered, &bdi->wb.state);
 
 	spin_lock_bh(&bdi_lock);
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
