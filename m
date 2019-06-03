Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0DE8C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 14:35:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75C0127A8E
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 14:35:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75C0127A8E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9953F6B000C; Mon,  3 Jun 2019 10:35:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F0EC6B0266; Mon,  3 Jun 2019 10:35:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C4EC6B0269; Mon,  3 Jun 2019 10:35:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id F03E76B000E
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 10:35:14 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k15so26874659eda.6
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 07:35:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=4lOoSD8nEnj7z+ICw415bghUg9I0LJXDUPsEjFA6gCQ=;
        b=UgCAHiDmzL3gzcrgmeeiQcK9MVBUGZDA3Mq7RDBL4tbvsWyfLfaMiqrdQmamvZS354
         rEjLd/HAE1ldojtZWq/qKPADtPJznkXPDYQd92Bp4fQ1+3I/mxo/6O7rjex685ztxRpB
         hvefAwCUB5kYwwaaKGIIyzf27a9dLfnA6uwm1zt+x9c/20I1PR4xy7qWajlWGhcDxvPx
         4c2/xeMQXlk7WShlI9KqwCra/ogoxDsm1/nvPh6e0svQAXPCXvJe4m8DxXTDqQ3k1oQb
         RiBGB2yF8Y2/W0oBbHbPXOk+3dg4rUJDOOx5aLGVWThRGGg84jqVVXlI2ZIfg8ARwB4n
         GEsw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAVomfleaMptifR3PjrvdEndE2Hb9rS3C5Rg//24lWhAjXCaLvl6
	jd+qeWt98Ct+39AEEXiAACIJXHQRPkbJpAnrN6cZG7IRzYC6C9icDtwrXyTwX81N3f970r4/8Bs
	L8a4d/S9hjWmgiFHOEn+/0XWiKG9Gs/S4cxaA1jfHcWIzGsnkmqk/q5roZbF9XwZqqw==
X-Received: by 2002:a50:bdc6:: with SMTP id z6mr29416142edh.47.1559572514453;
        Mon, 03 Jun 2019 07:35:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy7animOA9ov+0wr2B3IwDlZ81h7m129j51iQrCF8Vh8o+6MZ4xWXl7A3FStTR1yXKJ9Y1U
X-Received: by 2002:a50:bdc6:: with SMTP id z6mr29415959edh.47.1559572512492;
        Mon, 03 Jun 2019 07:35:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559572512; cv=none;
        d=google.com; s=arc-20160816;
        b=ibaQwZxAeZR9se2A6fMjJv2PrFMGHA0u45Th4o78OJMwCs2p+uyDBS7msjRtEcwQF/
         UgZcFAKg5LnIpE7Cl2H3AlPhjpYkx8qNrWOA+OQMpd96ENwwPp0xn14my/GtPHbhVQqi
         DA1CH4qer30vrD6BsFZ3nJRoU7TMAmCrVleWtdvNzdeos8HTyrN+Xa6Bh8pnSDW0oiMF
         jx1tvZ2KFIIn3QSMr37WFNlU2vZOXXIZQXlGxJdPUsdJfWBkcqI+M8+HpvWbdCFIadV9
         1RGecrYfqh7185azvIEtXFcrxQMXnulKctHYrse7SA69Loh0sqGteCXkiBcxM/p0TuYi
         Sb9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=4lOoSD8nEnj7z+ICw415bghUg9I0LJXDUPsEjFA6gCQ=;
        b=Tmmswbo/qNs/pRkKC5AsMFeNYcVi2NmOiI1V/L5rWhTXsdzFPbkFxzUeWSyGcFKasa
         HUOLK81BPlXFYR99JFaWfZ6D0kAMhvwTYQ+PZ2ybbraXe5VB5kawt1Y1abDamPB4BRrK
         FPV/xrL2alcM2sECTo2t1UjBfbbkcxDTkFPLR65o50eT1nL5AHAqXhpquA9n4f1m1ji8
         LfR98Wjqbe8lLeT0Es02n5r7ZinJhC1igTNwqT9HDdqESLNOTzKJtlh/U6rH09wi6wng
         /AdqzOUbNwsKcrm/l+QzEZNW16SbkEPtEquSaZVLcc9q3AiuykbGu0CGI+BI/EoPq9Gk
         wqDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l43si453371eda.71.2019.06.03.07.35.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 07:35:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id ECABCAD43;
	Mon,  3 Jun 2019 14:35:11 +0000 (UTC)
From: Vlastimil Babka <vbabka@suse.cz>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 2/3] mm, page_alloc: more extensive free page checking with debug_pagealloc
Date: Mon,  3 Jun 2019 16:34:50 +0200
Message-Id: <20190603143451.27353-3-vbabka@suse.cz>
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

The page allocator checks struct pages for expected state (mapcount, flags etc)
as pages are being allocated (check_new_page()) and freed (free_pages_check())
to provide some defense against errors in page allocator users. Prior commits
479f854a207c ("mm, page_alloc: defer debugging checks of pages allocated from
the PCP") and 4db7548ccbd9 ("mm, page_alloc: defer debugging checks of freed
pages until a PCP drain") this has happened for order-0 pages as they were
allocated from or freed to the per-cpu caches (pcplists). Since those are fast
paths, the checks are now performed only when pages are moved between pcplists
and global free lists. This however lowers the chances of catching errors soon
enough.

In order to increase the chances of the checks to catch errors, the kernel has
to be rebuilt with CONFIG_DEBUG_VM, which also enables multiple other internal
debug checks (VM_BUG_ON() etc), which is suboptimal when the goal is to catch
errors in mm users, not in mm code itself.

To catch some wrong users of page allocator, we have CONFIG_DEBUG_PAGEALLOC,
which is designed to have virtually no overhead unless enabled at boot time.
Memory corruptions when writing to freed pages have often the same underlying
errors (use-after-free, double free) as corrupting the corresponding struct
pages, so this existing debugging functionality is a good fit to extend by
also perform struct page checks at least as often as if CONFIG_DEBUG_VM was
enabled.

Specifically, after this patch, when debug_pagealloc is enabled on boot, and
CONFIG_DEBUG_VM disabled, pages are checked when allocated from or freed to the
pcplists *in addition* to being moved between pcplists and free lists. When
both debug_pagealloc and CONFIG_DEBUG_VM are enabled, pages are checked when
being moved between pcplists and free lists *in addition* to when allocated
from or freed to the pcplists.

When debug_pagealloc is not enabled on boot, the overhead in fast paths should
be virtually none thanks to the use of static key.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>
---
 mm/Kconfig.debug | 13 ++++++++----
 mm/page_alloc.c  | 53 +++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 52 insertions(+), 14 deletions(-)

diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index fa6d79281368..a35ab6c55192 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -19,12 +19,17 @@ config DEBUG_PAGEALLOC
 	  Depending on runtime enablement, this results in a small or large
 	  slowdown, but helps to find certain types of memory corruption.
 
+	  Also, the state of page tracking structures is checked more often as
+	  pages are being allocated and freed, as unexpected state changes
+	  often happen for same reasons as memory corruption (e.g. double free,
+	  use-after-free).
+
 	  For architectures which don't enable ARCH_SUPPORTS_DEBUG_PAGEALLOC,
 	  fill the pages with poison patterns after free_pages() and verify
-	  the patterns before alloc_pages().  Additionally,
-	  this option cannot be enabled in combination with hibernation as
-	  that would result in incorrect warnings of memory corruption after
-	  a resume because free pages are not saved to the suspend image.
+	  the patterns before alloc_pages(). Additionally, this option cannot
+	  be enabled in combination with hibernation as that would result in
+	  incorrect warnings of memory corruption after a resume because free
+	  pages are not saved to the suspend image.
 
 	  By default this option will have a small overhead, e.g. by not
 	  allowing the kernel mapping to be backed by large pages on some
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 639f1f9e74c5..e6248e391358 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1162,19 +1162,36 @@ static __always_inline bool free_pages_prepare(struct page *page,
 }
 
 #ifdef CONFIG_DEBUG_VM
-static inline bool free_pcp_prepare(struct page *page)
+/*
+ * With DEBUG_VM enabled, order-0 pages are checked immediately when being freed
+ * to pcp lists. With debug_pagealloc also enabled, they are also rechecked when
+ * moved from pcp lists to free lists.
+ */
+static bool free_pcp_prepare(struct page *page)
 {
 	return free_pages_prepare(page, 0, true);
 }
 
-static inline bool bulkfree_pcp_prepare(struct page *page)
+static bool bulkfree_pcp_prepare(struct page *page)
 {
-	return false;
+	if (debug_pagealloc_enabled())
+		return free_pages_check(page);
+	else
+		return false;
 }
 #else
+/*
+ * With DEBUG_VM disabled, order-0 pages being freed are checked only when
+ * moving from pcp lists to free list in order to reduce overhead. With
+ * debug_pagealloc enabled, they are checked also immediately when being freed
+ * to the pcp lists.
+ */
 static bool free_pcp_prepare(struct page *page)
 {
-	return free_pages_prepare(page, 0, false);
+	if (debug_pagealloc_enabled())
+		return free_pages_prepare(page, 0, true);
+	else
+		return free_pages_prepare(page, 0, false);
 }
 
 static bool bulkfree_pcp_prepare(struct page *page)
@@ -2036,23 +2053,39 @@ static inline bool free_pages_prezeroed(void)
 }
 
 #ifdef CONFIG_DEBUG_VM
-static bool check_pcp_refill(struct page *page)
+/*
+ * With DEBUG_VM enabled, order-0 pages are checked for expected state when
+ * being allocated from pcp lists. With debug_pagealloc also enabled, they are
+ * also checked when pcp lists are refilled from the free lists.
+ */
+static inline bool check_pcp_refill(struct page *page)
 {
-	return false;
+	if (debug_pagealloc_enabled())
+		return check_new_page(page);
+	else
+		return false;
 }
 
-static bool check_new_pcp(struct page *page)
+static inline bool check_new_pcp(struct page *page)
 {
 	return check_new_page(page);
 }
 #else
-static bool check_pcp_refill(struct page *page)
+/*
+ * With DEBUG_VM disabled, free order-0 pages are checked for expected state
+ * when pcp lists are being refilled from the free lists. With debug_pagealloc
+ * enabled, they are also checked when being allocated from the pcp lists.
+ */
+static inline bool check_pcp_refill(struct page *page)
 {
 	return check_new_page(page);
 }
-static bool check_new_pcp(struct page *page)
+static inline bool check_new_pcp(struct page *page)
 {
-	return false;
+	if (debug_pagealloc_enabled())
+		return check_new_page(page);
+	else
+		return false;
 }
 #endif /* CONFIG_DEBUG_VM */
 
-- 
2.21.0

