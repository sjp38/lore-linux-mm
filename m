Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B5B19900001
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 09:08:41 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp04.au.ibm.com (8.14.4/8.13.1) with ESMTP id p57D2ZYs012908
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 23:02:35 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p57D8cI11069074
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 23:08:38 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p57D8aOf029650
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 23:08:37 +1000
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Tue, 07 Jun 2011 18:31:46 +0530
Message-Id: <20110607130146.28590.71921.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v4 3.0-rc2-tip 18/22] 18: tracing: Uprobe tracer documentation
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>


Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 Documentation/trace/uprobetrace.txt |   94 +++++++++++++++++++++++++++++++++++
 1 files changed, 94 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/trace/uprobetrace.txt

diff --git a/Documentation/trace/uprobetrace.txt b/Documentation/trace/uprobetrace.txt
new file mode 100644
index 0000000..6c18ffe
--- /dev/null
+++ b/Documentation/trace/uprobetrace.txt
@@ -0,0 +1,94 @@
+		Uprobe-tracer: Uprobe-based Event Tracing
+		=========================================
+                 Documentation is written by Srikar Dronamraju
+
+Overview
+--------
+These events are similar to kprobe based events.
+To enable this feature, build your kernel with CONFIG_UPROBE_EVENTS=y.
+
+Similar to the kprobe-event tracer, this doesn't need to be activated via
+current_tracer. Instead of that, add probe points via
+/sys/kernel/debug/tracing/uprobe_events, and enable it via
+/sys/kernel/debug/tracing/events/uprobes/<EVENT>/enabled.
+
+
+Synopsis of uprobe_tracer
+-------------------------
+  p[:[GRP/]EVENT] PATH:SYMBOL[+offs] [FETCHARGS]	: Set a probe
+
+ GRP		: Group name. If omitted, use "uprobes" for it.
+ EVENT		: Event name. If omitted, the event name is generated
+		  based on SYMBOL+offs.
+ PATH		: path to an executable or a library.
+ SYMBOL[+offs]	: Symbol+offset where the probe is inserted.
+
+ FETCHARGS	: Arguments. Each probe can have up to 128 args.
+  %REG		: Fetch register REG
+
+Event Profiling
+---------------
+ You can check the total number of probe hits and probe miss-hits via
+/sys/kernel/debug/tracing/uprobe_profile.
+ The first column is event name, the second is the number of probe hits,
+the third is the number of probe miss-hits.
+
+Usage examples
+--------------
+To add a probe as a new event, write a new definition to uprobe_events
+as below.
+
+  echo 'p: /bin/bash:0x4245c0' > /sys/kernel/debug/tracing/uprobe_events
+
+ This sets a uprobe at an offset of 0x4245c0 in the executable /bin/bash
+
+
+  echo > /sys/kernel/debug/tracing/uprobe_events
+
+ This clears all probe points.
+
+The following example shows how to dump the instruction pointer and %ax
+a register at the probed text address.  Here we are trying to probe
+function zfree in /bin/zsh
+
+    # cd /sys/kernel/debug/tracing/
+    # cat /proc/`pgrep  zsh`/maps | grep /bin/zsh | grep r-xp
+    00400000-0048a000 r-xp 00000000 08:03 130904 /bin/zsh
+    # objdump -T /bin/zsh | grep -w zfree
+    0000000000446420 g    DF .text  0000000000000012  Base        zfree
+
+0x46420 is the offset of zfree in object /bin/zsh that is loaded at
+0x00400000. Hence the command to probe would be :
+
+    # echo 'p /bin/zsh:0x46420 %ip %ax' > uprobe_events
+
+We can see the events that are registered by looking at the uprobe_events
+file.
+
+    # cat uprobe_events
+    p:uprobes/p_zsh_0x46420 /bin/zsh:0x0000000000046420
+
+Right after definition, each event is disabled by default. For tracing these
+events, you need to enable it by:
+
+    # echo 1 > events/uprobes/enable
+
+Lets disable the event after sleeping for some time.
+    # sleep 20
+    # echo 0 > events/uprobes/enable
+
+And you can see the traced information via /sys/kernel/debug/tracing/trace.
+
+    # cat trace
+    # tracer: nop
+    #
+    #           TASK-PID    CPU#    TIMESTAMP  FUNCTION
+    #              | |       |          |         |
+                 zsh-24842 [006] 258544.995456: p_zsh_0x46420: (0x446420) arg1=446421 arg2=79
+                 zsh-24842 [007] 258545.000270: p_zsh_0x46420: (0x446420) arg1=446421 arg2=79
+                 zsh-24842 [002] 258545.043929: p_zsh_0x46420: (0x446420) arg1=446421 arg2=79
+                 zsh-24842 [004] 258547.046129: p_zsh_0x46420: (0x446420) arg1=446421 arg2=79
+
+Each line shows us probes were triggered for a pid 24842 with ip being
+0x446421 and contents of ax register being 79.
+

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
