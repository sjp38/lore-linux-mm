Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65F90C04E84
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 06:44:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C5F6208C3
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 06:44:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C5F6208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A304A6B0276; Tue, 28 May 2019 02:44:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BAB06B0278; Tue, 28 May 2019 02:44:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 85BBD6B0279; Tue, 28 May 2019 02:44:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4613E6B0278
	for <linux-mm@kvack.org>; Tue, 28 May 2019 02:44:45 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id m12so12732611pls.10
        for <linux-mm@kvack.org>; Mon, 27 May 2019 23:44:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=EL7P546aVIksJ5tzeHB6AZyhk0YYLiggkcui+umZJwQ=;
        b=oaULJNAQI5H6CpNEujtczMSbbHUbbe9f2193wLRQGvhD8sQtCy0qAwhnx3MGv9srqq
         568kD5OVywx+vXXEviWjPcPCpeKV05pUzvK52iNT2Na/768Mu4uqGTZY0Vapi9yu1NsY
         SOukMfW/sWkXeROFbYT+XrWXCe0wWo5i3bXHHjL0mPXpexo95IQCRZVD/IXXeb+/B5C8
         rgR/Y432+FUvRDoPG+HWCYM4vZe+M05Eo9ZgZawS29tMF0Q2RhfJHsfR3e/fHnIPRsmc
         OFbqK/DHcaRXsij1HgkYESPwmVFZi+z15RqfsrVt1Fz7864WzsgIzbLLu1owyFYm4sVs
         EFGg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVuS3im6qAAbI0ydA2azJjGm3P9QH9oW46mV5sgeB7in4sQ+lMd
	u5FvrWleU+ndVInKBN7INNbmLaVzC0mS7VRx54v9KI7jeKCQA3/XBqlrZYLVy+GGnJt9xiSqPte
	SzXYcputhcwLeZQXDtT7rD3GSj6QEnxmI7yPG/VXD+sHIn1bFPYG30K/dA26oAT11Aw==
X-Received: by 2002:a17:902:2d:: with SMTP id 42mr134078310pla.34.1559025884899;
        Mon, 27 May 2019 23:44:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVqbpX9GYqPj9sNblGkx/XXFKBVrSwQVp0IfALmkNFELSV60qWZ4Y9d0jWPF8VAH3gwG9Y
X-Received: by 2002:a17:902:2d:: with SMTP id 42mr134078216pla.34.1559025883377;
        Mon, 27 May 2019 23:44:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559025883; cv=none;
        d=google.com; s=arc-20160816;
        b=RCCfgoH+WgMvu/iD9GoDnOxQPz/VM6WbMJ9hTtkTzDCWX/vRg9VG8p1QEQvQU9dlZ6
         hlQLpfHoorfTCyl6A4MIn918QBb44Gh3rVJEstRBt5OgS+Enj0alSoDq120P4MhBs0uC
         cCN6j/a9JEgZ7lM9wvnrwzzZKlBdzhAP2JzMlqxfXdaSjHosmXbozYxhlwmmzund3X4A
         Z+eM9/nrpuGjHfCG5Pdeo5ObfziEd38Kc+GiaaYOwITz9zeJt4XfkvNmFLS7wmggT/wj
         Pl/WjS2apczhHPnAq2QwwxgLtyPwGnEhbKSSGlt8wHFT94+LPdJg986Ndr8MIgGB1xc2
         CqBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=EL7P546aVIksJ5tzeHB6AZyhk0YYLiggkcui+umZJwQ=;
        b=nAYUOE/ylGMSBlTIePEYrl37I0xCY4eDMKKqFq3FRuY+UO9Ncr1j+ejKeV0L3mgF0L
         r7ZgC2lDzBeGPwZtqWSxiO2sBOm9O94YLGBj/UZxh1uSjPdyCAwhCo8qLifSr2aB9Hu7
         fo5qEBaqn3Zop4datDpt46wJjIJ9lD1TVAap+dhqmlgjwDZdnAYPqDHhnRRTt4XUz0J+
         rkFb2j+spxppO4kbrc3E7Uwhih1Uv+FtWJReTlpQy0j8eoQKWdS+aAOcHx+rLJX8+csg
         XGHQyBWJbXFP6LQS9alzYP8ihHAIo8UAy/x697OsWniZq5HkX3eecQTeQudT3utlXOl6
         Jf5A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id q193si22898897pfq.95.2019.05.27.23.44.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 23:44:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R231e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04395;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TSrpwyt_1559025859;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TSrpwyt_1559025859)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 28 May 2019 14:44:28 +0800
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
Subject: [v7 PATCH 2/2] mm: vmscan: correct some vmscan counters for THP swapout
Date: Tue, 28 May 2019 14:44:19 +0800
Message-Id: <1559025859-72759-2-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1559025859-72759-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1559025859-72759-1-git-send-email-yang.shi@linux.alibaba.com>
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
v7: Fixed more incorrect account for split page per Huang Ying
v6: Fixed the other double account issue introduced by v5 per Huang Ying
v5: Fixed sc->nr_scanned double accounting per Huang Ying
    Added some comments to address the concern about premature OOM per Hillf Danton 
v4: Fixed the comments from Johannes and Huang Ying
v3: Removed Shakeel's Reviewed-by since the patch has been changed significantly
    Switched back to use compound_order per Matthew
    Fixed more counters per Johannes
v2: Added Shakeel's Reviewed-by
    Use hpage_nr_pages instead of compound_order per Huang Ying and William Kucharski

 mm/vmscan.c | 63 +++++++++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 49 insertions(+), 14 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b65bc50..58d8a8e 100644
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
@@ -1282,7 +1286,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				}
 				if (!add_to_swap(page)) {
 					if (!PageTransHuge(page))
-						goto activate_locked;
+						goto activate_locked_split;
 					/* Fallback to swap normal pages */
 					if (split_huge_page_to_list(page,
 								    page_list))
@@ -1291,7 +1295,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 					count_vm_event(THP_SWPOUT_FALLBACK);
 #endif
 					if (!add_to_swap(page))
-						goto activate_locked;
+						goto activate_locked_split;
 				}
 
 				may_enter_fs = 1;
@@ -1306,6 +1310,18 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		}
 
 		/*
+		 * THP may get split above, need minus tail pages and update
+		 * nr_pages to avoid accounting tail pages twice.
+		 *
+		 * The tail pages that are added into swap cache successfully
+		 * reach here.
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
@@ -1315,7 +1331,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			if (unlikely(PageTransHuge(page)))
 				flags |= TTU_SPLIT_HUGE_PMD;
 			if (!try_to_unmap(page, flags)) {
-				stat->nr_unmap_fail++;
+				stat->nr_unmap_fail += nr_pages;
 				goto activate_locked;
 			}
 		}
@@ -1442,7 +1458,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
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
@@ -1455,6 +1475,15 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			list_add(&page->lru, &free_pages);
 		continue;
 
+activate_locked_split:
+		/*
+		 * The tail pages that are failed to add into swap cache
+		 * reach here.  Fixup nr_scanned and nr_pages.
+		 */
+		if (nr_pages > 1) {
+			sc->nr_scanned -= (nr_pages - 1);
+			nr_pages = 1;
+		}
 activate_locked:
 		/* Not a candidate for swapping, so reclaim swap space. */
 		if (PageSwapCache(page) && (mem_cgroup_swap_full(page) ||
@@ -1464,8 +1493,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (!PageMlocked(page)) {
 			int type = page_is_file_cache(page);
 			SetPageActive(page);
-			pgactivate++;
-			stat->nr_activate[type] += hpage_nr_pages(page);
+			stat->nr_activate[type] += nr_pages;
 			count_memcg_page_event(page, PGACTIVATE);
 		}
 keep_locked:
@@ -1475,6 +1503,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page), page);
 	}
 
+	pgactivate = stat->nr_activate[0] + stat->nr_activate[1];
+
 	mem_cgroup_uncharge_list(&free_pages);
 	try_to_unmap_flush();
 	free_unref_page_list(&free_pages);
@@ -1646,10 +1676,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
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
@@ -1657,9 +1686,12 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
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
 
@@ -1668,11 +1700,14 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
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

