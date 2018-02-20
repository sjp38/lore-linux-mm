Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8D3816B0055
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 14:42:12 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 189so7320846pge.0
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 11:42:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bh1-v6sor1484610plb.27.2018.02.20.11.42.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Feb 2018 11:42:11 -0800 (PST)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH 3/3] fs: fsnotify: account fsnotify metadata to kmemcg
Date: Tue, 20 Feb 2018 11:41:49 -0800
Message-Id: <20180220194149.242009-4-shakeelb@google.com>
In-Reply-To: <20180220194149.242009-1-shakeelb@google.com>
References: <20180220194149.242009-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Amir Goldstein <amir73il@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

A lot of memory can be consumed by the events generated for the huge or
unlimited queues if there is either no or slow listener. This can cause
system level memory pressure or OOMs. So, it's better to account the
fsnotify kmem caches to the memcg of the listener.

There are seven fsnotify kmem caches and among them allocations from
dnotify_struct_cache, dnotify_mark_cache, fanotify_mark_cache and
inotify_inode_mark_cachep happens in the context of syscall from the
listener. So, SLAB_ACCOUNT is enough for these caches.

The objects from fsnotify_mark_connector_cachep are not accounted as
they are small compared to the notification mark or events and it is
unclear whom to account connector to since it is shared by all events
attached to the inode.

The allocations from the event caches happen in the context of the event
producer. For such caches we will need to remote charge the allocations
to the listener's memcg. Thus we save the memcg reference in the
fsnotify_group structure of the listener.

This patch has also moved the members of fsnotify_group to keep the
size same, at least for 64 bit build, even with additional member by
filling the holes.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
Changelog since v1:
- no more charging fsnotify_mark_connector objects

 fs/notify/dnotify/dnotify.c          |  5 +++--
 fs/notify/fanotify/fanotify.c        | 12 +++++++-----
 fs/notify/fanotify/fanotify.h        |  3 ++-
 fs/notify/fanotify/fanotify_user.c   |  7 +++++--
 fs/notify/group.c                    |  4 ++++
 fs/notify/inotify/inotify_fsnotify.c |  2 +-
 fs/notify/inotify/inotify_user.c     |  5 ++++-
 fs/notify/mark.c                     |  6 ++++--
 include/linux/fsnotify_backend.h     | 12 ++++++++----
 include/linux/memcontrol.h           |  7 +++++++
 mm/memcontrol.c                      |  2 +-
 11 files changed, 46 insertions(+), 19 deletions(-)

diff --git a/fs/notify/dnotify/dnotify.c b/fs/notify/dnotify/dnotify.c
index 63a1ca4b9dee..eb5c41284649 100644
--- a/fs/notify/dnotify/dnotify.c
+++ b/fs/notify/dnotify/dnotify.c
@@ -384,8 +384,9 @@ int fcntl_dirnotify(int fd, struct file *filp, unsigned long arg)
 
 static int __init dnotify_init(void)
 {
-	dnotify_struct_cache = KMEM_CACHE(dnotify_struct, SLAB_PANIC);
-	dnotify_mark_cache = KMEM_CACHE(dnotify_mark, SLAB_PANIC);
+	dnotify_struct_cache = KMEM_CACHE(dnotify_struct,
+					  SLAB_PANIC|SLAB_ACCOUNT);
+	dnotify_mark_cache = KMEM_CACHE(dnotify_mark, SLAB_PANIC|SLAB_ACCOUNT);
 
 	dnotify_group = fsnotify_alloc_group(&dnotify_fsnotify_ops);
 	if (IS_ERR(dnotify_group))
diff --git a/fs/notify/fanotify/fanotify.c b/fs/notify/fanotify/fanotify.c
index 6702a6a0bbb5..0d9493ebc7cd 100644
--- a/fs/notify/fanotify/fanotify.c
+++ b/fs/notify/fanotify/fanotify.c
@@ -140,22 +140,24 @@ static bool fanotify_should_send_event(struct fsnotify_mark *inode_mark,
 }
 
 struct fanotify_event_info *fanotify_alloc_event(struct inode *inode, u32 mask,
-						 const struct path *path)
+						 const struct path *path,
+						 struct mem_cgroup *memcg)
 {
 	struct fanotify_event_info *event;
 
 	if (fanotify_is_perm_event(mask)) {
 		struct fanotify_perm_event_info *pevent;
 
-		pevent = kmem_cache_alloc(fanotify_perm_event_cachep,
-					  GFP_KERNEL);
+		pevent = kmem_cache_alloc_memcg(fanotify_perm_event_cachep,
+						GFP_KERNEL, memcg);
 		if (!pevent)
 			return NULL;
 		event = &pevent->fae;
 		pevent->response = 0;
 		goto init;
 	}
-	event = kmem_cache_alloc(fanotify_event_cachep, GFP_KERNEL);
+	event = kmem_cache_alloc_memcg(fanotify_event_cachep, GFP_KERNEL,
+				       memcg);
 	if (!event)
 		return NULL;
 init: __maybe_unused
@@ -210,7 +212,7 @@ static int fanotify_handle_event(struct fsnotify_group *group,
 			return 0;
 	}
 
-	event = fanotify_alloc_event(inode, mask, data);
+	event = fanotify_alloc_event(inode, mask, data, group->memcg);
 	ret = -ENOMEM;
 	if (unlikely(!event))
 		goto finish;
diff --git a/fs/notify/fanotify/fanotify.h b/fs/notify/fanotify/fanotify.h
index 256d9d1ddea9..51b797896c87 100644
--- a/fs/notify/fanotify/fanotify.h
+++ b/fs/notify/fanotify/fanotify.h
@@ -53,4 +53,5 @@ static inline struct fanotify_event_info *FANOTIFY_E(struct fsnotify_event *fse)
 }
 
 struct fanotify_event_info *fanotify_alloc_event(struct inode *inode, u32 mask,
-						 const struct path *path);
+						 const struct path *path,
+						 struct mem_cgroup *memcg);
diff --git a/fs/notify/fanotify/fanotify_user.c b/fs/notify/fanotify/fanotify_user.c
index ef08d64c84b8..29c9b3e57a29 100644
--- a/fs/notify/fanotify/fanotify_user.c
+++ b/fs/notify/fanotify/fanotify_user.c
@@ -16,6 +16,7 @@
 #include <linux/uaccess.h>
 #include <linux/compat.h>
 #include <linux/sched/signal.h>
+#include <linux/memcontrol.h>
 
 #include <asm/ioctls.h>
 
@@ -756,8 +757,9 @@ SYSCALL_DEFINE2(fanotify_init, unsigned int, flags, unsigned int, event_f_flags)
 
 	group->fanotify_data.user = user;
 	atomic_inc(&user->fanotify_listeners);
+	group->memcg = get_mem_cgroup_from_mm(current->mm);
 
-	oevent = fanotify_alloc_event(NULL, FS_Q_OVERFLOW, NULL);
+	oevent = fanotify_alloc_event(NULL, FS_Q_OVERFLOW, NULL, group->memcg);
 	if (unlikely(!oevent)) {
 		fd = -ENOMEM;
 		goto out_destroy_group;
@@ -951,7 +953,8 @@ COMPAT_SYSCALL_DEFINE6(fanotify_mark,
  */
 static int __init fanotify_user_setup(void)
 {
-	fanotify_mark_cache = KMEM_CACHE(fsnotify_mark, SLAB_PANIC);
+	fanotify_mark_cache = KMEM_CACHE(fsnotify_mark,
+					 SLAB_PANIC|SLAB_ACCOUNT);
 	fanotify_event_cachep = KMEM_CACHE(fanotify_event_info, SLAB_PANIC);
 	if (IS_ENABLED(CONFIG_FANOTIFY_ACCESS_PERMISSIONS)) {
 		fanotify_perm_event_cachep =
diff --git a/fs/notify/group.c b/fs/notify/group.c
index b7a4b6a69efa..3e56459f4773 100644
--- a/fs/notify/group.c
+++ b/fs/notify/group.c
@@ -22,6 +22,7 @@
 #include <linux/srcu.h>
 #include <linux/rculist.h>
 #include <linux/wait.h>
+#include <linux/memcontrol.h>
 
 #include <linux/fsnotify_backend.h>
 #include "fsnotify.h"
@@ -36,6 +37,9 @@ static void fsnotify_final_destroy_group(struct fsnotify_group *group)
 	if (group->ops->free_group_priv)
 		group->ops->free_group_priv(group);
 
+	if (group->memcg)
+		mem_cgroup_put(group->memcg);
+
 	kfree(group);
 }
 
diff --git a/fs/notify/inotify/inotify_fsnotify.c b/fs/notify/inotify/inotify_fsnotify.c
index 8b73332735ba..ed8e7b5f3981 100644
--- a/fs/notify/inotify/inotify_fsnotify.c
+++ b/fs/notify/inotify/inotify_fsnotify.c
@@ -98,7 +98,7 @@ int inotify_handle_event(struct fsnotify_group *group,
 	i_mark = container_of(inode_mark, struct inotify_inode_mark,
 			      fsn_mark);
 
-	event = kmalloc(alloc_len, GFP_KERNEL);
+	event = kmalloc_memcg(alloc_len, GFP_KERNEL, group->memcg);
 	if (unlikely(!event))
 		return -ENOMEM;
 
diff --git a/fs/notify/inotify/inotify_user.c b/fs/notify/inotify/inotify_user.c
index 5c29bf16814f..e80f4656799f 100644
--- a/fs/notify/inotify/inotify_user.c
+++ b/fs/notify/inotify/inotify_user.c
@@ -38,6 +38,7 @@
 #include <linux/uaccess.h>
 #include <linux/poll.h>
 #include <linux/wait.h>
+#include <linux/memcontrol.h>
 
 #include "inotify.h"
 #include "../fdinfo.h"
@@ -618,6 +619,7 @@ static struct fsnotify_group *inotify_new_group(unsigned int max_events)
 	oevent->name_len = 0;
 
 	group->max_events = max_events;
+	group->memcg = get_mem_cgroup_from_mm(current->mm);
 
 	spin_lock_init(&group->inotify_data.idr_lock);
 	idr_init(&group->inotify_data.idr);
@@ -785,7 +787,8 @@ static int __init inotify_user_setup(void)
 
 	BUG_ON(hweight32(ALL_INOTIFY_BITS) != 21);
 
-	inotify_inode_mark_cachep = KMEM_CACHE(inotify_inode_mark, SLAB_PANIC);
+	inotify_inode_mark_cachep = KMEM_CACHE(inotify_inode_mark,
+					       SLAB_PANIC|SLAB_ACCOUNT);
 
 	inotify_max_queued_events = 16384;
 	init_user_ns.ucount_max[UCOUNT_INOTIFY_INSTANCES] = 128;
diff --git a/fs/notify/mark.c b/fs/notify/mark.c
index e9191b416434..c0014d0c3783 100644
--- a/fs/notify/mark.c
+++ b/fs/notify/mark.c
@@ -432,7 +432,8 @@ int fsnotify_compare_groups(struct fsnotify_group *a, struct fsnotify_group *b)
 static int fsnotify_attach_connector_to_object(
 				struct fsnotify_mark_connector __rcu **connp,
 				struct inode *inode,
-				struct vfsmount *mnt)
+				struct vfsmount *mnt,
+				struct fsnotify_group *group)
 {
 	struct fsnotify_mark_connector *conn;
 
@@ -517,7 +518,8 @@ static int fsnotify_add_mark_list(struct fsnotify_mark *mark,
 	conn = fsnotify_grab_connector(connp);
 	if (!conn) {
 		spin_unlock(&mark->lock);
-		err = fsnotify_attach_connector_to_object(connp, inode, mnt);
+		err = fsnotify_attach_connector_to_object(connp, inode, mnt,
+							  mark->group);
 		if (err)
 			return err;
 		goto restart;
diff --git a/include/linux/fsnotify_backend.h b/include/linux/fsnotify_backend.h
index 067d52e95f02..e4428e383215 100644
--- a/include/linux/fsnotify_backend.h
+++ b/include/linux/fsnotify_backend.h
@@ -84,6 +84,8 @@ struct fsnotify_event_private_data;
 struct fsnotify_fname;
 struct fsnotify_iter_info;
 
+struct mem_cgroup;
+
 /*
  * Each group much define these ops.  The fsnotify infrastructure will call
  * these operations for each relevant group.
@@ -129,6 +131,8 @@ struct fsnotify_event {
  * everything will be cleaned up.
  */
 struct fsnotify_group {
+	const struct fsnotify_ops *ops;	/* how this group handles things */
+
 	/*
 	 * How the refcnt is used is up to each group.  When the refcnt hits 0
 	 * fsnotify will clean up all of the resources associated with this group.
@@ -139,8 +143,6 @@ struct fsnotify_group {
 	 */
 	refcount_t refcnt;		/* things with interest in this group */
 
-	const struct fsnotify_ops *ops;	/* how this group handles things */
-
 	/* needed to send notification to userspace */
 	spinlock_t notification_lock;		/* protect the notification_list */
 	struct list_head notification_list;	/* list of event_holder this group needs to send to userspace */
@@ -162,6 +164,8 @@ struct fsnotify_group {
 	atomic_t num_marks;		/* 1 for each mark and 1 for not being
 					 * past the point of no return when freeing
 					 * a group */
+	atomic_t user_waits;		/* Number of tasks waiting for user
+					 * response */
 	struct list_head marks_list;	/* all inode marks for this group */
 
 	struct fasync_struct *fsn_fa;    /* async notification */
@@ -169,8 +173,8 @@ struct fsnotify_group {
 	struct fsnotify_event *overflow_event;	/* Event we queue when the
 						 * notification list is too
 						 * full */
-	atomic_t user_waits;		/* Number of tasks waiting for user
-					 * response */
+
+	struct mem_cgroup *memcg;	/* memcg to charge allocations */
 
 	/* groups can define private fields here or use the void *private */
 	union {
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 9dec8a5c0ca2..ee4b6b9d6813 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -352,6 +352,8 @@ struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *css){
 	return css ? container_of(css, struct mem_cgroup, css) : NULL;
 }
 
+struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm);
+
 static inline void mem_cgroup_put(struct mem_cgroup *memcg)
 {
 	css_put(&memcg->css);
@@ -809,6 +811,11 @@ static inline bool task_in_mem_cgroup(struct task_struct *task,
 	return true;
 }
 
+static inline struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
+{
+	return NULL;
+}
+
 static inline void mem_cgroup_put(struct mem_cgroup *memcg)
 {
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0dcd6ab6cc94..3a72394510a7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -678,7 +678,7 @@ struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
 }
 EXPORT_SYMBOL(mem_cgroup_from_task);
 
-static struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
+struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
 {
 	struct mem_cgroup *memcg = NULL;
 
-- 
2.16.1.291.g4437f3f132-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
