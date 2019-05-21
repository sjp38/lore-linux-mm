Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64F29C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 09:41:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20B6B21479
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 09:41:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20B6B21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8E876B0007; Tue, 21 May 2019 05:41:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A33066B0008; Tue, 21 May 2019 05:41:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 886116B000C; Tue, 21 May 2019 05:41:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4969C6B0008
	for <linux-mm@kvack.org>; Tue, 21 May 2019 05:41:11 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 5so11979326pff.11
        for <linux-mm@kvack.org>; Tue, 21 May 2019 02:41:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=+E9tZ5jftajU2k/zpNBz2bssx03Et5KHZum3c3z5GqI=;
        b=ruIsThlcNkvSBC5Y4LOLZmPdYh7f1jzi8aEi9SyLPQ0umtt9idFArNzr45lJAWGiUD
         5K839T8UDsGQJWf5nlEX2o4pNNdWHbDq1WHAsd07IZe6q3PpkY0Kyzu3PpSqGyhvI6YT
         AX/XUgWxf5xLBeU/J39fcrEK0DaK0353/pRDMjjkMGYkU27B1PrdazfNDRiznVyM1KFv
         nOxozpk7ijpJXNLr///xXeEkuOgpQ92+ovyAVXhP1BDGOdQxb+948buURdD0sJKhk2Vg
         hLBwDZYt4JiPRbicSrvs1RfTILra/zSxSEWnwRoBejbkODqR4jNbZ5yzAfVqpC9i2Fzq
         Xvww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAU4NZz2lyEgqAr8r8XQKpp4EUeiRX8ITWF1NiKswljcDE8A6Xvh
	vddPALQOJ+gc2Hj+7pD87sA2n5GFP172Mn9PBZx4bHobmZMJk9/eiZON1b/xX2MgVraofJcm10E
	bPyEwrEDA0+af+bF6zw5K0TJEKqibsCNfHP+vMoNWH03+qheHtFWa8JPebteB87W/xg==
X-Received: by 2002:a63:9d8d:: with SMTP id i135mr81102577pgd.245.1558431670860;
        Tue, 21 May 2019 02:41:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwL8798t+T0xLJEBK+Knq6UXG50wS9IRcIC5WficqHuL7RjfsQPzPNHkYg2d6jnC8EpfYQi
X-Received: by 2002:a63:9d8d:: with SMTP id i135mr81102487pgd.245.1558431669433;
        Tue, 21 May 2019 02:41:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558431669; cv=none;
        d=google.com; s=arc-20160816;
        b=UxGqR6fnCUbvvD7wHK3Iyr0TE5AhVAu5XH7aL4LL1XOKmpD++1/ZhqUOuOTlxshXvo
         O+noSqZ0YHq4zXEJroNn0PBZ17wu39hS7GWskB0krNf8PXjh7OYlMLPcKfGpx9lEhA3z
         u0wr2/evr6/4w4/OJcb48Uq6XarbPZ9JH8SxdN3gRxaEFlZS3C5M461Zjy2Obxmbprt+
         hnFluwkFiGv+eTeW2Z9+Wa8FEATsG7wCx0eZP6wy2dbqZ7F3FuovYD1/ZGI5sEmhoK1X
         XS9q5jIXDJf7EDVcSWHLuSmpicizNQ2jBYucf4YGSIvfeHjufNGHjWhFUS6xR08ePAKb
         Dmpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=+E9tZ5jftajU2k/zpNBz2bssx03Et5KHZum3c3z5GqI=;
        b=NR0p22mcVbvbnbqdi4svFOT6v6wYhUi3iu232s67AxV2fEJkUqp/bg3pRO4psp9gBG
         q8CvCYsyHQNVzt3BWNDaPf2vYK21N3D2zpV4fLNZlALhz+I2YJaU27W22z/xeGTak2yz
         QX+WxWIusvCtZuNNKKAUN9pcGP3X3h4iDfO+7uBX80nX3f8TNBhXV/D/X6vVeumtwgo8
         C9wZjonC3oOqF8oGKvMO8bowdkrSBP37beD8rchrrchtXnJFlqVROGGjsZOalhjDgKmH
         nAtlT2/JF5rxDgDkxlL3a9WeAi3MMPycMz0hpim6bGu36vO6fb2TjkkU6W+x1URXubPK
         ng9A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id k23si17355037pls.88.2019.05.21.02.41.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 02:41:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R241e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04400;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TSIe59t_1558431642;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TSIe59t_1558431642)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 21 May 2019 17:40:55 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: ying.huang@intel.com,
	hannes@cmpxchg.org,
	mhocko@suse.com,
	mgorman@techsingularity.net,
	kirill.shutemov@linux.intel.com,
	josef@toxicpanda.com,
	hughd@google.com,
	shakeelb@google.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v3 PATCH 2/2] mm: vmscan: correct some vmscan counters for THP swapout
Date: Tue, 21 May 2019 17:40:42 +0800
Message-Id: <1558431642-52120-2-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1558431642-52120-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1558431642-52120-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since commit bd4c82c22c36 ("mm, THP, swap: delay splitting THP after
swapped out"), THP can be swapped out in a whole.  But, nr_reclaimed
and some other vm counters still get inc'ed by one even though a whole
THP (512 pages) gets swapped out.

This doesn't make too much sense to memory reclaim.  For example, direct
reclaim may just need reclaim SWAP_CLUSTER_MAX pages, reclaiming one THP
could fulfill it.  But, if nr_reclaimed is not increased correctly,
direct reclaim may just waste time to reclaim more pages,
SWAP_CLUSTER_MAX * 512 pages in worst case.

And, it may cause pgsteal_{kswapd|direct} is greater than
pgscan_{kswapd|direct}, like the below:

pgsteal_kswapd 122933
pgsteal_direct 26600225
pgscan_kswapd 174153
pgscan_direct 14678312

nr_reclaimed and nr_scanned must be fixed in parallel otherwise it would
break some page reclaim logic, e.g.

vmpressure: this looks at the scanned/reclaimed ratio so it won't
change semantics as long as scanned & reclaimed are fixed in parallel.

compaction/reclaim: compaction wants a certain number of physical pages
freed up before going back to compacting.

kswapd priority raising: kswapd raises priority if we scan fewer pages
than the reclaim target (which itself is obviously expressed in order-0
pages). As a result, kswapd can falsely raise its aggressiveness even
when it's making great progress.

Other than nr_scanned and nr_reclaimed, some other counters, e.g.
pgactivate, nr_skipped, nr_ref_keep and nr_unmap_fail need to be fixed
too since they are user visible via cgroup, /proc/vmstat or trace
points, otherwise they would be underreported.

When isolating pages from LRUs, nr_taken has been accounted in base
page, but nr_scanned and nr_skipped are still accounted in THP.  It
doesn't make too much sense too since this may cause trace point
underreport the numbers as well.

So accounting those counters in base page instead of accounting THP as
one page.

This change may result in lower steal/scan ratio in some cases since
THP may get split during page reclaim, then a part of tail pages get
reclaimed instead of the whole 512 pages, but nr_scanned is accounted
by 512, particularly for direct reclaim.  But, this should be not a
significant issue.

Cc: "Huang, Ying" <ying.huang@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shakeel Butt <shakeelb@google.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
v3: Removed Shakeel's Reviewed-by since the patch has been changed significantly
    Switched back to use compound_order per Matthew
    Fixed more counters per Johannes
v2: Added Shakeel's Reviewed-by
    Use hpage_nr_pages instead of compound_order per Huang Ying and William Kucharski

 mm/vmscan.c | 40 ++++++++++++++++++++++++++++------------
 1 file changed, 28 insertions(+), 12 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b65bc50..1044834 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1250,7 +1250,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		case PAGEREF_ACTIVATE:
 			goto activate_locked;
 		case PAGEREF_KEEP:
-			stat->nr_ref_keep++;
+			stat->nr_ref_keep += (1 << compound_order(page));
 			goto keep_locked;
 		case PAGEREF_RECLAIM:
 		case PAGEREF_RECLAIM_CLEAN:
@@ -1294,6 +1294,17 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 						goto activate_locked;
 				}
 
+				/*
+				 * Account all tail pages when THP is added
+				 * into swap cache successfully.
+				 * The head page has been accounted at the
+				 * first place.
+				 */
+				if (PageTransHuge(page))
+					sc->nr_scanned +=
+						((1 << compound_order(page)) -
+							1);
+
 				may_enter_fs = 1;
 
 				/* Adding to swap updated mapping */
@@ -1315,7 +1326,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			if (unlikely(PageTransHuge(page)))
 				flags |= TTU_SPLIT_HUGE_PMD;
 			if (!try_to_unmap(page, flags)) {
-				stat->nr_unmap_fail++;
+				stat->nr_unmap_fail +=
+					(1 << compound_order(page));
 				goto activate_locked;
 			}
 		}
@@ -1442,7 +1454,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 		unlock_page(page);
 free_it:
-		nr_reclaimed++;
+		/*
+		 * THP may get swapped out in a whole, need account
+		 * all base pages.
+		 */
+		nr_reclaimed += (1 << compound_order(page));
 
 		/*
 		 * Is there need to periodically free_page_list? It would
@@ -1464,7 +1480,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (!PageMlocked(page)) {
 			int type = page_is_file_cache(page);
 			SetPageActive(page);
-			pgactivate++;
 			stat->nr_activate[type] += hpage_nr_pages(page);
 			count_memcg_page_event(page, PGACTIVATE);
 		}
@@ -1475,6 +1490,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page), page);
 	}
 
+	pgactivate = stat->nr_activate[0] + stat->nr_activate[1];
+
 	mem_cgroup_uncharge_list(&free_pages);
 	try_to_unmap_flush();
 	free_unref_page_list(&free_pages);
@@ -1642,14 +1659,12 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	unsigned long nr_zone_taken[MAX_NR_ZONES] = { 0 };
 	unsigned long nr_skipped[MAX_NR_ZONES] = { 0, };
 	unsigned long skipped = 0;
-	unsigned long scan, total_scan, nr_pages;
+	unsigned long scan, nr_pages;
 	LIST_HEAD(pages_skipped);
 	isolate_mode_t mode = (sc->may_unmap ? 0 : ISOLATE_UNMAPPED);
 
 	scan = 0;
-	for (total_scan = 0;
-	     scan < nr_to_scan && nr_taken < nr_to_scan && !list_empty(src);
-	     total_scan++) {
+	while (scan < nr_to_scan && nr_taken < nr_to_scan && !list_empty(src)) {
 		struct page *page;
 
 		page = lru_to_page(src);
@@ -1659,7 +1674,8 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 		if (page_zonenum(page) > sc->reclaim_idx) {
 			list_move(&page->lru, &pages_skipped);
-			nr_skipped[page_zonenum(page)]++;
+			nr_skipped[page_zonenum(page)] +=
+				(1 << compound_order(page));
 			continue;
 		}
 
@@ -1669,7 +1685,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		 * ineligible pages.  This causes the VM to not reclaim any
 		 * pages, triggering a premature OOM.
 		 */
-		scan++;
+		scan += (1 << compound_order(page));
 		switch (__isolate_lru_page(page, mode)) {
 		case 0:
 			nr_pages = hpage_nr_pages(page);
@@ -1707,9 +1723,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			skipped += nr_skipped[zid];
 		}
 	}
-	*nr_scanned = total_scan;
+	*nr_scanned = scan;
 	trace_mm_vmscan_lru_isolate(sc->reclaim_idx, sc->order, nr_to_scan,
-				    total_scan, skipped, nr_taken, mode, lru);
+				    scan, skipped, nr_taken, mode, lru);
 	update_lru_sizes(lruvec, lru, nr_zone_taken);
 	return nr_taken;
 }
-- 
1.8.3.1

