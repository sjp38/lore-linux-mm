Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 568D9C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 03:53:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D9BF2075C
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 03:53:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D9BF2075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 523D06B026C; Sun, 26 May 2019 23:53:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D33D6B026D; Sun, 26 May 2019 23:53:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3EA376B026E; Sun, 26 May 2019 23:53:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 071616B026C
	for <linux-mm@kvack.org>; Sun, 26 May 2019 23:53:08 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id m12so10400472pls.10
        for <linux-mm@kvack.org>; Sun, 26 May 2019 20:53:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=ceQb64fYqnp1CKDZEAMW2hLjug4FWMjmFiWgCbFK2pk=;
        b=EhNrPuutb7uhqu1t0xiWR6OjUSovyRfEKTDEPum6cgCT8jma0qON8RA8kq6tinznCE
         ZpMXyJFvE2XlISwL2FgUCq51831HjRMwGmgHI78roI85F1o5VHgMUJ+8h4QdSEfDKY0r
         F+E/PCVoGm1Dee+90WNSdtTXMsyO0CFcJFcGDy0CykFCKcxNxQR+3XzOw4/eC9vqmIxV
         62IBx8ncpAW0nualsCScPTUwIV1S84BIO7jF5RI5aUUu2wwT4U8t06SZH72B4C+XOF/t
         xuW35qfyD1uBEntoTdYvhTdvyXslmnQHv1SDuTDpyQB74Lnjdk/EuP4qv/b6rLtKvdSw
         D0rw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXbyqRn5GOANF8UbtpCL+vm4Tbn/drgkSM/yDALAC+9UIsZ+0QR
	LQVkBYO+b4Mz2lLImXbZ+y4dfPY//aL9qVpfpzPJ5SUUBxy2dxpmkpZ5sSFlvm2a37U3nIXNRvg
	Xz1wHuwAAKE2X+tfetfQTpSyZ4YhXBYoiEG8YeH7KwswJtB1eM/OoELAJLWr6ayzyaA==
X-Received: by 2002:a63:6848:: with SMTP id d69mr125779272pgc.0.1558929187631;
        Sun, 26 May 2019 20:53:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwt6GZx6zA3Bkq5XoqQiBwSSqXvXtBJv+2T1ymURibSfaqjtG9Pdew/67Svbt0rEG1wT5ll
X-Received: by 2002:a63:6848:: with SMTP id d69mr125779192pgc.0.1558929185927;
        Sun, 26 May 2019 20:53:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558929185; cv=none;
        d=google.com; s=arc-20160816;
        b=u2X9BLz0Uvx1k2OPQQmqHWUJFiqmP3cjAQis228T8JNIgApYbXgspKI7k0wsQDOLWI
         5/UrxMaVmtLl335r024gFzuqBVPGCpgRXth7aQWFakOpUROjQlYoKptJBDMr6wUsoLfr
         rTh7ENc4UOxRxX4KnoJXtxhx3AbSVr9zrMHkzhx56XSM239HrMJyjNRnzlYYQuLkPR2B
         lo2zhXQMezuznC7gNMoRIxPfzgRLlNmMiz52oayvwh8u1tL2Js0qyshZXq8iCweWByLa
         BJ6WuV96cqDsKo0SAhVRhFSGtZ3mxypRHkP/aaTy6ailf1+FLEhMi5PwMNh7VOBbRqQ6
         ff9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=ceQb64fYqnp1CKDZEAMW2hLjug4FWMjmFiWgCbFK2pk=;
        b=SdJNHIJKBRogeoa2hp6zA1igC7cKE8/EQrWtGy9MQFalpzJF18WpZq9VsY1ByDh7oo
         3P7L+quOFOO+ZugbvqefhjLvzgZ/tuO/WewfiBcsS0nbS4/RAvxWv97PzYfEAKw2uWqp
         YF+nHgGxeixt9hiRsIy0CKFhJndE/SpJpi0Z3UToO8Zio48i4tRVBKh8VrbIri/hNpY5
         6AL9ZkY5X103zb7oibkt2XQBvZoTCD90K/S1/TpW7v8YCD6B1IDlm8VKi/ElvDgabUhc
         JFe022iPDO8zvL+FyPW64kuo1ZkHTBvtzJ9W9zEo30UTGUdUkbH+7v9eSAmETHXTIDFj
         kV1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-57.freemail.mail.aliyun.com (out30-57.freemail.mail.aliyun.com. [115.124.30.57])
        by mx.google.com with ESMTPS id x32si17946705pld.190.2019.05.26.20.53.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 May 2019 20:53:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) client-ip=115.124.30.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04400;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TSm38VC_1558929166;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TSm38VC_1558929166)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 27 May 2019 11:53:03 +0800
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
Subject: [v6 PATCH 2/2] mm: vmscan: correct some vmscan counters for THP swapout
Date: Mon, 27 May 2019 11:52:46 +0800
Message-Id: <1558929166-3363-2-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1558929166-3363-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1558929166-3363-1-git-send-email-yang.shi@linux.alibaba.com>
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
Cc: Hillf Danton <hdanton@sina.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
v6: Fixed the other double account issue introduced by v5 per Huang Ying
v5: Fixed sc->nr_scanned double accounting per Huang Ying
    Added some comments to address the concern about premature OOM per Hillf Danton 
v4: Fixed the comments from Johannes and Huang Ying
v3: Removed Shakeel's Reviewed-by since the patch has been changed significantly
    Switched back to use compound_order per Matthew
    Fixed more counters per Johannes
v2: Added Shakeel's Reviewed-by
    Use hpage_nr_pages instead of compound_order per Huang Ying and William Kucharski

 mm/vmscan.c | 47 +++++++++++++++++++++++++++++++++++------------
 1 file changed, 35 insertions(+), 12 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b65bc50..378edff 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1118,6 +1118,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		int may_enter_fs;
 		enum page_references references = PAGEREF_RECLAIM_CLEAN;
 		bool dirty, writeback;
+		unsigned int nr_pages;
 
 		cond_resched();
 
@@ -1129,7 +1130,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 		VM_BUG_ON_PAGE(PageActive(page), page);
 
-		sc->nr_scanned++;
+		nr_pages = 1 << compound_order(page);
+
+		/* Account the number of base pages even though THP */
+		sc->nr_scanned += nr_pages;
 
 		if (unlikely(!page_evictable(page)))
 			goto activate_locked;
@@ -1250,7 +1254,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		case PAGEREF_ACTIVATE:
 			goto activate_locked;
 		case PAGEREF_KEEP:
-			stat->nr_ref_keep++;
+			stat->nr_ref_keep += nr_pages;
 			goto keep_locked;
 		case PAGEREF_RECLAIM:
 		case PAGEREF_RECLAIM_CLEAN:
@@ -1306,6 +1310,15 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		}
 
 		/*
+		 * THP may get split above, need minus tail pages and update
+		 * nr_pages to avoid accounting tail pages twice.
+		 */
+		if ((nr_pages > 1) && !PageTransHuge(page)) {
+			sc->nr_scanned -= (nr_pages - 1);
+			nr_pages = 1;
+		}
+
+		/*
 		 * The page is mapped into the page tables of one or more
 		 * processes. Try to unmap it here.
 		 */
@@ -1315,7 +1328,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			if (unlikely(PageTransHuge(page)))
 				flags |= TTU_SPLIT_HUGE_PMD;
 			if (!try_to_unmap(page, flags)) {
-				stat->nr_unmap_fail++;
+				stat->nr_unmap_fail += nr_pages;
 				goto activate_locked;
 			}
 		}
@@ -1442,7 +1455,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 		unlock_page(page);
 free_it:
-		nr_reclaimed++;
+		/*
+		 * THP may get swapped out in a whole, need account
+		 * all base pages.
+		 */
+		nr_reclaimed += nr_pages;
 
 		/*
 		 * Is there need to periodically free_page_list? It would
@@ -1464,8 +1481,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (!PageMlocked(page)) {
 			int type = page_is_file_cache(page);
 			SetPageActive(page);
-			pgactivate++;
-			stat->nr_activate[type] += hpage_nr_pages(page);
+			stat->nr_activate[type] += nr_pages;
 			count_memcg_page_event(page, PGACTIVATE);
 		}
 keep_locked:
@@ -1475,6 +1491,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page), page);
 	}
 
+	pgactivate = stat->nr_activate[0] + stat->nr_activate[1];
+
 	mem_cgroup_uncharge_list(&free_pages);
 	try_to_unmap_flush();
 	free_unref_page_list(&free_pages);
@@ -1646,10 +1664,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
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
@@ -1657,9 +1674,12 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
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
 
@@ -1668,11 +1688,14 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
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

