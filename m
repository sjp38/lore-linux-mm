Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3BDE66B0038
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 02:13:14 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so13838346pde.34
        for <linux-mm@kvack.org>; Wed, 01 Jan 2014 23:13:13 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ll1si23308157pab.57.2014.01.01.23.13.11
        for <linux-mm@kvack.org>;
        Wed, 01 Jan 2014 23:13:12 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v10 03/16] vrange: Add support for volatile ranges on file mappings
Date: Thu,  2 Jan 2014 16:12:11 +0900
Message-Id: <1388646744-15608-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1388646744-15608-1-git-send-email-minchan@kernel.org>
References: <1388646744-15608-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, John Stultz <john.stultz@linaro.org>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Minchan Kim <minchan@kernel.org>

From: John Stultz <john.stultz@linaro.org>

Like with the mm_struct, this patch adds basic support for
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

Cc: Dave Chinner <david@fromorbit.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: John Stultz <john.stultz@linaro.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 fs/inode.c         |    4 ++++
 include/linux/fs.h |    4 ++++
 2 files changed, 8 insertions(+)

diff --git a/fs/inode.c b/fs/inode.c
index b33ba8e021cc..b029472134ea 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -18,6 +18,7 @@
 #include <linux/buffer_head.h> /* for inode_has_buffers */
 #include <linux/ratelimit.h>
 #include <linux/list_lru.h>
+#include <linux/vrange.h>
 #include "internal.h"
 
 /*
@@ -353,6 +354,7 @@ void address_space_init_once(struct address_space *mapping)
 	spin_lock_init(&mapping->private_lock);
 	mapping->i_mmap = RB_ROOT;
 	INIT_LIST_HEAD(&mapping->i_mmap_nonlinear);
+	vrange_root_init(&mapping->vroot, VRANGE_FILE, mapping);
 }
 EXPORT_SYMBOL(address_space_init_once);
 
@@ -1388,6 +1390,8 @@ static void iput_final(struct inode *inode)
 		inode_lru_list_del(inode);
 	spin_unlock(&inode->i_lock);
 
+	vrange_root_cleanup(&inode->i_mapping->vroot);
+
 	evict(inode);
 }
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 3f40547ba191..19b70288e219 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -29,6 +29,7 @@
 #include <linux/lockdep.h>
 #include <linux/percpu-rwsem.h>
 #include <linux/blk_types.h>
+#include <linux/vrange_types.h>
 
 #include <asm/byteorder.h>
 #include <uapi/linux/fs.h>
@@ -414,6 +415,9 @@ struct address_space {
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
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
