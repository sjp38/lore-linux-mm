Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id D925E6B004D
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 15:08:59 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so5442856pbc.14
        for <linux-mm@kvack.org>; Mon, 23 Apr 2012 12:08:59 -0700 (PDT)
From: Sasikantha babu <sasikanth.v19@gmail.com>
Subject: [PATCH] mm:vmstat - Removed debug fs entries on failure of file creation and made extfrag_debug_root dentry local
Date: Tue, 24 Apr 2012 00:38:46 +0530
Message-Id: <1335208126-25919-1-git-send-email-sasikanth.v19@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasikantha babu <sasikanth.v19@gmail.com>

"Please Ignore my previous patch in which I had used alias name"

Removed debug fs files and directory on failure. Since no one using "extfrag_debug_root" dentry outside of function
extfrag_debug_init made it local to the function.

Signed-off-by: Sasikantha babu <sasikanth.v19@gmail.com>
---
 mm/vmstat.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index f600557..ddae476 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1220,7 +1220,6 @@ module_init(setup_vmstat)
 #if defined(CONFIG_DEBUG_FS) && defined(CONFIG_COMPACTION)
 #include <linux/debugfs.h>
 
-static struct dentry *extfrag_debug_root;
 
 /*
  * Return an index indicating how much of the available free memory is
@@ -1358,17 +1357,23 @@ static const struct file_operations extfrag_file_ops = {
 
 static int __init extfrag_debug_init(void)
 {
+	struct dentry *extfrag_debug_root;
+
 	extfrag_debug_root = debugfs_create_dir("extfrag", NULL);
 	if (!extfrag_debug_root)
 		return -ENOMEM;
 
 	if (!debugfs_create_file("unusable_index", 0444,
-			extfrag_debug_root, NULL, &unusable_file_ops))
+			extfrag_debug_root, NULL, &unusable_file_ops)) {
+		debugfs_remove (extfrag_debug_root);
 		return -ENOMEM;
+	}
 
 	if (!debugfs_create_file("extfrag_index", 0444,
-			extfrag_debug_root, NULL, &extfrag_file_ops))
+			extfrag_debug_root, NULL, &extfrag_file_ops)) {
+		debugfs_remove_recursive (extfrag_debug_root);
 		return -ENOMEM;
+	}
 
 	return 0;
 }
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
