Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05CCCC43331
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 21:46:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE06020825
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 21:46:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="VOKv3gR+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE06020825
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 485CE6B0005; Thu,  5 Sep 2019 17:46:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40E866B0007; Thu,  5 Sep 2019 17:46:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FB196B0008; Thu,  5 Sep 2019 17:46:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0222.hostedemail.com [216.40.44.222])
	by kanga.kvack.org (Postfix) with ESMTP id 00A496B0005
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:46:12 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 86B5E180AD7C3
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 21:46:12 +0000 (UTC)
X-FDA: 75902200584.18.cord93_8d6ca519e6f1f
X-HE-Tag: cord93_8d6ca519e6f1f
X-Filterd-Recvd-Size: 21591
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com [67.231.145.42])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 21:46:11 +0000 (UTC)
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.42/8.16.0.42) with SMTP id x85LjfHJ025642
	for <linux-mm@kvack.org>; Thu, 5 Sep 2019 14:46:10 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=KRUpM9B4qzOJCnYFrMw0m++EnlrcohwDNfLzf2h8uX0=;
 b=VOKv3gR+QImTqU3Qiq9sn3Eo03piZeOdDu5hKWx7ldkNKJ6nSjssClu535r+J4m+VXMa
 Lq6TunGBNgTPVah7NRR7VZuRpnYyef4y4fEDMfj82o0ZzgOoRSXsiJO1mRXTWcGB3/kE
 OC+V1yfMvq6UzRiNWCSK7xBPUkJkt/p7B9A= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2uu8mdrhe7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 05 Sep 2019 14:46:10 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::e) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 5 Sep 2019 14:46:09 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id AEECA17229DFE; Thu,  5 Sep 2019 14:46:06 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: <linux-mm@kvack.org>
CC: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Shakeel Butt
	<shakeelb@google.com>,
        Vladimir Davydov <vdavydov.dev@gmail.com>,
        Waiman Long
	<longman@redhat.com>, Roman Gushchin <guro@fb.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH RFC 04/14] mm: vmstat: convert slab vmstat counter to bytes
Date: Thu, 5 Sep 2019 14:45:48 -0700
Message-ID: <20190905214553.1643060-5-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190905214553.1643060-1-guro@fb.com>
References: <20190905214553.1643060-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:6.0.70,1.0.8
 definitions=2019-09-05_08:2019-09-04,2019-09-05 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 adultscore=0 spamscore=0
 suspectscore=3 priorityscore=1501 impostorscore=0 bulkscore=0
 mlxlogscore=999 clxscore=1015 mlxscore=0 lowpriorityscore=0 phishscore=0
 malwarescore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-1906280000 definitions=main-1909050203
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In order to prepare for per-object slab memory accounting,
convert NR_SLAB_RECLAIMABLE and NR_SLAB_UNRECLAIMABLE vmstat
items to bytes.

To make sure that these vmstats are in bytes, rename them
to NR_SLAB_RECLAIMABLE_B and NR_SLAB_UNRECLAIMABLE_B (similar to
NR_KERNEL_STACK_KB).

The size of slab memory shouldn't exceed 4Gb on 32-bit machines,
so it will fit into atomic_long_t we use for vmstats.

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 drivers/base/node.c     | 11 ++++++++---
 fs/proc/meminfo.c       |  4 ++--
 include/linux/mmzone.h  | 10 ++++++++--
 include/linux/vmstat.h  |  8 ++++++++
 kernel/power/snapshot.c |  2 +-
 mm/memcontrol.c         | 29 ++++++++++++++++-------------
 mm/oom_kill.c           |  2 +-
 mm/page_alloc.c         |  8 ++++----
 mm/slab.h               | 15 ++++++++-------
 mm/slab_common.c        |  4 ++--
 mm/slob.c               | 12 ++++++------
 mm/slub.c               |  8 ++++----
 mm/vmscan.c             |  3 ++-
 mm/vmstat.c             | 22 +++++++++++++++++++---
 mm/workingset.c         |  6 ++++--
 15 files changed, 93 insertions(+), 51 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 296546ffed6c..56664222f3fd 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -368,8 +368,8 @@ static ssize_t node_read_meminfo(struct device *dev,
 	unsigned long sreclaimable, sunreclaimable;
 
 	si_meminfo_node(&i, nid);
-	sreclaimable = node_page_state(pgdat, NR_SLAB_RECLAIMABLE);
-	sunreclaimable = node_page_state(pgdat, NR_SLAB_UNRECLAIMABLE);
+	sreclaimable = node_page_state_pages(pgdat, NR_SLAB_RECLAIMABLE_B);
+	sunreclaimable = node_page_state_pages(pgdat, NR_SLAB_UNRECLAIMABLE_B);
 	n = sprintf(buf,
 		       "Node %d MemTotal:       %8lu kB\n"
 		       "Node %d MemFree:        %8lu kB\n"
@@ -495,9 +495,14 @@ static ssize_t node_read_vmstat(struct device *dev,
 	int i;
 	int n = 0;
 
-	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
+	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++) {
+		unsigned long x = sum_zone_node_page_state(nid, i);
+
+		if (vmstat_item_in_bytes(i))
+			x >>= PAGE_SHIFT;
 		n += sprintf(buf+n, "%s %lu\n", vmstat_text[i],
 			     sum_zone_node_page_state(nid, i));
+	}
 
 #ifdef CONFIG_NUMA
 	for (i = 0; i < NR_VM_NUMA_STAT_ITEMS; i++)
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index ac9247371871..87afa8683c1b 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -53,8 +53,8 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		pages[lru] = global_node_page_state(NR_LRU_BASE + lru);
 
 	available = si_mem_available();
-	sreclaimable = global_node_page_state(NR_SLAB_RECLAIMABLE);
-	sunreclaim = global_node_page_state(NR_SLAB_UNRECLAIMABLE);
+	sreclaimable = global_node_page_state_pages(NR_SLAB_RECLAIMABLE_B);
+	sunreclaim = global_node_page_state_pages(NR_SLAB_UNRECLAIMABLE_B);
 
 	show_val_kb(m, "MemTotal:       ", i.totalram);
 	show_val_kb(m, "MemFree:        ", i.freeram);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 6e8233d52971..2dbc2d042ef6 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -215,8 +215,8 @@ enum node_stat_item {
 	NR_INACTIVE_FILE,	/*  "     "     "   "       "         */
 	NR_ACTIVE_FILE,		/*  "     "     "   "       "         */
 	NR_UNEVICTABLE,		/*  "     "     "   "       "         */
-	NR_SLAB_RECLAIMABLE,	/* Please do not reorder this item */
-	NR_SLAB_UNRECLAIMABLE,	/* and this one without looking at
+	NR_SLAB_RECLAIMABLE_B,	/* Please do not reorder this item */
+	NR_SLAB_UNRECLAIMABLE_B,/* and this one without looking at
 				 * memcg_flush_percpu_vmstats() first. */
 	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
 	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
@@ -247,6 +247,12 @@ enum node_stat_item {
 	NR_VM_NODE_STAT_ITEMS
 };
 
+static __always_inline bool vmstat_item_in_bytes(enum node_stat_item item)
+{
+	return (item == NR_SLAB_RECLAIMABLE_B ||
+		item == NR_SLAB_UNRECLAIMABLE_B);
+}
+
 /*
  * We do arithmetic on the LRU lists in various places in the code,
  * so it is important to keep the active lists LRU_ACTIVE higher in
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index bdeda4b079fe..e5460e597e0c 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -194,6 +194,12 @@ static inline unsigned long global_node_page_state(enum node_stat_item item)
 	return x;
 }
 
+static inline
+unsigned long global_node_page_state_pages(enum node_stat_item item)
+{
+	return global_node_page_state(item) >> PAGE_SHIFT;
+}
+
 static inline unsigned long zone_page_state(struct zone *zone,
 					enum zone_stat_item item)
 {
@@ -234,6 +240,8 @@ extern unsigned long sum_zone_node_page_state(int node,
 extern unsigned long sum_zone_numa_state(int node, enum numa_stat_item item);
 extern unsigned long node_page_state(struct pglist_data *pgdat,
 						enum node_stat_item item);
+extern unsigned long node_page_state_pages(struct pglist_data *pgdat,
+					   enum node_stat_item item);
 #else
 #define sum_zone_node_page_state(node, item) global_zone_page_state(item)
 #define node_page_state(node, item) global_node_page_state(item)
diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index 83105874f255..ce9e5686e745 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -1659,7 +1659,7 @@ static unsigned long minimum_image_size(unsigned long saveable)
 {
 	unsigned long size;
 
-	size = global_node_page_state(NR_SLAB_RECLAIMABLE)
+	size = global_node_page_state_pages(NR_SLAB_RECLAIMABLE_B)
 		+ global_node_page_state(NR_ACTIVE_ANON)
 		+ global_node_page_state(NR_INACTIVE_ANON)
 		+ global_node_page_state(NR_ACTIVE_FILE)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index cb9adb31360e..e4af9810b59e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -759,13 +759,16 @@ mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_node *mctz)
  */
 void __mod_memcg_state(struct mem_cgroup *memcg, int idx, int val)
 {
-	long x;
+	long x, threshold = MEMCG_CHARGE_BATCH;
 
 	if (mem_cgroup_disabled())
 		return;
 
+	if (vmstat_item_in_bytes(idx))
+		threshold <<= PAGE_SHIFT;
+
 	x = val + __this_cpu_read(memcg->vmstats_percpu->stat[idx]);
-	if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
+	if (unlikely(abs(x) > threshold)) {
 		struct mem_cgroup *mi;
 
 		/*
@@ -807,7 +810,7 @@ void __mod_lruvec_state(struct lruvec *lruvec, enum node_stat_item idx,
 	pg_data_t *pgdat = lruvec_pgdat(lruvec);
 	struct mem_cgroup_per_node *pn;
 	struct mem_cgroup *memcg;
-	long x;
+	long x, threshold = MEMCG_CHARGE_BATCH;
 
 	/* Update node */
 	__mod_node_page_state(pgdat, idx, val);
@@ -824,8 +827,11 @@ void __mod_lruvec_state(struct lruvec *lruvec, enum node_stat_item idx,
 	/* Update lruvec */
 	__this_cpu_add(pn->lruvec_stat_local->count[idx], val);
 
+	if (vmstat_item_in_bytes(idx))
+		threshold <<= PAGE_SHIFT;
+
 	x = val + __this_cpu_read(pn->lruvec_stat_cpu->count[idx]);
-	if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
+	if (unlikely(abs(x) > threshold)) {
 		struct mem_cgroup_per_node *pi;
 
 		for (pi = pn; pi; pi = parent_nodeinfo(pi, pgdat->node_id))
@@ -1478,9 +1484,8 @@ static char *memory_stat_format(struct mem_cgroup *memcg)
 		       (u64)memcg_page_state(memcg, MEMCG_KERNEL_STACK_KB) *
 		       1024);
 	seq_buf_printf(&s, "slab %llu\n",
-		       (u64)(memcg_page_state(memcg, NR_SLAB_RECLAIMABLE) +
-			     memcg_page_state(memcg, NR_SLAB_UNRECLAIMABLE)) *
-		       PAGE_SIZE);
+		       (u64)(memcg_page_state(memcg, NR_SLAB_RECLAIMABLE_B) +
+			     memcg_page_state(memcg, NR_SLAB_UNRECLAIMABLE_B)));
 	seq_buf_printf(&s, "sock %llu\n",
 		       (u64)memcg_page_state(memcg, MEMCG_SOCK) *
 		       PAGE_SIZE);
@@ -1514,11 +1519,9 @@ static char *memory_stat_format(struct mem_cgroup *memcg)
 			       PAGE_SIZE);
 
 	seq_buf_printf(&s, "slab_reclaimable %llu\n",
-		       (u64)memcg_page_state(memcg, NR_SLAB_RECLAIMABLE) *
-		       PAGE_SIZE);
+		       (u64)memcg_page_state(memcg, NR_SLAB_RECLAIMABLE_B));
 	seq_buf_printf(&s, "slab_unreclaimable %llu\n",
-		       (u64)memcg_page_state(memcg, NR_SLAB_UNRECLAIMABLE) *
-		       PAGE_SIZE);
+		       (u64)memcg_page_state(memcg, NR_SLAB_UNRECLAIMABLE_B));
 
 	/* Accumulated memory events */
 
@@ -3564,8 +3567,8 @@ static void memcg_flush_percpu_vmstats(struct mem_cgroup *memcg, bool slab_only)
 	int min_idx, max_idx;
 
 	if (slab_only) {
-		min_idx = NR_SLAB_RECLAIMABLE;
-		max_idx = NR_SLAB_UNRECLAIMABLE;
+		min_idx = NR_SLAB_RECLAIMABLE_B;
+		max_idx = NR_SLAB_UNRECLAIMABLE_B;
 	} else {
 		min_idx = 0;
 		max_idx = MEMCG_NR_STAT;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 314ce1a3cf25..61476bf0f147 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -183,7 +183,7 @@ static bool is_dump_unreclaim_slabs(void)
 		 global_node_page_state(NR_ISOLATED_FILE) +
 		 global_node_page_state(NR_UNEVICTABLE);
 
-	return (global_node_page_state(NR_SLAB_UNRECLAIMABLE) > nr_lru);
+	return (global_node_page_state_pages(NR_SLAB_UNRECLAIMABLE_B) > nr_lru);
 }
 
 /**
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c5d62f1c2851..9da8ee92c226 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5100,8 +5100,8 @@ long si_mem_available(void)
 	 * items that are in use, and cannot be freed. Cap this estimate at the
 	 * low watermark.
 	 */
-	reclaimable = global_node_page_state(NR_SLAB_RECLAIMABLE) +
-			global_node_page_state(NR_KERNEL_MISC_RECLAIMABLE);
+	reclaimable = global_node_page_state_pages(NR_SLAB_RECLAIMABLE_B) +
+		global_node_page_state(NR_KERNEL_MISC_RECLAIMABLE);
 	available += reclaimable - min(reclaimable / 2, wmark_low);
 
 	if (available < 0)
@@ -5245,8 +5245,8 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 		global_node_page_state(NR_FILE_DIRTY),
 		global_node_page_state(NR_WRITEBACK),
 		global_node_page_state(NR_UNSTABLE_NFS),
-		global_node_page_state(NR_SLAB_RECLAIMABLE),
-		global_node_page_state(NR_SLAB_UNRECLAIMABLE),
+		global_node_page_state_pages(NR_SLAB_RECLAIMABLE_B),
+		global_node_page_state_pages(NR_SLAB_UNRECLAIMABLE_B),
 		global_node_page_state(NR_FILE_MAPPED),
 		global_node_page_state(NR_SHMEM),
 		global_zone_page_state(NR_PAGETABLE),
diff --git a/mm/slab.h b/mm/slab.h
index 68e455f2b698..7c5577c2b9ea 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -272,7 +272,7 @@ int __kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);
 static inline int cache_vmstat_idx(struct kmem_cache *s)
 {
 	return (s->flags & SLAB_RECLAIM_ACCOUNT) ?
-		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE;
+		NR_SLAB_RECLAIMABLE_B : NR_SLAB_UNRECLAIMABLE_B;
 }
 
 #ifdef CONFIG_MEMCG_KMEM
@@ -360,7 +360,7 @@ static __always_inline int memcg_charge_slab(struct page *page,
 
 	if (unlikely(!memcg || mem_cgroup_is_root(memcg))) {
 		mod_node_page_state(page_pgdat(page), cache_vmstat_idx(s),
-				    (1 << order));
+				    (PAGE_SIZE << order));
 		percpu_ref_get_many(&s->memcg_params.refcnt, 1 << order);
 		return 0;
 	}
@@ -370,7 +370,7 @@ static __always_inline int memcg_charge_slab(struct page *page,
 		goto out;
 
 	lruvec = mem_cgroup_lruvec(page_pgdat(page), memcg);
-	mod_lruvec_state(lruvec, cache_vmstat_idx(s), 1 << order);
+	mod_lruvec_state(lruvec, cache_vmstat_idx(s), PAGE_SIZE << order);
 
 	/* transer try_charge() page references to kmem_cache */
 	percpu_ref_get_many(&s->memcg_params.refcnt, 1 << order);
@@ -394,11 +394,12 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
 	memcg = READ_ONCE(s->memcg_params.memcg);
 	if (likely(!mem_cgroup_is_root(memcg))) {
 		lruvec = mem_cgroup_lruvec(page_pgdat(page), memcg);
-		mod_lruvec_state(lruvec, cache_vmstat_idx(s), -(1 << order));
+		mod_lruvec_state(lruvec, cache_vmstat_idx(s),
+				 -(PAGE_SIZE << order));
 		memcg_kmem_uncharge_memcg(page, order, memcg);
 	} else {
 		mod_node_page_state(page_pgdat(page), cache_vmstat_idx(s),
-				    -(1 << order));
+				    -(PAGE_SIZE << order));
 	}
 	rcu_read_unlock();
 
@@ -482,7 +483,7 @@ static __always_inline int charge_slab_page(struct page *page,
 {
 	if (is_root_cache(s)) {
 		mod_node_page_state(page_pgdat(page), cache_vmstat_idx(s),
-				    1 << order);
+				    PAGE_SIZE << order);
 		return 0;
 	}
 
@@ -494,7 +495,7 @@ static __always_inline void uncharge_slab_page(struct page *page, int order,
 {
 	if (is_root_cache(s)) {
 		mod_node_page_state(page_pgdat(page), cache_vmstat_idx(s),
-				    -(1 << order));
+				    -(PAGE_SIZE << order));
 		return;
 	}
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index c29f03adca91..79695d9c34f3 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1303,8 +1303,8 @@ void *kmalloc_order(size_t size, gfp_t flags, unsigned int order)
 	page = alloc_pages(flags, order);
 	if (likely(page)) {
 		ret = page_address(page);
-		mod_node_page_state(page_pgdat(page), NR_SLAB_UNRECLAIMABLE,
-				    1 << order);
+		mod_node_page_state(page_pgdat(page), NR_SLAB_UNRECLAIMABLE_B,
+				    PAGE_SIZE << order);
 	}
 	ret = kasan_kmalloc_large(ret, size, flags);
 	/* As ret might get tagged, call kmemleak hook after KASAN. */
diff --git a/mm/slob.c b/mm/slob.c
index fa53e9f73893..8b7b56235438 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -202,8 +202,8 @@ static void *slob_new_pages(gfp_t gfp, int order, int node)
 	if (!page)
 		return NULL;
 
-	mod_node_page_state(page_pgdat(page), NR_SLAB_UNRECLAIMABLE,
-			    1 << order);
+	mod_node_page_state(page_pgdat(page), NR_SLAB_UNRECLAIMABLE_B,
+			    PAGE_SIZE << order);
 	return page_address(page);
 }
 
@@ -214,8 +214,8 @@ static void slob_free_pages(void *b, int order)
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += 1 << order;
 
-	mod_node_page_state(page_pgdat(sp), NR_SLAB_UNRECLAIMABLE,
-			    -(1 << order));
+	mod_node_page_state(page_pgdat(sp), NR_SLAB_UNRECLAIMABLE_B,
+			    -(PAGE_SIZE << order));
 	__free_pages(sp, order);
 }
 
@@ -550,8 +550,8 @@ void kfree(const void *block)
 		slob_free(m, *m + align);
 	} else {
 		unsigned int order = compound_order(sp);
-		mod_node_page_state(page_pgdat(sp), NR_SLAB_UNRECLAIMABLE,
-				    -(1 << order));
+		mod_node_page_state(page_pgdat(sp), NR_SLAB_UNRECLAIMABLE_B,
+				    -(PAGE_SIZE << order));
 		__free_pages(sp, order);
 
 	}
diff --git a/mm/slub.c b/mm/slub.c
index c9856a9807f1..0873b77727bf 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3825,8 +3825,8 @@ static void *kmalloc_large_node(size_t size, gfp_t flags, int node)
 	page = alloc_pages_node(node, flags, order);
 	if (page) {
 		ptr = page_address(page);
-		mod_node_page_state(page_pgdat(page), NR_SLAB_UNRECLAIMABLE,
-				    1 << order);
+		mod_node_page_state(page_pgdat(page), NR_SLAB_UNRECLAIMABLE_B,
+				    PAGE_SIZE << order);
 	}
 
 	return kmalloc_large_node_hook(ptr, size, flags);
@@ -3957,8 +3957,8 @@ void kfree(const void *x)
 
 		BUG_ON(!PageCompound(page));
 		kfree_hook(object);
-		mod_node_page_state(page_pgdat(page), NR_SLAB_UNRECLAIMABLE,
-				    -(1 << order));
+		mod_node_page_state(page_pgdat(page), NR_SLAB_UNRECLAIMABLE_B,
+				    -(PAGE_SIZE << order));
 		__free_pages(page, order);
 		return;
 	}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index ee47bbcb99b5..283da9a39de2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -4272,7 +4272,8 @@ int node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned int order)
 	 * unmapped file backed pages.
 	 */
 	if (node_pagecache_reclaimable(pgdat) <= pgdat->min_unmapped_pages &&
-	    node_page_state(pgdat, NR_SLAB_RECLAIMABLE) <= pgdat->min_slab_pages)
+	    node_page_state_pages(pgdat, NR_SLAB_RECLAIMABLE_B) <=
+	    pgdat->min_slab_pages)
 		return NODE_RECLAIM_FULL;
 
 	/*
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 98f43725d910..d04f53997fd2 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -344,6 +344,8 @@ void __mod_node_page_state(struct pglist_data *pgdat, enum node_stat_item item,
 	x = delta + __this_cpu_read(*p);
 
 	t = __this_cpu_read(pcp->stat_threshold);
+	if (vmstat_item_in_bytes(item))
+		t <<= PAGE_SHIFT;
 
 	if (unlikely(x > t || x < -t)) {
 		node_page_state_add(x, pgdat, item);
@@ -555,6 +557,8 @@ static inline void mod_node_state(struct pglist_data *pgdat,
 		 * for all cpus in a node.
 		 */
 		t = this_cpu_read(pcp->stat_threshold);
+		if (vmstat_item_in_bytes(item))
+			t <<= PAGE_SHIFT;
 
 		o = this_cpu_read(*p);
 		n = delta + o;
@@ -999,6 +1003,12 @@ unsigned long node_page_state(struct pglist_data *pgdat,
 #endif
 	return x;
 }
+
+unsigned long node_page_state_pages(struct pglist_data *pgdat,
+				    enum node_stat_item item)
+{
+	return node_page_state(pgdat, item) >> PAGE_SHIFT;
+}
 #endif
 
 #ifdef CONFIG_COMPACTION
@@ -1547,10 +1557,13 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 	if (is_zone_first_populated(pgdat, zone)) {
 		seq_printf(m, "\n  per-node stats");
 		for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++) {
+			unsigned long x = node_page_state(pgdat, i);
+
+			if (vmstat_item_in_bytes(i))
+				x >>= PAGE_SHIFT;
 			seq_printf(m, "\n      %-12s %lu",
 				vmstat_text[i + NR_VM_ZONE_STAT_ITEMS +
-				NR_VM_NUMA_STAT_ITEMS],
-				node_page_state(pgdat, i));
+				NR_VM_NUMA_STAT_ITEMS], x);
 		}
 	}
 	seq_printf(m,
@@ -1679,8 +1692,11 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 	v += NR_VM_NUMA_STAT_ITEMS;
 #endif
 
-	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++) {
 		v[i] = global_node_page_state(i);
+		if (vmstat_item_in_bytes(i))
+			v[i] >>= PAGE_SHIFT;
+	}
 	v += NR_VM_NODE_STAT_ITEMS;
 
 	global_dirty_limits(v + NR_DIRTY_BG_THRESHOLD,
diff --git a/mm/workingset.c b/mm/workingset.c
index c963831d354f..675792387e58 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -430,8 +430,10 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 		for (pages = 0, i = 0; i < NR_LRU_LISTS; i++)
 			pages += lruvec_page_state_local(lruvec,
 							 NR_LRU_BASE + i);
-		pages += lruvec_page_state_local(lruvec, NR_SLAB_RECLAIMABLE);
-		pages += lruvec_page_state_local(lruvec, NR_SLAB_UNRECLAIMABLE);
+		pages += lruvec_page_state_local(
+			lruvec, NR_SLAB_RECLAIMABLE_B) >> PAGE_SHIFT;
+		pages += lruvec_page_state_local(
+			lruvec, NR_SLAB_UNRECLAIMABLE_B) >> PAGE_SHIFT;
 	} else
 #endif
 		pages = node_present_pages(sc->nid);
-- 
2.21.0


