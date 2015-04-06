Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 3A4036B0078
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 01:37:50 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so34326415pdb.0
        for <linux-mm@kvack.org>; Sun, 05 Apr 2015 22:37:50 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id z3si5056866pas.11.2015.04.05.22.37.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Apr 2015 22:37:49 -0700 (PDT)
Received: by pacyx8 with SMTP id yx8so33931797pac.1
        for <linux-mm@kvack.org>; Sun, 05 Apr 2015 22:37:49 -0700 (PDT)
From: Namhyung Kim <namhyung@kernel.org>
Subject: [PATCH 8/9] perf kmem: Add kmem.default config option
Date: Mon,  6 Apr 2015 14:36:15 +0900
Message-Id: <1428298576-9785-9-git-send-email-namhyung@kernel.org>
In-Reply-To: <1428298576-9785-1-git-send-email-namhyung@kernel.org>
References: <1428298576-9785-1-git-send-email-namhyung@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, Taeung Song <treeze.taeung@gmail.com>

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

Cc: Taeung Song <treeze.taeung@gmail.com>
Signed-off-by: Namhyung Kim <namhyung@kernel.org>
---
 tools/perf/builtin-kmem.c | 32 +++++++++++++++++++++++++++++---
 1 file changed, 29 insertions(+), 3 deletions(-)

diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
index bf0f8bf56375..d2dfcabdf684 100644
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
@@ -1673,7 +1677,8 @@ static int parse_sort_opt(const struct option *opt __maybe_unused,
 	if (!arg)
 		return -1;
 
-	if (kmem_page > kmem_slab) {
+	if (kmem_page > kmem_slab ||
+	    (kmem_page == 0 && kmem_slab == 0 && kmem_default == KMEM_PAGE)) {
 		if (caller_flag > alloc_flag)
 			return setup_page_sorting(&page_caller_sort, arg);
 		else
@@ -1789,6 +1794,22 @@ static int __cmd_record(int argc, const char **argv)
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
 	struct perf_data_file file = {
@@ -1825,14 +1846,19 @@ int cmd_kmem(int argc, const char **argv, const char *prefix __maybe_unused)
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
2.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
