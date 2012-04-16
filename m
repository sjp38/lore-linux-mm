Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id A91276B00F8
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 08:17:24 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 16 Apr 2012 17:47:19 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3GCHKSd4800616
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 17:47:20 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3GHl1FC020603
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 23:17:02 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Mon, 16 Apr 2012 17:39:25 +0530
Message-Id: <20120416120925.30661.40409.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20120416120909.30661.99781.sendpatchset@srdronam.in.ibm.com>
References: <20120416120909.30661.99781.sendpatchset@srdronam.in.ibm.com>
Subject: [RFC] [PATCH 2/2] perf/probe: Detect probe target when m/x options are absent
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

Options -m and -x explicitly allow tracing of modules / user space
binaries. In absense of these options, check if the first argument
can be used as a target.

perf probe /bin/zsh zfree is equivalent to perf probe -x /bin/zsh
zfree.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 tools/perf/Documentation/perf-probe.txt |    8 ++++--
 tools/perf/builtin-probe.c              |   43 +++++++++++++++++++++++++++++--
 2 files changed, 46 insertions(+), 5 deletions(-)

diff --git a/tools/perf/Documentation/perf-probe.txt b/tools/perf/Documentation/perf-probe.txt
index fb673be..51205f0 100644
--- a/tools/perf/Documentation/perf-probe.txt
+++ b/tools/perf/Documentation/perf-probe.txt
@@ -104,6 +104,10 @@ OPTIONS
 	Specify path to the executable or shared library file for user
 	space tracing. Can also be used with --funcs option.
 
+In absence of -m/-x options, perf probe checks if the first argument after
+the options is an absolute path name. If its an absolute path, perf probe
+uses it as a target module/target user space binary to probe.
+
 PROBE SYNTAX
 ------------
 Probe points are defined by following syntax.
@@ -190,11 +194,11 @@ Delete all probes on schedule().
 
 Add probes at zfree() function on /bin/zsh
 
- ./perf probe -x /bin/zsh zfree
+ ./perf probe -x /bin/zsh zfree or ./perf probe /bin/zsh zfree
 
 Add probes at malloc() function on libc
 
- ./perf probe -x /lib/libc.so.6 malloc
+ ./perf probe -x /lib/libc.so.6 malloc or ./perf probe /lib/libc.so.6 malloc
 
 SEE ALSO
 --------
diff --git a/tools/perf/builtin-probe.c b/tools/perf/builtin-probe.c
index ee3d84a..e215ae6 100644
--- a/tools/perf/builtin-probe.c
+++ b/tools/perf/builtin-probe.c
@@ -85,21 +85,58 @@ static int parse_probe_event(const char *str)
 	return ret;
 }
 
+static int set_target(const char *ptr)
+{
+	int found = 0;
+	const char *buf;
+
+	/*
+	 * The first argument after options can be an absolute path
+	 * to an executable / library or kernel module.
+	 *
+	 * TODO: Support relative path, and $PATH, $LD_LIBRARY_PATH,
+	 * short module name.
+	 */
+	if (!params.target && ptr && *ptr == '/') {
+		params.target = ptr;
+		found = 1;
+		buf = ptr + (strlen(ptr) - 3);
+
+		if (strcmp(buf, ".ko"))
+			params.uprobes = true;
+
+	}
+
+	return found;
+}
+
 static int parse_probe_event_argv(int argc, const char **argv)
 {
-	int i, len, ret;
+	int i, len, ret, found_target;
 	char *buf;
 
+	found_target = set_target(argv[0]);
+	if (found_target && argc == 1)
+		return 0;
+
 	/* Bind up rest arguments */
 	len = 0;
-	for (i = 0; i < argc; i++)
+	for (i = 0; i < argc; i++) {
+		if (i == 0 && found_target)
+			continue;
+
 		len += strlen(argv[i]) + 1;
+	}
 	buf = zalloc(len + 1);
 	if (buf == NULL)
 		return -ENOMEM;
 	len = 0;
-	for (i = 0; i < argc; i++)
+	for (i = 0; i < argc; i++) {
+		if (i == 0 && found_target)
+			continue;
+
 		len += sprintf(&buf[len], "%s ", argv[i]);
+	}
 	params.mod_events = true;
 	ret = parse_probe_event(buf);
 	free(buf);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
