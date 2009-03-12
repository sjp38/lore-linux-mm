Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C216C6B0047
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 13:56:32 -0400 (EDT)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2CHuO2P024441
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 23:26:24 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2CHuWBj4337912
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 23:26:32 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2CHuNiE009276
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 04:56:23 +1100
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Thu, 12 Mar 2009 23:26:20 +0530
Message-Id: <20090312175620.17890.69177.sendpatchset@localhost.localdomain>
In-Reply-To: <20090312175603.17890.52593.sendpatchset@localhost.localdomain>
References: <20090312175603.17890.52593.sendpatchset@localhost.localdomain>
Subject: [PATCH 2/4] Memory controller soft limit interface (v5)
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Feature: Add soft limits interface to resource counters

From: Balbir Singh <balbir@linux.vnet.ibm.com>

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
index 4c5bcf6..5c821fd 100644
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
@@ -85,6 +89,7 @@ enum {
 	RES_MAX_USAGE,
 	RES_LIMIT,
 	RES_FAILCNT,
+	RES_SOFT_LIMIT,
 };
 
 /*
@@ -130,6 +135,36 @@ static inline bool res_counter_limit_check_locked(struct res_counter *cnt)
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
@@ -145,6 +180,17 @@ static inline bool res_counter_check_under_limit(struct res_counter *cnt)
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
@@ -178,4 +224,16 @@ static inline int res_counter_set_limit(struct res_counter *cnt,
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
index bf8e753..4e6dafe 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -19,6 +19,7 @@ void res_counter_init(struct res_counter *counter, struct res_counter *parent)
 {
 	spin_lock_init(&counter->lock);
 	counter->limit = (unsigned long long)LLONG_MAX;
+	counter->soft_limit = (unsigned long long)LLONG_MAX;
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
index 804bbae..b4f5b15 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1986,6 +1986,20 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
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
@@ -2235,6 +2249,12 @@ static struct cftype mem_cgroup_files[] = {
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
