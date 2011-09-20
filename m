Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 97A719000C9
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 08:18:39 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp05.in.ibm.com (8.14.4/8.13.1) with ESMTP id p8KCIUra013904
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 17:48:30 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8KCIUTn4423744
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 17:48:30 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8KCIS3K032050
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 22:18:30 +1000
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Tue, 20 Sep 2011 17:34:57 +0530
Message-Id: <20110920120457.25326.79727.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v5 3.1.0-rc4-tip 24/26]   perf: show possible probes in a given executable file or library.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>


Enhances -F/--funcs option of "perf probe" to list possible probe points in
an executable file or library.

Show last 10 functions in /bin/zsh.

# perf probe -F -x /bin/zsh | tail
zstrtol
ztrcmp
ztrdup
ztrduppfx
ztrftime
ztrlen
ztrncpy
ztrsub
zwarn
zwarnnam

Show first 10 functions in /lib/libc.so.6

# perf probe -F -x /lib/libc.so.6 | head
_IO_adjust_column
_IO_adjust_wcolumn
_IO_default_doallocate
_IO_default_finish
_IO_default_pbackfail
_IO_default_uflow
_IO_default_xsgetn
_IO_default_xsputn
_IO_do_write@@GLIBC_2.2.5
_IO_doallocbuf

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 tools/perf/builtin-probe.c    |    4 +--
 tools/perf/util/probe-event.c |   56 +++++++++++++++++++++++++++++++----------
 tools/perf/util/probe-event.h |    4 +--
 3 files changed, 47 insertions(+), 17 deletions(-)

diff --git a/tools/perf/builtin-probe.c b/tools/perf/builtin-probe.c
index 43e6321..5e7622c 100644
--- a/tools/perf/builtin-probe.c
+++ b/tools/perf/builtin-probe.c
@@ -365,8 +365,8 @@ int cmd_probe(int argc, const char **argv, const char *prefix __used)
 		if (!params.filter)
 			params.filter = strfilter__new(DEFAULT_FUNC_FILTER,
 						       NULL);
-		ret = show_available_funcs(params.target,
-					   params.filter);
+		ret = show_available_funcs(params.target, params.filter,
+					params.uprobes);
 		strfilter__delete(params.filter);
 		if (ret < 0)
 			pr_err("  Error: Failed to show functions."
diff --git a/tools/perf/util/probe-event.c b/tools/perf/util/probe-event.c
index a501486..659fecb 100644
--- a/tools/perf/util/probe-event.c
+++ b/tools/perf/util/probe-event.c
@@ -47,6 +47,7 @@
 #include "trace-event.h"	/* For __unused */
 #include "probe-event.h"
 #include "probe-finder.h"
+#include "session.h"
 
 #define MAX_CMDLEN 256
 #define MAX_PROBE_ARGS 128
@@ -2161,6 +2162,7 @@ int del_perf_probe_events(struct strlist *dellist)
 	}
 	return ret;
 }
+
 /* TODO: don't use a global variable for filter ... */
 static struct strfilter *available_func_filter;
 
@@ -2177,32 +2179,60 @@ static int filter_available_functions(struct map *map __unused,
 	return 1;
 }
 
-int show_available_funcs(const char *target, struct strfilter *_filter)
+static int __show_available_funcs(struct map *map)
+{
+	if (map__load(map, filter_available_functions)) {
+		pr_err("Failed to load map.\n");
+		return -EINVAL;
+	}
+	if (!dso__sorted_by_name(map->dso, map->type))
+		dso__sort_by_name(map->dso, map->type);
+
+	dso__fprintf_symbols_by_name(map->dso, map->type, stdout);
+	return 0;
+}
+
+static int available_kernel_funcs(const char *module)
 {
 	struct map *map;
 	int ret;
 
-	setup_pager();
-
 	ret = init_vmlinux();
 	if (ret < 0)
 		return ret;
 
-	map = kernel_get_module_map(target);
+	map = kernel_get_module_map(module);
 	if (!map) {
-		pr_err("Failed to find %s map.\n", (target) ? : "kernel");
+		pr_err("Failed to find %s map.\n", (module) ? : "kernel");
 		return -EINVAL;
 	}
+	return __show_available_funcs(map);
+}
+
+int show_available_funcs(const char *target, struct strfilter *_filter,
+					bool user)
+{
+	struct map *map;
+	int ret;
+
+	setup_pager();
 	available_func_filter = _filter;
-	if (map__load(map, filter_available_functions)) {
-		pr_err("Failed to load map.\n");
-		return -EINVAL;
-	}
-	if (!dso__sorted_by_name(map->dso, map->type))
-		dso__sort_by_name(map->dso, map->type);
 
-	dso__fprintf_symbols_by_name(map->dso, map->type, stdout);
-	return 0;
+	if (!user)
+		return available_kernel_funcs(target);
+
+	symbol_conf.try_vmlinux_path = false;
+	symbol_conf.sort_by_name = true;
+	ret = symbol__init();
+	if (ret < 0) {
+		pr_err("Failed to init symbol map.\n");
+		return ret;
+	}
+	map = dso__new_map(target);
+	ret = __show_available_funcs(map);
+	dso__delete(map->dso);
+	map__delete(map);
+	return ret;
 }
 
 #define DEFAULT_FUNC_FILTER "!_*"
diff --git a/tools/perf/util/probe-event.h b/tools/perf/util/probe-event.h
index 9e8c846..f9f3de8 100644
--- a/tools/perf/util/probe-event.h
+++ b/tools/perf/util/probe-event.h
@@ -131,8 +131,8 @@ extern int show_line_range(struct line_range *lr, const char *module);
 extern int show_available_vars(struct perf_probe_event *pevs, int npevs,
 			       int max_probe_points, const char *module,
 			       struct strfilter *filter, bool externs);
-extern int show_available_funcs(const char *module, struct strfilter *filter);
-
+extern int show_available_funcs(const char *module, struct strfilter *filter,
+				bool user);
 
 /* Maximum index number of event-name postfix */
 #define MAX_EVENT_INDEX	1024

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
