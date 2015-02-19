Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id CF3FE6B0088
	for <linux-mm@kvack.org>; Thu, 19 Feb 2015 12:19:41 -0500 (EST)
Received: by labgq15 with SMTP id gq15so978453lab.6
        for <linux-mm@kvack.org>; Thu, 19 Feb 2015 09:19:41 -0800 (PST)
Received: from forward-corp1f.mail.yandex.net (forward-corp1f.mail.yandex.net. [2a02:6b8:0:801::10])
        by mx.google.com with ESMTPS id ca4si17695804lad.53.2015.02.19.09.19.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Feb 2015 09:19:38 -0800 (PST)
Subject: [PATCH] fs: avoid locking sb_lock in grab_super_passive()
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Thu, 19 Feb 2015 20:19:35 +0300
Message-ID: <20150219171934.20458.30175.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>

I've noticed significant locking contention in memory reclaimer around
sb_lock inside grab_super_passive(). Grab_super_passive() is called from
two places: in icache/dcache shrinkers (function super_cache_scan) and
from writeback (function __writeback_inodes_wb). Both are required for
progress in memory reclaimer.

Also this lock isn't irq-safe. And I've seen suspicious livelock under
serious memory pressure where reclaimer was called from interrupt which
have happened right in place where sb_lock is held in normal context,
so all other cpus were stuck on that lock too.

Grab_super_passive() acquires sb_lock to increment sb->s_count and check
sb->s_instances. It seems sb->s_umount locked for read is enough here:
super-block deactivation always runs under sb->s_umount locked for write.
Protecting super-block itself isn't a problem: in super_cache_scan() sb
is protected by shrinker_rwsem: it cannot be freed if its slab shrinkers
are still active. Inside writeback super-block comes from inode from bdi
writeback list under wb->list_lock.

This patch removes locking sb_lock and checks s_instances under s_umount:
generic_shutdown_super() unlinks it under sb->s_umount locked for write.
Now successful grab_super_passive() only locks semaphore, callers must
call up_read(&sb->s_umount) instead of drop_super(sb) when they're done.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 fs/fs-writeback.c |    2 +-
 fs/super.c        |   18 ++++--------------
 2 files changed, 5 insertions(+), 15 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 073657f..3e92bb7 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -779,7 +779,7 @@ static long __writeback_inodes_wb(struct bdi_writeback *wb,
 			continue;
 		}
 		wrote += writeback_sb_inodes(sb, wb, work);
-		drop_super(sb);
+		up_read(&sb->s_umount);
 
 		/* refer to the same tests at the end of writeback_sb_inodes */
 		if (wrote) {
diff --git a/fs/super.c b/fs/super.c
index 65a53ef..6ae33ed 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -105,7 +105,7 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
 		freed += sb->s_op->free_cached_objects(sb, sc);
 	}
 
-	drop_super(sb);
+	up_read(&sb->s_umount);
 	return freed;
 }
 
@@ -356,27 +356,17 @@ static int grab_super(struct super_block *s) __releases(sb_lock)
  *	superblock does not go away while we are working on it. It returns
  *	false if a reference was not gained, and returns true with the s_umount
  *	lock held in read mode if a reference is gained. On successful return,
- *	the caller must drop the s_umount lock and the passive reference when
- *	done.
+ *	the caller must drop the s_umount lock when done.
  */
 bool grab_super_passive(struct super_block *sb)
 {
-	spin_lock(&sb_lock);
-	if (hlist_unhashed(&sb->s_instances)) {
-		spin_unlock(&sb_lock);
-		return false;
-	}
-
-	sb->s_count++;
-	spin_unlock(&sb_lock);
-
 	if (down_read_trylock(&sb->s_umount)) {
-		if (sb->s_root && (sb->s_flags & MS_BORN))
+		if (!hlist_unhashed(&sb->s_instances) &&
+		    sb->s_root && (sb->s_flags & MS_BORN))
 			return true;
 		up_read(&sb->s_umount);
 	}
 
-	put_super(sb);
 	return false;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
