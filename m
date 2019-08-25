Return-Path: <SRS0=zwjV=WV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 841DAC3A5A4
	for <linux-mm@archiver.kernel.org>; Sun, 25 Aug 2019 00:54:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 467D12190F
	for <linux-mm@archiver.kernel.org>; Sun, 25 Aug 2019 00:54:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="s36VIb77"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 467D12190F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC7606B04FB; Sat, 24 Aug 2019 20:54:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E74896B04FD; Sat, 24 Aug 2019 20:54:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D66486B04FE; Sat, 24 Aug 2019 20:54:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0025.hostedemail.com [216.40.44.25])
	by kanga.kvack.org (Postfix) with ESMTP id B62FD6B04FB
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 20:54:49 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 611024820
	for <linux-mm@kvack.org>; Sun, 25 Aug 2019 00:54:49 +0000 (UTC)
X-FDA: 75859130298.22.smile33_471e498b9e562
X-HE-Tag: smile33_471e498b9e562
X-Filterd-Recvd-Size: 4898
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 25 Aug 2019 00:54:48 +0000 (UTC)
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 73EAD22CE3;
	Sun, 25 Aug 2019 00:54:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566694487;
	bh=sZLrUwfxCBbdM8PK8O0U93Mf5Xfl+lDvsy3+XCkpuvA=;
	h=Date:From:To:Subject:From;
	b=s36VIb77QroDG9pO3hPB3BOcqFzGpvb1OkV7gBEvl53G9WWY8NEBvd++oIUnHemsD
	 k7HolEY+0dbcAbc8sxX5oRfh+sx+LscUaMbbGAzIExiObKyGKsooFrB2EGVX5+F/ln
	 xrorf5uNMFDw/tmDv5HTLJzTQIJ1Nu1fqWFcWxDs=
Date: Sat, 24 Aug 2019 17:54:47 -0700
From: akpm@linux-foundation.org
To: akpm@linux-foundation.org, guro@fb.com, hannes@cmpxchg.org,
 linux-mm@kvack.org, mhocko@suse.com, mm-commits@vger.kernel.org,
 stable@vger.kernel.org, torvalds@linux-foundation.org,
 vdavydov.dev@gmail.com
Subject:  [patch 04/11] mm: memcontrol: flush percpu vmstats before
 releasing memcg
Message-ID: <20190825005447.6PmKju-ud%akpm@linux-foundation.org>
User-Agent: s-nail v14.8.16
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Roman Gushchin <guro@fb.com>
Subject: mm: memcontrol: flush percpu vmstats before releasing memcg

Percpu caching of local vmstats with the conditional propagation by the
cgroup tree leads to an accumulation of errors on non-leaf levels.

Let's imagine two nested memory cgroups A and A/B.  Say, a process
belonging to A/B allocates 100 pagecache pages on the CPU 0.  The percpu
cache will spill 3 times, so that 32*3=96 pages will be accounted to A/B
and A atomic vmstat counters, 4 pages will remain in the percpu cache.

Imagine A/B is nearby memory.max, so that every following allocation
triggers a direct reclaim on the local CPU.  Say, each such attempt will
free 16 pages on a new cpu.  That means every percpu cache will have -16
pages, except the first one, which will have 4 - 16 = -12.  A/B and A
atomic counters will not be touched at all.

Now a user removes A/B.  All percpu caches are freed and corresponding
vmstat numbers are forgotten.  A has 96 pages more than expected.

As memory cgroups are created and destroyed, errors do accumulate.  Even
1-2 pages differences can accumulate into large numbers.

To fix this issue let's accumulate and propagate percpu vmstat values
before releasing the memory cgroup.  At this point these numbers are
stable and cannot be changed.

Since on cpu hotplug we do flush percpu vmstats anyway, we can iterate
only over online cpus.

Link: http://lkml.kernel.org/r/20190819202338.363363-2-guro@fb.com
Fixes: 42a300353577 ("mm: memcontrol: fix recursive statistics correctness & scalabilty")
Signed-off-by: Roman Gushchin <guro@fb.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/memcontrol.c |   40 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 40 insertions(+)

--- a/mm/memcontrol.c~mm-memcontrol-flush-percpu-vmstats-before-releasing-memcg
+++ a/mm/memcontrol.c
@@ -3260,6 +3260,41 @@ static u64 mem_cgroup_read_u64(struct cg
 	}
 }
 
+static void memcg_flush_percpu_vmstats(struct mem_cgroup *memcg)
+{
+	unsigned long stat[MEMCG_NR_STAT];
+	struct mem_cgroup *mi;
+	int node, cpu, i;
+
+	for (i = 0; i < MEMCG_NR_STAT; i++)
+		stat[i] = 0;
+
+	for_each_online_cpu(cpu)
+		for (i = 0; i < MEMCG_NR_STAT; i++)
+			stat[i] += raw_cpu_read(memcg->vmstats_percpu->stat[i]);
+
+	for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
+		for (i = 0; i < MEMCG_NR_STAT; i++)
+			atomic_long_add(stat[i], &mi->vmstats[i]);
+
+	for_each_node(node) {
+		struct mem_cgroup_per_node *pn = memcg->nodeinfo[node];
+		struct mem_cgroup_per_node *pi;
+
+		for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+			stat[i] = 0;
+
+		for_each_online_cpu(cpu)
+			for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+				stat[i] += raw_cpu_read(
+					pn->lruvec_stat_cpu->count[i]);
+
+		for (pi = pn; pi; pi = parent_nodeinfo(pi, node))
+			for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+				atomic_long_add(stat[i], &pi->lruvec_stat[i]);
+	}
+}
+
 #ifdef CONFIG_MEMCG_KMEM
 static int memcg_online_kmem(struct mem_cgroup *memcg)
 {
@@ -4682,6 +4717,11 @@ static void __mem_cgroup_free(struct mem
 {
 	int node;
 
+	/*
+	 * Flush percpu vmstats to guarantee the value correctness
+	 * on parent's and all ancestor levels.
+	 */
+	memcg_flush_percpu_vmstats(memcg);
 	for_each_node(node)
 		free_mem_cgroup_per_node_info(memcg, node);
 	free_percpu(memcg->vmstats_percpu);
_

