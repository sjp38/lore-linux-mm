Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 398576B00EA
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 18:22:33 -0400 (EDT)
Date: Fri, 6 Apr 2012 00:22:03 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 5/6] uprobes: teach handle_swbp() to rely on "is_swbp"
	rather than uprobes_srcu
Message-ID: <20120405222203.GE19166@redhat.com>
References: <20120405222024.GA19154@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120405222024.GA19154@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

Currently handle_swbp() assumes that it can't race with unregister,
so it roughly does:

	if (find_uprobe(vaddr))
		process_uprobe();
	else
		send_sig(SIGTRAP);

This relies on the not-really-working uprobes_srcu code we are going
to remove.

With this patch we rely on the result of is_swbp_at_addr_fast(bp_vaddr)
if find_uprobe() fails.

If is_swbp == 1, then we hit the normal int3, we should send SIGTRAP.

If is_swbp == 0, we raced with uprobe_unregister(), we simply restart
this insn again.

The "difficult" case is is_swbp == -EFAULT, when we can't read this
memory. In this case I think we should restart too, and this is more
correct compared to the current code which sends SIGTRAP.

Ignoring ENOMEM/etc from get_user_pages(), this can only happen if
another thread unmaps this memory before find_active_uprobe() takes
mmap_sem. It would be better to pretend it was unmapped before this
insn was executed, restart, and get SIGSEGV.
---
 kernel/events/uprobes.c |   18 +++++++++++++++---
 1 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 2af458d..ed76ee5 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -1538,14 +1538,26 @@ static void handle_swbp(struct pt_regs *regs)
 	struct uprobe_task *utask;
 	struct uprobe *uprobe;
 	unsigned long bp_vaddr;
-	int is_swbp;
+	int uninitialized_var(is_swbp);
 
 	bp_vaddr = uprobe_get_swbp_addr(regs);
 	uprobe = find_active_uprobe(bp_vaddr, &is_swbp);
 
 	if (!uprobe) {
-		/* No matching uprobe; signal SIGTRAP. */
-		send_sig(SIGTRAP, current, 0);
+		if (is_swbp > 0) {
+			/* No matching uprobe; signal SIGTRAP. */
+			send_sig(SIGTRAP, current, 0);
+		} else {
+			/*
+			 * Either we raced with uprobe_unregister() or we can't
+			 * access this memory. The latter is only possible if
+			 * another thread plays with our ->mm. In both cases
+			 * we can simply restart. If this vma was unmapped we
+			 * can pretend this insn was not executed yet and get
+			 * the (correct) SIGSEGV after restart.
+			 */
+			instruction_pointer_set(regs, bp_vaddr);
+		}
 		return;
 	}
 
-- 
1.5.5.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
