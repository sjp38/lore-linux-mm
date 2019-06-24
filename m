Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC3B7C48BE4
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 02:56:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 809AF208C3
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 02:56:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 809AF208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 017966B0003; Sun, 23 Jun 2019 22:56:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F0AB58E0002; Sun, 23 Jun 2019 22:56:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF9E78E0001; Sun, 23 Jun 2019 22:56:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id ABE916B0003
	for <linux-mm@kvack.org>; Sun, 23 Jun 2019 22:56:13 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j7so8627624pfn.10
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 19:56:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=14hwdtvFDq+AenOKYgds7GhM287m9jnEwcUgDZlU0d8=;
        b=Gyc8/5Fbo7UfRJEIq9Zv/oLLHUIv3gu0QOtYq0fqqLLbhjqRG9ZrOh3OChKL34et8v
         amue3ev4gw4lBUA+HY2rUVpMGlFUlahs0P/+3UH4gKw+MGESm7v3t/902MeaOFBjNPAm
         NCTK5ODL9GL0pCQGe+gPvv+gVxHalRv5TauIamFADXZZ2WqX3vjIarJM6T04JDNXSOI9
         WuqPgp9ErdPzDyMZxep4v1EfCPiIRJhLI8ReIIw4l4OGQcw7zoZRgpD/fBXkLVio3yis
         vjOCUgg5DSfkG6fTGebnBP8f22Id+jVEZGOrkNJcaiO/vq552ndAyOeF+q8nVaNCpwCo
         XeHQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU5ufHvrkI0vSlbry4tN6KTOVwT9qcR7KpBgRCKKcR7eB2ng8yn
	9PwzHXD9HgkhhzI/ZwNl/vVIG9JW+DGSMHx6qavlYeEYhNsSqeNv3tTpbAVF/fKB54bmoZ8b4EI
	w3NB/9Bt1xfFBjuKqcpWYjICJz6sJdTRdiT8mfD4GbkJ6AL4UfZbHJtieuSR18xjg2A==
X-Received: by 2002:a63:f50d:: with SMTP id w13mr30644578pgh.411.1561344973159;
        Sun, 23 Jun 2019 19:56:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvLXUlyRginYmQu5wx7xGXGgTAy2leq14pdMg8VXIHb94B+lvRK+IqzrCA5KFTcTe8tbO7
X-Received: by 2002:a63:f50d:: with SMTP id w13mr30644523pgh.411.1561344971967;
        Sun, 23 Jun 2019 19:56:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561344971; cv=none;
        d=google.com; s=arc-20160816;
        b=zRkkwuWmJ+SwSz3EaIU3N3kA/fWON4WUjHCsWJnvhwFhUD4WIp2QJa61K2KuhgLZI2
         cXm0YmOXIcC+YQhBQf1DjQCLavCAZMyMvBDoHa8Tpe5YR3Z1k3mVpHRBa4Jh/mfBhuyc
         wsIpWbyaSgC9S/s7sZPLCyqp5bB2T+j4geffQVivTkQp+Z3SiS9x+Y6G+IkykaScbVzv
         dXwKSZZWRzLhNlzCM2/HFsljbQe7xqeFgyqGaHAT6GDcpMmwJJ8P3aXPSzuFpzd+hcSj
         RrelZqSATJ+hRogqC//PAS/zI1W38UxZh9uKiODn+vMWcsEelXWIKiVOUbbl/14GtCDA
         1n+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=14hwdtvFDq+AenOKYgds7GhM287m9jnEwcUgDZlU0d8=;
        b=cibdzEckqBS/zx4BXQSbuu2jDPk9zQvL9Sca3uTl04tdk8RZAPadp2yrBpVn7cqxL2
         EURETSJCdHWa2vGDY8XZJjGnO/hRQGWVheEOOhtvxOeKnhtFYyTDrrhw1qYHXi4KNbhK
         LEJs5RVSYunrZuXzFByfP3toe4hvkYgWOIPn3/QiORNpYN4t+Ylp/oFyPWRLJ4IgnI+Q
         kjoIXykKKzZoe4y2DTLly94DPK7g9DXayYFFpuedqdMnAMi2L2c2RaOZVYSFw7TeZWH+
         dTEpTnOWg5nhJnqp3uuzf+oSliDei6XWBtNCsOHOVI8v+7z43Qhwm0sePbPuxycpvwYB
         eUiA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id k3si8896153pll.343.2019.06.23.19.56.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Jun 2019 19:56:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 23 Jun 2019 19:56:11 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,410,1557212400"; 
   d="scan'208";a="171838542"
Received: from yhuang-mobile.sh.intel.com ([10.239.197.69])
  by orsmga002.jf.intel.com with ESMTP; 23 Jun 2019 19:56:08 -0700
From: Huang Ying <ying.huang@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Huang Ying <ying.huang@intel.com>,
	Rik van Riel <riel@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Mel Gorman <mgorman@suse.de>,
	jhladky@redhat.com,
	lvenanci@redhat.com,
	Ingo Molnar <mingo@kernel.org>
Subject: [PATCH -mm] autonuma: Fix scan period updating
Date: Mon, 24 Jun 2019 10:56:04 +0800
Message-Id: <20190624025604.30896-1-ying.huang@intel.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The autonuma scan period should be increased (scanning is slowed down)
if the majority of the page accesses are shared with other processes.
But in current code, the scan period will be decreased (scanning is
speeded up) in that situation.

This patch fixes the code.  And this has been tested via tracing the
scan period changing and /proc/vmstat numa_pte_updates counter when
running a multi-threaded memory accessing program (most memory
areas are accessed by multiple threads).

Fixes: 37ec97deb3a8 ("sched/numa: Slow down scan rate if shared faults dominate")
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra (Intel) <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: jhladky@redhat.com
Cc: lvenanci@redhat.com
Cc: Ingo Molnar <mingo@kernel.org>
---
 kernel/sched/fair.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index f35930f5e528..79bc4d2d1e58 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1923,7 +1923,7 @@ static void update_task_scan_period(struct task_struct *p,
 			unsigned long shared, unsigned long private)
 {
 	unsigned int period_slot;
-	int lr_ratio, ps_ratio;
+	int lr_ratio, sp_ratio;
 	int diff;
 
 	unsigned long remote = p->numa_faults_locality[0];
@@ -1954,22 +1954,22 @@ static void update_task_scan_period(struct task_struct *p,
 	 */
 	period_slot = DIV_ROUND_UP(p->numa_scan_period, NUMA_PERIOD_SLOTS);
 	lr_ratio = (local * NUMA_PERIOD_SLOTS) / (local + remote);
-	ps_ratio = (private * NUMA_PERIOD_SLOTS) / (private + shared);
+	sp_ratio = (shared * NUMA_PERIOD_SLOTS) / (private + shared);
 
-	if (ps_ratio >= NUMA_PERIOD_THRESHOLD) {
+	if (sp_ratio >= NUMA_PERIOD_THRESHOLD) {
 		/*
-		 * Most memory accesses are local. There is no need to
-		 * do fast NUMA scanning, since memory is already local.
+		 * Most memory accesses are shared with other tasks.
+		 * There is no point in continuing fast NUMA scanning,
+		 * since other tasks may just move the memory elsewhere.
 		 */
-		int slot = ps_ratio - NUMA_PERIOD_THRESHOLD;
+		int slot = sp_ratio - NUMA_PERIOD_THRESHOLD;
 		if (!slot)
 			slot = 1;
 		diff = slot * period_slot;
 	} else if (lr_ratio >= NUMA_PERIOD_THRESHOLD) {
 		/*
-		 * Most memory accesses are shared with other tasks.
-		 * There is no point in continuing fast NUMA scanning,
-		 * since other tasks may just move the memory elsewhere.
+		 * Most memory accesses are local. There is no need to
+		 * do fast NUMA scanning, since memory is already local.
 		 */
 		int slot = lr_ratio - NUMA_PERIOD_THRESHOLD;
 		if (!slot)
@@ -1981,7 +1981,7 @@ static void update_task_scan_period(struct task_struct *p,
 		 * yet they are not on the local NUMA node. Speed up
 		 * NUMA scanning to get the memory moved over.
 		 */
-		int ratio = max(lr_ratio, ps_ratio);
+		int ratio = max(lr_ratio, sp_ratio);
 		diff = -(NUMA_PERIOD_THRESHOLD - ratio) * period_slot;
 	}
 
-- 
2.21.0

