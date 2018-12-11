Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6D63D8E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:27:53 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id y35so7044193edb.5
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 06:27:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p7-v6sor4051488ejb.30.2018.12.11.06.27.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 06:27:51 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/3] mm, memory_hotplug: deobfuscate migration part of offlining
Date: Tue, 11 Dec 2018 15:27:40 +0100
Message-Id: <20181211142741.2607-3-mhocko@kernel.org>
In-Reply-To: <20181211142741.2607-1-mhocko@kernel.org>
References: <20181211142741.2607-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>

From: Michal Hocko <mhocko@suse.com>

Memory migration might fail during offlining and we keep retrying in
that case. This is currently obfuscate by goto retry loop. The code
is hard to follow and as a result it is even suboptimal becase each
retry round scans the full range from start_pfn even though we have
successfully scanned/migrated [start_pfn, pfn] range already. This
is all only because check_pages_isolated failure has to rescan the full
range again.

De-obfuscate the migration retry loop by promoting it to a real for
loop. In fact remove the goto altogether by making it a proper double
loop (yeah, gotos are nasty in this specific case). In the end we
will get a slightly more optimal code which is better readable.

Reviewed-by: David Hildenbrand <david@redhat.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memory_hotplug.c | 58 ++++++++++++++++++++++-----------------------
 1 file changed, 29 insertions(+), 29 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 6263c8cd4491..c6c42a7425e5 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1591,38 +1591,38 @@ static int __ref __offline_pages(unsigned long start_pfn,
 		goto failed_removal_isolated;
 	}
 
-	pfn = start_pfn;
-repeat:
-	/* start memory hot removal */
-	ret = -EINTR;
-	if (signal_pending(current)) {
-		reason = "signal backoff";
-		goto failed_removal_isolated;
-	}
+	do {
+		for (pfn = start_pfn; pfn;) {
+			if (signal_pending(current)) {
+				ret = -EINTR;
+				reason = "signal backoff";
+				goto failed_removal_isolated;
+			}
 
-	cond_resched();
-	lru_add_drain_all();
-	drain_all_pages(zone);
+			cond_resched();
+			lru_add_drain_all();
+			drain_all_pages(zone);
 
-	pfn = scan_movable_pages(start_pfn, end_pfn);
-	if (pfn) { /* We have movable pages */
-		ret = do_migrate_range(pfn, end_pfn);
-		goto repeat;
-	}
+			pfn = scan_movable_pages(pfn, end_pfn);
+			if (pfn) {
+				/* TODO fatal migration failures should bail out */
+				do_migrate_range(pfn, end_pfn);
+			}
+		}
+
+		/*
+		 * dissolve free hugepages in the memory block before doing offlining
+		 * actually in order to make hugetlbfs's object counting consistent.
+		 */
+		ret = dissolve_free_huge_pages(start_pfn, end_pfn);
+		if (ret) {
+			reason = "failure to dissolve huge pages";
+			goto failed_removal_isolated;
+		}
+		/* check again */
+		offlined_pages = check_pages_isolated(start_pfn, end_pfn);
+	} while (offlined_pages < 0);
 
-	/*
-	 * dissolve free hugepages in the memory block before doing offlining
-	 * actually in order to make hugetlbfs's object counting consistent.
-	 */
-	ret = dissolve_free_huge_pages(start_pfn, end_pfn);
-	if (ret) {
-		reason = "failure to dissolve huge pages";
-		goto failed_removal_isolated;
-	}
-	/* check again */
-	offlined_pages = check_pages_isolated(start_pfn, end_pfn);
-	if (offlined_pages < 0)
-		goto repeat;
 	pr_info("Offlined Pages %ld\n", offlined_pages);
 	/* Ok, all of our target is isolated.
 	   We cannot do rollback at this point. */
-- 
2.19.2
