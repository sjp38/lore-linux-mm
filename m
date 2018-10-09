Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id AD5A96B000D
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 14:48:22 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id x5-v6so1514722ywd.19
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 11:48:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p3-v6sor2976494ywf.7.2018.10.09.11.48.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Oct 2018 11:48:21 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 4/4] mm: zero-seek shrinkers
Date: Tue,  9 Oct 2018 14:47:33 -0400
Message-Id: <20181009184732.762-5-hannes@cmpxchg.org>
In-Reply-To: <20181009184732.762-1-hannes@cmpxchg.org>
References: <20181009184732.762-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

The page cache and most shrinkable slab caches hold data that has been
read from disk, but there are some caches that only cache CPU work,
such as the dentry and inode caches of procfs and sysfs, as well as
the subset of radix tree nodes that track non-resident page cache.

Currently, all these are shrunk at the same rate: using DEFAULT_SEEKS
for the shrinker's seeks setting tells the reclaim algorithm that for
every two page cache pages scanned it should scan one slab object.

This is a bogus setting. A virtual inode that required no IO to create
is not twice as valuable as a page cache page; shadow cache entries
with eviction distances beyond the size of memory aren't either.

In most cases, the behavior in practice is still fine. Such virtual
caches don't tend to grow and assert themselves aggressively, and
usually get picked up before they cause problems. But there are
scenarios where that's not true.

Our database workloads suffer from two of those. For one, their file
workingset is several times bigger than available memory, which has
the kernel aggressively create shadow page cache entries for the
non-resident parts of it. The workingset code does tell the VM that
most of these are expendable, but the VM ends up balancing them 2:1 to
cache pages as per the seeks setting. This is a huge waste of memory.

These workloads also deal with tens of thousands of open files and use
/proc for introspection, which ends up growing the proc_inode_cache to
absurdly large sizes - again at the cost of valuable cache space,
which isn't a reasonable trade-off, given that proc inodes can be
re-created without involving the disk.

This patch implements a "zero-seek" setting for shrinkers that results
in a target ratio of 0:1 between their objects and IO-backed
caches. This allows such virtual caches to grow when memory is
available (they do cache/avoid CPU work after all), but effectively
disables them as soon as IO-backed objects are under pressure.

It then switches the shrinkers for procfs and sysfs metadata, as well
as excess page cache shadow nodes, to the new zero-seek setting.

Reported-by: Domas Mituzas <dmituzas@fb.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 fs/kernfs/mount.c |  3 +++
 fs/proc/root.c    |  3 +++
 mm/vmscan.c       | 15 ++++++++++++---
 mm/workingset.c   |  2 +-
 4 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/fs/kernfs/mount.c b/fs/kernfs/mount.c
index 1bd43f6947f3..7d56b624e0dc 100644
--- a/fs/kernfs/mount.c
+++ b/fs/kernfs/mount.c
@@ -251,6 +251,9 @@ static int kernfs_fill_super(struct super_block *sb, struct kernfs_fs_context *k
 		sb->s_export_op = &kernfs_export_ops;
 	sb->s_time_gran = 1;
 
+	/* sysfs dentries and inodes don't require IO to create */
+	sb->s_shrink.seeks = 0;
+
 	/* get root inode, initialize and unlock it */
 	mutex_lock(&kernfs_mutex);
 	inode = kernfs_get_inode(sb, info->root->kn);
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 8912a8b57ac3..74975ca77b71 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -127,6 +127,9 @@ static int proc_fill_super(struct super_block *s, struct fs_context *fc)
 	 */
 	s->s_stack_depth = FILESYSTEM_MAX_STACK_DEPTH;
 
+	/* procfs dentries and inodes don't require IO to create */
+	s->s_shrink.seeks = 0;
+
 	pde_get(&proc_root);
 	root_inode = proc_get_inode(s, &proc_root);
 	if (!root_inode) {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a859f64a2166..62ac0c488624 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -474,9 +474,18 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
 
 	total_scan = nr;
-	delta = freeable >> priority;
-	delta *= 4;
-	do_div(delta, shrinker->seeks);
+	if (shrinker->seeks) {
+		delta = freeable >> priority;
+		delta *= 4;
+		do_div(delta, shrinker->seeks);
+	} else {
+		/*
+		 * These objects don't require any IO to create. Trim
+		 * them aggressively under memory pressure to keep
+		 * them from causing refetches in the IO caches.
+		 */
+		delta = freeable / 2;
+	}
 
 	/*
 	 * Make sure we apply some minimal pressure on default priority
diff --git a/mm/workingset.c b/mm/workingset.c
index cfdf6adf7e7c..97523c4d3496 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -523,7 +523,7 @@ static unsigned long scan_shadow_nodes(struct shrinker *shrinker,
 static struct shrinker workingset_shadow_shrinker = {
 	.count_objects = count_shadow_nodes,
 	.scan_objects = scan_shadow_nodes,
-	.seeks = DEFAULT_SEEKS,
+	.seeks = 0, /* ->count reports only fully expendable nodes */
 	.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE,
 };
 
-- 
2.19.0
