Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id DD5DA6B00ED
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 09:08:01 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp08.in.ibm.com (8.14.4/8.13.1) with ESMTP id p57Cw9u0030115
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 18:28:09 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p57D7vOR3981452
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 18:37:57 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p57D7unf010063
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 23:07:57 +1000
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Tue, 07 Jun 2011 18:31:11 +0530
Message-Id: <20110607130111.28590.12029.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v4 3.0-rc2-tip 15/22] 15: uprobes: register a notifier for uprobes.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>


Uprobe needs to be intimated on int3 and singlestep exceptions.
Hence uprobes registers a die notifier so that its notified of the events.

Signed-off-by: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 kernel/uprobes.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index 1e88d64..95c16dd 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -36,6 +36,7 @@
 #include <linux/mman.h>	/* needed for PROT_EXEC, MAP_PRIVATE */
 #include <linux/file.h> /* needed for fput() */
 #include <linux/init_task.h> /* init_cred */
+#include <linux/kdebug.h> /* for notifier mechanism */
 
 #define UINSNS_PER_PAGE	(PAGE_SIZE/UPROBES_XOL_SLOT_BYTES)
 #define MAX_UPROBES_XOL_SLOTS UINSNS_PER_PAGE
@@ -1456,3 +1457,20 @@ int uprobe_post_notifier(struct pt_regs *regs)
 	set_thread_flag(TIF_UPROBE);
 	return 1;
 }
+
+struct notifier_block uprobe_exception_nb = {
+	.notifier_call = uprobe_exception_notify,
+	.priority = INT_MAX - 1,	/* notified after kprobes, kgdb */
+};
+
+static int __init init_uprobes(void)
+{
+	return register_die_notifier(&uprobe_exception_nb);
+}
+
+static void __exit exit_uprobes(void)
+{
+}
+
+module_init(init_uprobes);
+module_exit(exit_uprobes);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
