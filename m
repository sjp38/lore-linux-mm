Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id 303126B0038
	for <linux-mm@kvack.org>; Fri, 14 Aug 2015 15:03:54 -0400 (EDT)
Received: by lbcbn3 with SMTP id bn3so50488312lbc.2
        for <linux-mm@kvack.org>; Fri, 14 Aug 2015 12:03:53 -0700 (PDT)
Received: from mail-la0-x22a.google.com (mail-la0-x22a.google.com. [2a00:1450:4010:c03::22a])
        by mx.google.com with ESMTPS id tk5si6527419lbb.14.2015.08.14.12.03.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Aug 2015 12:03:52 -0700 (PDT)
Received: by lalv9 with SMTP id v9so48973372lal.0
        for <linux-mm@kvack.org>; Fri, 14 Aug 2015 12:03:51 -0700 (PDT)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH] mm/memblock: validate the creation of debugfs files
Date: Sat, 15 Aug 2015 01:03:31 +0600
Message-Id: <1439579011-14918-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Baoquan He <bhe@redhat.com>, Tang Chen <tangchen@cn.fujitsu.com>, Robin Holt <holt@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Kuleshov <kuleshovmail@gmail.com>

Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
---
 mm/memblock.c | 24 +++++++++++++++++++++---
 1 file changed, 21 insertions(+), 3 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 87108e7..c09e911 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1692,16 +1692,34 @@ static const struct file_operations memblock_debug_fops = {
 
 static int __init memblock_init_debugfs(void)
 {
+	struct dentry *f;
 	struct dentry *root = debugfs_create_dir("memblock", NULL);
 	if (!root)
 		return -ENXIO;
-	debugfs_create_file("memory", S_IRUGO, root, &memblock.memory, &memblock_debug_fops);
-	debugfs_create_file("reserved", S_IRUGO, root, &memblock.reserved, &memblock_debug_fops);
+
+	f = debugfs_create_file("memory", S_IRUGO, root, &memblock.memory, &memblock_debug_fops);
+	if (!f) {
+		pr_err("Failed to create memory debugfs file\n");
+		goto err_out;
+	}
+
+	f = debugfs_create_file("reserved", S_IRUGO, root, &memblock.reserved, &memblock_debug_fops);
+	if (!f) {
+		pr_err("Failed to create reserved debugfs file\n");
+		goto err_out;
+	}
+
 #ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
-	debugfs_create_file("physmem", S_IRUGO, root, &memblock.physmem, &memblock_debug_fops);
+	f = debugfs_create_file("physmem", S_IRUGO, root, &memblock.physmem, &memblock_debug_fops);
+	if (!f) {
+		pr_err("Failed to create physmem debugfs file\n");
+		goto err_out;
+	}
 #endif
 
 	return 0;
+err_out:
+	return -ENOMEM;
 }
 __initcall(memblock_init_debugfs);
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
