Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8377FC282DA
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 05:28:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F57120863
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 05:28:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F57120863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E44CA8E0005; Fri,  1 Feb 2019 00:28:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF4638E0001; Fri,  1 Feb 2019 00:28:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE5918E0005; Fri,  1 Feb 2019 00:28:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8EC578E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 00:28:07 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id 12so4224722plb.18
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 21:28:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=203f4hHw7wpu5c0wkT/XNvZ8JNYa2RhshYOJCFq6V7M=;
        b=UkfVrmDb65zpC3YSH4s/LzBjJMtBaeehwbU8XpoU/esZW8IhO5Xmrx6a/jDe6ajjMq
         r5i6el0Y5riPzlzMQK8dFJPCtq/aQ0CsupimC9ts+KBmoNt1a3PrOl/6G+ksp3yzZTtk
         hKkoZOiTzHJHQfDJPPWg0Cex2wMLvlBnygVWAvC0RCvwl0lYXl5IOszYRhzqyB9diJ2i
         YoyC8fdSLqHMYdRxntJLzpE/Jw7AqHhehHh6Uvt3hjzxHu9gzp+NlBx4GsQ+QKPueESm
         q3JyxcWFgMYFufMGzcjIdpgKKmwHCSdmQmsb0Rrz/qL5ffh3VQ4wcbKuvh/dGOwirJpK
         ivMQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukd+xB2JA/ZEh3dTEs2S8BKo7d6n7IBJSDgxjqlxxcLhLN6t8pcj
	SJm2VI3lfsSBJLonfFFrFTB6KzJHtrc5ol0g3J6jAfDoQXqhTd7MR+emzIynu6j5wJ7Dvlzj13g
	NRfIObMScheR8OaYpNA4sG/tvRAOzVXw2yzh4tJM2ZAuLFEeyLpzMgfSFWJ8hm+7vKg==
X-Received: by 2002:a62:ca05:: with SMTP id n5mr37992805pfg.154.1548998887245;
        Thu, 31 Jan 2019 21:28:07 -0800 (PST)
X-Google-Smtp-Source: ALg8bN72/qxRdPa98A9wiszHr/CH6NEuKKF+X2SqoR2oMFkVtQ0l2XR92YYsxEsueIn9/cl1JhGU
X-Received: by 2002:a62:ca05:: with SMTP id n5mr37992767pfg.154.1548998886334;
        Thu, 31 Jan 2019 21:28:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548998886; cv=none;
        d=google.com; s=arc-20160816;
        b=V40arGupyTT0hVmCq+pQ/6+/QOp1bqOuPhuBO0Z3QMm4/3YRuAK3LlDtd3YgxmsBji
         N5FNZiZTj7qcD1bvSpNT/aywRgXLZ5mY36k/jadqbrvapYyY8qcl5VFrykkcmGdgMr8S
         tlpqvm1h9icCXbeL7P/CBo1gZMEefpajwrgzVJjM18HG1e3x8PQj3ooq3hi1+wkAP2Gm
         fuAmltGJEWbXkmSUQdZrO0bPRyiCKdU9S2j7MVzW1dQp47g0gRJxuj6DxVaUjhsdzB1h
         0kxDxvO8PjI87jHjNfWuu9WeaApSGo18FuADwd1zHzk/zWJudv9ZFLnYgW2fW9dCC6My
         4k/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=203f4hHw7wpu5c0wkT/XNvZ8JNYa2RhshYOJCFq6V7M=;
        b=vpLKQSCaVWMAug/1GVbjeVwsx+DPgWT7BfM66yVqb3+6EZxuH6ogfJ8SQouBV+LaVT
         AlrSu7Xl7C3R/E1ZrW6vpMJsNqAIRAFzNUjfHwyt4t9YAV6VowvJBS9B1JKzwViW6Z4m
         T9nZPODwhXdvYXxx29UFkO1/KJXeg6jxtsy75po1R9/TdWfbGzCazSoTLGYvPnM5PLMK
         KrXkgYRDPO313dYVFlmiwmlWG4wVvEte7tldzNOuJ5ZVY3WhOZCUjIMC4fEOMwurr822
         BD1n16GMgz7vMMVBtVdpuT0xb9ByDqNyQl+s55MnCwljkBFu5iaZyVXJjj6g6oLGs9kp
         AvMw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id m10si6191393plt.295.2019.01.31.21.28.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 21:28:06 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 31 Jan 2019 21:28:05 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,547,1539673200"; 
   d="scan'208";a="114410573"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga008.jf.intel.com with ESMTP; 31 Jan 2019 21:28:05 -0800
Subject: [PATCH v10 3/3] mm: Maintain randomization of page free lists
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>,
 Kees Cook <keescook@chromium.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, keith.busch@intel.com
Date: Thu, 31 Jan 2019 21:15:27 -0800
Message-ID: <154899812788.3165233.9066631950746578517.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <154899811208.3165233.17623209031065121886.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <154899811208.3165233.17623209031065121886.stgit@dwillia2-desk3.amr.corp.intel.com>
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
 include/linux/mmzone.h |   12 ++++++++++++
 mm/page_alloc.c        |   11 +++++++++--
 mm/shuffle.c           |   23 +++++++++++++++++++++++
 mm/shuffle.h           |   12 ++++++++++++
 4 files changed, 56 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 2274e43933ae..a3cb9a21196d 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -116,6 +116,18 @@ static inline void add_to_free_area_tail(struct page *page, struct free_area *ar
 	area->nr_free++;
 }
 
+#ifdef CONFIG_SHUFFLE_PAGE_ALLOCATOR
+/* Used to preserve page allocation order entropy */
+void add_to_free_area_random(struct page *page, struct free_area *area,
+		int migratetype);
+#else
+static inline void add_to_free_area_random(struct page *page,
+		struct free_area *area, int migratetype)
+{
+	add_to_free_area(page, area, migratetype);
+}
+#endif
+
 /* Used for pages which are on another list */
 static inline void move_to_free_area(struct page *page, struct free_area *area,
 			     int migratetype)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3fd0df403766..2a0969e3b0eb 100644
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
index 8badf4f0a852..19bbf3e37fb6 100644
--- a/mm/shuffle.c
+++ b/mm/shuffle.c
@@ -168,3 +168,26 @@ void __meminit __shuffle_free_memory(pg_data_t *pgdat)
 	for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
 		shuffle_zone(z);
 }
+
+void add_to_free_area_random(struct page *page, struct free_area *area,
+		int migratetype)
+{
+	static u64 rand;
+	static u8 rand_bits;
+
+	/*
+	 * The lack of locking is deliberate. If 2 threads race to
+	 * update the rand state it just adds to the entropy.
+	 */
+	if (rand_bits == 0) {
+		rand_bits = 64;
+		rand = get_random_u64();
+	}
+
+	if (rand & 1)
+		add_to_free_area(page, area, migratetype);
+	else
+		add_to_free_area_tail(page, area, migratetype);
+	rand_bits--;
+	rand >>= 1;
+}
diff --git a/mm/shuffle.h b/mm/shuffle.h
index 644c8ee97b9e..fc1e327ae22d 100644
--- a/mm/shuffle.h
+++ b/mm/shuffle.h
@@ -36,6 +36,13 @@ static inline void shuffle_zone(struct zone *z)
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
@@ -48,5 +55,10 @@ static inline void shuffle_zone(struct zone *z)
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

