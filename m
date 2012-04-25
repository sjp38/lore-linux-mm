Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 72DB46B004D
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 16:00:13 -0400 (EDT)
Received: by dadq36 with SMTP id q36so661318dad.8
        for <linux-mm@kvack.org>; Wed, 25 Apr 2012 13:00:12 -0700 (PDT)
From: Sasikantha babu <sasikanth.v19@gmail.com>
Subject: [PATCH 2/2] mm: memblock - Handled failure of debug fs entries creation
Date: Thu, 26 Apr 2012 01:29:52 +0530
Message-Id: <1335383992-19419-1-git-send-email-sasikanth.v19@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, "H. Peter Anvin" <hpa@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasikantha babu <sasikanth.v19@gmail.com>

1) Removed already created debug fs entries on failure

2) Fixed coding style 80 char per line

Signed-off-by: Sasikantha babu <sasikanth.v19@gmail.com>
---
 mm/memblock.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index a44eab3..5553723 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -966,11 +966,19 @@ static int __init memblock_init_debugfs(void)
 {
 	struct dentry *root = debugfs_create_dir("memblock", NULL);
 	if (!root)
-		return -ENXIO;
-	debugfs_create_file("memory", S_IRUGO, root, &memblock.memory, &memblock_debug_fops);
-	debugfs_create_file("reserved", S_IRUGO, root, &memblock.reserved, &memblock_debug_fops);
+		return -ENOMEM;
+
+	if (!debugfs_create_file("memory", S_IRUGO, root, &memblock.memory,
+				&memblock_debug_fops))
+		goto fail;
+	if (!debugfs_create_file("reserved", S_IRUGO, root, &memblock.reserved,
+				&memblock_debug_fops))
+		goto fail;
 
 	return 0;
+fail:
+	debugfs_remove_recursive(root);
+	return -ENOMEM;
 }
 __initcall(memblock_init_debugfs);
 
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
