Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7F2A36B006C
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 01:00:23 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so229473625pab.3
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 22:00:23 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id cf1si1174750pdb.112.2015.04.20.22.00.18
        for <linux-mm@kvack.org>;
        Mon, 20 Apr 2015 22:00:19 -0700 (PDT)
From: Namhyung Kim <namhyung@kernel.org>
Subject: [PATCH 3/6] perf kmem: Add --live option for current allocation stat
Date: Tue, 21 Apr 2015 13:55:04 +0900
Message-Id: <1429592107-1807-4-git-send-email-namhyung@kernel.org>
In-Reply-To: <1429592107-1807-1-git-send-email-namhyung@kernel.org>
References: <1429592107-1807-1-git-send-email-namhyung@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Joonsoo Kim <js1304@gmail.com>, Minchan Kim <minchan@kernel.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org

Currently perf kmem shows total (page) allocation stat by default, but
sometimes one might want to see live (total alloc-only) requests/pages
only.  The new --live option does this by subtracting freed allocation
from the stat.

Acked-by: Pekka Enberg <penberg@kernel.org>
Signed-off-by: Namhyung Kim <namhyung@kernel.org>
---
 tools/perf/Documentation/perf-kmem.txt |   5 ++
 tools/perf/builtin-kmem.c              | 110 ++++++++++++++++++++-------------
 2 files changed, 73 insertions(+), 42 deletions(-)

diff --git a/tools/perf/Documentation/perf-kmem.txt b/tools/perf/Documentation/perf-kmem.txt
index 69e181272c51..ff0f433b3fce 100644
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
index 0393a7f3fa35..7ead9423fd7a 100644
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
@@ -403,10 +404,19 @@ static u64 find_callsite(struct perf_evsel *evsel, struct perf_sample *sample)
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
+
 static struct page_stat *
-__page_stat__findnew_page(u64 page, bool create)
+__page_stat__findnew_page(struct page_stat *pstat, bool create)
 {
-	struct rb_node **node = &page_tree.rb_node;
+	struct rb_node **node = &page_live_tree.rb_node;
 	struct rb_node *parent = NULL;
 	struct page_stat *data;
 
@@ -416,7 +426,7 @@ __page_stat__findnew_page(u64 page, bool create)
 		parent = *node;
 		data = rb_entry(*node, struct page_stat, node);
 
-		cmp = data->page - page;
+		cmp = data->page - pstat->page;
 		if (cmp < 0)
 			node = &parent->rb_left;
 		else if (cmp > 0)
@@ -430,34 +440,28 @@ __page_stat__findnew_page(u64 page, bool create)
 
 	data = zalloc(sizeof(*data));
 	if (data != NULL) {
-		data->page = page;
+		data->page = pstat->page;
+		data->order = pstat->order;
+		data->gfp_flags = pstat->gfp_flags;
+		data->migrate_type = pstat->migrate_type;
 
 		rb_link_node(&data->node, parent, node);
-		rb_insert_color(&data->node, &page_tree);
+		rb_insert_color(&data->node, &page_live_tree);
 	}
 
 	return data;
 }
 
-static struct page_stat *page_stat__find_page(u64 page)
+static struct page_stat *page_stat__find_page(struct page_stat *pstat)
 {
-	return __page_stat__findnew_page(page, false);
+	return __page_stat__findnew_page(pstat, false);
 }
 
-static struct page_stat *page_stat__findnew_page(u64 page)
+static struct page_stat *page_stat__findnew_page(struct page_stat *pstat)
 {
-	return __page_stat__findnew_page(page, true);
+	return __page_stat__findnew_page(pstat, true);
 }
 
-struct sort_dimension {
-	const char		name[20];
-	sort_fn_t		cmp;
-	struct list_head	list;
-};
-
-static LIST_HEAD(page_alloc_sort_input);
-static LIST_HEAD(page_caller_sort_input);
-
 static struct page_stat *
 __page_stat__findnew_alloc(struct page_stat *pstat, bool create)
 {
@@ -615,17 +619,8 @@ static int perf_evsel__process_page_alloc_event(struct perf_evsel *evsel,
 	 * This is to find the current page (with correct gfp flags and
 	 * migrate type) at free event.
 	 */
-	pstat = page_stat__findnew_page(page);
-	if (pstat == NULL)
-		return -ENOMEM;
-
-	pstat->order = order;
-	pstat->gfp_flags = gfp_flags;
-	pstat->migrate_type = migrate_type;
-	pstat->callsite = callsite;
-
 	this.page = page;
-	pstat = page_stat__findnew_alloc(&this);
+	pstat = page_stat__findnew_page(&this);
 	if (pstat == NULL)
 		return -ENOMEM;
 
@@ -633,6 +628,16 @@ static int perf_evsel__process_page_alloc_event(struct perf_evsel *evsel,
 	pstat->alloc_bytes += bytes;
 	pstat->callsite = callsite;
 
+	if (!live_page) {
+		pstat = page_stat__findnew_alloc(&this);
+		if (pstat == NULL)
+			return -ENOMEM;
+
+		pstat->nr_alloc++;
+		pstat->alloc_bytes += bytes;
+		pstat->callsite = callsite;
+	}
+
 	this.callsite = callsite;
 	pstat = page_stat__findnew_caller(&this);
 	if (pstat == NULL)
@@ -665,7 +670,8 @@ static int perf_evsel__process_page_free_event(struct perf_evsel *evsel,
 	nr_page_frees++;
 	total_page_free_bytes += bytes;
 
-	pstat = page_stat__find_page(page);
+	this.page = page;
+	pstat = page_stat__find_page(&this);
 	if (pstat == NULL) {
 		pr_debug2("missing free at page %"PRIx64" (order: %d)\n",
 			  page, order);
@@ -676,20 +682,23 @@ static int perf_evsel__process_page_free_event(struct perf_evsel *evsel,
 		return 0;
 	}
 
-	this.page = page;
 	this.gfp_flags = pstat->gfp_flags;
 	this.migrate_type = pstat->migrate_type;
 	this.callsite = pstat->callsite;
 
-	rb_erase(&pstat->node, &page_tree);
+	rb_erase(&pstat->node, &page_live_tree);
 	free(pstat);
 
-	pstat = page_stat__find_alloc(&this);
-	if (pstat == NULL)
-		return -ENOENT;
+	if (live_page) {
+		order_stats[this.order][this.migrate_type]--;
+	} else {
+		pstat = page_stat__find_alloc(&this);
+		if (pstat == NULL)
+			return -ENOMEM;
 
-	pstat->nr_free++;
-	pstat->free_bytes += bytes;
+		pstat->nr_free++;
+		pstat->free_bytes += bytes;
+	}
 
 	pstat = page_stat__find_caller(&this);
 	if (pstat == NULL)
@@ -698,6 +707,16 @@ static int perf_evsel__process_page_free_event(struct perf_evsel *evsel,
 	pstat->nr_free++;
 	pstat->free_bytes += bytes;
 
+	if (live_page) {
+		pstat->nr_alloc--;
+		pstat->alloc_bytes -= bytes;
+
+		if (pstat->nr_alloc == 0) {
+			rb_erase(&pstat->node, &page_caller_tree);
+			free(pstat);
+		}
+	}
+
 	return 0;
 }
 
@@ -815,8 +834,8 @@ static void __print_page_alloc_result(struct perf_session *session, int n_lines)
 	const char *format;
 
 	printf("\n%.105s\n", graph_dotted_line);
-	printf(" %-16s | Total alloc (KB) | Hits      | Order | Mig.type | GFP flags | Callsite\n",
-	       use_pfn ? "PFN" : "Page");
+	printf(" %-16s | %5s alloc (KB) | Hits      | Order | Mig.type | GFP flags | Callsite\n",
+	       use_pfn ? "PFN" : "Page", live_page ? "Live" : "Total");
 	printf("%.105s\n", graph_dotted_line);
 
 	if (use_pfn)
@@ -860,7 +879,8 @@ static void __print_page_caller_result(struct perf_session *session, int n_lines
 	struct machine *machine = &session->machines.host;
 
 	printf("\n%.105s\n", graph_dotted_line);
-	printf(" Total alloc (KB) | Hits      | Order | Mig.type | GFP flags | Callsite\n");
+	printf(" %5s alloc (KB) | Hits      | Order | Mig.type | GFP flags | Callsite\n",
+	       live_page ? "Live" : "Total");
 	printf("%.105s\n", graph_dotted_line);
 
 	while (next && n_lines--) {
@@ -1085,8 +1105,13 @@ static void sort_result(void)
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
@@ -1630,6 +1655,7 @@ int cmd_kmem(int argc, const char **argv, const char *prefix __maybe_unused)
 			   parse_slab_opt),
 	OPT_CALLBACK_NOOPT(0, "page", NULL, NULL, "Analyze page allocator",
 			   parse_page_opt),
+	OPT_BOOLEAN(0, "live", &live_page, "Show live page stat"),
 	OPT_END()
 	};
 	const char *const kmem_subcommands[] = { "record", "stat", NULL };
-- 
2.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
