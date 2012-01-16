Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id EC36C6B0093
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 09:31:47 -0500 (EST)
Received: from /spool/local
	by e6.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 16 Jan 2012 09:31:45 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 4881C1FF0047
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 07:30:36 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0GEUKjP017342
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 07:30:21 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0GEUILx015672
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 07:30:20 -0700
Date: Mon, 16 Jan 2012 19:51:31 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v9 3.2 9/9] perf: perf interface for uprobes
Message-ID: <20120116142131.GF10189@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20111216122756.2085.95791.sendpatchset@srdronam.in.ibm.com>
 <20111216122951.2085.95511.sendpatchset@srdronam.in.ibm.com>
 <4F06D22D.9060906@hitachi.com>
 <20120109112236.GA10189@linux.vnet.ibm.com>
 <4F0F8F41.3060806@hitachi.com>
 <20120113051447.GD10189@linux.vnet.ibm.com>
 <4F103975.8070505@hitachi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4F103975.8070505@hitachi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>, yrl.pp-manager.tt@hitachi.com

> >>>
> >>> This is to be in sync with your commit
> >>> 3c42258c9a4db70133fa6946a275b62a16792bb5
> >>
> >> I see, but that commit also provides filter option for changing
> >> the function filter. Here, user can not change the filter rule.
> >>
> >> I think, currently, we don't need to filter any function by name
> >> here, since the user obviously intends to probe given function :)
> > 
> > Actually this was discussed in LKML here
> > https://lkml.org/lkml/2010/7/20/5, please refer the sub-thread.
> > 
> > Basically without this filter, the list of functions is too large
> > including labels, weak, and local binding function which arent traced.
> 
> If you mean that this function is used for listing
> function (perf probe -F), that's true. But it seems
> this convert_name_to_addr() is used just for converting
> given function.
> 
> As far as I can understand, this means that the user
> specifies an actual and single function for the probe point.
> 
> If so, there is no need to list up all functions - just
> find a function which has the given symbol. I guess, it
> is enough to set given function name to
> available_func_filter as below. :)
> 
> available_func_filter = function
> 
> then, map__load() loads only the function which has the
> given function name, doesn't it? :)
> 

Agreed, 
Here is the patch with the additional change that you suggested


- Enhances perf probe to user space executables and libraries.
- Enhances -F/--funcs option of "perf probe" to list possible probe points in
  an executable file or library.
- Documents userspace probing support in perf.

[ Probing a function in the executable using function name  ]
perf probe -x /bin/zsh zfree

[ Probing a library function using function name ]
perf probe -x /lib64/libc.so.6 malloc

[ list probe-able functions in an executable ]
perf probe -F -x /bin/zsh

[ list probe-able functions in an library]
perf probe -F -x /lib/libc.so.6

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---

(Changelog (since v8) changes suggested by Masami)
- tp->symbol is now updated with the virtual address only.
- rename init_perf_uprobes to init_user_exec

(Changelog (since v5))
- Removed the separate documentation change patch and added the
  documentation changes as part of this patch.

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

 tools/perf/Documentation/perf-probe.txt |   14 +
 tools/perf/builtin-probe.c              |   41 +++
 tools/perf/util/probe-event.c           |  416 ++++++++++++++++++++++++-------
 tools/perf/util/probe-event.h           |   12 +
 tools/perf/util/symbol.c                |    8 +
 tools/perf/util/symbol.h                |    1 
 6 files changed, 393 insertions(+), 99 deletions(-)

diff --git a/tools/perf/Documentation/perf-probe.txt b/tools/perf/Documentation/perf-probe.txt
index 2780d9c..be88378 100644
--- a/tools/perf/Documentation/perf-probe.txt
+++ b/tools/perf/Documentation/perf-probe.txt
@@ -78,6 +78,8 @@ OPTIONS
 -F::
 --funcs::
 	Show available functions in given module or kernel.
+	With -x/--exec, can also list functions in a user space executable
+	/ shared library.
 
 --filter=FILTER::
 	(Only for --vars and --funcs) Set filter. FILTER is a combination of glob
@@ -98,6 +100,11 @@ OPTIONS
 --max-probes::
 	Set the maximum number of probe points for an event. Default is 128.
 
+-x::
+--exec=PATH::
+	Specify path to the executable or shared library file for user
+	space tracing. Can also be used with --funcs option.
+
 PROBE SYNTAX
 ------------
 Probe points are defined by following syntax.
@@ -182,6 +189,13 @@ Delete all probes on schedule().
 
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
index 93d5171..5e7622c 100644
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
@@ -336,8 +365,8 @@ int cmd_probe(int argc, const char **argv, const char *prefix __used)
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
@@ -346,7 +375,7 @@ int cmd_probe(int argc, const char **argv, const char *prefix __used)
 	}
 
 #ifdef DWARF_SUPPORT
-	if (params.show_lines) {
+	if (params.show_lines && !params.uprobes) {
 		if (params.mod_events) {
 			pr_err("  Error: Don't use --line with"
 			       " --add/--del.\n");
diff --git a/tools/perf/util/probe-event.c b/tools/perf/util/probe-event.c
index d54eefb..f6f5794 100644
--- a/tools/perf/util/probe-event.c
+++ b/tools/perf/util/probe-event.c
@@ -47,6 +47,7 @@
 #include "trace-event.h"	/* For __unused */
 #include "probe-event.h"
 #include "probe-finder.h"
+#include "session.h"
 
 #define MAX_CMDLEN 256
 #define MAX_PROBE_ARGS 128
@@ -73,6 +74,8 @@ static int e_snprintf(char *str, size_t size, const char *format, ...)
 }
 
 static char *synthesize_perf_probe_point(struct perf_probe_point *pp);
+static int convert_name_to_addr(struct perf_probe_event *pev,
+				const char *exec);
 static struct machine machine;
 
 /* Initialize symbol maps and path of vmlinux/modules */
@@ -173,6 +176,31 @@ const char *kernel_get_module_path(const char *module)
 	return (dso) ? dso->long_name : NULL;
 }
 
+static int init_user_exec(void)
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
@@ -227,10 +255,7 @@ static int kprobe_convert_to_perf_probe(struct probe_trace_point *tp,
 	if (ret <= 0) {
 		pr_debug("Failed to find corresponding probes from "
 			 "debuginfo. Use kprobe event information.\n");
-		pp->function = strdup(tp->symbol);
-		if (pp->function == NULL)
-			return -ENOMEM;
-		pp->offset = tp->offset;
+		return convert_to_perf_probe_point(tp, pp);
 	}
 	pp->retprobe = tp->retprobe;
 
@@ -278,9 +303,19 @@ static int try_to_find_probe_trace_events(struct perf_probe_event *pev,
 					  int max_tevs, const char *target)
 {
 	bool need_dwarf = perf_probe_event_need_dwarf(pev);
-	struct debuginfo *dinfo = open_debuginfo(target);
+	struct debuginfo *dinfo;
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
+	dinfo = open_debuginfo(target);
 	if (!dinfo) {
 		if (need_dwarf) {
 			pr_warning("Failed to open debuginfo file.\n");
@@ -606,23 +641,20 @@ static int kprobe_convert_to_perf_probe(struct probe_trace_point *tp,
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
 
@@ -887,6 +919,11 @@ static int parse_perf_probe_point(char *arg, struct perf_probe_event *pev)
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
@@ -896,6 +933,11 @@ static int parse_perf_probe_point(char *arg, struct perf_probe_event *pev)
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
 
@@ -1344,11 +1386,18 @@ char *synthesize_probe_trace_command(struct probe_trace_event *tev)
 	if (buf == NULL)
 		return NULL;
 
-	len = e_snprintf(buf, MAX_CMDLEN, "%c:%s/%s %s%s%s+%lu",
-			 tp->retprobe ? 'r' : 'p',
-			 tev->group, tev->event,
-			 tp->module ?: "", tp->module ? ":" : "",
-			 tp->symbol, tp->offset);
+	if (tev->uprobes)
+		len = e_snprintf(buf, MAX_CMDLEN, "%c:%s/%s %s:%s",
+				 tp->retprobe ? 'r' : 'p',
+				 tev->group, tev->event,
+				 tp->module, tp->symbol);
+	else
+		len = e_snprintf(buf, MAX_CMDLEN, "%c:%s/%s %s%s%s+%lu",
+				 tp->retprobe ? 'r' : 'p',
+				 tev->group, tev->event,
+				 tp->module ?: "", tp->module ? ":" : "",
+				 tp->symbol, tp->offset);
+
 	if (len <= 0)
 		goto error;
 
@@ -1367,7 +1416,7 @@ char *synthesize_probe_trace_command(struct probe_trace_event *tev)
 }
 
 static int convert_to_perf_probe_event(struct probe_trace_event *tev,
-				       struct perf_probe_event *pev)
+			       struct perf_probe_event *pev, bool is_kprobe)
 {
 	char buf[64] = "";
 	int i, ret;
@@ -1379,7 +1428,11 @@ static int convert_to_perf_probe_event(struct probe_trace_event *tev,
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
 
@@ -1475,7 +1528,7 @@ static void clear_probe_trace_event(struct probe_trace_event *tev)
 	memset(tev, 0, sizeof(*tev));
 }
 
-static int open_kprobe_events(bool readwrite)
+static int open_probe_events(const char *trace_file, bool readwrite)
 {
 	char buf[PATH_MAX];
 	const char *__debugfs;
@@ -1487,7 +1540,7 @@ static int open_kprobe_events(bool readwrite)
 		return -ENOENT;
 	}
 
-	ret = e_snprintf(buf, PATH_MAX, "%stracing/kprobe_events", __debugfs);
+	ret = e_snprintf(buf, PATH_MAX, "%s/%s", __debugfs, trace_file);
 	if (ret >= 0) {
 		pr_debug("Opening %s write=%d\n", buf, readwrite);
 		if (readwrite && !probe_event_dry_run)
@@ -1495,19 +1548,42 @@ static int open_kprobe_events(bool readwrite)
 		else
 			ret = open(buf, O_RDONLY, 0);
 	}
+	return ret;
+}
+
+static void print_warn_msg(const char *file, const char *config)
+{
+	if (errno == ENOENT)
+		pr_warning("%s file does not exist - please rebuild kernel"
+				" with %s.\n", file, config);
+	else
+		pr_warning("Failed to open %s file: %s\n", file,
+				strerror(errno));
+}
+
+static int open_kprobe_events(bool readwrite)
+{
+	int ret;
+
+	ret = open_probe_events("tracing/kprobe_events", readwrite);
+	if (ret < 0)
+		print_warn_msg("kprobe_events", "CONFIG_KPROBE_EVENTS");
 
-	if (ret < 0) {
-		if (errno == ENOENT)
-			pr_warning("kprobe_events file does not exist - please"
-				 " rebuild kernel with CONFIG_KPROBE_EVENT.\n");
-		else
-			pr_warning("Failed to open kprobe_events file: %s\n",
-				   strerror(errno));
-	}
 	return ret;
 }
 
-/* Get raw string list of current kprobe_events */
+static int open_uprobe_events(bool readwrite)
+{
+	int ret;
+
+	ret = open_probe_events("tracing/uprobe_events", readwrite);
+	if (ret < 0)
+		print_warn_msg("uprobe_events", "CONFIG_UPROBE_EVENTS");
+
+	return ret;
+}
+
+/* Get raw string list of current kprobe_events  or uprobe_events */
 static struct strlist *get_probe_trace_command_rawlist(int fd)
 {
 	int ret, idx;
@@ -1572,36 +1648,26 @@ static int show_perf_probe_event(struct perf_probe_event *pev)
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
@@ -1611,6 +1677,31 @@ int show_perf_probe_events(void)
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
@@ -1720,7 +1811,10 @@ static int __add_probe_trace_events(struct perf_probe_event *pev,
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
@@ -1832,6 +1926,7 @@ static int convert_to_probe_trace_events(struct perf_probe_event *pev,
 	tev->point.offset = pev->point.offset;
 	tev->point.retprobe = pev->point.retprobe;
 	tev->nargs = pev->nargs;
+	tev->uprobes = pev->uprobes;
 	if (tev->nargs) {
 		tev->args = zalloc(sizeof(struct probe_trace_arg)
 				   * tev->nargs);
@@ -1862,6 +1957,9 @@ static int convert_to_probe_trace_events(struct perf_probe_event *pev,
 		}
 	}
 
+	if (pev->uprobes)
+		return 1;
+
 	/* Currently just checking function name from symbol map */
 	sym = __find_kernel_function_by_name(tev->point.symbol, NULL);
 	if (!sym) {
@@ -1888,15 +1986,19 @@ struct __event_package {
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
+		ret = init_user_exec();
+
 	if (ret < 0) {
 		free(pkgs);
 		return ret;
@@ -1968,23 +2070,15 @@ static int __del_trace_probe_event(int fd, struct str_node *ent)
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
@@ -1993,40 +2087,41 @@ static int del_trace_probe_event(int fd, const char *group,
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
@@ -2038,17 +2133,40 @@ int del_perf_probe_events(struct strlist *dellist)
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
+	}
+
+error:
+	if (kfd >= 0) {
+		if (namelist)
+			strlist__delete(namelist);
+		close(kfd);
 	}
-	strlist__delete(namelist);
-	close(fd);
 
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
 
@@ -2065,30 +2183,150 @@ static int filter_available_functions(struct map *map __unused,
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
+static int available_user_funcs(const char *target)
+{
+	struct map *map;
+	int ret;
+
+	ret = init_user_exec();
+	if (ret < 0)
+		return ret;
+
+	map = dso__new_map(target);
+	ret = __show_available_funcs(map);
+	dso__delete(map->dso);
+	map__delete(map);
+	return ret;
+}
+
+int show_available_funcs(const char *target, struct strfilter *_filter,
+					bool user)
+{
+	setup_pager();
 	available_func_filter = _filter;
+
+	if (!user)
+		return available_kernel_funcs(target);
+
+	return available_user_funcs(target);
+}
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
+		pr_warning("Cannot find appropriate DSO for %s.\n", exec);
+		goto out;
+	}
+	available_func_filter = strfilter__new(function, NULL);
 	if (map__load(map, filter_available_functions)) {
 		pr_err("Failed to load map.\n");
 		return -EINVAL;
 	}
-	if (!dso__sorted_by_name(map->dso, map->type))
-		dso__sort_by_name(map->dso, map->type);
 
-	dso__fprintf_symbols_by_name(map->dso, map->type, stdout);
-	return 0;
+	sym = map__find_symbol_by_name(map, function, NULL);
+	if (!sym) {
+		pr_warning("Cannot find %s in DSO %s\n", function, exec);
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
+	e_snprintf(pp->function, MAX_PROBE_ARGS, "0x%llx", vaddr);
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
 }
diff --git a/tools/perf/util/probe-event.h b/tools/perf/util/probe-event.h
index a7dee83..f9f3de8 100644
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
 
@@ -129,8 +131,8 @@ extern int show_line_range(struct line_range *lr, const char *module);
 extern int show_available_vars(struct perf_probe_event *pevs, int npevs,
 			       int max_probe_points, const char *module,
 			       struct strfilter *filter, bool externs);
-extern int show_available_funcs(const char *module, struct strfilter *filter);
-
+extern int show_available_funcs(const char *module, struct strfilter *filter,
+				bool user);
 
 /* Maximum index number of event-name postfix */
 #define MAX_EVENT_INDEX	1024
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
