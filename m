Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 68A62900149
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 09:12:19 -0400 (EDT)
Subject: Re: [PATCH] mm, arch: Complete pagefault_disable abstraction
From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 05 Oct 2011 15:12:14 +0200
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317820334.6766.23.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>

For those with a strong stomach, here's what we do with kmap_atomic:

---
Subject: mm, rt: kmap_atomic scheduling
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 28 Jul 2011 10:43:51 +0200

In fact, with migrate_disable() existing one could play games with
kmap_atomic. You could save/restore the kmap_atomic slots on context
switch (if there are any in use of course), this should be esp easy now
that we have a kmap_atomic stack.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
[dvhart@linux.intel.com: build fix]
Link: http://lkml.kernel.org/r/1311842631.5890.208.camel@twins
---
 arch/x86/kernel/process_32.c |   36 ++++++++++++++++++++++++++++++++++++
 include/linux/sched.h        |    5 +++++
 mm/memory.c                  |    2 ++
 3 files changed, 43 insertions(+)

Index: linux-2.6/arch/x86/kernel/process_32.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/x86/kernel/process_32.c
+++ linux-2.6/arch/x86/kernel/process_32.c
@@ -38,6 +38,7 @@
 #include <linux/uaccess.h>
 #include <linux/io.h>
 #include <linux/kdebug.h>
+#include <linux/highmem.h>
=20
 #include <asm/pgtable.h>
 #include <asm/system.h>
@@ -346,6 +347,41 @@ __switch_to(struct task_struct *prev_p,=20
 		     task_thread_info(next_p)->flags & _TIF_WORK_CTXSW_NEXT))
 		__switch_to_xtra(prev_p, next_p, tss);
=20
+#if defined CONFIG_PREEMPT_RT_FULL && defined CONFIG_HIGHMEM
+	/*
+	 * Save @prev's kmap_atomic stack
+	 */
+	prev_p->kmap_idx =3D __this_cpu_read(__kmap_atomic_idx);
+	if (unlikely(prev_p->kmap_idx)) {
+		int i;
+
+		for (i =3D 0; i < prev_p->kmap_idx; i++) {
+			int idx =3D i + KM_TYPE_NR * smp_processor_id();
+
+			pte_t *ptep =3D kmap_pte - idx;
+			prev_p->kmap_pte[i] =3D *ptep;
+			kpte_clear_flush(ptep, __fix_to_virt(FIX_KMAP_BEGIN + idx));
+		}
+
+		__this_cpu_write(__kmap_atomic_idx, 0);
+	}
+
+	/*
+	 * Restore @next_p's kmap_atomic stack
+	 */
+	if (unlikely(next_p->kmap_idx)) {
+		int i;
+
+		__this_cpu_write(__kmap_atomic_idx, next_p->kmap_idx);
+
+		for (i =3D 0; i < next_p->kmap_idx; i++) {
+			int idx =3D i + KM_TYPE_NR * smp_processor_id();
+
+			set_pte(kmap_pte - idx, next_p->kmap_pte[i]);
+		}
+	}
+#endif
+
 	/* If we're going to preload the fpu context, make sure clts
 	   is run while we're batching the cpu state updates. */
 	if (preload_fpu)
Index: linux-2.6/include/linux/sched.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/include/linux/sched.h
+++ linux-2.6/include/linux/sched.h
@@ -63,6 +63,7 @@ struct sched_param {
 #include <linux/nodemask.h>
 #include <linux/mm_types.h>
=20
+#include <asm/kmap_types.h>
 #include <asm/system.h>
 #include <asm/page.h>
 #include <asm/ptrace.h>
@@ -1594,6 +1595,10 @@ struct task_struct {
 	struct rcu_head put_rcu;
 	int softirq_nestcnt;
 #endif
+#if defined CONFIG_PREEMPT_RT_FULL && defined CONFIG_HIGHMEM
+	int kmap_idx;
+	pte_t kmap_pte[KM_TYPE_NR];
+#endif
 };
=20
 #ifdef CONFIG_PREEMPT_RT_FULL
Index: linux-2.6/mm/memory.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -3431,6 +3431,7 @@ unlock:
 #ifdef CONFIG_PREEMPT_RT_FULL
 void pagefault_disable(void)
 {
+	migrate_disable();
 	current->pagefault_disabled++;
 	/*
 	 * make sure to have issued the store before a pagefault
@@ -3448,6 +3449,7 @@ void pagefault_enable(void)
 	 */
 	barrier();
 	current->pagefault_disabled--;
+	migrate_enable();
 }
 EXPORT_SYMBOL_GPL(pagefault_enable);
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
