Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,URIBL_SBL,URIBL_SBL_A,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 085F4C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:41:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B743222BE8
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:41:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Fw6HTIlJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B743222BE8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B386D6B0008; Fri, 26 Jul 2019 09:41:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC0A06B000A; Fri, 26 Jul 2019 09:41:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 913E78E0002; Fri, 26 Jul 2019 09:41:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5AA616B0008
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 09:41:01 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i2so33229000pfe.1
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 06:41:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=MGg0FzB3p0TMwh4TZ9VIwTM0GGTGoxcaifJgS0GBTNE=;
        b=TY3QK2rLjAUBQex5WHL20Z12zoAq+3z2wBBVdBy1LekAKh43gsssWnTcWmrcLKz8nu
         rk5VbZEVHUJ1sb9f+KnxfSWBvxXUvuRlJUPao57GvWIm7ddyyrAb7T4nKdNUwuQsjsH8
         0nQxb+iV2EdGJ+Cj7qstIcJa3KDTZIfmNVumu/COH44CX2gbSNYd8EM1qdMXDNyNYl4B
         gO6k6OZD2wLRkzSYZakhj75xtV9mFLszecZGEOi4YlL0BxE52jtllGnAQ1fNMHx25xtk
         tKVPXQXX3w6LYXu41pwrRsgmn56ychVSS0JO/V2GjcGVFTCD2DRUwqh28pu9h/2A71fu
         FeKw==
X-Gm-Message-State: APjAAAWsOPW1UMgG0EKFqSr7tW2L6ovHSyebxwRvjsjOEXRZ2Ugg3z8n
	1+KFvBK/Le5Gn79NJSzLwyrukDM+Qnps2TQrISmGl3U5RKmJ0Ty9g3ik1d3PwXROVwZiLkMFUd/
	iRbwB8+NMSQgdq1P4ScqZOMQ7geSL3gcWF4L6fQSS9oWhgKguQUS9oRdKVIhulellJg==
X-Received: by 2002:a65:5188:: with SMTP id h8mr58792508pgq.294.1564148460836;
        Fri, 26 Jul 2019 06:41:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwS4JJYrtoHxwAPp1jIIep6naQW0kUoIuWsna1JwGBHfNtC++UpGqdfp9trJeuYdS7pL8ys
X-Received: by 2002:a65:5188:: with SMTP id h8mr58792471pgq.294.1564148460075;
        Fri, 26 Jul 2019 06:41:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564148460; cv=none;
        d=google.com; s=arc-20160816;
        b=HRj6Vhi9uR4tYvRDzX364M6Bs7Na3/3/ugE5Jg1FNB0/qDte2bU5lcyz8/aD4ExPZ4
         hX3u+g6VKGm6LKZTjZiImMI8SoXRrs5XsYPUUx3K1cIZNiI1zQ3xtHeSWRtUMbCZuxCQ
         mFCrRiXU7eb9zKzGV9wMP0hXuGp2K3M8DCkTIYZB0Q4TXlyqiX1iKzpqv26o9OrWNoF3
         GJ4Wq2j35xDm2InP5zZfIgOYYTOoAZvoEGUAqMiWZfowaRhylyJqI+p+mJ/Ei0pTqudv
         Kir01lXHZVk6yw+F5fpKrDIZ6oUN497MR8tY3KVfBN17q0fyNiZ93F8ORggki9I9rIKQ
         2H7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=MGg0FzB3p0TMwh4TZ9VIwTM0GGTGoxcaifJgS0GBTNE=;
        b=qcN9xcqJkKREHCGenNS5XyJIGRXko+heTZTAeNv/4FVb9qV++MXPYqxlUGSw71zk/5
         VSDx65OdtwOZ8gJsQQ1ZoPHyzFlq3VNuJtSQyBWAbPuTh0wHp1MvwMxXIp+CAjeaaEoh
         VSOBZn5tWPgm6DFFAEF1UDMYG89Y7umyc+t+ybXs177mDsnkXm97Plebq9FfuBd87h7s
         K/EfCFksF+ylp7RhmgdSuAqBNTtyBQydUskNWUlPUou1aHBGA/jhRW8YtkGFus14HsnA
         LQRjAWsE13Fq921b2N10Mc8h9KDzPBg/AD9G9QugMS6zDBE0JwxchXzU47p+SkkqP++B
         798Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Fw6HTIlJ;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t6si20562463pfe.231.2019.07.26.06.40.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 06:41:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Fw6HTIlJ;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 935C122CD5;
	Fri, 26 Jul 2019 13:40:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564148459;
	bh=kL3mlcYcc+Q9jAb4Pl1atYrXYmTb6HeWN92nUpHLk3A=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=Fw6HTIlJ+dAqBanjdLDnU16zhOoRdqUtIylBtdNW2WzzF5FvL2Cx8vuj8jhqG1j9M
	 M3B+u6aLF4Gk3rzzT/VYncTazb8cwYNb5xdX3nivM5JTBdyB7WLV2x2rmt8R/F2hxY
	 U7BmMX8rV2rgejZsHmQ2yjPpYzbhRRGaDk4MvuHs=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Yafang Shao <laoar.shao@gmail.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Yafang Shao <shaoyafang@didiglobal.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	cgroups@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.2 52/85] mm/memcontrol.c: keep local VM counters in sync with the hierarchical ones
Date: Fri, 26 Jul 2019 09:39:02 -0400
Message-Id: <20190726133936.11177-52-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190726133936.11177-1-sashal@kernel.org>
References: <20190726133936.11177-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Yafang Shao <laoar.shao@gmail.com>

[ Upstream commit 766a4c19d880887c457811b86f1f68525e416965 ]

After commit 815744d75152 ("mm: memcontrol: don't batch updates of local
VM stats and events"), the local VM counter are not in sync with the
hierarchical ones.

Below is one example in a leaf memcg on my server (with 8 CPUs):

	inactive_file 3567570944
	total_inactive_file 3568029696

We find that the deviation is very great because the 'val' in
__mod_memcg_state() is in pages while the effective value in
memcg_stat_show() is in bytes.

So the maximum of this deviation between local VM stats and total VM
stats can be (32 * number_of_cpu * PAGE_SIZE), that may be an
unacceptably great value.

We should keep the local VM stats in sync with the total stats.  In
order to keep this behavior the same across counters, this patch updates
__mod_lruvec_state() and __count_memcg_events() as well.

Link: http://lkml.kernel.org/r/1562851979-10610-1-git-send-email-laoar.shao@gmail.com
Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Yafang Shao <shaoyafang@didiglobal.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/memcontrol.c | 22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ba9138a4a1de..07b4ca559bcc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -691,12 +691,15 @@ void __mod_memcg_state(struct mem_cgroup *memcg, int idx, int val)
 	if (mem_cgroup_disabled())
 		return;
 
-	__this_cpu_add(memcg->vmstats_local->stat[idx], val);
-
 	x = val + __this_cpu_read(memcg->vmstats_percpu->stat[idx]);
 	if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
 		struct mem_cgroup *mi;
 
+		/*
+		 * Batch local counters to keep them in sync with
+		 * the hierarchical ones.
+		 */
+		__this_cpu_add(memcg->vmstats_local->stat[idx], x);
 		for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
 			atomic_long_add(x, &mi->vmstats[idx]);
 		x = 0;
@@ -745,13 +748,15 @@ void __mod_lruvec_state(struct lruvec *lruvec, enum node_stat_item idx,
 	/* Update memcg */
 	__mod_memcg_state(memcg, idx, val);
 
-	/* Update lruvec */
-	__this_cpu_add(pn->lruvec_stat_local->count[idx], val);
-
 	x = val + __this_cpu_read(pn->lruvec_stat_cpu->count[idx]);
 	if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
 		struct mem_cgroup_per_node *pi;
 
+		/*
+		 * Batch local counters to keep them in sync with
+		 * the hierarchical ones.
+		 */
+		__this_cpu_add(pn->lruvec_stat_local->count[idx], x);
 		for (pi = pn; pi; pi = parent_nodeinfo(pi, pgdat->node_id))
 			atomic_long_add(x, &pi->lruvec_stat[idx]);
 		x = 0;
@@ -773,12 +778,15 @@ void __count_memcg_events(struct mem_cgroup *memcg, enum vm_event_item idx,
 	if (mem_cgroup_disabled())
 		return;
 
-	__this_cpu_add(memcg->vmstats_local->events[idx], count);
-
 	x = count + __this_cpu_read(memcg->vmstats_percpu->events[idx]);
 	if (unlikely(x > MEMCG_CHARGE_BATCH)) {
 		struct mem_cgroup *mi;
 
+		/*
+		 * Batch local counters to keep them in sync with
+		 * the hierarchical ones.
+		 */
+		__this_cpu_add(memcg->vmstats_local->events[idx], x);
 		for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
 			atomic_long_add(x, &mi->vmevents[idx]);
 		x = 0;
-- 
2.20.1

