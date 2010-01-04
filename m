Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D9C796005A4
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 15:49:32 -0500 (EST)
Message-Id: <20100104182813.390611101@chello.nl>
References: <20100104182429.833180340@chello.nl>
Date: Mon, 04 Jan 2010 19:24:32 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 3/8] mm: Add vma sequence count
Content-Disposition: inline; filename=mm-foo-5.patch
Sender: owner-linux-mm@kvack.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

In order to detect VMA range changes, add a sequence count.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/mm_types.h |    2 ++
 mm/mmap.c                |   10 ++++++++++
 2 files changed, 12 insertions(+)

Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h
+++ linux-2.6/include/linux/mm_types.h
@@ -12,6 +12,7 @@
 #include <linux/completion.h>
 #include <linux/cpumask.h>
 #include <linux/page-debug-flags.h>
+#include <linux/seqlock.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -186,6 +187,7 @@ struct vm_area_struct {
 #ifdef CONFIG_NUMA
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
+	seqcount_t vm_sequence;
 };
 
 struct core_thread {
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c
+++ linux-2.6/mm/mmap.c
@@ -512,6 +512,10 @@ void vma_adjust(struct vm_area_struct *v
 	long adjust_next = 0;
 	int remove_next = 0;
 
+	write_seqcount_begin(&vma->vm_sequence);
+	if (next)
+		write_seqcount_begin(&next->vm_sequence);
+
 	if (next && !insert) {
 		if (end >= next->vm_end) {
 			/*
@@ -647,11 +651,17 @@ again:			remove_next = 1 + (end > next->
 		 * up the code too much to do both in one go.
 		 */
 		if (remove_next == 2) {
+			write_seqcount_end(&next->vm_sequence);
 			next = vma->vm_next;
+			write_seqcount_begin(&next->vm_sequence);
 			goto again;
 		}
 	}
 
+	if (next)
+		write_seqcount_end(&next->vm_sequence);
+	write_seqcount_end(&vma->vm_sequence);
+
 	validate_mm(mm);
 }
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
