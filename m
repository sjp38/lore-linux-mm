Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 3F0486B0071
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 18:19:01 -0400 (EDT)
Date: Wed, 11 Jul 2012 00:18:55 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/2] mm: sparse: fix usemap allocation above node descriptor
 section
Message-ID: <20120710221855.GJ1779@cmpxchg.org>
References: <20120626234630.A54C9A0341@akpm.mtv.corp.google.com>
 <CAE9FiQUeQG6nr_k54ixEA4pvRT00e4bWoMJ+m0NO=FPEnBDB8Q@mail.gmail.com>
 <CAE9FiQX_ovuiGHShf72kLOe4WJybZiyWiGaQ9KUnc1jm3cvdHw@mail.gmail.com>
 <20120710212005.GG1779@cmpxchg.org>
 <20120710221559.GH1779@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120710221559.GH1779@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, tj@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Yinghai Lu <yinghai@kernel.org>

After f5bf18f "bootmem/sparsemem: remove limit constraint in
alloc_bootmem_section", usemap allocations may easily be placed
outside the optimal section that holds the node descriptor, even if
there is space available in that section.  This results in unnecessary
hotplug dependencies that need to have the node unplugged before the
section holding the usemap.

The reason is that the bootmem allocator doesn't guarantee a linear
search starting from the passed allocation goal but may start out at a
much higher address absent an upper limit.

Fix this by trying the allocation with the limit at the section end,
then retry without if that fails.  This keeps the fix from f5bf18f of
not panicking if the allocation does not fit in the section, but still
makes sure to try to stay within the section at first.

Signed-off-by: Yinghai Lu <yinghai@kernel.org>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: stable@kernel.org [3.3, 3.4]
---
 include/linux/bootmem.h |    5 +++++
 mm/bootmem.c            |    2 +-
 mm/nobootmem.c          |    2 +-
 mm/sparse.c             |   18 +++++++++++++-----
 4 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index 324fe08..6d6795d 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -91,6 +91,11 @@ extern void *__alloc_bootmem_node_nopanic(pg_data_t *pgdat,
 				  unsigned long size,
 				  unsigned long align,
 				  unsigned long goal);
+void *___alloc_bootmem_node_nopanic(pg_data_t *pgdat,
+				  unsigned long size,
+				  unsigned long align,
+				  unsigned long goal,
+				  unsigned long limit);
 extern void *__alloc_bootmem_low(unsigned long size,
 				 unsigned long align,
 				 unsigned long goal);
diff --git a/mm/bootmem.c b/mm/bootmem.c
index ec4fcb7..7309663 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -698,7 +698,7 @@ void * __init __alloc_bootmem(unsigned long size, unsigned long align,
 	return ___alloc_bootmem(size, align, goal, limit);
 }
 
-static void * __init ___alloc_bootmem_node_nopanic(pg_data_t *pgdat,
+void * __init ___alloc_bootmem_node_nopanic(pg_data_t *pgdat,
 				unsigned long size, unsigned long align,
 				unsigned long goal, unsigned long limit)
 {
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 6773ba5..4055730 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -282,7 +282,7 @@ void * __init __alloc_bootmem(unsigned long size, unsigned long align,
 	return ___alloc_bootmem(size, align, goal, limit);
 }
 
-static void * __init ___alloc_bootmem_node_nopanic(pg_data_t *pgdat,
+void * __init ___alloc_bootmem_node_nopanic(pg_data_t *pgdat,
 						   unsigned long size,
 						   unsigned long align,
 						   unsigned long goal,
diff --git a/mm/sparse.c b/mm/sparse.c
index e861397..c7bb952 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -275,8 +275,9 @@ static unsigned long * __init
 sparse_early_usemaps_alloc_pgdat_section(struct pglist_data *pgdat,
 					 unsigned long size)
 {
-	pg_data_t *host_pgdat;
-	unsigned long goal;
+	unsigned long goal, limit;
+	unsigned long *p;
+	int nid;
 	/*
 	 * A page may contain usemaps for other sections preventing the
 	 * page being freed and making a section unremovable while
@@ -288,9 +289,16 @@ sparse_early_usemaps_alloc_pgdat_section(struct pglist_data *pgdat,
 	 * this problem.
 	 */
 	goal = __pa(pgdat) & (PAGE_SECTION_MASK << PAGE_SHIFT);
-	host_pgdat = NODE_DATA(early_pfn_to_nid(goal >> PAGE_SHIFT));
-	return __alloc_bootmem_node_nopanic(host_pgdat, size,
-					    SMP_CACHE_BYTES, goal);
+	limit = goal + (1UL << PA_SECTION_SHIFT);
+	nid = early_pfn_to_nid(goal >> PAGE_SHIFT);
+again:
+	p = ___alloc_bootmem_node_nopanic(NODE_DATA(nid), size,
+					  SMP_CACHE_BYTES, goal, limit);
+	if (!p && limit) {
+		limit = 0;
+		goto again;
+	}
+	return p;
 }
 
 static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
