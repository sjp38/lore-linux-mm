Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id B51586B0036
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 02:30:20 -0400 (EDT)
Received: by mail-la0-f44.google.com with SMTP id er20so13424666lab.31
        for <linux-mm@kvack.org>; Tue, 25 Jun 2013 23:30:18 -0700 (PDT)
From: Glauber Costa <glommer@gmail.com>
Subject: [PATCH 1/2] inode: move inode to a different list inside lock
Date: Wed, 26 Jun 2013 02:29:40 -0400
Message-Id: <1372228181-18827-2-git-send-email-glommer@openvz.org>
In-Reply-To: <1372228181-18827-1-git-send-email-glommer@openvz.org>
References: <1372228181-18827-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, dchinner@redhat.com, Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@openvz.org>

When removing an element from the lru, this will be done today after the lock
is released. This is a clear mistake, although we are not sure if the bugs we
are seeing are related to this. All list manipulations are done inside the
lock, and so should this one.

Signed-off-by: Glauber Costa <glommer@openvz.org>
---
 fs/inode.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/inode.c b/fs/inode.c
index a2b49c8..e315c0a 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -735,9 +735,9 @@ inode_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
 
 	WARN_ON(inode->i_state & I_NEW);
 	inode->i_state |= I_FREEING;
+	list_move(&inode->i_lru, freeable);
 	spin_unlock(&inode->i_lock);
 
-	list_move(&inode->i_lru, freeable);
 	this_cpu_dec(nr_unused);
 	return LRU_REMOVED;
 }
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
