Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 113D9C31E47
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 12:06:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9EE1521841
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 12:06:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9EE1521841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 32F3E6B0003; Sat, 15 Jun 2019 08:06:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DFD16B0005; Sat, 15 Jun 2019 08:06:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1CF1D8E0001; Sat, 15 Jun 2019 08:06:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id D81116B0003
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 08:06:54 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id y187so3866556pgd.1
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 05:06:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=wSfk/dAHP0g3DHifocZiUILnLw3vQfT3d4H9SU6yuqc=;
        b=nsldOqSDkciEE9cXbHFuronKzpa0MZjhTwh14OoSGigGC4k6/HOni1XFCciPRd8ASt
         cOZR8TR8LxBafw/tgdm4Owb6mlpcc4RfRSJsNzEhOd9yN0cz+zsKyXSmJQ7sey3LwSiq
         eDPonR6d+LvOscJwu1AenIy2Dks0kO+espFfcEv6FfHV4cLnneW3zDaS1lldF6DF26E/
         5SCXOoy/bpQgL5071/OlPVmrJ5fgSg4SQ4TN1brWcfSlLFaysYwNOn5SduPFWnlaZrA1
         5OUUgW7L5UHA9Yw3C3yerVZhqB1IJbx/bv7anYTI9BGma4/YlbhvQRxuW2gP+0HZ8LXw
         tW7g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of xlpang@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=xlpang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUx4RHFDvBdxMd6q5h7VojQGzjwuINYLZdJYA7gJszwaZPJZx0d
	NycGvGMVr/PzHyVkUvy2t6D3LD3ksarqadxXvAD8BNfvOxBBrWwwsaMP/tBk/VnOIC6xl2x0w0l
	hG9ov6mlD6SAbm+croDtcl8VTccxo97fgNASii00Ahch2H0HYS3eueGzeFFtIGkJGvg==
X-Received: by 2002:a17:902:8b88:: with SMTP id ay8mr32349096plb.139.1560600414523;
        Sat, 15 Jun 2019 05:06:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwHqgAr8cPSJEWK1lVGfS8mEwJ4jKhRWWobay2H5vDBIPHnMCefIiwn0dKYAA2IOnRRpZfs
X-Received: by 2002:a17:902:8b88:: with SMTP id ay8mr32348995plb.139.1560600413196;
        Sat, 15 Jun 2019 05:06:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560600413; cv=none;
        d=google.com; s=arc-20160816;
        b=D00a5oTm2yclD7NM6/l0HNZ00CKtd25GTCTk7xj6JZ3UChl4fYuL3Vy7rYgzL8QKB7
         ENlBDSMdQavwqswhhxRLu7Cyn0Kh69o4xHS49maONYxlzvqypB4HP33f0w+LJ3RduqlK
         Xsvq1Ma0i3VzcQJchYMnKjXJYO3ZMBM7MdlLu72J8n8wbLMSlu9ez/Fzxcp1OIUT7hBY
         zv0emBZj7iu7Ya/crErkudtEmFFkH3WfA7dZT6GzPfgzURDJrWxYHtr2W2AS160FisCq
         dQdY6bTNRqES/0oR0soaXve9vlMWKdh1gGAcheIxZChqTcXiiJLvIaDoL13mkktn1eOn
         jgLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=wSfk/dAHP0g3DHifocZiUILnLw3vQfT3d4H9SU6yuqc=;
        b=lf7uH5ceJu+gNRU8cGWsBfCrVByCyP/KYOx2BzYMdi4DFu2ChjRXRFWsVIIqw6Y2hU
         MHXbO9Ovv1kPS5NqvBHtWBHtnkHy99KcrxGTHOnvBrNRiAilpbHdiog08/clIUlKbhd7
         EPfNDSQnyEgFqjMIXwTr6ZkilUVXKMHt+uDXpyS3eRWzZzbLekj+/M7mzwIRqhuLnorg
         425e2q+OilOudAbhlZ7BcC3nrNI1gwLr/VYDRdO41UPd0b2o4lf2FbsIyzIeke2NMqGd
         F0qtxCqO0ftY8tyVN9UF0kzr5TZSth10rSNSqlZ1GGnnUtSv8lE7N8E69VsaNUBFLpGJ
         lCRg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of xlpang@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=xlpang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-56.freemail.mail.aliyun.com (out30-56.freemail.mail.aliyun.com. [115.124.30.56])
        by mx.google.com with ESMTPS id w8si5048533pgr.258.2019.06.15.05.06.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jun 2019 05:06:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of xlpang@linux.alibaba.com designates 115.124.30.56 as permitted sender) client-ip=115.124.30.56;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of xlpang@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=xlpang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R171e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=xlpang@linux.alibaba.com;NM=1;PH=DS;RN=5;SR=0;TI=SMTPD_---0TUEbRAF_1560600404;
Received: from localhost(mailfrom:xlpang@linux.alibaba.com fp:SMTPD_---0TUEbRAF_1560600404)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 15 Jun 2019 20:06:50 +0800
From: Xunlei Pang <xlpang@linux.alibaba.com>
To: Roman Gushchin <guro@fb.com>,
	Michal Hocko <mhocko@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH] psi: Don't account force reclaim as memory pressure
Date: Sat, 15 Jun 2019 20:06:44 +0800
Message-Id: <20190615120644.26743-1-xlpang@linux.alibaba.com>
X-Mailer: git-send-email 2.14.4.44.g2045bb6
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There're several cases like resize and force_empty that don't
need to account to psi, otherwise is misleading.

We also have a module reclaiming dying memcgs at background to
avoid too many dead memcgs which can cause lots of trouble, then
it makes the psi inaccuracy even worse without this patch.

Signed-off-by: Xunlei Pang <xlpang@linux.alibaba.com>
---
 include/linux/swap.h |  3 ++-
 mm/memcontrol.c      | 13 +++++++------
 mm/vmscan.c          |  9 ++++++---
 3 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 4bfb5c4ac108..74b5443877d4 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -354,7 +354,8 @@ extern int __isolate_lru_page(struct page *page, isolate_mode_t mode);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 						  unsigned long nr_pages,
 						  gfp_t gfp_mask,
-						  bool may_swap);
+						  bool may_swap,
+						  bool force_reclaim);
 extern unsigned long mem_cgroup_shrink_node(struct mem_cgroup *mem,
 						gfp_t gfp_mask, bool noswap,
 						pg_data_t *pgdat,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f1dfa651f55d..f4ec57876ada 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2237,7 +2237,8 @@ static void reclaim_high(struct mem_cgroup *memcg,
 		if (page_counter_read(&memcg->memory) <= memcg->high)
 			continue;
 		memcg_memory_event(memcg, MEMCG_HIGH);
-		try_to_free_mem_cgroup_pages(memcg, nr_pages, gfp_mask, true);
+		try_to_free_mem_cgroup_pages(memcg, nr_pages,
+				gfp_mask, true, false);
 	} while ((memcg = parent_mem_cgroup(memcg)));
 }
 
@@ -2330,7 +2331,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	memcg_memory_event(mem_over_limit, MEMCG_MAX);
 
 	nr_reclaimed = try_to_free_mem_cgroup_pages(mem_over_limit, nr_pages,
-						    gfp_mask, may_swap);
+					 gfp_mask, may_swap, false);
 
 	if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
 		goto retry;
@@ -2860,7 +2861,7 @@ static int mem_cgroup_resize_max(struct mem_cgroup *memcg,
 		}
 
 		if (!try_to_free_mem_cgroup_pages(memcg, 1,
-					GFP_KERNEL, !memsw)) {
+					GFP_KERNEL, !memsw, true)) {
 			ret = -EBUSY;
 			break;
 		}
@@ -2993,7 +2994,7 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
 			return -EINTR;
 
 		progress = try_to_free_mem_cgroup_pages(memcg, 1,
-							GFP_KERNEL, true);
+							GFP_KERNEL, true, true);
 		if (!progress) {
 			nr_retries--;
 			/* maybe some writeback is necessary */
@@ -5549,7 +5550,7 @@ static ssize_t memory_high_write(struct kernfs_open_file *of,
 	nr_pages = page_counter_read(&memcg->memory);
 	if (nr_pages > high)
 		try_to_free_mem_cgroup_pages(memcg, nr_pages - high,
-					     GFP_KERNEL, true);
+					     GFP_KERNEL, true, true);
 
 	memcg_wb_domain_size_changed(memcg);
 	return nbytes;
@@ -5596,7 +5597,7 @@ static ssize_t memory_max_write(struct kernfs_open_file *of,
 
 		if (nr_reclaims) {
 			if (!try_to_free_mem_cgroup_pages(memcg, nr_pages - max,
-							  GFP_KERNEL, true))
+						GFP_KERNEL, true, true))
 				nr_reclaims--;
 			continue;
 		}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7acd0afdfc2a..3831848fca5a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3212,7 +3212,8 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
 unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 					   unsigned long nr_pages,
 					   gfp_t gfp_mask,
-					   bool may_swap)
+					   bool may_swap,
+					   bool force_reclaim)
 {
 	struct zonelist *zonelist;
 	unsigned long nr_reclaimed;
@@ -3243,13 +3244,15 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 
 	trace_mm_vmscan_memcg_reclaim_begin(0, sc.gfp_mask);
 
-	psi_memstall_enter(&pflags);
+	if (!force_reclaim)
+		psi_memstall_enter(&pflags);
 	noreclaim_flag = memalloc_noreclaim_save();
 
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
 
 	memalloc_noreclaim_restore(noreclaim_flag);
-	psi_memstall_leave(&pflags);
+	if (!force_reclaim)
+		psi_memstall_leave(&pflags);
 
 	trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
 
-- 
2.14.4.44.g2045bb6

