Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7266C76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 08:01:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 98D2E218F0
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 08:01:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98D2E218F0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 438DF8E004B; Thu, 25 Jul 2019 04:01:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E9078E0031; Thu, 25 Jul 2019 04:01:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D8618E004B; Thu, 25 Jul 2019 04:01:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E61F28E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 04:01:46 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 21so30350112pfu.9
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 01:01:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=box84mwXckKb/e1nS1rQC2JW53yaxZIWnKUU6wF79Tc=;
        b=nVa6U0MSjzwOAoAP9imR1K8uWd2VztCL1aW5QuZmeUQZomeLgm5SYpSCkwHTEBU7qL
         8A57oA8yPS6bNRCHSNS/aviiEmJtJ5oAokcrzrxRXGlj6fMZA2XitdOFPwWG/cuCLYSe
         oiwBknq3SpoIuyUDwctTeWb7QN1CXG5qfWyroCgX735DSHzpUG/XBBIuxT69CK1r07FW
         tno9qftioXsgkTa6dJ3h4lmDPCJjbaM1fLJ/ryK/Y/1clcmnncFo0lIFu4KHcrsOQAje
         Ac2A2KGnFgTzvB1JIcJKytOdzEvqMcG9p0yRb0WXoO76Uqnzr116j1NTb+ZjQNAYqBTe
         HH+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWB1SfJb9eM3MLr5zh5Ln1cjplEmJp1aT1GOT/E3b3YVuQZxZ7e
	3dt9gwXsORKYXpyAXoR9WzsTSP9JvHY71td7KIm/dnWnhtJrz/NnZP2Moz++TJzQjnnUwkxvnJl
	mrKdVOSVpfdsnAUA/jc8GBN4TgkfKytcvKkQ1OKa3dLgXk1kxIB4cFHRfwBRN1HD0uQ==
X-Received: by 2002:a62:b615:: with SMTP id j21mr14953846pff.190.1564041706597;
        Thu, 25 Jul 2019 01:01:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwxBVY54RavGZbZlLtrheluAaXXyTw6YP8fuT10D6pALj6FCfkPOwE0eOqce9UFCYfvyZYA
X-Received: by 2002:a62:b615:: with SMTP id j21mr14953750pff.190.1564041705408;
        Thu, 25 Jul 2019 01:01:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564041705; cv=none;
        d=google.com; s=arc-20160816;
        b=fcSmbvgodpQqFSP2rUC0XAMAbqK5OUSkeUhj7jXPuurKr7VTXYPvBGhrShf5uF6CnD
         RISTqEddurjVd2aDu6WRTS7weGnqONu3QXtrg0D+4AKK/L8Y2eLADapgLnqmQwzINhBw
         vfEmdRzWShWRPgQjqkJGRzHDA004IKB9LGgNJ5o56/pl3ZSBF5E9WQaTJwdltD9SwdF1
         eaxBwU7LxysZNJACZkVrCm2iwQ5su4yaxGYvfpLf7+9erc1plIO2xswX36OxHi1RAb0S
         tDvmtwKJolYc8Zwi+glJilnbR7nuq1DMubkl3jFEdmGv4i6DV2bGCKmYlC5mqNMLu+9g
         HS3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=box84mwXckKb/e1nS1rQC2JW53yaxZIWnKUU6wF79Tc=;
        b=wLX7XCMlA7d/9Fu5/EgLRdXxx5itz3CiZMF0vnCjHQmX25+WorXqOnEvbYmjmeeqBb
         VRLZ+C7DGNm14FsVjWO3d4vAZEzuRTNP24Q15hY6BDw7BgZCP2gNodtizXzWW8ezqXFY
         DflctH5+DnqLIGHGo8RRGJzq0yuY148XitEwtJMh3lCsNIixkGv75z3CG73LgdFi96Ao
         ct8zhmcQf+y+wceQFOu0HjBbwivSpRwa8CTDZrsejwR8klii1dZI18H3gFTNAE4LbHpg
         4SWj8fySLuhctYXxsSEYNd1GX+z/aDaMzXr2o/f+oB8magmnClzPdS83YNYmkDbdDBtU
         nafw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id l4si16068728pjq.69.2019.07.25.01.01.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 01:01:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Jul 2019 01:01:44 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,306,1559545200"; 
   d="scan'208";a="189268852"
Received: from yhuang-dev.sh.intel.com ([10.239.159.29])
  by fmsmga001.fm.intel.com with ESMTP; 25 Jul 2019 01:01:42 -0700
From: "Huang, Ying" <ying.huang@intel.com>
To: Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Huang Ying <ying.huang@intel.com>,
	Rik van Riel <riel@redhat.com>,
	Mel Gorman <mgorman@suse.de>,
	jhladky@redhat.com,
	lvenanci@redhat.com,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH RESEND] autonuma: Fix scan period updating
Date: Thu, 25 Jul 2019 16:01:24 +0800
Message-Id: <20190725080124.494-1-ying.huang@intel.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Huang Ying <ying.huang@intel.com>

From the commit log and comments of commit 37ec97deb3a8 ("sched/numa:
Slow down scan rate if shared faults dominate"), the autonuma scan
period should be increased (scanning is slowed down) if the majority
of the page accesses are shared with other processes.  But in current
code, the scan period will be decreased (scanning is speeded up) in
that situation.

The commit log and comments make more sense.  So this patch fixes the
code to make it match the commit log and comments.  And this has been
verified via tracing the scan period changing and /proc/vmstat
numa_pte_updates counter when running a multi-threaded memory
accessing program (most memory areas are accessed by multiple
threads).

Fixes: 37ec97deb3a8 ("sched/numa: Slow down scan rate if shared faults dominate")
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra (Intel) <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: jhladky@redhat.com
Cc: lvenanci@redhat.com
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 kernel/sched/fair.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 036be95a87e9..468a1c5038b2 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1940,7 +1940,7 @@ static void update_task_scan_period(struct task_struct *p,
 			unsigned long shared, unsigned long private)
 {
 	unsigned int period_slot;
-	int lr_ratio, ps_ratio;
+	int lr_ratio, sp_ratio;
 	int diff;
 
 	unsigned long remote = p->numa_faults_locality[0];
@@ -1971,22 +1971,22 @@ static void update_task_scan_period(struct task_struct *p,
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
@@ -1998,7 +1998,7 @@ static void update_task_scan_period(struct task_struct *p,
 		 * yet they are not on the local NUMA node. Speed up
 		 * NUMA scanning to get the memory moved over.
 		 */
-		int ratio = max(lr_ratio, ps_ratio);
+		int ratio = max(lr_ratio, sp_ratio);
 		diff = -(NUMA_PERIOD_THRESHOLD - ratio) * period_slot;
 	}
 
-- 
2.20.1

