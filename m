Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6651C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 14:32:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5EECC2087C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 14:32:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="BcU3oTNs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5EECC2087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC6B58E0003; Wed, 13 Mar 2019 10:31:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4D898E0001; Wed, 13 Mar 2019 10:31:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF1068E0003; Wed, 13 Mar 2019 10:31:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id A304B8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 10:31:59 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id h28so1333877qkk.7
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 07:31:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=zWwvp5HYTt2UGqggycNdgQkwCt4sLo6I2UnQvia+v8Q=;
        b=Lp4f2HlFWv81r4360g3iHaeNjoAgPDhEbjpHWrHdVzeCgegjgcjH13CiKxH6HjRN1p
         BkE66nBpOMOCFhAlY+hF1m7c/YIAMnFebpSnC7m22x1FDDL9Hf7xt0RELGXk59jZbzM+
         zVfbSPt0NWt/Dilo3p+yBNO5337BBTVow5+nlnLGGdCf0Nd1Bq6/jChBs1DzjWO32994
         2S1bL6sKUcySqszOCmeI658Od2dnujguxekfW6ZKkbkBYL6i3pplAO1PlfJ6u6IdUeO4
         jcjTFuzZ3/e/qA4CGDKEo2PzFcmHsAgWnKeZNqbWLCx46kp9ByCXGSNA+1NDxwFhFKni
         cZCA==
X-Gm-Message-State: APjAAAXa9ah667BPISVm2HvXcs/ncXRfrKgGpXkA+8ljg52AZ5fyDkmB
	knEVofT8IFyvpTDpJmWwVArZMd9EL1XcD4DtIjtz/bgDHNwgFEHuMdWUsBJnHDcWnuxw0DBvtjm
	h1x0fsSyagDavNh3gZrqV2C+hrncORpPSmgA8jTmaMmiC81eSNzPE0KKH4vujJn8bq43MNKZJ9E
	M2eZnaezF82IMWe98v35ItJf/JYmljxzL7weeCvQgmJi2pJzNzOXN/St8AQeYN5hVznbjfbBwbz
	Ko2vv9oH3jHYd5puAtfqQNKGajpYXjmk05IVdQ+b2ZNhwRoEXlWNEHjMgrYDmwRqICgCOJ3y7sJ
	xE3XsGzZZLHrWojC2lE0gGPGXr4x74YZLG35ZIIytotZbcGAKdjBwHiJ7OVUxkgehFc8pvuCcFW
	W
X-Received: by 2002:a37:5887:: with SMTP id m129mr23848547qkb.264.1552487519414;
        Wed, 13 Mar 2019 07:31:59 -0700 (PDT)
X-Received: by 2002:a37:5887:: with SMTP id m129mr23848468qkb.264.1552487518232;
        Wed, 13 Mar 2019 07:31:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552487518; cv=none;
        d=google.com; s=arc-20160816;
        b=m84ZevGKgwroMDqOR5jaUJxzxhFDgn6Us4MX1x6B9hdefQ05ejGAKXbO7foJHSb2n3
         BPammKu3PYddZs/VnxGsF6+LOfZMX0UPS9xq7vJOCowUmKJPYn9eBdOem8NpHhZQaPNU
         lFn6z4mdIJg4p5htUpP3orDjTpUXmagLWdRun36qcflkDconb8TlICJQYmwvlLVAOGlO
         LR3pvUTbfU00ugTTYjJJGbqjUpy+tg3ENBti6dUi4L67uSYt5N3h79CsL44GwK/N48nt
         ONJz393QDIzNdDfwsTPtudkAaSUDHJtlrQsi/6+1kXrh3pT7xPgE72upViTIRQShei4W
         jfPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=zWwvp5HYTt2UGqggycNdgQkwCt4sLo6I2UnQvia+v8Q=;
        b=whPcQVag4R/wTwFhqzUNgM+NUDkB8YXuwcrPgRAcc33FQLeWn06LHI08H3UA+NOJbm
         wOmx0XxPeoIlIRREShVBzJSe+bHSEpzmXrvj6tl4zVFpAt8IlkDWuvsvEOlnId1M+GS5
         JmYiDZfXzclFEi7Z5cxGmmzavFvRmerWopLqPKopOsXHZKvDFBUWf3oy7e0LzeLLXURo
         gFBIIOmXK5R0yyDGBA7mbJA32JbvKEni7hBtHsC6unZGGAr6R7Yn2tT9q8hvw/8wpmxO
         2MvmeWjWLcTnmI8PC6gqRICdrEFMX3PGyBymEXggmczqgggHxv/zxb7NU4BcdfETE1Gh
         WOXw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=BcU3oTNs;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g8sor6468055qkb.76.2019.03.13.07.31.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 07:31:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=BcU3oTNs;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=zWwvp5HYTt2UGqggycNdgQkwCt4sLo6I2UnQvia+v8Q=;
        b=BcU3oTNsoRMBivjqIfl5Apen1hlN23ETVuiivEbUZbV1AqcfMmLDlkuRV7W0GmpnYC
         Y0Gy9ZVZCLwf8RU+klZ4dx1O4vfB2rGJRMdtxFmLR9/MztzbDcUL3GfuhJWOo+PGQdOr
         C2K3uxfeOMgMohLKicLzru0VlnIj3CPRaDBX3DyIIopq3zOUcDWCkiN6fE76YgNQRzz6
         tFKStAQOeNLqYDN49OJf9LOIeWYg42ql6agjc+H5ZrzovRSMf+u+iuZB+q8zQq89na9T
         e2VjMpfHim8QeXqh65QG4nxyNzseRfEsik3nbSvwcUcpViRRMmwzEpCWueLywMaO2oDU
         GFWw==
X-Google-Smtp-Source: APXvYqxEzvE7apl4xb0kvGmqFkAtgk3l2CnCqVsh1tCeReWtuJN4sctxkQsBC+zoaC3x9xnte6Ua2w==
X-Received: by 2002:a37:7d86:: with SMTP id y128mr23316265qkc.36.1552487517888;
        Wed, 13 Mar 2019 07:31:57 -0700 (PDT)
Received: from ovpn-121-103.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id e2sm6147984qkd.7.2019.03.13.07.31.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 07:31:56 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: mhocko@kernel.org,
	osalvador@suse.de,
	vbabka@suse.cz,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH v2] mm/hotplug: fix offline undo_isolate_page_range()
Date: Wed, 13 Mar 2019 10:31:33 -0400
Message-Id: <20190313143133.46200-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The commit f1dd2cd13c4b ("mm, memory_hotplug: do not associate hotadded
memory to zones until online") introduced move_pfn_range_to_zone() which
calls memmap_init_zone() during onlining a memory block.
memmap_init_zone() will reset pagetype flags and makes migrate type to
be MOVABLE.

However, in __offline_pages(), it also call undo_isolate_page_range()
after offline_isolated_pages() to do the same thing. Due to
the commit 2ce13640b3f4 ("mm: __first_valid_page skip over offline
pages") changed __first_valid_page() to skip offline pages,
undo_isolate_page_range() here just waste CPU cycles looping around the
offlining PFN range while doing nothing, because __first_valid_page()
will return NULL as offline_isolated_pages() has already marked all
memory sections within the pfn range as offline via
offline_mem_sections().

Also, after calling the "useless" undo_isolate_page_range() here, it
reaches the point of no returning by notifying MEM_OFFLINE. Those pages
will be marked as MIGRATE_MOVABLE again once onlining. The only thing
left to do is to decrease the number of isolated pageblocks zone
counter which would make some paths of the page allocation slower that
the above commit introduced. A memory block is usually at most 1GiB in
size, so an "int" should be enough to represent the number of pageblocks
in a block. Fix an incorrect comment along the way.

Fixes: 2ce13640b3f4 ("mm: __first_valid_page skip over offline pages")
Signed-off-by: Qian Cai <cai@lca.pw>
---

v2: return the nubmer of isolated pageblocks in start_isolate_page_range() per
    Oscar; take the zone lock when undoing zone->nr_isolate_pageblock per
    Michal.

 mm/memory_hotplug.c | 17 +++++++++++++----
 mm/page_alloc.c     |  2 +-
 mm/page_isolation.c | 16 ++++++++++------
 mm/sparse.c         |  2 +-
 4 files changed, 25 insertions(+), 12 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index cd23c081924d..8ffe844766da 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1580,7 +1580,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 {
 	unsigned long pfn, nr_pages;
 	long offlined_pages;
-	int ret, node;
+	int ret, node, count;
 	unsigned long flags;
 	unsigned long valid_start, valid_end;
 	struct zone *zone;
@@ -1606,10 +1606,11 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	ret = start_isolate_page_range(start_pfn, end_pfn,
 				       MIGRATE_MOVABLE,
 				       SKIP_HWPOISON | REPORT_FAILURE);
-	if (ret) {
+	if (ret < 0) {
 		reason = "failure to isolate range";
 		goto failed_removal;
 	}
+	count = ret;
 
 	arg.start_pfn = start_pfn;
 	arg.nr_pages = nr_pages;
@@ -1661,8 +1662,16 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	/* Ok, all of our target is isolated.
 	   We cannot do rollback at this point. */
 	offline_isolated_pages(start_pfn, end_pfn);
-	/* reset pagetype flags and makes migrate type to be MOVABLE */
-	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
+
+	/*
+	 * Onlining will reset pagetype flags and makes migrate type
+	 * MOVABLE, so just need to decrease the number of isolated
+	 * pageblocks zone counter here.
+	 */
+	spin_lock_irqsave(&zone->lock, flags);
+	zone->nr_isolate_pageblock -= count;
+	spin_unlock_irqrestore(&zone->lock, flags);
+
 	/* removal success */
 	adjust_managed_page_count(pfn_to_page(start_pfn), -offlined_pages);
 	zone->present_pages -= offlined_pages;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 03fcf73d47da..d96ca5bc555b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -8233,7 +8233,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 
 	ret = start_isolate_page_range(pfn_max_align_down(start),
 				       pfn_max_align_up(end), migratetype, 0);
-	if (ret)
+	if (ret < 0)
 		return ret;
 
 	/*
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index ce323e56b34d..bf67b63227ca 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -172,7 +172,8 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
  * future will not be allocated again.
  *
  * start_pfn/end_pfn must be aligned to pageblock_order.
- * Return 0 on success and -EBUSY if any part of range cannot be isolated.
+ * Return the number of isolated pageblocks on success and -EBUSY if any part of
+ * range cannot be isolated.
  *
  * There is no high level synchronization mechanism that prevents two threads
  * from trying to isolate overlapping ranges.  If this happens, one thread
@@ -188,6 +189,7 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 	unsigned long pfn;
 	unsigned long undo_pfn;
 	struct page *page;
+	int count = 0;
 
 	BUG_ON(!IS_ALIGNED(start_pfn, pageblock_nr_pages));
 	BUG_ON(!IS_ALIGNED(end_pfn, pageblock_nr_pages));
@@ -196,13 +198,15 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 	     pfn < end_pfn;
 	     pfn += pageblock_nr_pages) {
 		page = __first_valid_page(pfn, pageblock_nr_pages);
-		if (page &&
-		    set_migratetype_isolate(page, migratetype, flags)) {
-			undo_pfn = pfn;
-			goto undo;
+		if (page) {
+			if (set_migratetype_isolate(page, migratetype, flags)) {
+				undo_pfn = pfn;
+				goto undo;
+			}
+			count++;
 		}
 	}
-	return 0;
+	return count;
 undo:
 	for (pfn = start_pfn;
 	     pfn < undo_pfn;
diff --git a/mm/sparse.c b/mm/sparse.c
index 69904aa6165b..56e057c432f9 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -567,7 +567,7 @@ void online_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-/* Mark all memory sections within the pfn range as online */
+/* Mark all memory sections within the pfn range as offline */
 void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 {
 	unsigned long pfn;
-- 
2.17.2 (Apple Git-113)

