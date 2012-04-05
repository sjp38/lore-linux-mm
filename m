Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 4EDC46B00E7
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 18:21:39 -0400 (EDT)
Date: Fri, 6 Apr 2012 00:21:06 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 2/6] uprobes: introduce is_swbp_at_addr_fast()
Message-ID: <20120405222106.GB19166@redhat.com>
References: <20120405222024.GA19154@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120405222024.GA19154@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

Add the new helper, is_swbp_at_addr_fast(), will be used by
find_active_uprobe().

It is almost the same as is_swbp_at_addr(), but since it plays
with current->mm it can avoid the slow get_user_pages() in the
likely case.
---
 kernel/events/uprobes.c |   23 +++++++++++++++++++++++
 1 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 3d0a4d6..2050b1a 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -1474,6 +1474,29 @@ static bool can_skip_sstep(struct uprobe *uprobe, struct pt_regs *regs)
 	return false;
 }
 
+int __weak is_swbp_at_addr_fast(unsigned long vaddr)
+{
+	uprobe_opcode_t opcode;
+	int fault;
+
+	pagefault_disable();
+	fault = __copy_from_user_inatomic(&opcode, (void __user*)vaddr,
+							sizeof(opcode));
+	pagefault_enable();
+
+	if (unlikely(fault)) {
+		/*
+		 * XXX: read_opcode() lacks FOLL_FORCE, it can fail if
+		 * we race with another thread which does mprotect(NONE)
+		 * after we hit bp.
+		 */
+		if (read_opcode(current->mm, vaddr, &opcode))
+			return -EFAULT;
+	}
+
+	return is_swbp_insn(&opcode);
+}
+
 static struct uprobe *find_active_uprobe(unsigned long bp_vaddr)
 {
 	struct mm_struct *mm = current->mm;
-- 
1.5.5.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
