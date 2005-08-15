Date: Mon, 15 Aug 2005 13:27:31 -0400
From: Martin Hicks <mort@sgi.com>
Subject: [PATCH] VM: add page_state info to per-node meminfo
Message-ID: <20050815172731.GF13449@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, ak@suse.de, Ray Bryant <raybry@mpdtxmail.amd.com>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


Add page_state info to the per-node meminfo file in sysfs.
This is mostly just for informational purposes.

The lack of this information was brought up recently during a
discussion regarding pagecache clearing, and I put this patch
together to test out one of the suggestions.

It seems like interesting info to have, so I'm submitting the
patch.

Signed-off-by: Martin Hicks <mort@sgi.com>

---
commit 24ecf7aeeb0b9abc84e23cc67c3ddcc2a7b51645
tree 8434482129ede191de950fce8620fbbccd0b8ed9
parent 2ba84684e8cf6f980e4e95a2300f53a505eb794e
author Martin Hicks,,,,,,,engr <mort@tomahawk.engr.sgi.com> Mon, 15 Aug 2005 10:15:01 -0700
committer Martin Hicks,,,,,,,engr <mort@tomahawk.engr.sgi.com> Mon, 15 Aug 2005 10:15:01 -0700

 drivers/base/node.c        |   24 ++++++++++++++++++++++--
 include/linux/page-flags.h |    1 +
 mm/page_alloc.c            |   25 ++++++++++++++++++++-----
 3 files changed, 43 insertions(+), 7 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -39,13 +39,25 @@ static ssize_t node_read_meminfo(struct 
 	int n;
 	int nid = dev->id;
 	struct sysinfo i;
+	struct page_state ps;
 	unsigned long inactive;
 	unsigned long active;
 	unsigned long free;
 
 	si_meminfo_node(&i, nid);
+	get_page_state_node(&ps, nid);
 	__get_zone_counts(&active, &inactive, &free, NODE_DATA(nid));
 
+	/* Check for negative values in these approximate counters */
+	if ((long)ps.nr_dirty < 0)
+		ps.nr_dirty = 0;
+	if ((long)ps.nr_writeback < 0)
+		ps.nr_writeback = 0;
+	if ((long)ps.nr_mapped < 0)
+		ps.nr_mapped = 0;
+	if ((long)ps.nr_slab < 0)
+		ps.nr_slab = 0;
+
 	n = sprintf(buf, "\n"
 		       "Node %d MemTotal:     %8lu kB\n"
 		       "Node %d MemFree:      %8lu kB\n"
@@ -55,7 +67,11 @@ static ssize_t node_read_meminfo(struct 
 		       "Node %d HighTotal:    %8lu kB\n"
 		       "Node %d HighFree:     %8lu kB\n"
 		       "Node %d LowTotal:     %8lu kB\n"
-		       "Node %d LowFree:      %8lu kB\n",
+		       "Node %d LowFree:      %8lu kB\n"
+		       "Node %d Dirty:        %8lu kB\n"
+		       "Node %d Writeback:    %8lu kB\n"
+		       "Node %d Mapped:       %8lu kB\n"
+		       "Node %d Slab:         %8lu kB\n",
 		       nid, K(i.totalram),
 		       nid, K(i.freeram),
 		       nid, K(i.totalram - i.freeram),
@@ -64,7 +80,11 @@ static ssize_t node_read_meminfo(struct 
 		       nid, K(i.totalhigh),
 		       nid, K(i.freehigh),
 		       nid, K(i.totalram - i.totalhigh),
-		       nid, K(i.freeram - i.freehigh));
+		       nid, K(i.freeram - i.freehigh),
+		       nid, K(ps.nr_dirty),
+		       nid, K(ps.nr_writeback),
+		       nid, K(ps.nr_mapped),
+		       nid, K(ps.nr_slab));
 	n += hugetlb_report_node_meminfo(nid, buf + n);
 	return n;
 }
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -134,6 +134,7 @@ struct page_state {
 };
 
 extern void get_page_state(struct page_state *ret);
+extern void get_page_state_node(struct page_state *ret, int node);
 extern void get_full_page_state(struct page_state *ret);
 extern unsigned long __read_page_state(unsigned long offset);
 extern void __mod_page_state(unsigned long offset, unsigned long delta);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1130,19 +1130,20 @@ EXPORT_SYMBOL(nr_pagecache);
 DEFINE_PER_CPU(long, nr_pagecache_local) = 0;
 #endif
 
-void __get_page_state(struct page_state *ret, int nr)
+void __get_page_state(struct page_state *ret, int nr, cpumask_t *cpumask)
 {
 	int cpu = 0;
 
 	memset(ret, 0, sizeof(*ret));
+	cpus_and(*cpumask, *cpumask, cpu_online_map);
 
-	cpu = first_cpu(cpu_online_map);
+	cpu = first_cpu(*cpumask);
 	while (cpu < NR_CPUS) {
 		unsigned long *in, *out, off;
 
 		in = (unsigned long *)&per_cpu(page_states, cpu);
 
-		cpu = next_cpu(cpu, cpu_online_map);
+		cpu = next_cpu(cpu, *cpumask);
 
 		if (cpu < NR_CPUS)
 			prefetch(&per_cpu(page_states, cpu));
@@ -1153,19 +1154,33 @@ void __get_page_state(struct page_state 
 	}
 }
 
+void get_page_state_node(struct page_state *ret, int node)
+{
+	int nr;
+	cpumask_t mask = node_to_cpumask(node);
+
+	nr = offsetof(struct page_state, GET_PAGE_STATE_LAST);
+	nr /= sizeof(unsigned long);
+
+	__get_page_state(ret, nr+1, &mask);
+}
+
 void get_page_state(struct page_state *ret)
 {
 	int nr;
+	cpumask_t mask = CPU_MASK_ALL;
 
 	nr = offsetof(struct page_state, GET_PAGE_STATE_LAST);
 	nr /= sizeof(unsigned long);
 
-	__get_page_state(ret, nr + 1);
+	__get_page_state(ret, nr + 1, &mask);
 }
 
 void get_full_page_state(struct page_state *ret)
 {
-	__get_page_state(ret, sizeof(*ret) / sizeof(unsigned long));
+	cpumask_t mask = CPU_MASK_ALL;
+
+	__get_page_state(ret, sizeof(*ret) / sizeof(unsigned long), &mask);
 }
 
 unsigned long __read_page_state(unsigned long offset)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
