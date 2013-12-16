Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id D8F7A6B0062
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 07:17:27 -0500 (EST)
Received: by mail-la0-f47.google.com with SMTP id ep20so2643227lab.34
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 04:17:27 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 6si5341310laz.140.2013.12.16.04.17.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 04:17:26 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v14 04/18] memcg: make for_each_mem_cgroup macros public
Date: Mon, 16 Dec 2013 16:16:53 +0400
Message-ID: <935807f1cf90abb10423e049346c49ef7b6bcc2f.1387193771.git.vdavydov@parallels.com>
In-Reply-To: <cover.1387193771.git.vdavydov@parallels.com>
References: <cover.1387193771.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dchinner@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, glommer@gmail.com, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I am going to use these macros in next patches, so let's move them to
the header. These macros are very handy and they depend only on
mem_cgroup_iter(), which is already public, so I guess it's worth it.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |   15 +++++++++++++++
 mm/memcontrol.c            |   15 ---------------
 2 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index b3e7a66..e3efab2 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -53,6 +53,21 @@ struct mem_cgroup_reclaim_cookie {
 	unsigned int generation;
 };
 
+/*
+ * Iteration constructs for visiting all cgroups (under a tree).  If
+ * loops are exited prematurely (break), mem_cgroup_iter_break() must
+ * be used for reference counting.
+ */
+#define for_each_mem_cgroup_tree(iter, root)		\
+	for (iter = mem_cgroup_iter(root, NULL, NULL);	\
+	     iter != NULL;				\
+	     iter = mem_cgroup_iter(root, iter, NULL))
+
+#define for_each_mem_cgroup(iter)			\
+	for (iter = mem_cgroup_iter(NULL, NULL, NULL);	\
+	     iter != NULL;				\
+	     iter = mem_cgroup_iter(NULL, iter, NULL))
+
 #ifdef CONFIG_MEMCG
 /*
  * All "charge" functions with gfp_mask should use GFP_KERNEL or
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8fdb239..b6ec029 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1261,21 +1261,6 @@ void mem_cgroup_iter_break(struct mem_cgroup *root,
 		css_put(&prev->css);
 }
 
-/*
- * Iteration constructs for visiting all cgroups (under a tree).  If
- * loops are exited prematurely (break), mem_cgroup_iter_break() must
- * be used for reference counting.
- */
-#define for_each_mem_cgroup_tree(iter, root)		\
-	for (iter = mem_cgroup_iter(root, NULL, NULL);	\
-	     iter != NULL;				\
-	     iter = mem_cgroup_iter(root, iter, NULL))
-
-#define for_each_mem_cgroup(iter)			\
-	for (iter = mem_cgroup_iter(NULL, NULL, NULL);	\
-	     iter != NULL;				\
-	     iter = mem_cgroup_iter(NULL, iter, NULL))
-
 void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
 {
 	struct mem_cgroup *memcg;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
