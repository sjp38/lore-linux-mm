Date: Sat, 1 May 2004 00:54:08 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: rmap spin_trylock success rates
Message-Id: <20040501005408.1cd77796.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I applied the appended patch to determine the spin_trylock success rate in
rmap.c.  The machine is a single P4-HT pseudo-2-way.  256MB of memory and
the workload is a straightforward `usemem -m 400': allocate and touch 400MB
of memory.

page_referenced_one_miss = 4027
page_referenced_one_hit = 212605
try_to_unmap_one_miss = 3257
try_to_unmap_one_hit = 61153

That's a 5% failure rate in try_to_unmap_one()'s spin_trylock().

I suspect this is the reason for the problem which Martin Schwidefsky
reported a while back: this particular workload only achieves half the disk
bandwidth on SMP when compared with UP.  I poked around with that a bit at
the time and determined that it was due to poor I/O submission patterns. 
Increasing the disk queue from 128 slots to 1024 fixed it completely
because the request queue fixed up the bad I/O submission patterns.

With `./qsbench -p 4 -m 96':

page_referenced_one_miss = 401
page_referenced_one_hit = 1224748
try_to_unmap_one_miss = 103
try_to_unmap_one_hit = 339944

That's negligible.

I don't think we really need to do anything about this - the
everything-in-one-mm case isn't the most interesting situation.

In a way it's an argument for serialising the whole page reclaim path.

It'd be nice of we can reduce the page_table_lock hold times in there.

hm, now I'm confused.  We're running try_to_unmap_one() under anonhd->lock,
so why is there any contention for page_table_lock at all with this
workload?  It must be contending with page_referenced_one().  Taking
anonhd->lock in page_referenced_one() also might fix this up.



 25-akpm/mm/rmap.c |   21 +++++++++++++++++++--
 1 files changed, 19 insertions(+), 2 deletions(-)

diff -puN mm/rmap.c~rmap-trylock-instrumentation mm/rmap.c
--- 25/mm/rmap.c~rmap-trylock-instrumentation	2004-05-01 00:19:05.485768648 -0700
+++ 25-akpm/mm/rmap.c	2004-05-01 00:22:32.029369248 -0700
@@ -27,6 +27,15 @@
 
 #include <asm/tlbflush.h>
 
+static struct stats {
+	int page_referenced_one_miss;
+	int page_referenced_one_hit;
+	int try_to_unmap_one_miss;
+	int try_to_unmap_one_hit;
+	int try_to_unmap_cluster_miss;
+	int try_to_unmap_cluster_hit;
+} stats;
+
 /*
  * struct anonmm: to track a bundle of anonymous memory mappings.
  *
@@ -178,6 +187,7 @@ static int page_referenced_one(struct pa
 	int referenced = 0;
 
 	if (!spin_trylock(&mm->page_table_lock)) {
+		stats.page_referenced_one_miss++;
 		/*
 		 * For debug we're currently warning if not all found,
 		 * but in this case that's expected: suppress warning.
@@ -185,6 +195,7 @@ static int page_referenced_one(struct pa
 		(*failed)++;
 		return 0;
 	}
+	stats.page_referenced_one_hit++;
 
 	pgd = pgd_offset(mm, address);
 	if (!pgd_present(*pgd))
@@ -495,8 +506,11 @@ static int try_to_unmap_one(struct page 
 	 * We need the page_table_lock to protect us from page faults,
 	 * munmap, fork, etc...
 	 */
-	if (!spin_trylock(&mm->page_table_lock))
+	if (!spin_trylock(&mm->page_table_lock)) {
+		stats.try_to_unmap_one_miss++;
 		goto out;
+	}
+	stats.try_to_unmap_one_hit++;
 
 	pgd = pgd_offset(mm, address);
 	if (!pgd_present(*pgd))
@@ -596,8 +610,11 @@ static int try_to_unmap_cluster(struct m
 	 * We need the page_table_lock to protect us from page faults,
 	 * munmap, fork, etc...
 	 */
-	if (!spin_trylock(&mm->page_table_lock))
+	if (!spin_trylock(&mm->page_table_lock)) {
+		stats.try_to_unmap_cluster_miss++;
 		return SWAP_FAIL;
+	}
+	stats.try_to_unmap_cluster_hit++;
 
 	address = (vma->vm_start + cursor) & CLUSTER_MASK;
 	end = address + CLUSTER_SIZE;

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
