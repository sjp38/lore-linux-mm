Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C65CA8D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 10:45:34 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp09.au.ibm.com (8.14.4/8.13.1) with ESMTP id p31EjTOV015134
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:45:29 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p31EjTec2478200
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:45:29 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p31EjSIx013396
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:45:29 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 01 Apr 2011 20:05:48 +0530
Message-Id: <20110401143548.15455.81188.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v3 2.6.39-rc1-tip 17/26] 17: uprobes: register a notifier for uprobes.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>


Uprobe needs to be intimated on int3 and singlestep exceptions.
Hence uprobes registers a die notifier so that its notified of the events.

Signed-off-by: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 kernel/uprobes.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index e0ff6ba..cdd52d0 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -33,6 +33,7 @@
 #include <linux/rmap.h> /* needed for anon_vma_prepare */
 #include <linux/mman.h>	/* needed for PROT_EXEC, MAP_PRIVATE */
 #include <linux/file.h> /* needed for fput() */
+#include <linux/kdebug.h> /* needed for notifier mechanism */
 
 #define UINSNS_PER_PAGE	(PAGE_SIZE/UPROBES_XOL_SLOT_BYTES)
 #define MAX_UPROBES_XOL_SLOTS UINSNS_PER_PAGE
@@ -1387,3 +1388,20 @@ int uprobe_post_notifier(struct pt_regs *regs)
 	}
 	return 0;
 }
+
+struct notifier_block uprobes_exception_nb = {
+	.notifier_call = uprobes_exception_notify,
+	.priority = 0x7ffffff0,
+};
+
+static int __init init_uprobes(void)
+{
+	return register_die_notifier(&uprobes_exception_nb);
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
