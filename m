Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id B1B166B00ED
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 13:39:59 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 16 Mar 2012 23:09:57 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2GHdrDj4100296
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 23:09:54 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2GN96jI030997
	for <linux-mm@kvack.org>; Sat, 17 Mar 2012 10:09:08 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V4 06/10] memcg: track resource index in cftype private
Date: Fri, 16 Mar 2012 23:09:26 +0530
Message-Id: <1331919570-2264-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1331919570-2264-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1331919570-2264-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This helps in using same memcg callbacks for non reclaim resource
control files.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/memcontrol.c |   27 +++++++++++++++++++++------
 1 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7a9ea94..d8b3513 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -358,9 +358,14 @@ enum charge_type {
 #define _MEM			(0)
 #define _MEMSWAP		(1)
 #define _OOM_TYPE		(2)
-#define MEMFILE_PRIVATE(x, val)	(((x) << 16) | (val))
-#define MEMFILE_TYPE(val)	(((val) >> 16) & 0xffff)
-#define MEMFILE_ATTR(val)	((val) & 0xffff)
+#define _MEMHUGETLB		(3)
+
+/*  0 ... val ...16.... x...24...idx...32*/
+#define __MEMFILE_PRIVATE(idx, x, val)	(((idx) << 24) | ((x) << 16) | (val))
+#define MEMFILE_PRIVATE(x, val)		__MEMFILE_PRIVATE(0, x, val)
+#define MEMFILE_TYPE(val)		(((val) >> 16) & 0xff)
+#define MEMFILE_IDX(val)		(((val) >> 24) & 0xff)
+#define MEMFILE_ATTR(val)		((val) & 0xffff)
 /* Used for OOM nofiier */
 #define OOM_CONTROL		(0)
 
@@ -3954,7 +3959,7 @@ static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 	u64 val;
-	int type, name;
+	int type, name, idx;
 
 	type = MEMFILE_TYPE(cft->private);
 	name = MEMFILE_ATTR(cft->private);
@@ -3971,6 +3976,10 @@ static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
 		else
 			val = res_counter_read_u64(&memcg->memsw, name);
 		break;
+	case _MEMHUGETLB:
+		idx = MEMFILE_IDX(cft->private);
+		val = res_counter_read_u64(&memcg->hugepage[idx], name);
+		break;
 	default:
 		BUG();
 		break;
@@ -4003,7 +4012,10 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
 			break;
 		if (type == _MEM)
 			ret = mem_cgroup_resize_limit(memcg, val);
-		else
+		else if (type == _MEMHUGETLB) {
+			int idx = MEMFILE_IDX(cft->private);
+			ret = res_counter_set_limit(&memcg->hugepage[idx], val);
+		} else
 			ret = mem_cgroup_resize_memsw_limit(memcg, val);
 		break;
 	case RES_SOFT_LIMIT:
@@ -4067,7 +4079,10 @@ static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
 	case RES_MAX_USAGE:
 		if (type == _MEM)
 			res_counter_reset_max(&memcg->res);
-		else
+		else if (type == _MEMHUGETLB) {
+			int idx = MEMFILE_IDX(event);
+			res_counter_reset_max(&memcg->hugepage[idx]);
+		} else
 			res_counter_reset_max(&memcg->memsw);
 		break;
 	case RES_FAILCNT:
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
