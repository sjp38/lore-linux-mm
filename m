Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D64336B00A3
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 06:37:27 -0500 (EST)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 18 Nov 2011 11:35:34 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAIBY46j3379418
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 22:34:04 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAIBbGZ2001684
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 22:37:16 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 18 Nov 2011 16:41:09 +0530
Message-Id: <20111118111109.10512.31812.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v7 3.2-rc2 23/30] perf: perf interface for uprobes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>


Enhances perf probe to user space executables and libraries.
Provides very basic support for uprobes.

[ Probing a function in the executable using function name  ]
-------------------------------------------------------------
[root@localhost ~]# perf probe -x /bin/zsh zfree
Add new event:
  probe_zsh:zfree      (on /bin/zsh:0x45400)

You can now use it on all perf tools, such as:

	perf record -e probe_zsh:zfree -aR sleep 1

[root@localhost ~]# perf record -e probe_zsh:zfree -aR sleep 15
[ perf record: Woken up 1 times to write data ]
[ perf record: Captured and wrote 0.314 MB perf.data (~13715 samples) ]
[root@localhost ~]# perf report --stdio
# Events: 3K probe_zsh:zfree
#
# Overhead  Command  Shared Object  Symbol
# ........  .......  .............  ......
#
   100.00%              zsh  zsh            [.] zfree


#
# (For a higher level overview, try: perf report --sort comm,dso)
#
[root@localhost ~]

[ Probing a library function using function name ]
--------------------------------------------------
[root@localhost]#
[root@localhost]# perf probe -x /lib64/libc.so.6 malloc
Add new event:
  probe_libc:malloc    (on /lib64/libc-2.5.so:0x74dc0)

You can now use it on all perf tools, such as:

	perf record -e probe_libc:malloc -aR sleep 1

[root@localhost]#
[root@localhost]# perf probe --list
  probe_libc:malloc    (on /lib64/libc-2.5.so:0x0000000000074dc0)

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---

(Changelog (since v5)
- Removed the separate documentation change patch and added the
  documentation changes as part of this patch.

 tools/perf/Documentation/perf-probe.txt |   12 +
 tools/perf/builtin-probe.c              |   37 +++
 tools/perf/util/probe-event.c           |  348 +++++++++++++++++++++++++------
 tools/perf/util/probe-event.h           |    8 -
 tools/perf/util/symbol.c                |    8 +
 tools/perf/util/symbol.h                |    1 
 6 files changed, 336 insertions(+), 78 deletions(-)

diff --git a/tools/perf/Documentation/perf-probe.txt b/tools/perf/Documentation/perf-probe.txt
index 2780d9c..469ad6d 100644
--- a/tools/perf/Documentation/perf-probe.txt
+++ b/tools/perf/Documentation/perf-probe.txt
@@ -98,6 +98,11 @@ OPTIONS
 --max-probes::
 	Set the maximum number of probe points for an event. Default is 128.
 
+-x::
+--exec=PATH::
+	Specify path to the executable or shared library file for user
+	space tracing.
+
 PROBE SYNTAX
 ------------
 Probe points are defined by following syntax.
@@ -182,6 +187,13 @@ Delete all probes on schedule().
 
  ./perf probe --del='schedule*'
 
+Add probes at zfree() function on /bin/zsh
+
+ ./perf probe -x /bin/zsh zfree
+
+Add probes at malloc() function on libc
+
+ ./perf probe -x /lib/libc.so.6 malloc
 
 SEE ALSO
 --------
diff --git a/tools/perf/builtin-probe.c b/tools/perf/builtin-probe.c
index 93d5171..43e6321 100644
--- a/tools/perf/builtin-probe.c
+++ b/tools/perf/builtin-probe.c
@@ -57,6 +57,7 @@ static struct {
 	bool show_ext_vars;
 	bool show_funcs;
 	bool mod_events;
+	bool uprobes;
 	int nevents;
 	struct perf_probe_event events[MAX_PROBES];
 	struct strlist *dellist;
@@ -78,6 +79,7 @@ static int parse_probe_event(const char *str)
 		return -1;
 	}
 
+	pev->uprobes = params.uprobes;
 	/* Parse a perf-probe command into event */
 	ret = parse_perf_probe_command(str, pev);
 	pr_debug("%d arguments\n", pev->nargs);
@@ -128,6 +130,27 @@ static int opt_del_probe_event(const struct option *opt __used,
 	return 0;
 }
 
+static int opt_set_target(const struct option *opt, const char *str,
+			int unset __used)
+{
+	int ret = -ENOENT;
+
+	if  (str && !params.target) {
+		if (!strcmp(opt->long_name, "exec"))
+			params.uprobes = true;
+#ifdef DWARF_SUPPORT
+		else if (!strcmp(opt->long_name, "module"))
+			params.uprobes = false;
+#endif
+		else
+			return ret;
+
+		params.target = str;
+		ret = 0;
+	}
+	return ret;
+}
+
 #ifdef DWARF_SUPPORT
 static int opt_show_lines(const struct option *opt __used,
 			  const char *str, int unset __used)
@@ -249,9 +272,9 @@ static const struct option options[] = {
 		   "file", "vmlinux pathname"),
 	OPT_STRING('s', "source", &symbol_conf.source_prefix,
 		   "directory", "path to kernel source"),
-	OPT_STRING('m', "module", &params.target,
-		   "modname|path",
-		   "target module name (for online) or path (for offline)"),
+	OPT_CALLBACK('m', "module", NULL, "modname|path",
+		"target module name (for online) or path (for offline)",
+		opt_set_target),
 #endif
 	OPT__DRY_RUN(&probe_event_dry_run),
 	OPT_INTEGER('\0', "max-probes", &params.max_probe_points,
@@ -263,6 +286,8 @@ static const struct option options[] = {
 		     "\t\t\t(default: \"" DEFAULT_VAR_FILTER "\" for --vars,\n"
 		     "\t\t\t \"" DEFAULT_FUNC_FILTER "\" for --funcs)",
 		     opt_set_filter),
+	OPT_CALLBACK('x', "exec", NULL, "executable|path",
+			"target executable name or path", opt_set_target),
 	OPT_END()
 };
 
@@ -313,6 +338,10 @@ int cmd_probe(int argc, const char **argv, const char *prefix __used)
 			pr_err("  Error: Don't use --list with --funcs.\n");
 			usage_with_options(probe_usage, options);
 		}
+		if (params.uprobes) {
+			pr_warning("  Error: Don't use --list with --exec.\n");
+			usage_with_options(probe_usage, options);
+		}
 		ret = show_perf_probe_events();
 		if (ret < 0)
 			pr_err("  Error: Failed to show event list. (%d)\n",
@@ -346,7 +375,7 @@ int cmd_probe(int argc, const char **argv, const char *prefix __used)
 	}
 
 #ifdef DWARF_SUPPORT
-	if (params.show_lines) {
+	if (params.show_lines && !params.uprobes) {
 		if (params.mod_events) {
 			pr_err("  Error: Don't use --line with"
 			       " --add/--del.\n");
diff --git a/tools/perf/util/probe-event.c b/tools/perf/util/probe-event.c
index d54eefb..d4f4c2b 100644
--- a/tools/perf/util/probe-event.c
+++ b/tools/perf/util/probe-event.c
@@ -73,6 +73,8 @@ static int e_snprintf(char *str, size_t size, const char *format, ...)
 }
 
 static char *synthesize_perf_probe_point(struct perf_probe_point *pp);
+static int convert_name_to_addr(struct perf_probe_event *pev,
+				const char *exec);
 static struct machine machine;
 
 /* Initialize symbol maps and path of vmlinux/modules */
@@ -173,6 +175,31 @@ const char *kernel_get_module_path(const char *module)
 	return (dso) ? dso->long_name : NULL;
 }
 
+static int init_perf_uprobes(void)
+{
+	int ret = 0;
+
+	symbol_conf.try_vmlinux_path = false;
+	symbol_conf.sort_by_name = true;
+	ret = symbol__init();
+	if (ret < 0)
+		pr_debug("Failed to init symbol map.\n");
+
+	return ret;
+}
+
+static int convert_to_perf_probe_point(struct probe_trace_point *tp,
+					struct perf_probe_point *pp)
+{
+	pp->function = strdup(tp->symbol);
+	if (pp->function == NULL)
+		return -ENOMEM;
+	pp->offset = tp->offset;
+	pp->retprobe = tp->retprobe;
+
+	return 0;
+}
+
 #ifdef DWARF_SUPPORT
 /* Open new debuginfo of given module */
 static struct debuginfo *open_debuginfo(const char *module)
@@ -281,6 +308,15 @@ static int try_to_find_probe_trace_events(struct perf_probe_event *pev,
 	struct debuginfo *dinfo = open_debuginfo(target);
 	int ntevs, ret = 0;
 
+	if (pev->uprobes) {
+		if (need_dwarf) {
+			pr_warning("Debuginfo-analysis is not yet supported"
+					" with -x/--exec option.\n");
+			return -ENOSYS;
+		}
+		return convert_name_to_addr(pev, target);
+	}
+
 	if (!dinfo) {
 		if (need_dwarf) {
 			pr_warning("Failed to open debuginfo file.\n");
@@ -606,23 +642,20 @@ static int kprobe_convert_to_perf_probe(struct probe_trace_point *tp,
 		pr_err("Failed to find symbol %s in kernel.\n", tp->symbol);
 		return -ENOENT;
 	}
-	pp->function = strdup(tp->symbol);
-	if (pp->function == NULL)
-		return -ENOMEM;
-	pp->offset = tp->offset;
-	pp->retprobe = tp->retprobe;
-
-	return 0;
+	return convert_to_perf_probe_point(tp, pp);
 }
 
 static int try_to_find_probe_trace_events(struct perf_probe_event *pev,
 				struct probe_trace_event **tevs __unused,
-				int max_tevs __unused, const char *mod __unused)
+				int max_tevs __unused, const char *target)
 {
 	if (perf_probe_event_need_dwarf(pev)) {
 		pr_warning("Debuginfo-analysis is not supported.\n");
 		return -ENOSYS;
 	}
+	if (pev->uprobes)
+		return convert_name_to_addr(pev, target);
+
 	return 0;
 }
 
@@ -887,6 +920,11 @@ static int parse_perf_probe_point(char *arg, struct perf_probe_event *pev)
 		return -EINVAL;
 	}
 
+	if (pev->uprobes && !pp->function) {
+		semantic_error("No function specified for uprobes");
+		return -EINVAL;
+	}
+
 	if ((pp->offset || pp->line || pp->lazy_line) && pp->retprobe) {
 		semantic_error("Offset/Line/Lazy pattern can't be used with "
 			       "return probe.\n");
@@ -896,6 +934,11 @@ static int parse_perf_probe_point(char *arg, struct perf_probe_event *pev)
 	pr_debug("symbol:%s file:%s line:%d offset:%lu return:%d lazy:%s\n",
 		 pp->function, pp->file, pp->line, pp->offset, pp->retprobe,
 		 pp->lazy_line);
+
+	if (pev->uprobes && perf_probe_event_need_dwarf(pev)) {
+		semantic_error("no dwarf based probes for uprobes.");
+		return -EINVAL;
+	}
 	return 0;
 }
 
@@ -1047,7 +1090,8 @@ bool perf_probe_event_need_dwarf(struct perf_probe_event *pev)
 {
 	int i;
 
-	if (pev->point.file || pev->point.line || pev->point.lazy_line)
+	if ((pev->point.file && !pev->uprobes) || pev->point.line ||
+					pev->point.lazy_line)
 		return true;
 
 	for (i = 0; i < pev->nargs; i++)
@@ -1344,11 +1388,17 @@ char *synthesize_probe_trace_command(struct probe_trace_event *tev)
 	if (buf == NULL)
 		return NULL;
 
-	len = e_snprintf(buf, MAX_CMDLEN, "%c:%s/%s %s%s%s+%lu",
-			 tp->retprobe ? 'r' : 'p',
-			 tev->group, tev->event,
-			 tp->module ?: "", tp->module ? ":" : "",
-			 tp->symbol, tp->offset);
+	if (tev->uprobes)
+		len = e_snprintf(buf, MAX_CMDLEN, "%c:%s/%s %s",
+				 tp->retprobe ? 'r' : 'p',
+				 tev->group, tev->event, tp->symbol);
+	else
+		len = e_snprintf(buf, MAX_CMDLEN, "%c:%s/%s %s%s%s+%lu",
+				 tp->retprobe ? 'r' : 'p',
+				 tev->group, tev->event,
+				 tp->module ?: "", tp->module ? ":" : "",
+				 tp->symbol, tp->offset);
+
 	if (len <= 0)
 		goto error;
 
@@ -1367,7 +1417,7 @@ char *synthesize_probe_trace_command(struct probe_trace_event *tev)
 }
 
 static int convert_to_perf_probe_event(struct probe_trace_event *tev,
-				       struct perf_probe_event *pev)
+			       struct perf_probe_event *pev, bool is_kprobe)
 {
 	char buf[64] = "";
 	int i, ret;
@@ -1379,7 +1429,11 @@ static int convert_to_perf_probe_event(struct probe_trace_event *tev,
 		return -ENOMEM;
 
 	/* Convert trace_point to probe_point */
-	ret = kprobe_convert_to_perf_probe(&tev->point, &pev->point);
+	if (is_kprobe)
+		ret = kprobe_convert_to_perf_probe(&tev->point, &pev->point);
+	else
+		ret = convert_to_perf_probe_point(&tev->point, &pev->point);
+
 	if (ret < 0)
 		return ret;
 
@@ -1475,7 +1529,7 @@ static void clear_probe_trace_event(struct probe_trace_event *tev)
 	memset(tev, 0, sizeof(*tev));
 }
 
-static int open_kprobe_events(bool readwrite)
+static int open_probe_events(bool readwrite, bool is_kprobe)
 {
 	char buf[PATH_MAX];
 	const char *__debugfs;
@@ -1486,8 +1540,13 @@ static int open_kprobe_events(bool readwrite)
 		pr_warning("Debugfs is not mounted.\n");
 		return -ENOENT;
 	}
+	if (is_kprobe)
+		ret = e_snprintf(buf, PATH_MAX, "%stracing/kprobe_events",
+							__debugfs);
+	else
+		ret = e_snprintf(buf, PATH_MAX, "%stracing/uprobe_events",
+							__debugfs);
 
-	ret = e_snprintf(buf, PATH_MAX, "%stracing/kprobe_events", __debugfs);
 	if (ret >= 0) {
 		pr_debug("Opening %s write=%d\n", buf, readwrite);
 		if (readwrite && !probe_event_dry_run)
@@ -1498,16 +1557,29 @@ static int open_kprobe_events(bool readwrite)
 
 	if (ret < 0) {
 		if (errno == ENOENT)
-			pr_warning("kprobe_events file does not exist - please"
-				 " rebuild kernel with CONFIG_KPROBE_EVENT.\n");
+			pr_warning("%s file does not exist - please"
+				" rebuild kernel with CONFIG_%s_EVENT.\n",
+				is_kprobe ? "kprobe_events" : "uprobe_events",
+				is_kprobe ? "KPROBE" : "UPROBE");
 		else
-			pr_warning("Failed to open kprobe_events file: %s\n",
-				   strerror(errno));
+			pr_warning("Failed to open %s file: %s\n",
+				is_kprobe ? "kprobe_events" : "uprobe_events",
+				strerror(errno));
 	}
 	return ret;
 }
 
-/* Get raw string list of current kprobe_events */
+static int open_kprobe_events(bool readwrite)
+{
+	return open_probe_events(readwrite, 1);
+}
+
+static int open_uprobe_events(bool readwrite)
+{
+	return open_probe_events(readwrite, 0);
+}
+
+/* Get raw string list of current kprobe_events  or uprobe_events */
 static struct strlist *get_probe_trace_command_rawlist(int fd)
 {
 	int ret, idx;
@@ -1572,36 +1644,26 @@ static int show_perf_probe_event(struct perf_probe_event *pev)
 	return ret;
 }
 
-/* List up current perf-probe events */
-int show_perf_probe_events(void)
+static int __show_perf_probe_events(int fd, bool is_kprobe)
 {
-	int fd, ret;
+	int ret = 0;
 	struct probe_trace_event tev;
 	struct perf_probe_event pev;
 	struct strlist *rawlist;
 	struct str_node *ent;
 
-	setup_pager();
-	ret = init_vmlinux();
-	if (ret < 0)
-		return ret;
-
 	memset(&tev, 0, sizeof(tev));
 	memset(&pev, 0, sizeof(pev));
 
-	fd = open_kprobe_events(false);
-	if (fd < 0)
-		return fd;
-
 	rawlist = get_probe_trace_command_rawlist(fd);
-	close(fd);
 	if (!rawlist)
 		return -ENOENT;
 
 	strlist__for_each(ent, rawlist) {
 		ret = parse_probe_trace_command(ent->s, &tev);
 		if (ret >= 0) {
-			ret = convert_to_perf_probe_event(&tev, &pev);
+			ret = convert_to_perf_probe_event(&tev, &pev,
+								is_kprobe);
 			if (ret >= 0)
 				ret = show_perf_probe_event(&pev);
 		}
@@ -1611,6 +1673,31 @@ int show_perf_probe_events(void)
 			break;
 	}
 	strlist__delete(rawlist);
+	return ret;
+}
+
+/* List up current perf-probe events */
+int show_perf_probe_events(void)
+{
+	int fd, ret;
+
+	setup_pager();
+	fd = open_kprobe_events(false);
+	if (fd < 0)
+		return fd;
+
+	ret = init_vmlinux();
+	if (ret < 0)
+		return ret;
+
+	ret = __show_perf_probe_events(fd, true);
+	close(fd);
+
+	fd = open_uprobe_events(false);
+	if (fd >= 0) {
+		ret = __show_perf_probe_events(fd, false);
+		close(fd);
+	}
 
 	return ret;
 }
@@ -1720,7 +1807,10 @@ static int __add_probe_trace_events(struct perf_probe_event *pev,
 	const char *event, *group;
 	struct strlist *namelist;
 
-	fd = open_kprobe_events(true);
+	if (pev->uprobes)
+		fd = open_uprobe_events(true);
+	else
+		fd = open_kprobe_events(true);
 	if (fd < 0)
 		return fd;
 	/* Get current event names */
@@ -1832,6 +1922,7 @@ static int convert_to_probe_trace_events(struct perf_probe_event *pev,
 	tev->point.offset = pev->point.offset;
 	tev->point.retprobe = pev->point.retprobe;
 	tev->nargs = pev->nargs;
+	tev->uprobes = pev->uprobes;
 	if (tev->nargs) {
 		tev->args = zalloc(sizeof(struct probe_trace_arg)
 				   * tev->nargs);
@@ -1862,6 +1953,9 @@ static int convert_to_probe_trace_events(struct perf_probe_event *pev,
 		}
 	}
 
+	if (pev->uprobes)
+		return 1;
+
 	/* Currently just checking function name from symbol map */
 	sym = __find_kernel_function_by_name(tev->point.symbol, NULL);
 	if (!sym) {
@@ -1888,15 +1982,19 @@ struct __event_package {
 int add_perf_probe_events(struct perf_probe_event *pevs, int npevs,
 			  int max_tevs, const char *target, bool force_add)
 {
-	int i, j, ret;
+	int i, j, ret = 0;
 	struct __event_package *pkgs;
 
 	pkgs = zalloc(sizeof(struct __event_package) * npevs);
 	if (pkgs == NULL)
 		return -ENOMEM;
 
-	/* Init vmlinux path */
-	ret = init_vmlinux();
+	if (!pevs->uprobes)
+		/* Init vmlinux path */
+		ret = init_vmlinux();
+	else
+		ret = init_perf_uprobes();
+
 	if (ret < 0) {
 		free(pkgs);
 		return ret;
@@ -1968,23 +2066,15 @@ static int __del_trace_probe_event(int fd, struct str_node *ent)
 	return ret;
 }
 
-static int del_trace_probe_event(int fd, const char *group,
-				  const char *event, struct strlist *namelist)
+static int del_trace_probe_event(int fd, const char *buf,
+						  struct strlist *namelist)
 {
-	char buf[128];
 	struct str_node *ent, *n;
-	int found = 0, ret = 0;
-
-	ret = e_snprintf(buf, 128, "%s:%s", group, event);
-	if (ret < 0) {
-		pr_err("Failed to copy event.\n");
-		return ret;
-	}
+	int ret = -1;
 
 	if (strpbrk(buf, "*?")) { /* Glob-exp */
 		strlist__for_each_safe(ent, n, namelist)
 			if (strglobmatch(ent->s, buf)) {
-				found++;
 				ret = __del_trace_probe_event(fd, ent);
 				if (ret < 0)
 					break;
@@ -1993,40 +2083,41 @@ static int del_trace_probe_event(int fd, const char *group,
 	} else {
 		ent = strlist__find(namelist, buf);
 		if (ent) {
-			found++;
 			ret = __del_trace_probe_event(fd, ent);
 			if (ret >= 0)
 				strlist__remove(namelist, ent);
 		}
 	}
-	if (found == 0 && ret >= 0)
-		pr_info("Info: Event \"%s\" does not exist.\n", buf);
-
 	return ret;
 }
 
 int del_perf_probe_events(struct strlist *dellist)
 {
-	int fd, ret = 0;
+	int ret = -1, ufd = -1, kfd = -1;
+	char buf[128];
 	const char *group, *event;
 	char *p, *str;
 	struct str_node *ent;
-	struct strlist *namelist;
-
-	fd = open_kprobe_events(true);
-	if (fd < 0)
-		return fd;
+	struct strlist *namelist = NULL, *unamelist = NULL;
 
 	/* Get current event names */
-	namelist = get_probe_trace_event_names(fd, true);
-	if (namelist == NULL)
-		return -EINVAL;
+	kfd = open_kprobe_events(true);
+	if (kfd < 0)
+		return kfd;
+	namelist = get_probe_trace_event_names(kfd, true);
+
+	ufd = open_uprobe_events(true);
+	if (ufd >= 0)
+		unamelist = get_probe_trace_event_names(ufd, true);
+
+	if (namelist == NULL && unamelist == NULL)
+		goto error;
 
 	strlist__for_each(ent, dellist) {
 		str = strdup(ent->s);
 		if (str == NULL) {
 			ret = -ENOMEM;
-			break;
+			goto error;
 		}
 		pr_debug("Parsing: %s\n", str);
 		p = strchr(str, ':');
@@ -2038,17 +2129,40 @@ int del_perf_probe_events(struct strlist *dellist)
 			group = "*";
 			event = str;
 		}
+
+		ret = e_snprintf(buf, 128, "%s:%s", group, event);
+		if (ret < 0) {
+			pr_err("Failed to copy event.");
+			free(str);
+			goto error;
+		}
+
 		pr_debug("Group: %s, Event: %s\n", group, event);
-		ret = del_trace_probe_event(fd, group, event, namelist);
+		if (namelist)
+			ret = del_trace_probe_event(kfd, buf, namelist);
+		if (unamelist && ret != 0)
+			ret = del_trace_probe_event(ufd, buf, unamelist);
+
 		free(str);
-		if (ret < 0)
-			break;
+		if (ret != 0)
+			pr_info("Info: Event \"%s\" does not exist.\n", buf);
 	}
-	strlist__delete(namelist);
-	close(fd);
 
+error:
+	if (kfd >= 0) {
+		if (namelist)
+			strlist__delete(namelist);
+		close(kfd);
+	}
+
+	if (ufd >= 0) {
+		if (unamelist)
+			strlist__delete(unamelist);
+		close(ufd);
+	}
 	return ret;
 }
+
 /* TODO: don't use a global variable for filter ... */
 static struct strfilter *available_func_filter;
 
@@ -2092,3 +2206,95 @@ int show_available_funcs(const char *target, struct strfilter *_filter)
 	dso__fprintf_symbols_by_name(map->dso, map->type, stdout);
 	return 0;
 }
+
+#define DEFAULT_FUNC_FILTER "!_*"
+
+/*
+ * uprobe_events only accepts address:
+ * Convert function and any offset to address
+ */
+static int convert_name_to_addr(struct perf_probe_event *pev, const char *exec)
+{
+	struct perf_probe_point *pp = &pev->point;
+	struct symbol *sym;
+	struct map *map = NULL;
+	char *function = NULL, *name = NULL;
+	int ret = -EINVAL;
+	unsigned long long vaddr = 0;
+
+	if (!pp->function)
+		goto out;
+
+	function = strdup(pp->function);
+	if (!function) {
+		pr_warning("Failed to allocate memory by strdup.\n");
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	name = realpath(exec, NULL);
+	if (!name) {
+		pr_warning("Cannot find realpath for %s.\n", exec);
+		goto out;
+	}
+	map = dso__new_map(name);
+	if (!map) {
+		pr_warning("Cannot find appropriate DSO for %s.\n", name);
+		goto out;
+	}
+	available_func_filter = strfilter__new(DEFAULT_FUNC_FILTER, NULL);
+	if (map__load(map, filter_available_functions)) {
+		pr_err("Failed to load map.\n");
+		return -EINVAL;
+	}
+
+	sym = map__find_symbol_by_name(map, function, NULL);
+	if (!sym) {
+		pr_warning("Cannot find %s in DSO %s\n", function, name);
+		goto out;
+	}
+
+	if (map->start > sym->start)
+		vaddr = map->start;
+	vaddr += sym->start + pp->offset + map->pgoff;
+	pp->offset = 0;
+
+	if (!pev->event) {
+		pev->event = function;
+		function = NULL;
+	}
+	if (!pev->group) {
+		char *ptr1, *ptr2;
+
+		pev->group = zalloc(sizeof(char *) * 64);
+		ptr1 = strdup(basename(exec));
+		if (ptr1) {
+			ptr2 = strpbrk(ptr1, "-._");
+			if (ptr2)
+				*ptr2 = '\0';
+			e_snprintf(pev->group, 64, "%s_%s", PERFPROBE_GROUP,
+					ptr1);
+			free(ptr1);
+		}
+	}
+	free(pp->function);
+	pp->function = zalloc(sizeof(char *) * MAX_PROBE_ARGS);
+	if (!pp->function) {
+		ret = -ENOMEM;
+		pr_warning("Failed to allocate memory by zalloc.\n");
+		goto out;
+	}
+	e_snprintf(pp->function, MAX_PROBE_ARGS, "%s:0x%llx", name, vaddr);
+	ret = 0;
+
+out:
+	if (map) {
+		dso__delete(map->dso);
+		map__delete(map);
+	}
+	if (function)
+		free(function);
+	if (name)
+		free(name);
+	return ret;
+}
diff --git a/tools/perf/util/probe-event.h b/tools/perf/util/probe-event.h
index a7dee83..9e8c846 100644
--- a/tools/perf/util/probe-event.h
+++ b/tools/perf/util/probe-event.h
@@ -7,7 +7,7 @@
 
 extern bool probe_event_dry_run;
 
-/* kprobe-tracer tracing point */
+/* kprobe-tracer and uprobe-tracer tracing point */
 struct probe_trace_point {
 	char		*symbol;	/* Base symbol */
 	char		*module;	/* Module name */
@@ -21,7 +21,7 @@ struct probe_trace_arg_ref {
 	long				offset;	/* Offset value */
 };
 
-/* kprobe-tracer tracing argument */
+/* kprobe-tracer and uprobe-tracer tracing argument */
 struct probe_trace_arg {
 	char				*name;	/* Argument name */
 	char				*value;	/* Base value */
@@ -29,12 +29,13 @@ struct probe_trace_arg {
 	struct probe_trace_arg_ref	*ref;	/* Referencing offset */
 };
 
-/* kprobe-tracer tracing event (point + arg) */
+/* kprobe-tracer and uprobe-tracer tracing event (point + arg) */
 struct probe_trace_event {
 	char				*event;	/* Event name */
 	char				*group;	/* Group name */
 	struct probe_trace_point	point;	/* Trace point */
 	int				nargs;	/* Number of args */
+	bool				uprobes;	/* uprobes only */
 	struct probe_trace_arg		*args;	/* Arguments */
 };
 
@@ -70,6 +71,7 @@ struct perf_probe_event {
 	char			*group;	/* Group name */
 	struct perf_probe_point	point;	/* Probe point */
 	int			nargs;	/* Number of arguments */
+	bool			uprobes;
 	struct perf_probe_arg	*args;	/* Arguments */
 };
 
diff --git a/tools/perf/util/symbol.c b/tools/perf/util/symbol.c
index 632b50c..e81c4fd 100644
--- a/tools/perf/util/symbol.c
+++ b/tools/perf/util/symbol.c
@@ -2767,3 +2767,11 @@ int machine__load_vmlinux_path(struct machine *machine, enum map_type type,
 
 	return ret;
 }
+
+struct map *dso__new_map(const char *name)
+{
+	struct dso *dso = dso__new(name);
+	struct map *map = map__new2(0, dso, MAP__FUNCTION);
+
+	return map;
+}
diff --git a/tools/perf/util/symbol.h b/tools/perf/util/symbol.h
index 29f8d74..6d28bbd 100644
--- a/tools/perf/util/symbol.h
+++ b/tools/perf/util/symbol.h
@@ -217,6 +217,7 @@ void dso__set_long_name(struct dso *dso, char *name);
 void dso__set_build_id(struct dso *dso, void *build_id);
 void dso__read_running_kernel_build_id(struct dso *dso,
 				       struct machine *machine);
+struct map *dso__new_map(const char *name);
 struct symbol *dso__find_symbol(struct dso *dso, enum map_type type,
 				u64 addr);
 struct symbol *dso__find_symbol_by_name(struct dso *dso, enum map_type type,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
