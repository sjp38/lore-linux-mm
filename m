Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D72F1900001
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 09:09:11 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp09.au.ibm.com (8.14.4/8.13.1) with ESMTP id p57D97jX005985
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 23:09:07 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p57D8HPx708652
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 23:08:17 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p57D96WV026424
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 23:09:07 +1000
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Tue, 07 Jun 2011 18:32:16 +0530
Message-Id: <20110607130216.28590.5724.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v4 3.0-rc2-tip 20/22] 20: perf: perf interface for uprobes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>


Enhances perf probe to user space executables and libraries.
Provides very basic support for uprobes.

[ Probing a function in the executable using function name  ]
-------------------------------------------------------------
[root@localhost ~]# perf probe -u zfree@/bin/zsh
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
[root@localhost]# perf probe -u malloc@/lib64/libc.so.6
Add new event:
  probe_libc:malloc    (on /lib64/libc-2.5.so:0x74dc0)

You can now use it on all perf tools, such as:

	perf record -e probe_libc:malloc -aR sleep 1

[root@localhost]#
[root@localhost]# perf probe --list
  probe_libc:malloc    (on /lib64/libc-2.5.so:0x0000000000074dc0)

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 tools/perf/builtin-probe.c    |   10 +
 tools/perf/util/probe-event.c |  387 +++++++++++++++++++++++++++++++++--------
 tools/perf/util/probe-event.h |    8 +
 tools/perf/util/symbol.c      |   10 +
 tools/perf/util/symbol.h      |    1 
 5 files changed, 334 insertions(+), 82 deletions(-)

diff --git a/tools/perf/builtin-probe.c b/tools/perf/builtin-probe.c
index 98db08f..a90ee01 100644
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
@@ -249,6 +251,8 @@ static const struct option options[] = {
 		 "Set how many probe points can be found for a probe."),
 	OPT_BOOLEAN('F', "funcs", &params.show_funcs,
 		    "Show potential probe-able functions."),
+	OPT_BOOLEAN('u', "uprobes", &params.uprobes,
+		    "user space probe events"),
 	OPT_CALLBACK('\0', "filter", NULL,
 		     "[!]FILTER", "Set a filter (with --vars/funcs only)\n"
 		     "\t\t\t(default: \"" DEFAULT_VAR_FILTER "\" for --vars,\n"
@@ -304,6 +308,10 @@ int cmd_probe(int argc, const char **argv, const char *prefix __used)
 			pr_err("  Error: Don't use --list with --funcs.\n");
 			usage_with_options(probe_usage, options);
 		}
+		if (params.uprobes) {
+			pr_warning("  Error: Don't use --list with --uprobes.\n");
+			usage_with_options(probe_usage, options);
+		}
 		ret = show_perf_probe_events();
 		if (ret < 0)
 			pr_err("  Error: Failed to show event list. (%d)\n",
@@ -337,7 +345,7 @@ int cmd_probe(int argc, const char **argv, const char *prefix __used)
 	}
 
 #ifdef DWARF_SUPPORT
-	if (params.show_lines) {
+	if (params.show_lines && !params.uprobes) {
 		if (params.mod_events) {
 			pr_err("  Error: Don't use --line with"
 			       " --add/--del.\n");
diff --git a/tools/perf/util/probe-event.c b/tools/perf/util/probe-event.c
index 153e860..30f9e2f 100644
--- a/tools/perf/util/probe-event.c
+++ b/tools/perf/util/probe-event.c
@@ -73,6 +73,7 @@ static int e_snprintf(char *str, size_t size, const char *format, ...)
 }
 
 static char *synthesize_perf_probe_point(struct perf_probe_point *pp);
+static int convert_name_to_addr(struct perf_probe_event *pev);
 static struct machine machine;
 
 /* Initialize symbol maps and path of vmlinux/modules */
@@ -169,6 +170,31 @@ const char *kernel_get_module_path(const char *module)
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
 static int open_vmlinux(const char *module)
 {
@@ -222,6 +248,15 @@ static int try_to_find_probe_trace_events(struct perf_probe_event *pev,
 	bool need_dwarf = perf_probe_event_need_dwarf(pev);
 	int fd, ntevs;
 
+	if (pev->uprobes) {
+		if (need_dwarf) {
+			pr_warning("Debuginfo-analysis is not yet supported"
+					" with -u/--uprobes option.\n");
+			return -ENOSYS;
+		}
+		return convert_name_to_addr(pev);
+	}
+
 	fd = open_vmlinux(module);
 	if (fd < 0) {
 		if (need_dwarf) {
@@ -537,13 +572,7 @@ static int kprobe_convert_to_perf_probe(struct probe_trace_point *tp,
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
@@ -554,6 +583,9 @@ static int try_to_find_probe_trace_events(struct perf_probe_event *pev,
 		pr_warning("Debuginfo-analysis is not supported.\n");
 		return -ENOSYS;
 	}
+	if (pev->uprobes)
+		return convert_name_to_addr(pev);
+
 	return 0;
 }
 
@@ -684,6 +716,7 @@ static int parse_perf_probe_point(char *arg, struct perf_probe_event *pev)
 	struct perf_probe_point *pp = &pev->point;
 	char *ptr, *tmp;
 	char c, nc = 0;
+	bool found = false;
 	/*
 	 * <Syntax>
 	 * perf probe [EVENT=]SRC[:LN|;PTN]
@@ -722,8 +755,11 @@ static int parse_perf_probe_point(char *arg, struct perf_probe_event *pev)
 	if (tmp == NULL)
 		return -ENOMEM;
 
-	/* Check arg is function or file and copy it */
-	if (strchr(tmp, '.'))	/* File */
+	/*
+	 * Check arg is function or file and copy it.
+	 * If its uprobes then expect the function to be of type a@b.c
+	 */
+	if (!pev->uprobes && strchr(tmp, '.'))	/* File */
 		pp->file = tmp;
 	else			/* Function */
 		pp->function = tmp;
@@ -761,6 +797,17 @@ static int parse_perf_probe_point(char *arg, struct perf_probe_event *pev)
 			}
 			break;
 		case '@':	/* File name */
+			if (pev->uprobes && !found) {
+				/* uprobes overloads @ operator */
+				tmp = zalloc(sizeof(char *) * MAX_PROBE_ARGS);
+				e_snprintf(tmp, MAX_PROBE_ARGS, "%s@%s",
+						pp->function, arg);
+				free(pp->function);
+				pp->function = tmp;
+				found = true;
+				break;
+			}
+
 			if (pp->file) {
 				semantic_error("SRC@SRC is not allowed.\n");
 				return -EINVAL;
@@ -818,6 +865,11 @@ static int parse_perf_probe_point(char *arg, struct perf_probe_event *pev)
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
@@ -827,6 +879,11 @@ static int parse_perf_probe_point(char *arg, struct perf_probe_event *pev)
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
 
@@ -978,7 +1035,8 @@ bool perf_probe_event_need_dwarf(struct perf_probe_event *pev)
 {
 	int i;
 
-	if (pev->point.file || pev->point.line || pev->point.lazy_line)
+	if ((pev->point.file && !pev->uprobes) || pev->point.line ||
+					pev->point.lazy_line)
 		return true;
 
 	for (i = 0; i < pev->nargs; i++)
@@ -1269,10 +1327,21 @@ char *synthesize_probe_trace_command(struct probe_trace_event *tev)
 	if (buf == NULL)
 		return NULL;
 
-	len = e_snprintf(buf, MAX_CMDLEN, "%c:%s/%s %s+%lu",
-			 tp->retprobe ? 'r' : 'p',
-			 tev->group, tev->event,
-			 tp->symbol, tp->offset);
+	if (tev->uprobes)
+		len = e_snprintf(buf, MAX_CMDLEN, "%c:%s/%s %s",
+				 tp->retprobe ? 'r' : 'p',
+				 tev->group, tev->event, tp->symbol);
+	else if (tp->offset)
+		len = e_snprintf(buf, MAX_CMDLEN, "%c:%s/%s %s+%lu",
+				 tp->retprobe ? 'r' : 'p',
+				 tev->group, tev->event,
+				 tp->symbol, tp->offset);
+	else
+		len = e_snprintf(buf, MAX_CMDLEN, "%c:%s/%s %s",
+				 tp->retprobe ? 'r' : 'p',
+				 tev->group, tev->event,
+				 tp->symbol);
+
 	if (len <= 0)
 		goto error;
 
@@ -1291,7 +1360,7 @@ error:
 }
 
 static int convert_to_perf_probe_event(struct probe_trace_event *tev,
-				       struct perf_probe_event *pev)
+			       struct perf_probe_event *pev, bool is_kprobe)
 {
 	char buf[64] = "";
 	int i, ret;
@@ -1303,7 +1372,11 @@ static int convert_to_perf_probe_event(struct probe_trace_event *tev,
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
 
@@ -1397,7 +1470,7 @@ static void clear_probe_trace_event(struct probe_trace_event *tev)
 	memset(tev, 0, sizeof(*tev));
 }
 
-static int open_kprobe_events(bool readwrite)
+static int open_probe_events(bool readwrite, bool is_kprobe)
 {
 	char buf[PATH_MAX];
 	const char *__debugfs;
@@ -1408,8 +1481,13 @@ static int open_kprobe_events(bool readwrite)
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
@@ -1420,16 +1498,29 @@ static int open_kprobe_events(bool readwrite)
 
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
@@ -1494,36 +1585,26 @@ static int show_perf_probe_event(struct perf_probe_event *pev)
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
@@ -1533,6 +1614,31 @@ int show_perf_probe_events(void)
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
@@ -1642,7 +1748,10 @@ static int __add_probe_trace_events(struct perf_probe_event *pev,
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
@@ -1656,18 +1765,19 @@ static int __add_probe_trace_events(struct perf_probe_event *pev,
 	printf("Add new event%s\n", (ntevs > 1) ? "s:" : ":");
 	for (i = 0; i < ntevs; i++) {
 		tev = &tevs[i];
-		if (pev->event)
-			event = pev->event;
-		else
-			if (pev->point.function)
-				event = pev->point.function;
-			else
-				event = tev->point.symbol;
+
 		if (pev->group)
 			group = pev->group;
 		else
 			group = PERFPROBE_GROUP;
 
+		if (pev->event)
+			event = pev->event;
+		else if (pev->point.function)
+			event = pev->point.function;
+		else
+			event = tev->point.symbol;
+
 		/* Get an unused new event name */
 		ret = get_new_event_name(buf, 64, event,
 					 namelist, allow_suffix);
@@ -1745,6 +1855,7 @@ static int convert_to_probe_trace_events(struct perf_probe_event *pev,
 	tev->point.offset = pev->point.offset;
 	tev->point.retprobe = pev->point.retprobe;
 	tev->nargs = pev->nargs;
+	tev->uprobes = pev->uprobes;
 	if (tev->nargs) {
 		tev->args = zalloc(sizeof(struct probe_trace_arg)
 				   * tev->nargs);
@@ -1775,6 +1886,9 @@ static int convert_to_probe_trace_events(struct perf_probe_event *pev,
 		}
 	}
 
+	if (pev->uprobes)
+		return 1;
+
 	/* Currently just checking function name from symbol map */
 	sym = __find_kernel_function_by_name(tev->point.symbol, NULL);
 	if (!sym) {
@@ -1801,15 +1915,19 @@ struct __event_package {
 int add_perf_probe_events(struct perf_probe_event *pevs, int npevs,
 			  int max_tevs, const char *module, bool force_add)
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
@@ -1879,23 +1997,15 @@ error:
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
@@ -1904,40 +2014,42 @@ static int del_trace_probe_event(int fd, const char *group,
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
+	struct strlist *namelist = NULL, *unamelist = NULL;
 
-	fd = open_kprobe_events(true);
-	if (fd < 0)
-		return fd;
 
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
@@ -1949,15 +2061,37 @@ int del_perf_probe_events(struct strlist *dellist)
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
 /* TODO: don't use a global variable for filter ... */
@@ -2003,3 +2137,102 @@ int show_available_funcs(const char *elfobject, struct strfilter *_filter)
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
+static int convert_name_to_addr(struct perf_probe_event *pev)
+{
+	struct perf_probe_point *pp = &pev->point;
+	struct symbol *sym;
+	struct map *map;
+	char *name = NULL, *tmpname = NULL, *function = NULL;
+	int ret = -EINVAL;
+	unsigned long long vaddr = 0;
+
+	/* check if user has specifed a virtual address
+	vaddr = strtoul(pp->function, NULL, 0); */
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
+	tmpname = strchr(function, '@');
+	if (!tmpname) {
+		pr_warning("Cannot break %s into function and file\n",
+				function);
+		goto out;
+	}
+
+	*tmpname = '\0';
+	name = realpath(tmpname + 1, NULL);
+	if (!name) {
+		pr_warning("Cannot find realpath for %s.\n", tmpname + 1);
+		goto out;
+	}
+
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
+		ptr1 = strdup(basename(name));
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
+	if (function)
+		free(function);
+	if (name)
+		free(name);
+	return ret;
+}
diff --git a/tools/perf/util/probe-event.h b/tools/perf/util/probe-event.h
index 3434fc9..365e016 100644
--- a/tools/perf/util/probe-event.h
+++ b/tools/perf/util/probe-event.h
@@ -7,7 +7,7 @@
 
 extern bool probe_event_dry_run;
 
-/* kprobe-tracer tracing point */
+/* kprobe-tracer and uprobe-tracer tracing point */
 struct probe_trace_point {
 	char		*symbol;	/* Base symbol */
 	unsigned long	offset;		/* Offset from symbol */
@@ -20,7 +20,7 @@ struct probe_trace_arg_ref {
 	long				offset;	/* Offset value */
 };
 
-/* kprobe-tracer tracing argument */
+/* kprobe-tracer and uprobe-tracer tracing argument */
 struct probe_trace_arg {
 	char				*name;	/* Argument name */
 	char				*value;	/* Base value */
@@ -28,12 +28,13 @@ struct probe_trace_arg {
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
 
@@ -69,6 +70,7 @@ struct perf_probe_event {
 	char			*group;	/* Group name */
 	struct perf_probe_point	point;	/* Probe point */
 	int			nargs;	/* Number of arguments */
+	bool			uprobes;
 	struct perf_probe_arg	*args;	/* Arguments */
 };
 
diff --git a/tools/perf/util/symbol.c b/tools/perf/util/symbol.c
index eec1963..6a52022 100644
--- a/tools/perf/util/symbol.c
+++ b/tools/perf/util/symbol.c
@@ -565,7 +565,7 @@ static int dso__split_kallsyms(struct dso *dso, struct map *map,
 	struct machine *machine = kmaps->machine;
 	struct map *curr_map = map;
 	struct symbol *pos;
-	int count = 0, moved = 0;	
+	int count = 0, moved = 0;
 	struct rb_root *root = &dso->symbols[map->type];
 	struct rb_node *next = rb_first(root);
 	int kernel_range = 0;
@@ -2665,3 +2665,11 @@ int machine__load_vmlinux_path(struct machine *machine, enum map_type type,
 
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
index 325ee36..8824d57 100644
--- a/tools/perf/util/symbol.h
+++ b/tools/perf/util/symbol.h
@@ -215,6 +215,7 @@ void dso__set_long_name(struct dso *dso, char *name);
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
