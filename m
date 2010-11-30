From: Christoph Lameter <cl@linux.com>
Subject: [thisops uV3 14/18] lguest: Use this_cpu_ops
Date: Tue, 30 Nov 2010 13:07:21 -0600
Message-ID: <20101130190849.422541374@linux.com>
References: <20101130190707.457099608@linux.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PNVZj-0000X2-UH
	for glkm-linux-mm-2@m.gmane.org; Tue, 30 Nov 2010 20:09:16 +0100
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 866F76B0096
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 14:08:52 -0500 (EST)
Content-Disposition: inline; filename=this_cpu_lguest
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rusty Russell <rusty@rustcorp.com.au>, linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Use this_cpu_ops in a couple of places in lguest.

Cc: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 arch/x86/lguest/boot.c       |    2 +-
 drivers/lguest/page_tables.c |    2 +-
 drivers/lguest/x86/core.c    |    4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

Index: linux-2.6/arch/x86/lguest/boot.c
===================================================================
--- linux-2.6.orig/arch/x86/lguest/boot.c	2010-11-30 12:22:34.000000000 -0600
+++ linux-2.6/arch/x86/lguest/boot.c	2010-11-30 12:24:08.000000000 -0600
@@ -821,7 +821,7 @@ static void __init lguest_init_IRQ(void)
 
 	for (i = FIRST_EXTERNAL_VECTOR; i < NR_VECTORS; i++) {
 		/* Some systems map "vectors" to interrupts weirdly.  Not us! */
-		__get_cpu_var(vector_irq)[i] = i - FIRST_EXTERNAL_VECTOR;
+		__this_cpu_write(vector_irq[i]) = i - FIRST_EXTERNAL_VECTOR;
 		if (i != SYSCALL_VECTOR)
 			set_intr_gate(i, interrupt[i - FIRST_EXTERNAL_VECTOR]);
 	}
Index: linux-2.6/drivers/lguest/page_tables.c
===================================================================
--- linux-2.6.orig/drivers/lguest/page_tables.c	2010-11-30 12:22:34.000000000 -0600
+++ linux-2.6/drivers/lguest/page_tables.c	2010-11-30 12:24:08.000000000 -0600
@@ -1137,7 +1137,7 @@ void free_guest_pagetable(struct lguest
  */
 void map_switcher_in_guest(struct lg_cpu *cpu, struct lguest_pages *pages)
 {
-	pte_t *switcher_pte_page = __get_cpu_var(switcher_pte_pages);
+	pte_t *switcher_pte_page = __this_cpu_read(switcher_pte_pages);
 	pte_t regs_pte;
 
 #ifdef CONFIG_X86_PAE
Index: linux-2.6/drivers/lguest/x86/core.c
===================================================================
--- linux-2.6.orig/drivers/lguest/x86/core.c	2010-11-30 12:22:34.000000000 -0600
+++ linux-2.6/drivers/lguest/x86/core.c	2010-11-30 12:24:08.000000000 -0600
@@ -90,8 +90,8 @@ static void copy_in_guest_info(struct lg
 	 * meanwhile).  If that's not the case, we pretend everything in the
 	 * Guest has changed.
 	 */
-	if (__get_cpu_var(lg_last_cpu) != cpu || cpu->last_pages != pages) {
-		__get_cpu_var(lg_last_cpu) = cpu;
+	if (__this_cpu_read(lg_last_cpu) != cpu || cpu->last_pages != pages) {
+		__this_cpu_read(lg_last_cpu) = cpu;
 		cpu->last_pages = pages;
 		cpu->changed = CHANGED_ALL;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
