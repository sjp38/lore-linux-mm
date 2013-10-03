Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8C7C86B003D
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 20:52:11 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id q10so1663201pdj.35
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 17:52:11 -0700 (PDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so1812596pab.27
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 17:52:09 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 04/14] vrange: Add support for volatile ranges on file mappings
Date: Wed,  2 Oct 2013 17:51:33 -0700
Message-Id: <1380761503-14509-5-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1380761503-14509-1-git-send-email-john.stultz@linaro.org>
References: <1380761503-14509-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dhaval.giani@gmail.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Rob Clark <robdclark@gmail.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Like with the mm struct, this patch add basic support for
volatile ranges on file address_space structures. This allows
for volatile ranges to be set on mmapped files that can be
shared between processes.

The semantics on the volatile range sharing is that the
volatility is shared, just as the data is shared. Thus
if one process marks the range as volatile, the data is
volatile in all processes that have those pages mapped.

It is advised that processes coordinate when using volatile
ranges on shared mappings (much as they must coordinate when
writing to shared data).

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Andrea Righi <andrea@betterlinux.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: Dhaval Giani <dhaval.giani@gmail.com>
Cc: Jan Kara <jack@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Rob Clark <robdclark@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 fs/inode.c         | 4 ++++
 include/linux/fs.h | 4 ++++
 2 files changed, 8 insertions(+)

diff --git a/fs/inode.c b/fs/inode.c
index d6dfb09..5364f91 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -17,6 +17,7 @@
 #include <linux/prefetch.h>
 #include <linux/buffer_head.h> /* for inode_has_buffers */
 #include <linux/ratelimit.h>
+#include <linux/vrange.h>
 #include "internal.h"
 
 /*
@@ -352,6 +353,7 @@ void address_space_init_once(struct address_space *mapping)
 	spin_lock_init(&mapping->private_lock);
 	mapping->i_mmap = RB_ROOT;
 	INIT_LIST_HEAD(&mapping->i_mmap_nonlinear);
+	vrange_root_init(&mapping->vroot, VRANGE_FILE, mapping);
 }
 EXPORT_SYMBOL(address_space_init_once);
 
@@ -1419,6 +1421,8 @@ static void iput_final(struct inode *inode)
 		inode_lru_list_del(inode);
 	spin_unlock(&inode->i_lock);
 
+	vrange_root_cleanup(&inode->i_mapping->vroot);
+
 	evict(inode);
 }
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 9818747..6ec2953 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -28,6 +28,7 @@
 #include <linux/lockdep.h>
 #include <linux/percpu-rwsem.h>
 #include <linux/blk_types.h>
+#include <linux/vrange_types.h>
 
 #include <asm/byteorder.h>
 #include <uapi/linux/fs.h>
@@ -413,6 +414,9 @@ struct address_space {
 	struct rb_root		i_mmap;		/* tree of private and shared mappings */
 	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
 	struct mutex		i_mmap_mutex;	/* protect tree, count, list */
+#ifdef CONFIG_MMU
+	struct vrange_root	vroot;
+#endif
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
