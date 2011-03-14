Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 110CA8D003E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 09:44:17 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp02.au.ibm.com (8.14.4/8.13.1) with ESMTP id p2EDbhXa007727
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 00:37:43 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2EDh5Id2039982
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 00:43:05 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2EDh3IN005865
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 00:43:04 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Mon, 14 Mar 2011 19:07:22 +0530
Message-Id: <20110314133722.27435.55663.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v2 2.6.38-rc8-tip 17/20] 17: uprobes: filter chain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>


Loops through the filters callbacks of currently registered
consumers to see if any consumer is interested in tracing this task.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 kernel/uprobes.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index bbedcef..e3a3051 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -428,6 +428,24 @@ static void handler_chain(struct uprobe *uprobe, struct pt_regs *regs)
 }
 
 /* Acquires uprobe->consumer_rwsem */
+static bool filter_chain(struct uprobe *uprobe, struct task_struct *t)
+{
+	struct uprobe_consumer *consumer;
+	bool ret = false;
+
+	down_read(&uprobe->consumer_rwsem);
+	for (consumer = uprobe->consumers; consumer;
+					consumer = consumer->next) {
+		if (!consumer->filter || consumer->filter(consumer, t)) {
+			ret = true;
+			break;
+		}
+	}
+	up_read(&uprobe->consumer_rwsem);
+	return ret;
+}
+
+/* Acquires uprobe->consumer_rwsem */
 static void add_consumer(struct uprobe *uprobe,
 				struct uprobe_consumer *consumer)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
