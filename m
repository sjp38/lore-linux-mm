Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 03F68900015
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 02:07:25 -0400 (EDT)
Received: by pabxg6 with SMTP id xg6so53303679pab.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 23:07:24 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id te6si6822365pbc.185.2015.03.25.23.07.12
        for <linux-mm@kvack.org>;
        Wed, 25 Mar 2015 23:07:14 -0700 (PDT)
From: Namhyung Kim <namhyung@kernel.org>
Subject: [PATCH 5/6] perf kmem: Add --live option for current allocation stat
Date: Thu, 26 Mar 2015 15:00:35 +0900
Message-Id: <1427349636-9796-6-git-send-email-namhyung@kernel.org>
In-Reply-To: <1427349636-9796-1-git-send-email-namhyung@kernel.org>
References: <1427349636-9796-1-git-send-email-namhyung@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org

Currently perf kmem shows total (page) allocation stat by default, but
sometimes one might want to see live (total alloc-only) requests/pages
only.  The new --live option does this by subtracting freed allocation
from the stat.

Signed-off-by: Namhyung Kim <namhyung@kernel.org>
---
 tools/perf/Documentation/perf-kmem.txt |   5 ++
 tools/perf/builtin-kmem.c              | 103 ++++++++++++++++++++-------------
 2 files changed, 69 insertions(+), 39 deletions(-)

diff --git a/tools/perf/Documentation/perf-kmem.txt b/tools/perf/Documentation/perf-kmem.txt
index 0ebd9c8bfdbf..5a2d9aaf1933 100644
--- a/tools/perf/Documentation/perf-kmem.txt
+++ b/tools/perf/Documentation/perf-kmem.txt
@@ -56,6 +56,11 @@ OPTIONS
 --page::
 	Analyze page allocator events
 
+--live::
+	Show live page stat.  The perf kmem shows total allocation stat by
+	default, but this option shows live (currently allocated) pages
+	instead.  (This option works with --page option only)
+
 SEE ALSO
 --------
 linkperf:perf-record[1]
diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
index 2f9322b59140..c09e332f7f38 100644
--- a/tools/perf/builtin-kmem.c
+++ b/tools/perf/builtin-kmem.c
@@ -244,6 +244,7 @@ static unsigned long nr_page_fails;
 static unsigned long nr_page_nomatch;
 
 static bool use_pfn;
+static bool live_page;
 static struct perf_session *kmem_session;
 
 #define MAX_MIGRATE_TYPES  6
@@ -264,7 +265,7 @@ struct page_stat {
 	int 		nr_free;
 };
 
-static struct rb_root page_tree;
+static struct rb_root page_live_tree;
 static struct rb_root page_alloc_tree;
 static struct rb_root page_alloc_sorted;
 static struct rb_root page_caller_tree;
@@ -398,10 +399,19 @@ static u64 find_callsite(struct perf_evsel *evsel, struct perf_sample *sample)
 	return sample->ip;
 }
 
+struct sort_dimension {
+	const char		name[20];
+	sort_fn_t		cmp;
+	struct list_head	list;
+};
+
+static LIST_HEAD(page_alloc_sort_input);
+static LIST_HEAD(page_caller_sort_input);
 
-static struct page_stat *search_page(u64 page, bool create)
+static struct page_stat *search_page_live_stat(struct page_stat *this,
+					       bool create)
 {
-	struct rb_node **node = &page_tree.rb_node;
+	struct rb_node **node = &page_live_tree.rb_node;
 	struct rb_node *parent = NULL;
 	struct page_stat *data;
 
@@ -411,7 +421,7 @@ static struct page_stat *search_page(u64 page, bool create)
 		parent = *node;
 		data = rb_entry(*node, struct page_stat, node);
 
-		cmp = data->page - page;
+		cmp = data->page - this->page;
 		if (cmp < 0)
 			node = &parent->rb_left;
 		else if (cmp > 0)
@@ -425,24 +435,17 @@ static struct page_stat *search_page(u64 page, bool create)
 
 	data = zalloc(sizeof(*data));
 	if (data != NULL) {
-		data->page = page;
+		data->page = this->page;
+		data->order = this->order;
+		data->migrate_type = this->migrate_type;
+		data->gfp_flags = this->gfp_flags;
 
 		rb_link_node(&data->node, parent, node);
-		rb_insert_color(&data->node, &page_tree);
+		rb_insert_color(&data->node, &page_live_tree);
 	}
 
 	return data;
 }
-
-struct sort_dimension {
-	const char		name[20];
-	sort_fn_t		cmp;
-	struct list_head	list;
-};
-
-static LIST_HEAD(page_alloc_sort_input);
-static LIST_HEAD(page_caller_sort_input);
-
 static struct page_stat *search_page_alloc_stat(struct page_stat *this,
 						bool create)
 {
@@ -580,17 +583,8 @@ static int perf_evsel__process_page_alloc_event(struct perf_evsel *evsel,
 	 * This is to find the current page (with correct gfp flags and
 	 * migrate type) at free event.
 	 */
-	stat = search_page(page, true);
-	if (stat == NULL)
-		return -ENOMEM;
-
-	stat->order = order;
-	stat->gfp_flags = gfp_flags;
-	stat->migrate_type = migrate_type;
-	stat->callsite = callsite;
-
 	this.page = page;
-	stat = search_page_alloc_stat(&this, true);
+	stat = search_page_live_stat(&this, true);
 	if (stat == NULL)
 		return -ENOMEM;
 
@@ -598,6 +592,16 @@ static int perf_evsel__process_page_alloc_event(struct perf_evsel *evsel,
 	stat->alloc_bytes += bytes;
 	stat->callsite = callsite;
 
+	if (!live_page) {
+		stat = search_page_alloc_stat(&this, true);
+		if (stat == NULL)
+			return -ENOMEM;
+
+		stat->nr_alloc++;
+		stat->alloc_bytes += bytes;
+		stat->callsite = callsite;
+	}
+
 	this.callsite = callsite;
 	stat = search_page_caller_stat(&this, true);
 	if (stat == NULL)
@@ -630,7 +634,8 @@ static int perf_evsel__process_page_free_event(struct perf_evsel *evsel,
 	nr_page_frees++;
 	total_page_free_bytes += bytes;
 
-	stat = search_page(page, false);
+	this.page = page;
+	stat = search_page_live_stat(&this, false);
 	if (stat == NULL) {
 		pr_debug2("missing free at page %"PRIx64" (order: %d)\n",
 			  page, order);
@@ -641,20 +646,23 @@ static int perf_evsel__process_page_free_event(struct perf_evsel *evsel,
 		return 0;
 	}
 
-	this.page = page;
 	this.gfp_flags = stat->gfp_flags;
 	this.migrate_type = stat->migrate_type;
 	this.callsite = stat->callsite;
 
-	rb_erase(&stat->node, &page_tree);
+	rb_erase(&stat->node, &page_live_tree);
 	free(stat);
 
-	stat = search_page_alloc_stat(&this, false);
-	if (stat == NULL)
-		return -ENOENT;
+	if (live_page) {
+		order_stats[this.order][this.migrate_type]--;
+	} else {
+		stat = search_page_alloc_stat(&this, false);
+		if (stat == NULL)
+			return -ENOMEM;
 
-	stat->nr_free++;
-	stat->free_bytes += bytes;
+		stat->nr_free++;
+		stat->free_bytes += bytes;
+	}
 
 	stat = search_page_caller_stat(&this, false);
 	if (stat == NULL)
@@ -663,6 +671,16 @@ static int perf_evsel__process_page_free_event(struct perf_evsel *evsel,
 	stat->nr_free++;
 	stat->free_bytes += bytes;
 
+	if (live_page) {
+		stat->nr_alloc--;
+		stat->alloc_bytes -= bytes;
+
+		if (stat->nr_alloc == 0) {
+			rb_erase(&stat->node, &page_caller_tree);
+			free(stat);
+		}
+	}
+
 	return 0;
 }
 
@@ -780,8 +798,8 @@ static void __print_page_alloc_result(struct perf_session *session, int n_lines)
 	const char *format;
 
 	printf("\n%.105s\n", graph_dotted_line);
-	printf(" %-16s | Total alloc (KB) | Hits      | Order | Migration type | GFP flags | Callsite\n",
-	       use_pfn ? "PFN" : "Page");
+	printf(" %-16s | %5s alloc (KB) | Hits      | Order | Migration type | GFP flags | Callsite\n",
+	       use_pfn ? "PFN" : "Page", live_page ? "Live" : "Total");
 	printf("%.105s\n", graph_dotted_line);
 
 	if (use_pfn)
@@ -825,7 +843,8 @@ static void __print_page_caller_result(struct perf_session *session, int n_lines
 	struct machine *machine = &session->machines.host;
 
 	printf("\n%.105s\n", graph_dotted_line);
-	printf(" Total alloc (KB) | Hits      | Order | Migration type | GFP flags | Callsite\n");
+	printf(" %5s alloc (KB) | Hits      | Order | Migration type | GFP flags | Callsite\n",
+	       live_page ? "Live" : "Total");
 	printf("%.105s\n", graph_dotted_line);
 
 	while (next && n_lines--) {
@@ -1050,8 +1069,13 @@ static void sort_result(void)
 				   &slab_caller_sort);
 	}
 	if (kmem_page) {
-		__sort_page_result(&page_alloc_tree, &page_alloc_sorted,
-				   &page_alloc_sort);
+		if (live_page)
+			__sort_page_result(&page_live_tree, &page_alloc_sorted,
+					   &page_alloc_sort);
+		else
+			__sort_page_result(&page_alloc_tree, &page_alloc_sorted,
+					   &page_alloc_sort);
+
 		__sort_page_result(&page_caller_tree, &page_caller_sorted,
 				   &page_caller_sort);
 	}
@@ -1591,6 +1615,7 @@ int cmd_kmem(int argc, const char **argv, const char *prefix __maybe_unused)
 			   parse_slab_opt),
 	OPT_CALLBACK_NOOPT(0, "page", NULL, NULL, "Analyze page allocator",
 			   parse_page_opt),
+	OPT_BOOLEAN(0, "live", &live_page, "Show live page stat"),
 	OPT_END()
 	};
 	const char *const kmem_subcommands[] = { "record", "stat", NULL };
-- 
2.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
