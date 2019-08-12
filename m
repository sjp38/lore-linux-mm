Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40914C41514
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 22:29:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E69C320842
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 22:29:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="TLnOzqgz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E69C320842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 935566B0003; Mon, 12 Aug 2019 18:29:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8984C6B0006; Mon, 12 Aug 2019 18:29:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5622D6B0003; Mon, 12 Aug 2019 18:29:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0189.hostedemail.com [216.40.44.189])
	by kanga.kvack.org (Postfix) with ESMTP id 2D55C6B0006
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 18:29:18 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id CB939348D
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 22:29:17 +0000 (UTC)
X-FDA: 75815217954.06.night57_8b4f98799b856
X-HE-Tag: night57_8b4f98799b856
X-Filterd-Recvd-Size: 6606
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com [67.231.153.30])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 22:29:17 +0000 (UTC)
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x7CMQV8M010905
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 15:29:16 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=SQoTC+NCQQ9W6x5cD8PLwp0PTrO5Opz10F4qJlZ53tY=;
 b=TLnOzqgzRboIpRY4BnaeQovFE15XNzwfELwSI4KfQxuMZncrNZXqmf1zF3r+EKjgjk7m
 K8Xd09EQ8mjEcLt/zfM+r/aEnXuELcYzQWixQlfmYrrKJDV6w0kAbVWaLveswp8Wmhyq
 wDept8AaR4Knz+nTWsEabeI1zxjmo4E5Fz0= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by m0001303.ppops.net with ESMTP id 2ubbbpsm25-4
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 15:29:16 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::6) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Mon, 12 Aug 2019 15:29:15 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 1E13E163FCBF8; Mon, 12 Aug 2019 15:29:14 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: Andrew Morton <akpm@linux-foundation.org>, <linux-mm@kvack.org>
CC: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Roman Gushchin
	<guro@fb.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH 2/2] mm: memcontrol: flush percpu slab vmstats on kmem offlining
Date: Mon, 12 Aug 2019 15:29:11 -0700
Message-ID: <20190812222911.2364802-3-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190812222911.2364802-1-guro@fb.com>
References: <20190812222911.2364802-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-12_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=706 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908120218
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I've noticed that the "slab" value in memory.stat is sometimes 0,
even if some children memory cgroups have a non-zero "slab" value.
The following investigation showed that this is the result
of the kmem_cache reparenting in combination with the per-cpu
batching of slab vmstats.

At the offlining some vmstat value may leave in the percpu cache,
not being propagated upwards by the cgroup hierarchy. It means
that stats on ancestor levels are lower than actual. Later when
slab pages are released, the precise number of pages is substracted
on the parent level, making the value negative. We don't show negative
values, 0 is printed instead.

To fix this issue, let's flush percpu slab memcg and lruvec stats
on memcg offlining. This guarantees that numbers on all ancestor
levels are accurate and match the actual number of outstanding
slab pages.

Fixes: fb2f2b0adb98 ("mm: memcg/slab: reparent memcg kmem_caches on cgroup removal")
Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 35 +++++++++++++++++++++++++++--------
 1 file changed, 27 insertions(+), 8 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 348f685ab94b..6d2427abcc0c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3412,37 +3412,49 @@ static int memcg_online_kmem(struct mem_cgroup *memcg)
 	return 0;
 }
 
-static void memcg_flush_percpu_vmstats(struct mem_cgroup *memcg)
+static void memcg_flush_percpu_vmstats(struct mem_cgroup *memcg, bool slab_only)
 {
 	unsigned long stat[MEMCG_NR_STAT];
 	struct mem_cgroup *mi;
 	int node, cpu, i;
+	int min_idx, max_idx;
 
-	for (i = 0; i < MEMCG_NR_STAT; i++)
+	if (slab_only) {
+		min_idx = NR_SLAB_RECLAIMABLE;
+		max_idx = NR_SLAB_UNRECLAIMABLE;
+	} else {
+		min_idx = 0;
+		max_idx = MEMCG_NR_STAT;
+	}
+
+	for (i = min_idx; i < max_idx; i++)
 		stat[i] = 0;
 
 	for_each_online_cpu(cpu)
-		for (i = 0; i < MEMCG_NR_STAT; i++)
+		for (i = min_idx; i < max_idx; i++)
 			stat[i] += raw_cpu_read(memcg->vmstats_percpu->stat[i]);
 
 	for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
-		for (i = 0; i < MEMCG_NR_STAT; i++)
+		for (i = min_idx; i < max_idx; i++)
 			atomic_long_add(stat[i], &mi->vmstats[i]);
 
+	if (!slab_only)
+		max_idx = NR_VM_NODE_STAT_ITEMS;
+
 	for_each_node(node) {
 		struct mem_cgroup_per_node *pn = memcg->nodeinfo[node];
 		struct mem_cgroup_per_node *pi;
 
-		for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+		for (i = min_idx; i < max_idx; i++)
 			stat[i] = 0;
 
 		for_each_online_cpu(cpu)
-			for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+			for (i = min_idx; i < max_idx; i++)
 				stat[i] += raw_cpu_read(
 					pn->lruvec_stat_cpu->count[i]);
 
 		for (pi = pn; pi; pi = parent_nodeinfo(pi, node))
-			for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+			for (i = min_idx; i < max_idx; i++)
 				atomic_long_add(stat[i], &pi->lruvec_stat[i]);
 	}
 }
@@ -3467,7 +3479,14 @@ static void memcg_offline_kmem(struct mem_cgroup *memcg)
 	if (!parent)
 		parent = root_mem_cgroup;
 
+	/*
+	 * Deactivate and reparent kmem_caches. Then flush percpu
+	 * slab statistics to have precise values at the parent and
+	 * all ancestor levels. It's required to keep slab stats
+	 * accurate after the reparenting of kmem_caches.
+	 */
 	memcg_deactivate_kmem_caches(memcg, parent);
+	memcg_flush_percpu_vmstats(memcg, true);
 
 	kmemcg_id = memcg->kmemcg_id;
 	BUG_ON(kmemcg_id < 0);
@@ -4844,7 +4863,7 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 	 * Flush percpu vmstats to guarantee the value correctness
 	 * on parent's and all ancestor levels.
 	 */
-	memcg_flush_percpu_vmstats(memcg);
+	memcg_flush_percpu_vmstats(memcg, false);
 	for_each_node(node)
 		free_mem_cgroup_per_node_info(memcg, node);
 	free_percpu(memcg->vmstats_percpu);
-- 
2.21.0


