Date: Fri, 14 Oct 2005 14:55:54 -0500
From: Dean Roe <roe@sgi.com>
Subject: [ PATCH ] - Avoid slow TLB purges on SGI Altix systems
Message-ID: <20051014195554.GA21639@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

flush_tlb_all() can be a scaling issue on large SGI Altix systems
since it uses the global call_lock and always executes on all cpus.
When a process enters flush_tlb_range() to purge TLBs for another
process, it is possible to avoid flush_tlb_all() and instead allow
sn2_global_tlb_purge() to purge TLBs only where necessary.

This patch modifies flush_tlb_range() so that this case can be handled
by platform TLB purge functions and updates ia64_global_tlb_purge()
accordingly.  sn2_global_tlb_purge() now calculates the region register
value from the mm argument introduced with this patch.

	Signed-off-by: Dean Roe <roe@sgi.com>



Index: linux-ia64-test/include/asm-ia64/machvec.h
===================================================================
--- linux-ia64-test.orig/include/asm-ia64/machvec.h
+++ linux-ia64-test/include/asm-ia64/machvec.h
@@ -26,7 +26,7 @@
 typedef void ia64_mv_irq_init_t (void);
 typedef void ia64_mv_send_ipi_t (int, int, int, int);
 typedef void ia64_mv_timer_interrupt_t (int, void *, struct pt_regs *);
-typedef void ia64_mv_global_tlb_purge_t (unsigned long, unsigned long, unsigned long);
+typedef void ia64_mv_global_tlb_purge_t (struct mm_struct *, unsigned long, unsigned long, unsigned long);
 typedef void ia64_mv_tlb_migrate_finish_t (struct mm_struct *);
 typedef unsigned int ia64_mv_local_vector_to_irq (u8);
 typedef char *ia64_mv_pci_get_legacy_mem_t (struct pci_bus *);
Index: linux-ia64-test/arch/ia64/mm/tlb.c
===================================================================
--- linux-ia64-test.orig/arch/ia64/mm/tlb.c
+++ linux-ia64-test/arch/ia64/mm/tlb.c
@@ -86,10 +86,16 @@
 }
 
 void
-ia64_global_tlb_purge (unsigned long start, unsigned long end, unsigned long nbits)
+ia64_global_tlb_purge (struct mm_struct *mm, unsigned long start, unsigned long end, unsigned long nbits)
 {
 	static DEFINE_SPINLOCK(ptcg_lock);
 
+	if (mm != current->active_mm) {
+		/* this does happen, but perhaps it's not worth optimizing for? */
+		flush_tlb_all();
+		return;
+	}
+
 	/* HW requires global serialization of ptc.ga.  */
 	spin_lock(&ptcg_lock);
 	{
@@ -135,16 +141,6 @@
 	unsigned long size = end - start;
 	unsigned long nbits;
 
-	if (mm != current->active_mm) {
-		/* this does happen, but perhaps it's not worth optimizing for? */
-#ifdef CONFIG_SMP
-		flush_tlb_all();
-#else
-		mm->context = 0;
-#endif
-		return;
-	}
-
 	nbits = ia64_fls(size + 0xfff);
 	while (unlikely (((1UL << nbits) & purge.mask) == 0) && (nbits < purge.max_bits))
 		++nbits;
@@ -153,7 +149,7 @@
 	start &= ~((1UL << nbits) - 1);
 
 # ifdef CONFIG_SMP
-	platform_global_tlb_purge(start, end, nbits);
+	platform_global_tlb_purge(mm, start, end, nbits);
 # else
 	do {
 		ia64_ptcl(start, (nbits<<2));
Index: linux-ia64-test/arch/ia64/sn/kernel/sn2/sn2_smp.c
===================================================================
--- linux-ia64-test.orig/arch/ia64/sn/kernel/sn2/sn2_smp.c
+++ linux-ia64-test/arch/ia64/sn/kernel/sn2/sn2_smp.c
@@ -177,6 +177,7 @@
 
 /**
  * sn2_global_tlb_purge - globally purge translation cache of virtual address range
+ * @mm: mm_struct containing virtual address range
  * @start: start of virtual address range
  * @end: end of virtual address range
  * @nbits: specifies number of bytes to purge per instruction (num = 1<<(nbits & 0xfc))
@@ -188,21 +189,22 @@
  * 	- cpu_vm_mask is a bit mask that indicates which cpus have loaded the context.
  * 	- cpu_vm_mask is converted into a nodemask of the nodes containing the
  * 	  cpus in cpu_vm_mask.
- *	- if only one bit is set in cpu_vm_mask & it is the current cpu,
- *	  then only the local TLB needs to be flushed. This flushing can be done
- *	  using ptc.l. This is the common case & avoids the global spinlock.
+ *	- if only one bit is set in cpu_vm_mask & it is the current cpu & the
+ *	  process is purging its own virtual address range, then only the
+ *	  local TLB needs to be flushed. This flushing can be done using
+ *	  ptc.l. This is the common case & avoids the global spinlock.
  *	- if multiple cpus have loaded the context, then flushing has to be
  *	  done with ptc.g/MMRs under protection of the global ptc_lock.
  */
 
 void
-sn2_global_tlb_purge(unsigned long start, unsigned long end,
-		     unsigned long nbits)
+sn2_global_tlb_purge(struct mm_struct *mm, unsigned long start,
+		     unsigned long end, unsigned long nbits)
 {
 	int i, opt, shub1, cnode, mynasid, cpu, lcpu = 0, nasid, flushed = 0;
+	int mymm = (mm == current->active_mm);
 	volatile unsigned long *ptc0, *ptc1;
-	unsigned long itc, itc2, flags, data0 = 0, data1 = 0;
-	struct mm_struct *mm = current->active_mm;
+	unsigned long itc, itc2, flags, data0 = 0, data1 = 0, rr_value;
 	short nasids[MAX_NUMNODES], nix;
 	nodemask_t nodes_flushed;
 
@@ -216,9 +218,12 @@
 		i++;
 	}
 
+	if (i == 0)
+		return;
+
 	preempt_disable();
 
-	if (likely(i == 1 && lcpu == smp_processor_id())) {
+	if (likely(i == 1 && lcpu == smp_processor_id() && mymm)) {
 		do {
 			ia64_ptcl(start, nbits << 2);
 			start += (1UL << nbits);
@@ -229,7 +234,7 @@
 		return;
 	}
 
-	if (atomic_read(&mm->mm_users) == 1) {
+	if (atomic_read(&mm->mm_users) == 1 && mymm) {
 		flush_tlb_mm(mm);
 		__get_cpu_var(ptcstats).change_rid++;
 		preempt_enable();
@@ -241,11 +246,13 @@
 	for_each_node_mask(cnode, nodes_flushed)
 		nasids[nix++] = cnodeid_to_nasid(cnode);
 
+	rr_value = (mm->context << 3) | REGION_NUMBER(start);
+
 	shub1 = is_shub1();
 	if (shub1) {
 		data0 = (1UL << SH1_PTC_0_A_SHFT) |
 		    	(nbits << SH1_PTC_0_PS_SHFT) |
-		    	((ia64_get_rr(start) >> 8) << SH1_PTC_0_RID_SHFT) |
+			(rr_value << SH1_PTC_0_RID_SHFT) |
 		    	(1UL << SH1_PTC_0_START_SHFT);
 		ptc0 = (long *)GLOBAL_MMR_PHYS_ADDR(0, SH1_PTC_0);
 		ptc1 = (long *)GLOBAL_MMR_PHYS_ADDR(0, SH1_PTC_1);
@@ -254,7 +261,7 @@
 			(nbits << SH2_PTC_PS_SHFT) |
 		    	(1UL << SH2_PTC_START_SHFT);
 		ptc0 = (long *)GLOBAL_MMR_PHYS_ADDR(0, SH2_PTC + 
-			((ia64_get_rr(start) >> 8) << SH2_PTC_RID_SHFT) );
+			(rr_value << SH2_PTC_RID_SHFT));
 		ptc1 = NULL;
 	}
 	
@@ -275,7 +282,7 @@
 			data0 = (data0 & ~SH2_PTC_ADDR_MASK) | (start & SH2_PTC_ADDR_MASK);
 		for (i = 0; i < nix; i++) {
 			nasid = nasids[i];
-			if ((!(sn2_ptctest & 3)) && unlikely(nasid == mynasid)) {
+			if ((!(sn2_ptctest & 3)) && unlikely(nasid == mynasid && mymm)) {
 				ia64_ptcga(start, nbits << 2);
 				ia64_srlz_i();
 			} else {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
