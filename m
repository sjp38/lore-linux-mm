Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1J76m1M017884
	for <linux-mm@kvack.org>; Tue, 19 Feb 2008 02:06:48 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1J76mPr250566
	for <linux-mm@kvack.org>; Tue, 19 Feb 2008 02:06:48 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1J76leP015543
	for <linux-mm@kvack.org>; Tue, 19 Feb 2008 02:06:48 -0500
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Tue, 19 Feb 2008 12:32:45 +0530
Message-Id: <20080219070245.25349.35082.sendpatchset@localhost.localdomain>
In-Reply-To: <20080219070232.25349.21196.sendpatchset@localhost.localdomain>
References: <20080219070232.25349.21196.sendpatchset@localhost.localdomain>
Subject: [mm] [PATCH 1/4] Modify resource counters to add soft limit support v2
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hugh@veritas.com>, Paul Menage <menage@google.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <nickpiggin@yahoo.com.au>, "Eric W. Biederman" <ebiederm@xmission.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik Van Riel <riel@redhat.com>, Herbert Poetzl <herbert@13thfloor.at>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


Changelog v2
1. Remove memory controller specific comments from resource counters

The resource counter member limit is split into soft and hard limits.
The same locking rule apply for both limits.


Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 include/linux/res_counter.h |   32 ++++++++++++++++++++++++--------
 kernel/res_counter.c        |   11 +++++++----
 mm/memcontrol.c             |   10 +++++-----
 3 files changed, 36 insertions(+), 17 deletions(-)

diff -puN include/linux/res_counter.h~memory-controller-res_counters-soft-limit-setup include/linux/res_counter.h
--- linux-2.6.25-rc2/include/linux/res_counter.h~memory-controller-res_counters-soft-limit-setup	2008-02-19 12:31:47.000000000 +0530
+++ linux-2.6.25-rc2-balbir/include/linux/res_counter.h	2008-02-19 12:31:47.000000000 +0530
@@ -27,7 +27,11 @@ struct res_counter {
 	/*
 	 * the limit that usage cannot exceed
 	 */
-	unsigned long long limit;
+	unsigned long long hard_limit;
+	/*
+	 * the limit that usage can exceed
+	 */
+	unsigned long long soft_limit;
 	/*
 	 * the number of unsuccessful attempts to consume the resource
 	 */
@@ -64,7 +68,8 @@ ssize_t res_counter_write(struct res_cou
 
 enum {
 	RES_USAGE,
-	RES_LIMIT,
+	RES_SOFT_LIMIT,
+	RES_HARD_LIMIT,
 	RES_FAILCNT,
 };
 
@@ -101,11 +106,21 @@ int res_counter_charge(struct res_counte
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
 
@@ -113,13 +128,14 @@ static inline bool res_counter_limit_che
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
diff -puN kernel/res_counter.c~memory-controller-res_counters-soft-limit-setup kernel/res_counter.c
--- linux-2.6.25-rc2/kernel/res_counter.c~memory-controller-res_counters-soft-limit-setup	2008-02-19 12:31:47.000000000 +0530
+++ linux-2.6.25-rc2-balbir/kernel/res_counter.c	2008-02-19 12:31:47.000000000 +0530
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
diff -puN mm/memcontrol.c~memory-controller-res_counters-soft-limit-setup mm/memcontrol.c
--- linux-2.6.25-rc2/mm/memcontrol.c~memory-controller-res_counters-soft-limit-setup	2008-02-19 12:31:47.000000000 +0530
+++ linux-2.6.25-rc2-balbir/mm/memcontrol.c	2008-02-19 12:31:47.000000000 +0530
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
