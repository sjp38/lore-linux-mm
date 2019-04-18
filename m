Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13537C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 21:42:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA28C217D7
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 21:42:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="oaWnOGJj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA28C217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 211556B0005; Thu, 18 Apr 2019 17:42:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 196AB6B0006; Thu, 18 Apr 2019 17:42:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 05EE66B0007; Thu, 18 Apr 2019 17:42:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id D5D1F6B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 17:42:42 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id e31so3278839qtb.0
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 14:42:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=605MB47TGZE7++nkg35APlvJ7LvXGdU0fZst7n36xg0=;
        b=fcc3ICa5NP1MmxRnxDB5LY73WFAIoIVfnlrcxza215tG++fYv6CDV1kDIJ3PvFWHke
         aarnqibONvthws8EcER14M9X3ZF4p6+45Beg3vVf4D9rn1ak9oxaLv6M/xcOpcsbCTK2
         soJ4IiPB0eCHHjc0Lq1QgW3J3IH0XvaQzRl0xQqmZiA9EccVRrf8eaU/SnMXE9R+y5f+
         l3P3BzHDretUyDWZHRIBgGGmpG8O99nC8lgwBQOdt7OfXDW4BLaXo5GmOi9XQblO0bTY
         esfXPnGWxanM+Lh2lvbVy/lKISpRfNG8U80O5ypUdT7xi+7WIvH3T3lR7IH16fsTTD09
         zUng==
X-Gm-Message-State: APjAAAX20tRBGw5Xn04B67rN0tZD066SJKlAiMxySIBYsLUNhq4rJLxE
	zvaWWEgz6PYruggoSa3u99EeXWrAS9+yD5DqZdKIo3PSwIrC6mUT1G6TT7bcXw8nnL7jgYitPsV
	7VKXGfqcsPz7Udm57KFa0lmuYhyS0CfZhkxr030ovqVdaSxJSlTvySvYv+OW8woZcXw==
X-Received: by 2002:a0c:8b69:: with SMTP id d41mr437913qvc.186.1555623762614;
        Thu, 18 Apr 2019 14:42:42 -0700 (PDT)
X-Received: by 2002:a0c:8b69:: with SMTP id d41mr437852qvc.186.1555623761815;
        Thu, 18 Apr 2019 14:42:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555623761; cv=none;
        d=google.com; s=arc-20160816;
        b=GUe4/Xz7XgYAAceAzGB/g1lwy2knO56gzo2U/tlU7prCKBabhf68T4U7GRMkESyE4P
         y6luO8CGjOwhXoMjjFQmsyznjlvH/syuNKLRY2Cb0dwbfR7vf71IzXL704VTcSR4iXWP
         B3iFP5nPwsSUEdemHIifzjaHBrirOFb6J4lfdVQo5qeQpRx71giRlHelV/4J36Q5iZtg
         xg1bFOh5wF0k+buyD7m9+nJ+MbxlZNowpv8DYj0rpA0T1eeP6eDFwkynZO/Y3FevIpOI
         wpodKlarLXxWem6oVJhbUG4UDN6i7g7WyiDADmT6tv9XOB6w3YTnIsFSNvBDTEtRPjxr
         tFcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=605MB47TGZE7++nkg35APlvJ7LvXGdU0fZst7n36xg0=;
        b=xxgbTrtceLjHtlmp0IS+hwWj4YjTX9KpnsedbV2XqlokxXj8uYHs+4UeOZruLF/8ze
         s+rZWTuVg740cKua2kw9QecwuCf0n24Zyb8k+F+xDJW5YF+ZtCv5IeJ7QFTg89Mhgr7A
         u1HD+gdnotSIYCvxLDkCFQIH8LLeJJ0geuN2SUsB/BB2a1CBYqPfzk/9l5EEmPVur7kY
         vFTZujL/EYMawNixEMwzvsDEIF4heVoL2timNOIuHoAFHvrNEnpotMU/dElJgfOMfeqg
         FEBbNhrGIeyaHuN0Y2yOtz0X/ibd4TPfiQsD52nZoVn3kRQcfCeDau4VP+waZ5rWr20B
         PQCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oaWnOGJj;
       spf=pass (google.com: domain of 3ue-4xagkcp4yngqkkrhmuumrk.iusrot03-ssq1giq.uxm@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Ue-4XAgKCP4yngqkkrhmuumrk.iusrot03-ssq1giq.uxm@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id l17sor1801138qkk.10.2019.04.18.14.42.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Apr 2019 14:42:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3ue-4xagkcp4yngqkkrhmuumrk.iusrot03-ssq1giq.uxm@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oaWnOGJj;
       spf=pass (google.com: domain of 3ue-4xagkcp4yngqkkrhmuumrk.iusrot03-ssq1giq.uxm@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Ue-4XAgKCP4yngqkkrhmuumrk.iusrot03-ssq1giq.uxm@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=605MB47TGZE7++nkg35APlvJ7LvXGdU0fZst7n36xg0=;
        b=oaWnOGJjefDF9ALhsI0TQQYT+yASuFR/0cQfdkTMFbKQL5kxt0lWvB0UfR/e/diMWA
         L5aPgj1ojrRz7lNhejHhqNQsMGPu/6Nzv3/CY8Qx7pKQUaD3AWxi3LJasbtot5BmbPyf
         daKcD6r5a3Sisc7gFSEVTCzEpZ7IY8yDAGe9uWnkIw6nBUdXrfbFSC7p+0YhkpPTQR0F
         kJmDsmSOyvV4y8m65E31wdOVUl2B7auUkm5c9a5Uif1GgOSo9YJSEgTZtwEjZfbBTqAo
         q3hfAfXohgmVx1vGKRM6jzTXjRjAGaBsl07x0Gnx7qDTyX6wRXxGFxin8gxl1bSzIwkl
         aY7A==
X-Google-Smtp-Source: APXvYqwoo51/pygjywuTIOUu6emXG8qvgN27gaAs1GFwF5lpCnhgwa8++3Zml2MqfC8VgSCoWvlvInqJyrPa3g==
X-Received: by 2002:a37:5a46:: with SMTP id o67mr290481qkb.31.1555623761557;
 Thu, 18 Apr 2019 14:42:41 -0700 (PDT)
Date: Thu, 18 Apr 2019 14:42:24 -0700
Message-Id: <20190418214224.61900-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.392.gf8f6787159e-goog
Subject: [PATCH] memcg: refill_stock for kmem uncharging too
From: Shakeel Butt <shakeelb@google.com>
To: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, 
	Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The commit 475d0487a2ad ("mm: memcontrol: use per-cpu stocks for socket
memory uncharging") added refill_stock() for skmem uncharging path to
optimize workloads having high network traffic. Do the same for the kmem
uncharging as well. However bypass the refill for offlined memcgs to not
cause zombie apocalypse.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 mm/memcontrol.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2535e54e7989..7b8de091f572 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -178,6 +178,7 @@ struct mem_cgroup_event {
 
 static void mem_cgroup_threshold(struct mem_cgroup *memcg);
 static void mem_cgroup_oom_notify(struct mem_cgroup *memcg);
+static void cancel_charge(struct mem_cgroup *memcg, unsigned int nr_pages);
 
 /* Stuffs for move charges at task migration. */
 /*
@@ -2097,10 +2098,7 @@ static void drain_stock(struct memcg_stock_pcp *stock)
 	struct mem_cgroup *old = stock->cached;
 
 	if (stock->nr_pages) {
-		page_counter_uncharge(&old->memory, stock->nr_pages);
-		if (do_memsw_account())
-			page_counter_uncharge(&old->memsw, stock->nr_pages);
-		css_put_many(&old->css, stock->nr_pages);
+		cancel_charge(old, stock->nr_pages);
 		stock->nr_pages = 0;
 	}
 	stock->cached = NULL;
@@ -2133,6 +2131,11 @@ static void refill_stock(struct mem_cgroup *memcg, unsigned int nr_pages)
 	struct memcg_stock_pcp *stock;
 	unsigned long flags;
 
+	if (unlikely(!mem_cgroup_online(memcg))) {
+		cancel_charge(memcg, nr_pages);
+		return;
+	}
+
 	local_irq_save(flags);
 
 	stock = this_cpu_ptr(&memcg_stock);
@@ -2768,17 +2771,13 @@ void __memcg_kmem_uncharge(struct page *page, int order)
 	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
 		page_counter_uncharge(&memcg->kmem, nr_pages);
 
-	page_counter_uncharge(&memcg->memory, nr_pages);
-	if (do_memsw_account())
-		page_counter_uncharge(&memcg->memsw, nr_pages);
-
 	page->mem_cgroup = NULL;
 
 	/* slab pages do not have PageKmemcg flag set */
 	if (PageKmemcg(page))
 		__ClearPageKmemcg(page);
 
-	css_put_many(&memcg->css, nr_pages);
+	refill_stock(memcg, nr_pages);
 }
 #endif /* CONFIG_MEMCG_KMEM */
 
-- 
2.21.0.392.gf8f6787159e-goog

