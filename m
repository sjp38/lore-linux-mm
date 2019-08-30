Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9AF12C3A59B
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 23:04:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A8082343B
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 23:04:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="deO+bEua"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A8082343B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 10EA36B0010; Fri, 30 Aug 2019 19:04:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0BE776B0266; Fri, 30 Aug 2019 19:04:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECD216B0269; Fri, 30 Aug 2019 19:04:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0152.hostedemail.com [216.40.44.152])
	by kanga.kvack.org (Postfix) with ESMTP id C5AC06B0010
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 19:04:52 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 664E5AC18
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 23:04:52 +0000 (UTC)
X-FDA: 75880626024.24.rod34_2a7fc28b42146
X-HE-Tag: rod34_2a7fc28b42146
X-Filterd-Recvd-Size: 4014
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 23:04:51 +0000 (UTC)
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7DD7F23711;
	Fri, 30 Aug 2019 23:04:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1567206290;
	bh=UXJ0EujneT5XTD+VEOHzRwZiNEM6Ozy7IvUxmJ84Ss0=;
	h=Date:From:To:Subject:From;
	b=deO+bEuaY/vYxRu7ptSfseS0bM0ON8jajgkY0hHge83QK1xsI4nmR2qvffjL3NC49
	 Ig6hejvM2CG7fNRB6nhLbD7cl58dVyKOCTXQoXYqC/37wBpm7w5A1bR/JQu+/SULAA
	 nlR3EpwX261GQ0q1VerMT8zhwq2M1ynEdknqi9D8=
Date: Fri, 30 Aug 2019 16:04:50 -0700
From: akpm@linux-foundation.org
To: akpm@linux-foundation.org, hannes@cmpxchg.org, hdanton@sina.com,
 laoar.shao@gmail.com, linux-mm@kvack.org, mhocko@suse.com,
 mm-commits@vger.kernel.org, promarbler14@gmail.com,
 torvalds@linux-foundation.org, yang.shi@linux.alibaba.com
Subject:  [patch 6/7] mm, memcg: do not set reclaim_state on soft
 limit reclaim
Message-ID: <20190830230450.zHIGf1pKy%akpm@linux-foundation.org>
User-Agent: s-nail v14.8.16
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Michal Hocko <mhocko@suse.com>
Subject: mm, memcg: do not set reclaim_state on soft limit reclaim

Adric Blake has noticed[1] the following warning:
[38491.963105] WARNING: CPU: 7 PID: 175 at mm/vmscan.c:245 set_task_reclaim_state+0x1e/0x40
[...]
[38491.963239] Call Trace:
[38491.963246]  mem_cgroup_shrink_node+0x9b/0x1d0
[38491.963250]  mem_cgroup_soft_limit_reclaim+0x10c/0x3a0
[38491.963254]  balance_pgdat+0x276/0x540
[38491.963258]  kswapd+0x200/0x3f0
[38491.963261]  ? wait_woken+0x80/0x80
[38491.963265]  kthread+0xfd/0x130
[38491.963267]  ? balance_pgdat+0x540/0x540
[38491.963269]  ? kthread_park+0x80/0x80
[38491.963273]  ret_from_fork+0x35/0x40
[38491.963276] ---[ end trace 727343df67b2398a ]---

which tells us that soft limit reclaim is about to overwrite the
reclaim_state configured up in the call chain (kswapd in this case but the
direct reclaim is equally possible).  This means that reclaim stats would
get misleading once the soft reclaim returns and another reclaim is done.

Fix the warning by dropping set_task_reclaim_state from the soft reclaim
which is always called with reclaim_state set up.

[1] http://lkml.kernel.org/r/CAE1jjeePxYPvw1mw2B3v803xHVR_BNnz0hQUY_JDMN8ny29M6w@mail.gmail.com

Link: http://lkml.kernel.org/r/20190828071808.20410-1-mhocko@kernel.org
Signed-off-by: Michal Hocko <mhocko@suse.com>
Reported-by: Adric Blake <promarbler14@gmail.com>
Acked-by: Yafang Shao <laoar.shao@gmail.com>
Acked-by: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hillf Danton <hdanton@sina.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/vmscan.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- a/mm/vmscan.c~mm-memcg-do-not-set-reclaim_state-on-soft-limit-reclaim
+++ a/mm/vmscan.c
@@ -3220,6 +3220,7 @@ unsigned long try_to_free_pages(struct z
 
 #ifdef CONFIG_MEMCG
 
+/* Only used by soft limit reclaim. Do not reuse for anything else. */
 unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
 						gfp_t gfp_mask, bool noswap,
 						pg_data_t *pgdat,
@@ -3235,7 +3236,8 @@ unsigned long mem_cgroup_shrink_node(str
 	};
 	unsigned long lru_pages;
 
-	set_task_reclaim_state(current, &sc.reclaim_state);
+	WARN_ON_ONCE(!current->reclaim_state);
+
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
 
@@ -3253,7 +3255,6 @@ unsigned long mem_cgroup_shrink_node(str
 
 	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
 
-	set_task_reclaim_state(current, NULL);
 	*nr_scanned = sc.nr_scanned;
 
 	return sc.nr_reclaimed;
_

