Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CBAB08D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 10:46:17 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp02.au.ibm.com (8.14.4/8.13.1) with ESMTP id p31EejHQ023933
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:40:45 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p31EkD4u2097374
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:46:13 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p31EkCa7023643
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:46:13 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 01 Apr 2011 20:06:32 +0530
Message-Id: <20110401143632.15455.66380.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v3 2.6.39-rc1-tip 20/26] 20: tracing: uprobes trace_event interface
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, LKML <linux-kernel@vger.kernel.org>


Implements trace_event support for uprobes. In its current form it can
be used to put probes at a specified offset in a file and dump the
required registers when the code flow reaches the probed address.

The following example shows how to dump the instruction pointer and %ax
a register at the probed text address.  Here we are trying to probe
zfree in /bin/zsh

# cd /sys/kernel/debug/tracing/
# cat /proc/`pgrep  zsh`/maps | grep /bin/zsh | grep r-xp
00400000-0048a000 r-xp 00000000 08:03 130904 /bin/zsh
# objdump -T /bin/zsh | grep -w zfree
0000000000446420 g    DF .text  0000000000000012  Base        zfree
# echo 'p /bin/zsh:0x46420 %ip %ax' > uprobe_events
# cat uprobe_events
p:uprobes/p_zsh_0x46420 /bin/zsh:0x0000000000046420
# echo 1 > events/uprobes/enable
# sleep 20
# echo 0 > events/uprobes/enable
# cat trace
# tracer: nop
#
#           TASK-PID    CPU#    TIMESTAMP  FUNCTION
#              | |       |          |         |
             zsh-24842 [006] 258544.995456: p_zsh_0x46420: (0x446420) arg1=446421 arg2=79
             zsh-24842 [007] 258545.000270: p_zsh_0x46420: (0x446420) arg1=446421 arg2=79
             zsh-24842 [002] 258545.043929: p_zsh_0x46420: (0x446420) arg1=446421 arg2=79
             zsh-24842 [004] 258547.046129: p_zsh_0x46420: (0x446420) arg1=446421 arg2=79

TODO: Connect a filter to a consumer.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 arch/Kconfig                |   10 -
 kernel/trace/Kconfig        |   16 +
 kernel/trace/Makefile       |    1 
 kernel/trace/trace.h        |    5 
 kernel/trace/trace_kprobe.c |    4 
 kernel/trace/trace_probe.c  |   14 +
 kernel/trace/trace_probe.h  |    6 
 kernel/trace/trace_uprobe.c |  803 +++++++++++++++++++++++++++++++++++++++++++
 8 files changed, 842 insertions(+), 17 deletions(-)
 create mode 100644 kernel/trace/trace_uprobe.c

diff --git a/arch/Kconfig b/arch/Kconfig
index c681f16..c4e9663 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -62,16 +62,8 @@ config OPTPROBES
 	depends on !PREEMPT
 
 config UPROBES
-	bool "User-space probes (EXPERIMENTAL)"
-	depends on ARCH_SUPPORTS_UPROBES
-	depends on MMU
 	select MM_OWNER
-	help
-	  Uprobes enables kernel subsystems to establish probepoints
-	  in user applications and execute handler functions when
-	  the probepoints are hit.
-
-	  If in doubt, say "N".
+	def_bool n
 
 config HAVE_EFFICIENT_UNALIGNED_ACCESS
 	bool
diff --git a/kernel/trace/Kconfig b/kernel/trace/Kconfig
index 9c62806..0b1b7d5 100644
--- a/kernel/trace/Kconfig
+++ b/kernel/trace/Kconfig
@@ -386,6 +386,22 @@ config KPROBE_EVENT
 	  This option is also required by perf-probe subcommand of perf tools.
 	  If you want to use perf tools, this option is strongly recommended.
 
+config UPROBE_EVENT
+	bool "Enable uprobes-based dynamic events"
+	depends on ARCH_SUPPORTS_UPROBES
+	depends on MMU
+	select UPROBES
+	select PROBE_EVENTS
+	select TRACING
+	default n
+	help
+	  This allows the user to add tracing events on top of userspace dynamic
+	  events (similar to tracepoints) on the fly via the traceevents interface.
+	  Those events can be inserted wherever uprobes can probe, and record
+	  various registers.
+	  This option is required if you plan to use perf-probe subcommand of perf
+	  tools on user space applications.
+
 config PROBE_EVENTS
 	def_bool n
 
diff --git a/kernel/trace/Makefile b/kernel/trace/Makefile
index 692223a..bb3d3ff 100644
--- a/kernel/trace/Makefile
+++ b/kernel/trace/Makefile
@@ -57,5 +57,6 @@ ifeq ($(CONFIG_TRACING),y)
 obj-$(CONFIG_KGDB_KDB) += trace_kdb.o
 endif
 obj-$(CONFIG_PROBE_EVENTS) +=trace_probe.o
+obj-$(CONFIG_UPROBE_EVENT) += trace_uprobe.o
 
 libftrace-y := ftrace.o
diff --git a/kernel/trace/trace.h b/kernel/trace/trace.h
index 5e9dfc6..55249f8 100644
--- a/kernel/trace/trace.h
+++ b/kernel/trace/trace.h
@@ -97,6 +97,11 @@ struct kretprobe_trace_entry_head {
 	unsigned long		ret_ip;
 };
 
+struct uprobe_trace_entry_head {
+	struct trace_entry	ent;
+	unsigned long		ip;
+};
+
 /*
  * trace_flag_type is an enumeration that holds different
  * states when a trace occurs. These are:
diff --git a/kernel/trace/trace_kprobe.c b/kernel/trace/trace_kprobe.c
index 3f9189d..dec70fb 100644
--- a/kernel/trace/trace_kprobe.c
+++ b/kernel/trace/trace_kprobe.c
@@ -374,8 +374,8 @@ static int create_trace_probe(int argc, char **argv)
 		}
 
 		/* Parse fetch argument */
-		ret = traceprobe_parse_probe_arg(arg, &tp->size, &tp->args[i],
-								is_return);
+		ret = traceprobe_parse_probe_arg(arg, &tp->size,
+					&tp->args[i], is_return, true);
 		if (ret) {
 			pr_info("Parse error at argument[%d]. (%d)\n", i, ret);
 			goto error;
diff --git a/kernel/trace/trace_probe.c b/kernel/trace/trace_probe.c
index 0fcdb16..4499a2a 100644
--- a/kernel/trace/trace_probe.c
+++ b/kernel/trace/trace_probe.c
@@ -508,13 +508,17 @@ static int parse_probe_vars(char *arg, const struct fetch_type *t,
 
 /* Recursive argument parser */
 static int parse_probe_arg(char *arg, const struct fetch_type *t,
-		     struct fetch_param *f, bool is_return)
+		     struct fetch_param *f, bool is_return, bool is_kprobe)
 {
 	int ret = 0;
 	unsigned long param;
 	long offset;
 	char *tmp;
 
+	/* Until uprobe_events supports only reg arguments */
+	if (!is_kprobe && arg[0] != '%')
+		return -EINVAL;
+
 	switch (arg[0]) {
 	case '$':
 		ret = parse_probe_vars(arg + 1, t, f, is_return);
@@ -564,7 +568,8 @@ static int parse_probe_arg(char *arg, const struct fetch_type *t,
 			if (!dprm)
 				return -ENOMEM;
 			dprm->offset = offset;
-			ret = parse_probe_arg(arg, t2, &dprm->orig, is_return);
+			ret = parse_probe_arg(arg, t2, &dprm->orig, is_return,
+							is_kprobe);
 			if (ret)
 				kfree(dprm);
 			else {
@@ -618,7 +623,7 @@ static int __parse_bitfield_probe_arg(const char *bf,
 
 /* String length checking wrapper */
 int traceprobe_parse_probe_arg(char *arg, ssize_t *size,
-		struct probe_arg *parg, bool is_return)
+		struct probe_arg *parg, bool is_return, bool is_kprobe)
 {
 	const char *t;
 	int ret;
@@ -644,7 +649,8 @@ int traceprobe_parse_probe_arg(char *arg, ssize_t *size,
 	}
 	parg->offset = *size;
 	*size += parg->type->size;
-	ret = parse_probe_arg(arg, parg->type, &parg->fetch, is_return);
+	ret = parse_probe_arg(arg, parg->type, &parg->fetch, is_return,
+							is_kprobe);
 	if (ret >= 0 && t != NULL)
 		ret = __parse_bitfield_probe_arg(t, parg->type, &parg->fetch);
 	if (ret >= 0) {
diff --git a/kernel/trace/trace_probe.h b/kernel/trace/trace_probe.h
index 487514b..f625d8d 100644
--- a/kernel/trace/trace_probe.h
+++ b/kernel/trace/trace_probe.h
@@ -48,6 +48,7 @@
 #define FIELD_STRING_IP "__probe_ip"
 #define FIELD_STRING_RETIP "__probe_ret_ip"
 #define FIELD_STRING_FUNC "__probe_func"
+#define FIELD_STRING_PID "__probe_pid"
 
 #undef DEFINE_FIELD
 #define DEFINE_FIELD(type, item, name, is_signed)			\
@@ -64,6 +65,7 @@
 /* Flags for trace_probe */
 #define TP_FLAG_TRACE	1
 #define TP_FLAG_PROFILE	2
+#define TP_FLAG_UPROBE	4
 
 
 /* data_rloc: data relative location, compatible with u32 */
@@ -130,7 +132,7 @@ static inline __kprobes void call_fetch(struct fetch_param *fprm,
 }
 
 /* Check the name is good for event/group/fields */
-static int is_good_name(const char *name)
+static inline int is_good_name(const char *name)
 {
 	if (!isalpha(*name) && *name != '_')
 		return 0;
@@ -142,7 +144,7 @@ static int is_good_name(const char *name)
 }
 
 extern int traceprobe_parse_probe_arg(char *arg, ssize_t *size,
-		   struct probe_arg *parg, bool is_return);
+		   struct probe_arg *parg, bool is_return, bool is_kprobe);
 
 extern int traceprobe_conflict_field_name(const char *name,
 			       struct probe_arg *args, int narg);
diff --git a/kernel/trace/trace_uprobe.c b/kernel/trace/trace_uprobe.c
new file mode 100644
index 0000000..8395cfc
--- /dev/null
+++ b/kernel/trace/trace_uprobe.c
@@ -0,0 +1,803 @@
+/*
+ * uprobes-based tracing events
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ * Copyright (C) IBM Corporation, 2010
+ * Author:	Srikar Dronamraju
+ */
+
+#include <linux/module.h>
+#include <linux/uaccess.h>
+#include <linux/uprobes.h>
+#include <linux/namei.h>
+
+#include "trace_probe.h"
+
+#define UPROBE_EVENT_SYSTEM "uprobes"
+
+/**
+ * uprobe event core functions
+ */
+struct trace_uprobe;
+struct uprobe_trace_consumer {
+	struct uprobe_consumer cons;
+	struct trace_uprobe *tp;
+};
+
+struct trace_uprobe {
+	struct list_head	list;
+	struct ftrace_event_class	class;
+	struct ftrace_event_call	call;
+	struct uprobe_trace_consumer	*consumer;
+	struct inode		*inode;
+	char			*filename;
+	unsigned long		offset;
+	unsigned long		nhit;
+	unsigned int		flags;	/* For TP_FLAG_* */
+	ssize_t			size;		/* trace entry size */
+	unsigned int		nr_args;
+	struct probe_arg	args[];
+};
+
+#define SIZEOF_TRACE_UPROBE(n)			\
+	(offsetof(struct trace_uprobe, args) +	\
+	(sizeof(struct probe_arg) * (n)))
+
+static int register_uprobe_event(struct trace_uprobe *tp);
+static void unregister_uprobe_event(struct trace_uprobe *tp);
+
+static DEFINE_MUTEX(uprobe_lock);
+static LIST_HEAD(uprobe_list);
+
+static int uprobe_dispatcher(struct uprobe_consumer *con, struct pt_regs *regs);
+
+/*
+ * Allocate new trace_uprobe and initialize it (including uprobes).
+ */
+static struct trace_uprobe *alloc_trace_uprobe(const char *group,
+				const char *event, int nargs)
+{
+	struct trace_uprobe *tp;
+
+	if (!event || !is_good_name(event))  {
+		printk(KERN_ERR "%s\n", event);
+		return ERR_PTR(-EINVAL);
+	}
+
+	if (!group || !is_good_name(group)) {
+		printk(KERN_ERR "%s\n", group);
+		return ERR_PTR(-EINVAL);
+	}
+
+	tp = kzalloc(SIZEOF_TRACE_UPROBE(nargs), GFP_KERNEL);
+	if (!tp)
+		return ERR_PTR(-ENOMEM);
+
+	tp->call.class = &tp->class;
+	tp->call.name = kstrdup(event, GFP_KERNEL);
+	if (!tp->call.name)
+		goto error;
+
+	tp->class.system = kstrdup(group, GFP_KERNEL);
+	if (!tp->class.system)
+		goto error;
+
+	INIT_LIST_HEAD(&tp->list);
+	return tp;
+error:
+	kfree(tp->call.name);
+	kfree(tp);
+	return ERR_PTR(-ENOMEM);
+}
+
+static void free_trace_uprobe(struct trace_uprobe *tp)
+{
+	int i;
+
+	for (i = 0; i < tp->nr_args; i++)
+		traceprobe_free_probe_arg(&tp->args[i]);
+
+	iput(tp->inode);
+	kfree(tp->call.class->system);
+	kfree(tp->call.name);
+	kfree(tp->filename);
+	kfree(tp);
+}
+
+static struct trace_uprobe *find_probe_event(const char *event,
+					const char *group)
+{
+	struct trace_uprobe *tp;
+
+	list_for_each_entry(tp, &uprobe_list, list)
+		if (strcmp(tp->call.name, event) == 0 &&
+		    strcmp(tp->call.class->system, group) == 0)
+			return tp;
+	return NULL;
+}
+
+/* Unregister a trace_uprobe and probe_event: call with locking uprobe_lock */
+static void unregister_trace_uprobe(struct trace_uprobe *tp)
+{
+	list_del(&tp->list);
+	unregister_uprobe_event(tp);
+	free_trace_uprobe(tp);
+}
+
+/* Register a trace_uprobe and probe_event */
+static int register_trace_uprobe(struct trace_uprobe *tp)
+{
+	struct trace_uprobe *old_tp;
+	int ret;
+
+	mutex_lock(&uprobe_lock);
+
+	/* register as an event */
+	old_tp = find_probe_event(tp->call.name, tp->call.class->system);
+	if (old_tp)
+		/* delete old event */
+		unregister_trace_uprobe(old_tp);
+
+	ret = register_uprobe_event(tp);
+	if (ret) {
+		pr_warning("Failed to register probe event(%d)\n", ret);
+		goto end;
+	}
+
+	list_add_tail(&tp->list, &uprobe_list);
+end:
+	mutex_unlock(&uprobe_lock);
+	return ret;
+}
+
+static int create_trace_uprobe(int argc, char **argv)
+{
+	/*
+	 * Argument syntax:
+	 *  - Add uprobe: p[:[GRP/]EVENT] VADDR@PID [%REG]
+	 *
+	 *  - Remove uprobe: -:[GRP/]EVENT
+	 */
+	struct path path;
+	struct inode *inode;
+	struct trace_uprobe *tp;
+	int i, ret = 0;
+	int is_delete = 0;
+	char *arg = NULL, *event = NULL, *group = NULL;
+	unsigned long offset;
+	char buf[MAX_EVENT_NAME_LEN];
+	char *filename;
+
+	/* argc must be >= 1 */
+	if (argv[0][0] == '-')
+		is_delete = 1;
+	else if (argv[0][0] != 'p') {
+		pr_info("Probe definition must be started with 'p', 'r' or"
+			" '-'.\n");
+		return -EINVAL;
+	}
+
+	if (argv[0][1] == ':') {
+		event = &argv[0][2];
+		if (strchr(event, '/')) {
+			group = event;
+			event = strchr(group, '/') + 1;
+			event[-1] = '\0';
+			if (strlen(group) == 0) {
+				pr_info("Group name is not specified\n");
+				return -EINVAL;
+			}
+		}
+		if (strlen(event) == 0) {
+			pr_info("Event name is not specified\n");
+			return -EINVAL;
+		}
+	}
+	if (!group)
+		group = UPROBE_EVENT_SYSTEM;
+
+	if (is_delete) {
+		if (!event) {
+			pr_info("Delete command needs an event name.\n");
+			return -EINVAL;
+		}
+		mutex_lock(&uprobe_lock);
+		tp = find_probe_event(event, group);
+		if (!tp) {
+			mutex_unlock(&uprobe_lock);
+			pr_info("Event %s/%s doesn't exist.\n", group, event);
+			return -ENOENT;
+		}
+		/* delete an event */
+		unregister_trace_uprobe(tp);
+		mutex_unlock(&uprobe_lock);
+		return 0;
+	}
+
+	if (argc < 2) {
+		pr_info("Probe point is not specified.\n");
+		return -EINVAL;
+	}
+	if (isdigit(argv[1][0])) {
+		pr_info("probe point must be have a filename.\n");
+		return -EINVAL;
+	}
+	arg = strchr(argv[1], ':');
+	if (!arg)
+		goto fail_address_parse;
+
+	*arg++ = '\0';
+	filename = argv[1];
+	ret = kern_path(filename, LOOKUP_FOLLOW, &path);
+	if (ret)
+		goto fail_address_parse;
+	inode = path.dentry->d_inode;
+	__iget(inode);
+
+	ret = strict_strtoul(arg, 0, &offset);
+		if (ret)
+			goto fail_address_parse;
+	argc -= 2; argv += 2;
+
+	/* setup a probe */
+	if (!event) {
+		char *tail = strrchr(filename, '/');
+
+		snprintf(buf, MAX_EVENT_NAME_LEN, "%c_%s_0x%lx", 'p',
+				(tail ? tail + 1 : filename), offset);
+		event = buf;
+	}
+	tp = alloc_trace_uprobe(group, event, argc);
+	if (IS_ERR(tp)) {
+		pr_info("Failed to allocate trace_uprobe.(%d)\n",
+			(int)PTR_ERR(tp));
+		iput(inode);
+		return PTR_ERR(tp);
+	}
+	tp->offset = offset;
+	tp->inode = inode;
+	tp->filename = kstrdup(filename, GFP_KERNEL);
+	if (!tp->filename) {
+			pr_info("Failed to allocate filename.\n");
+			ret = -ENOMEM;
+			goto error;
+	}
+
+	/* parse arguments */
+	ret = 0;
+	for (i = 0; i < argc && i < MAX_TRACE_ARGS; i++) {
+		/* Increment count for freeing args in error case */
+		tp->nr_args++;
+
+		/* Parse argument name */
+		arg = strchr(argv[i], '=');
+		if (arg) {
+			*arg++ = '\0';
+			tp->args[i].name = kstrdup(argv[i], GFP_KERNEL);
+		} else {
+			arg = argv[i];
+			/* If argument name is omitted, set "argN" */
+			snprintf(buf, MAX_EVENT_NAME_LEN, "arg%d", i + 1);
+			tp->args[i].name = kstrdup(buf, GFP_KERNEL);
+		}
+
+		if (!tp->args[i].name) {
+			pr_info("Failed to allocate argument[%d] name.\n", i);
+			ret = -ENOMEM;
+			goto error;
+		}
+
+		if (!is_good_name(tp->args[i].name)) {
+			pr_info("Invalid argument[%d] name: %s\n",
+				i, tp->args[i].name);
+			ret = -EINVAL;
+			goto error;
+		}
+
+		if (traceprobe_conflict_field_name(tp->args[i].name,
+							tp->args, i)) {
+			pr_info("Argument[%d] name '%s' conflicts with "
+				"another field.\n", i, argv[i]);
+			ret = -EINVAL;
+			goto error;
+		}
+
+		/* Parse fetch argument */
+		ret = traceprobe_parse_probe_arg(arg, &tp->size, &tp->args[i],
+								false, false);
+		if (ret) {
+			pr_info("Parse error at argument[%d]. (%d)\n", i, ret);
+			goto error;
+		}
+	}
+
+	ret = register_trace_uprobe(tp);
+	if (ret)
+		goto error;
+	return 0;
+
+error:
+	free_trace_uprobe(tp);
+	return ret;
+
+fail_address_parse:
+	pr_info("Failed to parse address.\n");
+	return ret;
+}
+
+static void cleanup_all_probes(void)
+{
+	struct trace_uprobe *tp;
+
+	mutex_lock(&uprobe_lock);
+	while (!list_empty(&uprobe_list)) {
+		tp = list_entry(uprobe_list.next, struct trace_uprobe, list);
+		unregister_trace_uprobe(tp);
+	}
+	mutex_unlock(&uprobe_lock);
+}
+
+
+/* Probes listing interfaces */
+static void *probes_seq_start(struct seq_file *m, loff_t *pos)
+{
+	mutex_lock(&uprobe_lock);
+	return seq_list_start(&uprobe_list, *pos);
+}
+
+static void *probes_seq_next(struct seq_file *m, void *v, loff_t *pos)
+{
+	return seq_list_next(v, &uprobe_list, pos);
+}
+
+static void probes_seq_stop(struct seq_file *m, void *v)
+{
+	mutex_unlock(&uprobe_lock);
+}
+
+static int probes_seq_show(struct seq_file *m, void *v)
+{
+	struct trace_uprobe *tp = v;
+	int i;
+
+	seq_printf(m, "p:%s/%s", tp->call.class->system, tp->call.name);
+	seq_printf(m, " %s:0x%p", tp->filename, (void *)tp->offset);
+
+	for (i = 0; i < tp->nr_args; i++)
+		seq_printf(m, " %s=%s", tp->args[i].name, tp->args[i].comm);
+	seq_printf(m, "\n");
+	return 0;
+}
+
+static const struct seq_operations probes_seq_op = {
+	.start  = probes_seq_start,
+	.next   = probes_seq_next,
+	.stop   = probes_seq_stop,
+	.show   = probes_seq_show
+};
+
+static int probes_open(struct inode *inode, struct file *file)
+{
+	if ((file->f_mode & FMODE_WRITE) &&
+	    (file->f_flags & O_TRUNC))
+		cleanup_all_probes();
+
+	return seq_open(file, &probes_seq_op);
+}
+
+static ssize_t probes_write(struct file *file, const char __user *buffer,
+			    size_t count, loff_t *ppos)
+{
+	return traceprobe_probes_write(file, buffer, count, ppos,
+			create_trace_uprobe);
+}
+
+static const struct file_operations uprobe_events_ops = {
+	.owner          = THIS_MODULE,
+	.open           = probes_open,
+	.read           = seq_read,
+	.llseek         = seq_lseek,
+	.release        = seq_release,
+	.write		= probes_write,
+};
+
+/* Probes profiling interfaces */
+static int probes_profile_seq_show(struct seq_file *m, void *v)
+{
+	struct trace_uprobe *tp = v;
+
+	seq_printf(m, "  %s %-44s %15lu\n", tp->filename, tp->call.name,
+								tp->nhit);
+	return 0;
+}
+
+static const struct seq_operations profile_seq_op = {
+	.start  = probes_seq_start,
+	.next   = probes_seq_next,
+	.stop   = probes_seq_stop,
+	.show   = probes_profile_seq_show
+};
+
+static int profile_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &profile_seq_op);
+}
+
+static const struct file_operations uprobe_profile_ops = {
+	.owner          = THIS_MODULE,
+	.open           = profile_open,
+	.read           = seq_read,
+	.llseek         = seq_lseek,
+	.release        = seq_release,
+};
+
+/* uprobe handler */
+static void uprobe_trace_func(struct trace_uprobe *tp, struct pt_regs *regs)
+{
+	struct uprobe_trace_entry_head *entry;
+	struct ring_buffer_event *event;
+	struct ring_buffer *buffer;
+	u8 *data;
+	int size, i, pc;
+	unsigned long irq_flags;
+	struct ftrace_event_call *call = &tp->call;
+
+	tp->nhit++;
+
+	local_save_flags(irq_flags);
+	pc = preempt_count();
+
+	size = sizeof(*entry) + tp->size;
+
+	event = trace_current_buffer_lock_reserve(&buffer, call->event.type,
+						  size, irq_flags, pc);
+	if (!event)
+		return;
+
+	entry = ring_buffer_event_data(event);
+	entry->ip = uprobes_get_bkpt_addr(task_pt_regs(current));
+	data = (u8 *)&entry[1];
+	for (i = 0; i < tp->nr_args; i++)
+		call_fetch(&tp->args[i].fetch, regs,
+						data + tp->args[i].offset);
+
+	if (!filter_current_check_discard(buffer, call, entry, event))
+		trace_buffer_unlock_commit(buffer, event, irq_flags, pc);
+}
+
+/* Event entry printers */
+enum print_line_t
+print_uprobe_event(struct trace_iterator *iter, int flags,
+		   struct trace_event *event)
+{
+	struct uprobe_trace_entry_head *field;
+	struct trace_seq *s = &iter->seq;
+	struct trace_uprobe *tp;
+	u8 *data;
+	int i;
+
+	field = (struct uprobe_trace_entry_head *)iter->ent;
+	tp = container_of(event, struct trace_uprobe, call.event);
+
+	if (!trace_seq_printf(s, "%s: (", tp->call.name))
+		goto partial;
+
+	if (!seq_print_ip_sym(s, field->ip, flags | TRACE_ITER_SYM_OFFSET))
+		goto partial;
+
+	if (!trace_seq_puts(s, ")"))
+		goto partial;
+
+	data = (u8 *)&field[1];
+	for (i = 0; i < tp->nr_args; i++)
+		if (!tp->args[i].type->print(s, tp->args[i].name,
+					     data + tp->args[i].offset, field))
+			goto partial;
+
+	if (!trace_seq_puts(s, "\n"))
+		goto partial;
+
+	return TRACE_TYPE_HANDLED;
+partial:
+	return TRACE_TYPE_PARTIAL_LINE;
+}
+
+
+static int probe_event_enable(struct ftrace_event_call *call)
+{
+	struct uprobe_trace_consumer *utc;
+	struct trace_uprobe *tp = (struct trace_uprobe *)call->data;
+	int ret = 0;
+
+	if (!tp->inode || tp->consumer)
+		return -EINTR;
+
+	utc = kzalloc(sizeof(struct uprobe_trace_consumer), GFP_KERNEL);
+	if (!utc)
+		return -EINTR;
+
+	utc->cons.handler = uprobe_dispatcher;
+	utc->cons.filter = NULL;
+	ret = register_uprobe(tp->inode, tp->offset, &utc->cons);
+	if (ret) {
+		kfree(utc);
+		return ret;
+	}
+
+	tp->flags |= TP_FLAG_TRACE;
+	utc->tp = tp;
+	tp->consumer = utc;
+	return 0;
+}
+
+static void probe_event_disable(struct ftrace_event_call *call)
+{
+	struct trace_uprobe *tp = (struct trace_uprobe *)call->data;
+
+	if (!tp->inode || !tp->consumer)
+		return;
+
+	unregister_uprobe(tp->inode, tp->offset, &tp->consumer->cons);
+	tp->flags &= ~TP_FLAG_TRACE;
+	kfree(tp->consumer);
+	tp->consumer = NULL;
+}
+
+static int uprobe_event_define_fields(struct ftrace_event_call *event_call)
+{
+	int ret, i;
+	struct uprobe_trace_entry_head field;
+	struct trace_uprobe *tp = (struct trace_uprobe *)event_call->data;
+
+	DEFINE_FIELD(unsigned long, ip, FIELD_STRING_IP, 0);
+	/* Set argument names as fields */
+	for (i = 0; i < tp->nr_args; i++) {
+		ret = trace_define_field(event_call, tp->args[i].type->fmttype,
+					 tp->args[i].name,
+					 sizeof(field) + tp->args[i].offset,
+					 tp->args[i].type->size,
+					 tp->args[i].type->is_signed,
+					 FILTER_OTHER);
+		if (ret)
+			return ret;
+	}
+	return 0;
+}
+
+static int __set_print_fmt(struct trace_uprobe *tp, char *buf, int len)
+{
+	int i;
+	int pos = 0;
+
+	const char *fmt, *arg;
+
+	fmt = "(%lx)";
+	arg = "REC->" FIELD_STRING_IP;
+
+	/* When len=0, we just calculate the needed length */
+#define LEN_OR_ZERO (len ? len - pos : 0)
+
+	pos += snprintf(buf + pos, LEN_OR_ZERO, "\"%s", fmt);
+
+	for (i = 0; i < tp->nr_args; i++) {
+		pos += snprintf(buf + pos, LEN_OR_ZERO, " %s=%s",
+				tp->args[i].name, tp->args[i].type->fmt);
+	}
+
+	pos += snprintf(buf + pos, LEN_OR_ZERO, "\", %s", arg);
+
+	for (i = 0; i < tp->nr_args; i++) {
+		pos += snprintf(buf + pos, LEN_OR_ZERO, ", REC->%s",
+				tp->args[i].name);
+	}
+
+#undef LEN_OR_ZERO
+
+	/* return the length of print_fmt */
+	return pos;
+}
+
+static int set_print_fmt(struct trace_uprobe *tp)
+{
+	int len;
+	char *print_fmt;
+
+	/* First: called with 0 length to calculate the needed length */
+	len = __set_print_fmt(tp, NULL, 0);
+	print_fmt = kmalloc(len + 1, GFP_KERNEL);
+	if (!print_fmt)
+		return -ENOMEM;
+
+	/* Second: actually write the @print_fmt */
+	__set_print_fmt(tp, print_fmt, len + 1);
+	tp->call.print_fmt = print_fmt;
+
+	return 0;
+}
+
+#ifdef CONFIG_PERF_EVENTS
+
+/* uprobe profile handler */
+static void uprobe_perf_func(struct trace_uprobe *tp,
+					 struct pt_regs *regs)
+{
+	struct ftrace_event_call *call = &tp->call;
+	struct uprobe_trace_entry_head *entry;
+	struct hlist_head *head;
+	u8 *data;
+	int size, __size, i;
+	int rctx;
+
+	__size = sizeof(*entry) + tp->size;
+	size = ALIGN(__size + sizeof(u32), sizeof(u64));
+	size -= sizeof(u32);
+	if (WARN_ONCE(size > PERF_MAX_TRACE_SIZE,
+		     "profile buffer not large enough"))
+		return;
+
+	entry = perf_trace_buf_prepare(size, call->event.type, regs, &rctx);
+	if (!entry)
+		return;
+
+	entry->ip = uprobes_get_bkpt_addr(task_pt_regs(current));
+	data = (u8 *)&entry[1];
+	for (i = 0; i < tp->nr_args; i++)
+		call_fetch(&tp->args[i].fetch, regs,
+						data + tp->args[i].offset);
+
+	head = this_cpu_ptr(call->perf_events);
+	perf_trace_buf_submit(entry, size, rctx, entry->ip, 1, regs, head);
+}
+
+static int probe_perf_enable(struct ftrace_event_call *call)
+{
+	struct uprobe_trace_consumer *utc;
+	struct trace_uprobe *tp = (struct trace_uprobe *)call->data;
+	int ret = 0;
+
+	if (!tp->inode || tp->consumer)
+		return -EINTR;
+
+	utc = kzalloc(sizeof(struct uprobe_trace_consumer), GFP_KERNEL);
+	if (!utc)
+		return -EINTR;
+
+	utc->cons.handler = uprobe_dispatcher;
+	utc->cons.filter = NULL;
+	ret = register_uprobe(tp->inode, tp->offset, &utc->cons);
+	if (ret) {
+		kfree(utc);
+		return ret;
+	}
+
+	tp->flags |= TP_FLAG_PROFILE;
+	tp->consumer = utc;
+	utc->tp = tp;
+	return 0;
+}
+
+static void probe_perf_disable(struct ftrace_event_call *call)
+{
+	struct trace_uprobe *tp = (struct trace_uprobe *)call->data;
+
+	if (!tp->inode || !tp->consumer)
+		return;
+
+	unregister_uprobe(tp->inode, tp->offset, &tp->consumer->cons);
+	tp->flags &= ~TP_FLAG_PROFILE;
+	kfree(tp->consumer);
+	tp->consumer = NULL;
+}
+#endif	/* CONFIG_PERF_EVENTS */
+
+static
+int uprobe_register(struct ftrace_event_call *event, enum trace_reg type)
+{
+	switch (type) {
+	case TRACE_REG_REGISTER:
+		return probe_event_enable(event);
+	case TRACE_REG_UNREGISTER:
+		probe_event_disable(event);
+		return 0;
+
+#ifdef CONFIG_PERF_EVENTS
+	case TRACE_REG_PERF_REGISTER:
+		return probe_perf_enable(event);
+	case TRACE_REG_PERF_UNREGISTER:
+		probe_perf_disable(event);
+		return 0;
+#endif
+	}
+	return 0;
+}
+
+static int uprobe_dispatcher(struct uprobe_consumer *con, struct pt_regs *regs)
+{
+	struct uprobe_trace_consumer *utc;
+	struct trace_uprobe *tp;
+
+	utc = container_of(con, struct uprobe_trace_consumer, cons);
+	tp = utc->tp;
+	if (!tp || tp->consumer != utc)
+		return 0;
+
+	if (tp->flags & TP_FLAG_TRACE)
+		uprobe_trace_func(tp, regs);
+#ifdef CONFIG_PERF_EVENTS
+	if (tp->flags & TP_FLAG_PROFILE)
+		uprobe_perf_func(tp, regs);
+#endif
+	return 0;
+}
+
+
+static struct trace_event_functions uprobe_funcs = {
+	.trace		= print_uprobe_event
+};
+
+static int register_uprobe_event(struct trace_uprobe *tp)
+{
+	struct ftrace_event_call *call = &tp->call;
+	int ret;
+
+	/* Initialize ftrace_event_call */
+	INIT_LIST_HEAD(&call->class->fields);
+	call->event.funcs = &uprobe_funcs;
+	call->class->define_fields = uprobe_event_define_fields;
+	if (set_print_fmt(tp) < 0)
+		return -ENOMEM;
+	ret = register_ftrace_event(&call->event);
+	if (!ret) {
+		kfree(call->print_fmt);
+		return -ENODEV;
+	}
+	call->flags = 0;
+	call->class->reg = uprobe_register;
+	call->data = tp;
+	ret = trace_add_event_call(call);
+	if (ret) {
+		pr_info("Failed to register uprobe event: %s\n", call->name);
+		kfree(call->print_fmt);
+		unregister_ftrace_event(&call->event);
+	}
+	return ret;
+}
+
+static void unregister_uprobe_event(struct trace_uprobe *tp)
+{
+	/* tp->event is unregistered in trace_remove_event_call() */
+	trace_remove_event_call(&tp->call);
+	kfree(tp->call.print_fmt);
+	tp->call.print_fmt = NULL;
+}
+
+/* Make a trace interface for controling probe points */
+static __init int init_uprobe_trace(void)
+{
+	struct dentry *d_tracer;
+	struct dentry *entry;
+
+	d_tracer = tracing_init_dentry();
+	if (!d_tracer)
+		return 0;
+
+	entry = trace_create_file("uprobe_events", 0644, d_tracer,
+				    NULL, &uprobe_events_ops);
+	/* Profile interface */
+	entry = trace_create_file("uprobe_profile", 0444, d_tracer,
+				    NULL, &uprobe_profile_ops);
+	return 0;
+}
+fs_initcall(init_uprobe_trace);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
