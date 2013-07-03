Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 5A7F96B0036
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 09:02:09 -0400 (EDT)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Wed, 3 Jul 2013 13:57:26 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 7E3DC17D805F
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 14:03:36 +0100 (BST)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r63D1sZf30015502
	for <linux-mm@kvack.org>; Wed, 3 Jul 2013 13:01:54 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r63D24gH019163
	for <linux-mm@kvack.org>; Wed, 3 Jul 2013 09:02:04 -0400
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH 2/2] s390/kvm: support collaborative memory management
Date: Wed,  3 Jul 2013 15:01:52 +0200
Message-Id: <1372856512-25710-3-git-send-email-schwidefsky@de.ibm.com>
In-Reply-To: <1372856512-25710-1-git-send-email-schwidefsky@de.ibm.com>
References: <1372856512-25710-1-git-send-email-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Nick Piggin <npiggin@kernel.dk>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Konstantin Weitz <konstantin.weitz@gmail.com>

From: Konstantin Weitz <konstantin.weitz@gmail.com>

This patch enables Collaborative Memory Management (CMM) for kvm
on s390. CMM allows the guest to inform the host about page usage
(see arch/s390/mm/cmm.c). The host uses this information to avoid
swapping in unused pages in the page fault handler. Further, a CPU
provided list of unused invalid pages is processed to reclaim swap
space of not yet accessed unused pages.

[ Martin Schwidefsky: patch reordering and cleanup ]

Signed-off-by: Konstantin Weitz <konstantin.weitz@gmail.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 arch/s390/include/asm/kvm_host.h |    8 +++-
 arch/s390/include/asm/pgtable.h  |   24 ++++++++++++
 arch/s390/kvm/kvm-s390.c         |   24 ++++++++++++
 arch/s390/kvm/kvm-s390.h         |    2 +
 arch/s390/kvm/priv.c             |   37 ++++++++++++++++++
 arch/s390/mm/pgtable.c           |   77 ++++++++++++++++++++++++++++++++++++++
 mm/rmap.c                        |    2 +-
 7 files changed, 171 insertions(+), 3 deletions(-)

diff --git a/arch/s390/include/asm/kvm_host.h b/arch/s390/include/asm/kvm_host.h
index 16bd5d1..8d1bcf4 100644
--- a/arch/s390/include/asm/kvm_host.h
+++ b/arch/s390/include/asm/kvm_host.h
@@ -90,7 +90,8 @@ struct kvm_s390_sie_block {
 	__u32	scaoh;			/* 0x005c */
 	__u8	reserved60;		/* 0x0060 */
 	__u8	ecb;			/* 0x0061 */
-	__u8	reserved62[2];		/* 0x0062 */
+	__u8	ecb2;			/* 0x0062 */
+	__u8	reserved63[1];		/* 0x0063 */
 	__u32	scaol;			/* 0x0064 */
 	__u8	reserved68[4];		/* 0x0068 */
 	__u32	todpr;			/* 0x006c */
@@ -105,7 +106,9 @@ struct kvm_s390_sie_block {
 	__u64	gbea;			/* 0x0180 */
 	__u8	reserved188[24];	/* 0x0188 */
 	__u32	fac;			/* 0x01a0 */
-	__u8	reserved1a4[92];	/* 0x01a4 */
+	__u8	reserved1a4[20];	/* 0x01a4 */
+	__u64	cbrlo;			/* 0x01b8 */
+	__u8	reserved1c0[64];	/* 0x01c0 */
 } __attribute__((packed));
 
 struct kvm_vcpu_stat {
@@ -140,6 +143,7 @@ struct kvm_vcpu_stat {
 	u32 instruction_stsi;
 	u32 instruction_stfl;
 	u32 instruction_tprot;
+	u32 instruction_essa;
 	u32 instruction_sigp_sense;
 	u32 instruction_sigp_sense_running;
 	u32 instruction_sigp_external_call;
diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 9aefa3c..061e274 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -227,6 +227,7 @@ extern unsigned long MODULES_END;
 #define _PAGE_SWR	0x008		/* SW pte referenced bit */
 #define _PAGE_SWW	0x010		/* SW pte write bit */
 #define _PAGE_SPECIAL	0x020		/* SW associated with special page */
+#define _PAGE_UNUSED	0x040		/* SW bit for ptep_clear_flush() */
 #define __HAVE_ARCH_PTE_SPECIAL
 
 /* Set of bits not changed in pte_modify */
@@ -379,6 +380,12 @@ extern unsigned long MODULES_END;
 
 #endif /* CONFIG_64BIT */
 
+/* Guest Page State used for virtualization */
+#define _PGSTE_GPS_ZERO 	0x0000000080000000UL
+#define _PGSTE_GPS_USAGE_MASK	0x0000000003000000UL
+#define _PGSTE_GPS_USAGE_STABLE 0x0000000000000000UL
+#define _PGSTE_GPS_USAGE_UNUSED 0x0000000001000000UL
+
 /*
  * A user page table pointer has the space-switch-event bit, the
  * private-space-control bit and the storage-alteration-event-control
@@ -594,6 +601,12 @@ static inline int pte_file(pte_t pte)
 	return (pte_val(pte) & mask) == _PAGE_TYPE_FILE;
 }
 
+static inline int pte_swap(pte_t pte)
+{
+	unsigned long mask = _PAGE_RO | _PAGE_INVALID | _PAGE_SWT | _PAGE_SWX;
+	return (pte_val(pte) & mask) == _PAGE_TYPE_SWAP;
+}
+
 static inline int pte_special(pte_t pte)
 {
 	return (pte_val(pte) & _PAGE_SPECIAL);
@@ -797,6 +810,7 @@ unsigned long gmap_translate(unsigned long address, struct gmap *);
 unsigned long __gmap_fault(unsigned long address, struct gmap *);
 unsigned long gmap_fault(unsigned long address, struct gmap *);
 void gmap_discard(unsigned long from, unsigned long to, struct gmap *);
+void __gmap_zap(unsigned long address, struct gmap *);
 
 void gmap_register_ipte_notifier(struct gmap_notifier *);
 void gmap_unregister_ipte_notifier(struct gmap_notifier *);
@@ -828,6 +842,7 @@ static inline void set_pte_at(struct mm_struct *mm, unsigned long addr,
 
 	if (mm_has_pgste(mm)) {
 		pgste = pgste_get_lock(ptep);
+		pgste_val(pgste) &= ~_PGSTE_GPS_ZERO;
 		pgste_set_key(ptep, pgste, entry);
 		pgste_set_pte(ptep, entry);
 		pgste_set_unlock(ptep, pgste);
@@ -861,6 +876,12 @@ static inline int pte_young(pte_t pte)
 	return 0;
 }
 
+#define __HAVE_ARCH_PTE_UNUSED
+static inline int pte_unused(pte_t pte)
+{
+	return pte_val(pte) & _PAGE_UNUSED;
+}
+
 /*
  * pgd/pmd/pte modification functions
  */
@@ -1145,6 +1166,9 @@ static inline pte_t ptep_clear_flush(struct vm_area_struct *vma,
 	pte_val(*ptep) = _PAGE_TYPE_EMPTY;
 
 	if (mm_has_pgste(vma->vm_mm)) {
+		if ((pgste_val(pgste) & _PGSTE_GPS_USAGE_MASK) ==
+		    _PGSTE_GPS_USAGE_UNUSED)
+			pte_val(pte) |= _PAGE_UNUSED;
 		pgste = pgste_update_all(&pte, pgste);
 		pgste_set_unlock(ptep, pgste);
 	}
diff --git a/arch/s390/kvm/kvm-s390.c b/arch/s390/kvm/kvm-s390.c
index c1c7c68..4961845 100644
--- a/arch/s390/kvm/kvm-s390.c
+++ b/arch/s390/kvm/kvm-s390.c
@@ -66,6 +66,7 @@ struct kvm_stats_debugfs_item debugfs_entries[] = {
 	{ "instruction_storage_key", VCPU_STAT(instruction_storage_key) },
 	{ "instruction_stsch", VCPU_STAT(instruction_stsch) },
 	{ "instruction_chsc", VCPU_STAT(instruction_chsc) },
+	{ "instruction_essa", VCPU_STAT(instruction_essa) },
 	{ "instruction_stsi", VCPU_STAT(instruction_stsi) },
 	{ "instruction_stfl", VCPU_STAT(instruction_stfl) },
 	{ "instruction_tprot", VCPU_STAT(instruction_tprot) },
@@ -268,7 +269,11 @@ void kvm_arch_vcpu_destroy(struct kvm_vcpu *vcpu)
 	if (kvm_is_ucontrol(vcpu->kvm))
 		gmap_free(vcpu->arch.gmap);
 
+	if (vcpu->arch.sie_block->cbrlo)
+		__free_page(__pfn_to_page(
+				vcpu->arch.sie_block->cbrlo >> PAGE_SHIFT));
 	free_page((unsigned long)(vcpu->arch.sie_block));
+
 	kvm_vcpu_uninit(vcpu);
 	kfree(vcpu);
 }
@@ -371,12 +376,21 @@ int kvm_arch_vcpu_postcreate(struct kvm_vcpu *vcpu)
 
 int kvm_arch_vcpu_setup(struct kvm_vcpu *vcpu)
 {
+	struct page *cbrl;
+
 	atomic_set(&vcpu->arch.sie_block->cpuflags, CPUSTAT_ZARCH |
 						    CPUSTAT_SM |
 						    CPUSTAT_STOPPED);
 	vcpu->arch.sie_block->ecb   = 6;
 	vcpu->arch.sie_block->eca   = 0xC1002001U;
 	vcpu->arch.sie_block->fac   = (int) (long) facilities;
+	if (kvm_enabled_cmma()) {
+		cbrl = alloc_page(GFP_KERNEL | __GFP_ZERO);
+		if (cbrl) {
+			vcpu->arch.sie_block->ecb2 = 0x80;
+			vcpu->arch.sie_block->cbrlo = page_to_phys(cbrl);
+		}
+	}
 	hrtimer_init(&vcpu->arch.ckc_timer, CLOCK_REALTIME, HRTIMER_MODE_ABS);
 	tasklet_init(&vcpu->arch.tasklet, kvm_s390_tasklet,
 		     (unsigned long) vcpu);
@@ -606,6 +620,16 @@ int kvm_arch_vcpu_ioctl_set_mpstate(struct kvm_vcpu *vcpu,
 	return -EINVAL; /* not implemented yet */
 }
 
+bool kvm_enabled_cmma(void)
+{
+	if (!MACHINE_IS_LPAR)
+		return false;
+	/* only enable for z10 and later */
+	if (!MACHINE_HAS_EDAT1)
+		return false;
+	return true;
+}
+
 static int __vcpu_run(struct kvm_vcpu *vcpu)
 {
 	int rc;
diff --git a/arch/s390/kvm/kvm-s390.h b/arch/s390/kvm/kvm-s390.h
index efc14f6..9caf102 100644
--- a/arch/s390/kvm/kvm-s390.h
+++ b/arch/s390/kvm/kvm-s390.h
@@ -133,6 +133,8 @@ int kvm_s390_handle_sigp(struct kvm_vcpu *vcpu);
 /* implemented in kvm-s390.c */
 int kvm_s390_vcpu_store_status(struct kvm_vcpu *vcpu,
 				 unsigned long addr);
+/* are we going to support cmma? */
+bool kvm_enabled_cmma(void);
 /* implemented in diag.c */
 int kvm_s390_handle_diag(struct kvm_vcpu *vcpu);
 
diff --git a/arch/s390/kvm/priv.c b/arch/s390/kvm/priv.c
index 6bbd7b5..ddccf39 100644
--- a/arch/s390/kvm/priv.c
+++ b/arch/s390/kvm/priv.c
@@ -20,6 +20,8 @@
 #include <asm/debug.h>
 #include <asm/ebcdic.h>
 #include <asm/sysinfo.h>
+#include <asm/pgtable.h>
+#include <asm/io.h>
 #include <asm/ptrace.h>
 #include <asm/compat.h>
 #include "gaccess.h"
@@ -467,9 +469,44 @@ static int handle_epsw(struct kvm_vcpu *vcpu)
 	return 0;
 }
 
+static int handle_essa(struct kvm_vcpu *vcpu)
+{
+	/* entries expected to be 1FF */
+	int entries = (vcpu->arch.sie_block->cbrlo & ~PAGE_MASK) >> 3;
+	unsigned long *cbrlo, cbrle;
+	struct gmap *gmap;
+	int i;
+
+	VCPU_EVENT(vcpu, 5, "cmma release %d pages", entries);
+	gmap = vcpu->arch.gmap;
+	vcpu->stat.instruction_essa++;
+	if (!kvm_enabled_cmma() || !vcpu->arch.sie_block->cbrlo)
+		return kvm_s390_inject_program_int(vcpu, PGM_OPERATION);
+
+	/* Rewind PSW to repeat the ESSA instruction */
+	vcpu->arch.sie_block->gpsw.addr =
+		__rewind_psw(vcpu->arch.sie_block->gpsw, 4);
+	vcpu->arch.sie_block->cbrlo &= PAGE_MASK;	/* reset nceo */
+	cbrlo = phys_to_virt(vcpu->arch.sie_block->cbrlo);
+	down_read(&gmap->mm->mmap_sem);
+	for (i = 0; i < entries; ++i) {
+		cbrle = cbrlo[i];
+		if (unlikely(cbrle & ~PAGE_MASK || cbrle < 2 * PAGE_SIZE))
+			/* invalid entry */
+			break;
+		/* try to free backing */
+		__gmap_zap(cbrle, gmap);
+	}
+	up_read(&gmap->mm->mmap_sem);
+	if (i < entries)
+		return kvm_s390_inject_program_int(vcpu, PGM_SPECIFICATION);
+	return 0;
+}
+
 static const intercept_handler_t b9_handlers[256] = {
 	[0x8d] = handle_epsw,
 	[0x9c] = handle_io_inst,
+	[0xab] = handle_essa,
 };
 
 int kvm_s390_handle_b9(struct kvm_vcpu *vcpu)
diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index a938b54..5a4d8ef 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -17,6 +17,7 @@
 #include <linux/quicklist.h>
 #include <linux/rcupdate.h>
 #include <linux/slab.h>
+#include <linux/swapops.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -573,6 +574,82 @@ unsigned long gmap_fault(unsigned long address, struct gmap *gmap)
 }
 EXPORT_SYMBOL_GPL(gmap_fault);
 
+static void gmap_zap_swap_entry(swp_entry_t entry, struct mm_struct *mm)
+{
+	if (!non_swap_entry(entry))
+		dec_mm_counter(mm, MM_SWAPENTS);
+	else if (is_migration_entry(entry)) {
+		struct page *page = migration_entry_to_page(entry);
+
+		if (PageAnon(page))
+			dec_mm_counter(mm, MM_ANONPAGES);
+		else
+			dec_mm_counter(mm, MM_FILEPAGES);
+	}
+	free_swap_and_cache(entry);
+}
+
+/**
+ * The mm->mmap_sem lock must be held
+ */
+static void gmap_zap_unused(struct mm_struct *mm, unsigned long address)
+{
+	unsigned long ptev, pgstev;
+	spinlock_t *ptl;
+	pgste_t pgste;
+	pte_t *ptep, pte;
+
+	ptep = get_locked_pte(mm, address, &ptl);
+	if (unlikely(!ptep))
+		return;
+	pte = *ptep;
+	if (!pte_swap(pte))
+		goto out_pte;
+	/* Zap unused and logically-zero pages */
+	pgste = pgste_get_lock(ptep);
+	pgstev = pgste_val(pgste);
+	ptev = pte_val(pte);
+	if (((pgstev & _PGSTE_GPS_USAGE_MASK) == _PGSTE_GPS_USAGE_UNUSED) ||
+	    ((pgstev & _PGSTE_GPS_ZERO) && (ptev & _PAGE_INVALID))) {
+		gmap_zap_swap_entry(pte_to_swp_entry(pte), mm);
+		pte_clear(mm, address, ptep);
+	}
+	pgste_set_unlock(ptep, pgste);
+out_pte:
+	pte_unmap_unlock(*ptep, ptl);
+}
+
+/*
+ * this function is assumed to be called with mmap_sem held
+ */
+void __gmap_zap(unsigned long address, struct gmap *gmap)
+{
+	unsigned long *table, *segment_ptr;
+	unsigned long segment, pgstev, ptev;
+	struct gmap_pgtable *mp;
+	struct page *page;
+
+	segment_ptr = gmap_table_walk(address, gmap);
+	if (IS_ERR(segment_ptr))
+		return;
+	segment = *segment_ptr;
+	if (segment & _SEGMENT_ENTRY_INV)
+		return;
+	page = pfn_to_page(segment >> PAGE_SHIFT);
+	mp = (struct gmap_pgtable *) page->index;
+	address = mp->vmaddr | (address & ~PMD_MASK);
+	/* Page table is present */
+	table = (unsigned long *)(segment & _SEGMENT_ENTRY_ORIGIN);
+	table = table + ((address >> 12) & 0xff);
+	pgstev = table[PTRS_PER_PTE];
+	ptev = table[0];
+	/* quick check, checked again with locks held */
+	if (((pgstev & _PGSTE_GPS_USAGE_MASK) == _PGSTE_GPS_USAGE_UNUSED) ||
+	    ((pgstev & _PGSTE_GPS_ZERO) && (ptev & _PAGE_INVALID)))
+		gmap_zap_unused(gmap->mm, address);
+}
+EXPORT_SYMBOL_GPL(__gmap_zap);
+
 void gmap_discard(unsigned long from, unsigned long to, struct gmap *gmap)
 {
 
diff --git a/mm/rmap.c b/mm/rmap.c
index be2788d..3155097 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1233,7 +1233,7 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		}
 		set_pte_at(mm, address, pte,
 			   swp_entry_to_pte(make_hwpoison_entry(page)));
-	} else if (pte_unused(pteval) && PageAnon(page)) {
+	} else if (pte_unused(pteval) && PageSwapCache(page) && PageAnon(page)) {
 		pte_clear(mm, address, pte);
 		dec_mm_counter(mm, MM_ANONPAGES);
 		ret = SWAP_FREE;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
