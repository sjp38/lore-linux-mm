Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8D11B8D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 10:46:49 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp06.in.ibm.com (8.14.4/8.13.1) with ESMTP id p31EkY7r013977
	for <linux-mm@kvack.org>; Fri, 1 Apr 2011 20:16:34 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p31EkYpB4247764
	for <linux-mm@kvack.org>; Fri, 1 Apr 2011 20:16:34 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p31EkXWi000599
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:46:34 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 01 Apr 2011 20:06:57 +0530
Message-Id: <20110401143657.15455.4701.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v3 2.6.39-rc1-tip 22/26] 22: perf: rename target_module to target
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>


This is a precursor patch that modifies names that refer to kernel/module
to also refer to user space names.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 tools/perf/builtin-probe.c    |   12 ++++++------
 tools/perf/util/probe-event.c |    6 +++---
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/tools/perf/builtin-probe.c b/tools/perf/builtin-probe.c
index 2c0e64d..98db08f 100644
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
@@ -241,7 +241,7 @@ static const struct option options[] = {
 		   "file", "vmlinux pathname"),
 	OPT_STRING('s', "source", &symbol_conf.source_prefix,
 		   "directory", "path to kernel source"),
-	OPT_STRING('m', "module", &params.target_module,
+	OPT_STRING('m', "module", &params.target,
 		   "modname", "target module name"),
 #endif
 	OPT__DRY_RUN(&probe_event_dry_run),
@@ -327,7 +327,7 @@ int cmd_probe(int argc, const char **argv, const char *prefix __used)
 		if (!params.filter)
 			params.filter = strfilter__new(DEFAULT_FUNC_FILTER,
 						       NULL);
-		ret = show_available_funcs(params.target_module,
+		ret = show_available_funcs(params.target,
 					   params.filter);
 		strfilter__delete(params.filter);
 		if (ret < 0)
@@ -348,7 +348,7 @@ int cmd_probe(int argc, const char **argv, const char *prefix __used)
 			usage_with_options(probe_usage, options);
 		}
 
-		ret = show_line_range(&params.line_range, params.target_module);
+		ret = show_line_range(&params.line_range, params.target);
 		if (ret < 0)
 			pr_err("  Error: Failed to show lines. (%d)\n", ret);
 		return ret;
@@ -365,7 +365,7 @@ int cmd_probe(int argc, const char **argv, const char *prefix __used)
 
 		ret = show_available_vars(params.events, params.nevents,
 					  params.max_probe_points,
-					  params.target_module,
+					  params.target,
 					  params.filter,
 					  params.show_ext_vars);
 		strfilter__delete(params.filter);
@@ -387,7 +387,7 @@ int cmd_probe(int argc, const char **argv, const char *prefix __used)
 	if (params.nevents) {
 		ret = add_perf_probe_events(params.events, params.nevents,
 					    params.max_probe_points,
-					    params.target_module,
+					    params.target,
 					    params.force_add);
 		if (ret < 0) {
 			pr_err("  Error: Failed to add events. (%d)\n", ret);
diff --git a/tools/perf/util/probe-event.c b/tools/perf/util/probe-event.c
index 5ddee66..09c53c1 100644
--- a/tools/perf/util/probe-event.c
+++ b/tools/perf/util/probe-event.c
@@ -1979,7 +1979,7 @@ static int filter_available_functions(struct map *map __unused,
 	return 1;
 }
 
-int show_available_funcs(const char *module, struct strfilter *_filter)
+int show_available_funcs(const char *elfobject, struct strfilter *_filter)
 {
 	struct map *map;
 	int ret;
@@ -1990,9 +1990,9 @@ int show_available_funcs(const char *module, struct strfilter *_filter)
 	if (ret < 0)
 		return ret;
 
-	map = kernel_get_module_map(module);
+	map = kernel_get_module_map(elfobject);
 	if (!map) {
-		pr_err("Failed to find %s map.\n", (module) ? : "kernel");
+		pr_err("Failed to find %s map.\n", (elfobject) ? : "kernel");
 		return -EINVAL;
 	}
 	available_func_filter = _filter;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
