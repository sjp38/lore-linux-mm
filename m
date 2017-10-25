Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BE2376B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 11:23:33 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id s75so196159pgs.12
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 08:23:33 -0700 (PDT)
Received: from BJEXCAS004.didichuxing.com ([36.110.17.22])
        by mx.google.com with ESMTPS id w16si1683476plp.130.2017.10.25.08.23.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 25 Oct 2017 08:23:32 -0700 (PDT)
Date: Wed, 25 Oct 2017 23:23:18 +0800
From: weiping zhang <zhangweiping@didichuxing.com>
Subject: [PATCH] bdi: add check before create debugfs dir or files
Message-ID: <20171025152312.GA23944@source.didichuxing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, jack@suse.cz
Cc: linux-mm@kvack.org

we should make sure parents directory exist, and then create dir or
files under that.

Signed-off-by: weiping zhang <zhangweiping@didichuxing.com>
---
 mm/backing-dev.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 74b52dfd5852..81f4a86ebbed 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -115,9 +115,11 @@ static const struct file_operations bdi_debug_stats_fops = {
 
 static void bdi_debug_register(struct backing_dev_info *bdi, const char *name)
 {
-	bdi->debug_dir = debugfs_create_dir(name, bdi_debug_root);
-	bdi->debug_stats = debugfs_create_file("stats", 0444, bdi->debug_dir,
-					       bdi, &bdi_debug_stats_fops);
+	if (bdi_debug_root)
+		bdi->debug_dir = debugfs_create_dir(name, bdi_debug_root);
+	if (bdi->debug_dir)
+		bdi->debug_stats = debugfs_create_file("stats", 0444,
+				bdi->debug_dir, bdi, &bdi_debug_stats_fops);
 }
 
 static void bdi_debug_unregister(struct backing_dev_info *bdi)
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
