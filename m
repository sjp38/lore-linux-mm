Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1C8D06B026F
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 14:22:29 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 191so6358454pgd.0
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 11:22:29 -0700 (PDT)
Received: from out0-205.mail.aliyun.com (out0-205.mail.aliyun.com. [140.205.0.205])
        by mx.google.com with ESMTPS id e9si4746168pli.671.2017.10.27.11.22.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Oct 2017 11:22:27 -0700 (PDT)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [PATCH v2] fs: fsnotify: account fsnotify metadata to kmemcg
Date: Sat, 28 Oct 2017 02:22:18 +0800
Message-Id: <1509128538-50162-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jack@suse.cz, amir73il@gmail.com
Cc: Yang Shi <yang.s@alibaba-inc.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

If some process generates events into a huge or unlimit event queue, but no
listener read them, they may consume significant amount of memory silently
until oom happens or some memory pressure issue is raised.
It'd better to account those slab caches in memcg so that we can get heads
up before the problematic process consume too much memory silently.

But, the accounting might be heuristic if the producer is in the different
memcg from listener if the listener doesn't read the events. Due to the
current design of kmemcg, who does the allocation, who gets the accounting.

Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
---
v1 --> v2:
* Updated commit log per Amir's suggestion

 fs/notify/dnotify/dnotify.c        | 4 ++--
 fs/notify/fanotify/fanotify_user.c | 6 +++---
 fs/notify/fsnotify.c               | 2 +-
 fs/notify/inotify/inotify_user.c   | 2 +-
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/notify/dnotify/dnotify.c b/fs/notify/dnotify/dnotify.c
index cba3283..3ec6233 100644
--- a/fs/notify/dnotify/dnotify.c
+++ b/fs/notify/dnotify/dnotify.c
@@ -379,8 +379,8 @@ int fcntl_dirnotify(int fd, struct file *filp, unsigned long arg)
 
 static int __init dnotify_init(void)
 {
-	dnotify_struct_cache = KMEM_CACHE(dnotify_struct, SLAB_PANIC);
-	dnotify_mark_cache = KMEM_CACHE(dnotify_mark, SLAB_PANIC);
+	dnotify_struct_cache = KMEM_CACHE(dnotify_struct, SLAB_PANIC|SLAB_ACCOUNT);
+	dnotify_mark_cache = KMEM_CACHE(dnotify_mark, SLAB_PANIC|SLAB_ACCOUNT);
 
 	dnotify_group = fsnotify_alloc_group(&dnotify_fsnotify_ops);
 	if (IS_ERR(dnotify_group))
diff --git a/fs/notify/fanotify/fanotify_user.c b/fs/notify/fanotify/fanotify_user.c
index 907a481..7d62dee 100644
--- a/fs/notify/fanotify/fanotify_user.c
+++ b/fs/notify/fanotify/fanotify_user.c
@@ -947,11 +947,11 @@ static int fanotify_add_inode_mark(struct fsnotify_group *group,
  */
 static int __init fanotify_user_setup(void)
 {
-	fanotify_mark_cache = KMEM_CACHE(fsnotify_mark, SLAB_PANIC);
-	fanotify_event_cachep = KMEM_CACHE(fanotify_event_info, SLAB_PANIC);
+	fanotify_mark_cache = KMEM_CACHE(fsnotify_mark, SLAB_PANIC|SLAB_ACCOUNT);
+	fanotify_event_cachep = KMEM_CACHE(fanotify_event_info, SLAB_PANIC|SLAB_ACCOUNT);
 #ifdef CONFIG_FANOTIFY_ACCESS_PERMISSIONS
 	fanotify_perm_event_cachep = KMEM_CACHE(fanotify_perm_event_info,
-						SLAB_PANIC);
+						SLAB_PANIC|SLAB_ACCOUNT);
 #endif
 
 	return 0;
diff --git a/fs/notify/fsnotify.c b/fs/notify/fsnotify.c
index 0c4583b..82620ac 100644
--- a/fs/notify/fsnotify.c
+++ b/fs/notify/fsnotify.c
@@ -386,7 +386,7 @@ static __init int fsnotify_init(void)
 		panic("initializing fsnotify_mark_srcu");
 
 	fsnotify_mark_connector_cachep = KMEM_CACHE(fsnotify_mark_connector,
-						    SLAB_PANIC);
+						    SLAB_PANIC|SLAB_ACCOUNT);
 
 	return 0;
 }
diff --git a/fs/notify/inotify/inotify_user.c b/fs/notify/inotify/inotify_user.c
index 7cc7d3f..57b32ff 100644
--- a/fs/notify/inotify/inotify_user.c
+++ b/fs/notify/inotify/inotify_user.c
@@ -785,7 +785,7 @@ static int __init inotify_user_setup(void)
 
 	BUG_ON(hweight32(ALL_INOTIFY_BITS) != 21);
 
-	inotify_inode_mark_cachep = KMEM_CACHE(inotify_inode_mark, SLAB_PANIC);
+	inotify_inode_mark_cachep = KMEM_CACHE(inotify_inode_mark, SLAB_PANIC|SLAB_ACCOUNT);
 
 	inotify_max_queued_events = 16384;
 	init_user_ns.ucount_max[UCOUNT_INOTIFY_INSTANCES] = 128;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
