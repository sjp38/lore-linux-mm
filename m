Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 5343D6B00E9
	for <linux-mm@kvack.org>; Mon, 14 May 2012 09:41:41 -0400 (EDT)
Date: Mon, 14 May 2012 06:41:15 -0700
From: tip-bot for Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Message-ID: <tip-73eff9f56e15598c8399c0b86899fd889b97f085@git.kernel.org>
Reply-To: mingo@kernel.org, acme@redhat.com, torvalds@linux-foundation.org,
        peterz@infradead.org, anton@redhat.com, rostedt@goodmis.org,
        jkenisto@linux.vnet.ibm.com, akpm@linux-foundation.org,
        tglx@linutronix.de, oleg@redhat.com, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, hpa@zytor.com, andi@firstfloor.org,
        hch@infradead.org, ananth@in.ibm.com, masami.hiramatsu.pt@hitachi.com,
        srikar@linux.vnet.ibm.com, mingo@elte.hu
In-Reply-To: <20120416120925.30661.40409.sendpatchset@srdronam.in.ibm.com>
References: <20120416120925.30661.40409.sendpatchset@srdronam.in.ibm.com>
Subject: [tip:perf/uprobes] perf probe: Detect probe target when m/
 x options are absent
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: acme@redhat.com, mingo@kernel.org, torvalds@linux-foundation.org, peterz@infradead.org, anton@redhat.com, rostedt@goodmis.org, jkenisto@linux.vnet.ibm.com, akpm@linux-foundation.org, oleg@redhat.com, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hpa@zytor.com, andi@firstfloor.org, hch@infradead.org, ananth@in.ibm.com, masami.hiramatsu.pt@hitachi.com, srikar@linux.vnet.ibm.com, mingo@elte.hu

Commit-ID:  73eff9f56e15598c8399c0b86899fd889b97f085
Gitweb:     http://git.kernel.org/tip/73eff9f56e15598c8399c0b86899fd889b97f085
Author:     Srikar Dronamraju <srikar@linux.vnet.ibm.com>
AuthorDate: Mon, 16 Apr 2012 17:39:25 +0530
Committer:  Arnaldo Carvalho de Melo <acme@redhat.com>
CommitDate: Fri, 11 May 2012 13:58:53 -0300

perf probe: Detect probe target when m/x options are absent

Options -m and -x explicitly allow tracing of modules / user space
binaries. In absense of these options, check if the first argument can
be used as a target.

perf probe /bin/zsh zfree is equivalent to perf probe -x /bin/zsh zfree.

Suggested-by: Arnaldo Carvalho de Melo <acme@redhat.com>
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
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Link: http://lkml.kernel.org/r/20120416120925.30661.40409.sendpatchset@srdronam.in.ibm.com
Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 tools/perf/Documentation/perf-probe.txt |    8 ++++-
 tools/perf/builtin-probe.c              |   43 ++++++++++++++++++++++++++++--
 2 files changed, 46 insertions(+), 5 deletions(-)

diff --git a/tools/perf/Documentation/perf-probe.txt b/tools/perf/Documentation/perf-probe.txt
index fb673be..b715cb7 100644
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
