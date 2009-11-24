Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0E9446B0082
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 11:56:14 -0500 (EST)
Date: Tue, 24 Nov 2009 16:55:35 GMT
From: tip-bot for Li Zefan <lizf@cn.fujitsu.com>
Reply-To: mingo@redhat.com, hpa@zytor.com, linux-kernel@vger.kernel.org,
        fweisbec@gmail.com, lizf@cn.fujitsu.com, penberg@cs.helsinki.fi,
        peterz@infradead.org, eduard.munteanu@linux360.ro, tglx@linutronix.de,
        linux-mm@kvack.org, mingo@elte.hu
In-Reply-To: <4B0B6E9F.6020309@cn.fujitsu.com>
References: <4B0B6E9F.6020309@cn.fujitsu.com>
Subject: [tip:perf/core] perf kmem: Measure kmalloc/kfree CPU ping-pong call-sites
Message-ID: <tip-079d3f653134e2f2ac99dae28b08c0cc64268103@git.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-tip-commits@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, hpa@zytor.com, mingo@redhat.com, penberg@cs.helsinki.fi, lizf@cn.fujitsu.com, peterz@infradead.org, eduard.munteanu@linux360.ro, fweisbec@gmail.com, tglx@linutronix.de, linux-mm@kvack.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

Commit-ID:  079d3f653134e2f2ac99dae28b08c0cc64268103
Gitweb:     http://git.kernel.org/tip/079d3f653134e2f2ac99dae28b08c0cc64268103
Author:     Li Zefan <lizf@cn.fujitsu.com>
AuthorDate: Tue, 24 Nov 2009 13:26:55 +0800
Committer:  Ingo Molnar <mingo@elte.hu>
CommitDate: Tue, 24 Nov 2009 08:49:50 +0100

perf kmem: Measure kmalloc/kfree CPU ping-pong call-sites

Show statistics for allocations and frees on different cpus:

------------------------------------------------------------------------------------------------------
Callsite                           | Total_alloc/Per | Total_req/Per   | Hit   | Ping-pong | Frag
------------------------------------------------------------------------------------------------------
 perf_event_alloc.clone.0+0         |      7504/682   |      7128/648   |     11 |        0 |  5.011%
 alloc_buffer_head+16               |       288/57    |       280/56    |      5 |        0 |  2.778%
 radix_tree_preload+51              |       296/296   |       288/288   |      1 |        0 |  2.703%
 tracepoint_add_probe+32e           |       157/31    |       154/30    |      5 |        0 |  1.911%
 do_maps_open+0                     |       796/12    |       792/12    |     66 |        0 |  0.503%
 sock_alloc_send_pskb+16e           |     23780/495   |     23744/494   |     48 |       38 |  0.151%
 anon_vma_prepare+9a                |      3744/44    |      3740/44    |     85 |        0 |  0.107%
 d_alloc+21                         |     64948/164   |     64944/164   |    396 |        0 |  0.006%
 proc_alloc_inode+23                |    262292/676   |    262288/676   |    388 |        0 |  0.002%
 create_object+28                   |    459600/200   |    459600/200   |   2298 |       71 |  0.000%
 journal_start+67                   |     14440/40    |     14440/40    |    361 |        0 |  0.000%
 get_empty_filp+df                  |     53504/256   |     53504/256   |    209 |        0 |  0.000%
 getname+2a                         |    823296/4096  |    823296/4096  |    201 |        0 |  0.000%
 seq_read+2b0                       |    544768/4096  |    544768/4096  |    133 |        0 |  0.000%
 seq_open+6d                        |     17024/128   |     17024/128   |    133 |        0 |  0.000%
 mmap_region+2e6                    |     11704/88    |     11704/88    |    133 |        0 |  0.000%
 single_open+0                      |      1072/16    |      1072/16    |     67 |        0 |  0.000%
 __alloc_skb+2e                     |     12544/256   |     12544/256   |     49 |       38 |  0.000%
 __sigqueue_alloc+4a                |      1296/144   |      1296/144   |      9 |        8 |  0.000%
 tracepoint_add_probe+6f            |        80/16    |        80/16    |      5 |        0 |  0.000%
------------------------------------------------------------------------------------------------------
...

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Frederic Weisbecker <fweisbec@gmail.com>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
LKML-Reference: <4B0B6E9F.6020309@cn.fujitsu.com>
Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 tools/perf/builtin-kmem.c |  122 ++++++++++++++++++++++++++++++++++----------
 1 files changed, 94 insertions(+), 28 deletions(-)

diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
index 1ecf3f4..173d6db 100644
--- a/tools/perf/builtin-kmem.c
+++ b/tools/perf/builtin-kmem.c
@@ -40,13 +40,14 @@ static int			*cpunode_map;
 static int			max_cpu_num;
 
 struct alloc_stat {
-	union {
-		u64	call_site;
-		u64	ptr;
-	};
+	u64	call_site;
+	u64	ptr;
 	u64	bytes_req;
 	u64	bytes_alloc;
 	u32	hit;
+	u32	pingpong;
+
+	short	alloc_cpu;
 
 	struct rb_node node;
 };
@@ -144,16 +145,13 @@ process_comm_event(event_t *event, unsigned long offset, unsigned long head)
 	return 0;
 }
 
-static void insert_alloc_stat(unsigned long ptr,
-			      int bytes_req, int bytes_alloc)
+static void insert_alloc_stat(unsigned long call_site, unsigned long ptr,
+			      int bytes_req, int bytes_alloc, int cpu)
 {
 	struct rb_node **node = &root_alloc_stat.rb_node;
 	struct rb_node *parent = NULL;
 	struct alloc_stat *data = NULL;
 
-	if (!alloc_flag)
-		return;
-
 	while (*node) {
 		parent = *node;
 		data = rb_entry(*node, struct alloc_stat, node);
@@ -172,7 +170,10 @@ static void insert_alloc_stat(unsigned long ptr,
 		data->bytes_alloc += bytes_req;
 	} else {
 		data = malloc(sizeof(*data));
+		if (!data)
+			die("malloc");
 		data->ptr = ptr;
+		data->pingpong = 0;
 		data->hit = 1;
 		data->bytes_req = bytes_req;
 		data->bytes_alloc = bytes_alloc;
@@ -180,6 +181,8 @@ static void insert_alloc_stat(unsigned long ptr,
 		rb_link_node(&data->node, parent, node);
 		rb_insert_color(&data->node, &root_alloc_stat);
 	}
+	data->call_site = call_site;
+	data->alloc_cpu = cpu;
 }
 
 static void insert_caller_stat(unsigned long call_site,
@@ -189,9 +192,6 @@ static void insert_caller_stat(unsigned long call_site,
 	struct rb_node *parent = NULL;
 	struct alloc_stat *data = NULL;
 
-	if (!caller_flag)
-		return;
-
 	while (*node) {
 		parent = *node;
 		data = rb_entry(*node, struct alloc_stat, node);
@@ -210,7 +210,10 @@ static void insert_caller_stat(unsigned long call_site,
 		data->bytes_alloc += bytes_req;
 	} else {
 		data = malloc(sizeof(*data));
+		if (!data)
+			die("malloc");
 		data->call_site = call_site;
+		data->pingpong = 0;
 		data->hit = 1;
 		data->bytes_req = bytes_req;
 		data->bytes_alloc = bytes_alloc;
@@ -238,7 +241,7 @@ static void process_alloc_event(struct raw_event_sample *raw,
 	bytes_req = raw_field_value(event, "bytes_req", raw->data);
 	bytes_alloc = raw_field_value(event, "bytes_alloc", raw->data);
 
-	insert_alloc_stat(ptr, bytes_req, bytes_alloc);
+	insert_alloc_stat(call_site, ptr, bytes_req, bytes_alloc, cpu);
 	insert_caller_stat(call_site, bytes_req, bytes_alloc);
 
 	total_requested += bytes_req;
@@ -253,12 +256,58 @@ static void process_alloc_event(struct raw_event_sample *raw,
 	nr_allocs++;
 }
 
-static void process_free_event(struct raw_event_sample *raw __used,
-			       struct event *event __used,
-			       int cpu __used,
+static int ptr_cmp(struct alloc_stat *, struct alloc_stat *);
+static int callsite_cmp(struct alloc_stat *, struct alloc_stat *);
+
+static struct alloc_stat *search_alloc_stat(unsigned long ptr,
+					    unsigned long call_site,
+					    struct rb_root *root,
+					    sort_fn_t sort_fn)
+{
+	struct rb_node *node = root->rb_node;
+	struct alloc_stat key = { .ptr = ptr, .call_site = call_site };
+
+	while (node) {
+		struct alloc_stat *data;
+		int cmp;
+
+		data = rb_entry(node, struct alloc_stat, node);
+
+		cmp = sort_fn(&key, data);
+		if (cmp < 0)
+			node = node->rb_left;
+		else if (cmp > 0)
+			node = node->rb_right;
+		else
+			return data;
+	}
+	return NULL;
+}
+
+static void process_free_event(struct raw_event_sample *raw,
+			       struct event *event,
+			       int cpu,
 			       u64 timestamp __used,
 			       struct thread *thread __used)
 {
+	unsigned long ptr;
+	struct alloc_stat *s_alloc, *s_caller;
+
+	ptr = raw_field_value(event, "ptr", raw->data);
+
+	s_alloc = search_alloc_stat(ptr, 0, &root_alloc_stat, ptr_cmp);
+	if (!s_alloc)
+		return;
+
+	if (cpu != s_alloc->alloc_cpu) {
+		s_alloc->pingpong++;
+
+		s_caller = search_alloc_stat(0, s_alloc->call_site,
+					     &root_caller_stat, callsite_cmp);
+		assert(s_caller);
+		s_caller->pingpong++;
+	}
+	s_alloc->alloc_cpu = -1;
 }
 
 static void
@@ -379,10 +428,10 @@ static void __print_result(struct rb_root *root, int n_lines, int is_caller)
 {
 	struct rb_node *next;
 
-	printf("%.78s\n", graph_dotted_line);
-	printf("%-28s|",  is_caller ? "Callsite": "Alloc Ptr");
-	printf("Total_alloc/Per | Total_req/Per | Hit  | Frag\n");
-	printf("%.78s\n", graph_dotted_line);
+	printf("%.102s\n", graph_dotted_line);
+	printf(" %-34s |",  is_caller ? "Callsite": "Alloc Ptr");
+	printf(" Total_alloc/Per | Total_req/Per   | Hit   | Ping-pong | Frag\n");
+	printf("%.102s\n", graph_dotted_line);
 
 	next = rb_first(root);
 
@@ -390,7 +439,7 @@ static void __print_result(struct rb_root *root, int n_lines, int is_caller)
 		struct alloc_stat *data = rb_entry(next, struct alloc_stat,
 						   node);
 		struct symbol *sym = NULL;
-		char bf[BUFSIZ];
+		char buf[BUFSIZ];
 		u64 addr;
 
 		if (is_caller) {
@@ -402,26 +451,28 @@ static void __print_result(struct rb_root *root, int n_lines, int is_caller)
 			addr = data->ptr;
 
 		if (sym != NULL)
-			snprintf(bf, sizeof(bf), "%s+%Lx", sym->name,
+			snprintf(buf, sizeof(buf), "%s+%Lx", sym->name,
 				 addr - sym->start);
 		else
-			snprintf(bf, sizeof(bf), "%#Lx", addr);
+			snprintf(buf, sizeof(buf), "%#Lx", addr);
+		printf(" %-34s |", buf);
 
-		printf("%-28s|%8llu/%-6lu |%8llu/%-6lu|%6lu|%8.3f%%\n",
-		       bf, (unsigned long long)data->bytes_alloc,
+		printf(" %9llu/%-5lu | %9llu/%-5lu | %6lu | %8lu | %6.3f%%\n",
+		       (unsigned long long)data->bytes_alloc,
 		       (unsigned long)data->bytes_alloc / data->hit,
 		       (unsigned long long)data->bytes_req,
 		       (unsigned long)data->bytes_req / data->hit,
 		       (unsigned long)data->hit,
+		       (unsigned long)data->pingpong,
 		       fragmentation(data->bytes_req, data->bytes_alloc));
 
 		next = rb_next(next);
 	}
 
 	if (n_lines == -1)
-		printf(" ...                        | ...            | ...           | ...    | ...   \n");
+		printf(" ...                                | ...             | ...             | ...    | ...      | ...   \n");
 
-	printf("%.78s\n", graph_dotted_line);
+	printf("%.102s\n", graph_dotted_line);
 }
 
 static void print_summary(void)
@@ -597,12 +648,27 @@ static struct sort_dimension frag_sort_dimension = {
 	.cmp	= frag_cmp,
 };
 
+static int pingpong_cmp(struct alloc_stat *l, struct alloc_stat *r)
+{
+	if (l->pingpong < r->pingpong)
+		return -1;
+	else if (l->pingpong > r->pingpong)
+		return 1;
+	return 0;
+}
+
+static struct sort_dimension pingpong_sort_dimension = {
+	.name	= "pingpong",
+	.cmp	= pingpong_cmp,
+};
+
 static struct sort_dimension *avail_sorts[] = {
 	&ptr_sort_dimension,
 	&callsite_sort_dimension,
 	&hit_sort_dimension,
 	&bytes_sort_dimension,
 	&frag_sort_dimension,
+	&pingpong_sort_dimension,
 };
 
 #define NUM_AVAIL_SORTS	\
@@ -703,7 +769,7 @@ static const struct option kmem_options[] = {
 		     "stat selector, Pass 'alloc' or 'caller'.",
 		     parse_stat_opt),
 	OPT_CALLBACK('s', "sort", NULL, "key[,key2...]",
-		     "sort by key(s): ptr, call_site, bytes, hit, frag",
+		     "sort by keys: ptr, call_site, bytes, hit, pingpong, frag",
 		     parse_sort_opt),
 	OPT_CALLBACK('l', "line", NULL, "num",
 		     "show n lins",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
