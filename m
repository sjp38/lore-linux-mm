Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7FF276B005C
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 06:19:57 -0500 (EST)
Received: by mail-lb0-f180.google.com with SMTP id w6so8459411lbh.11
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 03:19:56 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id h3si4257407lbd.66.2013.12.02.03.19.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 03:19:56 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v12 05/18] fs: do not use destroy_super() in alloc_super() fail path
Date: Mon, 2 Dec 2013 15:19:40 +0400
Message-ID: <af90b79aebe9cd9f6e1d35513f2618f4e9888e9b.1385974612.git.vdavydov@parallels.com>
In-Reply-To: <cover.1385974612.git.vdavydov@parallels.com>
References: <cover.1385974612.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, vdavydov@parallels.com, Al Viro <viro@zeniv.linux.org.uk>

Using destroy_super() in alloc_super() fail path is bad, because:

* It will trigger WARN_ON(!list_empty(&s->s_mounts)) since s_mounts is
  initialized after several 'goto fail's.
* It will call kfree_rcu() to free the super block although kfree() is
  obviously enough there.
* The list_lru structure was initially implemented without the ability
  to destroy an uninitialized object in mind.

I'm going to replace the conventional list_lru with per-memcg lru to
implement per-memcg slab reclaim. This new structure will fail
destruction of objects that haven't been properly initialized so let's
inline appropriate snippets from destroy_super() to alloc_super() fail
path instead of using the whole function there.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
---
 fs/super.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/super.c b/fs/super.c
index e5f6c2c..cece164 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -185,8 +185,10 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
 
 	if (list_lru_init(&s->s_dentry_lru))
 		goto fail;
-	if (list_lru_init(&s->s_inode_lru))
+	if (list_lru_init(&s->s_inode_lru)) {
+		list_lru_destroy(&s->s_dentry_lru);
 		goto fail;
+	}
 
 	INIT_LIST_HEAD(&s->s_mounts);
 	init_rwsem(&s->s_umount);
@@ -227,7 +229,10 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
 	return s;
 
 fail:
-	destroy_super(s);
+	for (i = 0; i < SB_FREEZE_LEVELS; i++)
+		percpu_counter_destroy(&s->s_writers.counter[i]);
+	security_sb_free(s);
+	kfree(s);
 	return NULL;
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
