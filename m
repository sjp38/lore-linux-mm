Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B74EC3A5A3
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 20:32:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0FEAA2070B
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 20:31:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="clb8vgnf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FEAA2070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 805F36B0008; Thu, 29 Aug 2019 16:31:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B67B6B000C; Thu, 29 Aug 2019 16:31:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6CD176B000D; Thu, 29 Aug 2019 16:31:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0024.hostedemail.com [216.40.44.24])
	by kanga.kvack.org (Postfix) with ESMTP id 4CAC26B0008
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 16:31:59 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id D5D01181AC9AE
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 20:31:58 +0000 (UTC)
X-FDA: 75876611916.13.trees26_688c769824462
X-HE-Tag: trees26_688c769824462
X-Filterd-Recvd-Size: 4823
Received: from mail-pl1-f202.google.com (mail-pl1-f202.google.com [209.85.214.202])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 20:31:58 +0000 (UTC)
Received: by mail-pl1-f202.google.com with SMTP id x5so2661773pln.5
        for <linux-mm@kvack.org>; Thu, 29 Aug 2019 13:31:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=geHtoFXurL0uoZHjOhgaOZVjBMzfZ9r5aS+mHaqaGKA=;
        b=clb8vgnfdAWejSqdYesxGEEQnx4giF3KnWD9AiidlIHSstMsGWsGy5pi0M0JJt14PR
         oYpbacQ7W+rsBrVExXVXJ4anZmp0jL84zhjJvFId3vj95RMAe8GdttHBbsWBaHuHcP42
         Q2LXVjKc27IwhIz/Qnb0Kbv8NlEskVG5j9GhD7dM/r0Gtg5Way7BtwKntEsyPOk5O8/Z
         cTWU+RZgNMJMHywTXWh3H8drfMAfUmysLJzfn4+Lj7kai3KiAhc7L5GtkVP61Eu1UKaY
         77K380nwQWhYnUgNtnUwbV1BJ4QvxkXmgSz6ZAvI8KB7LaKpCuzuuRb2HQxu1a0b649F
         shcg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:message-id:mime-version:subject:from:to:cc;
        bh=geHtoFXurL0uoZHjOhgaOZVjBMzfZ9r5aS+mHaqaGKA=;
        b=PZ8iV4NJfMYRJOsLqCyGK/TP+oUdqs4jTreavhFro4aBdfMm179rUHhgfddohpZB+g
         cL5lEpt9DIqt+5QcVa4jqVfvEstIa3yc+gauOif1mH2S3baO7xoCPGy/XDsyUNy2VWEM
         SAPzFT9+4H9xyiqL+34vsRVh7eysSopZ2G4D+qdDapOqXds2ema+rxxbjkrhj8VGQvdm
         aV/TWbRBqZbH/G96UoBNwLUdX6Pr6jxa+v9krry2BxAdur5dM9WZwZEtUyOoIeBsbek5
         lpDF+gl/lvarvr3phR14yiRRIRB0ZsrCOZ8vmH4L6sgqHCJGwq8Gydxk9uS1PAjmWLPm
         3//A==
X-Gm-Message-State: APjAAAX1MMm1JK3+tmawcbjJzVw7RXfOIOKdO8FbVs6sQ7dH2+Gi/itM
	WWfrM+WgJiL4dxJdAgcSQ2kyZRGNIDTibg==
X-Google-Smtp-Source: APXvYqw6jTDiw5RFZN+vIR41RyOP9xsg4tXKrl+EiImbjrdsMxY4mqDerTnQl3fwg7DsBEt0qE524hAjLzYavg==
X-Received: by 2002:a63:30c6:: with SMTP id w189mr9624802pgw.398.1567110716648;
 Thu, 29 Aug 2019 13:31:56 -0700 (PDT)
Date: Thu, 29 Aug 2019 13:31:10 -0700
Message-Id: <20190829203110.129263-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.23.0.187.g17f5b7556c-goog
Subject: [PATCH] mm: memcontrol: fix percpu vmstats and vmevents flush
From: Shakeel Butt <shakeelb@google.com>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, 
	Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@suse.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Instead of using raw_cpu_read() use per_cpu() to read the actual data of
the corresponding cpu otherwise we will be reading the data of the
current cpu for the number of online CPUs.

Fixes: bb65f89b7d3d ("mm: memcontrol: flush percpu vmevents before releasing memcg")
Fixes: c350a99ea2b1 ("mm: memcontrol: flush percpu vmstats before releasing memcg")
Signed-off-by: Shakeel Butt <shakeelb@google.com>
Cc: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: <stable@vger.kernel.org>
---

Note: The buggy patches were marked for stable therefore adding Cc to
stable.

 mm/memcontrol.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 26e2999af608..f4e60ee8b845 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3271,7 +3271,7 @@ static void memcg_flush_percpu_vmstats(struct mem_cgroup *memcg)
 
 	for_each_online_cpu(cpu)
 		for (i = 0; i < MEMCG_NR_STAT; i++)
-			stat[i] += raw_cpu_read(memcg->vmstats_percpu->stat[i]);
+			stat[i] += per_cpu(memcg->vmstats_percpu->stat[i], cpu);
 
 	for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
 		for (i = 0; i < MEMCG_NR_STAT; i++)
@@ -3286,8 +3286,8 @@ static void memcg_flush_percpu_vmstats(struct mem_cgroup *memcg)
 
 		for_each_online_cpu(cpu)
 			for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
-				stat[i] += raw_cpu_read(
-					pn->lruvec_stat_cpu->count[i]);
+				stat[i] += per_cpu(
+					pn->lruvec_stat_cpu->count[i], cpu);
 
 		for (pi = pn; pi; pi = parent_nodeinfo(pi, node))
 			for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
@@ -3306,8 +3306,8 @@ static void memcg_flush_percpu_vmevents(struct mem_cgroup *memcg)
 
 	for_each_online_cpu(cpu)
 		for (i = 0; i < NR_VM_EVENT_ITEMS; i++)
-			events[i] += raw_cpu_read(
-				memcg->vmstats_percpu->events[i]);
+			events[i] += per_cpu(memcg->vmstats_percpu->events[i],
+					     cpu);
 
 	for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
 		for (i = 0; i < NR_VM_EVENT_ITEMS; i++)
-- 
2.23.0.187.g17f5b7556c-goog


