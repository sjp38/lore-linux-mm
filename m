Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5D2EC282E3
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 01:58:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9BC3020815
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 01:58:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BC3020815
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3564D6B0271; Sun, 26 May 2019 21:58:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 30A136B0272; Sun, 26 May 2019 21:58:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 159566B0273; Sun, 26 May 2019 21:58:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id CD1BC6B0271
	for <linux-mm@kvack.org>; Sun, 26 May 2019 21:58:22 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 11so12243713pfb.4
        for <linux-mm@kvack.org>; Sun, 26 May 2019 18:58:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=LP1sErBd2BR1zKVZ2zZNExqXOGfpDqRKSw19ANa0a6c=;
        b=Nkb5HFW8u1ROgNfp3WsvuLiw94Nc2JDdSJewMOf1kYyT6kBJeVtydP/wSzDyD5Ar1X
         iCA4sG6BEn00D//PxWdEnZbKWnhyH+ULQVpDs/GbZxnR1AhIirfBs3JZt7A7nfBr7FvV
         ybmYh1x8A7CwqO2+C97OmExQEVizeqVIQ/n8WJN/ZonfVIFPHLvmOBf8wEBbjz153Gds
         qen7dM9Ub2XDk3iouzBCK6j6jls/zy+En/uV0Y0VYCTK+FyqunUTbUM3mvVlLVQDitVL
         42EK/HFJTxaeBFJaXJPj0F6sVNl2AVpDWrzhxxiH7nNL1oOMvdbSE5dQqpDqbL3Vd/+z
         O/Iw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAX7ooEISYMEHHCFXeFSkjOTarjamIRm1yo4rm0QUpgc2pTtv26n
	+tsFP7btr6YjEkdnKAdw0XRIpN/QwUWj6Vz7XcaTqFywURMzGHGmlKGuggG5nyiDej02+BAJ80N
	fZb9/J80XRuQ3WQWylzuqGw/IQ2+LiqjiyQuxAM7Wb0luiG/5JeB2n6lX+FI8tErGDQ==
X-Received: by 2002:a62:82c1:: with SMTP id w184mr18035315pfd.171.1558922302235;
        Sun, 26 May 2019 18:58:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhjen/UTkxSvFFmY0gXThJnbzW69VMHCvE/qO2Yx87SHZy4xnNKn+dqKzD+nlJZD3No6uE
X-Received: by 2002:a62:82c1:: with SMTP id w184mr18035232pfd.171.1558922300684;
        Sun, 26 May 2019 18:58:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558922300; cv=none;
        d=google.com; s=arc-20160816;
        b=XuqVaSx7Dq6k+3StSS4zr5oZdeHH2Krx1l2iWCfx0EwIJaVdy/BOqL+AYEmhKHajRV
         J9+rRfBybC0OT7GKkv9FOgjQ9QO3GQNSxhgMGM12cHFAlYnMcznXh8fG3LDIl9YStxUt
         dvk062MVpv/U3er1GUfd1Ig9EOEhvW3qVs9Hbm6lkKJJO/LbO+WcjYJ1QAKQCHrsY2jW
         YVlm/VvFmX24zYJFVPWnB0x0vdI//HBYtVA2AKL00yHyKErS2HFQdVyFNX0R305gFznl
         5hBc9JRxdGXFhTf6FZu+TIxLWooOjpPw/3opvihbUKZpA/QplZOEuZD1fDqUwB1V06wt
         nrPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=LP1sErBd2BR1zKVZ2zZNExqXOGfpDqRKSw19ANa0a6c=;
        b=MAKL/22NZoCKaRMD0EfKxNFSi+UJkBzwa5XnXX1+WiFgOHkADaY0DzjnbX4AnDHExH
         9pE4PCBEOPlo+l9ibIYqcCxb/1XbR++wp3v9AEDk0BayNXwUrm+X/4ICwXyue7sXFUL8
         bxCbMdo3qwOEYwwLJvpkoNOC3FdB28HuNhrx9DWR6VkQ/788IeghJe8LvCdpGxs7fypA
         imGW+fuEPzQOU5MmfeC5zlrdaBuABYwRL3T8AZUjTILzgYU22dWA+6LvLRq3hxxJKAki
         2ZyxVZhYwG54Bo1xs+cOnXe2lahxxjpjnIXWHa/XRBHlpaTlybCvgj9P0/QWlpUNukId
         IkPg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id o33si17462191pld.268.2019.05.26.18.58.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 May 2019 18:58:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R561e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04395;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TSlLoRp_1558922275;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TSlLoRp_1558922275)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 27 May 2019 09:58:04 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: ying.huang@intel.com,
	hannes@cmpxchg.org,
	mhocko@suse.com,
	mgorman@techsingularity.net,
	kirill.shutemov@linux.intel.com,
	josef@toxicpanda.com,
	hughd@google.com,
	shakeelb@google.com,
	hdanton@sina.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RESEND v5 PATCH 2/2] mm: vmscan: correct some vmscan counters for THP swapout
Date: Mon, 27 May 2019 09:57:55 +0800
Message-Id: <1558922275-31782-2-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1558922275-31782-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1558922275-31782-1-git-send-email-yang.shi@linux.alibaba.com>
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

nr_dirty, nr_unqueued_dirty, nr_congested and nr_writeback are used by
file cache, so they are not impacted by THP swap.

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
v5: Fixed sc->nr_scanned double accounting per Huang Ying
    Added some comments to address the concern about premature OOM per Hillf Danton 
v4: Fixed the comments from Johannes and Huang Ying
v3: Removed Shakeel's Reviewed-by since the patch has been changed significantly
    Switched back to use compound_order per Matthew
    Fixed more counters per Johannes
v2: Added Shakeel's Reviewed-by
    Use hpage_nr_pages instead of compound_order per Huang Ying and William Kucharski

 mm/vmscan.c | 42 +++++++++++++++++++++++++++++++-----------
 1 file changed, 31 insertions(+), 11 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b65bc50..f4f4d57 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1118,6 +1118,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		int may_enter_fs;
 		enum page_references references = PAGEREF_RECLAIM_CLEAN;
 		bool dirty, writeback;
+		unsigned int nr_pages;
 
 		cond_resched();
 
@@ -1129,6 +1130,13 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 		VM_BUG_ON_PAGE(PageActive(page), page);
 
+		nr_pages = 1 << compound_order(page);
+
+		/*
+		 * Accounted one page for THP for now.  If THP gets swapped
+		 * out in a whole, will account all tail pages later to
+		 * avoid accounting tail pages twice.
+		 */
 		sc->nr_scanned++;
 
 		if (unlikely(!page_evictable(page)))
@@ -1250,7 +1258,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		case PAGEREF_ACTIVATE:
 			goto activate_locked;
 		case PAGEREF_KEEP:
-			stat->nr_ref_keep++;
+			stat->nr_ref_keep += nr_pages;
 			goto keep_locked;
 		case PAGEREF_RECLAIM:
 		case PAGEREF_RECLAIM_CLEAN:
@@ -1292,7 +1300,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 #endif
 					if (!add_to_swap(page))
 						goto activate_locked;
-				}
+				} else
+					/* Account tail pages for THP */
+					sc->nr_scanned += nr_pages - 1;
 
 				may_enter_fs = 1;
 
@@ -1315,7 +1325,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			if (unlikely(PageTransHuge(page)))
 				flags |= TTU_SPLIT_HUGE_PMD;
 			if (!try_to_unmap(page, flags)) {
-				stat->nr_unmap_fail++;
+				stat->nr_unmap_fail += nr_pages;
 				goto activate_locked;
 			}
 		}
@@ -1442,7 +1452,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
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
@@ -1464,7 +1478,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (!PageMlocked(page)) {
 			int type = page_is_file_cache(page);
 			SetPageActive(page);
-			pgactivate++;
 			stat->nr_activate[type] += hpage_nr_pages(page);
 			count_memcg_page_event(page, PGACTIVATE);
 		}
@@ -1475,6 +1488,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page), page);
 	}
 
+	pgactivate = stat->nr_activate[0] + stat->nr_activate[1];
+
 	mem_cgroup_uncharge_list(&free_pages);
 	try_to_unmap_flush();
 	free_unref_page_list(&free_pages);
@@ -1646,10 +1661,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	LIST_HEAD(pages_skipped);
 	isolate_mode_t mode = (sc->may_unmap ? 0 : ISOLATE_UNMAPPED);
 
+	total_scan = 0;
 	scan = 0;
-	for (total_scan = 0;
-	     scan < nr_to_scan && nr_taken < nr_to_scan && !list_empty(src);
-	     total_scan++) {
+	while (scan < nr_to_scan && !list_empty(src)) {
 		struct page *page;
 
 		page = lru_to_page(src);
@@ -1657,9 +1671,12 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 		VM_BUG_ON_PAGE(!PageLRU(page), page);
 
+		nr_pages = 1 << compound_order(page);
+		total_scan += nr_pages;
+
 		if (page_zonenum(page) > sc->reclaim_idx) {
 			list_move(&page->lru, &pages_skipped);
-			nr_skipped[page_zonenum(page)]++;
+			nr_skipped[page_zonenum(page)] += nr_pages;
 			continue;
 		}
 
@@ -1668,11 +1685,14 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		 * return with no isolated pages if the LRU mostly contains
 		 * ineligible pages.  This causes the VM to not reclaim any
 		 * pages, triggering a premature OOM.
+		 *
+		 * Account all tail pages of THP.  This would not cause
+		 * premature OOM since __isolate_lru_page() returns -EBUSY
+		 * only when the page is being freed somewhere else.
 		 */
-		scan++;
+		scan += nr_pages;
 		switch (__isolate_lru_page(page, mode)) {
 		case 0:
-			nr_pages = hpage_nr_pages(page);
 			nr_taken += nr_pages;
 			nr_zone_taken[page_zonenum(page)] += nr_pages;
 			list_move(&page->lru, dst);
-- 
1.8.3.1

