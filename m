Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 733AAC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 14:07:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECCD92070D
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 14:07:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="kcH9UPV3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECCD92070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D1508E0003; Thu, 14 Mar 2019 10:07:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 457608E0001; Thu, 14 Mar 2019 10:07:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F9488E0003; Thu, 14 Mar 2019 10:07:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0BFFB8E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 10:07:16 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id 77so2925789qkd.9
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 07:07:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=5iJnHF8Pb0pzI2sh2ryvQW8OFemSrBwyS9FuB9ORbTA=;
        b=RKPJZI84Ev/FrR1fk0c5W2ZEXH9Dhe+bZRYlMZQtGfjjb9vT4bhOENe6UYCsx7Ae/a
         dJ0d5BQxmwAfUT15BIpE9K0UTs6pMMHOppAxhmJ3LvvmCPWv4RYJ7vh5zfx0+5mpPYyA
         db0Q11mFUW+YOeVQkmdz9gOm2M3gcGAfiFtMI3SH8XJpbzHVKc3pJFtFUfbKlRtMe0N8
         MAx8zY6NH0UHdaHt5UdxwGPUSwpSqK7GxFxu2VU3/UuNdZDaGGwRKykJqIeB2dCNeeyN
         pnCuIE5eM00wbXsi77X22i+vhumlf2PprytJWxvT9EWoV7meBV3+D9cVELj3LmnZheA2
         m0Ug==
X-Gm-Message-State: APjAAAX62NlD4U3038haWYL2Ww+drLNJN/utqxj66mPqn2txeieesyL7
	2mOQBI5diwMZ+ogXjS7PKlqtu5b0hyDNp2eXoh6x4q5P6wjgUjK6lJJDjsu35FQ4+KkpL/o+neC
	0OWa00NODPj0DiyxLjdNGe8T6uHxcviMdaX9AGauo9Mii07P0WDh0cT8iZOWwhU70A12hKOsb+9
	KazmSRriJILb8EvH2mCPeo6xzZab5k5rE0x/453GYt7dbf1sH0aRYazyXoZs4/X7uSBcvv+IN8t
	wPpsWLB1In9ZaS22sPawecuZEhwwJHrYUShrvdqqDQY2WBxCyPEUW2R768ybWUrMLfJWMePNQwX
	nyY9VjfUFB+9OWp+ghYZtS0+OqAvvVa3AneDLEULsXiRSRB94WAMmpHSX+Uzlg3uemevKIjtLKs
	X
X-Received: by 2002:a0c:c30e:: with SMTP id f14mr6550526qvi.195.1552572435747;
        Thu, 14 Mar 2019 07:07:15 -0700 (PDT)
X-Received: by 2002:a0c:c30e:: with SMTP id f14mr6550425qvi.195.1552572434342;
        Thu, 14 Mar 2019 07:07:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552572434; cv=none;
        d=google.com; s=arc-20160816;
        b=Wl6t78P7Qrnpv0XyPKONnf36pm8JSu/3PPajkSTKUdi3PainUxl1LFsVYZvj9zt7Lu
         6d498cKlAobyRd0LzATx6rHYbL3iks7yTjuIWg5CdXZuCAZurErp4pQWM6tmPzAJ8lF2
         Sp7mSS1OYQsGLsMHOA3G/R56XcQLqF3shFtmk+x2qNuXfciBya7I3ry1Hn5OHrqP5dmF
         X/XXkfJcgnSt2SzcfH/K1NBI6hk7JoX/DE6GG0cPDyjWJbCa59q8nlN9d3G0gfGSCd+g
         bQWVjV2xPtQBNXNz1BVbLVEZqpEMYp60Jd+k2FzHrzZwsIwYBPUIUZbJPNgza7hKLcWM
         bdZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=5iJnHF8Pb0pzI2sh2ryvQW8OFemSrBwyS9FuB9ORbTA=;
        b=dEpximRd04kmFirrXfVfmDf/RnBUvyxi9KwBsIRzhENMrmNohIPhNo3aR1JNbg91BF
         Y9L3R0FkkIJo/MZgddPSqSp2SkbgiEyvp3vf94yKq+YAzRXCFzhCVYWdhyYYT5LDkgcM
         n09yP9j+tJq0dMkXWiodaUtIkGmgGSt09kuPs6aeAWC07jl+r2fcGDU2J9q0kUbiO4+v
         e//99NBlomh+psbTb3OqMTUZp85ElGbkWxk85xCS/XVZuHQ5OXOomiNzGgazLfBmpqqb
         mrvxbdnWoy1IrP2pzfmOK2rTNkXb3/tjQzCPwBg/MgGXY/F7U7SFOwXEugYqeZPcHx6Z
         sx9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=kcH9UPV3;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h11sor9474713qta.48.2019.03.14.07.07.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Mar 2019 07:07:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=kcH9UPV3;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=5iJnHF8Pb0pzI2sh2ryvQW8OFemSrBwyS9FuB9ORbTA=;
        b=kcH9UPV3qou2OsNGhvYwYsqaZdVn8ZaikfS6iaTqLzE0q2hhSoNgjcAjr2KfWgohlD
         a1WQnLT80jqeV3EAEsvKk7lJTIwHH5GcatsSOLa8zCn5eIIYSp6D/4a6aar8uGg52B64
         +EDjdlN4mABlJImSorOS7PsU7faoekQuXvuxVjqhm1UDbNOrGgyf1mS46ZqCGDPSVw2M
         omBvHGtgV1cMlZPqQ0ao/QX1QeZZo4N3b0AHmAPGXeRhlRiXqR9CADxLodahwfWiV3DV
         7BtaUPZnnJDeT8neEZTp2eRVeIuIJJ96NmAbLq4XPVayngQHwZfaI+at//OAv7PIUUQv
         6Ktw==
X-Google-Smtp-Source: APXvYqwY1Ga7bUmn9ECzxYvaz4veSE3FmtrAZb/U7jldjkgjIw0VhM+ZRUdEBMPadnA+jQFidgIjJw==
X-Received: by 2002:aed:3608:: with SMTP id e8mr39425056qtb.31.1552572433845;
        Thu, 14 Mar 2019 07:07:13 -0700 (PDT)
Received: from ovpn-121-103.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id c2sm11636828qtc.41.2019.03.14.07.07.12
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 07:07:13 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: mhocko@kernel.org,
	osalvador@suse.de,
	vbabka@suse.cz,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH v3] mm/hotplug: fix offline undo_isolate_page_range()
Date: Thu, 14 Mar 2019 10:06:54 -0400
Message-Id: <20190314140654.58883-1-cai@lca.pw>
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
Signed-off-by: Qian Cai <cai@lca.pw>
---

v3: Reconstruct the kernel-doc comments.
    Use a more meaningful variable name per Oscar.
    Update the commit log a bit.
v2: Return the nubmer of isolated pageblocks in start_isolate_page_range() per
    Oscar; take the zone lock when undoing zone->nr_isolate_pageblock per
    Michal.

 include/linux/page-isolation.h |  4 ----
 mm/memory_hotplug.c            | 17 +++++++++++++----
 mm/page_alloc.c                |  2 +-
 mm/page_isolation.c            | 35 +++++++++++++++++++++-------------
 mm/sparse.c                    |  2 +-
 5 files changed, 37 insertions(+), 23 deletions(-)

diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 4eb26d278046..5b24d56b2296 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -47,10 +47,6 @@ int move_freepages_block(struct zone *zone, struct page *page,
  * For isolating all pages in the range finally, the caller have to
  * free all pages in the range. test_page_isolated() can be used for
  * test it.
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
index e8baab91b1d1..dd7c002cd5ae 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -162,19 +162,22 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
 }
 
 /*
- * start_isolate_page_range() -- make page-allocation-type of range of pages
- * to be MIGRATE_ISOLATE.
- * @start_pfn: The lower PFN of the range to be isolated.
- * @end_pfn: The upper PFN of the range to be isolated.
- * @migratetype: migrate type to set in error recovery.
+ * start_isolate_page_range() - make page-allocation-type of range of pages to
+ * be MIGRATE_ISOLATE.
+ * @start_pfn:		The lower PFN of the range to be isolated.
+ * @end_pfn:		The upper PFN of the range to be isolated.
+ *			start_pfn/end_pfn must be aligned to pageblock_order.
+ * @migratetype:	migrate type to set in error recovery.
+ * @flags:		The following flags are allowed (they can be combined in
+ *			a bit mask)
+ *			SKIP_HWPOISON - ignore hwpoison pages
+ *			REPORT_FAILURE - report details about the failure to
+ *			isolate the range
  *
  * Making page-allocation-type to be MIGRATE_ISOLATE means free pages in
  * the range will never be allocated. Any free pages and pages freed in the
  * future will not be allocated again.
  *
- * start_pfn/end_pfn must be aligned to pageblock_order.
- * Return 0 on success and -EBUSY if any part of range cannot be isolated.
- *
  * There is no high level synchronization mechanism that prevents two threads
  * from trying to isolate overlapping ranges.  If this happens, one thread
  * will notice pageblocks in the overlapping range already set to isolate.
@@ -182,6 +185,9 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
  * returns an error.  We then clean up by restoring the migration type on
  * pageblocks we may have modified and return -EBUSY to caller.  This
  * prevents two threads from simultaneously working on overlapping ranges.
+ *
+ * Return: the number of isolated pageblocks on success and -EBUSY if any part
+ * of range cannot be isolated.
  */
 int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 			     unsigned migratetype, int flags)
@@ -189,6 +195,7 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 	unsigned long pfn;
 	unsigned long undo_pfn;
 	struct page *page;
+	int nr_isolate_pageblock = 0;
 
 	BUG_ON(!IS_ALIGNED(start_pfn, pageblock_nr_pages));
 	BUG_ON(!IS_ALIGNED(end_pfn, pageblock_nr_pages));
@@ -197,13 +204,15 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
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

