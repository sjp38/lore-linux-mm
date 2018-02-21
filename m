Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 791A46B0005
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 08:01:51 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id j3so1121414wrb.18
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 05:01:51 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v191si16471078wmf.132.2018.02.21.05.01.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Feb 2018 05:01:49 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 084/167] x86/mm: Rename flush_tlb_single() and flush_tlb_one() to __flush_tlb_one_[user|kernel]()
Date: Wed, 21 Feb 2018 13:48:15 +0100
Message-Id: <20180221124529.013876487@linuxfoundation.org>
In-Reply-To: <20180221124524.639039577@linuxfoundation.org>
References: <20180221124524.639039577@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Eduardo Valentin <eduval@amazon.com>, Hugh Dickins <hughd@google.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Kees Cook <keescook@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@kernel.org>

4.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Andy Lutomirski <luto@kernel.org>

commit 1299ef1d8870d2d9f09a5aadf2f8b2c887c2d033 upstream.

flush_tlb_single() and flush_tlb_one() sound almost identical, but
they really mean "flush one user translation" and "flush one kernel
translation".  Rename them to flush_tlb_one_user() and
flush_tlb_one_kernel() to make the semantics more obvious.

[ I was looking at some PTI-related code, and the flush-one-address code
  is unnecessarily hard to understand because the names of the helpers are
  uninformative.  This came up during PTI review, but no one got around to
  doing it. ]

Signed-off-by: Andy Lutomirski <luto@kernel.org>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Eduardo Valentin <eduval@amazon.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Kees Cook <keescook@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Will Deacon <will.deacon@arm.com>
Link: http://lkml.kernel.org/r/3303b02e3c3d049dc5235d5651e0ae6d29a34354.1517414378.git.luto@kernel.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/include/asm/paravirt.h       |    4 ++--
 arch/x86/include/asm/paravirt_types.h |    2 +-
 arch/x86/include/asm/pgtable_32.h     |    2 +-
 arch/x86/include/asm/tlbflush.h       |   27 ++++++++++++++++++++-------
 arch/x86/kernel/acpi/apei.c           |    2 +-
 arch/x86/kernel/paravirt.c            |    6 +++---
 arch/x86/mm/init_64.c                 |    2 +-
 arch/x86/mm/ioremap.c                 |    2 +-
 arch/x86/mm/kmmio.c                   |    2 +-
 arch/x86/mm/pgtable_32.c              |    2 +-
 arch/x86/mm/tlb.c                     |    6 +++---
 arch/x86/platform/uv/tlb_uv.c         |    2 +-
 arch/x86/xen/mmu_pv.c                 |    6 +++---
 include/trace/events/xen.h            |    2 +-
 14 files changed, 40 insertions(+), 27 deletions(-)

--- a/arch/x86/include/asm/paravirt.h
+++ b/arch/x86/include/asm/paravirt.h
@@ -297,9 +297,9 @@ static inline void __flush_tlb_global(vo
 {
 	PVOP_VCALL0(pv_mmu_ops.flush_tlb_kernel);
 }
-static inline void __flush_tlb_single(unsigned long addr)
+static inline void __flush_tlb_one_user(unsigned long addr)
 {
-	PVOP_VCALL1(pv_mmu_ops.flush_tlb_single, addr);
+	PVOP_VCALL1(pv_mmu_ops.flush_tlb_one_user, addr);
 }
 
 static inline void flush_tlb_others(const struct cpumask *cpumask,
--- a/arch/x86/include/asm/paravirt_types.h
+++ b/arch/x86/include/asm/paravirt_types.h
@@ -217,7 +217,7 @@ struct pv_mmu_ops {
 	/* TLB operations */
 	void (*flush_tlb_user)(void);
 	void (*flush_tlb_kernel)(void);
-	void (*flush_tlb_single)(unsigned long addr);
+	void (*flush_tlb_one_user)(unsigned long addr);
 	void (*flush_tlb_others)(const struct cpumask *cpus,
 				 const struct flush_tlb_info *info);
 
--- a/arch/x86/include/asm/pgtable_32.h
+++ b/arch/x86/include/asm/pgtable_32.h
@@ -61,7 +61,7 @@ void paging_init(void);
 #define kpte_clear_flush(ptep, vaddr)		\
 do {						\
 	pte_clear(&init_mm, (vaddr), (ptep));	\
-	__flush_tlb_one((vaddr));		\
+	__flush_tlb_one_kernel((vaddr));		\
 } while (0)
 
 #endif /* !__ASSEMBLY__ */
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -140,7 +140,7 @@ static inline unsigned long build_cr3_no
 #else
 #define __flush_tlb() __native_flush_tlb()
 #define __flush_tlb_global() __native_flush_tlb_global()
-#define __flush_tlb_single(addr) __native_flush_tlb_single(addr)
+#define __flush_tlb_one_user(addr) __native_flush_tlb_one_user(addr)
 #endif
 
 static inline bool tlb_defer_switch_to_init_mm(void)
@@ -397,7 +397,7 @@ static inline void __native_flush_tlb_gl
 /*
  * flush one page in the user mapping
  */
-static inline void __native_flush_tlb_single(unsigned long addr)
+static inline void __native_flush_tlb_one_user(unsigned long addr)
 {
 	u32 loaded_mm_asid = this_cpu_read(cpu_tlbstate.loaded_mm_asid);
 
@@ -434,18 +434,31 @@ static inline void __flush_tlb_all(void)
 /*
  * flush one page in the kernel mapping
  */
-static inline void __flush_tlb_one(unsigned long addr)
+static inline void __flush_tlb_one_kernel(unsigned long addr)
 {
 	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ONE);
-	__flush_tlb_single(addr);
+
+	/*
+	 * If PTI is off, then __flush_tlb_one_user() is just INVLPG or its
+	 * paravirt equivalent.  Even with PCID, this is sufficient: we only
+	 * use PCID if we also use global PTEs for the kernel mapping, and
+	 * INVLPG flushes global translations across all address spaces.
+	 *
+	 * If PTI is on, then the kernel is mapped with non-global PTEs, and
+	 * __flush_tlb_one_user() will flush the given address for the current
+	 * kernel address space and for its usermode counterpart, but it does
+	 * not flush it for other address spaces.
+	 */
+	__flush_tlb_one_user(addr);
 
 	if (!static_cpu_has(X86_FEATURE_PTI))
 		return;
 
 	/*
-	 * __flush_tlb_single() will have cleared the TLB entry for this ASID,
-	 * but since kernel space is replicated across all, we must also
-	 * invalidate all others.
+	 * See above.  We need to propagate the flush to all other address
+	 * spaces.  In principle, we only need to propagate it to kernelmode
+	 * address spaces, but the extra bookkeeping we would need is not
+	 * worth it.
 	 */
 	invalidate_other_asid();
 }
--- a/arch/x86/kernel/acpi/apei.c
+++ b/arch/x86/kernel/acpi/apei.c
@@ -55,5 +55,5 @@ void arch_apei_report_mem_error(int sev,
 
 void arch_apei_flush_tlb_one(unsigned long addr)
 {
-	__flush_tlb_one(addr);
+	__flush_tlb_one_kernel(addr);
 }
--- a/arch/x86/kernel/paravirt.c
+++ b/arch/x86/kernel/paravirt.c
@@ -190,9 +190,9 @@ static void native_flush_tlb_global(void
 	__native_flush_tlb_global();
 }
 
-static void native_flush_tlb_single(unsigned long addr)
+static void native_flush_tlb_one_user(unsigned long addr)
 {
-	__native_flush_tlb_single(addr);
+	__native_flush_tlb_one_user(addr);
 }
 
 struct static_key paravirt_steal_enabled;
@@ -391,7 +391,7 @@ struct pv_mmu_ops pv_mmu_ops __ro_after_
 
 	.flush_tlb_user = native_flush_tlb,
 	.flush_tlb_kernel = native_flush_tlb_global,
-	.flush_tlb_single = native_flush_tlb_single,
+	.flush_tlb_one_user = native_flush_tlb_one_user,
 	.flush_tlb_others = native_flush_tlb_others,
 
 	.pgd_alloc = __paravirt_pgd_alloc,
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -256,7 +256,7 @@ static void __set_pte_vaddr(pud_t *pud,
 	 * It's enough to flush this one mapping.
 	 * (PGE mappings get flushed as well)
 	 */
-	__flush_tlb_one(vaddr);
+	__flush_tlb_one_kernel(vaddr);
 }
 
 void set_pte_vaddr_p4d(p4d_t *p4d_page, unsigned long vaddr, pte_t new_pte)
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -749,5 +749,5 @@ void __init __early_set_fixmap(enum fixe
 		set_pte(pte, pfn_pte(phys >> PAGE_SHIFT, flags));
 	else
 		pte_clear(&init_mm, addr, pte);
-	__flush_tlb_one(addr);
+	__flush_tlb_one_kernel(addr);
 }
--- a/arch/x86/mm/kmmio.c
+++ b/arch/x86/mm/kmmio.c
@@ -168,7 +168,7 @@ static int clear_page_presence(struct km
 		return -1;
 	}
 
-	__flush_tlb_one(f->addr);
+	__flush_tlb_one_kernel(f->addr);
 	return 0;
 }
 
--- a/arch/x86/mm/pgtable_32.c
+++ b/arch/x86/mm/pgtable_32.c
@@ -63,7 +63,7 @@ void set_pte_vaddr(unsigned long vaddr,
 	 * It's enough to flush this one mapping.
 	 * (PGE mappings get flushed as well)
 	 */
-	__flush_tlb_one(vaddr);
+	__flush_tlb_one_kernel(vaddr);
 }
 
 unsigned long __FIXADDR_TOP = 0xfffff000;
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -492,7 +492,7 @@ static void flush_tlb_func_common(const
 	 *    flush that changes context.tlb_gen from 2 to 3.  If they get
 	 *    processed on this CPU in reverse order, we'll see
 	 *     local_tlb_gen == 1, mm_tlb_gen == 3, and end != TLB_FLUSH_ALL.
-	 *    If we were to use __flush_tlb_single() and set local_tlb_gen to
+	 *    If we were to use __flush_tlb_one_user() and set local_tlb_gen to
 	 *    3, we'd be break the invariant: we'd update local_tlb_gen above
 	 *    1 without the full flush that's needed for tlb_gen 2.
 	 *
@@ -513,7 +513,7 @@ static void flush_tlb_func_common(const
 
 		addr = f->start;
 		while (addr < f->end) {
-			__flush_tlb_single(addr);
+			__flush_tlb_one_user(addr);
 			addr += PAGE_SIZE;
 		}
 		if (local)
@@ -660,7 +660,7 @@ static void do_kernel_range_flush(void *
 
 	/* flush range by one by one 'invlpg' */
 	for (addr = f->start; addr < f->end; addr += PAGE_SIZE)
-		__flush_tlb_one(addr);
+		__flush_tlb_one_kernel(addr);
 }
 
 void flush_tlb_kernel_range(unsigned long start, unsigned long end)
--- a/arch/x86/platform/uv/tlb_uv.c
+++ b/arch/x86/platform/uv/tlb_uv.c
@@ -299,7 +299,7 @@ static void bau_process_message(struct m
 		local_flush_tlb();
 		stat->d_alltlb++;
 	} else {
-		__flush_tlb_single(msg->address);
+		__flush_tlb_one_user(msg->address);
 		stat->d_onetlb++;
 	}
 	stat->d_requestee++;
--- a/arch/x86/xen/mmu_pv.c
+++ b/arch/x86/xen/mmu_pv.c
@@ -1300,12 +1300,12 @@ static void xen_flush_tlb(void)
 	preempt_enable();
 }
 
-static void xen_flush_tlb_single(unsigned long addr)
+static void xen_flush_tlb_one_user(unsigned long addr)
 {
 	struct mmuext_op *op;
 	struct multicall_space mcs;
 
-	trace_xen_mmu_flush_tlb_single(addr);
+	trace_xen_mmu_flush_tlb_one_user(addr);
 
 	preempt_disable();
 
@@ -2360,7 +2360,7 @@ static const struct pv_mmu_ops xen_mmu_o
 
 	.flush_tlb_user = xen_flush_tlb,
 	.flush_tlb_kernel = xen_flush_tlb,
-	.flush_tlb_single = xen_flush_tlb_single,
+	.flush_tlb_one_user = xen_flush_tlb_one_user,
 	.flush_tlb_others = xen_flush_tlb_others,
 
 	.pgd_alloc = xen_pgd_alloc,
--- a/include/trace/events/xen.h
+++ b/include/trace/events/xen.h
@@ -365,7 +365,7 @@ TRACE_EVENT(xen_mmu_flush_tlb,
 	    TP_printk("%s", "")
 	);
 
-TRACE_EVENT(xen_mmu_flush_tlb_single,
+TRACE_EVENT(xen_mmu_flush_tlb_one_user,
 	    TP_PROTO(unsigned long addr),
 	    TP_ARGS(addr),
 	    TP_STRUCT__entry(


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
