Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id B633D6B006C
	for <linux-mm@kvack.org>; Fri,  6 Jan 2012 12:39:02 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id c41so1435832eek.14
        for <linux-mm@kvack.org>; Fri, 06 Jan 2012 09:39:02 -0800 (PST)
Subject: [PATCH 3/3] mm: adjust rss counters for migration entiries
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Fri, 06 Jan 2012 21:38:56 +0400
Message-ID: <20120106173856.11700.98858.stgit@zurg>
In-Reply-To: <20120106173827.11700.74305.stgit@zurg>
References: <20120106173827.11700.74305.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Memory migration fill pte with migration entry and it didn't update rss counters.
Then it replace migration entry with new page (or old one if migration was failed).
But between this two passes this pte can be unmaped, or task can fork child and
it will get copy of this migration entry. Nobody account this into rss counters.

This patch properly adjust rss counters for migration entries in zap_pte_range()
and copy_one_pte(). Thus we avoid extra atomic operations on migration fast-path.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/memory.c |   37 ++++++++++++++++++++++++++++---------
 1 files changed, 28 insertions(+), 9 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 829d437..2f96ffc 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -878,15 +878,24 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 			}
 			if (likely(!non_swap_entry(entry)))
 				rss[MM_SWAPENTS]++;
-			else if (is_write_migration_entry(entry) &&
-					is_cow_mapping(vm_flags)) {
-				/*
-				 * COW mappings require pages in both parent
-				 * and child to be set to read.
-				 */
-				make_migration_entry_read(&entry);
-				pte = swp_entry_to_pte(entry);
-				set_pte_at(src_mm, addr, src_pte, pte);
+			else if (is_migration_entry(entry)) {
+				page = migration_entry_to_page(entry);
+
+				if (PageAnon(page))
+					rss[MM_ANONPAGES]++;
+				else
+					rss[MM_FILEPAGES]++;
+
+				if (is_write_migration_entry(entry) &&
+				    is_cow_mapping(vm_flags)) {
+					/*
+					 * COW mappings require pages in both
+					 * parent and child to be set to read.
+					 */
+					make_migration_entry_read(&entry);
+					pte = swp_entry_to_pte(entry);
+					set_pte_at(src_mm, addr, src_pte, pte);
+				}
 			}
 		}
 		goto out_set_pte;
@@ -1191,6 +1200,16 @@ again:
 
 			if (!non_swap_entry(entry))
 				rss[MM_SWAPENTS]--;
+			else if (is_migration_entry(entry)) {
+				struct page *page;
+
+				page = migration_entry_to_page(entry);
+
+				if (PageAnon(page))
+					rss[MM_ANONPAGES]--;
+				else
+					rss[MM_FILEPAGES]--;
+			}
 			if (unlikely(!free_swap_and_cache(entry)))
 				print_bad_pte(vma, addr, ptent, NULL);
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
