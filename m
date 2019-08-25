Return-Path: <SRS0=zwjV=WV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4DA56C3A5A4
	for <linux-mm@archiver.kernel.org>; Sun, 25 Aug 2019 00:54:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0FF252190F
	for <linux-mm@archiver.kernel.org>; Sun, 25 Aug 2019 00:54:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="AZCZ5CG1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FF252190F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B19F06B04FD; Sat, 24 Aug 2019 20:54:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACB716B04FF; Sat, 24 Aug 2019 20:54:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A07A06B0500; Sat, 24 Aug 2019 20:54:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0054.hostedemail.com [216.40.44.54])
	by kanga.kvack.org (Postfix) with ESMTP id 824746B04FD
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 20:54:52 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 319F8181AC9B4
	for <linux-mm@kvack.org>; Sun, 25 Aug 2019 00:54:52 +0000 (UTC)
X-FDA: 75859130424.19.burn82_479499eaeb905
X-HE-Tag: burn82_479499eaeb905
X-Filterd-Recvd-Size: 3780
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 25 Aug 2019 00:54:51 +0000 (UTC)
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A04902190F;
	Sun, 25 Aug 2019 00:54:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566694490;
	bh=oDtFyeAh0PJ+Q411JYh5/5alblkC4nC7vhAYVRdeYPw=;
	h=Date:From:To:Subject:From;
	b=AZCZ5CG1iRFy6DDBDEGN2TTobvBPXuwctoVPSGHtTwtLYPmr9SbT5BpI0d9aK/+te
	 bNP/7zUGtUxkSY8mQueRRnJciQYLS5/Ua1S0fvXcWlGaF/9/Vz0H9T0b53OnYfgRzq
	 ABAsLMKYupZQ3erI/aQ1M3QB7WlrGfeGWon8OxOA=
Date: Sat, 24 Aug 2019 17:54:50 -0700
From: akpm@linux-foundation.org
To: akpm@linux-foundation.org, guro@fb.com, hannes@cmpxchg.org,
 linux-mm@kvack.org, mhocko@suse.com, mm-commits@vger.kernel.org,
 stable@vger.kernel.org, torvalds@linux-foundation.org,
 vdavydov.dev@gmail.com
Subject:  [patch 05/11] mm: memcontrol: flush percpu vmevents
 before releasing memcg
Message-ID: <20190825005450.VXGCpG7ix%akpm@linux-foundation.org>
User-Agent: s-nail v14.8.16
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Roman Gushchin <guro@fb.com>
Subject: mm: memcontrol: flush percpu vmevents before releasing memcg

Similar to vmstats, percpu caching of local vmevents leads to an
accumulation of errors on non-leaf levels.  This happens because some
leftovers may remain in percpu caches, so that they are never propagated
up by the cgroup tree and just disappear into nonexistence with on
releasing of the memory cgroup.

To fix this issue let's accumulate and propagate percpu vmevents values
before releasing the memory cgroup similar to what we're doing with
vmstats.

Since on cpu hotplug we do flush percpu vmstats anyway, we can iterate
only over online cpus.

Link: http://lkml.kernel.org/r/20190819202338.363363-4-guro@fb.com
Fixes: 42a300353577 ("mm: memcontrol: fix recursive statistics correctness & scalabilty")
Signed-off-by: Roman Gushchin <guro@fb.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/memcontrol.c |   22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

--- a/mm/memcontrol.c~mm-memcontrol-flush-percpu-vmevents-before-releasing-memcg
+++ a/mm/memcontrol.c
@@ -3295,6 +3295,25 @@ static void memcg_flush_percpu_vmstats(s
 	}
 }
 
+static void memcg_flush_percpu_vmevents(struct mem_cgroup *memcg)
+{
+	unsigned long events[NR_VM_EVENT_ITEMS];
+	struct mem_cgroup *mi;
+	int cpu, i;
+
+	for (i = 0; i < NR_VM_EVENT_ITEMS; i++)
+		events[i] = 0;
+
+	for_each_online_cpu(cpu)
+		for (i = 0; i < NR_VM_EVENT_ITEMS; i++)
+			events[i] += raw_cpu_read(
+				memcg->vmstats_percpu->events[i]);
+
+	for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
+		for (i = 0; i < NR_VM_EVENT_ITEMS; i++)
+			atomic_long_add(events[i], &mi->vmevents[i]);
+}
+
 #ifdef CONFIG_MEMCG_KMEM
 static int memcg_online_kmem(struct mem_cgroup *memcg)
 {
@@ -4718,10 +4737,11 @@ static void __mem_cgroup_free(struct mem
 	int node;
 
 	/*
-	 * Flush percpu vmstats to guarantee the value correctness
+	 * Flush percpu vmstats and vmevents to guarantee the value correctness
 	 * on parent's and all ancestor levels.
 	 */
 	memcg_flush_percpu_vmstats(memcg);
+	memcg_flush_percpu_vmevents(memcg);
 	for_each_node(node)
 		free_mem_cgroup_per_node_info(memcg, node);
 	free_percpu(memcg->vmstats_percpu);
_

