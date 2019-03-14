Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7AF07C10F06
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 15:07:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB7EE20811
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 15:07:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="DstI7JL/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB7EE20811
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46FC18E0003; Thu, 14 Mar 2019 11:07:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F5CC8E0001; Thu, 14 Mar 2019 11:07:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 297658E0003; Thu, 14 Mar 2019 11:07:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0319A8E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 11:07:31 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id x12so5681848qtk.2
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 08:07:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=qqKKYwmNOJL5Qk/cT18HRvgYusMPXha156/gW8h/2Lk=;
        b=HXyhIDQosPy/IvUzfIj9BadYhsab7yVMNeUuu6/37KlUYQiNJK5Aa4alucCKCefuMa
         Qcp2tFJdmVZWuPNL+HtKo+XXNwKlVwDWyk7HbflEvbTAHFARVlXrNBzuwiJj/l00s+jD
         MMsblxxpvs8U8SZOsuEIycXAKbDtDsb2qifcvJLNWgZs5PtpSvNRmu/JM/5f2Zmn+8I4
         UsO2qzkadaoqcyrZDJrkENm3FZA1S289BVX45rZSIRm+e9nKT0hl5n8tiu/8BCvrdZIM
         wrJtwQ3xaroqlEyERNsyMl6WlCH8M2phh7oIX4i2q7k6OkZdML+KZ6hsbR0wPE5mhIGb
         lASw==
X-Gm-Message-State: APjAAAVdkvIzudLn8T3EZ9uGO5pr7IB6cNwzgyE8VKNBEscgz+bs81kc
	XCb43QRMVS7WWiRpMEzf2e2qqvZJKFJ498NpdLK21bCbAjPSdCCw2h7u83J0Tgw8zSXmIDM/vmm
	q4uKqWt5SOKhOmVQkY0+0emIvifnBCK01pKiMdI/ctfRZbXdEi4GuVQG6HlVb/GXJAYFH26J6dI
	GECvTLOtikRHy4BF3u2/wpEf8IF0rCMIxCCn2eVVrkfFT9r5T3bGtIhak/s6UNwMeOyjvcTMFRG
	BhhT5PSLWLh3Y1XKOm00zlA7M3KnWuNxWlrPL30f7QcinxSa2NsqDqfUvLKZRTMHtwEBQO4WQ1v
	1uPlNeMuQYOw4clp9vI0LQEKvK2nw77wjLaqPGanMjsF37TKrRwTlGTXoxyNdg4XYK+CZ3vbwI9
	R
X-Received: by 2002:aed:3c0f:: with SMTP id t15mr39935565qte.282.1552576050746;
        Thu, 14 Mar 2019 08:07:30 -0700 (PDT)
X-Received: by 2002:aed:3c0f:: with SMTP id t15mr39935429qte.282.1552576049304;
        Thu, 14 Mar 2019 08:07:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552576049; cv=none;
        d=google.com; s=arc-20160816;
        b=TEA3qoiOLxQZozp2LyJFv7DoGUQnfUOlTAIcZkSGh+tXlfpg2WjYj1RiMmstF1yPxj
         79/VtXROOMPP0Z9hT78RVPhwsof45ql5oDSX3P7TX7WVJmhI9yCSbq+398bm1KDKw8EV
         G6YlhtcBZrWjne+Gt02dDqHkL0SCI6o6bpJBOmeoKyKea9ZymP5ch2lXff1lBs8RvbOW
         Ms7kV01Ty28tRcooVB76O2cPwbW/I8iCFe7VhR5hDLklOUQjQBUgbrkwqeOC7s6Bwxkd
         7N12uT1Ej57kLV/BCjqJmhAcN2EVZu2qncWnorJjqdG6hd16p6Ydlq6ZSnpe3lzN45lz
         l07A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=qqKKYwmNOJL5Qk/cT18HRvgYusMPXha156/gW8h/2Lk=;
        b=yKOwfMJv0YRFxqzs+K3tVsJMQEhK7+dz8+kyVkeefvu3thDZngDTTJOpgTn8Ae2+AK
         nzIP7sFdRQzsEjEd3XSxDv0s+P/kkRvRLtlzRhWCpOsbKSEKmEJJlXg3xItHDbV3YXQe
         DKX9NMXcEr9P8thVrOUJOOxBhvLxy1y8ZTVWFv98KAIOuLBAd/+wvK0OeFUvhepNjC7i
         QaOUNZIxElHE+j/3sl/AVyxqr9SDh9zTcimJZyz0B+hvwR00zvceqZC/+1OrtTlvQF4j
         G29oxYdRZdBYxhLq+U9bFsYnUzG+DPxYQniOjTJdJm9Z/wokOmcuaZiMboX6Wqc6W1Qm
         NxeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="DstI7JL/";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l8sor16502512qve.69.2019.03.14.08.07.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Mar 2019 08:07:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="DstI7JL/";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=qqKKYwmNOJL5Qk/cT18HRvgYusMPXha156/gW8h/2Lk=;
        b=DstI7JL/Z5AiJFF5vjgNuV2JA4zQdDoj5REPrMwOQgZf/dhXjpEt8Mjt1hfKXSmD/E
         E67AM6dfQaoilfbNoExl9s8VvWCHjwu9K4JzLH0MOXZhpCNv6XfSWNOThVeRU8Vs0YBS
         mLnps2OsKyjyzGBSbdBlCagFrEyPj2z+TWcGXhuPxhyFBi9yEOc1Ygw9QArrffp/ha1J
         N1gDzdMvJxqUXkkaglXgBD8R9+OWLXlsl7XyADdFPuXwqC4BSJmCSP1MwHWvvH+vROUR
         6pUUADRRlFW8TnNJLIAit5hQ1VvIdVYrUgYjldjV2ttZNrcnTSjB9JjGDq19CLjLuO+b
         LGCg==
X-Google-Smtp-Source: APXvYqwaEgkBSRtGZ+3Kzu6OboY4VESMBKovz2oX88xWy78iykW6Qz8eLVKgxJuum11rUXQZ3/A3Jg==
X-Received: by 2002:a0c:be8f:: with SMTP id n15mr5487125qvi.203.1552576048742;
        Thu, 14 Mar 2019 08:07:28 -0700 (PDT)
Received: from ovpn-121-103.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id q5sm10185705qtc.37.2019.03.14.08.07.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 08:07:27 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: mhocko@kernel.org,
	osalvador@suse.de,
	vbabka@suse.cz,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>,
	stable@vger.kernel.org
Subject: [PATCH v4] mm/hotplug: fix offline undo_isolate_page_range()
Date: Thu, 14 Mar 2019 11:06:41 -0400
Message-Id: <20190314150641.59358-1-cai@lca.pw>
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
the above commit introduced.

Even if alloc_contig_range() can be used to isolate 16GB-hugetlb pages
on ppc64, an "int" should still be enough to represent the number of
pageblocks there. Fix an incorrect comment along the way.

Fixes: 2ce13640b3f4 ("mm: __first_valid_page skip over offline pages")
Cc: <stable@vger.kernel.org> # v4.13+
Acked-by: Michal Hocko <mhocko@suse.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Signed-off-by: Qian Cai <cai@lca.pw>
---

v4: Further consolidate comments.
    Turn on kernel-doc and add a stable tag per Michal.
v3: Reconstruct the kernel-doc comments.
    Use a more meaningful variable name per Oscar.
    Update the commit log a bit.
v2: Return the nubmer of isolated pageblocks in start_isolate_page_range() per
    Oscar; take the zone lock when undoing zone->nr_isolate_pageblock per
    Michal.

 include/linux/page-isolation.h | 10 -------
 mm/memory_hotplug.c            | 17 +++++++++---
 mm/page_alloc.c                |  2 +-
 mm/page_isolation.c            | 48 +++++++++++++++++++++-------------
 mm/sparse.c                    |  2 +-
 5 files changed, 45 insertions(+), 34 deletions(-)

diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 4eb26d278046..280ae96dc4c3 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -41,16 +41,6 @@ int move_freepages_block(struct zone *zone, struct page *page,
 
 /*
  * Changes migrate type in [start_pfn, end_pfn) to be MIGRATE_ISOLATE.
- * If specified range includes migrate types other than MOVABLE or CMA,
- * this will fail with -EBUSY.
- *
- * For isolating all pages in the range finally, the caller have to
- * free all pages in the range. test_page_isolated() can be used for
- * test it.
- *
- * The following flags are allowed (they can be combined in a bit mask)
- * SKIP_HWPOISON - ignore hwpoison pages
- * REPORT_FAILURE - report details about the failure to isolate the range
  */
 int
 start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d63c5a2959cf..cd1a8c4c6183 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1580,7 +1580,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 {
 	unsigned long pfn, nr_pages;
 	long offlined_pages;
-	int ret, node;
+	int ret, node, nr_isolate_pageblock;
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
+	nr_isolate_pageblock = ret;
 
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
+	zone->nr_isolate_pageblock -= nr_isolate_pageblock;
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
index e8baab91b1d1..019280712e1b 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -161,27 +161,36 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
 	return NULL;
 }
 
-/*
- * start_isolate_page_range() -- make page-allocation-type of range of pages
- * to be MIGRATE_ISOLATE.
- * @start_pfn: The lower PFN of the range to be isolated.
- * @end_pfn: The upper PFN of the range to be isolated.
- * @migratetype: migrate type to set in error recovery.
+/**
+ * start_isolate_page_range() - make page-allocation-type of range of pages to
+ * be MIGRATE_ISOLATE.
+ * @start_pfn:		The lower PFN of the range to be isolated.
+ * @end_pfn:		The upper PFN of the range to be isolated.
+ *			start_pfn/end_pfn must be aligned to pageblock_order.
+ * @migratetype:	Migrate type to set in error recovery.
+ * @flags:		The following flags are allowed (they can be combined in
+ *			a bit mask)
+ *			SKIP_HWPOISON - ignore hwpoison pages
+ *			REPORT_FAILURE - report details about the failure to
+ *			isolate the range
  *
  * Making page-allocation-type to be MIGRATE_ISOLATE means free pages in
  * the range will never be allocated. Any free pages and pages freed in the
- * future will not be allocated again.
- *
- * start_pfn/end_pfn must be aligned to pageblock_order.
- * Return 0 on success and -EBUSY if any part of range cannot be isolated.
+ * future will not be allocated again. If specified range includes migrate types
+ * other than MOVABLE or CMA, this will fail with -EBUSY. For isolating all
+ * pages in the range finally, the caller have to free all pages in the range.
+ * test_page_isolated() can be used for test it.
  *
  * There is no high level synchronization mechanism that prevents two threads
- * from trying to isolate overlapping ranges.  If this happens, one thread
+ * from trying to isolate overlapping ranges. If this happens, one thread
  * will notice pageblocks in the overlapping range already set to isolate.
  * This happens in set_migratetype_isolate, and set_migratetype_isolate
- * returns an error.  We then clean up by restoring the migration type on
- * pageblocks we may have modified and return -EBUSY to caller.  This
+ * returns an error. We then clean up by restoring the migration type on
+ * pageblocks we may have modified and return -EBUSY to caller. This
  * prevents two threads from simultaneously working on overlapping ranges.
+ *
+ * Return: the number of isolated pageblocks on success and -EBUSY if any part
+ * of range cannot be isolated.
  */
 int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 			     unsigned migratetype, int flags)
@@ -189,6 +198,7 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 	unsigned long pfn;
 	unsigned long undo_pfn;
 	struct page *page;
+	int nr_isolate_pageblock = 0;
 
 	BUG_ON(!IS_ALIGNED(start_pfn, pageblock_nr_pages));
 	BUG_ON(!IS_ALIGNED(end_pfn, pageblock_nr_pages));
@@ -197,13 +207,15 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
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
+			nr_isolate_pageblock++;
 		}
 	}
-	return 0;
+	return nr_isolate_pageblock;
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

