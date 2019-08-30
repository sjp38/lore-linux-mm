Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34DF8C3A59B
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 23:04:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D65662343B
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 23:04:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="wvItWZOL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D65662343B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D6CC6B0008; Fri, 30 Aug 2019 19:04:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 886876B000A; Fri, 30 Aug 2019 19:04:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C4316B000C; Fri, 30 Aug 2019 19:04:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0226.hostedemail.com [216.40.44.226])
	by kanga.kvack.org (Postfix) with ESMTP id 59A8A6B0008
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 19:04:35 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 02F97824CA3A
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 23:04:35 +0000 (UTC)
X-FDA: 75880625310.24.team00_27f319c7be338
X-HE-Tag: team00_27f319c7be338
X-Filterd-Recvd-Size: 6191
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 23:04:34 +0000 (UTC)
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3024423430;
	Fri, 30 Aug 2019 23:04:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1567206273;
	bh=3QIQU0+eV9xEx2tw2zCzTxTXFMxxeJ3boCCt1P6mvKI=;
	h=Date:From:To:Subject:From;
	b=wvItWZOLaZOD4aID5BsC5HeUguM9upNN2a4t4Ax0aqI1R/9UnX0JX37WCSIjMYOfK
	 YcLDwr31Z9C50858pK5r7jU0fg1e4Y+gDGHrSEqXO1vkkV7flp8lZEPcKRSJu1ncBg
	 sr5+ZNNZK8Pwmf3RF85xL/b53xlsQ0J4zelOOsk8=
Date: Fri, 30 Aug 2019 16:04:32 -0700
From: akpm@linux-foundation.org
To: akpm@linux-foundation.org, guro@fb.com, hannes@cmpxchg.org,
 linux-mm@kvack.org, mhocko@kernel.org, mm-commits@vger.kernel.org,
 torvalds@linux-foundation.org, vdavydov.dev@gmail.com
Subject:  [patch 1/7] mm: memcontrol: flush percpu slab vmstats on
 kmem offlining
Message-ID: <20190830230432.WqlvzriFX%akpm@linux-foundation.org>
User-Agent: s-nail v14.8.16
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Roman Gushchin <guro@fb.com>
Subject: mm: memcontrol: flush percpu slab vmstats on kmem offlining

I've noticed that the "slab" value in memory.stat is sometimes 0, even if
some children memory cgroups have a non-zero "slab" value.  The following
investigation showed that this is the result of the kmem_cache reparenting
in combination with the per-cpu batching of slab vmstats.

At the offlining some vmstat value may leave in the percpu cache, not
being propagated upwards by the cgroup hierarchy.  It means that stats on
ancestor levels are lower than actual.  Later when slab pages are
released, the precise number of pages is substracted on the parent level,
making the value negative.  We don't show negative values, 0 is printed
instead.

To fix this issue, let's flush percpu slab memcg and lruvec stats on memcg
offlining.  This guarantees that numbers on all ancestor levels are
accurate and match the actual number of outstanding slab pages.

Link: http://lkml.kernel.org/r/20190819202338.363363-3-guro@fb.com
Fixes: fb2f2b0adb98 ("mm: memcg/slab: reparent memcg kmem_caches on cgroup removal")
Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/mmzone.h |    5 +++--
 mm/memcontrol.c        |   35 +++++++++++++++++++++++++++--------
 2 files changed, 30 insertions(+), 10 deletions(-)

--- a/include/linux/mmzone.h~mm-memcontrol-flush-percpu-slab-vmstats-on-kmem-offlining
+++ a/include/linux/mmzone.h
@@ -215,8 +215,9 @@ enum node_stat_item {
 	NR_INACTIVE_FILE,	/*  "     "     "   "       "         */
 	NR_ACTIVE_FILE,		/*  "     "     "   "       "         */
 	NR_UNEVICTABLE,		/*  "     "     "   "       "         */
-	NR_SLAB_RECLAIMABLE,
-	NR_SLAB_UNRECLAIMABLE,
+	NR_SLAB_RECLAIMABLE,	/* Please do not reorder this item */
+	NR_SLAB_UNRECLAIMABLE,	/* and this one without looking at
+				 * memcg_flush_percpu_vmstats() first. */
 	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
 	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
 	WORKINGSET_NODES,
--- a/mm/memcontrol.c~mm-memcontrol-flush-percpu-slab-vmstats-on-kmem-offlining
+++ a/mm/memcontrol.c
@@ -3260,37 +3260,49 @@ static u64 mem_cgroup_read_u64(struct cg
 	}
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
@@ -3363,7 +3375,14 @@ static void memcg_offline_kmem(struct me
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
@@ -4740,7 +4759,7 @@ static void __mem_cgroup_free(struct mem
 	 * Flush percpu vmstats and vmevents to guarantee the value correctness
 	 * on parent's and all ancestor levels.
 	 */
-	memcg_flush_percpu_vmstats(memcg);
+	memcg_flush_percpu_vmstats(memcg, false);
 	memcg_flush_percpu_vmevents(memcg);
 	for_each_node(node)
 		free_mem_cgroup_per_node_info(memcg, node);
_

