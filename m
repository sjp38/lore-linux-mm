Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7A1DE90011B
	for <linux-mm@kvack.org>; Fri,  8 Jul 2011 00:15:33 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 13/14] vfs: increase shrinker batch size
Date: Fri,  8 Jul 2011 14:14:45 +1000
Message-Id: <1310098486-6453-14-git-send-email-david@fromorbit.com>
In-Reply-To: <1310098486-6453-1-git-send-email-david@fromorbit.com>
References: <1310098486-6453-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Dave Chinner <dchinner@redhat.com>

Now that the per-sb shrinker is responsible for shrinking 2 or more
caches, increase the batch size to keep econmies of scale for
shrinking each cache.  Increase the shrinker batch size to 1024
objects.

To allow for a large increase in batch size, add a conditional
reschedule to prune_icache_sb() so that we don't hold the LRU spin
lock for too long. This mirrors the behaviour of the
__shrink_dcache_sb(), and allows us to increase the batch size
without needing to worry about problems caused by long lock hold
times.

To ensure that filesystems using the per-sb shrinker callouts don't
cause problems, document that the object freeing method must
reschedule appropriately inside loops.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 Documentation/filesystems/vfs.txt |    6 ++++++
 fs/super.c                        |    1 +
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index fd24f34..6bf85b7 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -317,6 +317,12 @@ or bottom half).
 	the VM is trying to reclaim under GFP_NOFS conditions, hence this
 	method does not need to handle that situation itself.
 
+	Implementations must include conditional reschedule calls inside any
+	scanning loop that is done. This allows the VFS to determine
+	appropriate scan batch sizes without having to worry about whether
+	implementations will cause holdoff problems due to large scan batch
+	sizes.
+
 Whoever sets up the inode is responsible for filling in the "i_op" field. This
 is a pointer to a "struct inode_operations" which describes the methods that
 can be performed on individual inodes.
diff --git a/fs/super.c b/fs/super.c
index ca8e735..c1e0836 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -183,6 +183,7 @@ static struct super_block *alloc_super(struct file_system_type *type)
 
 		s->s_shrink.seeks = DEFAULT_SEEKS;
 		s->s_shrink.shrink = prune_super;
+		s->s_shrink.batch = 1024;
 	}
 out:
 	return s;
-- 
1.7.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
