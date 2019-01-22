Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 233D38E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 10:23:26 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id e68so15609712plb.3
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 07:23:26 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j17si5395880pfd.113.2019.01.22.07.23.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 07:23:25 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH] zsmalloc: no need to check return value of debugfs_create functions
Date: Tue, 22 Jan 2019 16:21:09 +0100
Message-Id: <20190122152151.16139-10-gregkh@linuxfoundation.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org

When calling debugfs functions, there is no need to ever check the
return value.  The function can work or not, but the code logic should
never do something different based on this.

Cc: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: linux-mm@kvack.org
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 mm/zsmalloc.c | 22 ++++------------------
 1 file changed, 4 insertions(+), 18 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 0787d33b80d8..1347d7922ea2 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -575,8 +575,6 @@ static void __init zs_stat_init(void)
 	}
 
 	zs_stat_root = debugfs_create_dir("zsmalloc", NULL);
-	if (!zs_stat_root)
-		pr_warn("debugfs 'zsmalloc' stat dir creation failed\n");
 }
 
 static void __exit zs_stat_exit(void)
@@ -654,22 +652,10 @@ static void zs_pool_stat_create(struct zs_pool *pool, const char *name)
 		return;
 	}
 
-	entry = debugfs_create_dir(name, zs_stat_root);
-	if (!entry) {
-		pr_warn("debugfs dir <%s> creation failed\n", name);
-		return;
-	}
-	pool->stat_dentry = entry;
-
-	entry = debugfs_create_file("classes", S_IFREG | 0444,
-				    pool->stat_dentry, pool,
-				    &zs_stats_size_fops);
-	if (!entry) {
-		pr_warn("%s: debugfs file entry <%s> creation failed\n",
-				name, "classes");
-		debugfs_remove_recursive(pool->stat_dentry);
-		pool->stat_dentry = NULL;
-	}
+	pool->stat_dentry = debugfs_create_dir(name, zs_stat_root);
+
+	debugfs_create_file("classes", S_IFREG | 0444, pool->stat_dentry, pool,
+			    &zs_stats_size_fops);
 }
 
 static void zs_pool_stat_destroy(struct zs_pool *pool)
-- 
2.20.1
