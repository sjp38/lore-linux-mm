Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6ACD26B006C
	for <linux-mm@kvack.org>; Mon,  4 May 2015 17:36:47 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so171905798pab.2
        for <linux-mm@kvack.org>; Mon, 04 May 2015 14:36:47 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id qz4si21381369pac.210.2015.05.04.14.36.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 May 2015 14:36:46 -0700 (PDT)
From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH 19/21] perf kmem: Add --live option for current allocation stat
Date: Mon,  4 May 2015 18:36:28 -0300
Message-Id: <1430775390-22523-20-git-send-email-acme@kernel.org>
In-Reply-To: <1430775390-22523-1-git-send-email-acme@kernel.org>
References: <1430775390-22523-1-git-send-email-acme@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, David Ahern <dsahern@gmail.com>, Jiri Olsa <jolsa@redhat.com>, Joonsoo Kim <js1304@gmail.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Arnaldo Carvalho de Melo <acme@redhat.com>

From: Namhyung Kim <namhyung@kernel.org>

Currently 'perf kmem stat --page' shows total (page) allocation stat by
default, but sometimes one might want to see live (total alloc-only)
requests/pages only.  The new --live option does this by subtracting freed
allocation from the stat.

E.g.:

 # perf kmem stat --page

 SUMMARY (page allocator)
 ========================
 Total allocation requests     :          988,858   [        4,045,368 KB ]
 Total free requests           :          886,484   [        3,624,996 KB ]

 Total alloc+freed requests    :          885,969   [        3,622,628 KB ]
 Total alloc-only requests     :          102,889   [          422,740 KB ]
 Total free-only requests      :              515   [            2,368 KB ]

 Total allocation failures     :                0   [                0 KB ]

 Order     Unmovable   Reclaimable       Movable      Reserved  CMA/Isolated
 -----  ------------  ------------  ------------  ------------  ------------
     0       172,173         3,083       806,686             .             .
     1           284             .             .             .             .
     2         6,124            58             .             .             .
     3           114           335             .             .             .
     4             .             .             .             .             .
     5             .             .             .             .             .
     6             .             .             .             .             .
     7             .             .             .             .             .
     8             .             .             .             .             .
     9             .             .             1             .             .
    10             .             .             .             .             .
 # perf kmem stat --page --live

 SUMMARY (page allocator)
 ========================
 Total allocation requests     :          988,858   [        4,045,368 KB ]
 Total free requests           :          886,484   [        3,624,996 KB ]

 Total alloc+freed requests    :          885,969   [        3,622,628 KB ]
 Total alloc-only requests     :          102,889   [          422,740 KB ]
 Total free-only requests      :              515   [            2,368 KB ]

 Total allocation failures     :                0   [                0 KB ]

 Order     Unmovable   Reclaimable       Movable      Reserved  CMA/Isolated
 -----  ------------  ------------  ------------  ------------  ------------
     0         2,214         3,025        97,156             .             .
     1            59             .             .             .             .
     2            19            58             .             .             .
     3            23           335             .             .             .
     4             .             .             .             .             .
     5             .             .             .             .             .
     6             .             .             .             .             .
     7             .             .             .             .             .
     8             .             .             .             .             .
     9             .             .             .             .             .
    10             .             .             .             .             .
 #

Signed-off-by: Namhyung Kim <namhyung@kernel.org>
Acked-by: Pekka Enberg <penberg@kernel.org>
Tested-by: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: David Ahern <dsahern@gmail.com>
Cc: Jiri Olsa <jolsa@redhat.com>
Cc: Joonsoo Kim <js1304@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/1429592107-1807-4-git-send-email-namhyung@kernel.org
[ Added examples to the changeset log ]
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 tools/perf/Documentation/perf-kmem.txt |   5 ++
 tools/perf/builtin-kmem.c              | 110 ++++++++++++++++++++-------------
 2 files changed, 73 insertions(+), 42 deletions(-)

diff --git a/tools/perf/Documentation/perf-kmem.txt b/tools/perf/Documentation/perf-kmem.txt
index 69e1812..ff0f433 100644
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
index 0393a7f..7ead942 100644
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
@@ -403,10 +404,19 @@ out:
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
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
