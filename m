Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E996DC04AAD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 05:39:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D79F214AE
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 05:39:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="kvAK+IVN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D79F214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 546E86B000D; Tue,  7 May 2019 01:39:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D1C96B0266; Tue,  7 May 2019 01:39:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 34A8B6B0269; Tue,  7 May 2019 01:39:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id ED4F56B000D
	for <linux-mm@kvack.org>; Tue,  7 May 2019 01:39:07 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id j36so4808553pgb.20
        for <linux-mm@kvack.org>; Mon, 06 May 2019 22:39:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=MYivS4rFRtfjs9OjDs6d/Vd7T/QEP+DYV07ABLUGRjQ=;
        b=pwEPlTLI5YYNkovIj3CcKGYSXPYlRIFO8QSci8afsuHW7uDc/U6WdiY78Ada5Pm6vc
         54pJOo4CjFDliCAyCyRJSDyFBO7dmGTkvoejJSgQuTW09Alx8AZERZh7xnAr1wA5lgcV
         x8w2xrV07cfN8zRywqv9XcGAQG5fe6S7qyUUIBJpvVAIQDgqHkK0EdkNIqCY+90hAQQK
         IXUW4XH7VVD7xPRR6qgAIBL71hzK6sr44cq/4upyl5gF534S0DGURITBuLuF7xxp+HTz
         mn9AOizwUmZTFvlSBOlFjtl99rY/fcxFtFiSsEuaKuYCj3Hxl0Xdg8a/xcc8NvbNTXa0
         fX8Q==
X-Gm-Message-State: APjAAAU06KaaPym8pu33TnRC1S8DQF4xjxNfmRWj2MTVlrpvmJRTks9f
	JiePVYfUTzjZN7Kff7ukIh4BoV0SQyPwFScckVMV5gfghHDoAhV9gAVUWZiXZlWFKDMVEd45T7N
	UJEjclC5rMW+erSgzcp/AAUVEiFcLuu/MXh49hzqu8WYTLooCRxSn9g3jtl7Qbp5LTA==
X-Received: by 2002:aa7:8284:: with SMTP id s4mr34734597pfm.235.1557207547619;
        Mon, 06 May 2019 22:39:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwMFPQBs1ajtUWVZV78xGrkF8iBlOinWZx+KrfdfNYsurtcLVXUsD11pqTHd0wYkpD4yQmV
X-Received: by 2002:aa7:8284:: with SMTP id s4mr34734547pfm.235.1557207546790;
        Mon, 06 May 2019 22:39:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557207546; cv=none;
        d=google.com; s=arc-20160816;
        b=mjKCZGi+KV25CExmKsuDCaDIcWL1R/Vef82FFNFyenlqeOrNUg1Tv+rleD6+CXIZ4b
         gkII+cZjvlQnhEhIoxLZZp8EBAh9ir9hIYk9k6lpr6iDwfSlXvV1XNKCzOztD7J6cjz6
         tSzsJCGdsu2QO7kikHhxIN92oegEqjqoog+7xwJP25Jadr2LulvxZq1nm3ASIVhcOpdz
         uwo5KA40f0TPEMQ9IhYhVG3vuDI6Ko1ljkjMOHyFCWPmhTMzE/Z2Rpr4DnXGVidIUjkz
         i11IKM/Y1jSbuoZAeTvPEWKZwojnFOp6hN7HccsZ5nheBr4/rnLTYpCtvRcCIKjaL8Sp
         43pg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=MYivS4rFRtfjs9OjDs6d/Vd7T/QEP+DYV07ABLUGRjQ=;
        b=OHH1X21GdTZS5YX0MG7sMyB0Ro6JojetZSphdeCd8Zyza+dvh7jRKJTxZACLtxOSZ8
         7ogDLkv2OkZjqZP3MEOI9xiulsSRrQWU3TP/nFTS4tCv2ZapG8DJvLfDFQ1QdgVUVZBX
         fJ/006pQcRcR1+71lyQpb3F4YpFd0LShszly7gJ/XWJZsyPXfNpmPsy77tdB5BDCU+Vp
         AXfLzIyvIAm8KuPer3txmZC+6byohto/LGm0lDcQCaPmA4ZAsrM8PGu51zvBQoyVQuot
         kq1pNUrbAdYgm0h4lnrRGnHWAa9PCSkb40EteiH9pvZjbNi0dCQhLH6qeKuEMY7wdOJB
         yyZw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=kvAK+IVN;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l10si17074524pgm.20.2019.05.06.22.39.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 22:39:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=kvAK+IVN;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5C4EC2087F;
	Tue,  7 May 2019 05:39:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557207546;
	bh=fSR++6+gYhk9xqGswU5f+QsciubFC4MA0Ap4MAcdRoI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=kvAK+IVN6m+Q6vt0Eqp8xPrcj2VF9FgSBrP9q9QewPDzTi14A82tZ7/CkkwEctlra
	 vDXtxHD8amnZzF0nJUtzmscEXoYdEY5AXVUVIjSpUwObussUXdHLeSgacCvtAUkXYv
	 kJ+ifZaZbUOxrNsoF0feo/Aj6OUv56NQMS6l9Dl0=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Shakeel Butt <shakeelb@google.com>,
	Roman Gushchin <guro@fb.com>,
	Michal Hocko <mhocko@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.14 21/95] mm: fix inactive list balancing between NUMA nodes and cgroups
Date: Tue,  7 May 2019 01:37:10 -0400
Message-Id: <20190507053826.31622-21-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190507053826.31622-1-sashal@kernel.org>
References: <20190507053826.31622-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Johannes Weiner <hannes@cmpxchg.org>

[ Upstream commit 3b991208b897f52507168374033771a984b947b1 ]

During !CONFIG_CGROUP reclaim, we expand the inactive list size if it's
thrashing on the node that is about to be reclaimed.  But when cgroups
are enabled, we suddenly ignore the node scope and use the cgroup scope
only.  The result is that pressure bleeds between NUMA nodes depending
on whether cgroups are merely compiled into Linux.  This behavioral
difference is unexpected and undesirable.

When the refault adaptivity of the inactive list was first introduced,
there were no statistics at the lruvec level - the intersection of node
and memcg - so it was better than nothing.

But now that we have that infrastructure, use lruvec_page_state() to
make the list balancing decision always NUMA aware.

[hannes@cmpxchg.org: fix bisection hole]
  Link: http://lkml.kernel.org/r/20190417155241.GB23013@cmpxchg.org
Link: http://lkml.kernel.org/r/20190412144438.2645-1-hannes@cmpxchg.org
Fixes: 2a2e48854d70 ("mm: vmscan: fix IO/refault regression in cache workingset transition")
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Shakeel Butt <shakeelb@google.com>
Cc: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/vmscan.c | 29 +++++++++--------------------
 1 file changed, 9 insertions(+), 20 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9734e62654fa..144961f6f89c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2111,7 +2111,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
  *   10TB     320        32GB
  */
 static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
-				 struct mem_cgroup *memcg,
 				 struct scan_control *sc, bool actual_reclaim)
 {
 	enum lru_list active_lru = file * LRU_FILE + LRU_ACTIVE;
@@ -2132,16 +2131,12 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 	inactive = lruvec_lru_size(lruvec, inactive_lru, sc->reclaim_idx);
 	active = lruvec_lru_size(lruvec, active_lru, sc->reclaim_idx);
 
-	if (memcg)
-		refaults = memcg_page_state(memcg, WORKINGSET_ACTIVATE);
-	else
-		refaults = node_page_state(pgdat, WORKINGSET_ACTIVATE);
-
 	/*
 	 * When refaults are being observed, it means a new workingset
 	 * is being established. Disable active list protection to get
 	 * rid of the stale workingset quickly.
 	 */
+	refaults = lruvec_page_state(lruvec, WORKINGSET_ACTIVATE);
 	if (file && actual_reclaim && lruvec->refaults != refaults) {
 		inactive_ratio = 0;
 	} else {
@@ -2162,12 +2157,10 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 }
 
 static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
-				 struct lruvec *lruvec, struct mem_cgroup *memcg,
-				 struct scan_control *sc)
+				 struct lruvec *lruvec, struct scan_control *sc)
 {
 	if (is_active_lru(lru)) {
-		if (inactive_list_is_low(lruvec, is_file_lru(lru),
-					 memcg, sc, true))
+		if (inactive_list_is_low(lruvec, is_file_lru(lru), sc, true))
 			shrink_active_list(nr_to_scan, lruvec, sc, lru);
 		return 0;
 	}
@@ -2267,7 +2260,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 			 * anonymous pages on the LRU in eligible zones.
 			 * Otherwise, the small LRU gets thrashed.
 			 */
-			if (!inactive_list_is_low(lruvec, false, memcg, sc, false) &&
+			if (!inactive_list_is_low(lruvec, false, sc, false) &&
 			    lruvec_lru_size(lruvec, LRU_INACTIVE_ANON, sc->reclaim_idx)
 					>> sc->priority) {
 				scan_balance = SCAN_ANON;
@@ -2285,7 +2278,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * lruvec even if it has plenty of old anonymous pages unless the
 	 * system is under heavy pressure.
 	 */
-	if (!inactive_list_is_low(lruvec, true, memcg, sc, false) &&
+	if (!inactive_list_is_low(lruvec, true, sc, false) &&
 	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE, sc->reclaim_idx) >> sc->priority) {
 		scan_balance = SCAN_FILE;
 		goto out;
@@ -2438,7 +2431,7 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
 				nr[lru] -= nr_to_scan;
 
 				nr_reclaimed += shrink_list(lru, nr_to_scan,
-							    lruvec, memcg, sc);
+							    lruvec, sc);
 			}
 		}
 
@@ -2505,7 +2498,7 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
 	 * Even if we did not try to evict anon pages at all, we want to
 	 * rebalance the anon lru active/inactive ratio.
 	 */
-	if (inactive_list_is_low(lruvec, false, memcg, sc, true))
+	if (inactive_list_is_low(lruvec, false, sc, true))
 		shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
 				   sc, LRU_ACTIVE_ANON);
 }
@@ -2830,12 +2823,8 @@ static void snapshot_refaults(struct mem_cgroup *root_memcg, pg_data_t *pgdat)
 		unsigned long refaults;
 		struct lruvec *lruvec;
 
-		if (memcg)
-			refaults = memcg_page_state(memcg, WORKINGSET_ACTIVATE);
-		else
-			refaults = node_page_state(pgdat, WORKINGSET_ACTIVATE);
-
 		lruvec = mem_cgroup_lruvec(pgdat, memcg);
+		refaults = lruvec_page_state(lruvec, WORKINGSET_ACTIVATE);
 		lruvec->refaults = refaults;
 	} while ((memcg = mem_cgroup_iter(root_memcg, memcg, NULL)));
 }
@@ -3183,7 +3172,7 @@ static void age_active_anon(struct pglist_data *pgdat,
 	do {
 		struct lruvec *lruvec = mem_cgroup_lruvec(pgdat, memcg);
 
-		if (inactive_list_is_low(lruvec, false, memcg, sc, true))
+		if (inactive_list_is_low(lruvec, false, sc, true))
 			shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
 					   sc, LRU_ACTIVE_ANON);
 
-- 
2.20.1

