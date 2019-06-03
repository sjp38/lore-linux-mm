Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C20B9C46470
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 14:35:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 774BF27A83
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 14:35:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 774BF27A83
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 020086B0008; Mon,  3 Jun 2019 10:35:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEB526B000D; Mon,  3 Jun 2019 10:35:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D63B36B000E; Mon,  3 Jun 2019 10:35:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 81AB86B0008
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 10:35:14 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l53so4748465edc.7
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 07:35:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Iv0VISLDGp1pb4crv451Mpvs0adMiY7F6Ubd9/bdvuI=;
        b=rqDMvxo3PrVki3mnvCttdkH6U+SpFKY7l2RWAZ7jnAdxsu72PQi6qTkQfsqbhYfRea
         sfGU+0wV0bZthMuyF3BF2538F1QSFygqsU+jHBzZwbmpxIpT9OqhqJ/grwLPbGXjK407
         GdIk2qIwxPOdYpc9mipuQQcu07lYisxQoQyW5FwfgiGswgcTOQTSFO2lSaCe2uxn7ww5
         OA52o6dZK1CPmvT2bh/C7s5dQxUXVZ/PaBB2LoxPE4tmEuiePHd0hG+8zzsjWG69JNW9
         wfMQRkKZh281eTpefObVjiUoXAzZLg1sJ7IWUAuWj1ZgvswWxWmk63fLjdJXR4RfqRs4
         640w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAUsLEjnLYsZEZv0T0o/Hbbt4F8ROIrTQTzkQaePx7phmQj3gF7q
	bavBesi/mlS/DJN/qTG/inhxitIWXoUTR3y2KoQ1mb0T33sx4c6hmZJDIKIjDMPaDTNXPrraLm7
	AbbDpXCRhDUcJ405vQidWD1rB04Z7hexr3NiH7rOBtuwL7SVLNktShPrnUIXqJQYsEQ==
X-Received: by 2002:a17:906:546:: with SMTP id k6mr19841103eja.53.1559572513968;
        Mon, 03 Jun 2019 07:35:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBylShCXTmC0hxaIHu40IYm0i/xYIIlrVDXqT46gyyYjalpn4TtPfr1RefTZssnBjftm05
X-Received: by 2002:a17:906:546:: with SMTP id k6mr19840990eja.53.1559572512527;
        Mon, 03 Jun 2019 07:35:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559572512; cv=none;
        d=google.com; s=arc-20160816;
        b=iLBJyjMgfeYJajuj/jWpB0F9pvIlvggsNYQY7ck8dLCoG3NX1QPpeWjIo76ia2inRz
         NzjInjSCL95vCwDmIKyuIXZkHZjvcAVEVhFgVi6bRCvdZ463PgzPc0fDJThfhbqd1vLy
         14pQf6D1gviREo53tSNZnpEjWYEf/28iTiy/rOwYC51GQ9FMmqW7DZZmbeEYVOeyBb6N
         DgiCs4lcmuUjcLroAn5RTg0uslSIKkmgSGQtSCCghT1qY0e9eNmZ3F+rU9X3JNKfKOAR
         3hyyJ6UZUipBlc+FctaCc9FjJKxdShifxO6cdINp/PFsoLPbbO8qvfZBXcK1Yo1vpDrl
         duQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Iv0VISLDGp1pb4crv451Mpvs0adMiY7F6Ubd9/bdvuI=;
        b=WrtD6WzkeSHUDKgcXmRQ6QibIA0GAgLtlFSG1VeE3T3bwKvRaN79j34183yqPcVEcO
         g/0kUWrrRwC5sN0KlenaMSEVRK8m818jKp+T3/weLHHn80E32kn81EQ6iyVhRzOYcRnI
         2FXXlbryYZL1jp4COrGhoymlqm0QcfklXADwN8qRO8gdO4/wmn4FnEdTjFbBoSJER62f
         PafVEisMJJOFZyghOfLOlMjF0Kq2vBRmYaT6xolK73cxsyHb+hc0JWZ4ZhDGk+dCYPdb
         DwEZnpQ1SAcQ7ZkQzpcWnSN3u9FVFZ0l88AVsiGezuInU/JIvM2rBZ1VfcUsvTL7Ng50
         iZ+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c55si772440edc.323.2019.06.03.07.35.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 07:35:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EDAEFAD8B;
	Mon,  3 Jun 2019 14:35:11 +0000 (UTC)
From: Vlastimil Babka <vbabka@suse.cz>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 3/3] mm, debug_pagealloc: use a page type instead of page_ext flag
Date: Mon,  3 Jun 2019 16:34:51 +0200
Message-Id: <20190603143451.27353-4-vbabka@suse.cz>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190603143451.27353-1-vbabka@suse.cz>
References: <20190603143451.27353-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When debug_pagealloc is enabled, we currently allocate the page_ext array to
mark guard pages with the PAGE_EXT_DEBUG_GUARD flag. Now that we have the
page_type field in struct page, we can use that instead, as guard pages are
neither PageSlab nor mapped to userspace. This reduces memory overhead when
debug_pagealloc is enabled and there are no other features requiring the
page_ext array.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Matthew Wilcox <willy@infradead.org>
---
 .../admin-guide/kernel-parameters.txt         | 10 ++---
 include/linux/mm.h                            | 10 +----
 include/linux/page-flags.h                    |  6 +++
 include/linux/page_ext.h                      |  1 -
 mm/Kconfig.debug                              |  1 -
 mm/page_alloc.c                               | 40 +++----------------
 mm/page_ext.c                                 |  3 --
 7 files changed, 17 insertions(+), 54 deletions(-)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 138f6664b2e2..32003e76ba3b 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -805,12 +805,10 @@
 			tracking down these problems.
 
 	debug_pagealloc=
-			[KNL] When CONFIG_DEBUG_PAGEALLOC is set, this
-			parameter enables the feature at boot time. In
-			default, it is disabled. We can avoid allocating huge
-			chunk of memory for debug pagealloc if we don't enable
-			it at boot time and the system will work mostly same
-			with the kernel built without CONFIG_DEBUG_PAGEALLOC.
+			[KNL] When CONFIG_DEBUG_PAGEALLOC is set, this parameter
+			enables the feature at boot time. By default, it is
+			disabled and the system will work mostly the same as a
+			kernel built without CONFIG_DEBUG_PAGEALLOC.
 			on: enable the feature
 
 	debugpat	[X86] Enable PAT debugging
diff --git a/include/linux/mm.h b/include/linux/mm.h
index c71ed22769f3..2ba991e687db 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2846,8 +2846,6 @@ extern long copy_huge_page_from_user(struct page *dst_page,
 				bool allow_pagefault);
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */
 
-extern struct page_ext_operations debug_guardpage_ops;
-
 #ifdef CONFIG_DEBUG_PAGEALLOC
 extern unsigned int _debug_guardpage_minorder;
 DECLARE_STATIC_KEY_FALSE(_debug_guardpage_enabled);
@@ -2864,16 +2862,10 @@ static inline bool debug_guardpage_enabled(void)
 
 static inline bool page_is_guard(struct page *page)
 {
-	struct page_ext *page_ext;
-
 	if (!debug_guardpage_enabled())
 		return false;
 
-	page_ext = lookup_page_ext(page);
-	if (unlikely(!page_ext))
-		return false;
-
-	return test_bit(PAGE_EXT_DEBUG_GUARD, &page_ext->flags);
+	return PageGuard(page);
 }
 #else
 static inline unsigned int debug_guardpage_minorder(void) { return 0; }
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 9f8712a4b1a5..b848517da64c 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -703,6 +703,7 @@ PAGEFLAG_FALSE(DoubleMap)
 #define PG_offline	0x00000100
 #define PG_kmemcg	0x00000200
 #define PG_table	0x00000400
+#define PG_guard	0x00000800
 
 #define PageType(page, flag)						\
 	((page->page_type & (PAGE_TYPE_BASE | flag)) == PAGE_TYPE_BASE)
@@ -754,6 +755,11 @@ PAGE_TYPE_OPS(Kmemcg, kmemcg)
  */
 PAGE_TYPE_OPS(Table, table)
 
+/*
+ * Marks guardpages used with debug_pagealloc.
+ */
+PAGE_TYPE_OPS(Guard, guard)
+
 extern bool is_free_buddy_page(struct page *page);
 
 __PAGEFLAG(Isolated, isolated, PF_ANY);
diff --git a/include/linux/page_ext.h b/include/linux/page_ext.h
index f84f167ec04c..09592951725c 100644
--- a/include/linux/page_ext.h
+++ b/include/linux/page_ext.h
@@ -17,7 +17,6 @@ struct page_ext_operations {
 #ifdef CONFIG_PAGE_EXTENSION
 
 enum page_ext_flags {
-	PAGE_EXT_DEBUG_GUARD,
 	PAGE_EXT_OWNER,
 #if defined(CONFIG_IDLE_PAGE_TRACKING) && !defined(CONFIG_64BIT)
 	PAGE_EXT_YOUNG,
diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index a35ab6c55192..82b6a20898bd 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -12,7 +12,6 @@ config DEBUG_PAGEALLOC
 	bool "Debug page memory allocations"
 	depends on DEBUG_KERNEL
 	depends on !HIBERNATION || ARCH_SUPPORTS_DEBUG_PAGEALLOC && !PPC && !SPARC
-	select PAGE_EXTENSION
 	select PAGE_POISONING if !ARCH_SUPPORTS_DEBUG_PAGEALLOC
 	---help---
 	  Unmap pages from the kernel linear mapping after free_pages().
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e6248e391358..b178f297df68 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -50,7 +50,6 @@
 #include <linux/backing-dev.h>
 #include <linux/fault-inject.h>
 #include <linux/page-isolation.h>
-#include <linux/page_ext.h>
 #include <linux/debugobjects.h>
 #include <linux/kmemleak.h>
 #include <linux/compaction.h>
@@ -670,18 +669,6 @@ static int __init early_debug_pagealloc(char *buf)
 }
 early_param("debug_pagealloc", early_debug_pagealloc);
 
-static bool need_debug_guardpage(void)
-{
-	/* If we don't use debug_pagealloc, we don't need guard page */
-	if (!debug_pagealloc_enabled())
-		return false;
-
-	if (!debug_guardpage_minorder())
-		return false;
-
-	return true;
-}
-
 static void init_debug_guardpage(void)
 {
 	if (!debug_pagealloc_enabled())
@@ -693,11 +680,6 @@ static void init_debug_guardpage(void)
 	static_branch_enable(&_debug_guardpage_enabled);
 }
 
-struct page_ext_operations debug_guardpage_ops = {
-	.need = need_debug_guardpage,
-	.init = init_debug_guardpage,
-};
-
 static int __init debug_guardpage_minorder_setup(char *buf)
 {
 	unsigned long res;
@@ -715,20 +697,13 @@ early_param("debug_guardpage_minorder", debug_guardpage_minorder_setup);
 static inline bool set_page_guard(struct zone *zone, struct page *page,
 				unsigned int order, int migratetype)
 {
-	struct page_ext *page_ext;
-
 	if (!debug_guardpage_enabled())
 		return false;
 
 	if (order >= debug_guardpage_minorder())
 		return false;
 
-	page_ext = lookup_page_ext(page);
-	if (unlikely(!page_ext))
-		return false;
-
-	__set_bit(PAGE_EXT_DEBUG_GUARD, &page_ext->flags);
-
+	__SetPageGuard(page);
 	INIT_LIST_HEAD(&page->lru);
 	set_page_private(page, order);
 	/* Guard pages are not available for any usage */
@@ -740,23 +715,16 @@ static inline bool set_page_guard(struct zone *zone, struct page *page,
 static inline void clear_page_guard(struct zone *zone, struct page *page,
 				unsigned int order, int migratetype)
 {
-	struct page_ext *page_ext;
-
 	if (!debug_guardpage_enabled())
 		return;
 
-	page_ext = lookup_page_ext(page);
-	if (unlikely(!page_ext))
-		return;
-
-	__clear_bit(PAGE_EXT_DEBUG_GUARD, &page_ext->flags);
+	__ClearPageGuard(page);
 
 	set_page_private(page, 0);
 	if (!is_migrate_isolate(migratetype))
 		__mod_zone_freepage_state(zone, (1 << order), migratetype);
 }
 #else
-struct page_ext_operations debug_guardpage_ops;
 static inline bool set_page_guard(struct zone *zone, struct page *page,
 			unsigned int order, int migratetype) { return false; }
 static inline void clear_page_guard(struct zone *zone, struct page *page,
@@ -1931,6 +1899,10 @@ void __init page_alloc_init_late(void)
 
 	for_each_populated_zone(zone)
 		set_zone_contiguous(zone);
+
+#ifdef CONFIG_DEBUG_PAGEALLOC
+	init_debug_guardpage();
+#endif
 }
 
 #ifdef CONFIG_CMA
diff --git a/mm/page_ext.c b/mm/page_ext.c
index d8f1aca4ad43..5f5769c7db3b 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -59,9 +59,6 @@
  */
 
 static struct page_ext_operations *page_ext_ops[] = {
-#ifdef CONFIG_DEBUG_PAGEALLOC
-	&debug_guardpage_ops,
-#endif
 #ifdef CONFIG_PAGE_OWNER
 	&page_owner_ops,
 #endif
-- 
2.21.0

