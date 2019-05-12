Return-Path: <SRS0=ZOUz=TM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6FE4C04A6B
	for <linux-mm@archiver.kernel.org>; Sun, 12 May 2019 08:25:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3316C2133D
	for <linux-mm@archiver.kernel.org>; Sun, 12 May 2019 08:25:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cUf9YHKk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3316C2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F90D6B0003; Sun, 12 May 2019 04:25:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7AA326B0005; Sun, 12 May 2019 04:25:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 697BE6B0006; Sun, 12 May 2019 04:25:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2F14F6B0003
	for <linux-mm@kvack.org>; Sun, 12 May 2019 04:25:54 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id b24so7058228pgh.11
        for <linux-mm@kvack.org>; Sun, 12 May 2019 01:25:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=OpBSvAH9Al+PDU6JkDEZvcUWKlMFecMiqNmNuiPXeio=;
        b=fSR4IqTrr4EpkZPCCrpc0vP1xv953ygn0civ8+R5dMvdG+CVsfpCxWlRcUmAPQVjVy
         kMaN1eYLolrU125WbuLRNaLy+EDT70Vlh/ScV2dpul5sGxD3Bgf/e6vJXCVupLHXEwEB
         v/oNuOnhoByTzocmFBrcaLJ3AyhNO49jyCPuxw9Jrr6+KW123QWEmnecMsyMr+AUg5uC
         Ka6mKRU7scn203tvHlZEZBfGoi5ApTh4MdQ5hQeGtqVqAhEibCYCsn7ocDDUXfOy6wlq
         iu4AjFAe7L7iFTmPRCDfzAzMIXDRTyA+G8vseyI3e9zdI40H4Lwb02sUG3+RpLT8RnvH
         sEzQ==
X-Gm-Message-State: APjAAAV5sPTLu59eMEk+TLb2JCji2yaRPpYLNOaTrzjPeEu5aZtFSPrv
	YASy79TTWTZV8z8QPJyChvhjT6b5GaDQ/qQsfIw4wf56YD7ObIOOWZt0XhkUBsq3usr8rap1s+I
	ZsnSFyYdfTntUgwnTFFs1Cnq0u7O3x8ibeUaZr8ghstsGdI0N8FMYqyeRKhKBsGbSUw==
X-Received: by 2002:a65:5941:: with SMTP id g1mr24881189pgu.51.1557649553629;
        Sun, 12 May 2019 01:25:53 -0700 (PDT)
X-Received: by 2002:a65:5941:: with SMTP id g1mr24881130pgu.51.1557649552125;
        Sun, 12 May 2019 01:25:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557649552; cv=none;
        d=google.com; s=arc-20160816;
        b=fLHk7KXdx4rB8BBkqMSJMu7qgmqTnVCQxQHILyXhBJbdYq4kHXjOdbwL42yQhK+Yv6
         EnBDMJl/xWfk+mQ4/m8F5imsE1NJfv7eXvkmlc660b4pTtFm3A6BtOscpWkoX1yoPe+x
         3IoNrmTHCyCNnAVEnc6/yBhdqJ2DerqjLQKQKbLaFO3yaaU90wnNXGt97u04nwBNWTyc
         eQaKbY32Ywb5flYkK2juT7bf7L6RFCZL86TXUG3RfG6HlqksBEDehEwSdFJPUZImjEJX
         P4mHjCqayPE/yd/7RZ6FkhPSS/dA0PedddZY+m+7uGedCP8vptVDcKm5F9MkeTvKQlNn
         XqoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=OpBSvAH9Al+PDU6JkDEZvcUWKlMFecMiqNmNuiPXeio=;
        b=GU40OOVtAYB5QEIDMVZYdMSGgRTnkERWaFtB9Nua7umqKx481SLWg2iBt4LGGBBdhB
         GoeyT/zNUcsFR+0w9w4+glTeOhmFKrCXwPsv2+7w/AKS3NVILhoQ08P0xn/7h8eoXtsn
         VaNI6IgJw58sW5U24Sk6ihKfp4MJs1ACUV7/ucRiPP3JyskxxKIrgHhqDtjWTce1GyGX
         N6yct2cOtR9xFb8ZM+tf6NmchnWlfs+a4LqAX5da2IR5visorliH+6YDiPwofqByWAAD
         YdRw110u/d1nKozK7O3zfcO2M6zN0kuUMeyyBZLL1aukDeIhXOzflARG2bEnMlYqn6F8
         gY/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cUf9YHKk;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k24sor9513002pgf.37.2019.05.12.01.25.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 12 May 2019 01:25:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cUf9YHKk;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=OpBSvAH9Al+PDU6JkDEZvcUWKlMFecMiqNmNuiPXeio=;
        b=cUf9YHKkFis6p2rlWLUXSPRFrgoIM18v/DgqqOt1PrVkfWqu8dopyrT9nax4rbJO+G
         HTUcJiYqUcSsjSlnpd7qdZDJEYNqt1dpC3yk92MLr7Iffpaory5E180EDq7++Th65SWZ
         Wbts2LJXVSI2A519Q42lO2H8v1hfGj34w83bc7qcSmfDdq7J+DRpi6thr+khvIgs2Mgw
         uYI+S9uuFzduKzA2hNyBECm4HZnyY53ruhonwMUI+hr0/AIhbAOG1D6L5I7/m5JTFTqt
         gMVUucFq6Iq1qNlnBdxRXlajGBBjgyBiC8nx8wyvafK4Ki0cIXGnPzQhOSeYey41IMn4
         msvQ==
X-Google-Smtp-Source: APXvYqwiiwejvkODzvU1OmaxsmHv/9jgXNwdM5pzND/3//vA9HUbahL+9N9J77KeoynwoUuXByvSPA==
X-Received: by 2002:a63:7c55:: with SMTP id l21mr609050pgn.121.1557649551796;
        Sun, 12 May 2019 01:25:51 -0700 (PDT)
Received: from bogon.bogon ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id y14sm11815059pga.54.2019.05.12.01.25.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 May 2019 01:25:45 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: 9erthalion6@gmail.com,
	akpm@linux-foundation.org,
	mhocko@suse.com
Cc: shaoyafang@didiglobal.com,
	linux-mm@kvack.org,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH v2] mm/vmscan: expose cgroup_ino for memcg reclaim tracepoints
Date: Sun, 12 May 2019 16:25:28 +0800
Message-Id: <1557649528-11676-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We can use the exposed cgroup_ino to trace specified cgroup.

For example,
step 1, get the inode of the specified cgroup
	$ ls -di /tmp/cgroupv2/foo
step 2, set this inode into tracepoint filter to trace this cgroup only
	(assume the inode is 11)
	$ cd /sys/kernel/debug/tracing/events/vmscan/
	$ echo 'cgroup_ino == 11' > mm_vmscan_memcg_reclaim_begin/filter
	$ echo 'cgroup_ino == 11' > mm_vmscan_memcg_reclaim_end/filter

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>

---
v2: rebase it against the latest -mmotm
---
 include/trace/events/vmscan.h | 71 +++++++++++++++++++++++++++++++++++--------
 mm/vmscan.c                   | 18 ++++++++---
 2 files changed, 72 insertions(+), 17 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index a5ab297..c37e228 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -127,18 +127,43 @@
 );
 
 #ifdef CONFIG_MEMCG
-DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_memcg_reclaim_begin,
+DECLARE_EVENT_CLASS(mm_vmscan_memcg_reclaim_begin_template,
 
-	TP_PROTO(int order, gfp_t gfp_flags),
+	TP_PROTO(unsigned int cgroup_ino, int order, gfp_t gfp_flags),
 
-	TP_ARGS(order, gfp_flags)
+	TP_ARGS(cgroup_ino, order, gfp_flags),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, cgroup_ino)
+		__field(int, order)
+		__field(gfp_t, gfp_flags)
+	),
+
+	TP_fast_assign(
+		__entry->cgroup_ino	= cgroup_ino;
+		__entry->order		= order;
+		__entry->gfp_flags	= gfp_flags;
+	),
+
+	TP_printk("cgroup_ino=%u order=%d gfp_flags=%s",
+		__entry->cgroup_ino, __entry->order,
+		show_gfp_flags(__entry->gfp_flags))
 );
 
-DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_memcg_softlimit_reclaim_begin,
+DEFINE_EVENT(mm_vmscan_memcg_reclaim_begin_template,
+	     mm_vmscan_memcg_reclaim_begin,
 
-	TP_PROTO(int order, gfp_t gfp_flags),
+	TP_PROTO(unsigned int cgroup_ino, int order, gfp_t gfp_flags),
 
-	TP_ARGS(order, gfp_flags)
+	TP_ARGS(cgroup_ino, order, gfp_flags)
+);
+
+DEFINE_EVENT(mm_vmscan_memcg_reclaim_begin_template,
+	     mm_vmscan_memcg_softlimit_reclaim_begin,
+
+	TP_PROTO(unsigned int cgroup_ino, int order, gfp_t gfp_flags),
+
+	TP_ARGS(cgroup_ino, order, gfp_flags)
 );
 #endif /* CONFIG_MEMCG */
 
@@ -167,18 +192,40 @@
 );
 
 #ifdef CONFIG_MEMCG
-DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_memcg_reclaim_end,
+DECLARE_EVENT_CLASS(mm_vmscan_memcg_reclaim_end_template,
 
-	TP_PROTO(unsigned long nr_reclaimed),
+	TP_PROTO(unsigned int cgroup_ino, unsigned long nr_reclaimed),
 
-	TP_ARGS(nr_reclaimed)
+	TP_ARGS(cgroup_ino, nr_reclaimed),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, cgroup_ino)
+		__field(unsigned long, nr_reclaimed)
+	),
+
+	TP_fast_assign(
+		__entry->cgroup_ino	= cgroup_ino;
+		__entry->nr_reclaimed	= nr_reclaimed;
+	),
+
+	TP_printk("cgroup_ino=%u nr_reclaimed=%lu",
+		__entry->cgroup_ino, __entry->nr_reclaimed)
 );
 
-DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_memcg_softlimit_reclaim_end,
+DEFINE_EVENT(mm_vmscan_memcg_reclaim_end_template,
+	     mm_vmscan_memcg_reclaim_end,
 
-	TP_PROTO(unsigned long nr_reclaimed),
+	TP_PROTO(unsigned int cgroup_ino, unsigned long nr_reclaimed),
 
-	TP_ARGS(nr_reclaimed)
+	TP_ARGS(cgroup_ino, nr_reclaimed)
+);
+
+DEFINE_EVENT(mm_vmscan_memcg_reclaim_end_template,
+	     mm_vmscan_memcg_softlimit_reclaim_end,
+
+	TP_PROTO(unsigned int cgroup_ino, unsigned long nr_reclaimed),
+
+	TP_ARGS(cgroup_ino, nr_reclaimed)
 );
 #endif /* CONFIG_MEMCG */
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d9c3e87..91c50dc 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3244,8 +3244,10 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
 
-	trace_mm_vmscan_memcg_softlimit_reclaim_begin(sc.order,
-						      sc.gfp_mask);
+	trace_mm_vmscan_memcg_softlimit_reclaim_begin(
+					cgroup_ino(memcg->css.cgroup),
+					sc.order,
+					sc.gfp_mask);
 
 	/*
 	 * NOTE: Although we can get the priority field, using it
@@ -3256,7 +3258,9 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
 	 */
 	shrink_node_memcg(pgdat, memcg, &sc);
 
-	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
+	trace_mm_vmscan_memcg_softlimit_reclaim_end(
+					cgroup_ino(memcg->css.cgroup),
+					sc.nr_reclaimed);
 
 	*nr_scanned = sc.nr_scanned;
 	return sc.nr_reclaimed;
@@ -3294,7 +3298,9 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 
 	zonelist = &NODE_DATA(nid)->node_zonelists[ZONELIST_FALLBACK];
 
-	trace_mm_vmscan_memcg_reclaim_begin(0, sc.gfp_mask);
+	trace_mm_vmscan_memcg_reclaim_begin(
+				cgroup_ino(memcg->css.cgroup),
+				0, sc.gfp_mask);
 
 	psi_memstall_enter(&pflags);
 	noreclaim_flag = memalloc_noreclaim_save();
@@ -3304,7 +3310,9 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 	memalloc_noreclaim_restore(noreclaim_flag);
 	psi_memstall_leave(&pflags);
 
-	trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
+	trace_mm_vmscan_memcg_reclaim_end(
+				cgroup_ino(memcg->css.cgroup),
+				nr_reclaimed);
 
 	return nr_reclaimed;
 }
-- 
1.8.3.1

