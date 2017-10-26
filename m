Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 493A06B0069
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 13:35:44 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id n79so5630157ion.17
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 10:35:44 -0700 (PDT)
Received: from BJEXCAS004.didichuxing.com (mx1.didichuxing.com. [111.202.154.82])
        by mx.google.com with ESMTPS id w10si3941023iof.246.2017.10.26.10.35.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 26 Oct 2017 10:35:42 -0700 (PDT)
Date: Fri, 27 Oct 2017 01:35:36 +0800
From: weiping zhang <zhangweiping@didichuxing.com>
Subject: [PATCH 1/4] bdi: add check for bdi_debug_root
Message-ID: <883f8bb529fbde0d4adc2b78ba3bbda81e1ce6a0.1509038624.git.zhangweiping@didichuxing.com>
References: <cover.1509038624.git.zhangweiping@didichuxing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <cover.1509038624.git.zhangweiping@didichuxing.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, jack@suse.cz
Cc: linux-block@vger.kernel.org, linux-mm@kvack.org

this patch add a check for bdi_debug_root and do error handle for it.
we should make sure it was created success, otherwise when add new
block device's bdi folder(eg, 8:0) will be create a debugfs root directory.

Signed-off-by: weiping zhang <zhangweiping@didichuxing.com>
---
 mm/backing-dev.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 74b52dfd5852..5072be19d9b2 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -36,9 +36,12 @@ struct workqueue_struct *bdi_wq;
 
 static struct dentry *bdi_debug_root;
 
-static void bdi_debug_init(void)
+static int bdi_debug_init(void)
 {
 	bdi_debug_root = debugfs_create_dir("bdi", NULL);
+	if (!bdi_debug_root)
+		return -ENOMEM;
+	return 0;
 }
 
 static int bdi_debug_stats_show(struct seq_file *m, void *v)
@@ -126,8 +129,9 @@ static void bdi_debug_unregister(struct backing_dev_info *bdi)
 	debugfs_remove(bdi->debug_dir);
 }
 #else
-static inline void bdi_debug_init(void)
+static inline int bdi_debug_init(void)
 {
+	return 0;
 }
 static inline void bdi_debug_register(struct backing_dev_info *bdi,
 				      const char *name)
@@ -229,12 +233,19 @@ ATTRIBUTE_GROUPS(bdi_dev);
 
 static __init int bdi_class_init(void)
 {
+	int ret;
+
 	bdi_class = class_create(THIS_MODULE, "bdi");
 	if (IS_ERR(bdi_class))
 		return PTR_ERR(bdi_class);
 
 	bdi_class->dev_groups = bdi_dev_groups;
-	bdi_debug_init();
+	ret = bdi_debug_init();
+	if (ret) {
+		class_destroy(bdi_class);
+		bdi_class = NULL;
+		return ret;
+	}
 
 	return 0;
 }
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
