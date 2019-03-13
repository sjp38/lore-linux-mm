Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29489C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:40:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2EA2213A2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:40:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hpA4uXez"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2EA2213A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 867EA8E0006; Wed, 13 Mar 2019 14:40:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 81A998E0001; Wed, 13 Mar 2019 14:40:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 644628E0006; Wed, 13 Mar 2019 14:40:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2489C8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 14:40:06 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id c15so3101200pfn.11
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 11:40:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oz/TqQdvSWg5Jr50nmxxA8VLsKG86DG+TYlsVRNN9G4=;
        b=Hc3jRM7WJVD8Wd3QjV/oCr7dwMAdRNsFH8o9q4FsOVlwL+gOs4wmgokeHfHpNkMZVi
         0ayrwlgI7pzdRAu+BuPhdVavwNqOC8NnyobgiAT8298Kbh01ICHKHGvGGho9oYw/PLHM
         F7o0Uuu5nao6qQWScML2gqtxLqJGWsQr6Iv4LsMUqWsmK2b2z02NwBktMgcj2k21Q+YH
         kAl3KifeGQ/s8K0WWGehoRytlHjoZQwpH4Q47z+g/EIW2F2tyQh8U0OZPdJLOvypqFyP
         YMvblU8zjZaTn1BFcHzOTXfJltEOSVAe+V20IiAIXiogGJLYz9F60jovstBfzP2I3KO0
         spOg==
X-Gm-Message-State: APjAAAXMddKjMHm5UIAlnXTcDOubZHC0rViFezpHl+sNWVckJdsRwiH2
	QNNyFuDd8lYemnq52jLETi5zbEpa3hq6/gveevIv2h0pWgia5+nYY91uM1OOp0CEYSf9w3ubQII
	qCpqzdiHN2w6zUFbAeGQAuNph1AhxuOvyTuA5H1y2KYPUSDZl7QmxvSmeuiLFieHQoryfbsqEzc
	YTsyU/IUZPbfBGyMxevRyEqZ3ESjtP4Y4IAc1QUDjh+BRXWUWSisadvGNVZsksOKfQEW10Xfnqk
	mfeiGn82eVWb6AcZ/LX+Uu7GxqudkMKBnSWisEn70f5u3mbymx4cFv5j8RNFKruqgmsWqnsBSJN
	OhqBg448q7umR8pJu8e3653uoP2vRddQwBZJ6QGMv/n3OUSygf6j5ijBfAVyCQWFe/OsA95gkK3
	f
X-Received: by 2002:a62:ee13:: with SMTP id e19mr45315253pfi.224.1552502405815;
        Wed, 13 Mar 2019 11:40:05 -0700 (PDT)
X-Received: by 2002:a62:ee13:: with SMTP id e19mr45315137pfi.224.1552502404146;
        Wed, 13 Mar 2019 11:40:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552502404; cv=none;
        d=google.com; s=arc-20160816;
        b=CE6+oR28SDThB28SkdC4rdmK0xyCRqvg+/zAg4tNNBXC07e/igv7ZFmpMr0IX+pLPU
         0lQ6YGcK3wjLovWGDAxVCYh0Utuy1TjAAexV/nt7vn4M+OEJmZ8nQEVJ3oWwnrqh935o
         jO62PeO5NzJsu2BIsOxIJXZqb3WR+B0IfJDeZyMH7IGEefkknQw+RpdqA8tg0xBWbzy3
         GlERp1jpvx9/4Bn6de8/QHY8t6Tpjk18rg1de/+9NfMZ9lUFGj9KYkLgja+65VTKtjhP
         5qFT+eoA8NXtC99lriDBM3viIh3LIz4F1/3B2XnMJadMuevZhHpnEWiK2DQfjd3TO4dA
         7u0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=oz/TqQdvSWg5Jr50nmxxA8VLsKG86DG+TYlsVRNN9G4=;
        b=iMOPM5fS+qPLynA/QK+EPLVMSCeEZJnmGINcmxQINZvPB804ne07oHTZ/FUJ7pMi30
         bBf/oh9dbmC7MW4iBnD8DFzsSkfY6qBx3a4bgfY1aOMBqfcHj3/aZqzlzChu52/TbESK
         smF+pFV1fgjonw/JSTbtWTfAgmFsSrndUJ0Xt9ZyBOxvm8got3UrGVVuzGlsPsaVrG5+
         Klsd73NnZho3+GjydBnS/mnLwuFFaBtidmcYFD14V7hlumYnmsW9YlmLgHWeDEGP5Haz
         TqqbbZI6mUpEdz+NyiCKme4ZCaperYiNtuLZ/zuPRbpR3xj+xKAcMFseKy4d/kH4uXW5
         wrqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hpA4uXez;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id gb2sor2442695plb.38.2019.03.13.11.40.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 11:40:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hpA4uXez;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=oz/TqQdvSWg5Jr50nmxxA8VLsKG86DG+TYlsVRNN9G4=;
        b=hpA4uXezJFytHX61offN86IKtbXpFLvm0HHYlX8PLBCp9odTDBdRU8iJWN3FkjG122
         b3I5QU+GFy+ySN9iL/v1WbxdD4J5pM6RZhnbR/5Xy6yEWtUUb4SgbDfEL8AWQzU3ksc9
         dxD0BT3xL9WkpAUrESpPq67O28TWu0JXAd6O2VkjjX5d4B+JUKYID4HLiDzUt007FtaP
         kcj3J+jPbkdIisv9YZiwBzrDl94TKH+SuAm4SQFwBLlZI5bgnTYIN6xU+op53OMku+3l
         ngLhXVK4SKh5wj9C6wp1kVoBQJwpZhaOJdgBC4HoUu/DX+kYq2axNWUAX6d2QOVCnjri
         9lCw==
X-Google-Smtp-Source: APXvYqx4HX+wI/C6J5UVMWvM/fRe8b3x/cIh7frkr+wyT2vN7/DzQXFBG11e1pn8YPu0Tg1SxzbrDw==
X-Received: by 2002:a17:902:8c8a:: with SMTP id t10mr10452660plo.160.1552502403281;
        Wed, 13 Mar 2019 11:40:03 -0700 (PDT)
Received: from castle.hsd1.ca.comcast.net ([2603:3024:1704:3e00::d657])
        by smtp.gmail.com with ESMTPSA id i13sm15792562pgq.17.2019.03.13.11.40.01
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Mar 2019 11:40:02 -0700 (PDT)
From: Roman Gushchin <guroan@gmail.com>
X-Google-Original-From: Roman Gushchin <guro@fb.com>
To: linux-mm@kvack.org,
	kernel-team@fb.com
Cc: linux-kernel@vger.kernel.org,
	Tejun Heo <tj@kernel.org>,
	Rik van Riel <riel@surriel.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Roman Gushchin <guro@fb.com>
Subject: [PATCH v3 2/6] mm: prepare to premature release of per-node lruvec_stat_cpu
Date: Wed, 13 Mar 2019 11:39:49 -0700
Message-Id: <20190313183953.17854-3-guro@fb.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190313183953.17854-1-guro@fb.com>
References: <20190313183953.17854-1-guro@fb.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Similar to the memcg's vmstats_percpu, per-memcg per-node stats
consists of percpu- and atomic counterparts, and we do expect
that both coexist during the whole life-cycle of the memcg.

To prepare for a premature release of percpu per-node data,
let's pretend that lruvec_stat_cpu is a rcu-protected pointer,
which can be NULL. This patch adds corresponding checks whenever
required.

Signed-off-by: Roman Gushchin <guro@fb.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 21 +++++++++++++++------
 mm/memcontrol.c            | 14 +++++++++++---
 2 files changed, 26 insertions(+), 9 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 05ca77767c6a..8ac04632002a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -126,7 +126,7 @@ struct memcg_shrinker_map {
 struct mem_cgroup_per_node {
 	struct lruvec		lruvec;
 
-	struct lruvec_stat __percpu *lruvec_stat_cpu;
+	struct lruvec_stat __rcu /* __percpu */ *lruvec_stat_cpu;
 	atomic_long_t		lruvec_stat[NR_VM_NODE_STAT_ITEMS];
 
 	unsigned long		lru_zone_size[MAX_NR_ZONES][NR_LRU_LISTS];
@@ -682,6 +682,7 @@ static inline unsigned long lruvec_page_state(struct lruvec *lruvec,
 static inline void __mod_lruvec_state(struct lruvec *lruvec,
 				      enum node_stat_item idx, int val)
 {
+	struct lruvec_stat __percpu *lruvec_stat_cpu;
 	struct mem_cgroup_per_node *pn;
 	long x;
 
@@ -697,12 +698,20 @@ static inline void __mod_lruvec_state(struct lruvec *lruvec,
 	__mod_memcg_state(pn->memcg, idx, val);
 
 	/* Update lruvec */
-	x = val + __this_cpu_read(pn->lruvec_stat_cpu->count[idx]);
-	if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
-		atomic_long_add(x, &pn->lruvec_stat[idx]);
-		x = 0;
+	rcu_read_lock();
+	lruvec_stat_cpu = (struct lruvec_stat __percpu *)
+		rcu_dereference(pn->lruvec_stat_cpu);
+	if (likely(lruvec_stat_cpu)) {
+		x = val + __this_cpu_read(lruvec_stat_cpu->count[idx]);
+		if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
+			atomic_long_add(x, &pn->lruvec_stat[idx]);
+			x = 0;
+		}
+		__this_cpu_write(lruvec_stat_cpu->count[idx], x);
+	} else {
+		atomic_long_add(val, &pn->lruvec_stat[idx]);
 	}
-	__this_cpu_write(pn->lruvec_stat_cpu->count[idx], x);
+	rcu_read_unlock();
 }
 
 static inline void mod_lruvec_state(struct lruvec *lruvec,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 803c772f354b..5ef4098f3f8d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2122,6 +2122,7 @@ static void drain_all_stock(struct mem_cgroup *root_memcg)
 static int memcg_hotplug_cpu_dead(unsigned int cpu)
 {
 	struct memcg_vmstats_percpu __percpu *vmstats_percpu;
+	struct lruvec_stat __percpu *lruvec_stat_cpu;
 	struct memcg_stock_pcp *stock;
 	struct mem_cgroup *memcg;
 
@@ -2152,7 +2153,12 @@ static int memcg_hotplug_cpu_dead(unsigned int cpu)
 				struct mem_cgroup_per_node *pn;
 
 				pn = mem_cgroup_nodeinfo(memcg, nid);
-				x = this_cpu_xchg(pn->lruvec_stat_cpu->count[i], 0);
+
+				lruvec_stat_cpu = (struct lruvec_stat __percpu*)
+					rcu_dereference(pn->lruvec_stat_cpu);
+				if (!lruvec_stat_cpu)
+					continue;
+				x = this_cpu_xchg(lruvec_stat_cpu->count[i], 0);
 				if (x)
 					atomic_long_add(x, &pn->lruvec_stat[i]);
 			}
@@ -4414,6 +4420,7 @@ struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
 
 static int alloc_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
 {
+	struct lruvec_stat __percpu *lruvec_stat_cpu;
 	struct mem_cgroup_per_node *pn;
 	int tmp = node;
 	/*
@@ -4430,11 +4437,12 @@ static int alloc_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
 	if (!pn)
 		return 1;
 
-	pn->lruvec_stat_cpu = alloc_percpu(struct lruvec_stat);
-	if (!pn->lruvec_stat_cpu) {
+	lruvec_stat_cpu = alloc_percpu(struct lruvec_stat);
+	if (!lruvec_stat_cpu) {
 		kfree(pn);
 		return 1;
 	}
+	rcu_assign_pointer(pn->lruvec_stat_cpu, lruvec_stat_cpu);
 
 	lruvec_init(&pn->lruvec);
 	pn->usage_in_excess = 0;
-- 
2.20.1

