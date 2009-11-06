Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 211A86B004D
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 13:55:08 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B20E782C4A9
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 14:01:56 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 4r8uYYz+xKgP for <linux-mm@kvack.org>;
	Fri,  6 Nov 2009 14:01:56 -0500 (EST)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8AEBC82C475
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 14:01:50 -0500 (EST)
Date: Fri, 6 Nov 2009 13:53:35 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [RFC MM] mmap_sem scaling: only scan cpus used by an mm
In-Reply-To: <20091106073946.GV31511@one.firstfloor.org>
Message-ID: <alpine.DEB.1.10.0911061352320.22205@V090114053VZO-1>
References: <alpine.DEB.1.10.0911051417370.24312@V090114053VZO-1> <alpine.DEB.1.10.0911051419320.24312@V090114053VZO-1> <87r5sc7kst.fsf@basil.nowhere.org> <alpine.DEB.1.10.0911051558220.7668@V090114053VZO-1> <20091106073946.GV31511@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

One way to reduce the cost of the writer lock is to track the cpus used
and loop over the processors in that bitmap.

---
 arch/x86/include/asm/mmu_context.h |    1 +
 include/linux/mm_types.h           |    3 ++-
 kernel/fork.c                      |    2 ++
 mm/init-mm.c                       |    1 +
 4 files changed, 6 insertions(+), 1 deletion(-)

Index: linux-2.6/arch/x86/include/asm/mmu_context.h
===================================================================
--- linux-2.6.orig/arch/x86/include/asm/mmu_context.h	2009-11-06 12:26:24.000000000 -0600
+++ linux-2.6/arch/x86/include/asm/mmu_context.h	2009-11-06 12:26:36.000000000 -0600
@@ -43,6 +43,7 @@ static inline void switch_mm(struct mm_s
 		percpu_write(cpu_tlbstate.active_mm, next);
 #endif
 		cpumask_set_cpu(cpu, mm_cpumask(next));
+		cpumask_set_cpu(cpu, &next->cpus_used);

 		/* Re-load page tables */
 		load_cr3(next->pgd);
Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h	2009-11-06 12:26:35.000000000 -0600
+++ linux-2.6/include/linux/mm_types.h	2009-11-06 12:26:36.000000000 -0600
@@ -241,6 +241,7 @@ struct mm_struct {
 	struct linux_binfmt *binfmt;

 	cpumask_t cpu_vm_mask;
+	cpumask_t cpus_used;

 	/* Architecture-specific MM context */
 	mm_context_t context;
@@ -291,7 +292,7 @@ static inline int mm_has_reader(struct m
 {
 	int cpu;

-	for_each_possible_cpu(cpu)
+	for_each_cpu(cpu, &mm->cpus_used)
 		if (per_cpu(mm->rss->readers, cpu))
 			return 1;

Index: linux-2.6/mm/init-mm.c
===================================================================
--- linux-2.6.orig/mm/init-mm.c	2009-11-06 12:26:35.000000000 -0600
+++ linux-2.6/mm/init-mm.c	2009-11-06 12:26:36.000000000 -0600
@@ -19,5 +19,6 @@ struct mm_struct init_mm = {
 	.page_table_lock =  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
 	.mmlist		= LIST_HEAD_INIT(init_mm.mmlist),
 	.cpu_vm_mask	= CPU_MASK_ALL,
+	.cpus_used	= CPU_MASK_ALL,
 	.rss		= &init_mm_counters,
 };
Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c	2009-11-06 12:26:35.000000000 -0600
+++ linux-2.6/kernel/fork.c	2009-11-06 12:26:40.000000000 -0600
@@ -297,6 +297,8 @@ static int dup_mmap(struct mm_struct *mm
 	mm->cached_hole_size = ~0UL;
 	mm->map_count = 0;
 	cpumask_clear(mm_cpumask(mm));
+	cpumask_clear(&mm->cpus_used);
+	cpumask_set_cpu(smp_processor_id(), &mm->cpus_used);
 	mm->mm_rb = RB_ROOT;
 	rb_link = &mm->mm_rb.rb_node;
 	rb_parent = NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
