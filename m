Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C48586B01F4
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 18:37:48 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 1/2] mm,migration: During fork(), wait for migration to end if migration PTE is encountered
Date: Mon, 26 Apr 2010 23:37:57 +0100
Message-Id: <1272321478-28481-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1272321478-28481-1-git-send-email-mel@csn.ul.ie>
References: <1272321478-28481-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

At page migration, we replace pte with migration_entry, which has
similar format as swap_entry and replace it with real pfn at the
end of migration. But there is a race with fork()'s copy_page_range().

Assume page migraion on CPU A and fork in CPU B. On CPU A, a page of
a process is under migration. On CPU B, a page's pte is under copy.

	CPUA			CPU B
				do_fork()
				copy_mm() (from process 1 to process2)
				insert new vma to mmap_list (if inode/anon_vma)
	pte_lock(process1)
	unmap a page
	insert migration_entry
	pte_unlock(process1)

	migrate page copy
				copy_page_range
	remap new page by rmap_walk()
	pte_lock(process2)
	found no pte.
	pte_unlock(process2)
				pte lock(process2)
				pte lock(process1)
				copy migration entry to process2
				pte unlock(process1)
				pte unlokc(process2)
	pte_lock(process1)
	replace migration entry
	to new page's pte.
	pte_unlock(process1)

Then, some serialization is necessary. IIUC, this is very rare event but
it is reproducible if a lot of migration is happening a lot with the
following program running in parallel.

    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <sys/mman.h>

    #define SIZE (24*1048576UL)
    #define CHILDREN 100
    int main()
    {
	    int i = 0;
	    pid_t pids[CHILDREN];
	    char *buf = mmap(NULL, SIZE, PROT_READ|PROT_WRITE,
			    MAP_PRIVATE|MAP_ANONYMOUS,
			    0, 0);
	    if (buf == MAP_FAILED) {
		    perror("mmap");
		    exit(-1);
	    }

	    while (++i) {
		    int j = i % CHILDREN;

		    if (j == 0) {
			    printf("Waiting on children\n");
			    for (j = 0; j < CHILDREN; j++) {
				    memset(buf, i, SIZE);
				    if (pids[j] != -1)
					    waitpid(pids[j], NULL, 0);
			    }
			    j = 0;
		    }

		    if ((pids[j] = fork()) == 0) {
			    memset(buf, i, SIZE);
			    exit(EXIT_SUCCESS);
		    }
	    }

	    munmap(buf, SIZE);
    }

copy_page_range() can wait for the end of migration.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/memory.c |   24 +++++++++++++++---------
 1 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 833952d..36dadd4 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -675,15 +675,8 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
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
+			else {
+				BUG();
 			}
 		}
 		goto out_set_pte;
@@ -760,6 +753,19 @@ again:
 			progress++;
 			continue;
 		}
+		if (unlikely(!pte_present(*src_pte) && !pte_file(*src_pte))) {
+			entry = pte_to_swp_entry(*src_pte);
+			if (is_migration_entry(entry)) {
+				/*
+				 * Because copying pte has the race with
+				 * pte rewriting of migraton, release lock
+				 * and retry.
+				 */
+				progress = 0;
+				entry.val = 0;
+				break;
+			}
+		}
 		entry.val = copy_one_pte(dst_mm, src_mm, dst_pte, src_pte,
 							vma, addr, rss);
 		if (entry.val)
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
