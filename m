Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89DB6C282D4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 05:15:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47D3620989
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 05:15:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47D3620989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E33B08E0005; Wed, 30 Jan 2019 00:15:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE3C28E0001; Wed, 30 Jan 2019 00:15:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C86578E0005; Wed, 30 Jan 2019 00:15:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7CA0F8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 00:15:05 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id q63so18833087pfi.19
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 21:15:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=pMbNAOrG9Rn5SbMTkVjrrJ/u1178nfcMHqo1RcWbs4w=;
        b=jSCH+qy1xHY9Y6nNM/JLXKxixSg+QD84Q1W5r5C9l/7BuD5DZc7uuxr4GkOpYcLiRY
         zPr0SqV0mwQoHrsQ4rfkgn7FUBT+1M/5npv2jOycJfSsDS75K5HUU+K6iNeg9+aiEP/v
         Il8umJ2LgJMRu4IyRp4HC9rc9SwbVol2w6FiTC68EtRsefQtQE0KezG3annSDKaRJSDH
         qrTTCZY5WwOhOeDKW8MwBAoTGhYVXul/DOKwnIe9eCw35+2l+VV6jpAv0+4vo82fUSx8
         mlAP3sj1UHuNQO5Gd/ZpfFYwWrK2bNab+9wCt4EuYRq8EZarTI0iptd2smnQbeLq8Q66
         H15w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUuke25OnJ+PDAZFlhmLrCShjti8YZhLVuma2JlqvhFPNkN60ay6ch
	dlemubB3t9pSIHox6Iyo7wuiqqSUFR/72KbEfaXUMEBXTyJm1FpUUevrDxFwm/dn2zqk7LMFNRt
	17ijezZTmYmRkJotII2XlNqtRXlyxDaOSFVW77cGxWU9L8mCwtvVHIjC0JcYUxXz05A==
X-Received: by 2002:a17:902:7402:: with SMTP id g2mr28175247pll.198.1548825305048;
        Tue, 29 Jan 2019 21:15:05 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5x5jzuxro4IXJ5GtjWMlBAN6FRjpWXWywZXhJ9UIlxHIxkrlqyCU24tK/p3u0/KiTLzFiK
X-Received: by 2002:a17:902:7402:: with SMTP id g2mr28175201pll.198.1548825304257;
        Tue, 29 Jan 2019 21:15:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548825304; cv=none;
        d=google.com; s=arc-20160816;
        b=K7c4xzqUDrwX8a6tqBx9NyTht7qN7U64xmF3e/XvI7Fybe4IYkyAGfPWd5MNEbZSXl
         1TjWclMcG78WpLQ5RAHiEyQdvsJ/BJrAHBwn/NQv3T0xTh4n8pYxkAzl5xVNU21NJS2h
         PnLetAyKMdxhuHQHHZsI2096KIG4VKvYmiZkPCmuLFMjv2fJU1C43CpU2pgaXPRtpfkw
         i0RAWa4yOBiBcMLrBbFNdVJ8WFHMyne+aPcoA2PBvroGWXv/NMeqY0+FV0iloFommoxq
         CX3nwhrvX3rZ7jxS+K3oj48C+64Ne/Leu9Yh2IsvBEk7wOk+CzT9d6pkd8HVVMCHcW1k
         ZNTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=pMbNAOrG9Rn5SbMTkVjrrJ/u1178nfcMHqo1RcWbs4w=;
        b=ZBhPgoK+KvSXVvItHEqr8CU+vzRmWDSF3K2GiLtUfU/KuIWGPaI8y97fJQi/maeKCq
         /zY509N3ABeFOQfay7xgY271fUS0cQkdKEuhx2R8NrC/ZVy+RmUOV3hJZDB7VWFcvx9E
         P+8Rqf5X2xcesWDLRTIahkXiTNcxK4Ex+M+bW6v5dTQqY5LZcGYRUY/Nt8/D2ZddI8Bb
         JnKe0vv+lm/cd45Qf0bvFSQCWnxWNEM2Nh09W4WHipT4S5oG7KEEyXkdJVaeHQ+5Lh1a
         gP3hBx/Zmir5Sget+dmSVnpIGQWxdU4TZYZYDDM2FemPnYUvplZXHxIbc+J5RvXDWqsW
         o8vg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id b3si533472pld.282.2019.01.29.21.15.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 21:15:04 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 29 Jan 2019 21:15:03 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,539,1539673200"; 
   d="scan'208";a="130031834"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga002.jf.intel.com with ESMTP; 29 Jan 2019 21:15:03 -0800
Subject: [PATCH v9 3/3] mm: Maintain randomization of page free lists
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>,
 Kees Cook <keescook@chromium.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Date: Tue, 29 Jan 2019 21:02:26 -0800
Message-ID: <154882454628.1338686.46582179767934746.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <154882453052.1338686.16411162273671426494.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <154882453052.1338686.16411162273671426494.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When freeing a page with an order >= shuffle_page_order randomly select
the front or back of the list for insertion.

While the mm tries to defragment physical pages into huge pages this can
tend to make the page allocator more predictable over time. Inject the
front-back randomness to preserve the initial randomness established by
shuffle_free_memory() when the kernel was booted.

The overhead of this manipulation is constrained by only being applied
for MAX_ORDER sized pages by default.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mmzone.h  |   12 ++++++++++++
 include/linux/shuffle.h |   12 ++++++++++++
 mm/page_alloc.c         |   11 +++++++++--
 mm/shuffle.c            |   16 ++++++++++++++++
 4 files changed, 49 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 6ab8b58c6481..d42aafe23045 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -98,6 +98,10 @@ extern int page_group_by_mobility_disabled;
 struct free_area {
 	struct list_head	free_list[MIGRATE_TYPES];
 	unsigned long		nr_free;
+#ifdef CONFIG_SHUFFLE_PAGE_ALLOCATOR
+	u64			rand;
+	u8			rand_bits;
+#endif
 };
 
 /* Used for pages not on another list */
@@ -116,6 +120,14 @@ static inline void add_to_free_area_tail(struct page *page, struct free_area *ar
 	area->nr_free++;
 }
 
+#ifdef CONFIG_SHUFFLE_PAGE_ALLOCATOR
+/* Used to preserve page allocation order entropy */
+void add_to_free_area_random(struct page *page, struct free_area *area,
+		int migratetype);
+#else
+#define add_to_free_area_random add_to_free_area
+#endif
+
 /* Used for pages which are on another list */
 static inline void move_to_free_area(struct page *page, struct free_area *area,
 			     int migratetype)
diff --git a/include/linux/shuffle.h b/include/linux/shuffle.h
index bed2d2901d13..649498442aa0 100644
--- a/include/linux/shuffle.h
+++ b/include/linux/shuffle.h
@@ -29,6 +29,13 @@ static inline void shuffle_zone(struct zone *z)
 		return;
 	__shuffle_zone(z);
 }
+
+static inline bool is_shuffle_order(int order)
+{
+	if (!static_branch_unlikely(&page_alloc_shuffle_key))
+                return false;
+	return order >= SHUFFLE_ORDER;
+}
 #else
 static inline void shuffle_free_memory(pg_data_t *pgdat)
 {
@@ -41,5 +48,10 @@ static inline void shuffle_zone(struct zone *z)
 static inline void page_alloc_shuffle(enum mm_shuffle_ctl ctl)
 {
 }
+
+static inline bool is_shuffle_order(int order)
+{
+	return false;
+}
 #endif
 #endif /* _MM_SHUFFLE_H */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1cb9a467e451..7895f8bd1a32 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -43,6 +43,7 @@
 #include <linux/mempolicy.h>
 #include <linux/memremap.h>
 #include <linux/stop_machine.h>
+#include <linux/random.h>
 #include <linux/sort.h>
 #include <linux/pfn.h>
 #include <linux/backing-dev.h>
@@ -889,7 +890,8 @@ static inline void __free_one_page(struct page *page,
 	 * so it's less likely to be used soon and more likely to be merged
 	 * as a higher order page
 	 */
-	if ((order < MAX_ORDER-2) && pfn_valid_within(buddy_pfn)) {
+	if ((order < MAX_ORDER-2) && pfn_valid_within(buddy_pfn)
+			&& !is_shuffle_order(order)) {
 		struct page *higher_page, *higher_buddy;
 		combined_pfn = buddy_pfn & pfn;
 		higher_page = page + (combined_pfn - pfn);
@@ -903,7 +905,12 @@ static inline void __free_one_page(struct page *page,
 		}
 	}
 
-	add_to_free_area(page, &zone->free_area[order], migratetype);
+	if (is_shuffle_order(order))
+		add_to_free_area_random(page, &zone->free_area[order],
+				migratetype);
+	else
+		add_to_free_area(page, &zone->free_area[order], migratetype);
+
 }
 
 /*
diff --git a/mm/shuffle.c b/mm/shuffle.c
index db517cdbaebe..0da7d1826c6a 100644
--- a/mm/shuffle.c
+++ b/mm/shuffle.c
@@ -186,3 +186,19 @@ void __meminit __shuffle_free_memory(pg_data_t *pgdat)
 	for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
 		shuffle_zone(z);
 }
+
+void add_to_free_area_random(struct page *page, struct free_area *area,
+		int migratetype)
+{
+	if (area->rand_bits == 0) {
+		area->rand_bits = 64;
+		area->rand = get_random_u64();
+	}
+
+	if (area->rand & 1)
+		add_to_free_area(page, area, migratetype);
+	else
+		add_to_free_area_tail(page, area, migratetype);
+	area->rand_bits--;
+	area->rand >>= 1;
+}

