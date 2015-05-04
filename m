Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0474B6B0071
	for <linux-mm@kvack.org>; Mon,  4 May 2015 17:36:54 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so171907928pab.2
        for <linux-mm@kvack.org>; Mon, 04 May 2015 14:36:53 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id ep1si21377708pbb.85.2015.05.04.14.36.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 May 2015 14:36:46 -0700 (PDT)
From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH 21/21] perf kmem: Add kmem.default config option
Date: Mon,  4 May 2015 18:36:30 -0300
Message-Id: <1430775390-22523-22-git-send-email-acme@kernel.org>
In-Reply-To: <1430775390-22523-1-git-send-email-acme@kernel.org>
References: <1430775390-22523-1-git-send-email-acme@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, David Ahern <dsahern@gmail.com>, Jiri Olsa <jolsa@redhat.com>, Joonsoo Kim <js1304@gmail.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Taeung Song <treeze.taeung@gmail.com>, linux-mm@kvack.org, Arnaldo Carvalho de Melo <acme@redhat.com>

From: Namhyung Kim <namhyung@kernel.org>

Currently perf kmem command will select --slab if neither --slab nor
--page is given for backward compatibility.  Add kmem.default config
option to select the default value ('page' or 'slab').

  # cat ~/.perfconfig
  [kmem]
  	default = page

  # perf kmem stat

  SUMMARY (page allocator)
  ========================
  Total allocation requests     :            1,518   [            6,096 KB ]
  Total free requests           :            1,431   [            5,748 KB ]

  Total alloc+freed requests    :            1,330   [            5,344 KB ]
  Total alloc-only requests     :              188   [              752 KB ]
  Total free-only requests      :              101   [              404 KB ]

  Total allocation failures     :                0   [                0 KB ]
  ...

Signed-off-by: Namhyung Kim <namhyung@kernel.org>
Acked-by: Pekka Enberg <penberg@kernel.org>
Cc: David Ahern <dsahern@gmail.com>
Cc: Jiri Olsa <jolsa@redhat.com>
Cc: Joonsoo Kim <js1304@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Taeung Song <treeze.taeung@gmail.com>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/1429592107-1807-6-git-send-email-namhyung@kernel.org
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 tools/perf/builtin-kmem.c | 32 +++++++++++++++++++++++++++++---
 1 file changed, 29 insertions(+), 3 deletions(-)

diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
index 1c66895..828b728 100644
--- a/tools/perf/builtin-kmem.c
+++ b/tools/perf/builtin-kmem.c
@@ -28,6 +28,10 @@ static int	kmem_slab;
 static int	kmem_page;
 
 static long	kmem_page_size;
+static enum {
+	KMEM_SLAB,
+	KMEM_PAGE,
+} kmem_default = KMEM_SLAB;  /* for backward compatibility */
 
 struct alloc_stat;
 typedef int (*sort_fn_t)(void *, void *);
@@ -1710,7 +1714,8 @@ static int parse_sort_opt(const struct option *opt __maybe_unused,
 	if (!arg)
 		return -1;
 
-	if (kmem_page > kmem_slab) {
+	if (kmem_page > kmem_slab ||
+	    (kmem_page == 0 && kmem_slab == 0 && kmem_default == KMEM_PAGE)) {
 		if (caller_flag > alloc_flag)
 			return setup_page_sorting(&page_caller_sort, arg);
 		else
@@ -1826,6 +1831,22 @@ static int __cmd_record(int argc, const char **argv)
 	return cmd_record(i, rec_argv, NULL);
 }
 
+static int kmem_config(const char *var, const char *value, void *cb)
+{
+	if (!strcmp(var, "kmem.default")) {
+		if (!strcmp(value, "slab"))
+			kmem_default = KMEM_SLAB;
+		else if (!strcmp(value, "page"))
+			kmem_default = KMEM_PAGE;
+		else
+			pr_err("invalid default value ('slab' or 'page' required): %s\n",
+			       value);
+		return 0;
+	}
+
+	return perf_default_config(var, value, cb);
+}
+
 int cmd_kmem(int argc, const char **argv, const char *prefix __maybe_unused)
 {
 	const char * const default_slab_sort = "frag,hit,bytes";
@@ -1862,14 +1883,19 @@ int cmd_kmem(int argc, const char **argv, const char *prefix __maybe_unused)
 	struct perf_session *session;
 	int ret = -1;
 
+	perf_config(kmem_config, NULL);
 	argc = parse_options_subcommand(argc, argv, kmem_options,
 					kmem_subcommands, kmem_usage, 0);
 
 	if (!argc)
 		usage_with_options(kmem_usage, kmem_options);
 
-	if (kmem_slab == 0 && kmem_page == 0)
-		kmem_slab = 1;  /* for backward compatibility */
+	if (kmem_slab == 0 && kmem_page == 0) {
+		if (kmem_default == KMEM_SLAB)
+			kmem_slab = 1;
+		else
+			kmem_page = 1;
+	}
 
 	if (!strncmp(argv[0], "rec", 3)) {
 		symbol__init(NULL);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
