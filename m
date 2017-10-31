Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0A93C6B026C
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 06:38:01 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 15so16505451pgc.21
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 03:38:01 -0700 (PDT)
Received: from BJEXCAS006.didichuxing.com ([36.110.17.22])
        by mx.google.com with ESMTPS id a8si1224943pgu.368.2017.10.31.03.37.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 31 Oct 2017 03:37:59 -0700 (PDT)
Date: Tue, 31 Oct 2017 18:37:54 +0800
From: weiping zhang <zhangweiping@didichuxing.com>
Subject: [PATCH v2 1/3] bdi: convert bdi_debug_register to int
Message-ID: <8f8d9678f5843f7fd01588d2cc4f4dc3f21dd50b.1509415695.git.zhangweiping@didichuxing.com>
References: <cover.1509415695.git.zhangweiping@didichuxing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <cover.1509415695.git.zhangweiping@didichuxing.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, jack@suse.cz
Cc: linux-block@vger.kernel.org, linux-mm@kvack.org

Convert bdi_debug_register to int and then do error handle for it.

Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: weiping zhang <zhangweiping@didichuxing.com>
---
 mm/backing-dev.c | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 74b52dfd5852..b5f940ce0143 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -113,11 +113,23 @@ static const struct file_operations bdi_debug_stats_fops = {
 	.release	= single_release,
 };
 
-static void bdi_debug_register(struct backing_dev_info *bdi, const char *name)
+static int bdi_debug_register(struct backing_dev_info *bdi, const char *name)
 {
+	if (!bdi_debug_root)
+		return -ENOMEM;
+
 	bdi->debug_dir = debugfs_create_dir(name, bdi_debug_root);
+	if (!bdi->debug_dir)
+		return -ENOMEM;
+
 	bdi->debug_stats = debugfs_create_file("stats", 0444, bdi->debug_dir,
 					       bdi, &bdi_debug_stats_fops);
+	if (!bdi->debug_stats) {
+		debugfs_remove(bdi->debug_dir);
+		return -ENOMEM;
+	}
+
+	return 0;
 }
 
 static void bdi_debug_unregister(struct backing_dev_info *bdi)
@@ -129,9 +141,10 @@ static void bdi_debug_unregister(struct backing_dev_info *bdi)
 static inline void bdi_debug_init(void)
 {
 }
-static inline void bdi_debug_register(struct backing_dev_info *bdi,
+static inline int bdi_debug_register(struct backing_dev_info *bdi,
 				      const char *name)
 {
+	return 0;
 }
 static inline void bdi_debug_unregister(struct backing_dev_info *bdi)
 {
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
