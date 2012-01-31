Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 877E56B002C
	for <linux-mm@kvack.org>; Tue, 31 Jan 2012 11:35:32 -0500 (EST)
Date: Tue, 31 Jan 2012 16:35:28 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: compaction: Check pfn_valid when entering a new
 MAX_ORDER_NR_PAGES block during isolation for migration
Message-ID: <20120131163528.GR4065@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Herbert van den Bergh <herbert.van.den.bergh@oracle.com>, Michal Nazarewicz <mina86@mina86.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

When isolating for migration, migration starts at the start of a zone
which is not necessarily pageblock aligned. Further, it stops isolating
when COMPACT_CLUSTER_MAX pages are isolated so migrate_pfn is generally
not aligned.

The problem is that pfn_valid is only called on the first PFN being
checked. Lets say we have a case like this

H = MAX_ORDER_NR_PAGES boundary
| = pageblock boundary
m = cc->migrate_pfn
f = cc->free_pfn
o = memory hole

H------|------H------|----m-Hoooooo|ooooooH-f----|------H

The migrate_pfn is just below a memory hole and the free scanner is
beyond the hole. When isolate_migratepages started, it scans from
migrate_pfn to migrate_pfn+pageblock_nr_pages which is now in a memory
hole. It checks pfn_valid() on the first PFN but then scans into the
hole where there are not necessarily valid struct pages.

This patch ensures that isolate_migratepages calls pfn_valid when
necessary.

Reported-and-tested-by: Herbert van den Bergh <herbert.van.den.bergh@oracle.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Michal Nazarewicz <mina86@mina86.com>
Cc: stable@kernel.org
---
 mm/compaction.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 899d956..edc1e26 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -313,6 +313,19 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 		} else if (!locked)
 			spin_lock_irq(&zone->lru_lock);
 
+		/*
+		 * migrate_pfn does not necessarily start aligned to a
+		 * pageblock. Ensure that pfn_valid is called when moving
+		 * into a new MAX_ORDER_NR_PAGES range in case of large
+		 * memory holes within the zone
+		 */
+		if ((low_pfn & (MAX_ORDER_NR_PAGES - 1)) == 0) {
+			if (!pfn_valid(low_pfn)) {
+				low_pfn += MAX_ORDER_NR_PAGES - 1;
+				continue;
+			}
+		}
+
 		if (!pfn_valid_within(low_pfn))
 			continue;
 		nr_scanned++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
