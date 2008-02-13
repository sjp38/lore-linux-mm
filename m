Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1DFFKuS005457
	for <linux-mm@kvack.org>; Wed, 13 Feb 2008 10:15:20 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1DFFJwY137142
	for <linux-mm@kvack.org>; Wed, 13 Feb 2008 08:15:19 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1DFFGrh014615
	for <linux-mm@kvack.org>; Wed, 13 Feb 2008 08:15:19 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Wed, 13 Feb 2008 20:42:14 +0530
Message-Id: <20080213151214.7529.3954.sendpatchset@localhost.localdomain>
In-Reply-To: <20080213151201.7529.53642.sendpatchset@localhost.localdomain>
References: <20080213151201.7529.53642.sendpatchset@localhost.localdomain>
Subject: [RFC] [PATCH 1/4] Modify resource counters to add soft limit support
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <nickpiggin@yahoo.com.au>, "Eric W. Biederman" <ebiederm@xmission.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik Van Riel <riel@redhat.com>, Herbert Poetzl <herbert@13thfloor.at>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


The resource counter member limit is split into soft and hard limits.
The same locking rule apply for both limits.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 include/linux/res_counter.h |   34 ++++++++++++++++++++++++++--------
 kernel/res_counter.c        |   11 +++++++----
 mm/memcontrol.c             |   10 +++++-----
 3 files changed, 38 insertions(+), 17 deletions(-)

diff -puN mm/vmscan.c~memory-controller-res_counters-soft-limit-setup mm/vmscan.c
diff -puN mm/memcontrol.c~memory-controller-res_counters-soft-limit-setup mm/memcontrol.c
--- linux-2.6.24/mm/memcontrol.c~memory-controller-res_counters-soft-limit-setup	2008-02-13 19:50:24.000000000 +0530
+++ linux-2.6.24-balbir/mm/memcontrol.c	2008-02-13 19:50:24.000000000 +0530
@@ -568,7 +568,7 @@ unsigned long mem_cgroup_isolate_pages(u
  * Charge the memory controller for page usage.
  * Return
  * 0 if the charge was successful
- * < 0 if the cgroup is over its limit
+ * < 0 if the cgroup is over its hard limit
  */
 static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask, enum charge_type ctype)
@@ -632,7 +632,7 @@ retry:
 
 	/*
 	 * If we created the page_cgroup, we should free it on exceeding
-	 * the cgroup limit.
+	 * the cgroup hard limit.
 	 */
 	while (res_counter_charge(&mem->res, PAGE_SIZE)) {
 		if (!(gfp_mask & __GFP_WAIT))
@@ -645,10 +645,10 @@ retry:
  		 * try_to_free_mem_cgroup_pages() might not give us a full
  		 * picture of reclaim. Some pages are reclaimed and might be
  		 * moved to swap cache or just unmapped from the cgroup.
- 		 * Check the limit again to see if the reclaim reduced the
+ 		 * Check the hard limit again to see if the reclaim reduced the
  		 * current usage of the cgroup before giving up
  		 */
-		if (res_counter_check_under_limit(&mem->res))
+		if (res_counter_check_under_limit(&mem->res, RES_HARD_LIMIT))
 			continue;
 
 		if (!nr_retries--) {
@@ -1028,7 +1028,7 @@ static struct cftype mem_cgroup_files[] 
 	},
 	{
 		.name = "limit_in_bytes",
-		.private = RES_LIMIT,
+		.private = RES_HARD_LIMIT,
 		.write = mem_cgroup_write,
 		.read = mem_cgroup_read,
 	},
diff -puN kernel/res_counter.c~memory-controller-res_counters-soft-limit-setup kernel/res_counter.c
--- linux-2.6.24/kernel/res_counter.c~memory-controller-res_counters-soft-limit-setup	2008-02-13 19:50:24.000000000 +0530
+++ linux-2.6.24-balbir/kernel/res_counter.c	2008-02-13 19:50:24.000000000 +0530
@@ -16,12 +16,13 @@
 void res_counter_init(struct res_counter *counter)
 {
 	spin_lock_init(&counter->lock);
-	counter->limit = (unsigned long long)LLONG_MAX;
+	counter->soft_limit = (unsigned long long)LLONG_MAX;
+	counter->hard_limit = (unsigned long long)LLONG_MAX;
 }
 
 int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
 {
-	if (counter->usage + val > counter->limit) {
+	if (counter->usage + val > counter->hard_limit) {
 		counter->failcnt++;
 		return -ENOMEM;
 	}
@@ -65,8 +66,10 @@ res_counter_member(struct res_counter *c
 	switch (member) {
 	case RES_USAGE:
 		return &counter->usage;
-	case RES_LIMIT:
-		return &counter->limit;
+	case RES_SOFT_LIMIT:
+		return &counter->soft_limit;
+	case RES_HARD_LIMIT:
+		return &counter->hard_limit;
 	case RES_FAILCNT:
 		return &counter->failcnt;
 	};
diff -puN include/linux/res_counter.h~memory-controller-res_counters-soft-limit-setup include/linux/res_counter.h
--- linux-2.6.24/include/linux/res_counter.h~memory-controller-res_counters-soft-limit-setup	2008-02-13 19:50:24.000000000 +0530
+++ linux-2.6.24-balbir/include/linux/res_counter.h	2008-02-13 19:50:24.000000000 +0530
@@ -27,7 +27,13 @@ struct res_counter {
 	/*
 	 * the limit that usage cannot exceed
 	 */
-	unsigned long long limit;
+	unsigned long long hard_limit;
+	/*
+	 * the limit that usage can exceed, but under memory
+	 * pressure, we will reclaim back memory above the
+	 * soft limit mark
+	 */
+	unsigned long long soft_limit;
 	/*
 	 * the number of unsuccessful attempts to consume the resource
 	 */
@@ -64,7 +70,8 @@ ssize_t res_counter_write(struct res_cou
 
 enum {
 	RES_USAGE,
-	RES_LIMIT,
+	RES_SOFT_LIMIT,
+	RES_HARD_LIMIT,
 	RES_FAILCNT,
 };
 
@@ -101,11 +108,21 @@ int res_counter_charge(struct res_counte
 void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val);
 void res_counter_uncharge(struct res_counter *counter, unsigned long val);
 
-static inline bool res_counter_limit_check_locked(struct res_counter *cnt)
+static inline bool res_counter_limit_check_locked(struct res_counter *cnt,
+							int member)
 {
-	if (cnt->usage < cnt->limit)
-		return true;
-
+	switch (member) {
+	case RES_HARD_LIMIT:
+		if (cnt->usage < cnt->hard_limit)
+			return true;
+		break;
+	case RES_SOFT_LIMIT:
+		if (cnt->usage < cnt->soft_limit)
+			return true;
+		break;
+	default:
+		BUG_ON(1);
+	}
 	return false;
 }
 
@@ -113,13 +130,14 @@ static inline bool res_counter_limit_che
  * Helper function to detect if the cgroup is within it's limit or
  * not. It's currently called from cgroup_rss_prepare()
  */
-static inline bool res_counter_check_under_limit(struct res_counter *cnt)
+static inline bool res_counter_check_under_limit(struct res_counter *cnt,
+							int member)
 {
 	bool ret;
 	unsigned long flags;
 
 	spin_lock_irqsave(&cnt->lock, flags);
-	ret = res_counter_limit_check_locked(cnt);
+	ret = res_counter_limit_check_locked(cnt, member);
 	spin_unlock_irqrestore(&cnt->lock, flags);
 	return ret;
 }
diff -puN include/linux/memcontrol.h~memory-controller-res_counters-soft-limit-setup include/linux/memcontrol.h
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
