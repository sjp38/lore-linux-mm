Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id A02196B0254
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 03:54:54 -0400 (EDT)
Received: by lalv9 with SMTP id v9so92633138lal.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 00:54:54 -0700 (PDT)
Received: from mail-lb0-x22a.google.com (mail-lb0-x22a.google.com. [2a00:1450:4010:c04::22a])
        by mx.google.com with ESMTPS id s12si15396863lbp.106.2015.08.25.00.54.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 00:54:53 -0700 (PDT)
Received: by lbcbn3 with SMTP id bn3so94278054lbc.2
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 00:54:52 -0700 (PDT)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH] mm/backing-dev: Check return value of the debugfs_create_dir()
Date: Tue, 25 Aug 2015 13:54:23 +0600
Message-Id: <1440489263-3547-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Kuleshov <kuleshovmail@gmail.com>

The debugfs_create_dir() function may fail and return error. If the
root directory not created, we can't create anything inside it. This
patch adds check for this case.

Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
---
 mm/backing-dev.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index dac5bf5..518d26a 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -117,15 +117,21 @@ static const struct file_operations bdi_debug_stats_fops = {
 
 static void bdi_debug_register(struct backing_dev_info *bdi, const char *name)
 {
-	bdi->debug_dir = debugfs_create_dir(name, bdi_debug_root);
-	bdi->debug_stats = debugfs_create_file("stats", 0444, bdi->debug_dir,
-					       bdi, &bdi_debug_stats_fops);
+	if (bdi_debug_root) {
+		bdi->debug_dir = debugfs_create_dir(name, bdi_debug_root);
+		if (bdi->debug_dir)
+			bdi->debug_stats = debugfs_create_file("stats", 0444,
+							bdi->debug_dir, bdi,
+							&bdi_debug_stats_fops);
+	}
 }
 
 static void bdi_debug_unregister(struct backing_dev_info *bdi)
 {
-	debugfs_remove(bdi->debug_stats);
-	debugfs_remove(bdi->debug_dir);
+	if (bdi_debug_root) {
+		debugfs_remove(bdi->debug_stats);
+		debugfs_remove(bdi->debug_dir);
+	}
 }
 #else
 static inline void bdi_debug_init(void)
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
