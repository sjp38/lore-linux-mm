Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 667EA6B0082
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 00:26:56 -0500 (EST)
Message-ID: <4B0B6E72.7010200@cn.fujitsu.com>
Date: Tue, 24 Nov 2009 13:26:10 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 2/5] perf kmem: Default to sort by fragmentation
References: <4B0B6E44.6090106@cn.fujitsu.com>
In-Reply-To: <4B0B6E44.6090106@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Peter Zijlstra <peterz@infradead.org>, Frederic Weisbecker <fweisbec@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Make the output sort by fragmentation by default.

Also make the usage of "--sort" option consistent with other perf
tools. That is, we support multi keys: "--sort key1[,key2]...".

 # ./perf kmem --stat caller
 ------------------------------------------------------------------------------
 Callsite                    |Total_alloc/Per | Total_req/Per | Hit  | Frag
 ------------------------------------------------------------------------------
 __netdev_alloc_skb+23       |    5048/1682   |    4564/1521  |     3|   9.588%
 perf_event_alloc.clone.0+0  |    7504/682    |    7128/648   |    11|   5.011%
 tracepoint_add_probe+32e    |     157/31     |     154/30    |     5|   1.911%
 alloc_buffer_head+16        |     456/57     |     448/56    |     8|   1.754%
 radix_tree_preload+51       |     584/292    |     576/288   |     2|   1.370%
 ...

TODO:
- Extract duplicate code in builtin-kmem.c and builtin-sched.c
  into util/sort.c.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 tools/perf/builtin-kmem.c |  142 ++++++++++++++++++++++++++++++++++-----------
 1 files changed, 108 insertions(+), 34 deletions(-)

diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
index 1ef43c2..dc86f1e 100644
--- a/tools/perf/builtin-kmem.c
+++ b/tools/perf/builtin-kmem.c
@@ -26,14 +26,13 @@ static u64			sample_type;
 static int			alloc_flag;
 static int			caller_flag;
 
-sort_fn_t			alloc_sort_fn;
-sort_fn_t			caller_sort_fn;
-
 static int			alloc_lines = -1;
 static int			caller_lines = -1;
 
 static bool			raw_ip;
 
+static char			default_sort_order[] = "frag,hit,bytes";
+
 static char			*cwd;
 static int			cwdlen;
 
@@ -371,20 +370,34 @@ static void print_result(void)
 	print_summary();
 }
 
+struct sort_dimension {
+	const char		name[20];
+	sort_fn_t		cmp;
+	struct list_head	list;
+};
+
+static LIST_HEAD(caller_sort);
+static LIST_HEAD(alloc_sort);
+
 static void sort_insert(struct rb_root *root, struct alloc_stat *data,
-			sort_fn_t sort_fn)
+			struct list_head *sort_list)
 {
 	struct rb_node **new = &(root->rb_node);
 	struct rb_node *parent = NULL;
+	struct sort_dimension *sort;
 
 	while (*new) {
 		struct alloc_stat *this;
-		int cmp;
+		int cmp = 0;
 
 		this = rb_entry(*new, struct alloc_stat, node);
 		parent = *new;
 
-		cmp = sort_fn(data, this);
+		list_for_each_entry(sort, sort_list, list) {
+			cmp = sort->cmp(data, this);
+			if (cmp)
+				break;
+		}
 
 		if (cmp > 0)
 			new = &((*new)->rb_left);
@@ -397,7 +410,7 @@ static void sort_insert(struct rb_root *root, struct alloc_stat *data,
 }
 
 static void __sort_result(struct rb_root *root, struct rb_root *root_sorted,
-			  sort_fn_t sort_fn)
+			  struct list_head *sort_list)
 {
 	struct rb_node *node;
 	struct alloc_stat *data;
@@ -409,14 +422,14 @@ static void __sort_result(struct rb_root *root, struct rb_root *root_sorted,
 
 		rb_erase(node, root);
 		data = rb_entry(node, struct alloc_stat, node);
-		sort_insert(root_sorted, data, sort_fn);
+		sort_insert(root_sorted, data, sort_list);
 	}
 }
 
 static void sort_result(void)
 {
-	__sort_result(&root_alloc_stat, &root_alloc_sorted, alloc_sort_fn);
-	__sort_result(&root_caller_stat, &root_caller_sorted, caller_sort_fn);
+	__sort_result(&root_alloc_stat, &root_alloc_sorted, &alloc_sort);
+	__sort_result(&root_caller_stat, &root_caller_sorted, &caller_sort);
 }
 
 static int __cmd_kmem(void)
@@ -434,7 +447,6 @@ static const char * const kmem_usage[] = {
 	NULL
 };
 
-
 static int ptr_cmp(struct alloc_stat *l, struct alloc_stat *r)
 {
 	if (l->ptr < r->ptr)
@@ -444,6 +456,11 @@ static int ptr_cmp(struct alloc_stat *l, struct alloc_stat *r)
 	return 0;
 }
 
+static struct sort_dimension ptr_sort_dimension = {
+	.name	= "ptr",
+	.cmp	= ptr_cmp,
+};
+
 static int callsite_cmp(struct alloc_stat *l, struct alloc_stat *r)
 {
 	if (l->call_site < r->call_site)
@@ -453,6 +470,11 @@ static int callsite_cmp(struct alloc_stat *l, struct alloc_stat *r)
 	return 0;
 }
 
+static struct sort_dimension callsite_sort_dimension = {
+	.name	= "callsite",
+	.cmp	= callsite_cmp,
+};
+
 static int hit_cmp(struct alloc_stat *l, struct alloc_stat *r)
 {
 	if (l->hit < r->hit)
@@ -462,6 +484,11 @@ static int hit_cmp(struct alloc_stat *l, struct alloc_stat *r)
 	return 0;
 }
 
+static struct sort_dimension hit_sort_dimension = {
+	.name	= "hit",
+	.cmp	= hit_cmp,
+};
+
 static int bytes_cmp(struct alloc_stat *l, struct alloc_stat *r)
 {
 	if (l->bytes_alloc < r->bytes_alloc)
@@ -471,6 +498,11 @@ static int bytes_cmp(struct alloc_stat *l, struct alloc_stat *r)
 	return 0;
 }
 
+static struct sort_dimension bytes_sort_dimension = {
+	.name	= "bytes",
+	.cmp	= bytes_cmp,
+};
+
 static int frag_cmp(struct alloc_stat *l, struct alloc_stat *r)
 {
 	double x, y;
@@ -485,31 +517,73 @@ static int frag_cmp(struct alloc_stat *l, struct alloc_stat *r)
 	return 0;
 }
 
+static struct sort_dimension frag_sort_dimension = {
+	.name	= "frag",
+	.cmp	= frag_cmp,
+};
+
+static struct sort_dimension *avail_sorts[] = {
+	&ptr_sort_dimension,
+	&callsite_sort_dimension,
+	&hit_sort_dimension,
+	&bytes_sort_dimension,
+	&frag_sort_dimension,
+};
+
+#define NUM_AVAIL_SORTS	\
+	(int)(sizeof(avail_sorts) / sizeof(struct sort_dimension *))
+
+static int sort_dimension__add(const char *tok, struct list_head *list)
+{
+	struct sort_dimension *sort;
+	int i;
+
+	for (i = 0; i < NUM_AVAIL_SORTS; i++) {
+		if (!strcmp(avail_sorts[i]->name, tok)) {
+			sort = malloc(sizeof(*sort));
+			if (!sort)
+				die("malloc");
+			memcpy(sort, avail_sorts[i], sizeof(*sort));
+			list_add_tail(&sort->list, list);
+			return 0;
+		}
+	}
+
+	return -1;
+}
+
+static int setup_sorting(struct list_head *sort_list, const char *arg)
+{
+	char *tok;
+	char *str = strdup(arg);
+
+	if (!str)
+		die("strdup");
+
+	while (true) {
+		tok = strsep(&str, ",");
+		if (!tok)
+			break;
+		if (sort_dimension__add(tok, sort_list) < 0) {
+			error("Unknown --sort key: '%s'", tok);
+			return -1;
+		}
+	}
+
+	free(str);
+	return 0;
+}
+
 static int parse_sort_opt(const struct option *opt __used,
 			  const char *arg, int unset __used)
 {
-	sort_fn_t sort_fn;
-
 	if (!arg)
 		return -1;
 
-	if (strcmp(arg, "ptr") == 0)
-		sort_fn = ptr_cmp;
-	else if (strcmp(arg, "call_site") == 0)
-		sort_fn = callsite_cmp;
-	else if (strcmp(arg, "hit") == 0)
-		sort_fn = hit_cmp;
-	else if (strcmp(arg, "bytes") == 0)
-		sort_fn = bytes_cmp;
-	else if (strcmp(arg, "frag") == 0)
-		sort_fn = frag_cmp;
-	else
-		return -1;
-
 	if (caller_flag > alloc_flag)
-		caller_sort_fn = sort_fn;
+		return setup_sorting(&caller_sort, arg);
 	else
-		alloc_sort_fn = sort_fn;
+		return setup_sorting(&alloc_sort, arg);
 
 	return 0;
 }
@@ -553,8 +627,8 @@ static const struct option kmem_options[] = {
 	OPT_CALLBACK(0, "stat", NULL, "<alloc>|<caller>",
 		     "stat selector, Pass 'alloc' or 'caller'.",
 		     parse_stat_opt),
-	OPT_CALLBACK('s', "sort", NULL, "key",
-		     "sort by key: ptr, call_site, hit, bytes, frag",
+	OPT_CALLBACK('s', "sort", NULL, "key[,key2...]",
+		     "sort by key(s): ptr, call_site, bytes, hit, frag",
 		     parse_sort_opt),
 	OPT_CALLBACK('l', "line", NULL, "num",
 		     "show n lins",
@@ -606,10 +680,10 @@ int cmd_kmem(int argc, const char **argv, const char *prefix __used)
 	else if (argc)
 		usage_with_options(kmem_usage, kmem_options);
 
-	if (!alloc_sort_fn)
-		alloc_sort_fn = bytes_cmp;
-	if (!caller_sort_fn)
-		caller_sort_fn = bytes_cmp;
+	if (list_empty(&caller_sort))
+		setup_sorting(&caller_sort, default_sort_order);
+	if (list_empty(&alloc_sort))
+		setup_sorting(&alloc_sort, default_sort_order);
 
 	return __cmd_kmem();
 }
-- 
1.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
