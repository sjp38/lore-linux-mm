Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 18BC78D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 10:45:49 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp06.au.ibm.com (8.14.4/8.13.1) with ESMTP id p31EjXZ5029113
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:45:33 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p31EjioM1519784
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:45:44 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p31EjgSZ028425
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:45:43 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 01 Apr 2011 20:06:02 +0530
Message-Id: <20110401143602.15455.82211.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v3 2.6.39-rc1-tip 18/26] 18: uprobes: commonly used filters.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>


Provides most commonly used filters that most users of uprobes can
reuse.  However this would be useful once we can dynamically associate a
filter with a uprobe-event tracer.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/uprobes.h |    5 +++++
 kernel/uprobes.c        |   50 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 55 insertions(+), 0 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 26c4d78..34b989f 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -65,6 +65,11 @@ struct uprobe_consumer {
 	struct uprobe_consumer *next;
 };
 
+struct uprobe_simple_consumer {
+	struct uprobe_consumer consumer;
+	pid_t fvalue;
+};
+
 struct uprobe {
 	struct rb_node		rb_node;	/* node in the rb tree */
 	atomic_t		ref;
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index cdd52d0..c950f13 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -1389,6 +1389,56 @@ int uprobe_post_notifier(struct pt_regs *regs)
 	return 0;
 }
 
+bool uprobes_pid_filter(struct uprobe_consumer *self, struct task_struct *t)
+{
+	struct uprobe_simple_consumer *usc;
+
+	usc = container_of(self, struct uprobe_simple_consumer, consumer);
+	if (t->tgid == usc->fvalue)
+		return true;
+	return false;
+}
+
+bool uprobes_tid_filter(struct uprobe_consumer *self, struct task_struct *t)
+{
+	struct uprobe_simple_consumer *usc;
+
+	usc = container_of(self, struct uprobe_simple_consumer, consumer);
+	if (t->pid == usc->fvalue)
+		return true;
+	return false;
+}
+
+bool uprobes_ppid_filter(struct uprobe_consumer *self, struct task_struct *t)
+{
+	pid_t pid;
+	struct uprobe_simple_consumer *usc;
+
+	usc = container_of(self, struct uprobe_simple_consumer, consumer);
+	rcu_read_lock();
+	pid = task_tgid_vnr(t->real_parent);
+	rcu_read_unlock();
+
+	if (pid == usc->fvalue)
+		return true;
+	return false;
+}
+
+bool uprobes_sid_filter(struct uprobe_consumer *self, struct task_struct *t)
+{
+	pid_t pid;
+	struct uprobe_simple_consumer *usc;
+
+	usc = container_of(self, struct uprobe_simple_consumer, consumer);
+	rcu_read_lock();
+	pid = pid_vnr(task_session(t));
+	rcu_read_unlock();
+
+	if (pid == usc->fvalue)
+		return true;
+	return false;
+}
+
 struct notifier_block uprobes_exception_nb = {
 	.notifier_call = uprobes_exception_notify,
 	.priority = 0x7ffffff0,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
