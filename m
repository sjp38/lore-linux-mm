Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id D06D16B006E
	for <linux-mm@kvack.org>; Tue,  5 May 2015 17:32:38 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so209206613pdb.1
        for <linux-mm@kvack.org>; Tue, 05 May 2015 14:32:38 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id dt10si26216377pdb.120.2015.05.05.14.32.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 May 2015 14:32:36 -0700 (PDT)
From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH 14/25] perf kmem: Show warning when trying to run stat without record
Date: Tue,  5 May 2015 18:32:08 -0300
Message-Id: <1430861539-30518-15-git-send-email-acme@kernel.org>
In-Reply-To: <1430861539-30518-1-git-send-email-acme@kernel.org>
References: <1430861539-30518-1-git-send-email-acme@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, David Ahern <dsahern@gmail.com>, Jiri Olsa <jolsa@redhat.com>, Joonsoo Kim <js1304@gmail.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Arnaldo Carvalho de Melo <acme@redhat.com>

From: Namhyung Kim <namhyung@kernel.org>

Sometimes one can mistakenly run 'perf kmem stat' without running 'perf
kmem record' before or with a different configuration like recording
--slab and stat --page.  Show a warning message like the one below to
inform the user:

  # perf kmem stat --page --caller
  No page allocation events found.  Have you run 'perf kmem record --page'?

Signed-off-by: Namhyung Kim <namhyung@kernel.org>
Acked-by: Pekka Enberg <penberg@kernel.org>
Cc: David Ahern <dsahern@gmail.com>
Cc: Jiri Olsa <jolsa@redhat.com>
Cc: Joonsoo Kim <js1304@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/1430837572-31395-1-git-send-email-namhyung@kernel.org
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 tools/perf/builtin-kmem.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
index 828b728..e628bf1 100644
--- a/tools/perf/builtin-kmem.c
+++ b/tools/perf/builtin-kmem.c
@@ -1882,6 +1882,7 @@ int cmd_kmem(int argc, const char **argv, const char *prefix __maybe_unused)
 	};
 	struct perf_session *session;
 	int ret = -1;
+	const char errmsg[] = "No %s allocation events found.  Have you run 'perf kmem record --%s'?\n";
 
 	perf_config(kmem_config, NULL);
 	argc = parse_options_subcommand(argc, argv, kmem_options,
@@ -1908,11 +1909,21 @@ int cmd_kmem(int argc, const char **argv, const char *prefix __maybe_unused)
 	if (session == NULL)
 		return -1;
 
+	if (kmem_slab) {
+		if (!perf_evlist__find_tracepoint_by_name(session->evlist,
+							  "kmem:kmalloc")) {
+			pr_err(errmsg, "slab", "slab");
+			return -1;
+		}
+	}
+
 	if (kmem_page) {
-		struct perf_evsel *evsel = perf_evlist__first(session->evlist);
+		struct perf_evsel *evsel;
 
-		if (evsel == NULL || evsel->tp_format == NULL) {
-			pr_err("invalid event found.. aborting\n");
+		evsel = perf_evlist__find_tracepoint_by_name(session->evlist,
+							     "kmem:mm_page_alloc");
+		if (evsel == NULL) {
+			pr_err(errmsg, "page", "page");
 			return -1;
 		}
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
