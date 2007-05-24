Message-Id: <200705242357.l4ONvw49006681@shell0.pdx.osdl.net>
Subject: [patch 1/1] vmscan: give referenced, active and unmapped pages a second trip around the LRU
From: akpm@linux-foundation.org
Date: Thu, 24 May 2007 16:57:58 -0700
Sender: owner-linux-mm@kvack.org
From: Andrew Morton <akpm@linux-foundation.org>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mbligh@mbligh.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Martin spotted this.

In the original rmap conversion in 2.5.32 we broke aging of pagecache pages on
the active list: we deactivate these pages even if they had PG_referenced set.

We should instead clear PG_referenced and give these pages another trip around
the active list.

We have basically no way of working out whether or not this change will
benefit or worsen anything.

Cc: Martin Bligh <mbligh@mbligh.org>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/vmscan.c |    3 +++
 1 files changed, 3 insertions(+)

diff -puN mm/vmscan.c~vmscan-give-referenced-active-and-unmapped-pages-a-second-trip-around-the-lru mm/vmscan.c
--- a/mm/vmscan.c~vmscan-give-referenced-active-and-unmapped-pages-a-second-trip-around-the-lru
+++ a/mm/vmscan.c
@@ -836,6 +836,9 @@ force_reclaim_mapped:
 				list_add(&page->lru, &l_active);
 				continue;
 			}
+		} else if (TestClearPageReferenced(page)) {
+			list_add(&page->lru, &l_active);
+			continue;
 		}
 		list_add(&page->lru, &l_inactive);
 	}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
