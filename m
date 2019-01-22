Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C0C738E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 10:23:20 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id r13so16656263pgb.7
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 07:23:20 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w6si14892048pfb.191.2019.01.22.07.23.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 07:23:19 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH] backing-dev: no need to check return value of debugfs_create functions
Date: Tue, 22 Jan 2019 16:21:07 +0100
Message-Id: <20190122152151.16139-8-gregkh@linuxfoundation.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Anders Roxell <anders.roxell@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org

When calling debugfs functions, there is no need to ever check the
return value.  The function can work or not, but the code logic should
never do something different based on this.

And as the return value does not matter at all, no need to save the
dentry in struct backing_dev_info, so delete it.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Anders Roxell <anders.roxell@linaro.org>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 include/linux/backing-dev-defs.h |  1 -
 mm/backing-dev.c                 | 24 +++++-------------------
 2 files changed, 5 insertions(+), 20 deletions(-)

diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index c31157135598..7f64d813580b 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -202,7 +202,6 @@ struct backing_dev_info {
 
 #ifdef CONFIG_DEBUG_FS
 	struct dentry *debug_dir;
-	struct dentry *debug_stats;
 #endif
 };
 
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 8a8bb8796c6c..85ef344a9c67 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -102,39 +102,25 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 }
 DEFINE_SHOW_ATTRIBUTE(bdi_debug_stats);
 
-static int bdi_debug_register(struct backing_dev_info *bdi, const char *name)
+static void bdi_debug_register(struct backing_dev_info *bdi, const char *name)
 {
-	if (!bdi_debug_root)
-		return -ENOMEM;
-
 	bdi->debug_dir = debugfs_create_dir(name, bdi_debug_root);
-	if (!bdi->debug_dir)
-		return -ENOMEM;
-
-	bdi->debug_stats = debugfs_create_file("stats", 0444, bdi->debug_dir,
-					       bdi, &bdi_debug_stats_fops);
-	if (!bdi->debug_stats) {
-		debugfs_remove(bdi->debug_dir);
-		bdi->debug_dir = NULL;
-		return -ENOMEM;
-	}
 
-	return 0;
+	debugfs_create_file("stats", 0444, bdi->debug_dir, bdi,
+			    &bdi_debug_stats_fops);
 }
 
 static void bdi_debug_unregister(struct backing_dev_info *bdi)
 {
-	debugfs_remove(bdi->debug_stats);
-	debugfs_remove(bdi->debug_dir);
+	debugfs_remove_recursive(bdi->debug_dir);
 }
 #else
 static inline void bdi_debug_init(void)
 {
 }
-static inline int bdi_debug_register(struct backing_dev_info *bdi,
+static inline void bdi_debug_register(struct backing_dev_info *bdi,
 				      const char *name)
 {
-	return 0;
 }
 static inline void bdi_debug_unregister(struct backing_dev_info *bdi)
 {
-- 
2.20.1
