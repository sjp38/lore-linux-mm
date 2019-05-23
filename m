Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45F32C282CE
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 02:28:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDE4120881
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 02:28:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDE4120881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70B496B0007; Wed, 22 May 2019 22:28:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B0EF6B0006; Wed, 22 May 2019 22:28:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 578736B0007; Wed, 22 May 2019 22:28:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 187186B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 22:28:03 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id c12so3088254pfb.2
        for <linux-mm@kvack.org>; Wed, 22 May 2019 19:28:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=pxbR2tROxGdscNPq0FHUMQrz/OcrNWf6ZKt9Si6kHuk=;
        b=AbXU56TKVXr+MLPOTVYobZyOa5hFuVncQtUjXrgo3JfnW2O25HdZOkbBg5Xph76bvM
         X63i6ztI7UUxnXibIoSsdjuMV+zJzREAmf3swTcSCeFkWRsfsy86QPI8ACi4IHG31YMB
         XIfi+5jgXC8uiWQp9RUm2tZRQDnXGm6hhTr/G5XPut+MqeZKwsAtDemRh+RGYjJc365K
         Zz/5HYNOsanhomjKH9MKdhA+vYrx13ZpQyg7N65xtfnXzb5INDk5YCWb29Da36CWxj8Q
         Y8e6OKGAvoGgK7Ng8pMHwjZYjsTbJD6QabhpBKDKvPqkk/bOxjfU69qB5nIcxqs9KOlX
         gt0Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWgikQJeHgfrRiu8KAGu1FoRXJkpd6VT08d2hLKN7YMPBtX3aW4
	vjo40pmOBMZas1ceLoAdm8FVY1NL3y7fTqOIC+CXSaOR35yIr8q4+0J15DqgZozrz7y3nT+pMAz
	Xj6MPHq325t3cagEV8Z52+d1cA09lpzYqHm9jWa52+LrVlAP5QD2NBK0N79zKY1YNQA==
X-Received: by 2002:a63:9d83:: with SMTP id i125mr1255477pgd.229.1558578482736;
        Wed, 22 May 2019 19:28:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxuy9Ci0eWOmGqdVxJI9iEzZjf4Bh4kzWl5VGu1kiESRi5JpSYB3YBWGk61jBXT663S2K8q
X-Received: by 2002:a63:9d83:: with SMTP id i125mr1255361pgd.229.1558578481216;
        Wed, 22 May 2019 19:28:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558578481; cv=none;
        d=google.com; s=arc-20160816;
        b=cHQgjCnZRqz7WYrcs9/twBZLtX7dd2erj9V3EVYeWIOUWqxXhr/vQRoIogik6gfeqy
         9K/ZanDYNvvJ7fdPRg1VZPVVkePEid/FHvcAXsrhnePseXWAl3xFEC7gq8e6G5PTKutY
         F0xreF2X/mglzdbTpKrAf5gaNHlBAbY7z5886B6ZqMh6Vuvs97yKYRy5dZM3r4VyPO4F
         3qWXkC3Shw0oy/jgZqjrHsQ6cXLcJzPjycmyKUR6fOmkDBOYQwRkP7PlsNRpLppbDxxO
         mebgNcFHK4clPbmtLdQ/0YobGV1BgviMklKA5HA5oEX7kw9E/NERd6r2hY8mLABt6q1c
         ZILg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=pxbR2tROxGdscNPq0FHUMQrz/OcrNWf6ZKt9Si6kHuk=;
        b=hQfALXZcf/5dZUUhBzwDel1XZIUVCsbap1kMPtwK69Dp3RcTEwAYO6H9hS5EDf+6aP
         CNZCIPHCFl52/3i79yAg+MH0+pIVfEFKmm7ML2uJamRBfLMs9zf4XkSH6c9KlFN3+sLc
         ovDHqErA9cZtJIvMJxtRrNCVDb1vfYaH5gh2j3+kYLQPwwbq/Xi7GQau26C78U2D9++O
         J66jKQpTtp4n4ZzgFmxCw+UM4/kElIJn/l2kmD9SCbQxGu4dNAhO7ak55TbzO+MH4Lzm
         8oU0B434vpGfztX5Ythu8N9N/++BH3H5K6f4grNEitI2ecAH/VVcKncwWBCbOsmSx26P
         9KsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id g16si29623972pfo.191.2019.05.22.19.27.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 19:28:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R721e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07417;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TSQws5W_1558578458;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TSQws5W_1558578458)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 23 May 2019 10:27:45 +0800
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
Subject: [v4 PATCH 2/2] mm: vmscan: correct some vmscan counters for THP swapout
Date: Thu, 23 May 2019 10:27:38 +0800
Message-Id: <1558578458-83807-2-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1558578458-83807-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1558578458-83807-1-git-send-email-yang.shi@linux.alibaba.com>
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
v4: Fixed the comments from Johannes and Huang Ying
v3: Removed Shakeel's Reviewed-by since the patch has been changed significantly
    Switched back to use compound_order per Matthew
    Fixed more counters per Johannes
v2: Added Shakeel's Reviewed-by
    Use hpage_nr_pages instead of compound_order per Huang Ying and William Kucharski

 mm/vmscan.c | 34 ++++++++++++++++++++++------------
 1 file changed, 22 insertions(+), 12 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b65bc50..1b35a7a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1118,6 +1118,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		int may_enter_fs;
 		enum page_references references = PAGEREF_RECLAIM_CLEAN;
 		bool dirty, writeback;
+		unsigned int nr_pages;
 
 		cond_resched();
 
@@ -1129,7 +1130,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 		VM_BUG_ON_PAGE(PageActive(page), page);
 
-		sc->nr_scanned++;
+		/* Account the number of base pages evne though THP */
+		nr_pages = 1 << compound_order(page);
+		sc->nr_scanned += nr_pages;
 
 		if (unlikely(!page_evictable(page)))
 			goto activate_locked;
@@ -1250,7 +1253,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		case PAGEREF_ACTIVATE:
 			goto activate_locked;
 		case PAGEREF_KEEP:
-			stat->nr_ref_keep++;
+			stat->nr_ref_keep += nr_pages;
 			goto keep_locked;
 		case PAGEREF_RECLAIM:
 		case PAGEREF_RECLAIM_CLEAN:
@@ -1315,7 +1318,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			if (unlikely(PageTransHuge(page)))
 				flags |= TTU_SPLIT_HUGE_PMD;
 			if (!try_to_unmap(page, flags)) {
-				stat->nr_unmap_fail++;
+				stat->nr_unmap_fail += nr_pages;
 				goto activate_locked;
 			}
 		}
@@ -1442,7 +1445,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
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
@@ -1464,7 +1471,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (!PageMlocked(page)) {
 			int type = page_is_file_cache(page);
 			SetPageActive(page);
-			pgactivate++;
 			stat->nr_activate[type] += hpage_nr_pages(page);
 			count_memcg_page_event(page, PGACTIVATE);
 		}
@@ -1475,6 +1481,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page), page);
 	}
 
+	pgactivate = stat->nr_activate[0] + stat->nr_activate[1];
+
 	mem_cgroup_uncharge_list(&free_pages);
 	try_to_unmap_flush();
 	free_unref_page_list(&free_pages);
@@ -1642,14 +1650,14 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	unsigned long nr_zone_taken[MAX_NR_ZONES] = { 0 };
 	unsigned long nr_skipped[MAX_NR_ZONES] = { 0, };
 	unsigned long skipped = 0;
-	unsigned long scan, total_scan, nr_pages;
+	unsigned long scan, total_scan;
+	unsigned long nr_pages;
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
@@ -1657,9 +1665,12 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
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
 
@@ -1669,10 +1680,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		 * ineligible pages.  This causes the VM to not reclaim any
 		 * pages, triggering a premature OOM.
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

