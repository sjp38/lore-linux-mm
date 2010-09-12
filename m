Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 388626B0099
	for <linux-mm@kvack.org>; Sun, 12 Sep 2010 11:55:03 -0400 (EDT)
Message-Id: <20100912155205.108097852@intel.com>
Date: Sun, 12 Sep 2010 23:50:01 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 16/17] mm: create /vm/dirty_pressure in debugfs
References: <20100912154945.758129106@intel.com>
Content-Disposition: inline; filename=mm-debugfs-dirty-pressure.patch
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Li Shaohua <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

Create /debug/vm/ -- a convenient place for kernel hackers to play with
VM variables.

The first exported is vm_dirty_pressure for avoiding excessive pageout()s.
It ranges from 0 to 1024, the lower value, the lower dirty limit.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/vmstat.c |   29 +++++++++++++++++++++++++++--
 1 file changed, 27 insertions(+), 2 deletions(-)

--- linux-next.orig/mm/vmstat.c	2010-09-12 09:50:57.000000000 +0800
+++ linux-next/mm/vmstat.c	2010-09-12 13:27:44.000000000 +0800
@@ -1045,9 +1045,33 @@ static int __init setup_vmstat(void)
 }
 module_init(setup_vmstat)
 
-#if defined(CONFIG_DEBUG_FS) && defined(CONFIG_COMPACTION)
+#if defined(CONFIG_DEBUG_FS)
 #include <linux/debugfs.h>
+#include <linux/writeback.h>
 
+static struct dentry *vm_debug_root;
+
+static int __init vm_debug_init(void)
+{
+	struct dentry *dentry;
+
+	vm_debug_root = debugfs_create_dir("vm", NULL);
+	if (!vm_debug_root)
+		goto fail;
+
+	dentry = debugfs_create_u32("dirty_pressure", 0644,
+				    vm_debug_root, &vm_dirty_pressure);
+	if (!dentry)
+		goto fail;
+
+	return 0;
+fail:
+	return -ENOMEM;
+}
+
+module_init(vm_debug_init);
+
+#if defined(CONFIG_COMPACTION)
 static struct dentry *extfrag_debug_root;
 
 /*
@@ -1202,4 +1226,5 @@ static int __init extfrag_debug_init(voi
 }
 
 module_init(extfrag_debug_init);
-#endif
+#endif /* CONFIG_COMPACTION */
+#endif /* CONFIG_DEBUG_FS */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
