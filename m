Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id BFCCE6B13F1
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 17:11:06 -0500 (EST)
From: Arnaldo Carvalho de Melo <acme@infradead.org>
Subject: [PATCH 3/8] perf probe: Rename target_module to target
Date: Mon,  6 Feb 2012 20:10:18 -0200
Message-Id: <1328566223-27218-4-git-send-email-acme@infradead.org>
In-Reply-To: <1328566223-27218-1-git-send-email-acme@infradead.org>
References: <1328566223-27218-1-git-send-email-acme@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-kernel@vger.kernel.org, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Anton Arapov <anton@redhat.com>, Christoph Hellwig <hch@infradead.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Linux-mm <linux-mm@kvack.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Roland McGrath <roland@hack.frob.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Arnaldo Carvalho de Melo <acme@redhat.com>

From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

This is a precursor patch that modifies names that refer to
kernel/module to also refer to user space names.

Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Anton Arapov <anton@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Jim Keniston <jkenisto@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux-mm <linux-mm@kvack.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Roland McGrath <roland@hack.frob.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Link: http://lkml.kernel.org/r/20120202142040.5967.64156.sendpatchset@srdronam.in.ibm.com
Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 tools/perf/builtin-probe.c    |   12 ++++++------
 tools/perf/util/probe-event.c |   26 +++++++++++++-------------
 2 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/tools/perf/builtin-probe.c b/tools/perf/builtin-probe.c
index fb85661..4935c09 100644
--- a/tools/perf/builtin-probe.c
+++ b/tools/perf/builtin-probe.c
@@ -58,7 +58,7 @@ static struct {
 	struct perf_probe_event events[MAX_PROBES];
 	struct strlist *dellist;
 	struct line_range line_range;
-	const char *target_module;
+	const char *target;
 	int max_probe_points;
 	struct strfilter *filter;
 } params;
@@ -246,7 +246,7 @@ static const struct option options[] = {
 		   "file", "vmlinux pathname"),
 	OPT_STRING('s', "source", &symbol_conf.source_prefix,
 		   "directory", "path to kernel source"),
-	OPT_STRING('m', "module", &params.target_module,
+	OPT_STRING('m', "module", &params.target,
 		   "modname|path",
 		   "target module name (for online) or path (for offline)"),
 #endif
@@ -333,7 +333,7 @@ int cmd_probe(int argc, const char **argv, const char *prefix __used)
 		if (!params.filter)
 			params.filter = strfilter__new(DEFAULT_FUNC_FILTER,
 						       NULL);
-		ret = show_available_funcs(params.target_module,
+		ret = show_available_funcs(params.target,
 					   params.filter);
 		strfilter__delete(params.filter);
 		if (ret < 0)
@@ -354,7 +354,7 @@ int cmd_probe(int argc, const char **argv, const char *prefix __used)
 			usage_with_options(probe_usage, options);
 		}
 
-		ret = show_line_range(&params.line_range, params.target_module);
+		ret = show_line_range(&params.line_range, params.target);
 		if (ret < 0)
 			pr_err("  Error: Failed to show lines. (%d)\n", ret);
 		return ret;
@@ -371,7 +371,7 @@ int cmd_probe(int argc, const char **argv, const char *prefix __used)
 
 		ret = show_available_vars(params.events, params.nevents,
 					  params.max_probe_points,
-					  params.target_module,
+					  params.target,
 					  params.filter,
 					  params.show_ext_vars);
 		strfilter__delete(params.filter);
@@ -393,7 +393,7 @@ int cmd_probe(int argc, const char **argv, const char *prefix __used)
 	if (params.nevents) {
 		ret = add_perf_probe_events(params.events, params.nevents,
 					    params.max_probe_points,
-					    params.target_module,
+					    params.target,
 					    params.force_add);
 		if (ret < 0) {
 			pr_err("  Error: Failed to add events. (%d)\n", ret);
diff --git a/tools/perf/util/probe-event.c b/tools/perf/util/probe-event.c
index b9bbdd2..c1a513e 100644
--- a/tools/perf/util/probe-event.c
+++ b/tools/perf/util/probe-event.c
@@ -273,10 +273,10 @@ static int add_module_to_probe_trace_events(struct probe_trace_event *tevs,
 /* Try to find perf_probe_event with debuginfo */
 static int try_to_find_probe_trace_events(struct perf_probe_event *pev,
 					  struct probe_trace_event **tevs,
-					  int max_tevs, const char *module)
+					  int max_tevs, const char *target)
 {
 	bool need_dwarf = perf_probe_event_need_dwarf(pev);
-	struct debuginfo *dinfo = open_debuginfo(module);
+	struct debuginfo *dinfo = open_debuginfo(target);
 	int ntevs, ret = 0;
 
 	if (!dinfo) {
@@ -295,9 +295,9 @@ static int try_to_find_probe_trace_events(struct perf_probe_event *pev,
 
 	if (ntevs > 0) {	/* Succeeded to find trace events */
 		pr_debug("find %d probe_trace_events.\n", ntevs);
-		if (module)
+		if (target)
 			ret = add_module_to_probe_trace_events(*tevs, ntevs,
-							       module);
+							       target);
 		return ret < 0 ? ret : ntevs;
 	}
 
@@ -1796,14 +1796,14 @@ static int __add_probe_trace_events(struct perf_probe_event *pev,
 
 static int convert_to_probe_trace_events(struct perf_probe_event *pev,
 					  struct probe_trace_event **tevs,
-					  int max_tevs, const char *module)
+					  int max_tevs, const char *target)
 {
 	struct symbol *sym;
 	int ret = 0, i;
 	struct probe_trace_event *tev;
 
 	/* Convert perf_probe_event with debuginfo */
-	ret = try_to_find_probe_trace_events(pev, tevs, max_tevs, module);
+	ret = try_to_find_probe_trace_events(pev, tevs, max_tevs, target);
 	if (ret != 0)
 		return ret;	/* Found in debuginfo or got an error */
 
@@ -1819,8 +1819,8 @@ static int convert_to_probe_trace_events(struct perf_probe_event *pev,
 		goto error;
 	}
 
-	if (module) {
-		tev->point.module = strdup(module);
+	if (target) {
+		tev->point.module = strdup(target);
 		if (tev->point.module == NULL) {
 			ret = -ENOMEM;
 			goto error;
@@ -1884,7 +1884,7 @@ struct __event_package {
 };
 
 int add_perf_probe_events(struct perf_probe_event *pevs, int npevs,
-			  int max_tevs, const char *module, bool force_add)
+			  int max_tevs, const char *target, bool force_add)
 {
 	int i, j, ret;
 	struct __event_package *pkgs;
@@ -1907,7 +1907,7 @@ int add_perf_probe_events(struct perf_probe_event *pevs, int npevs,
 		ret  = convert_to_probe_trace_events(pkgs[i].pev,
 						     &pkgs[i].tevs,
 						     max_tevs,
-						     module);
+						     target);
 		if (ret < 0)
 			goto end;
 		pkgs[i].ntevs = ret;
@@ -2063,7 +2063,7 @@ static int filter_available_functions(struct map *map __unused,
 	return 1;
 }
 
-int show_available_funcs(const char *module, struct strfilter *_filter)
+int show_available_funcs(const char *target, struct strfilter *_filter)
 {
 	struct map *map;
 	int ret;
@@ -2074,9 +2074,9 @@ int show_available_funcs(const char *module, struct strfilter *_filter)
 	if (ret < 0)
 		return ret;
 
-	map = kernel_get_module_map(module);
+	map = kernel_get_module_map(target);
 	if (!map) {
-		pr_err("Failed to find %s map.\n", (module) ? : "kernel");
+		pr_err("Failed to find %s map.\n", (target) ? : "kernel");
 		return -EINVAL;
 	}
 	available_func_filter = _filter;
-- 
1.7.9.123.g65da0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
