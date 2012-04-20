Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 22C3B6B010C
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 18:00:09 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 10/23] slab/slub: struct memcg_params
Date: Fri, 20 Apr 2012 18:57:18 -0300
Message-Id: <1334959051-18203-11-git-send-email-glommer@parallels.com>
In-Reply-To: <1334959051-18203-1-git-send-email-glommer@parallels.com>
References: <1334959051-18203-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Glauber Costa <glommer@parallels.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

For the kmem slab controller, we need to record some extra
information in the kmem_cache structure.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Suleiman Souhlal <suleiman@google.com>
---
 include/linux/slab.h     |   15 +++++++++++++++
 include/linux/slab_def.h |    4 ++++
 include/linux/slub_def.h |    3 +++
 3 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index a595dce..a5127e1 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -153,6 +153,21 @@ unsigned int kmem_cache_size(struct kmem_cache *);
 #define ARCH_SLAB_MINALIGN __alignof__(unsigned long long)
 #endif
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
+struct mem_cgroup_cache_params {
+	struct mem_cgroup *memcg;
+	int id;
+
+#ifdef CONFIG_SLAB
+	/* Original cache parameters, used when creating a memcg cache */
+	size_t orig_align;
+	atomic_t refcnt;
+
+#endif
+	struct list_head destroyed_list; /* Used when deleting cpuset cache */
+};
+#endif
+
 /*
  * Common kmalloc functions provided by all allocators
  */
diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index cba3139..06e4a3e 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -83,6 +83,10 @@ struct kmem_cache {
 	int obj_size;
 #endif
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
+	struct mem_cgroup_cache_params memcg_params;
+#endif
+
 /* 6) per-cpu/per-node data, touched during every alloc/free */
 	/*
 	 * We put array[] at the end of kmem_cache, because we want to size
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index c2f8c8b..5f5e942 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -102,6 +102,9 @@ struct kmem_cache {
 #ifdef CONFIG_SYSFS
 	struct kobject kobj;	/* For sysfs */
 #endif
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
+	struct mem_cgroup_cache_params memcg_params;
+#endif
 
 #ifdef CONFIG_NUMA
 	/*
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
