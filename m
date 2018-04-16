Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 504936B0009
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 16:52:12 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id e11so3055807pgv.15
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 13:52:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m3sor4073016pff.146.2018.04.16.13.52.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Apr 2018 13:52:10 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH v5 2/2] fs: fsnotify: account fsnotify metadata to kmemcg
Date: Mon, 16 Apr 2018 13:51:50 -0700
Message-Id: <20180416205150.113915-3-shakeelb@google.com>
In-Reply-To: <20180416205150.113915-1-shakeelb@google.com>
References: <20180416205150.113915-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Jan Kara <jack@suse.cz>, Amir Goldstein <amir73il@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Shakeel Butt <shakeelb@google.com>

A lot of memory can be consumed by the events generated for the huge or
unlimited queues if there is either no or slow listener.  This can cause
system level memory pressure or OOMs.  So, it's better to account the
fsnotify kmem caches to the memcg of the listener.

There are seven fsnotify kmem caches and among them allocations from
dnotify_struct_cache, dnotify_mark_cache, fanotify_mark_cache and
inotify_inode_mark_cachep happens in the context of syscall from the
listener.  So, SLAB_ACCOUNT is enough for these caches.

The objects from fsnotify_mark_connector_cachep are not accounted as they
are small compared to the notification mark or events and it is unclear
whom to account connector to since it is shared by all events attached to
the inode.

The allocations from the event caches happen in the context of the event
producer.  For such caches we will need to remote charge the allocations
to the listener's memcg.  Thus we save the memcg reference in the
fsnotify_group structure of the listener.

This patch has also moved the members of fsnotify_group to keep the size
same, at least for 64 bit build, even with additional member by filling
the holes.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
Acked-by: Jan Kara <jack@suse.cz>
---
Changelog since v4:
- Fixed the build for CONFIG_MEMCG=n

Changelog since v3:
- Rebased over Jan's patches.
- Some cleanup based on Amir's comments.

Changelog since v2:
- None

Changelog since v1:
- no more charging fsnotify_mark_connector objects
- Fixed the build for SLOB

 fs/notify/dnotify/dnotify.c          |  5 +++--
 fs/notify/fanotify/fanotify.c        |  6 ++++--
 fs/notify/fanotify/fanotify_user.c   |  5 ++++-
 fs/notify/group.c                    |  4 ++++
 fs/notify/inotify/inotify_fsnotify.c |  2 +-
 fs/notify/inotify/inotify_user.c     |  5 ++++-
 include/linux/fsnotify_backend.h     | 12 ++++++++----
 include/linux/memcontrol.h           |  7 +++++++
 mm/memcontrol.c                      |  2 +-
 9 files changed, 36 insertions(+), 12 deletions(-)

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
index d94e8031fe5f..78cfdcfd9f8e 100644
--- a/fs/notify/fanotify/fanotify.c
+++ b/fs/notify/fanotify/fanotify.c
@@ -153,14 +153,16 @@ struct fanotify_event_info *fanotify_alloc_event(struct fsnotify_group *group,
 	if (fanotify_is_perm_event(mask)) {
 		struct fanotify_perm_event_info *pevent;
 
-		pevent = kmem_cache_alloc(fanotify_perm_event_cachep, gfp);
+		pevent = kmem_cache_alloc_memcg(fanotify_perm_event_cachep, gfp,
+						group->memcg);
 		if (!pevent)
 			return NULL;
 		event = &pevent->fae;
 		pevent->response = 0;
 		goto init;
 	}
-	event = kmem_cache_alloc(fanotify_event_cachep, gfp);
+	event = kmem_cache_alloc_memcg(fanotify_event_cachep, gfp,
+				       group->memcg);
 	if (!event)
 		return NULL;
 init: __maybe_unused
diff --git a/fs/notify/fanotify/fanotify_user.c b/fs/notify/fanotify/fanotify_user.c
index ec4d8c59d0e3..0cf45041dc32 100644
--- a/fs/notify/fanotify/fanotify_user.c
+++ b/fs/notify/fanotify/fanotify_user.c
@@ -16,6 +16,7 @@
 #include <linux/uaccess.h>
 #include <linux/compat.h>
 #include <linux/sched/signal.h>
+#include <linux/memcontrol.h>
 
 #include <asm/ioctls.h>
 
@@ -756,6 +757,7 @@ SYSCALL_DEFINE2(fanotify_init, unsigned int, flags, unsigned int, event_f_flags)
 
 	group->fanotify_data.user = user;
 	atomic_inc(&user->fanotify_listeners);
+	group->memcg = get_mem_cgroup_from_mm(current->mm);
 
 	oevent = fanotify_alloc_event(group, NULL, FS_Q_OVERFLOW, NULL);
 	if (unlikely(!oevent)) {
@@ -957,7 +959,8 @@ COMPAT_SYSCALL_DEFINE6(fanotify_mark,
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
index 40dedb37a1f3..b184bff93d02 100644
--- a/fs/notify/inotify/inotify_fsnotify.c
+++ b/fs/notify/inotify/inotify_fsnotify.c
@@ -98,7 +98,7 @@ int inotify_handle_event(struct fsnotify_group *group,
 	i_mark = container_of(inode_mark, struct inotify_inode_mark,
 			      fsn_mark);
 
-	event = kmalloc(alloc_len, GFP_KERNEL);
+	event = kmalloc_memcg(alloc_len, GFP_KERNEL, group->memcg);
 	if (unlikely(!event)) {
 		/*
 		 * Treat lost event due to ENOMEM the same way as queue
diff --git a/fs/notify/inotify/inotify_user.c b/fs/notify/inotify/inotify_user.c
index ef32f3657958..3c152e350805 100644
--- a/fs/notify/inotify/inotify_user.c
+++ b/fs/notify/inotify/inotify_user.c
@@ -38,6 +38,7 @@
 #include <linux/uaccess.h>
 #include <linux/poll.h>
 #include <linux/wait.h>
+#include <linux/memcontrol.h>
 
 #include "inotify.h"
 #include "../fdinfo.h"
@@ -632,6 +633,7 @@ static struct fsnotify_group *inotify_new_group(unsigned int max_events)
 	oevent->name_len = 0;
 
 	group->max_events = max_events;
+	group->memcg = get_mem_cgroup_from_mm(current->mm);
 
 	spin_lock_init(&group->inotify_data.idr_lock);
 	idr_init(&group->inotify_data.idr);
@@ -804,7 +806,8 @@ static int __init inotify_user_setup(void)
 
 	BUG_ON(hweight32(ALL_INOTIFY_BITS) != 21);
 
-	inotify_inode_mark_cachep = KMEM_CACHE(inotify_inode_mark, SLAB_PANIC);
+	inotify_inode_mark_cachep = KMEM_CACHE(inotify_inode_mark,
+					       SLAB_PANIC|SLAB_ACCOUNT);
 
 	inotify_max_queued_events = 16384;
 	init_user_ns.ucount_max[UCOUNT_INOTIFY_INSTANCES] = 128;
diff --git a/include/linux/fsnotify_backend.h b/include/linux/fsnotify_backend.h
index 9f1edb92c97e..81bd86dfa2cd 100644
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
index 2da009958798..af9eed2e3e04 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -356,6 +356,8 @@ struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *css){
 	return css ? container_of(css, struct mem_cgroup, css) : NULL;
 }
 
+struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm);
+
 static inline void mem_cgroup_put(struct mem_cgroup *memcg)
 {
 	css_put(&memcg->css);
@@ -813,6 +815,11 @@ static inline bool task_in_mem_cgroup(struct task_struct *task,
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
index 2c5f6b8819d9..d47d356b9087 100644
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
2.17.0.484.g0c8726318c-goog
