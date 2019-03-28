Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A099AC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 01:25:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29AE92082F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 01:25:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lsgm72C+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29AE92082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA2DD6B0003; Wed, 27 Mar 2019 21:25:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C2A216B0006; Wed, 27 Mar 2019 21:25:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF19B6B0007; Wed, 27 Mar 2019 21:25:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6E26F6B0003
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 21:25:42 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id b12so13500507pfj.5
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 18:25:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=Ba9MLl0wdwMQV0ZvJwbqfucX+YOQVSVq5fnXfEeXRNw=;
        b=ir2JaLOTRDXFbyK+JhqXgMGClK0jdoQEubHYYVD2ksg6kqWQnEOmyiUTrIAmJQ5Qwt
         +/0XyBgWe8tjIFN/hE/4E+iy9ACktKBeycu6dF2zY/BfneAq3ADYBqRJWlpnIBuFoSun
         U+1KeGNi7szmPrygUoBna7K1vflwtpfXfiL5pTGh++2Ud/IgqtFXhNmuhqSn/ZsmDghF
         FPJVqQihMz7zycOV9eNkg5hn7NtCMo1ILcne6EM2Is3v74d1bjO4Xo48JQ7EJoaXPiQq
         SuYGF3o2Zcgx/8NGIUT8z8XGXnE5NDoehOPI37B24udn8XOouc6FnD9S3s2qsrhJh2qP
         IA8w==
X-Gm-Message-State: APjAAAUr7uYyWGpbEVNz4m3JDjweaFTtPCbWFMd+j5RSFm1tFwOF6QF8
	Q3igISCcIABwAZFFi6vigNuVThaHPO3LYHYQhe3rQXCDAqDycQYrh3vSNwFrcUryDp40NiZ44Ft
	Q+jAUoVSxasllcY9HOpPL/NdWiGwEgb2WvNvVftAwtvhMIBiMM3lJACDoCjGtmDAIiw==
X-Received: by 2002:a62:b61a:: with SMTP id j26mr37893933pff.151.1553736342005;
        Wed, 27 Mar 2019 18:25:42 -0700 (PDT)
X-Received: by 2002:a62:b61a:: with SMTP id j26mr37893857pff.151.1553736340624;
        Wed, 27 Mar 2019 18:25:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553736340; cv=none;
        d=google.com; s=arc-20160816;
        b=iYy+/SfVArcEMLWk/DLI7rp6ghGYODPyuCisyDILYYe0oUa8Pl0yU+SloDcM5lAbAW
         cBgZBCjRMQwyHIqLhaoAskOonff99D4wCmnw8bI60nHpmEibudnravIUIvUuJDgdTUTc
         riS15yEZZj5SI4tNMYBjcBfHUCoTyve2xZ2YM6XMTPlvydXVUtw9FY5pu3W0KEnLKVs1
         mARAKUoR/J9EcFMTeiyhcY3jhGH9ty70TQCmEWhn9pzZX/8/9mhGzVeCwaeBL3C+nu53
         ouFvioFGygIHqd8YrjCGpxPOrK34aZKgHk485OQE/F+aa3EmYKUBLgTaWgbzNNDpOMDe
         qc5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=Ba9MLl0wdwMQV0ZvJwbqfucX+YOQVSVq5fnXfEeXRNw=;
        b=ID9g0KwVLGt7MmMbrTK9OJ0u9cCfvx+PVIAE36yXblsSYAsmia/rueElEryDwefgAz
         jt6YVK3aFg0swWLT2ifa193HN1d3SWPUrcTsVm66uuGzrh7OhTcJQn72n0e1Gksu+84S
         u1l0lJovfzwByz1APl1w3CfLmAatop/Oh7pebKO5litewd7xkNF388wKIwXA4f2fk+u0
         F9lqnpQxLUViO2Go+HUYaTdTyt6vGdmgh4vB89AwngOmnBlm5aS0kQBW4bfs2l86bCqh
         JWfW9Nn9ek+/FJivsIuUQPQPKRA1Jiyku8R/++9EyvAqY33XcwY8j7v6hvJQhtmFZlm6
         1ZrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lsgm72C+;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 34sor29454506plp.24.2019.03.27.18.25.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Mar 2019 18:25:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lsgm72C+;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=Ba9MLl0wdwMQV0ZvJwbqfucX+YOQVSVq5fnXfEeXRNw=;
        b=lsgm72C+zh7zax5G9gjn4zDrjdD/Fzs5KOfJCax53h4/ZftuF/RLocIlWFJhOlJBZd
         8kLAj9IeSYrhWd5GQgCVwlt6E+obf3xnZBxQf7P18pjyajcQylM/XCfhXlPXjTUpWTxg
         wSBMn+ErJADSoUFcX+vOtcSPYaxp+Mi9cPfnpBAanIR54Q49QzOBEAfTvGyf66fFSOCC
         53LS+klgPuiyhj5ZP5OTCwuGGVULil8nNEubUNsUWpGTouCDnKmwy+jlO8WVhMZM0pe3
         zc7GA/C/2rfkfri9FxNzLNcAvaSFWk2BlNh1/oI46ot3EqxqD0jLwV3FsX5Jin71hBSQ
         nh9w==
X-Google-Smtp-Source: APXvYqx3Gnnpo5XB8v/JP5tgkXS8CMcPtvSiLAyq9M2/a4FXNjlnFMfJ2b8JMH2dVqXGlGi3najldA==
X-Received: by 2002:a17:902:28e6:: with SMTP id f93mr40240888plb.264.1553736340281;
        Wed, 27 Mar 2019 18:25:40 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id k124sm25157496pgc.65.2019.03.27.18.25.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 18:25:38 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm/vmscan: drop may_writepage and classzone_idx from direct reclaim begin template
Date: Thu, 28 Mar 2019 09:25:22 +0800
Message-Id: <1553736322-32235-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There are three tracepoints using this template, which are
mm_vmscan_direct_reclaim_begin,
mm_vmscan_memcg_reclaim_begin,
mm_vmscan_memcg_softlimit_reclaim_begin.

Regarding mm_vmscan_direct_reclaim_begin,
sc.may_writepage is !laptop_mode, that's a static setting, and
reclaim_idx is derived from gfp_mask which is already show in this
tracepoint.

Regarding mm_vmscan_memcg_reclaim_begin,
may_writepage is !laptop_mode too, and reclaim_idx is (MAX_NR_ZONES-1),
which are both static value.

mm_vmscan_memcg_softlimit_reclaim_begin is the same with
mm_vmscan_memcg_reclaim_begin.

So we can drop them all.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/trace/events/vmscan.h | 26 ++++++++++----------------
 mm/vmscan.c                   | 14 +++-----------
 2 files changed, 13 insertions(+), 27 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index a1cb913..153d90c 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -105,51 +105,45 @@
 
 DECLARE_EVENT_CLASS(mm_vmscan_direct_reclaim_begin_template,
 
-	TP_PROTO(int order, int may_writepage, gfp_t gfp_flags, int classzone_idx),
+	TP_PROTO(int order, gfp_t gfp_flags),
 
-	TP_ARGS(order, may_writepage, gfp_flags, classzone_idx),
+	TP_ARGS(order, gfp_flags),
 
 	TP_STRUCT__entry(
 		__field(	int,	order		)
-		__field(	int,	may_writepage	)
 		__field(	gfp_t,	gfp_flags	)
-		__field(	int,	classzone_idx	)
 	),
 
 	TP_fast_assign(
 		__entry->order		= order;
-		__entry->may_writepage	= may_writepage;
 		__entry->gfp_flags	= gfp_flags;
-		__entry->classzone_idx	= classzone_idx;
 	),
 
-	TP_printk("order=%d may_writepage=%d gfp_flags=%s classzone_idx=%d",
+	TP_printk("order=%d gfp_flags=%s",
 		__entry->order,
-		__entry->may_writepage,
-		show_gfp_flags(__entry->gfp_flags),
-		__entry->classzone_idx)
+		show_gfp_flags(__entry->gfp_flags))
 );
 
 DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_direct_reclaim_begin,
 
-	TP_PROTO(int order, int may_writepage, gfp_t gfp_flags, int classzone_idx),
+	TP_PROTO(int order, gfp_t gfp_flags),
 
-	TP_ARGS(order, may_writepage, gfp_flags, classzone_idx)
+	TP_ARGS(order, gfp_flags)
 );
 
 #ifdef CONFIG_MEMCG
 DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_memcg_reclaim_begin,
 
-	TP_PROTO(int order, int may_writepage, gfp_t gfp_flags, int classzone_idx),
+	TP_PROTO(int order, gfp_t gfp_flags),
 
-	TP_ARGS(order, may_writepage, gfp_flags, classzone_idx)
+	TP_ARGS(order, gfp_flags)
 );
 
 DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_memcg_softlimit_reclaim_begin,
 
-	TP_PROTO(int order, int may_writepage, gfp_t gfp_flags, int classzone_idx),
+	TP_PROTO(int order, gfp_t gfp_flags),
 
-	TP_ARGS(order, may_writepage, gfp_flags, classzone_idx)
+	TP_ARGS(order, gfp_flags)
 );
 #endif /* CONFIG_MEMCG */
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index ac4806f..cdc0305 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3304,10 +3304,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 	if (throttle_direct_reclaim(sc.gfp_mask, zonelist, nodemask))
 		return 1;
 
-	trace_mm_vmscan_direct_reclaim_begin(order,
-				sc.may_writepage,
-				sc.gfp_mask,
-				sc.reclaim_idx);
+	trace_mm_vmscan_direct_reclaim_begin(order, sc.gfp_mask);
 
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
 
@@ -3338,9 +3335,7 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
 
 	trace_mm_vmscan_memcg_softlimit_reclaim_begin(sc.order,
-						      sc.may_writepage,
-						      sc.gfp_mask,
-						      sc.reclaim_idx);
+						      sc.gfp_mask);
 
 	/*
 	 * NOTE: Although we can get the priority field, using it
@@ -3389,10 +3384,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 
 	zonelist = &NODE_DATA(nid)->node_zonelists[ZONELIST_FALLBACK];
 
-	trace_mm_vmscan_memcg_reclaim_begin(0,
-					    sc.may_writepage,
-					    sc.gfp_mask,
-					    sc.reclaim_idx);
+	trace_mm_vmscan_memcg_reclaim_begin(0, sc.gfp_mask);
 
 	psi_memstall_enter(&pflags);
 	noreclaim_flag = memalloc_noreclaim_save();
-- 
1.8.3.1

