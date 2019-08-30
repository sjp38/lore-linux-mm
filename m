Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1808CC3A5A6
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 23:04:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC1D12343D
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 23:04:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="KdcYK/Er"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC1D12343D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B33A6B000C; Fri, 30 Aug 2019 19:04:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 664936B000D; Fri, 30 Aug 2019 19:04:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5796D6B000E; Fri, 30 Aug 2019 19:04:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0054.hostedemail.com [216.40.44.54])
	by kanga.kvack.org (Postfix) with ESMTP id 339926B000C
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 19:04:43 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id DC244181AC9AE
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 23:04:42 +0000 (UTC)
X-FDA: 75880625604.26.talk66_291e0b176732c
X-HE-Tag: talk66_291e0b176732c
X-Filterd-Recvd-Size: 4151
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 23:04:42 +0000 (UTC)
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 370082343B;
	Fri, 30 Aug 2019 23:04:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1567206281;
	bh=P9JwtoFE4dUzqEeLWL39JApIh4Pvvk+uUQ3+QyiWhzQ=;
	h=Date:From:To:Subject:From;
	b=KdcYK/ErY46cf8C+FZjPpT9RfkX+yHrC8mquILc/p5piX8Xy6Gm8AWjsryMdmhWS7
	 sE2TM7qSFi336S1aXFES2HUkU4UjWdKCKh++ca5l0VQR/vq3h9VW2YwtxBLAo/wY6t
	 ptvOXbBJLgTqGhFUJwVAzfraTU19XYQjVM8lMA/I=
Date: Fri, 30 Aug 2019 16:04:39 -0700
From: akpm@linux-foundation.org
To: akpm@linux-foundation.org, guro@fb.com, hannes@cmpxchg.org,
 laoar.shao@gmail.com, linux-mm@kvack.org, mhocko@kernel.org,
 mm-commits@vger.kernel.org, stable@vger.kernel.org,
 torvalds@linux-foundation.org
Subject:  [patch 3/7] mm, memcg: partially revert "mm/memcontrol.c:
 keep local VM counters in sync with the hierarchical ones"
Message-ID: <20190830230439.CUHEZRcvZ%akpm@linux-foundation.org>
User-Agent: s-nail v14.8.16
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Roman Gushchin <guro@fb.com>
Subject: mm, memcg: partially revert "mm/memcontrol.c: keep local VM counters in sync with the hierarchical ones"

Commit 766a4c19d880 ("mm/memcontrol.c: keep local VM counters in sync with
the hierarchical ones") effectively decreased the precision of per-memcg
vmstats_local and per-memcg-per-node lruvec percpu counters.

That's good for displaying in memory.stat, but brings a serious regression
into the reclaim process.

One issue I've discovered and debugged is the following: lruvec_lru_size()
can return 0 instead of the actual number of pages in the lru list,
preventing the kernel to reclaim last remaining pages.  Result is yet
another dying memory cgroups flooding.  The opposite is also happening:
scanning an empty lru list is the waste of cpu time.

Also, inactive_list_is_low() can return incorrect values, preventing the
active lru from being scanned and freed.  It can fail both because the
size of active and inactive lists are inaccurate, and because the number
of workingset refaults isn't precise.  In other words, the result is
pretty random.

I'm not sure, if using the approximate number of slab pages in
count_shadow_number() is acceptable, but issues described above are enough
to partially revert the patch.

Let's keep per-memcg vmstat_local batched (they are only used for
displaying stats to the userspace), but keep lruvec stats precise.  This
change fixes the dead memcg flooding on my setup.

Link: http://lkml.kernel.org/r/20190817004726.2530670-1-guro@fb.com
Fixes: 766a4c19d880 ("mm/memcontrol.c: keep local VM counters in sync with the hierarchical ones")
Signed-off-by: Roman Gushchin <guro@fb.com>
Acked-by: Yafang Shao <laoar.shao@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/memcontrol.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

--- a/mm/memcontrol.c~partially-revert-mm-memcontrolc-keep-local-vm-counters-in-sync-with-the-hierarchical-ones
+++ a/mm/memcontrol.c
@@ -752,15 +752,13 @@ void __mod_lruvec_state(struct lruvec *l
 	/* Update memcg */
 	__mod_memcg_state(memcg, idx, val);
 
+	/* Update lruvec */
+	__this_cpu_add(pn->lruvec_stat_local->count[idx], val);
+
 	x = val + __this_cpu_read(pn->lruvec_stat_cpu->count[idx]);
 	if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
 		struct mem_cgroup_per_node *pi;
 
-		/*
-		 * Batch local counters to keep them in sync with
-		 * the hierarchical ones.
-		 */
-		__this_cpu_add(pn->lruvec_stat_local->count[idx], x);
 		for (pi = pn; pi; pi = parent_nodeinfo(pi, pgdat->node_id))
 			atomic_long_add(x, &pi->lruvec_stat[idx]);
 		x = 0;
_

