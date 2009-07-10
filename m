Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5918F6B0055
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 08:35:33 -0400 (EDT)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp08.au.ibm.com (8.13.1/8.13.1) with ESMTP id n6AMqsM3013314
	for <linux-mm@kvack.org>; Sat, 11 Jul 2009 08:52:54 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n6AD07wj1224866
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 23:00:07 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6AD06RQ024775
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 23:00:07 +1000
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Fri, 10 Jul 2009 18:30:04 +0530
Message-Id: <20090710130004.5610.57822.sendpatchset@balbir-laptop>
In-Reply-To: <20090710125950.5610.99139.sendpatchset@balbir-laptop>
References: <20090710125950.5610.99139.sendpatchset@balbir-laptop>
Subject: [RFC][PATCH 2/5] Memory controller soft limit interface (v9)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Feature: Add soft limits interface to resource counters

From: Balbir Singh <balbir@linux.vnet.ibm.com>

Changelog v8..v1 (yeah this patch changed only in v8)
1. Change ULONGLOGMAX to RESOURCE_MAX while initializing the soft limit
   counter

Changelog v2...v1
1. Add support for res_counter_check_soft_limit_locked. This is used
   by the hierarchy code.

Add an interface to allow get/set of soft limits. Soft limits for memory plus
swap controller (memsw) is currently not supported. Resource counters have
been enhanced to support soft limits and new type RES_SOFT_LIMIT has been
added. Unlike hard limits, soft limits can be directly set and do not
need any reclaim or checks before setting them to a newer value.

Kamezawa-San raised a question as to whether soft limit should belong
to res_counter. Since all resources understand the basic concepts of
hard and soft limits, it is justified to add soft limits here. Soft limits
are a generic resource usage feature, even file system quotas support
soft limits.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 include/linux/res_counter.h |   58 +++++++++++++++++++++++++++++++++++++++++++
 kernel/res_counter.c        |    3 ++
 mm/memcontrol.c             |   20 +++++++++++++++
 3 files changed, 81 insertions(+), 0 deletions(-)


diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index 511f42f..fcb9884 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -35,6 +35,10 @@ struct res_counter {
 	 */
 	unsigned long long limit;
 	/*
+	 * the limit that usage can be exceed
+	 */
+	unsigned long long soft_limit;
+	/*
 	 * the number of unsuccessful attempts to consume the resource
 	 */
 	unsigned long long failcnt;
@@ -87,6 +91,7 @@ enum {
 	RES_MAX_USAGE,
 	RES_LIMIT,
 	RES_FAILCNT,
+	RES_SOFT_LIMIT,
 };
 
 /*
@@ -132,6 +137,36 @@ static inline bool res_counter_limit_check_locked(struct res_counter *cnt)
 	return false;
 }
 
+static inline bool res_counter_soft_limit_check_locked(struct res_counter *cnt)
+{
+	if (cnt->usage < cnt->soft_limit)
+		return true;
+
+	return false;
+}
+
+/**
+ * Get the difference between the usage and the soft limit
+ * @cnt: The counter
+ *
+ * Returns 0 if usage is less than or equal to soft limit
+ * The difference between usage and soft limit, otherwise.
+ */
+static inline unsigned long long
+res_counter_soft_limit_excess(struct res_counter *cnt)
+{
+	unsigned long long excess;
+	unsigned long flags;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	if (cnt->usage <= cnt->soft_limit)
+		excess = 0;
+	else
+		excess = cnt->usage - cnt->soft_limit;
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return excess;
+}
+
 /*
  * Helper function to detect if the cgroup is within it's limit or
  * not. It's currently called from cgroup_rss_prepare()
@@ -147,6 +182,17 @@ static inline bool res_counter_check_under_limit(struct res_counter *cnt)
 	return ret;
 }
 
+static inline bool res_counter_check_under_soft_limit(struct res_counter *cnt)
+{
+	bool ret;
+	unsigned long flags;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	ret = res_counter_soft_limit_check_locked(cnt);
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return ret;
+}
+
 static inline void res_counter_reset_max(struct res_counter *cnt)
 {
 	unsigned long flags;
@@ -180,4 +226,16 @@ static inline int res_counter_set_limit(struct res_counter *cnt,
 	return ret;
 }
 
+static inline int
+res_counter_set_soft_limit(struct res_counter *cnt,
+				unsigned long long soft_limit)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	cnt->soft_limit = soft_limit;
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return 0;
+}
+
 #endif
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index e1338f0..bcdabf3 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -19,6 +19,7 @@ void res_counter_init(struct res_counter *counter, struct res_counter *parent)
 {
 	spin_lock_init(&counter->lock);
 	counter->limit = RESOURCE_MAX;
+	counter->soft_limit = RESOURCE_MAX;
 	counter->parent = parent;
 }
 
@@ -101,6 +102,8 @@ res_counter_member(struct res_counter *counter, int member)
 		return &counter->limit;
 	case RES_FAILCNT:
 		return &counter->failcnt;
+	case RES_SOFT_LIMIT:
+		return &counter->soft_limit;
 	};
 
 	BUG();
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4da70c9..3c9292b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2106,6 +2106,20 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
 		else
 			ret = mem_cgroup_resize_memsw_limit(memcg, val);
 		break;
+	case RES_SOFT_LIMIT:
+		ret = res_counter_memparse_write_strategy(buffer, &val);
+		if (ret)
+			break;
+		/*
+		 * For memsw, soft limits are hard to implement in terms
+		 * of semantics, for now, we support soft limits for
+		 * control without swap
+		 */
+		if (type == _MEM)
+			ret = res_counter_set_soft_limit(&memcg->res, val);
+		else
+			ret = -EINVAL;
+		break;
 	default:
 		ret = -EINVAL; /* should be BUG() ? */
 		break;
@@ -2359,6 +2373,12 @@ static struct cftype mem_cgroup_files[] = {
 		.read_u64 = mem_cgroup_read,
 	},
 	{
+		.name = "soft_limit_in_bytes",
+		.private = MEMFILE_PRIVATE(_MEM, RES_SOFT_LIMIT),
+		.write_string = mem_cgroup_write,
+		.read_u64 = mem_cgroup_read,
+	},
+	{
 		.name = "failcnt",
 		.private = MEMFILE_PRIVATE(_MEM, RES_FAILCNT),
 		.trigger = mem_cgroup_reset,

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
