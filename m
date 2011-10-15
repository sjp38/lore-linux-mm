Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C0BA06B002F
	for <linux-mm@kvack.org>; Sat, 15 Oct 2011 15:06:06 -0400 (EDT)
Date: Sat, 15 Oct 2011 21:01:48 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 5/X] uprobes: xol_alloc_area() needs memory barriers
Message-ID: <20111015190148.GF30243@redhat.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20111015190007.GA30243@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111015190007.GA30243@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

If xol_get_insn_slot() or xol_alloc_area() races with another thread
doing xol_add_vma() it is not safe to dereference ->uprobes_xol_area.

Add the necessary wmb/read_barrier_depends pair, this ensures that
xol_get_insn_slot() always sees the properly initialized memory.

Other users of ->uprobes_xol_area look fine, they can't race with
xol_add_vma() this way. xol_free_insn_slot() checks utask->xol_vaddr,
and free_uprobes_xol_area() is calles by mmput().

Except: valid_vma() is racy but it should not use ->uprobes_xol_area
as we discussed.
---
 kernel/uprobes.c |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index 5c2554c..b59af3b 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -1087,6 +1087,7 @@ static int xol_add_vma(struct uprobes_xol_area *area)
 	}
 
 	area->vaddr = addr;
+	smp_wmb();	/* pairs with get_uprobes_xol_area() */
 	mm->uprobes_xol_area = area;
 	ret = 0;
 fail:
@@ -1094,6 +1095,14 @@ fail:
 	return ret;
 }
 
+static inline
+struct uprobes_xol_area *get_uprobes_xol_area(struct mm_struct *mm)
+{
+	struct uprobes_xol_area *area = mm->uprobes_xol_area;
+	smp_read_barrier_depends();	/* pairs with wmb in xol_add_vma() */
+	return area;
+}
+
 /*
  * xol_alloc_area - Allocate process's uprobes_xol_area.
  * This area will be used for storing instructions for execution out of
@@ -1124,7 +1133,7 @@ static struct uprobes_xol_area *xol_alloc_area(void)
 fail:
 	kfree(area->bitmap);
 	kfree(area);
-	return current->mm->uprobes_xol_area;
+	return get_uprobes_xol_area(current->mm);
 }
 
 /*
@@ -1183,17 +1192,17 @@ static unsigned long xol_take_insn_slot(struct uprobes_xol_area *area)
 static unsigned long xol_get_insn_slot(struct uprobe *uprobe,
 					unsigned long slot_addr)
 {
-	struct uprobes_xol_area *area = current->mm->uprobes_xol_area;
+	struct uprobes_xol_area *area;
 	unsigned long offset;
 	void *vaddr;
 
+	area = get_uprobes_xol_area(current->mm);
 	if (!area) {
 		area = xol_alloc_area();
 		if (!area)
 			return 0;
 	}
 	current->utask->xol_vaddr = xol_take_insn_slot(area);
-
 	/*
 	 * Initialize the slot if xol_vaddr points to valid
 	 * instruction slot.
-- 
1.5.5.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
