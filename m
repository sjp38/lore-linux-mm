Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id D18536B025E
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 13:36:26 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 189so5751120iow.14
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 10:36:26 -0700 (PDT)
Received: from BJEXCAS004.didichuxing.com (mx1.didichuxing.com. [111.202.154.82])
        by mx.google.com with ESMTPS id o6si1384282ito.16.2017.10.26.10.36.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 26 Oct 2017 10:36:25 -0700 (PDT)
Date: Fri, 27 Oct 2017 01:36:14 +0800
From: weiping zhang <zhangweiping@didichuxing.com>
Subject: [PATCH 3/4] bdi: add error handle for bdi_debug_register
Message-ID: <b28a35a3af256e2c64b905728b0e9df307e12b0b.1509038624.git.zhangweiping@didichuxing.com>
References: <cover.1509038624.git.zhangweiping@didichuxing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <cover.1509038624.git.zhangweiping@didichuxing.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, jack@suse.cz
Cc: linux-block@vger.kernel.org, linux-mm@kvack.org

In order to make error handle more cleaner we call bdi_debug_register
before set state to WB_registered, that we can avoid call bdi_unregister
in release_bdi().

Signed-off-by: weiping zhang <zhangweiping@didichuxing.com>
---
 mm/backing-dev.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index e9d6a1ede12b..54396d53f471 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -893,10 +893,13 @@ int bdi_register_va(struct backing_dev_info *bdi, const char *fmt, va_list args)
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
@@ -916,6 +919,8 @@ int bdi_register(struct backing_dev_info *bdi, const char *fmt, ...)
 	va_start(args, fmt);
 	ret = bdi_register_va(bdi, fmt, args);
 	va_end(args);
+	if (ret)
+		bdi_put(bdi);
 	return ret;
 }
 EXPORT_SYMBOL(bdi_register);
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
