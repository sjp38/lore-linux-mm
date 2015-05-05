Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 893DC6B006E
	for <linux-mm@kvack.org>; Tue,  5 May 2015 10:54:10 -0400 (EDT)
Received: by pdea3 with SMTP id a3so198766231pde.3
        for <linux-mm@kvack.org>; Tue, 05 May 2015 07:54:09 -0700 (PDT)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com. [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id qp7si12542031pac.120.2015.05.05.07.54.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 May 2015 07:54:08 -0700 (PDT)
Received: by pdbqd1 with SMTP id qd1so198656295pdb.2
        for <linux-mm@kvack.org>; Tue, 05 May 2015 07:54:08 -0700 (PDT)
From: Namhyung Kim <namhyung@kernel.org>
Subject: [PATCH v3 6/6] perf kmem: Show warning when trying to run stat without record
Date: Tue,  5 May 2015 23:52:52 +0900
Message-Id: <1430837572-31395-1-git-send-email-namhyung@kernel.org>
In-Reply-To: <5548D0BD.3080602@iki.fi>
References: <5548D0BD.3080602@iki.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Joonsoo Kim <js1304@gmail.com>, Minchan Kim <minchan@kernel.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org

Sometimes one can mistakenly run perf kmem stat without perf kmem
record before or different configuration like recoding --slab and stat
--page.  Show a warning message like below to inform user:

  # perf kmem stat --page --caller
  No page allocation events found.  Have you run 'perf kmem record --page'?

Acked-by: Pekka Enberg <penberg@kernel.org>
Signed-off-by: Namhyung Kim <namhyung@kernel.org>
---
Update the warning message.

 tools/perf/builtin-kmem.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
index 828b7284e547..e628bf1a0c24 100644
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
2.3.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
