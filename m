Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 812426B0092
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 18:21:17 -0400 (EDT)
Date: Fri, 6 Apr 2012 00:20:46 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 1/6] uprobes: introduce find_active_uprobe()
Message-ID: <20120405222046.GA19166@redhat.com>
References: <20120405222024.GA19154@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120405222024.GA19154@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

No functional changes. Move the "find uprobe" code from
handle_swbp() to the new helper, find_active_uprobe().

Note: with or without this change, the find-active-uprobe logic
is not exactly right. We can race with another thread which unmaps
the memory with the valid uprobe before we take mm->mmap_sem. We
can't find this uprobe simply because find_vma() fails. In this
case we wrongly assume that this trap was not caused by uprobe
and send the erroneous SIGTRAP.
---
 kernel/events/uprobes.c |   31 +++++++++++++++++++------------
 1 files changed, 19 insertions(+), 12 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 29e881b..3d0a4d6 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -1474,21 +1474,12 @@ static bool can_skip_sstep(struct uprobe *uprobe, struct pt_regs *regs)
 	return false;
 }
 
-/*
- * Run handler and ask thread to singlestep.
- * Ensure all non-fatal signals cannot interrupt thread while it singlesteps.
- */
-static void handle_swbp(struct pt_regs *regs)
+static struct uprobe *find_active_uprobe(unsigned long bp_vaddr)
 {
+	struct mm_struct *mm = current->mm;
+	struct uprobe *uprobe = NULL;
 	struct vm_area_struct *vma;
-	struct uprobe_task *utask;
-	struct uprobe *uprobe;
-	struct mm_struct *mm;
-	unsigned long bp_vaddr;
 
-	uprobe = NULL;
-	bp_vaddr = uprobe_get_swbp_addr(regs);
-	mm = current->mm;
 	down_read(&mm->mmap_sem);
 	vma = find_vma(mm, bp_vaddr);
 
@@ -1506,6 +1497,22 @@ static void handle_swbp(struct pt_regs *regs)
 	current->uprobe_srcu_id = -1;
 	up_read(&mm->mmap_sem);
 
+	return uprobe;
+}
+
+/*
+ * Run handler and ask thread to singlestep.
+ * Ensure all non-fatal signals cannot interrupt thread while it singlesteps.
+ */
+static void handle_swbp(struct pt_regs *regs)
+{
+	struct uprobe_task *utask;
+	struct uprobe *uprobe;
+	unsigned long bp_vaddr;
+
+	bp_vaddr = uprobe_get_swbp_addr(regs);
+	uprobe = find_active_uprobe(bp_vaddr);
+
 	if (!uprobe) {
 		/* No matching uprobe; signal SIGTRAP. */
 		send_sig(SIGTRAP, current, 0);
-- 
1.5.5.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
