Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 69A176B0070
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 18:15:28 -0400 (EDT)
Received: by igblo3 with SMTP id lo3so967388igb.0
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 15:15:28 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id i201si10579916ioi.31.2015.04.13.15.15.27
        for <linux-mm@kvack.org>;
        Mon, 13 Apr 2015 15:15:27 -0700 (PDT)
From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH 2/5] perf kmem: Analyze page allocator events also
Date: Mon, 13 Apr 2015 19:14:59 -0300
Message-Id: <1428963302-31538-3-git-send-email-acme@kernel.org>
In-Reply-To: <1428963302-31538-1-git-send-email-acme@kernel.org>
References: <1428963302-31538-1-git-send-email-acme@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, David Ahern <dsahern@gmail.com>, Jiri Olsa <jolsa@redhat.com>, Joonsoo Kim <js1304@gmail.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Arnaldo Carvalho de Melo <acme@redhat.com>

From: Namhyung Kim <namhyung@kernel.org>

The perf kmem command records and analyze kernel memory allocation only
for SLAB objects.  This patch implement a simple page allocator analyzer
using kmem:mm_page_alloc and kmem:mm_page_free events.

It adds two new options of --slab and --page.  The --slab option is for
analyzing SLAB allocator and that's what perf kmem currently does.

The new --page option enables page allocator events and analyze kernel
memory usage in page unit.  Currently, 'stat --alloc' subcommand is
implemented only.

If none of these --slab nor --page is specified, --slab is implied.

First run 'perf kmem record' to generate a suitable perf.data file:

  # perf kmem record --page sleep 5

Then run 'perf kmem stat' to postprocess the perf.data file:

  # perf kmem stat --page --alloc --line 10

  -------------------------------------------------------------------------------
   PFN              | Total alloc (KB) | Hits     | Order | Mig.type | GFP flags
  -------------------------------------------------------------------------------
            4045014 |               16 |        1 |     2 |  RECLAIM |  00285250
            4143980 |               16 |        1 |     2 |  RECLAIM |  00285250
            3938658 |               16 |        1 |     2 |  RECLAIM |  00285250
            4045400 |               16 |        1 |     2 |  RECLAIM |  00285250
            3568708 |               16 |        1 |     2 |  RECLAIM |  00285250
            3729824 |               16 |        1 |     2 |  RECLAIM |  00285250
            3657210 |               16 |        1 |     2 |  RECLAIM |  00285250
            4120750 |               16 |        1 |     2 |  RECLAIM |  00285250
            3678850 |               16 |        1 |     2 |  RECLAIM |  00285250
            3693874 |               16 |        1 |     2 |  RECLAIM |  00285250
   ...              | ...              | ...      | ...   | ...      | ...
  -------------------------------------------------------------------------------

  SUMMARY (page allocator)
  ========================
  Total allocation requests     :           44,260   [          177,256 KB ]
  Total free requests           :              117   [              468 KB ]

  Total alloc+freed requests    :               49   [              196 KB ]
  Total alloc-only requests     :           44,211   [          177,060 KB ]
  Total free-only requests      :               68   [              272 KB ]

  Total allocation failures     :                0   [                0 KB ]

  Order     Unmovable   Reclaimable       Movable      Reserved  CMA/Isolated
  -----  ------------  ------------  ------------  ------------  ------------
      0            32             .        44,210             .             .
      1             .             .             .             .             .
      2             .            18             .             .             .
      3             .             .             .             .             .
      4             .             .             .             .             .
      5             .             .             .             .             .
      6             .             .             .             .             .
      7             .             .             .             .             .
      8             .             .             .             .             .
      9             .             .             .             .             .
     10             .             .             .             .             .

Signed-off-by: Namhyung Kim <namhyung@kernel.org>
Tested-by: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: David Ahern <dsahern@gmail.com>
Cc: Jiri Olsa <jolsa@redhat.com>
Cc: Joonsoo Kim <js1304@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/1428298576-9785-4-git-send-email-namhyung@kernel.org
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 tools/perf/Documentation/perf-kmem.txt |   8 +-
 tools/perf/builtin-kmem.c              | 500 +++++++++++++++++++++++++++++++--
 2 files changed, 491 insertions(+), 17 deletions(-)

diff --git a/tools/perf/Documentation/perf-kmem.txt b/tools/perf/Documentation/perf-kmem.txt
index 150253cc3c97..23219c65c16f 100644
--- a/tools/perf/Documentation/perf-kmem.txt
+++ b/tools/perf/Documentation/perf-kmem.txt
@@ -3,7 +3,7 @@ perf-kmem(1)
 
 NAME
 ----
-perf-kmem - Tool to trace/measure kernel memory(slab) properties
+perf-kmem - Tool to trace/measure kernel memory properties
 
 SYNOPSIS
 --------
@@ -46,6 +46,12 @@ OPTIONS
 --raw-ip::
 	Print raw ip instead of symbol
 
+--slab::
+	Analyze SLAB allocator events.
+
+--page::
+	Analyze page allocator events
+
 SEE ALSO
 --------
 linkperf:perf-record[1]
diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
index 4ebf65c79434..63ea01349b6e 100644
--- a/tools/perf/builtin-kmem.c
+++ b/tools/perf/builtin-kmem.c
@@ -22,6 +22,11 @@
 #include <linux/string.h>
 #include <locale.h>
 
+static int	kmem_slab;
+static int	kmem_page;
+
+static long	kmem_page_size;
+
 struct alloc_stat;
 typedef int (*sort_fn_t)(struct alloc_stat *, struct alloc_stat *);
 
@@ -226,6 +231,244 @@ static int perf_evsel__process_free_event(struct perf_evsel *evsel,
 	return 0;
 }
 
+static u64 total_page_alloc_bytes;
+static u64 total_page_free_bytes;
+static u64 total_page_nomatch_bytes;
+static u64 total_page_fail_bytes;
+static unsigned long nr_page_allocs;
+static unsigned long nr_page_frees;
+static unsigned long nr_page_fails;
+static unsigned long nr_page_nomatch;
+
+static bool use_pfn;
+
+#define MAX_MIGRATE_TYPES  6
+#define MAX_PAGE_ORDER     11
+
+static int order_stats[MAX_PAGE_ORDER][MAX_MIGRATE_TYPES];
+
+struct page_stat {
+	struct rb_node 	node;
+	u64 		page;
+	int 		order;
+	unsigned 	gfp_flags;
+	unsigned 	migrate_type;
+	u64		alloc_bytes;
+	u64 		free_bytes;
+	int 		nr_alloc;
+	int 		nr_free;
+};
+
+static struct rb_root page_tree;
+static struct rb_root page_alloc_tree;
+static struct rb_root page_alloc_sorted;
+
+static struct page_stat *search_page(unsigned long page, bool create)
+{
+	struct rb_node **node = &page_tree.rb_node;
+	struct rb_node *parent = NULL;
+	struct page_stat *data;
+
+	while (*node) {
+		s64 cmp;
+
+		parent = *node;
+		data = rb_entry(*node, struct page_stat, node);
+
+		cmp = data->page - page;
+		if (cmp < 0)
+			node = &parent->rb_left;
+		else if (cmp > 0)
+			node = &parent->rb_right;
+		else
+			return data;
+	}
+
+	if (!create)
+		return NULL;
+
+	data = zalloc(sizeof(*data));
+	if (data != NULL) {
+		data->page = page;
+
+		rb_link_node(&data->node, parent, node);
+		rb_insert_color(&data->node, &page_tree);
+	}
+
+	return data;
+}
+
+static int page_stat_cmp(struct page_stat *a, struct page_stat *b)
+{
+	if (a->page > b->page)
+		return -1;
+	if (a->page < b->page)
+		return 1;
+	if (a->order > b->order)
+		return -1;
+	if (a->order < b->order)
+		return 1;
+	if (a->migrate_type > b->migrate_type)
+		return -1;
+	if (a->migrate_type < b->migrate_type)
+		return 1;
+	if (a->gfp_flags > b->gfp_flags)
+		return -1;
+	if (a->gfp_flags < b->gfp_flags)
+		return 1;
+	return 0;
+}
+
+static struct page_stat *search_page_alloc_stat(struct page_stat *stat, bool create)
+{
+	struct rb_node **node = &page_alloc_tree.rb_node;
+	struct rb_node *parent = NULL;
+	struct page_stat *data;
+
+	while (*node) {
+		s64 cmp;
+
+		parent = *node;
+		data = rb_entry(*node, struct page_stat, node);
+
+		cmp = page_stat_cmp(data, stat);
+		if (cmp < 0)
+			node = &parent->rb_left;
+		else if (cmp > 0)
+			node = &parent->rb_right;
+		else
+			return data;
+	}
+
+	if (!create)
+		return NULL;
+
+	data = zalloc(sizeof(*data));
+	if (data != NULL) {
+		data->page = stat->page;
+		data->order = stat->order;
+		data->gfp_flags = stat->gfp_flags;
+		data->migrate_type = stat->migrate_type;
+
+		rb_link_node(&data->node, parent, node);
+		rb_insert_color(&data->node, &page_alloc_tree);
+	}
+
+	return data;
+}
+
+static bool valid_page(u64 pfn_or_page)
+{
+	if (use_pfn && pfn_or_page == -1UL)
+		return false;
+	if (!use_pfn && pfn_or_page == 0)
+		return false;
+	return true;
+}
+
+static int perf_evsel__process_page_alloc_event(struct perf_evsel *evsel,
+						struct perf_sample *sample)
+{
+	u64 page;
+	unsigned int order = perf_evsel__intval(evsel, sample, "order");
+	unsigned int gfp_flags = perf_evsel__intval(evsel, sample, "gfp_flags");
+	unsigned int migrate_type = perf_evsel__intval(evsel, sample,
+						       "migratetype");
+	u64 bytes = kmem_page_size << order;
+	struct page_stat *stat;
+	struct page_stat this = {
+		.order = order,
+		.gfp_flags = gfp_flags,
+		.migrate_type = migrate_type,
+	};
+
+	if (use_pfn)
+		page = perf_evsel__intval(evsel, sample, "pfn");
+	else
+		page = perf_evsel__intval(evsel, sample, "page");
+
+	nr_page_allocs++;
+	total_page_alloc_bytes += bytes;
+
+	if (!valid_page(page)) {
+		nr_page_fails++;
+		total_page_fail_bytes += bytes;
+
+		return 0;
+	}
+
+	/*
+	 * This is to find the current page (with correct gfp flags and
+	 * migrate type) at free event.
+	 */
+	stat = search_page(page, true);
+	if (stat == NULL)
+		return -ENOMEM;
+
+	stat->order = order;
+	stat->gfp_flags = gfp_flags;
+	stat->migrate_type = migrate_type;
+
+	this.page = page;
+	stat = search_page_alloc_stat(&this, true);
+	if (stat == NULL)
+		return -ENOMEM;
+
+	stat->nr_alloc++;
+	stat->alloc_bytes += bytes;
+
+	order_stats[order][migrate_type]++;
+
+	return 0;
+}
+
+static int perf_evsel__process_page_free_event(struct perf_evsel *evsel,
+						struct perf_sample *sample)
+{
+	u64 page;
+	unsigned int order = perf_evsel__intval(evsel, sample, "order");
+	u64 bytes = kmem_page_size << order;
+	struct page_stat *stat;
+	struct page_stat this = {
+		.order = order,
+	};
+
+	if (use_pfn)
+		page = perf_evsel__intval(evsel, sample, "pfn");
+	else
+		page = perf_evsel__intval(evsel, sample, "page");
+
+	nr_page_frees++;
+	total_page_free_bytes += bytes;
+
+	stat = search_page(page, false);
+	if (stat == NULL) {
+		pr_debug2("missing free at page %"PRIx64" (order: %d)\n",
+			  page, order);
+
+		nr_page_nomatch++;
+		total_page_nomatch_bytes += bytes;
+
+		return 0;
+	}
+
+	this.page = page;
+	this.gfp_flags = stat->gfp_flags;
+	this.migrate_type = stat->migrate_type;
+
+	rb_erase(&stat->node, &page_tree);
+	free(stat);
+
+	stat = search_page_alloc_stat(&this, false);
+	if (stat == NULL)
+		return -ENOENT;
+
+	stat->nr_free++;
+	stat->free_bytes += bytes;
+
+	return 0;
+}
+
 typedef int (*tracepoint_handler)(struct perf_evsel *evsel,
 				  struct perf_sample *sample);
 
@@ -270,8 +513,9 @@ static double fragmentation(unsigned long n_req, unsigned long n_alloc)
 		return 100.0 - (100.0 * n_req / n_alloc);
 }
 
-static void __print_result(struct rb_root *root, struct perf_session *session,
-			   int n_lines, int is_caller)
+static void __print_slab_result(struct rb_root *root,
+				struct perf_session *session,
+				int n_lines, int is_caller)
 {
 	struct rb_node *next;
 	struct machine *machine = &session->machines.host;
@@ -323,9 +567,56 @@ static void __print_result(struct rb_root *root, struct perf_session *session,
 	printf("%.105s\n", graph_dotted_line);
 }
 
-static void print_summary(void)
+static const char * const migrate_type_str[] = {
+	"UNMOVABL",
+	"RECLAIM",
+	"MOVABLE",
+	"RESERVED",
+	"CMA/ISLT",
+	"UNKNOWN",
+};
+
+static void __print_page_result(struct rb_root *root,
+				struct perf_session *session __maybe_unused,
+				int n_lines)
+{
+	struct rb_node *next = rb_first(root);
+	const char *format;
+
+	printf("\n%.80s\n", graph_dotted_line);
+	printf(" %-16s | Total alloc (KB) | Hits      | Order | Mig.type | GFP flags\n",
+	       use_pfn ? "PFN" : "Page");
+	printf("%.80s\n", graph_dotted_line);
+
+	if (use_pfn)
+		format = " %16llu | %'16llu | %'9d | %5d | %8s |  %08lx\n";
+	else
+		format = " %016llx | %'16llu | %'9d | %5d | %8s |  %08lx\n";
+
+	while (next && n_lines--) {
+		struct page_stat *data;
+
+		data = rb_entry(next, struct page_stat, node);
+
+		printf(format, (unsigned long long)data->page,
+		       (unsigned long long)data->alloc_bytes / 1024,
+		       data->nr_alloc, data->order,
+		       migrate_type_str[data->migrate_type],
+		       (unsigned long)data->gfp_flags);
+
+		next = rb_next(next);
+	}
+
+	if (n_lines == -1)
+		printf(" ...              | ...              | ...       | ...   | ...      | ...     \n");
+
+	printf("%.80s\n", graph_dotted_line);
+}
+
+static void print_slab_summary(void)
 {
-	printf("\nSUMMARY\n=======\n");
+	printf("\nSUMMARY (SLAB allocator)");
+	printf("\n========================\n");
 	printf("Total bytes requested: %'lu\n", total_requested);
 	printf("Total bytes allocated: %'lu\n", total_allocated);
 	printf("Total bytes wasted on internal fragmentation: %'lu\n",
@@ -335,13 +626,73 @@ static void print_summary(void)
 	printf("Cross CPU allocations: %'lu/%'lu\n", nr_cross_allocs, nr_allocs);
 }
 
-static void print_result(struct perf_session *session)
+static void print_page_summary(void)
+{
+	int o, m;
+	u64 nr_alloc_freed = nr_page_frees - nr_page_nomatch;
+	u64 total_alloc_freed_bytes = total_page_free_bytes - total_page_nomatch_bytes;
+
+	printf("\nSUMMARY (page allocator)");
+	printf("\n========================\n");
+	printf("%-30s: %'16lu   [ %'16"PRIu64" KB ]\n", "Total allocation requests",
+	       nr_page_allocs, total_page_alloc_bytes / 1024);
+	printf("%-30s: %'16lu   [ %'16"PRIu64" KB ]\n", "Total free requests",
+	       nr_page_frees, total_page_free_bytes / 1024);
+	printf("\n");
+
+	printf("%-30s: %'16lu   [ %'16"PRIu64" KB ]\n", "Total alloc+freed requests",
+	       nr_alloc_freed, (total_alloc_freed_bytes) / 1024);
+	printf("%-30s: %'16lu   [ %'16"PRIu64" KB ]\n", "Total alloc-only requests",
+	       nr_page_allocs - nr_alloc_freed,
+	       (total_page_alloc_bytes - total_alloc_freed_bytes) / 1024);
+	printf("%-30s: %'16lu   [ %'16"PRIu64" KB ]\n", "Total free-only requests",
+	       nr_page_nomatch, total_page_nomatch_bytes / 1024);
+	printf("\n");
+
+	printf("%-30s: %'16lu   [ %'16"PRIu64" KB ]\n", "Total allocation failures",
+	       nr_page_fails, total_page_fail_bytes / 1024);
+	printf("\n");
+
+	printf("%5s  %12s  %12s  %12s  %12s  %12s\n", "Order",  "Unmovable",
+	       "Reclaimable", "Movable", "Reserved", "CMA/Isolated");
+	printf("%.5s  %.12s  %.12s  %.12s  %.12s  %.12s\n", graph_dotted_line,
+	       graph_dotted_line, graph_dotted_line, graph_dotted_line,
+	       graph_dotted_line, graph_dotted_line);
+
+	for (o = 0; o < MAX_PAGE_ORDER; o++) {
+		printf("%5d", o);
+		for (m = 0; m < MAX_MIGRATE_TYPES - 1; m++) {
+			if (order_stats[o][m])
+				printf("  %'12d", order_stats[o][m]);
+			else
+				printf("  %12c", '.');
+		}
+		printf("\n");
+	}
+}
+
+static void print_slab_result(struct perf_session *session)
 {
 	if (caller_flag)
-		__print_result(&root_caller_sorted, session, caller_lines, 1);
+		__print_slab_result(&root_caller_sorted, session, caller_lines, 1);
+	if (alloc_flag)
+		__print_slab_result(&root_alloc_sorted, session, alloc_lines, 0);
+	print_slab_summary();
+}
+
+static void print_page_result(struct perf_session *session)
+{
 	if (alloc_flag)
-		__print_result(&root_alloc_sorted, session, alloc_lines, 0);
-	print_summary();
+		__print_page_result(&page_alloc_sorted, session, alloc_lines);
+	print_page_summary();
+}
+
+static void print_result(struct perf_session *session)
+{
+	if (kmem_slab)
+		print_slab_result(session);
+	if (kmem_page)
+		print_page_result(session);
 }
 
 struct sort_dimension {
@@ -353,8 +704,8 @@ struct sort_dimension {
 static LIST_HEAD(caller_sort);
 static LIST_HEAD(alloc_sort);
 
-static void sort_insert(struct rb_root *root, struct alloc_stat *data,
-			struct list_head *sort_list)
+static void sort_slab_insert(struct rb_root *root, struct alloc_stat *data,
+			     struct list_head *sort_list)
 {
 	struct rb_node **new = &(root->rb_node);
 	struct rb_node *parent = NULL;
@@ -383,8 +734,8 @@ static void sort_insert(struct rb_root *root, struct alloc_stat *data,
 	rb_insert_color(&data->node, root);
 }
 
-static void __sort_result(struct rb_root *root, struct rb_root *root_sorted,
-			  struct list_head *sort_list)
+static void __sort_slab_result(struct rb_root *root, struct rb_root *root_sorted,
+			       struct list_head *sort_list)
 {
 	struct rb_node *node;
 	struct alloc_stat *data;
@@ -396,26 +747,79 @@ static void __sort_result(struct rb_root *root, struct rb_root *root_sorted,
 
 		rb_erase(node, root);
 		data = rb_entry(node, struct alloc_stat, node);
-		sort_insert(root_sorted, data, sort_list);
+		sort_slab_insert(root_sorted, data, sort_list);
+	}
+}
+
+static void sort_page_insert(struct rb_root *root, struct page_stat *data)
+{
+	struct rb_node **new = &root->rb_node;
+	struct rb_node *parent = NULL;
+
+	while (*new) {
+		struct page_stat *this;
+		int cmp = 0;
+
+		this = rb_entry(*new, struct page_stat, node);
+		parent = *new;
+
+		/* TODO: support more sort key */
+		cmp = data->alloc_bytes - this->alloc_bytes;
+
+		if (cmp > 0)
+			new = &parent->rb_left;
+		else
+			new = &parent->rb_right;
+	}
+
+	rb_link_node(&data->node, parent, new);
+	rb_insert_color(&data->node, root);
+}
+
+static void __sort_page_result(struct rb_root *root, struct rb_root *root_sorted)
+{
+	struct rb_node *node;
+	struct page_stat *data;
+
+	for (;;) {
+		node = rb_first(root);
+		if (!node)
+			break;
+
+		rb_erase(node, root);
+		data = rb_entry(node, struct page_stat, node);
+		sort_page_insert(root_sorted, data);
 	}
 }
 
 static void sort_result(void)
 {
-	__sort_result(&root_alloc_stat, &root_alloc_sorted, &alloc_sort);
-	__sort_result(&root_caller_stat, &root_caller_sorted, &caller_sort);
+	if (kmem_slab) {
+		__sort_slab_result(&root_alloc_stat, &root_alloc_sorted,
+				   &alloc_sort);
+		__sort_slab_result(&root_caller_stat, &root_caller_sorted,
+				   &caller_sort);
+	}
+	if (kmem_page) {
+		__sort_page_result(&page_alloc_tree, &page_alloc_sorted);
+	}
 }
 
 static int __cmd_kmem(struct perf_session *session)
 {
 	int err = -EINVAL;
+	struct perf_evsel *evsel;
 	const struct perf_evsel_str_handler kmem_tracepoints[] = {
+		/* slab allocator */
 		{ "kmem:kmalloc",		perf_evsel__process_alloc_event, },
     		{ "kmem:kmem_cache_alloc",	perf_evsel__process_alloc_event, },
 		{ "kmem:kmalloc_node",		perf_evsel__process_alloc_node_event, },
     		{ "kmem:kmem_cache_alloc_node", perf_evsel__process_alloc_node_event, },
 		{ "kmem:kfree",			perf_evsel__process_free_event, },
     		{ "kmem:kmem_cache_free",	perf_evsel__process_free_event, },
+		/* page allocator */
+		{ "kmem:mm_page_alloc",		perf_evsel__process_page_alloc_event, },
+		{ "kmem:mm_page_free",		perf_evsel__process_page_free_event, },
 	};
 
 	if (!perf_session__has_traces(session, "kmem record"))
@@ -426,10 +830,20 @@ static int __cmd_kmem(struct perf_session *session)
 		goto out;
 	}
 
+	evlist__for_each(session->evlist, evsel) {
+		if (!strcmp(perf_evsel__name(evsel), "kmem:mm_page_alloc") &&
+		    perf_evsel__field(evsel, "pfn")) {
+			use_pfn = true;
+			break;
+		}
+	}
+
 	setup_pager();
 	err = perf_session__process_events(session);
-	if (err != 0)
+	if (err != 0) {
+		pr_err("error during process events: %d\n", err);
 		goto out;
+	}
 	sort_result();
 	print_result(session);
 out:
@@ -612,6 +1026,22 @@ static int parse_alloc_opt(const struct option *opt __maybe_unused,
 	return 0;
 }
 
+static int parse_slab_opt(const struct option *opt __maybe_unused,
+			  const char *arg __maybe_unused,
+			  int unset __maybe_unused)
+{
+	kmem_slab = (kmem_page + 1);
+	return 0;
+}
+
+static int parse_page_opt(const struct option *opt __maybe_unused,
+			  const char *arg __maybe_unused,
+			  int unset __maybe_unused)
+{
+	kmem_page = (kmem_slab + 1);
+	return 0;
+}
+
 static int parse_line_opt(const struct option *opt __maybe_unused,
 			  const char *arg, int unset __maybe_unused)
 {
@@ -634,6 +1064,8 @@ static int __cmd_record(int argc, const char **argv)
 {
 	const char * const record_args[] = {
 	"record", "-a", "-R", "-c", "1",
+	};
+	const char * const slab_events[] = {
 	"-e", "kmem:kmalloc",
 	"-e", "kmem:kmalloc_node",
 	"-e", "kmem:kfree",
@@ -641,10 +1073,19 @@ static int __cmd_record(int argc, const char **argv)
 	"-e", "kmem:kmem_cache_alloc_node",
 	"-e", "kmem:kmem_cache_free",
 	};
+	const char * const page_events[] = {
+	"-e", "kmem:mm_page_alloc",
+	"-e", "kmem:mm_page_free",
+	};
 	unsigned int rec_argc, i, j;
 	const char **rec_argv;
 
 	rec_argc = ARRAY_SIZE(record_args) + argc - 1;
+	if (kmem_slab)
+		rec_argc += ARRAY_SIZE(slab_events);
+	if (kmem_page)
+		rec_argc += ARRAY_SIZE(page_events);
+
 	rec_argv = calloc(rec_argc + 1, sizeof(char *));
 
 	if (rec_argv == NULL)
@@ -653,6 +1094,15 @@ static int __cmd_record(int argc, const char **argv)
 	for (i = 0; i < ARRAY_SIZE(record_args); i++)
 		rec_argv[i] = strdup(record_args[i]);
 
+	if (kmem_slab) {
+		for (j = 0; j < ARRAY_SIZE(slab_events); j++, i++)
+			rec_argv[i] = strdup(slab_events[j]);
+	}
+	if (kmem_page) {
+		for (j = 0; j < ARRAY_SIZE(page_events); j++, i++)
+			rec_argv[i] = strdup(page_events[j]);
+	}
+
 	for (j = 1; j < (unsigned int)argc; j++, i++)
 		rec_argv[i] = argv[j];
 
@@ -679,6 +1129,10 @@ int cmd_kmem(int argc, const char **argv, const char *prefix __maybe_unused)
 	OPT_CALLBACK('l', "line", NULL, "num", "show n lines", parse_line_opt),
 	OPT_BOOLEAN(0, "raw-ip", &raw_ip, "show raw ip instead of symbol"),
 	OPT_BOOLEAN('f', "force", &file.force, "don't complain, do it"),
+	OPT_CALLBACK_NOOPT(0, "slab", NULL, NULL, "Analyze slab allocator",
+			   parse_slab_opt),
+	OPT_CALLBACK_NOOPT(0, "page", NULL, NULL, "Analyze page allocator",
+			   parse_page_opt),
 	OPT_END()
 	};
 	const char *const kmem_subcommands[] = { "record", "stat", NULL };
@@ -695,6 +1149,9 @@ int cmd_kmem(int argc, const char **argv, const char *prefix __maybe_unused)
 	if (!argc)
 		usage_with_options(kmem_usage, kmem_options);
 
+	if (kmem_slab == 0 && kmem_page == 0)
+		kmem_slab = 1;  /* for backward compatibility */
+
 	if (!strncmp(argv[0], "rec", 3)) {
 		symbol__init(NULL);
 		return __cmd_record(argc, argv);
@@ -706,6 +1163,17 @@ int cmd_kmem(int argc, const char **argv, const char *prefix __maybe_unused)
 	if (session == NULL)
 		return -1;
 
+	if (kmem_page) {
+		struct perf_evsel *evsel = perf_evlist__first(session->evlist);
+
+		if (evsel == NULL || evsel->tp_format == NULL) {
+			pr_err("invalid event found.. aborting\n");
+			return -1;
+		}
+
+		kmem_page_size = pevent_get_page_size(evsel->tp_format->pevent);
+	}
+
 	symbol__init(&session->header.env);
 
 	if (!strcmp(argv[0], "stat")) {
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
