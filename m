Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A1A1C48BE0
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 10:15:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54DEB208CA
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 10:15:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Cz7XVWBq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54DEB208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E84366B0006; Fri, 21 Jun 2019 06:15:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E34FF8E0002; Fri, 21 Jun 2019 06:15:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFDA58E0001; Fri, 21 Jun 2019 06:15:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9BB036B0006
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 06:15:18 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id v6so3825136pgh.6
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 03:15:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=8meTcVfBbALt7e866SvNTHpKuyGyAQEHX/hr6O+UtcE=;
        b=HIipDlRRF4lcoQGQfQNVmD9sjIjX+OTkP4CIEJMPNZU0Zc5Y+nwea5TacdvI9Wl0+s
         jH3HFqWRtC9s2eHpHIi/Lf9/X/s96pgRQl8NsVBSuyQSd5jlfw9RYCtTWlrkPV7d7vfV
         qCgtMCgt+KLJxQ535FxcfKOq87Tef1gMc2+bNHLoaRzB7tucieVqIZx1clbvxecI2/S8
         qCOps6IQC4LIboX73y3dbp2vGQQWVw4jAO9Ts0295GSfpfm5/bYCuIj07Ct1E6vaPfKw
         3eIWC8B+3R9E3iEsb63jgiXdFFjnIpSXG9lyKCfXbl02+57iBizuhAsdZMzR2j0bORHY
         edsA==
X-Gm-Message-State: APjAAAVwo5O5GknE/pHaMWfZCcpiUA94X0qEf8vfXeIHR11gVWkGHofx
	ENpW1m9uIQr2flFRmuXXoHrfwvo/ombZRFeFNKsQfO1/cLnzwl9cCeWsVes1cRb41bOrqY1dAuP
	+8nw5oYm/wN1FTrrpkmDk6DfHKs4ExEVLzq2P7bFAjlsOq/5SDWPU0W0sajY52kXXOg==
X-Received: by 2002:a17:90a:9bc5:: with SMTP id b5mr5636127pjw.109.1561112118303;
        Fri, 21 Jun 2019 03:15:18 -0700 (PDT)
X-Received: by 2002:a17:90a:9bc5:: with SMTP id b5mr5636007pjw.109.1561112117170;
        Fri, 21 Jun 2019 03:15:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561112117; cv=none;
        d=google.com; s=arc-20160816;
        b=x0K2fMzgd9Dq2dzbJVqiAEwgi0IeHjryjVF4WzZkvf/4minC6iw8h9EUXkz6VEbwbf
         PV1QI11Vvasvh579Y9QAhN+cFR/G0f92g6i+abr4yiSC52PJ9iz7cD/ZAbE+QqVzxln0
         ao1k6CYNUibInMPAbLftOnW45PzlpP6POupQgRWzDqyUjVIcc26wQHX4AribOhv70vJ0
         jViTywq0JixMfgkfIg4TJ2ygsDEzL/2dCDZhnhQfBuMMJFrpG7wVEEvWHEMIOBzHMWwD
         Grbx2axjqCdf9K2Uz/1B9/N92dKLGVgJhIZ0OkH5VGL2U269q8v66I78kBy78Om2B/Mm
         FqmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=8meTcVfBbALt7e866SvNTHpKuyGyAQEHX/hr6O+UtcE=;
        b=exLLEcjfLVVcy/DGI7OTXl+6HIxlJlB+PsQQQMR2bz36DZz72zrP0U89otDFsgKUwG
         Z3NSrf0ElPJQtqAUShm71i/w4ks90FPA9U2W3pnylaJiCwirl+H6VRzTy+ezeKpkfaLl
         W78BY/7kGf5drZtvKGhFqN9lACUWKISeFkIGR0vfutHYLEoIEAaU9qdWWzs5+QCphQZ0
         o4dt6XaYyLROjhT9ToZnNalnyyKnrEnJQu0RDKJXVr1utgS5E+30ZNkHdK6Csdbxa7EB
         UUyHWgw7YKVv5hmdZtZSPh0AJpK0xOFRYU2uvVm4WfYf3E9keizZbU9Ya4xnsGzq1aOV
         fbYA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Cz7XVWBq;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q17sor1956073pff.71.2019.06.21.03.15.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 03:15:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Cz7XVWBq;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=8meTcVfBbALt7e866SvNTHpKuyGyAQEHX/hr6O+UtcE=;
        b=Cz7XVWBql8vsXxWBQTTAP7Cr4dKoFcj/J3CupMh/MGRASWoDm7BXUctXSG/Gga4uvZ
         o/UXUjmrBy3b3OWr7ApaCd+1giki8Ukn5XteH7gNbJYfK4Wag8416ozMPVoUAqp5uMC/
         RbpbcUZP48f4rFXvtGrOCXu9jENBS8rku9vzMCkQDS0pNQYDQ4cwx8UKOKRoB7QqMBa7
         YAjXPPas+4IpQEeZaS4vZNYGjRgXQ91C6PfGOVUaGG+wnR8+KZFtlauQuhY/CiuodrG9
         Vf8UegRcdQRW29I8FWtAmqKF7vs5cTWW146LpIa9sh3Gqh2PZaj9VxcCIh9rovRq3Jfl
         oR+g==
X-Google-Smtp-Source: APXvYqxsvLlv0eW/I5AcbKwGVGRGtI4GkWBTPnwZQ/vPUMwtODB0gnfGpUNQ83yfvsIqDcGeOeu04w==
X-Received: by 2002:a63:1243:: with SMTP id 3mr6274547pgs.235.1561112116867;
        Fri, 21 Jun 2019 03:15:16 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id c9sm2578763pfn.3.2019.06.21.03.15.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 03:15:16 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org,
	ktkhai@virtuozzo.com,
	mhocko@suse.com,
	hannes@cmpxchg.org,
	vdavydov.dev@gmail.com,
	mgorman@techsingularity.net
Cc: linux-mm@kvack.org,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH 1/2] mm/vmscan: add a new member reclaim_state in struct shrink_control
Date: Fri, 21 Jun 2019 18:14:45 +0800
Message-Id: <1561112086-6169-2-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1561112086-6169-1-git-send-email-laoar.shao@gmail.com>
References: <1561112086-6169-1-git-send-email-laoar.shao@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The struct reclaim_state is used to record how many slab caches are
reclaimed in one reclaim path.
The struct shrink_control is used to control one reclaim path.
So we'd better put reclaim_state into shrink_control.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 mm/vmscan.c | 20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b79f584..18a66e5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -131,6 +131,9 @@ struct scan_control {
 		unsigned int file_taken;
 		unsigned int taken;
 	} nr;
+
+	/* for recording the reclaimed slab by now */
+	struct reclaim_state reclaim_state;
 };
 
 #ifdef ARCH_HAS_PREFETCH
@@ -3461,6 +3464,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		.may_unmap = 1,
 	};
 
+	current->reclaim_state = &sc.reclaim_state;
 	psi_memstall_enter(&pflags);
 	__fs_reclaim_acquire();
 
@@ -3642,6 +3646,8 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 	snapshot_refaults(NULL, pgdat);
 	__fs_reclaim_release();
 	psi_memstall_leave(&pflags);
+	current->reclaim_state = NULL;
+
 	/*
 	 * Return the order kswapd stopped reclaiming at as
 	 * prepare_kswapd_sleep() takes it into account. If another caller
@@ -3766,15 +3772,10 @@ static int kswapd(void *p)
 	unsigned int classzone_idx = MAX_NR_ZONES - 1;
 	pg_data_t *pgdat = (pg_data_t*)p;
 	struct task_struct *tsk = current;
-
-	struct reclaim_state reclaim_state = {
-		.reclaimed_slab = 0,
-	};
 	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
 
 	if (!cpumask_empty(cpumask))
 		set_cpus_allowed_ptr(tsk, cpumask);
-	current->reclaim_state = &reclaim_state;
 
 	/*
 	 * Tell the memory management that we're a "memory allocator",
@@ -3836,7 +3837,6 @@ static int kswapd(void *p)
 	}
 
 	tsk->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD);
-	current->reclaim_state = NULL;
 
 	return 0;
 }
@@ -3897,7 +3897,6 @@ void wakeup_kswapd(struct zone *zone, gfp_t gfp_flags, int order,
  */
 unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 {
-	struct reclaim_state reclaim_state;
 	struct scan_control sc = {
 		.nr_to_reclaim = nr_to_reclaim,
 		.gfp_mask = GFP_HIGHUSER_MOVABLE,
@@ -3915,8 +3914,7 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 
 	fs_reclaim_acquire(sc.gfp_mask);
 	noreclaim_flag = memalloc_noreclaim_save();
-	reclaim_state.reclaimed_slab = 0;
-	p->reclaim_state = &reclaim_state;
+	p->reclaim_state = &sc.reclaim_state;
 
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
 
@@ -4085,7 +4083,6 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 	/* Minimum pages needed in order to stay on node */
 	const unsigned long nr_pages = 1 << order;
 	struct task_struct *p = current;
-	struct reclaim_state reclaim_state;
 	unsigned int noreclaim_flag;
 	struct scan_control sc = {
 		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
@@ -4110,8 +4107,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 	 */
 	noreclaim_flag = memalloc_noreclaim_save();
 	p->flags |= PF_SWAPWRITE;
-	reclaim_state.reclaimed_slab = 0;
-	p->reclaim_state = &reclaim_state;
+	p->reclaim_state = &sc.reclaim_state;
 
 	if (node_pagecache_reclaimable(pgdat) > pgdat->min_unmapped_pages) {
 		/*
-- 
1.8.3.1

