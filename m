Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 96FE66B006E
	for <linux-mm@kvack.org>; Mon,  4 May 2015 17:36:49 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so174386903pdb.0
        for <linux-mm@kvack.org>; Mon, 04 May 2015 14:36:49 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id rs11si21401059pab.141.2015.05.04.14.36.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 May 2015 14:36:46 -0700 (PDT)
From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH 18/21] perf kmem: Support sort keys on page analysis
Date: Mon,  4 May 2015 18:36:27 -0300
Message-Id: <1430775390-22523-19-git-send-email-acme@kernel.org>
In-Reply-To: <1430775390-22523-1-git-send-email-acme@kernel.org>
References: <1430775390-22523-1-git-send-email-acme@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, David Ahern <dsahern@gmail.com>, Jiri Olsa <jolsa@redhat.com>, Joonsoo Kim <js1304@gmail.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Arnaldo Carvalho de Melo <acme@redhat.com>

From: Namhyung Kim <namhyung@kernel.org>

Add new sort keys for page: page, order, migtype, gfp - existing
'bytes', 'hit' and 'callsite' sort keys also work for page.  Note that
-s/--sort option should be preceded by either of --slab or --page option
to determine where the sort keys applies.

Now it properly groups and sorts allocation stats - so same
page/caller with different order/migtype/gfp will be printed on a
different line.

 # perf kmem stat --page --caller -l 10 -s order,hit

 -----------------------------------------------------------------------------
 Total alloc (KB) | Hits   | Order | Mig.type | GFP flags | Callsite
 -----------------------------------------------------------------------------
               64 |      4 |     2 |  RECLAIM |  00285250 | new_slab
           50,144 | 12,536 |     0 |  MOVABLE |  0102005a | __page_cache_alloc
               52 |     13 |     0 | UNMOVABL |  002084d0 | pte_alloc_one
               40 |     10 |     0 |  MOVABLE |  000280da | handle_mm_fault
               28 |      7 |     0 | UNMOVABL |  000000d0 | __pollwait
               20 |      5 |     0 |  MOVABLE |  000200da | do_wp_page
               20 |      5 |     0 |  MOVABLE |  000200da | do_cow_fault
               16 |      4 |     0 | UNMOVABL |  00000200 | __tlb_remove_page
               16 |      4 |     0 | UNMOVABL |  000084d0 | __pmd_alloc
                8 |      2 |     0 | UNMOVABL |  000084d0 | __pud_alloc
 ...              | ...    | ...   | ...      | ...       | ...
 -----------------------------------------------------------------------------

Signed-off-by: Namhyung Kim <namhyung@kernel.org>
Acked-by: Pekka Enberg <penberg@kernel.org>
Tested-by: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: David Ahern <dsahern@gmail.com>
Cc: Jiri Olsa <jolsa@redhat.com>
Cc: Joonsoo Kim <js1304@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/1429592107-1807-3-git-send-email-namhyung@kernel.org
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 tools/perf/Documentation/perf-kmem.txt |   6 +-
 tools/perf/builtin-kmem.c              | 393 ++++++++++++++++++++++++++-------
 2 files changed, 313 insertions(+), 86 deletions(-)

diff --git a/tools/perf/Documentation/perf-kmem.txt b/tools/perf/Documentation/perf-kmem.txt
index 23219c6..69e1812 100644
--- a/tools/perf/Documentation/perf-kmem.txt
+++ b/tools/perf/Documentation/perf-kmem.txt
@@ -37,7 +37,11 @@ OPTIONS
 
 -s <key[,key2...]>::
 --sort=<key[,key2...]>::
-	Sort the output (default: frag,hit,bytes)
+	Sort the output (default: 'frag,hit,bytes' for slab and 'bytes,hit'
+	for page).  Available sort keys are 'ptr, callsite, bytes, hit,
+	pingpong, frag' for slab and 'page, callsite, bytes, hit, order,
+	migtype, gfp' for page.  This option should be preceded by one of the
+	mode selection options - i.e. --slab, --page, --alloc and/or --caller.
 
 -l <num>::
 --line=<num>::
diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
index 3649eec..0393a7f 100644
--- a/tools/perf/builtin-kmem.c
+++ b/tools/perf/builtin-kmem.c
@@ -30,7 +30,7 @@ static int	kmem_page;
 static long	kmem_page_size;
 
 struct alloc_stat;
-typedef int (*sort_fn_t)(struct alloc_stat *, struct alloc_stat *);
+typedef int (*sort_fn_t)(void *, void *);
 
 static int			alloc_flag;
 static int			caller_flag;
@@ -181,8 +181,8 @@ static int perf_evsel__process_alloc_node_event(struct perf_evsel *evsel,
 	return ret;
 }
 
-static int ptr_cmp(struct alloc_stat *, struct alloc_stat *);
-static int callsite_cmp(struct alloc_stat *, struct alloc_stat *);
+static int ptr_cmp(void *, void *);
+static int slab_callsite_cmp(void *, void *);
 
 static struct alloc_stat *search_alloc_stat(unsigned long ptr,
 					    unsigned long call_site,
@@ -223,7 +223,8 @@ static int perf_evsel__process_free_event(struct perf_evsel *evsel,
 		s_alloc->pingpong++;
 
 		s_caller = search_alloc_stat(0, s_alloc->call_site,
-					     &root_caller_stat, callsite_cmp);
+					     &root_caller_stat,
+					     slab_callsite_cmp);
 		if (!s_caller)
 			return -1;
 		s_caller->pingpong++;
@@ -448,26 +449,14 @@ static struct page_stat *page_stat__findnew_page(u64 page)
 	return __page_stat__findnew_page(page, true);
 }
 
-static int page_stat_cmp(struct page_stat *a, struct page_stat *b)
-{
-	if (a->page > b->page)
-		return -1;
-	if (a->page < b->page)
-		return 1;
-	if (a->order > b->order)
-		return -1;
-	if (a->order < b->order)
-		return 1;
-	if (a->migrate_type > b->migrate_type)
-		return -1;
-	if (a->migrate_type < b->migrate_type)
-		return 1;
-	if (a->gfp_flags > b->gfp_flags)
-		return -1;
-	if (a->gfp_flags < b->gfp_flags)
-		return 1;
-	return 0;
-}
+struct sort_dimension {
+	const char		name[20];
+	sort_fn_t		cmp;
+	struct list_head	list;
+};
+
+static LIST_HEAD(page_alloc_sort_input);
+static LIST_HEAD(page_caller_sort_input);
 
 static struct page_stat *
 __page_stat__findnew_alloc(struct page_stat *pstat, bool create)
@@ -475,14 +464,20 @@ __page_stat__findnew_alloc(struct page_stat *pstat, bool create)
 	struct rb_node **node = &page_alloc_tree.rb_node;
 	struct rb_node *parent = NULL;
 	struct page_stat *data;
+	struct sort_dimension *sort;
 
 	while (*node) {
-		s64 cmp;
+		int cmp = 0;
 
 		parent = *node;
 		data = rb_entry(*node, struct page_stat, node);
 
-		cmp = page_stat_cmp(data, pstat);
+		list_for_each_entry(sort, &page_alloc_sort_input, list) {
+			cmp = sort->cmp(pstat, data);
+			if (cmp)
+				break;
+		}
+
 		if (cmp < 0)
 			node = &parent->rb_left;
 		else if (cmp > 0)
@@ -519,19 +514,25 @@ static struct page_stat *page_stat__findnew_alloc(struct page_stat *pstat)
 }
 
 static struct page_stat *
-__page_stat__findnew_caller(u64 callsite, bool create)
+__page_stat__findnew_caller(struct page_stat *pstat, bool create)
 {
 	struct rb_node **node = &page_caller_tree.rb_node;
 	struct rb_node *parent = NULL;
 	struct page_stat *data;
+	struct sort_dimension *sort;
 
 	while (*node) {
-		s64 cmp;
+		int cmp = 0;
 
 		parent = *node;
 		data = rb_entry(*node, struct page_stat, node);
 
-		cmp = data->callsite - callsite;
+		list_for_each_entry(sort, &page_caller_sort_input, list) {
+			cmp = sort->cmp(pstat, data);
+			if (cmp)
+				break;
+		}
+
 		if (cmp < 0)
 			node = &parent->rb_left;
 		else if (cmp > 0)
@@ -545,7 +546,10 @@ __page_stat__findnew_caller(u64 callsite, bool create)
 
 	data = zalloc(sizeof(*data));
 	if (data != NULL) {
-		data->callsite = callsite;
+		data->callsite = pstat->callsite;
+		data->order = pstat->order;
+		data->gfp_flags = pstat->gfp_flags;
+		data->migrate_type = pstat->migrate_type;
 
 		rb_link_node(&data->node, parent, node);
 		rb_insert_color(&data->node, &page_caller_tree);
@@ -554,14 +558,14 @@ __page_stat__findnew_caller(u64 callsite, bool create)
 	return data;
 }
 
-static struct page_stat *page_stat__find_caller(u64 callsite)
+static struct page_stat *page_stat__find_caller(struct page_stat *pstat)
 {
-	return __page_stat__findnew_caller(callsite, false);
+	return __page_stat__findnew_caller(pstat, false);
 }
 
-static struct page_stat *page_stat__findnew_caller(u64 callsite)
+static struct page_stat *page_stat__findnew_caller(struct page_stat *pstat)
 {
-	return __page_stat__findnew_caller(callsite, true);
+	return __page_stat__findnew_caller(pstat, true);
 }
 
 static bool valid_page(u64 pfn_or_page)
@@ -629,14 +633,11 @@ static int perf_evsel__process_page_alloc_event(struct perf_evsel *evsel,
 	pstat->alloc_bytes += bytes;
 	pstat->callsite = callsite;
 
-	pstat = page_stat__findnew_caller(callsite);
+	this.callsite = callsite;
+	pstat = page_stat__findnew_caller(&this);
 	if (pstat == NULL)
 		return -ENOMEM;
 
-	pstat->order = order;
-	pstat->gfp_flags = gfp_flags;
-	pstat->migrate_type = migrate_type;
-
 	pstat->nr_alloc++;
 	pstat->alloc_bytes += bytes;
 
@@ -690,7 +691,7 @@ static int perf_evsel__process_page_free_event(struct perf_evsel *evsel,
 	pstat->nr_free++;
 	pstat->free_bytes += bytes;
 
-	pstat = page_stat__find_caller(this.callsite);
+	pstat = page_stat__find_caller(&this);
 	if (pstat == NULL)
 		return -ENOENT;
 
@@ -976,14 +977,10 @@ static void print_result(struct perf_session *session)
 		print_page_result(session);
 }
 
-struct sort_dimension {
-	const char		name[20];
-	sort_fn_t		cmp;
-	struct list_head	list;
-};
-
-static LIST_HEAD(caller_sort);
-static LIST_HEAD(alloc_sort);
+static LIST_HEAD(slab_caller_sort);
+static LIST_HEAD(slab_alloc_sort);
+static LIST_HEAD(page_caller_sort);
+static LIST_HEAD(page_alloc_sort);
 
 static void sort_slab_insert(struct rb_root *root, struct alloc_stat *data,
 			     struct list_head *sort_list)
@@ -1032,10 +1029,12 @@ static void __sort_slab_result(struct rb_root *root, struct rb_root *root_sorted
 	}
 }
 
-static void sort_page_insert(struct rb_root *root, struct page_stat *data)
+static void sort_page_insert(struct rb_root *root, struct page_stat *data,
+			     struct list_head *sort_list)
 {
 	struct rb_node **new = &root->rb_node;
 	struct rb_node *parent = NULL;
+	struct sort_dimension *sort;
 
 	while (*new) {
 		struct page_stat *this;
@@ -1044,8 +1043,11 @@ static void sort_page_insert(struct rb_root *root, struct page_stat *data)
 		this = rb_entry(*new, struct page_stat, node);
 		parent = *new;
 
-		/* TODO: support more sort key */
-		cmp = data->alloc_bytes - this->alloc_bytes;
+		list_for_each_entry(sort, sort_list, list) {
+			cmp = sort->cmp(data, this);
+			if (cmp)
+				break;
+		}
 
 		if (cmp > 0)
 			new = &parent->rb_left;
@@ -1057,7 +1059,8 @@ static void sort_page_insert(struct rb_root *root, struct page_stat *data)
 	rb_insert_color(&data->node, root);
 }
 
-static void __sort_page_result(struct rb_root *root, struct rb_root *root_sorted)
+static void __sort_page_result(struct rb_root *root, struct rb_root *root_sorted,
+			       struct list_head *sort_list)
 {
 	struct rb_node *node;
 	struct page_stat *data;
@@ -1069,7 +1072,7 @@ static void __sort_page_result(struct rb_root *root, struct rb_root *root_sorted
 
 		rb_erase(node, root);
 		data = rb_entry(node, struct page_stat, node);
-		sort_page_insert(root_sorted, data);
+		sort_page_insert(root_sorted, data, sort_list);
 	}
 }
 
@@ -1077,13 +1080,15 @@ static void sort_result(void)
 {
 	if (kmem_slab) {
 		__sort_slab_result(&root_alloc_stat, &root_alloc_sorted,
-				   &alloc_sort);
+				   &slab_alloc_sort);
 		__sort_slab_result(&root_caller_stat, &root_caller_sorted,
-				   &caller_sort);
+				   &slab_caller_sort);
 	}
 	if (kmem_page) {
-		__sort_page_result(&page_alloc_tree, &page_alloc_sorted);
-		__sort_page_result(&page_caller_tree, &page_caller_sorted);
+		__sort_page_result(&page_alloc_tree, &page_alloc_sorted,
+				   &page_alloc_sort);
+		__sort_page_result(&page_caller_tree, &page_caller_sorted,
+				   &page_caller_sort);
 	}
 }
 
@@ -1132,8 +1137,12 @@ out:
 	return err;
 }
 
-static int ptr_cmp(struct alloc_stat *l, struct alloc_stat *r)
+/* slab sort keys */
+static int ptr_cmp(void *a, void *b)
 {
+	struct alloc_stat *l = a;
+	struct alloc_stat *r = b;
+
 	if (l->ptr < r->ptr)
 		return -1;
 	else if (l->ptr > r->ptr)
@@ -1146,8 +1155,11 @@ static struct sort_dimension ptr_sort_dimension = {
 	.cmp	= ptr_cmp,
 };
 
-static int callsite_cmp(struct alloc_stat *l, struct alloc_stat *r)
+static int slab_callsite_cmp(void *a, void *b)
 {
+	struct alloc_stat *l = a;
+	struct alloc_stat *r = b;
+
 	if (l->call_site < r->call_site)
 		return -1;
 	else if (l->call_site > r->call_site)
@@ -1157,11 +1169,14 @@ static int callsite_cmp(struct alloc_stat *l, struct alloc_stat *r)
 
 static struct sort_dimension callsite_sort_dimension = {
 	.name	= "callsite",
-	.cmp	= callsite_cmp,
+	.cmp	= slab_callsite_cmp,
 };
 
-static int hit_cmp(struct alloc_stat *l, struct alloc_stat *r)
+static int hit_cmp(void *a, void *b)
 {
+	struct alloc_stat *l = a;
+	struct alloc_stat *r = b;
+
 	if (l->hit < r->hit)
 		return -1;
 	else if (l->hit > r->hit)
@@ -1174,8 +1189,11 @@ static struct sort_dimension hit_sort_dimension = {
 	.cmp	= hit_cmp,
 };
 
-static int bytes_cmp(struct alloc_stat *l, struct alloc_stat *r)
+static int bytes_cmp(void *a, void *b)
 {
+	struct alloc_stat *l = a;
+	struct alloc_stat *r = b;
+
 	if (l->bytes_alloc < r->bytes_alloc)
 		return -1;
 	else if (l->bytes_alloc > r->bytes_alloc)
@@ -1188,9 +1206,11 @@ static struct sort_dimension bytes_sort_dimension = {
 	.cmp	= bytes_cmp,
 };
 
-static int frag_cmp(struct alloc_stat *l, struct alloc_stat *r)
+static int frag_cmp(void *a, void *b)
 {
 	double x, y;
+	struct alloc_stat *l = a;
+	struct alloc_stat *r = b;
 
 	x = fragmentation(l->bytes_req, l->bytes_alloc);
 	y = fragmentation(r->bytes_req, r->bytes_alloc);
@@ -1207,8 +1227,11 @@ static struct sort_dimension frag_sort_dimension = {
 	.cmp	= frag_cmp,
 };
 
-static int pingpong_cmp(struct alloc_stat *l, struct alloc_stat *r)
+static int pingpong_cmp(void *a, void *b)
 {
+	struct alloc_stat *l = a;
+	struct alloc_stat *r = b;
+
 	if (l->pingpong < r->pingpong)
 		return -1;
 	else if (l->pingpong > r->pingpong)
@@ -1221,7 +1244,135 @@ static struct sort_dimension pingpong_sort_dimension = {
 	.cmp	= pingpong_cmp,
 };
 
-static struct sort_dimension *avail_sorts[] = {
+/* page sort keys */
+static int page_cmp(void *a, void *b)
+{
+	struct page_stat *l = a;
+	struct page_stat *r = b;
+
+	if (l->page < r->page)
+		return -1;
+	else if (l->page > r->page)
+		return 1;
+	return 0;
+}
+
+static struct sort_dimension page_sort_dimension = {
+	.name	= "page",
+	.cmp	= page_cmp,
+};
+
+static int page_callsite_cmp(void *a, void *b)
+{
+	struct page_stat *l = a;
+	struct page_stat *r = b;
+
+	if (l->callsite < r->callsite)
+		return -1;
+	else if (l->callsite > r->callsite)
+		return 1;
+	return 0;
+}
+
+static struct sort_dimension page_callsite_sort_dimension = {
+	.name	= "callsite",
+	.cmp	= page_callsite_cmp,
+};
+
+static int page_hit_cmp(void *a, void *b)
+{
+	struct page_stat *l = a;
+	struct page_stat *r = b;
+
+	if (l->nr_alloc < r->nr_alloc)
+		return -1;
+	else if (l->nr_alloc > r->nr_alloc)
+		return 1;
+	return 0;
+}
+
+static struct sort_dimension page_hit_sort_dimension = {
+	.name	= "hit",
+	.cmp	= page_hit_cmp,
+};
+
+static int page_bytes_cmp(void *a, void *b)
+{
+	struct page_stat *l = a;
+	struct page_stat *r = b;
+
+	if (l->alloc_bytes < r->alloc_bytes)
+		return -1;
+	else if (l->alloc_bytes > r->alloc_bytes)
+		return 1;
+	return 0;
+}
+
+static struct sort_dimension page_bytes_sort_dimension = {
+	.name	= "bytes",
+	.cmp	= page_bytes_cmp,
+};
+
+static int page_order_cmp(void *a, void *b)
+{
+	struct page_stat *l = a;
+	struct page_stat *r = b;
+
+	if (l->order < r->order)
+		return -1;
+	else if (l->order > r->order)
+		return 1;
+	return 0;
+}
+
+static struct sort_dimension page_order_sort_dimension = {
+	.name	= "order",
+	.cmp	= page_order_cmp,
+};
+
+static int migrate_type_cmp(void *a, void *b)
+{
+	struct page_stat *l = a;
+	struct page_stat *r = b;
+
+	/* for internal use to find free'd page */
+	if (l->migrate_type == -1U)
+		return 0;
+
+	if (l->migrate_type < r->migrate_type)
+		return -1;
+	else if (l->migrate_type > r->migrate_type)
+		return 1;
+	return 0;
+}
+
+static struct sort_dimension migrate_type_sort_dimension = {
+	.name	= "migtype",
+	.cmp	= migrate_type_cmp,
+};
+
+static int gfp_flags_cmp(void *a, void *b)
+{
+	struct page_stat *l = a;
+	struct page_stat *r = b;
+
+	/* for internal use to find free'd page */
+	if (l->gfp_flags == -1U)
+		return 0;
+
+	if (l->gfp_flags < r->gfp_flags)
+		return -1;
+	else if (l->gfp_flags > r->gfp_flags)
+		return 1;
+	return 0;
+}
+
+static struct sort_dimension gfp_flags_sort_dimension = {
+	.name	= "gfp",
+	.cmp	= gfp_flags_cmp,
+};
+
+static struct sort_dimension *slab_sorts[] = {
 	&ptr_sort_dimension,
 	&callsite_sort_dimension,
 	&hit_sort_dimension,
@@ -1230,16 +1381,24 @@ static struct sort_dimension *avail_sorts[] = {
 	&pingpong_sort_dimension,
 };
 
-#define NUM_AVAIL_SORTS	((int)ARRAY_SIZE(avail_sorts))
+static struct sort_dimension *page_sorts[] = {
+	&page_sort_dimension,
+	&page_callsite_sort_dimension,
+	&page_hit_sort_dimension,
+	&page_bytes_sort_dimension,
+	&page_order_sort_dimension,
+	&migrate_type_sort_dimension,
+	&gfp_flags_sort_dimension,
+};
 
-static int sort_dimension__add(const char *tok, struct list_head *list)
+static int slab_sort_dimension__add(const char *tok, struct list_head *list)
 {
 	struct sort_dimension *sort;
 	int i;
 
-	for (i = 0; i < NUM_AVAIL_SORTS; i++) {
-		if (!strcmp(avail_sorts[i]->name, tok)) {
-			sort = memdup(avail_sorts[i], sizeof(*avail_sorts[i]));
+	for (i = 0; i < (int)ARRAY_SIZE(slab_sorts); i++) {
+		if (!strcmp(slab_sorts[i]->name, tok)) {
+			sort = memdup(slab_sorts[i], sizeof(*slab_sorts[i]));
 			if (!sort) {
 				pr_err("%s: memdup failed\n", __func__);
 				return -1;
@@ -1252,7 +1411,27 @@ static int sort_dimension__add(const char *tok, struct list_head *list)
 	return -1;
 }
 
-static int setup_sorting(struct list_head *sort_list, const char *arg)
+static int page_sort_dimension__add(const char *tok, struct list_head *list)
+{
+	struct sort_dimension *sort;
+	int i;
+
+	for (i = 0; i < (int)ARRAY_SIZE(page_sorts); i++) {
+		if (!strcmp(page_sorts[i]->name, tok)) {
+			sort = memdup(page_sorts[i], sizeof(*page_sorts[i]));
+			if (!sort) {
+				pr_err("%s: memdup failed\n", __func__);
+				return -1;
+			}
+			list_add_tail(&sort->list, list);
+			return 0;
+		}
+	}
+
+	return -1;
+}
+
+static int setup_slab_sorting(struct list_head *sort_list, const char *arg)
 {
 	char *tok;
 	char *str = strdup(arg);
@@ -1267,8 +1446,34 @@ static int setup_sorting(struct list_head *sort_list, const char *arg)
 		tok = strsep(&pos, ",");
 		if (!tok)
 			break;
-		if (sort_dimension__add(tok, sort_list) < 0) {
-			error("Unknown --sort key: '%s'", tok);
+		if (slab_sort_dimension__add(tok, sort_list) < 0) {
+			error("Unknown slab --sort key: '%s'", tok);
+			free(str);
+			return -1;
+		}
+	}
+
+	free(str);
+	return 0;
+}
+
+static int setup_page_sorting(struct list_head *sort_list, const char *arg)
+{
+	char *tok;
+	char *str = strdup(arg);
+	char *pos = str;
+
+	if (!str) {
+		pr_err("%s: strdup failed\n", __func__);
+		return -1;
+	}
+
+	while (true) {
+		tok = strsep(&pos, ",");
+		if (!tok)
+			break;
+		if (page_sort_dimension__add(tok, sort_list) < 0) {
+			error("Unknown page --sort key: '%s'", tok);
 			free(str);
 			return -1;
 		}
@@ -1284,10 +1489,17 @@ static int parse_sort_opt(const struct option *opt __maybe_unused,
 	if (!arg)
 		return -1;
 
-	if (caller_flag > alloc_flag)
-		return setup_sorting(&caller_sort, arg);
-	else
-		return setup_sorting(&alloc_sort, arg);
+	if (kmem_page > kmem_slab) {
+		if (caller_flag > alloc_flag)
+			return setup_page_sorting(&page_caller_sort, arg);
+		else
+			return setup_page_sorting(&page_alloc_sort, arg);
+	} else {
+		if (caller_flag > alloc_flag)
+			return setup_slab_sorting(&slab_caller_sort, arg);
+		else
+			return setup_slab_sorting(&slab_alloc_sort, arg);
+	}
 
 	return 0;
 }
@@ -1395,7 +1607,8 @@ static int __cmd_record(int argc, const char **argv)
 
 int cmd_kmem(int argc, const char **argv, const char *prefix __maybe_unused)
 {
-	const char * const default_sort_order = "frag,hit,bytes";
+	const char * const default_slab_sort = "frag,hit,bytes";
+	const char * const default_page_sort = "bytes,hit";
 	struct perf_data_file file = {
 		.mode = PERF_DATA_MODE_READ,
 	};
@@ -1408,8 +1621,8 @@ int cmd_kmem(int argc, const char **argv, const char *prefix __maybe_unused)
 	OPT_CALLBACK_NOOPT(0, "alloc", NULL, NULL,
 			   "show per-allocation statistics", parse_alloc_opt),
 	OPT_CALLBACK('s', "sort", NULL, "key[,key2...]",
-		     "sort by keys: ptr, call_site, bytes, hit, pingpong, frag",
-		     parse_sort_opt),
+		     "sort by keys: ptr, callsite, bytes, hit, pingpong, frag, "
+		     "page, order, migtype, gfp", parse_sort_opt),
 	OPT_CALLBACK('l', "line", NULL, "num", "show n lines", parse_line_opt),
 	OPT_BOOLEAN(0, "raw-ip", &raw_ip, "show raw ip instead of symbol"),
 	OPT_BOOLEAN('f', "force", &file.force, "don't complain, do it"),
@@ -1467,11 +1680,21 @@ int cmd_kmem(int argc, const char **argv, const char *prefix __maybe_unused)
 		if (cpu__setup_cpunode_map())
 			goto out_delete;
 
-		if (list_empty(&caller_sort))
-			setup_sorting(&caller_sort, default_sort_order);
-		if (list_empty(&alloc_sort))
-			setup_sorting(&alloc_sort, default_sort_order);
-
+		if (list_empty(&slab_caller_sort))
+			setup_slab_sorting(&slab_caller_sort, default_slab_sort);
+		if (list_empty(&slab_alloc_sort))
+			setup_slab_sorting(&slab_alloc_sort, default_slab_sort);
+		if (list_empty(&page_caller_sort))
+			setup_page_sorting(&page_caller_sort, default_page_sort);
+		if (list_empty(&page_alloc_sort))
+			setup_page_sorting(&page_alloc_sort, default_page_sort);
+
+		if (kmem_page) {
+			setup_page_sorting(&page_alloc_sort_input,
+					   "page,order,migtype,gfp");
+			setup_page_sorting(&page_caller_sort_input,
+					   "callsite,order,migtype,gfp");
+		}
 		ret = __cmd_kmem(session);
 	} else
 		usage_with_options(kmem_usage, kmem_options);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
