Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 56A996B203E
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 08:43:39 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id w15so1282167edl.21
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 05:43:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p16-v6sor21836215eds.29.2018.11.20.05.43.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 05:43:37 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 2/3] mm, memory_hotplug: deobfuscate migration part of offlining
Date: Tue, 20 Nov 2018 14:43:22 +0100
Message-Id: <20181120134323.13007-3-mhocko@kernel.org>
In-Reply-To: <20181120134323.13007-1-mhocko@kernel.org>
References: <20181120134323.13007-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Hildenbrand <david@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

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

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memory_hotplug.c | 60 +++++++++++++++++++++++----------------------
 1 file changed, 31 insertions(+), 29 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 6263c8cd4491..9cd161db3061 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1591,38 +1591,40 @@ static int __ref __offline_pages(unsigned long start_pfn,
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
+		for (pfn = start_pfn; pfn;)
+		{
+			/* start memory hot removal */
+			ret = -EINTR;
+			if (signal_pending(current)) {
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
2.19.1
