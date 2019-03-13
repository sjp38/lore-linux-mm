Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC3D2C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 01:42:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51E2D2177E
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 01:42:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="e7XyM4kB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51E2D2177E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FEDD8E0003; Tue, 12 Mar 2019 21:42:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9AE178E0002; Tue, 12 Mar 2019 21:42:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C43C8E0003; Tue, 12 Mar 2019 21:42:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 64BD28E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 21:42:33 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id k21so213904qkg.19
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:42:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=NQfucrhbD0VzPNhfRkKgVrADDarqnaY6kdS2R65H4Ys=;
        b=MBZw/2/e/nNRVISYKwYdzfUeYcs/vcLCEdrQYczXFKsCIf06cByEupjAorVcB22ThE
         VLi515W4UPyUq/oMcbetuplaG5fCH8/toRCRNmwrG3/j0+yh36rLz5MvfmzmqIALj4DM
         +5f2WZ1Qo6aAeDcPQJXml41RiJ4kwMiFu2DKAK01c3/2EoTZkZigvPTJmT8MefPyZk5q
         KWOhHVp9NFvNiMSdfph4I/kMRR1OdHPup4W46EhpZxHkF4IDx3LKws3TP0OqwfnGQb3m
         nv59Zt4FrQyCAxb406Mp2gu21r9eoxYX2sfGVzcD7GHDbndaC46gKHu6e6u/qVASlWFy
         q3Ow==
X-Gm-Message-State: APjAAAVQeaArIk2XtFPl4K8D/8kYuaIkDXHjhRV/KJk+HySxlvhwsCIL
	7z7eA1z9bZ+afaqC7cjll3lmVRdntqcFqN+8pvfP9MBglVQXZw3+aEy3ghucfC98RLAdw+p6yw3
	DFC2sW0SJ3tUhNN/mNLxUHD9KoHepj9Mn0Y7aZKlGonbOioJ0h+dINWUxLnr3JKvHG7wGkqOjc6
	dAT1XPcjbVU3kE1Rm2Iu8QDexlrpIHyZirdmmT6o1fH59rD6FbipfvesSibzoBWVZldI8CbonU8
	PUAi6jsQaRrT4xxa7yy2ltnIUrh1sUS8OeRh54feenREKTNj5dQG4fzEGxB4xIVCQ1jQokyw4Bi
	yVk7/tXvqZievL60HKDVjjUmlohjAQsANUmPBnzVuqJyRWglmOMxmy7z9clnyoDmxNbXzHhVU4r
	3
X-Received: by 2002:a37:7e83:: with SMTP id z125mr23034108qkc.351.1552441353143;
        Tue, 12 Mar 2019 18:42:33 -0700 (PDT)
X-Received: by 2002:a37:7e83:: with SMTP id z125mr23034080qkc.351.1552441352350;
        Tue, 12 Mar 2019 18:42:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552441352; cv=none;
        d=google.com; s=arc-20160816;
        b=dVWJzvSQZLhiHTUeQs+Y1eq/ISlKO3AKDBlXWP0RB/otLUvNHixfrkX4fJtRfIUGcF
         rW4FIwyFFOCS1UHCdYo3Gu922ChhwgTwb9JfRpjUNqjuuiXSUeKyerkuXWAMR+muoS4k
         gIluA0HwXS9bSqaInB49u0tfVInR07p/Q7mBA0+ZBs+Xi2K/b3gmc44pBdBHO/sdJXlp
         9Ie284fMzrTWWWn1HyfZSk090khzmMg82nyGCQou6nBDllw6iOufwFKPmRZIRp+x8FNz
         ZtwJPxYrDvUy9iEDCXy3+0THsQ6rzxsk8n5T2UmlwK1SIypVa8ULl4lDZQ55UPqaMO1g
         Q9RA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=NQfucrhbD0VzPNhfRkKgVrADDarqnaY6kdS2R65H4Ys=;
        b=y7T5yYiqADxUNO2Q2bGSy3RzGOq85Kn9Vpw+FdmXXiLCr1li8zFronvB78dEUOrCvq
         BssO8d8gaJiX4mXjPfCSBeQmktDJDQehVHqq2oZ7O+oqJiliUZwkfWvygFg+GGIrfX/B
         QPY+KTZJ8U2HsBSHuNGi63urTCLf5TulsH81Gd20i4TA4RlaH1m8SxpBvRI3c/BEKicD
         1mqDa3C0iN+T9eawvw6IgaaT4iHu09HyoVpn4wv/GlDff6GZWMOJEdCcXNj7WgRM8qSb
         GrW2I8aKbk+wI2Hv6O/4Fi/zU2+AOFxyNKIuTg5RF8KyMt79N4ZYgWefm9XxUzGLDON1
         XwTA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=e7XyM4kB;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v143sor5539547qka.108.2019.03.12.18.42.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 18:42:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=e7XyM4kB;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=NQfucrhbD0VzPNhfRkKgVrADDarqnaY6kdS2R65H4Ys=;
        b=e7XyM4kBeSQFwVYWCx0/Yxi0Qx9ADcd3TwYCdYNRuNf4al9WnSxZAeYjZmNPaWxyIs
         VklR/LEo84lmUJia9s7w5DrGdLEj87JIckavIKkKWVWYSt9UNH808J3ffoqwtRkv7Oz+
         RZFUe1YXjz+HvfvVk7+ztrqd1/2HkC03kOUJw9t5KpLZyCqBysEdOV/8Hs6k+e53j0ah
         ajHGF4iWjvHYXnnv3jAqn+LTemgh8BV34HyFwH23ao/qh8oHehgXhJro34Gc/uY8kWhZ
         Qfog2rea4i0y8vTER1HoCgAB7WhHgnO43D8lhVoOi+0DgNU0Chk4IVgKZk947gvy3rRz
         tR+w==
X-Google-Smtp-Source: APXvYqxYSU6Hctdcn1af2We1tjwMEFTeS7kbgBVB6LLHwgPjs07KCSeVn3dtDT4JtYQzYlmbGQD9zQ==
X-Received: by 2002:a37:c9d9:: with SMTP id m86mr11303831qkl.174.1552441352093;
        Tue, 12 Mar 2019 18:42:32 -0700 (PDT)
Received: from ovpn-121-103.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id s187sm4894678qkh.76.2019.03.12.18.42.31
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 18:42:31 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: osalvador@suse.de,
	mhocko@kernel.org,
	vbabka@suse.cz,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] mm/hotplug: fix offline undo_isolate_page_range()
Date: Tue, 12 Mar 2019 21:42:16 -0400
Message-Id: <20190313014216.36782-1-cai@lca.pw>
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
the above commit introduced. Fix an incorrect comment along the way.

Fixes: 2ce13640b3f4 ("mm: __first_valid_page skip over offline pages")
Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/memory_hotplug.c | 18 ++++++++++++++++--
 mm/sparse.c         |  2 +-
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index cd23c081924d..260a8e943483 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1661,8 +1661,22 @@ static int __ref __offline_pages(unsigned long start_pfn,
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
+	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
+		int i;
+
+		for (i = 0; i < pageblock_nr_pages; i++)
+			if (pfn_valid_within(pfn + i)) {
+				zone->nr_isolate_pageblock--;
+				break;
+			}
+	}
+
 	/* removal success */
 	adjust_managed_page_count(pfn_to_page(start_pfn), -offlined_pages);
 	zone->present_pages -= offlined_pages;
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

