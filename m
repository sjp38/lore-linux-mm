Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id D21146B005A
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 06:58:02 -0500 (EST)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 10 Jan 2012 11:43:04 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0ABvkdT5394626
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 22:57:46 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0ABvjKT024161
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 22:57:46 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Tue, 10 Jan 2012 17:19:58 +0530
Message-Id: <20120110114958.17610.41626.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com>
References: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v9 3.2 8/9] perf: rename target_module to target
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>


This is a precursor patch that modifies names that refer to
kernel/module to also refer to user space names.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 tools/perf/builtin-probe.c    |   12 ++++++------
 tools/perf/util/probe-event.c |   26 +++++++++++++-------------
 2 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/tools/perf/builtin-probe.c b/tools/perf/builtin-probe.c
index 710ae3d..93d5171 100644
--- a/tools/perf/builtin-probe.c
+++ b/tools/perf/builtin-probe.c
@@ -61,7 +61,7 @@ static struct {
 	struct perf_probe_event events[MAX_PROBES];
 	struct strlist *dellist;
 	struct line_range line_range;
-	const char *target_module;
+	const char *target;
 	int max_probe_points;
 	struct strfilter *filter;
 } params;
@@ -249,7 +249,7 @@ static const struct option options[] = {
 		   "file", "vmlinux pathname"),
 	OPT_STRING('s', "source", &symbol_conf.source_prefix,
 		   "directory", "path to kernel source"),
-	OPT_STRING('m', "module", &params.target_module,
+	OPT_STRING('m', "module", &params.target,
 		   "modname|path",
 		   "target module name (for online) or path (for offline)"),
 #endif
@@ -336,7 +336,7 @@ int cmd_probe(int argc, const char **argv, const char *prefix __used)
 		if (!params.filter)
 			params.filter = strfilter__new(DEFAULT_FUNC_FILTER,
 						       NULL);
-		ret = show_available_funcs(params.target_module,
+		ret = show_available_funcs(params.target,
 					   params.filter);
 		strfilter__delete(params.filter);
 		if (ret < 0)
@@ -357,7 +357,7 @@ int cmd_probe(int argc, const char **argv, const char *prefix __used)
 			usage_with_options(probe_usage, options);
 		}
 
-		ret = show_line_range(&params.line_range, params.target_module);
+		ret = show_line_range(&params.line_range, params.target);
 		if (ret < 0)
 			pr_err("  Error: Failed to show lines. (%d)\n", ret);
 		return ret;
@@ -374,7 +374,7 @@ int cmd_probe(int argc, const char **argv, const char *prefix __used)
 
 		ret = show_available_vars(params.events, params.nevents,
 					  params.max_probe_points,
-					  params.target_module,
+					  params.target,
 					  params.filter,
 					  params.show_ext_vars);
 		strfilter__delete(params.filter);
@@ -396,7 +396,7 @@ int cmd_probe(int argc, const char **argv, const char *prefix __used)
 	if (params.nevents) {
 		ret = add_perf_probe_events(params.events, params.nevents,
 					    params.max_probe_points,
-					    params.target_module,
+					    params.target,
 					    params.force_add);
 		if (ret < 0) {
 			pr_err("  Error: Failed to add events. (%d)\n", ret);
diff --git a/tools/perf/util/probe-event.c b/tools/perf/util/probe-event.c
index eb25900..d54eefb 100644
--- a/tools/perf/util/probe-event.c
+++ b/tools/perf/util/probe-event.c
@@ -275,10 +275,10 @@ static int add_module_to_probe_trace_events(struct probe_trace_event *tevs,
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
@@ -297,9 +297,9 @@ static int try_to_find_probe_trace_events(struct perf_probe_event *pev,
 
 	if (ntevs > 0) {	/* Succeeded to find trace events */
 		pr_debug("find %d probe_trace_events.\n", ntevs);
-		if (module)
+		if (target)
 			ret = add_module_to_probe_trace_events(*tevs, ntevs,
-							       module);
+							       target);
 		return ret < 0 ? ret : ntevs;
 	}
 
@@ -1798,14 +1798,14 @@ static int __add_probe_trace_events(struct perf_probe_event *pev,
 
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
 
@@ -1821,8 +1821,8 @@ static int convert_to_probe_trace_events(struct perf_probe_event *pev,
 		goto error;
 	}
 
-	if (module) {
-		tev->point.module = strdup(module);
+	if (target) {
+		tev->point.module = strdup(target);
 		if (tev->point.module == NULL) {
 			ret = -ENOMEM;
 			goto error;
@@ -1886,7 +1886,7 @@ struct __event_package {
 };
 
 int add_perf_probe_events(struct perf_probe_event *pevs, int npevs,
-			  int max_tevs, const char *module, bool force_add)
+			  int max_tevs, const char *target, bool force_add)
 {
 	int i, j, ret;
 	struct __event_package *pkgs;
@@ -1909,7 +1909,7 @@ int add_perf_probe_events(struct perf_probe_event *pevs, int npevs,
 		ret  = convert_to_probe_trace_events(pkgs[i].pev,
 						     &pkgs[i].tevs,
 						     max_tevs,
-						     module);
+						     target);
 		if (ret < 0)
 			goto end;
 		pkgs[i].ntevs = ret;
@@ -2065,7 +2065,7 @@ static int filter_available_functions(struct map *map __unused,
 	return 1;
 }
 
-int show_available_funcs(const char *module, struct strfilter *_filter)
+int show_available_funcs(const char *target, struct strfilter *_filter)
 {
 	struct map *map;
 	int ret;
@@ -2076,9 +2076,9 @@ int show_available_funcs(const char *module, struct strfilter *_filter)
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
