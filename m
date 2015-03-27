Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 39FEF6B0074
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 22:15:21 -0400 (EDT)
Received: by pacwz10 with SMTP id wz10so29889094pac.2
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 19:15:21 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id es2si753740pbd.135.2015.03.26.19.15.07
        for <linux-mm@kvack.org>;
        Thu, 26 Mar 2015 19:15:08 -0700 (PDT)
From: Namhyung Kim <namhyung@kernel.org>
Subject: [PATCH 6/7] perf kmem: Print gfp flags in human readable string
Date: Fri, 27 Mar 2015 11:08:06 +0900
Message-Id: <1427422087-17239-7-git-send-email-namhyung@kernel.org>
In-Reply-To: <1427422087-17239-1-git-send-email-namhyung@kernel.org>
References: <1427422087-17239-1-git-send-email-namhyung@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org

Save libtraceevent output and print it in the header.

  # perf kmem stat --page --caller
  # GFP flags
  # ---------
  # 00000010:       NI: GFP_NOIO
  # 000000d0:        K: GFP_KERNEL
  # 00000200:      NWR: GFP_NOWARN
  # 000084d0:    K|R|Z: GFP_KERNEL|GFP_REPEAT|GFP_ZERO
  # 000200d2:       HU: GFP_HIGHUSER
  # 000200da:      HUM: GFP_HIGHUSER_MOVABLE
  # 000280da:    HUM|Z: GFP_HIGHUSER_MOVABLE|GFP_ZERO
  # 002084d0: K|R|Z|NT: GFP_KERNEL|GFP_REPEAT|GFP_ZERO|GFP_NOTRACK
  # 0102005a:  NF|HW|M: GFP_NOFS|GFP_HARDWALL|GFP_MOVABLE

  ---------------------------------------------------------------------------------------------------------
   Total alloc (KB) | Hits      | Order | Migration type | GFP flags | Callsite
  ---------------------------------------------------------------------------------------------------------
                 60 |        15 |     0 |      UNMOVABLE | K|R|Z|NT  | pte_alloc_one
                 40 |        10 |     0 |        MOVABLE | HUM|Z     | handle_mm_fault
                 24 |         6 |     0 |        MOVABLE | HUM       | do_wp_page
                 24 |         6 |     0 |      UNMOVABLE | K         | __pollwait
   ...

Requested-by: Joonsoo Kim <js1304@gmail.com>
Suggested-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: Namhyung Kim <namhyung@kernel.org>
---
 tools/perf/builtin-kmem.c | 221 +++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 208 insertions(+), 13 deletions(-)

diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
index 863d882d6a94..0046e8cebed5 100644
--- a/tools/perf/builtin-kmem.c
+++ b/tools/perf/builtin-kmem.c
@@ -545,6 +545,176 @@ static bool valid_page(u64 pfn_or_page)
 	return true;
 }
 
+struct gfp_flag {
+	unsigned int flags;
+	char *compact_str;
+	char *human_readable;
+};
+
+static struct gfp_flag *gfps;
+static int nr_gfps;
+
+static int gfpcmp(const void *a, const void *b)
+{
+	const struct gfp_flag *fa = a;
+	const struct gfp_flag *fb = b;
+
+	return fa->flags - fb->flags;
+}
+
+/* see include/trace/events/gfpflags.h */
+static const struct {
+	const char *original;
+	const char *compact;
+} gfp_compact_table[] = {
+	{ "GFP_TRANSHUGE",		"THP" },
+	{ "GFP_HIGHUSER_MOVABLE",	"HUM" },
+	{ "GFP_HIGHUSER",		"HU" },
+	{ "GFP_USER",			"U" },
+	{ "GFP_TEMPORARY",		"TMP" },
+	{ "GFP_KERNEL",			"K" },
+	{ "GFP_NOFS",			"NF" },
+	{ "GFP_ATOMIC",			"A" },
+	{ "GFP_NOIO",			"NI" },
+	{ "GFP_HIGH",			"H" },
+	{ "GFP_WAIT",			"W" },
+	{ "GFP_IO",			"I" },
+	{ "GFP_COLD",			"CO" },
+	{ "GFP_NOWARN",			"NWR" },
+	{ "GFP_REPEAT",			"R" },
+	{ "GFP_NOFAIL",			"NF" },
+	{ "GFP_NORETRY",		"NR" },
+	{ "GFP_COMP",			"C" },
+	{ "GFP_ZERO",			"Z" },
+	{ "GFP_NOMEMALLOC",		"NMA" },
+	{ "GFP_MEMALLOC",		"MA" },
+	{ "GFP_HARDWALL",		"HW" },
+	{ "GFP_THISNODE",		"TN" },
+	{ "GFP_RECLAIMABLE",		"RC" },
+	{ "GFP_MOVABLE",		"M" },
+	{ "GFP_NOTRACK",		"NT" },
+	{ "GFP_NO_KSWAPD",		"NK" },
+	{ "GFP_OTHER_NODE",		"ON" },
+	{ "GFP_NOWAIT",			"NW" },
+};
+
+static size_t max_gfp_len;
+
+static char *compact_gfp_flags(char *gfp_flags)
+{
+	char *orig_flags = strdup(gfp_flags);
+	char *new_flags = NULL;
+	char *str, *pos;
+	size_t len = 0;
+
+	if (orig_flags == NULL)
+		return NULL;
+
+	str = strtok_r(orig_flags, "|", &pos);
+	while (str) {
+		size_t i;
+		char *new;
+		const char *cpt;
+
+		for (i = 0; i < ARRAY_SIZE(gfp_compact_table); i++) {
+			if (strcmp(gfp_compact_table[i].original, str))
+				continue;
+
+			cpt = gfp_compact_table[i].compact;
+			new = realloc(new_flags, len + strlen(cpt) + 2);
+			if (new == NULL) {
+				free(new_flags);
+				return NULL;
+			}
+
+			new_flags = new;
+
+			if (!len) {
+				strcpy(new_flags, cpt);
+			} else {
+				strcat(new_flags, "|");
+				strcat(new_flags, cpt);
+				len++;
+			}
+
+			len += strlen(cpt);
+		}
+
+		str = strtok_r(NULL, "|", &pos);
+	}
+
+	if (max_gfp_len < len)
+		max_gfp_len = len;
+
+	free(orig_flags);
+	return new_flags;
+}
+
+static char *compact_gfp_string(unsigned long gfp_flags)
+{
+	struct gfp_flag key = {
+		.flags = gfp_flags,
+	};
+	struct gfp_flag *gfp;
+
+	gfp = bsearch(&key, gfps, nr_gfps, sizeof(*gfps), gfpcmp);
+	if (gfp)
+		return gfp->compact_str;
+
+	return NULL;
+}
+
+static int parse_gfp_flags(struct perf_evsel *evsel, struct perf_sample *sample,
+			   unsigned int gfp_flags)
+{
+	struct pevent_record record = {
+		.cpu = sample->cpu,
+		.data = sample->raw_data,
+		.size = sample->raw_size,
+	};
+	struct trace_seq seq;
+	char *str, *pos;
+
+	if (nr_gfps) {
+		struct gfp_flag key = {
+			.flags = gfp_flags,
+		};
+
+		if (bsearch(&key, gfps, nr_gfps, sizeof(*gfps), gfpcmp))
+			return 0;
+	}
+
+	trace_seq_init(&seq);
+	pevent_event_info(&seq, evsel->tp_format, &record);
+
+	str = strtok_r(seq.buffer, " ", &pos);
+	while (str) {
+		if (!strncmp(str, "gfp_flags=", 10)) {
+			struct gfp_flag *new;
+
+			new = realloc(gfps, (nr_gfps + 1) * sizeof(*gfps));
+			if (new == NULL)
+				return -ENOMEM;
+
+			gfps = new;
+			new += nr_gfps++;
+
+			new->flags = gfp_flags;
+			new->human_readable = strdup(str + 10);
+			new->compact_str = compact_gfp_flags(str + 10);
+			if (!new->human_readable || !new->compact_str)
+				return -ENOMEM;
+
+			qsort(gfps, nr_gfps, sizeof(*gfps), gfpcmp);
+		}
+
+		str = strtok_r(NULL, " ", &pos);
+	}
+
+	trace_seq_destroy(&seq);
+	return 0;
+}
+
 static int perf_evsel__process_page_alloc_event(struct perf_evsel *evsel,
 						struct perf_sample *sample)
 {
@@ -577,6 +747,9 @@ static int perf_evsel__process_page_alloc_event(struct perf_evsel *evsel,
 		return 0;
 	}
 
+	if (parse_gfp_flags(evsel, sample, gfp_flags) < 0)
+		return -1;
+
 	callsite = find_callsite(evsel, sample);
 
 	/*
@@ -796,16 +969,18 @@ static void __print_page_alloc_result(struct perf_session *session, int n_lines)
 	struct rb_node *next = rb_first(&page_alloc_sorted);
 	struct machine *machine = &session->machines.host;
 	const char *format;
+	int gfp_len = max(strlen("GFP flags"), max_gfp_len);
 
 	printf("\n%.105s\n", graph_dotted_line);
-	printf(" %-16s | %5s alloc (KB) | Hits      | Order | Mig.type | GFP flags | Callsite\n",
-	       use_pfn ? "PFN" : "Page", live_page ? "Live" : "Total");
+	printf(" %-16s | %5s alloc (KB) | Hits      | Order | Mig.type | %-*s | Callsite\n",
+	       use_pfn ? "PFN" : "Page", live_page ? "Live" : "Total",
+	       gfp_len, "GFP flags");
 	printf("%.105s\n", graph_dotted_line);
 
 	if (use_pfn)
-		format = " %16llu | %'16llu | %'9d | %5d | %8s |  %08lx | %s\n";
+		format = " %16llu | %'16llu | %'9d | %5d | %8s | %-*s | %s\n";
 	else
-		format = " %016llx | %'16llu | %'9d | %5d | %8s |  %08lx | %s\n";
+		format = " %016llx | %'16llu | %'9d | %5d | %8s | %-*s | %s\n";
 
 	while (next && n_lines--) {
 		struct page_stat *data;
@@ -826,13 +1001,15 @@ static void __print_page_alloc_result(struct perf_session *session, int n_lines)
 		       (unsigned long long)data->alloc_bytes / 1024,
 		       data->nr_alloc, data->order,
 		       migrate_type_str[data->migrate_type],
-		       (unsigned long)data->gfp_flags, caller);
+		       gfp_len, compact_gfp_string(data->gfp_flags), caller);
 
 		next = rb_next(next);
 	}
 
-	if (n_lines == -1)
-		printf(" ...              | ...              | ...       | ...   | ...      | ...       | ...\n");
+	if (n_lines == -1) {
+		printf(" ...              | ...              | ...       | ...   | ...      | %-*s | ...\n",
+		       gfp_len, "...");
+	}
 
 	printf("%.105s\n", graph_dotted_line);
 }
@@ -841,10 +1018,11 @@ static void __print_page_caller_result(struct perf_session *session, int n_lines
 {
 	struct rb_node *next = rb_first(&page_caller_sorted);
 	struct machine *machine = &session->machines.host;
+	int gfp_len = max(strlen("GFP flags"), max_gfp_len);
 
 	printf("\n%.105s\n", graph_dotted_line);
-	printf(" %5s alloc (KB) | Hits      | Order | Mig.type | GFP flags | Callsite\n",
-	       live_page ? "Live" : "Total");
+	printf(" %5s alloc (KB) | Hits      | Order | Mig.type | %-*s | Callsite\n",
+	       live_page ? "Live" : "Total", gfp_len, "GFP flags");
 	printf("%.105s\n", graph_dotted_line);
 
 	while (next && n_lines--) {
@@ -862,21 +1040,36 @@ static void __print_page_caller_result(struct perf_session *session, int n_lines
 		else
 			scnprintf(buf, sizeof(buf), "%"PRIx64, data->callsite);
 
-		printf(" %'16llu | %'9d | %5d | %8s |  %08lx | %s\n",
+		printf(" %'16llu | %'9d | %5d | %8s | %-*s | %s\n",
 		       (unsigned long long)data->alloc_bytes / 1024,
 		       data->nr_alloc, data->order,
 		       migrate_type_str[data->migrate_type],
-		       (unsigned long)data->gfp_flags, caller);
+		       gfp_len, compact_gfp_string(data->gfp_flags), caller);
 
 		next = rb_next(next);
 	}
 
-	if (n_lines == -1)
-		printf(" ...              | ...       | ...   | ...      | ...       | ...\n");
+	if (n_lines == -1) {
+		printf(" ...              | ...       | ...   | ...      | %-*s | ...\n",
+		       gfp_len, "...");
+	}
 
 	printf("%.105s\n", graph_dotted_line);
 }
 
+static void print_gfp_flags(void)
+{
+	int i;
+
+	printf("# GFP flags\n");
+	printf("# ---------\n");
+	for (i = 0; i < nr_gfps; i++) {
+		printf("# %08x: %*s: %s\n", gfps[i].flags,
+		       (int) max_gfp_len, gfps[i].compact_str,
+		       gfps[i].human_readable);
+	}
+}
+
 static void print_slab_summary(void)
 {
 	printf("\nSUMMARY (SLAB allocator)");
@@ -946,6 +1139,8 @@ static void print_slab_result(struct perf_session *session)
 
 static void print_page_result(struct perf_session *session)
 {
+	if (caller_flag || alloc_flag)
+		print_gfp_flags();
 	if (caller_flag)
 		__print_page_caller_result(session, caller_lines);
 	if (alloc_flag)
-- 
2.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
