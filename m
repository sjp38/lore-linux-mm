Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AFE876B002E
	for <linux-mm@kvack.org>; Sun, 16 Oct 2011 12:18:50 -0400 (EDT)
Date: Sun, 16 Oct 2011 18:14:29 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 7/X] uprobes: xol_add_vma: simply use TASK_SIZE as a hint
Message-ID: <20111016161429.GB24893@redhat.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20111015190007.GA30243@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111015190007.GA30243@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

I don't understand why xol_add_vma() abuses mm->mm_rb to find the
highest mapping. We can simply use TASK_SIZE-PAGE_SIZE a hint.

If this area is already occupied, the hint will be ignored with
or without this change. Otherwise the result is "obviously better"
and the code becomes simpler.

---

 kernel/uprobes.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index 038f21c..b876977 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -1045,9 +1045,7 @@ void munmap_uprobe(struct vm_area_struct *vma)
 /* Slot allocation for XOL */
 static int xol_add_vma(struct uprobes_xol_area *area)
 {
-	struct vm_area_struct *vma;
 	struct mm_struct *mm;
-	unsigned long addr_hint;
 	int ret;
 
 	area->page = alloc_page(GFP_HIGHUSER);
@@ -1060,15 +1058,12 @@ static int xol_add_vma(struct uprobes_xol_area *area)
 	ret = -EALREADY;
 	if (mm->uprobes_xol_area)
 		goto fail;
+
 	/*
-	 * Find the end of the top mapping and skip a page.
-	 * If there is no space for PAGE_SIZE above that,
-	 * this hint will be ignored.
+	 * Try to map as high as possible, this is only a hint.
 	 */
-	vma = rb_entry(rb_last(&mm->mm_rb), struct vm_area_struct, vm_rb);
-	addr_hint = vma->vm_end + PAGE_SIZE;
-
-	area->vaddr = get_unmapped_area(NULL, addr_hint, PAGE_SIZE, 0, 0);
+	area->vaddr = get_unmapped_area(NULL, TASK_SIZE - PAGE_SIZE,
+					PAGE_SIZE, 0, 0);
 	if (IS_ERR_VALUE(area->vaddr)) {
 		ret = area->vaddr;
 		goto fail;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
