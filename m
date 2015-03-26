Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id C1A21900015
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 02:07:22 -0400 (EDT)
Received: by pacwe9 with SMTP id we9so53186857pac.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 23:07:22 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id oz10si6912431pdb.15.2015.03.25.23.07.12
        for <linux-mm@kvack.org>;
        Wed, 25 Mar 2015 23:07:13 -0700 (PDT)
From: Namhyung Kim <namhyung@kernel.org>
Subject: [PATCH 6/6] perf kmem: Print gfp flags in human readable string
Date: Thu, 26 Mar 2015 15:00:36 +0900
Message-Id: <1427349636-9796-7-git-send-email-namhyung@kernel.org>
In-Reply-To: <1427349636-9796-1-git-send-email-namhyung@kernel.org>
References: <1427349636-9796-1-git-send-email-namhyung@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org

Save libtraceevent output and print it in the header.

  # perf kmem stat --page --caller
  # GFP flags
  # ---------
  # 00000010: GFP_NOIO
  # 000000d0: GFP_KERNEL
  # 00000200: GFP_NOWARN
  # 000084d0: GFP_KERNEL|GFP_REPEAT|GFP_ZERO
  # 000200d2: GFP_HIGHUSER
  # 000200da: GFP_HIGHUSER_MOVABLE
  # 000280da: GFP_HIGHUSER_MOVABLE|GFP_ZERO
  # 002084d0: GFP_KERNEL|GFP_REPEAT|GFP_ZERO|GFP_NOTRACK
  # 0102005a: GFP_NOFS|GFP_HARDWALL|GFP_MOVABLE

  ---------------------------------------------------------------------------------------------------------
   Total alloc (KB) | Hits      | Order | Migration type | GFP flags | Callsite
  ---------------------------------------------------------------------------------------------------------
                 60 |        15 |     0 |      UNMOVABLE |  002084d0 | pte_alloc_one
                 40 |        10 |     0 |        MOVABLE |  000280da | handle_mm_fault
                 24 |         6 |     0 |        MOVABLE |  000200da | do_wp_page
                 24 |         6 |     0 |      UNMOVABLE |  000000d0 | __pollwait
   ...

Requested-by: Joonsoo Kim <js1304@gmail.com>
Suggested-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: Namhyung Kim <namhyung@kernel.org>
---
 tools/perf/builtin-kmem.c | 81 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 81 insertions(+)

diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
index c09e332f7f38..502f6944a04c 100644
--- a/tools/perf/builtin-kmem.c
+++ b/tools/perf/builtin-kmem.c
@@ -545,6 +545,72 @@ static bool valid_page(u64 pfn_or_page)
 	return true;
 }
 
+struct gfp_flag {
+	unsigned int flags;
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
+static int parse_gfp_flags(struct perf_evsel *evsel, struct perf_sample *sample,
+			   unsigned int gfp_flags)
+{
+	struct pevent_record record = {
+		.cpu = sample->cpu,
+		.data = sample->raw_data,
+		.size = sample->raw_size,
+	};
+	struct trace_seq seq;
+	char *str;
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
+	str = strtok(seq.buffer, " ");
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
+			if (new->human_readable == NULL)
+				return -ENOMEM;
+
+			qsort(gfps, nr_gfps, sizeof(*gfps), gfpcmp);
+		}
+
+		str = strtok(NULL, " ");
+	}
+
+	trace_seq_destroy(&seq);
+	return 0;
+}
+
 static int perf_evsel__process_page_alloc_event(struct perf_evsel *evsel,
 						struct perf_sample *sample)
 {
@@ -577,6 +643,9 @@ static int perf_evsel__process_page_alloc_event(struct perf_evsel *evsel,
 		return 0;
 	}
 
+	if (parse_gfp_flags(evsel, sample, gfp_flags) < 0)
+		return -1;
+
 	callsite = find_callsite(evsel, sample);
 
 	/*
@@ -877,6 +946,16 @@ static void __print_page_caller_result(struct perf_session *session, int n_lines
 	printf("%.105s\n", graph_dotted_line);
 }
 
+static void print_gfp_flags(void)
+{
+	int i;
+
+	printf("# GFP flags\n");
+	printf("# ---------\n");
+	for (i = 0; i < nr_gfps; i++)
+		printf("# %08x: %s\n", gfps[i].flags, gfps[i].human_readable);
+}
+
 static void print_slab_summary(void)
 {
 	printf("\nSUMMARY (SLAB allocator)");
@@ -946,6 +1025,8 @@ static void print_slab_result(struct perf_session *session)
 
 static void print_page_result(struct perf_session *session)
 {
+	if (caller_flag || alloc_flag)
+		print_gfp_flags();
 	if (caller_flag)
 		__print_page_caller_result(session, caller_lines);
 	if (alloc_flag)
-- 
2.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
