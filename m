Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id ED0646B0253
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 13:36:07 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id h70so5730848ioi.5
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 10:36:07 -0700 (PDT)
Received: from BJEXCAS007.didichuxing.com (mx1.didichuxing.com. [111.202.154.82])
        by mx.google.com with ESMTPS id c127si1322296ite.150.2017.10.26.10.36.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 26 Oct 2017 10:36:06 -0700 (PDT)
Date: Fri, 27 Oct 2017 01:35:57 +0800
From: weiping zhang <zhangweiping@didichuxing.com>
Subject: [PATCH 2/4] bdi: convert bdi_debug_register to int
Message-ID: <2c475848d5aa52f54e7c2440a0f5b06791980aac.1509038624.git.zhangweiping@didichuxing.com>
References: <cover.1509038624.git.zhangweiping@didichuxing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <cover.1509038624.git.zhangweiping@didichuxing.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, jack@suse.cz
Cc: linux-block@vger.kernel.org, linux-mm@kvack.org

Convert bdi_debug_register to int and then do error handle for it.

Signed-off-by: weiping zhang <zhangweiping@didichuxing.com>
---
 mm/backing-dev.c | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 5072be19d9b2..e9d6a1ede12b 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -116,11 +116,23 @@ static const struct file_operations bdi_debug_stats_fops = {
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
@@ -133,9 +145,10 @@ static inline int bdi_debug_init(void)
 {
 	return 0;
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
