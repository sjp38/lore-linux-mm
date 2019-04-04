Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96594C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:02:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3BD0420820
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:02:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="Yr+ax8/Q";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="oPEdqyfk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3BD0420820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D5EA6B027E; Wed,  3 Apr 2019 22:01:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 55ED36B0280; Wed,  3 Apr 2019 22:01:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 425026B0281; Wed,  3 Apr 2019 22:01:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1CE786B027E
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 22:01:59 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id 77so943687qkd.9
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 19:01:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=PhVR5Tm+hbp1uFSOwTqwsUckzcZYN8AfZd5SoP03jII=;
        b=LL2wR9rS2dvKE2nJtnOqy7aH32nf8xN7TJNPxJfKHsPk9RUUnTPd5EdCmN5UKJaee8
         qjjp6MQvH1udhttyqLUCn16Rfi+WClnYoNmKvCK/Vo3x1jyjlvLz/7wFSFupYXuXXwpo
         ENl3RsunBKweWm2Vl76QZeVMrIJdGeofegP4yIhOHNB2jMnX+Usm0HCUlP2vgXMM/tS6
         fmWIisP3+ARISD3iei2nFob4kg/BhN7y9mV1Gz1sLGf2JjRF4ayq+JHmG9Pb2gPmMasA
         6uYUwzK8ZLOeRml2zTW5znyuriu0KsT3y3DbeuRkBuVxZ0mJSpeb1nUweZVfaz/XI2r5
         CA0A==
X-Gm-Message-State: APjAAAWvdsFtgRyUgntvs7aarBVGGDLYx0XoW03D6VDAS942BO097C2t
	InP55NV4aEblP/LVQQN0dx1XbyA++7ma3asagRMkSeNLJlfCBEPF5jwhDDFGZCIOhpAdAqTUooh
	4QteudnVbYEaCPZIBtpGpwH8WAYX+JgqzBfs+dtQFyz6mEM195RbmhsllryWJwg4NjQ==
X-Received: by 2002:ac8:538c:: with SMTP id x12mr2947442qtp.238.1554343318865;
        Wed, 03 Apr 2019 19:01:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRcYlw5eso3XnHDPhE/wogvkXGUrPjD+8Ohri7ZyaD6OgFM7JExRCqJvx/5ddWKOSkiNUT
X-Received: by 2002:ac8:538c:: with SMTP id x12mr2947384qtp.238.1554343317667;
        Wed, 03 Apr 2019 19:01:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554343317; cv=none;
        d=google.com; s=arc-20160816;
        b=xyW7noPnmC7uTYfql5iePLdqY5Ps4k6oArcaQ+NkfZ6uCt0p88/hkzcZPCwWRsiQmO
         YsJEWjSP9RQ13k/QwTaAq1ybqfhEwdjBUQJ6HkRnZPD7bd7WwxSwhdHxQkWjm1bZcuvD
         sd2mtRTp0+7dDMk3pl44l6bvAfClJqEiVjA+JAHvSgLpH+/UPmqCZzF7Te+cJKZ0bbg5
         NZJxvXuM/dJVQuH4kvxiTRXxaHVBN+DjRYsy4HMA4ePrHaqvxM7ww5TDqlB31WQC7b98
         mJs3r7Kl87IwCoFgzoR+19A6TMNiwVxepJf2qPrabQ3eJkB8vFp/LEFF00o/e9O0+3nS
         AA0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=PhVR5Tm+hbp1uFSOwTqwsUckzcZYN8AfZd5SoP03jII=;
        b=GQ1boNG0nXiLqE4Q3cxdigM3z6jVumbOVUb67AIUE4wQY9H7xtPO5Opj0NmfpboIEL
         j1OF+hNGKDGDv9UVY06rsRY13yrrU1BLhYPcRRIz889bx7G2slhky2RcqbAzpPjKqOb0
         xebLdBHJHpGgOqc9RnCT3pEZe9Tx1mOLBFySp91dxEzJxNqFaNqNU7hjTmhcfzeR6OMl
         e3akvRz/epXERPxpsHBAT3jd54m1G5hx8oUaM/JqYNIFjhCc8dZPBHtUhA9NagMw83J9
         K3a+d31PdYtBKuuEz9whFKKcynTdkAVREALQctMUsbBeWIxz7j/eTOd7qPZ6er6zrOcf
         YFew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b="Yr+ax8/Q";
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=oPEdqyfk;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id b189si5280925qkd.230.2019.04.03.19.01.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 19:01:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) client-ip=66.111.4.29;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b="Yr+ax8/Q";
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=oPEdqyfk;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 5ADAD22A8A;
	Wed,  3 Apr 2019 22:01:57 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 22:01:57 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm3; bh=PhVR5Tm+hbp1u
	FSOwTqwsUckzcZYN8AfZd5SoP03jII=; b=Yr+ax8/QVYPA1+W4dwtnPPgONbRsx
	CoMF+dfi9QtEPs7g0RiLU0pk0iVzICDgXU+At416R46J4I7W0fTnatME4kl5KAbu
	zcy+cb/BVsz3H3kZbWWZ9WpsYqBgrPkJifyZQq0NQGJaBQTq1SzAFzQJurhA2+5y
	O0RrMVKSKeObFdnk6RqGNur+0U6DjptvN0jr9DJnVmwAYeD6I7g8JLUW3xD44aT5
	12e05CYeOXAtVaDMUatMFf/HENG9325wrtYwsBbHYhuCvNhDQbgpCq5MKFsEaW3Y
	kYc9owHk7glJtDNRiJDtGpilgFsbr6V8Jjj0cVWjKi4ce6Ts0Y9CHQqfw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=PhVR5Tm+hbp1uFSOwTqwsUckzcZYN8AfZd5SoP03jII=; b=oPEdqyfk
	qmB60PvsJ01YVyhW1msq2+79MMbiCd+DOqBpEd4/V4c2ONuYgW8GsXHZakCoiao4
	l9yLhOoKXJo2VL4oM/S0YbHmTJM42epHCIKJOjcH/Yu3ZtWB5es5DBgjHD7aQ9Sy
	L7TeL0RCElkGYeWslFraN4QHcpPQGbWYR3JKuX/aSnyuc9GHH35RhRI7T3zGOGzd
	9sPWcZXsZSAorFAWcUJ77jbioPTPHHMWFXrscP2Ux0wZzw/nKDPs5p1J0vPXyv5D
	R9pGXdzYZB3ZKXBR+6iuv1bP5hVNpgxYyhY3Z+FLe1ipe4cyT5rheF5Jq3EPkg5E
	xL7NTzTZordTDg==
X-ME-Sender: <xms:lWWlXBg96v7_nQzecl-GefNwcOuB2dGuW3H1kL_RfSJmXN6iG5f3gA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtdeggdehudculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhhrggfgsedtkeertdertddt
    necuhfhrohhmpegkihcujggrnhcuoeiiihdrhigrnhesshgvnhhtrdgtohhmqeenucfkph
    epvdduiedrvddvkedrudduvddrvddvnecurfgrrhgrmhepmhgrihhlfhhrohhmpeiiihdr
    higrnhesshgvnhhtrdgtohhmnecuvehluhhsthgvrhfuihiivgepvdeg
X-ME-Proxy: <xmx:lWWlXMDkp52DfJEQ0lOVDpOtrttc7pWAavVCCl5-r-VT9jHnhNIk_g>
    <xmx:lWWlXNjO_QuyFEOIIiPWuZsTfjBba4NHTHvej_E-0Q4lYds-lwx3Mw>
    <xmx:lWWlXL1CdJYUDY6mNBJ0XCOZLQT8tEruXPYPpViflNOZ6GYEEuCRUg>
    <xmx:lWWlXIZbTj45X_AYOJGtQQutMK6xam_fk2i5ijL6pjt793fhHdSkww>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 7114310316;
	Wed,  3 Apr 2019 22:01:55 -0400 (EDT)
From: Zi Yan <zi.yan@sent.com>
To: Dave Hansen <dave.hansen@linux.intel.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	Keith Busch <keith.busch@intel.com>,
	Fengguang Wu <fengguang.wu@intel.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	Javier Cabezas <jcabezas@nvidia.com>,
	David Nellans <dnellans@nvidia.com>,
	Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 25/25] memory manage: use exchange pages to memory manage to improve throughput.
Date: Wed,  3 Apr 2019 19:00:46 -0700
Message-Id: <20190404020046.32741-26-zi.yan@sent.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190404020046.32741-1-zi.yan@sent.com>
References: <20190404020046.32741-1-zi.yan@sent.com>
Reply-To: ziy@nvidia.com
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zi Yan <ziy@nvidia.com>

1. Exclude file-backed base pages from exchanging.
2. Split THP in exchange pages if THP support is disabled.
3. if THP migration is supported, only exchange THPs.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 mm/memory_manage.c | 173 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 173 insertions(+)

diff --git a/mm/memory_manage.c b/mm/memory_manage.c
index 8b76fcf..d3d07b7 100644
--- a/mm/memory_manage.c
+++ b/mm/memory_manage.c
@@ -7,6 +7,7 @@
 #include <linux/mempolicy.h>
 #include <linux/memcontrol.h>
 #include <linux/migrate.h>
+#include <linux/exchange.h>
 #include <linux/mm_inline.h>
 #include <linux/nodemask.h>
 #include <linux/rmap.h>
@@ -253,6 +254,147 @@ static int putback_overflow_pages(unsigned long max_nr_base_pages,
 			huge_page_list, nr_huge_pages);
 }
 
+static int add_pages_to_exchange_list(struct list_head *from_pagelist,
+	struct list_head *to_pagelist, struct exchange_page_info *info_list,
+	struct list_head *exchange_list, unsigned long info_list_size)
+{
+	unsigned long info_list_index = 0;
+	LIST_HEAD(failed_from_list);
+	LIST_HEAD(failed_to_list);
+
+	while (!list_empty(from_pagelist) && !list_empty(to_pagelist)) {
+		struct page *from_page, *to_page;
+		struct exchange_page_info *one_pair = &info_list[info_list_index];
+		int rc;
+
+		from_page = list_first_entry_or_null(from_pagelist, struct page, lru);
+		to_page = list_first_entry_or_null(to_pagelist, struct page, lru);
+
+		if (!from_page || !to_page)
+			break;
+
+		if (!thp_migration_supported() && PageTransHuge(from_page)) {
+			lock_page(from_page);
+			rc = split_huge_page_to_list(from_page, &from_page->lru);
+			unlock_page(from_page);
+			if (rc) {
+				list_move(&from_page->lru, &failed_from_list);
+				continue;
+			}
+		}
+
+		if (!thp_migration_supported() && PageTransHuge(to_page)) {
+			lock_page(to_page);
+			rc = split_huge_page_to_list(to_page, &to_page->lru);
+			unlock_page(to_page);
+			if (rc) {
+				list_move(&to_page->lru, &failed_to_list);
+				continue;
+			}
+		}
+
+		if (hpage_nr_pages(from_page) != hpage_nr_pages(to_page)) {
+			if (!(hpage_nr_pages(from_page) == 1 && hpage_nr_pages(from_page) == HPAGE_PMD_NR)) {
+				list_del(&from_page->lru);
+				list_add(&from_page->lru, &failed_from_list);
+			}
+			if (!(hpage_nr_pages(to_page) == 1 && hpage_nr_pages(to_page) == HPAGE_PMD_NR)) {
+				list_del(&to_page->lru);
+				list_add(&to_page->lru, &failed_to_list);
+			}
+			continue;
+		}
+
+		/* Exclude file-backed pages, exchange it concurrently is not
+		 * implemented yet. */
+		if (page_mapping(from_page)) {
+			list_del(&from_page->lru);
+			list_add(&from_page->lru, &failed_from_list);
+			continue;
+		}
+		if (page_mapping(to_page)) {
+			list_del(&to_page->lru);
+			list_add(&to_page->lru, &failed_to_list);
+			continue;
+		}
+
+		list_del(&from_page->lru);
+		list_del(&to_page->lru);
+
+		one_pair->from_page = from_page;
+		one_pair->to_page = to_page;
+
+		list_add_tail(&one_pair->list, exchange_list);
+
+		info_list_index++;
+		if (info_list_index >= info_list_size)
+			break;
+	}
+	list_splice(&failed_from_list, from_pagelist);
+	list_splice(&failed_to_list, to_pagelist);
+
+	return info_list_index;
+}
+
+static unsigned long exchange_pages_between_nodes(unsigned long nr_from_pages,
+	unsigned long nr_to_pages, struct list_head *from_page_list,
+	struct list_head *to_page_list, int batch_size,
+	bool huge_page, enum migrate_mode mode)
+{
+	struct exchange_page_info *info_list;
+	unsigned long info_list_size = min_t(unsigned long,
+		nr_from_pages, nr_to_pages) / (huge_page?HPAGE_PMD_NR:1);
+	unsigned long added_size = 0;
+	bool migrate_concur = mode & MIGRATE_CONCUR;
+	LIST_HEAD(exchange_list);
+
+	/* non concurrent does not need to split into batches  */
+	if (!migrate_concur || batch_size <= 0)
+		batch_size = info_list_size;
+
+	/* prepare for huge page split  */
+	if (!thp_migration_supported() && huge_page) {
+		batch_size = batch_size * HPAGE_PMD_NR;
+		info_list_size = info_list_size * HPAGE_PMD_NR;
+	}
+
+	info_list = kvzalloc(sizeof(struct exchange_page_info)*batch_size,
+			GFP_KERNEL);
+	if (!info_list)
+		return 0;
+
+	while (!list_empty(from_page_list) && !list_empty(to_page_list)) {
+		unsigned long nr_added_pages;
+		INIT_LIST_HEAD(&exchange_list);
+
+		nr_added_pages = add_pages_to_exchange_list(from_page_list, to_page_list,
+			info_list, &exchange_list, batch_size);
+
+		/*
+		 * Nothing to exchange, we bail out.
+		 *
+		 * In case from_page_list and to_page_list both only have file-backed
+		 * pages left */
+		if (!nr_added_pages)
+			break;
+
+		added_size += nr_added_pages;
+
+		VM_BUG_ON(added_size > info_list_size);
+
+		if (migrate_concur)
+			exchange_pages_concur(&exchange_list, mode, MR_SYSCALL);
+		else
+			exchange_pages(&exchange_list, mode, MR_SYSCALL);
+
+		memset(info_list, 0, sizeof(struct exchange_page_info)*batch_size);
+	}
+
+	kvfree(info_list);
+
+	return info_list_size;
+}
+
 static int do_mm_manage(struct task_struct *p, struct mm_struct *mm,
 		const nodemask_t *slow, const nodemask_t *fast,
 		unsigned long nr_pages, int flags)
@@ -261,6 +403,7 @@ static int do_mm_manage(struct task_struct *p, struct mm_struct *mm,
 	bool migrate_concur = flags & MPOL_MF_MOVE_CONCUR;
 	bool migrate_dma = flags & MPOL_MF_MOVE_DMA;
 	bool move_hot_and_cold_pages = flags & MPOL_MF_MOVE_ALL;
+	bool migrate_exchange_pages = flags & MPOL_MF_EXCHANGE;
 	struct mem_cgroup *memcg = mem_cgroup_from_task(p);
 	int err = 0;
 	unsigned long nr_isolated_slow_pages;
@@ -338,6 +481,35 @@ static int do_mm_manage(struct task_struct *p, struct mm_struct *mm,
 			&nr_isolated_fast_base_pages, &nr_isolated_fast_huge_pages,
 			move_hot_and_cold_pages?ISOLATE_HOT_AND_COLD_PAGES:ISOLATE_COLD_PAGES);
 
+		if (migrate_exchange_pages) {
+			unsigned long nr_exchange_pages;
+
+			/*
+			 * base pages can include file-backed ones, we do not handle them
+			 * at the moment
+			 */
+			if (!thp_migration_supported()) {
+				nr_exchange_pages =  exchange_pages_between_nodes(nr_isolated_slow_base_pages,
+					nr_isolated_fast_base_pages, &slow_base_page_list,
+					&fast_base_page_list, migration_batch_size, false, mode);
+
+				nr_isolated_fast_base_pages -= nr_exchange_pages;
+			}
+
+			/* THP page exchange */
+			nr_exchange_pages =  exchange_pages_between_nodes(nr_isolated_slow_huge_pages,
+				nr_isolated_fast_huge_pages, &slow_huge_page_list,
+				&fast_huge_page_list, migration_batch_size, true, mode);
+
+			/* split THP above, so we do not need to multiply the counter */
+			if (!thp_migration_supported())
+				nr_isolated_fast_huge_pages -= nr_exchange_pages;
+			else
+				nr_isolated_fast_huge_pages -= nr_exchange_pages * HPAGE_PMD_NR;
+
+			goto migrate_out;
+		} else {
+migrate_out:
 		/* Migrate pages to slow node */
 		/* No multi-threaded migration for base pages */
 		nr_isolated_fast_base_pages -=
@@ -347,6 +519,7 @@ static int do_mm_manage(struct task_struct *p, struct mm_struct *mm,
 		nr_isolated_fast_huge_pages -=
 			migrate_to_node(&fast_huge_page_list, slow_nid, mode,
 				migration_batch_size);
+		}
 	}
 
 	if (nr_isolated_fast_base_pages != ULONG_MAX &&
-- 
2.7.4

