Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id D62556B0093
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 10:07:47 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v3 03/13] memcg: change defines to an enum
Date: Tue, 18 Sep 2012 18:04:00 +0400
Message-Id: <1347977050-29476-4-git-send-email-glommer@parallels.com>
In-Reply-To: <1347977050-29476-1-git-send-email-glommer@parallels.com>
References: <1347977050-29476-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>

This is just a cleanup patch for clarity of expression.  In earlier
submissions, people asked it to be in a separate patch, so here it is.

[ v2: use named enum as type throughout the file as well ]

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b12121b..d6ad138 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -385,9 +385,12 @@ enum charge_type {
 };
 
 /* for encoding cft->private value on file */
-#define _MEM			(0)
-#define _MEMSWAP		(1)
-#define _OOM_TYPE		(2)
+enum res_type {
+	_MEM,
+	_MEMSWAP,
+	_OOM_TYPE,
+};
+
 #define MEMFILE_PRIVATE(x, val)	((x) << 16 | (val))
 #define MEMFILE_TYPE(val)	((val) >> 16 & 0xffff)
 #define MEMFILE_ATTR(val)	((val) & 0xffff)
@@ -3921,7 +3924,8 @@ static ssize_t mem_cgroup_read(struct cgroup *cont, struct cftype *cft,
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 	char str[64];
 	u64 val;
-	int type, name, len;
+	int name, len;
+	enum res_type type;
 
 	type = MEMFILE_TYPE(cft->private);
 	name = MEMFILE_ATTR(cft->private);
@@ -3957,7 +3961,8 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
 			    const char *buffer)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
-	int type, name;
+	enum res_type type;
+	int name;
 	unsigned long long val;
 	int ret;
 
@@ -4033,7 +4038,8 @@ out:
 static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
-	int type, name;
+	int name;
+	enum res_type type;
 
 	type = MEMFILE_TYPE(event);
 	name = MEMFILE_ATTR(event);
@@ -4369,7 +4375,7 @@ static int mem_cgroup_usage_register_event(struct cgroup *cgrp,
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
 	struct mem_cgroup_thresholds *thresholds;
 	struct mem_cgroup_threshold_ary *new;
-	int type = MEMFILE_TYPE(cft->private);
+	enum res_type type = MEMFILE_TYPE(cft->private);
 	u64 threshold, usage;
 	int i, size, ret;
 
@@ -4452,7 +4458,7 @@ static void mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
 	struct mem_cgroup_thresholds *thresholds;
 	struct mem_cgroup_threshold_ary *new;
-	int type = MEMFILE_TYPE(cft->private);
+	enum res_type type = MEMFILE_TYPE(cft->private);
 	u64 usage;
 	int i, j, size;
 
@@ -4530,7 +4536,7 @@ static int mem_cgroup_oom_register_event(struct cgroup *cgrp,
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
 	struct mem_cgroup_eventfd_list *event;
-	int type = MEMFILE_TYPE(cft->private);
+	enum res_type type = MEMFILE_TYPE(cft->private);
 
 	BUG_ON(type != _OOM_TYPE);
 	event = kmalloc(sizeof(*event),	GFP_KERNEL);
@@ -4555,7 +4561,7 @@ static void mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
 	struct mem_cgroup_eventfd_list *ev, *tmp;
-	int type = MEMFILE_TYPE(cft->private);
+	enum res_type type = MEMFILE_TYPE(cft->private);
 
 	BUG_ON(type != _OOM_TYPE);
 
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
