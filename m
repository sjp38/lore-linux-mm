Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id E25A46B0037
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 00:23:17 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id y14so6552422pdi.16
        for <linux-mm@kvack.org>; Tue, 11 Jun 2013 21:23:17 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 2/8] vrange: Add vrange support for file address_spaces
Date: Tue, 11 Jun 2013 21:22:45 -0700
Message-Id: <1371010971-15647-3-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1371010971-15647-1-git-send-email-john.stultz@linaro.org>
References: <1371010971-15647-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dgiani@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Modify address_space structures to be able to store vrange trees.

This includes logic to clear all volatile ranges when the last
file handle is closed.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Andrea Righi <andrea@betterlinux.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: Dhaval Giani <dgiani@mozilla.com>
Cc: Jan Kara <jack@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Signed-off-by: John Stultz <john.stultz@linaro.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
[jstultz: Major refactoring of the code]
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 fs/file_table.c    | 5 +++++
 fs/inode.c         | 2 ++
 include/linux/fs.h | 2 ++
 3 files changed, 9 insertions(+)

diff --git a/fs/file_table.c b/fs/file_table.c
index cd4d87a..94e2cd3 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -26,6 +26,7 @@
 #include <linux/hardirq.h>
 #include <linux/task_work.h>
 #include <linux/ima.h>
+#include <linux/vrange.h>
 
 #include <linux/atomic.h>
 
@@ -244,6 +245,10 @@ static void __fput(struct file *file)
 			file->f_op->fasync(-1, file, 0);
 	}
 	ima_file_free(file);
+
+	/* drop all vranges on last close */
+	vrange_root_cleanup(&inode->i_mapping->vroot);
+
 	if (file->f_op && file->f_op->release)
 		file->f_op->release(inode, file);
 	security_file_free(file);
diff --git a/fs/inode.c b/fs/inode.c
index 00d5fc3..bf32780 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -17,6 +17,7 @@
 #include <linux/prefetch.h>
 #include <linux/buffer_head.h> /* for inode_has_buffers */
 #include <linux/ratelimit.h>
+#include <linux/vrange.h>
 #include "internal.h"
 
 /*
@@ -350,6 +351,7 @@ void address_space_init_once(struct address_space *mapping)
 	spin_lock_init(&mapping->private_lock);
 	mapping->i_mmap = RB_ROOT;
 	INIT_LIST_HEAD(&mapping->i_mmap_nonlinear);
+	vrange_root_init(&mapping->vroot, VRANGE_FILE);
 }
 EXPORT_SYMBOL(address_space_init_once);
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 43db02e..1cbed73 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -27,6 +27,7 @@
 #include <linux/lockdep.h>
 #include <linux/percpu-rwsem.h>
 #include <linux/blk_types.h>
+#include <linux/vrange_types.h>
 
 #include <asm/byteorder.h>
 #include <uapi/linux/fs.h>
@@ -411,6 +412,7 @@ struct address_space {
 	struct rb_root		i_mmap;		/* tree of private and shared mappings */
 	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
 	struct mutex		i_mmap_mutex;	/* protect tree, count, list */
+	struct vrange_root	vroot;
 	/* Protected by tree_lock together with the radix tree */
 	unsigned long		nrpages;	/* number of total pages */
 	pgoff_t			writeback_index;/* writeback starts here */
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
