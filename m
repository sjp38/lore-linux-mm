Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA551C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 03:58:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7245B217F4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 03:58:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7245B217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 149A16B000C; Wed, 10 Apr 2019 23:58:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F99D6B000E; Wed, 10 Apr 2019 23:58:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F02736B0010; Wed, 10 Apr 2019 23:58:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B5F946B000C
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 23:58:01 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d16so3205650pll.21
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 20:58:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=kPV/IimYK8rIwnVzgWtbkuEOj9DcMDBGg1cT6gUJMCE=;
        b=NtWaX/AFnnTvRkcg89//yDBYkFRkaM8LBQIw4nF4Il078H+6C7fkc1EPx63Vp2dwHB
         KaKTdUg/J5Jk7BilEqEAtIYeDCq6YAHHR+lVFXwKyKZdwPXa4lQno/QM64pCL0xzW3I9
         K9cFGuBvXoGZKVgb+yvCW+3TjpBEEXWm6pstZsggBS0s36FavKbcPayHS0O3Rt+5dLzV
         xP1thCSbqYcEQA8uspubf3TI2qL4rtEU616dv/3SbEwHsP4m1j24ywVRFv3NnUp4RMiU
         jDZv9ELE7aE4SIcN736ncnVU3YA3rCL4GM4dESIaPjqugZXQQoaZFSns/AM/unm1NRFL
         GsrQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAULNXb7SmkLaCEV080MdlayxP7RA4ZkZ8o0AKstkcZBBkqKtPtV
	6zYI9GBB7KbbNE1Eb0MURIRbafqcf7Xaa9sgWuWhcmUKwlGWfy/FjT50ErPcXqyFp4EeQq00nQ/
	oP0cqHNOlovm+yasORvUA2YveuD3VKJIf7BCHeaCPN3yGhTA6UlIi+W3wQcX41PzQ6Q==
X-Received: by 2002:a63:711d:: with SMTP id m29mr45178533pgc.109.1554955081301;
        Wed, 10 Apr 2019 20:58:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwf0tO+XBYV99+JNELIJ/keN/hba1UwHO5vhYW4nljK6uYSZTFQMWz04INdMNrwaMPbVgfI
X-Received: by 2002:a63:711d:: with SMTP id m29mr45178477pgc.109.1554955080041;
        Wed, 10 Apr 2019 20:58:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554955080; cv=none;
        d=google.com; s=arc-20160816;
        b=pJXuQR3+kKBtLBYAzlrC8+LGU95i7+HNkEgDZteXiLCsqQKSvPB0vdLLnnpAaxG+i4
         k8lO9E8npMzMQgrh6IGvD1MGUJFhpodne90Vp7riNipKIclro0p6mS8PKUQghiK6iSyt
         k6atcsUtl/c3fisrIGi2cdEY2Hczk2nqJFBCNpCQf99N9hNP8hgh03cn8hTII+8gcmEV
         CZYemdITEdOrPdMO91a+BdWuEnKcoW/620itKZRH3N5lodRfJ7jOpLP7pHZOUq6xofaP
         ZsiRB5yteZXEdPC44vapukTm3Xpbvkdo/HLh82+4odsjeOsxHU8X5lOtzcUhNDDIPeVy
         s33Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=kPV/IimYK8rIwnVzgWtbkuEOj9DcMDBGg1cT6gUJMCE=;
        b=nKKoCbnEk1z3anTH5+Kh3kJI7hbyaqDB3TWnObV99+jZmfIkjQkMOYgCfQ3iMd3e2C
         aHSxza1w4JS3kr9W8rDIW1eo8xqsZPdSgYZmoUNKozKp4jsogbE6nDaVYsetAklwcFBV
         uYrNqqz73NPoWLamOzgSY4L4QWtwnxadgUYcn+RJrjTUATS6YhXnsk/74qXeqrF300u2
         Kv+e09qveVMHLJPKe1VZu4M38wO+BFwACGhXgwtVkDVKeDGnbq2C+Zaj2faHyI8pRepi
         G/1RHvOn92DqQeroMAyw4VPszLvl7jbpiyqmMMuMdr0kXNLFxknLE8s7uKRZTkbiriOj
         rmPg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id a23si32832829pls.188.2019.04.10.20.57.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 20:58:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R941e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04391;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=15;SR=0;TI=SMTPD_---0TP0I5rB_1554955031;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TP0I5rB_1554955031)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 11 Apr 2019 11:57:23 +0800
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
Subject: [v2 PATCH 6/9] mm: vmscan: don't demote for memcg reclaim
Date: Thu, 11 Apr 2019 11:56:56 +0800
Message-Id: <1554955019-29472-7-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
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
index 2a96609..80cd624 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1046,8 +1046,12 @@ static void page_check_dirty_writeback(struct page *page,
 		mapping->a_ops->is_dirty_writeback(page, dirty, writeback);
 }
 
-static inline bool is_demote_ok(int nid)
+static inline bool is_demote_ok(int nid, struct scan_control *sc)
 {
+	/* It is pointless to do demotion in memcg reclaim */
+	if (!global_reclaim(sc))
+		return false;
+
 	/* Current node is cpuless node */
 	if (!node_state(nid, N_CPU_MEM))
 		return false;
@@ -1267,7 +1271,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				 * Demotion only happen from primary nodes
 				 * to cpuless nodes.
 				 */
-				if (is_demote_ok(page_to_nid(page))) {
+				if (is_demote_ok(page_to_nid(page), sc)) {
 					list_add(&page->lru, &demote_pages);
 					unlock_page(page);
 					continue;
@@ -2219,7 +2223,7 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 	 * deactivation is pointless.
 	 */
 	if (!file && !total_swap_pages &&
-	    !is_demote_ok(pgdat->node_id))
+	    !is_demote_ok(pgdat->node_id, sc))
 		return false;
 
 	inactive = lruvec_lru_size(lruvec, inactive_lru, sc->reclaim_idx);
@@ -2306,7 +2310,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 *
 	 * If current node is already PMEM node, demotion is not applicable.
 	 */
-	if (!is_demote_ok(pgdat->node_id)) {
+	if (!is_demote_ok(pgdat->node_id, sc)) {
 		/*
 		 * If we have no swap space, do not bother scanning
 		 * anon pages.
@@ -2315,18 +2319,18 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
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
@@ -2675,7 +2679,7 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 	 */
 	pages_for_compaction = compact_gap(sc->order);
 	inactive_lru_pages = node_page_state(pgdat, NR_INACTIVE_FILE);
-	if (get_nr_swap_pages() > 0 || is_demote_ok(pgdat->node_id))
+	if (get_nr_swap_pages() > 0 || is_demote_ok(pgdat->node_id, sc))
 		inactive_lru_pages += node_page_state(pgdat, NR_INACTIVE_ANON);
 	if (sc->nr_reclaimed < pages_for_compaction &&
 			inactive_lru_pages > pages_for_compaction)
@@ -3373,7 +3377,7 @@ static void age_active_anon(struct pglist_data *pgdat,
 	struct mem_cgroup *memcg;
 
 	/* Aging anon page as long as demotion is fine */
-	if (!total_swap_pages && !is_demote_ok(pgdat->node_id))
+	if (!total_swap_pages && !is_demote_ok(pgdat->node_id, sc))
 		return;
 
 	memcg = mem_cgroup_iter(NULL, NULL, NULL);
-- 
1.8.3.1

