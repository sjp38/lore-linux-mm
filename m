Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 21D908D003E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 09:43:21 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp03.in.ibm.com (8.14.4/8.13.1) with ESMTP id p2EDhFVI009252
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:13:15 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2EDhFSo344140
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:13:15 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2EDhFcp025717
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:13:16 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Mon, 14 Mar 2011 19:07:35 +0530
Message-Id: <20110314133735.27435.21582.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v2 2.6.38-rc8-tip 18/20] 18: uprobes: commonly used filters.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>


Provides most commonly used filters that most users of uprobes can
reuse.  However this would be useful once we can dynamically associate a
filter with a uprobe-event tracer.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/uprobes.h |    5 +++++
 kernel/uprobes.c        |   50 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 55 insertions(+), 0 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index b7fd925..a7a8d5a 100644
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
index e3a3051..328053e 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -1262,6 +1262,56 @@ int uprobe_post_notifier(struct pt_regs *regs)
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
