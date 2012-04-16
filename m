Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 87D806B00E8
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 06:45:14 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 16 Apr 2012 16:15:07 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3GAj9Hh3858642
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 16:15:09 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3GGFgHn001156
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 02:15:45 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V6 09/14] memcg: track resource index in cftype private
Date: Mon, 16 Apr 2012 16:14:46 +0530
Message-Id: <1334573091-18602-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1334573091-18602-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1334573091-18602-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This patch adds a new charge type _MEMHUGETLB for tracking hugetlb
resources. We also use cftype to encode the hugetlb resource index.
This helps in using same memcg callbacks for hugetlb control files.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/memcontrol.c |   27 +++++++++++++++++++++------
 1 file changed, 21 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e906b41..0f9ec34 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -381,9 +381,14 @@ enum charge_type {
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
 
@@ -4003,7 +4008,7 @@ static ssize_t mem_cgroup_read(struct cgroup *cont, struct cftype *cft,
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 	char str[64];
 	u64 val;
-	int type, name, len;
+	int type, name, len, idx;
 
 	type = MEMFILE_TYPE(cft->private);
 	name = MEMFILE_ATTR(cft->private);
@@ -4024,6 +4029,10 @@ static ssize_t mem_cgroup_read(struct cgroup *cont, struct cftype *cft,
 		else
 			val = res_counter_read_u64(&memcg->memsw, name);
 		break;
+	case _MEMHUGETLB:
+		idx = MEMFILE_IDX(cft->private);
+		val = res_counter_read_u64(&memcg->hugepage[idx], name);
+		break;
 	default:
 		BUG();
 	}
@@ -4061,7 +4070,10 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
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
@@ -4127,7 +4139,10 @@ static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
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
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
