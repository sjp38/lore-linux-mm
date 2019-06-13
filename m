Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3996C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:30:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3ACF620896
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:30:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3ACF620896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CADC46B000C; Thu, 13 Jun 2019 19:30:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C5D6E6B000E; Thu, 13 Jun 2019 19:30:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7D5D6B0266; Thu, 13 Jun 2019 19:30:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 82CE56B000C
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 19:30:04 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id a21so440089pgh.11
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:30:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=amxFSe5SyXBQQAe5Ku8yftAIKY+0zVP6ltWnawYlljs=;
        b=BanCVj5el7qphBOGUzCyoBw+P81qZo34O1nWA9xP8wPnDM+fN0opUxphDfFFsGmOBA
         Zh5iaPCVT59WwSVXRJcXiS1ujb7Ww6DJXRSfSoGjev/jJVHslUg7LK2khgyXiP7zQg0d
         fz+DeNUCJEh51sY+T+fnm8Y5cUgGwy8Hbhvswr+XzbuWGWtXJHy9I6/xrLzQEW9TGxFL
         Ye8RsIwL2tlpfUGxO8lpDd49vnYxlv9Gw2CX/lKQLFwGM0TeF24Ro+lfsbXqa/n8sfJf
         K5iQzj0FlUpHt0QravU3zu8Gcaml3yJA1dgdHORbc7N4e4SrWAMNIIWHXe3c8Z6EzZFQ
         uMQQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVadnl2iiePuZZqnCL8ZLZf8jJTq/6w+8pVeYswxYOxhpIYs48J
	7U9THj4wRTqpmQnLHVvRG6XiEJAg32M5T2LyH40WA/qgxYOJz/qs7hDdCONDiIf2w+S3JvqNDzo
	ucZMwg3ypXwvww0tly+uJ9scmxshBcedsnIEjGHdxp5cocABiXSpHuX2Kko1320RClQ==
X-Received: by 2002:aa7:9087:: with SMTP id i7mr38504625pfa.40.1560468604154;
        Thu, 13 Jun 2019 16:30:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqziVSNt4qwldYBdIjkKFMQ+K6aQ6Q47eVR73+bTAUK9CkWO4dmA/WWe+55mFRtZEkr+LHc/
X-Received: by 2002:aa7:9087:: with SMTP id i7mr38504544pfa.40.1560468602891;
        Thu, 13 Jun 2019 16:30:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560468602; cv=none;
        d=google.com; s=arc-20160816;
        b=jO5ta7+crsyfq2KIubC0alJfM50cKWaFA2v0IBtcN7+iPL5CxLR+qNUm2sdDaO4jq7
         rjpObbvC+9Ic8IkYgAYlRV/9yah9u/AagCya58ZmgkYeqdMbt4N0f+3JTKoG7t4fVmaH
         auCRa1QPKSPn3I94gMjUKpY1tzXCL58hBeYh7qY8R69bvxmqiypANA0Zfm9u1Vq6NBBW
         iSmOQgf2prXo++2XyCkwwH55kHuHzvlAtBRFKSwwstTYJJATCujAxb7XzWpART2qB/Xn
         dhU0enGJu589renI5NlpZ4WMKja39azJ5dlGJyQmW/NpeIh01m/FgzEVvgqGM7B1pEe/
         Q2aw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=amxFSe5SyXBQQAe5Ku8yftAIKY+0zVP6ltWnawYlljs=;
        b=pvuX2TCDPYr9JNCYOb2HomkGk6EehV/qRuff80rtscCy1ILe37In66cusSn0coM+uU
         MZfoMuvuNcJ1dCVRm09GZ4cnj7BTx/7BurGAltdgiWefb/L0lkEwZ1UPbl+p4fkzdJp3
         Cknhy7pvkdIRzSKh4drV3ijjrDmXeoXd7+DYDUnUVIK4l7FIzyT+8U0HKjzYrrGskHC5
         7xnLU4uVzJOtOGoPObMDP3VbL2VmaPqcC4hbRlPCPC+NwWSFcFS+zFGNEq+NDk4bPFHr
         DOClVFZP+VcvUvS6ccV4tKM6CQDetAfpnsmoBSZ9juNfTbx9jLUi67bKIoAtOdLnVAfW
         cFpg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id k186si892418pgd.148.2019.06.13.16.30.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 16:30:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) client-ip=115.124.30.131;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R211e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e01422;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=15;SR=0;TI=SMTPD_---0TU6DYEz_1560468591;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TU6DYEz_1560468591)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 14 Jun 2019 07:30:00 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: mhocko@suse.com,
	mgorman@techsingularity.net,
	riel@surriel.com,
	hannes@cmpxchg.org,
	akpm@linux-foundation.org,
	dave.hansen@intel.com,
	keith.busch@intel.com,
	dan.j.williams@intel.com,
	fengguang.wu@intel.com,
	fan.du@intel.com,
	ying.huang@intel.com,
	ziy@nvidia.com
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v3 PATCH 6/9] mm: vmscan: don't demote for memcg reclaim
Date: Fri, 14 Jun 2019 07:29:34 +0800
Message-Id: <1560468577-101178-7-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1560468577-101178-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1560468577-101178-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The memcg reclaim happens when the limit is breached, but demotion just
migrate pages to the other node instead of reclaiming them.  This sounds
pointless to memcg reclaim since the usage is not reduced at all.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/vmscan.c | 38 +++++++++++++++++++++-----------------
 1 file changed, 21 insertions(+), 17 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 428a83b..fb931ded 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1126,12 +1126,16 @@ static inline struct page *alloc_demote_page(struct page *page,
 }
 #endif
 
-static inline bool is_demote_ok(int nid)
+static inline bool is_demote_ok(int nid, struct scan_control *sc)
 {
 	/* Just do demotion with migrate mode of node reclaim */
 	if (!(node_reclaim_mode & RECLAIM_MIGRATE))
 		return false;
 
+	/* It is pointless to do demotion in memcg reclaim */
+	if (!global_reclaim(sc))
+		return false;
+
 	/* Current node is cpuless node */
 	if (!node_state(nid, N_CPU_MEM))
 		return false;
@@ -1326,7 +1330,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				 * Demotion only happen from primary nodes
 				 * to cpuless nodes.
 				 */
-				if (is_demote_ok(page_to_nid(page))) {
+				if (is_demote_ok(page_to_nid(page), sc)) {
 					list_add(&page->lru, &demote_pages);
 					unlock_page(page);
 					continue;
@@ -2226,7 +2230,7 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 	 * anonymous page deactivation is pointless.
 	 */
 	if (!file && !total_swap_pages &&
-	    !is_demote_ok(pgdat->node_id))
+	    !is_demote_ok(pgdat->node_id, sc))
 		return false;
 
 	inactive = lruvec_lru_size(lruvec, inactive_lru, sc->reclaim_idx);
@@ -2307,7 +2311,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 *
 	 * If current node is already PMEM node, demotion is not applicable.
 	 */
-	if (!is_demote_ok(pgdat->node_id)) {
+	if (!is_demote_ok(pgdat->node_id, sc)) {
 		/*
 		 * If we have no swap space, do not bother scanning
 		 * anon pages.
@@ -2316,18 +2320,18 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 			scan_balance = SCAN_FILE;
 			goto out;
 		}
+	}
 
-		/*
-		 * Global reclaim will swap to prevent OOM even with no
-		 * swappiness, but memcg users want to use this knob to
-		 * disable swapping for individual groups completely when
-		 * using the memory controller's swap limit feature would be
-		 * too expensive.
-		 */
-		if (!global_reclaim(sc) && !swappiness) {
-			scan_balance = SCAN_FILE;
-			goto out;
-		}
+	/*
+	 * Global reclaim will swap to prevent OOM even with no
+	 * swappiness, but memcg users want to use this knob to
+	 * disable swapping for individual groups completely when
+	 * using the memory controller's swap limit feature would be
+	 * too expensive.
+	 */
+	if (!global_reclaim(sc) && !swappiness) {
+		scan_balance = SCAN_FILE;
+		goto out;
 	}
 
 	/*
@@ -2676,7 +2680,7 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 	 */
 	pages_for_compaction = compact_gap(sc->order);
 	inactive_lru_pages = node_page_state(pgdat, NR_INACTIVE_FILE);
-	if (get_nr_swap_pages() > 0 || is_demote_ok(pgdat->node_id))
+	if (get_nr_swap_pages() > 0 || is_demote_ok(pgdat->node_id, sc))
 		inactive_lru_pages += node_page_state(pgdat, NR_INACTIVE_ANON);
 	if (sc->nr_reclaimed < pages_for_compaction &&
 			inactive_lru_pages > pages_for_compaction)
@@ -3362,7 +3366,7 @@ static void age_active_anon(struct pglist_data *pgdat,
 	struct mem_cgroup *memcg;
 
 	/* Aging anon page as long as demotion is fine */
-	if (!total_swap_pages && !is_demote_ok(pgdat->node_id))
+	if (!total_swap_pages && !is_demote_ok(pgdat->node_id, sc))
 		return;
 
 	memcg = mem_cgroup_iter(NULL, NULL, NULL);
-- 
1.8.3.1

