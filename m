Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1B0D58E0216
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 18:03:13 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e17so3418500edr.7
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 15:03:13 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id hk19-v6si195815ejb.253.2018.12.14.15.03.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 15:03:11 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 54D231C1D19
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 23:03:11 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 02/14] mm, compaction: Rearrange compact_control
Date: Fri, 14 Dec 2018 23:02:58 +0000
Message-Id: <20181214230310.572-3-mgorman@techsingularity.net>
In-Reply-To: <20181214230310.572-1-mgorman@techsingularity.net>
References: <20181214230310.572-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

compact_control spans two cache lines with write-intensive lines on
both. Rearrange so the most write-intensive fields are in the same
cache line. This has a negligible impact on the overall performance of
compaction and is more a tidying exercise than anything.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/internal.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 5564841fce36..867af5425432 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -184,14 +184,14 @@ extern int user_min_free_kbytes;
 struct compact_control {
 	struct list_head freepages;	/* List of free pages to migrate to */
 	struct list_head migratepages;	/* List of pages being migrated */
-	struct zone *zone;
 	unsigned int nr_freepages;	/* Number of isolated free pages */
 	unsigned int nr_migratepages;	/* Number of pages to migrate */
-	unsigned long total_migrate_scanned;
-	unsigned long total_free_scanned;
 	unsigned long free_pfn;		/* isolate_freepages search base */
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
 	unsigned long last_migrated_pfn;/* Not yet flushed page being freed */
+	struct zone *zone;
+	unsigned long total_migrate_scanned;
+	unsigned long total_free_scanned;
 	const gfp_t gfp_mask;		/* gfp mask of a direct compactor */
 	int order;			/* order a direct compactor needs */
 	int migratetype;		/* migratetype of direct compactor */
-- 
2.16.4
