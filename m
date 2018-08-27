Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 57B646B422D
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 15:44:02 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id q67-v6so82908pgq.9
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 12:44:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a65-v6sor41112pfg.16.2018.08.27.12.44.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Aug 2018 12:44:00 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: TLB flushes on fixmap changes
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <823D916E-4056-4A36-BDD8-0FB682A8DCAE@gmail.com>
Date: Mon, 27 Aug 2018 12:43:57 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <E5B40DF6-C28A-4EB2-84C3-146BC5B8B312@gmail.com>
References: <D74A89DF-0D89-4AB6-8A6B-93BEC9A83595@gmail.com>
 <20180824180438.GS24124@hirez.programming.kicks-ass.net>
 <56A9902F-44BE-4520-A17C-26650FCC3A11@gmail.com>
 <CA+55aFzerzTPm94jugheVmWg8dJre94yu+GyZGT9NNZanNx_qw@mail.gmail.com>
 <9A38D3F4-2F75-401D-8B4D-83A844C9061B@gmail.com>
 <CA+55aFz1KYT7fRRG98wei24spiVg7u1Ec66piWY5359ykFmezw@mail.gmail.com>
 <8E0D8C66-6F21-4890-8984-B6B3082D4CC5@gmail.com>
 <CALCETrWdeKBcEs7zAbpEM1YdYiT2UBXwPtF0mMTvcDX_KRpz1A@mail.gmail.com>
 <20180826112341.f77a528763e297cbc36058fa@kernel.org>
 <CALCETrXPaX-+R6Z9LqZp0uOVmq-TUX_ksPbUL7mnfbdqo6z2AA@mail.gmail.com>
 <20180826090958.GT24124@hirez.programming.kicks-ass.net>
 <20180827120305.01a6f26267c64610cadec5d8@kernel.org>
 <4BF82052-4738-441C-8763-26C85003F2C9@gmail.com>
 <20180827170511.6bafa15cbc102ae135366e86@kernel.org>
 <01DA0BDD-7504-4209-8A8F-20B27CF6A1C7@gmail.com>
 <CALCETrWxwpr+Xx0mCK1HUkanmCDOSRbw50VmebgoAgeNaaPAKg@mail.gmail.com>
 <0000D631-FDDF-4273-8F3C-714E6825E59B@gmail.com>
 <CALCETrUoNdwDuNSHb3haw9-fYk+sNC_M4r+5EMVVzJ8HWeSsOQ@mail.gmail.com>
 <823D916E-4056-4A36-BDD8-0FB682A8DCAE@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Masami Hiramatsu <mhiramat@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Jiri Kosina <jkosina@suse.cz>, Will Deacon <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@au1.ibm.com>, Nick Piggin <npiggin@gmail.com>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

at 12:10 PM, Nadav Amit <nadav.amit@gmail.com> wrote:

> at 11:58 AM, Andy Lutomirski <luto@kernel.org> wrote:
>=20
>> On Mon, Aug 27, 2018 at 11:54 AM, Nadav Amit <nadav.amit@gmail.com> =
wrote:
>>>> On Mon, Aug 27, 2018 at 10:34 AM, Nadav Amit <nadav.amit@gmail.com> =
wrote:
>>>> What do you all think?
>>>=20
>>> I agree in general. But I think that current->mm would need to be =
loaded, as
>>> otherwise I am afraid it would break switch_mm_irqs_off().
>>=20
>> What breaks?
>=20
> Actually nothing. I just saw the IBPB stuff regarding tsk, but it =
should not
> matter.

So here is what I got. It certainly needs some cleanup, but it boots.

Let me know how crappy you find it...


diff --git a/arch/x86/include/asm/mmu_context.h =
b/arch/x86/include/asm/mmu_context.h
index bbc796eb0a3b..336779650a41 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -343,4 +343,24 @@ static inline unsigned long =
__get_current_cr3_fast(void)
 	return cr3;
 }
=20
+typedef struct {
+	struct mm_struct *prev;
+} temporary_mm_state_t;
+
+static inline temporary_mm_state_t use_temporary_mm(struct mm_struct =
*mm)
+{
+	temporary_mm_state_t state;
+
+	lockdep_assert_irqs_disabled();
+	state.prev =3D this_cpu_read(cpu_tlbstate.loaded_mm);
+	switch_mm_irqs_off(NULL, mm, current);
+	return state;
+}
+
+static inline void unuse_temporary_mm(temporary_mm_state_t prev)
+{
+	lockdep_assert_irqs_disabled();
+	switch_mm_irqs_off(NULL, prev.prev, current);
+}
+
 #endif /* _ASM_X86_MMU_CONTEXT_H */
diff --git a/arch/x86/include/asm/pgtable.h =
b/arch/x86/include/asm/pgtable.h
index 5715647fc4fe..ef62af9a0ef7 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -976,6 +976,10 @@ static inline void __meminit =
init_trampoline_default(void)
 	/* Default trampoline pgd value */
 	trampoline_pgd_entry =3D init_top_pgt[pgd_index(__PAGE_OFFSET)];
 }
+
+void __init patching_mm_init(void);
+#define patching_mm_init patching_mm_init
+
 # ifdef CONFIG_RANDOMIZE_MEMORY
 void __meminit init_trampoline(void);
 # else
diff --git a/arch/x86/include/asm/pgtable_64_types.h =
b/arch/x86/include/asm/pgtable_64_types.h
index 054765ab2da2..9f44262abde0 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -116,6 +116,9 @@ extern unsigned int ptrs_per_p4d;
 #define LDT_PGD_ENTRY		(pgtable_l5_enabled() ? LDT_PGD_ENTRY_L5 =
: LDT_PGD_ENTRY_L4)
 #define LDT_BASE_ADDR		(LDT_PGD_ENTRY << PGDIR_SHIFT)
=20
+#define TEXT_POKE_PGD_ENTRY	-5UL
+#define TEXT_POKE_ADDR		(TEXT_POKE_PGD_ENTRY << PGDIR_SHIFT)
+
 #define __VMALLOC_BASE_L4	0xffffc90000000000UL
 #define __VMALLOC_BASE_L5 	0xffa0000000000000UL
=20
diff --git a/arch/x86/include/asm/pgtable_types.h =
b/arch/x86/include/asm/pgtable_types.h
index 99fff853c944..840c72ec8c4f 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -505,6 +505,9 @@ pgprot_t phys_mem_access_prot(struct file *file, =
unsigned long pfn,
 /* Install a pte for a particular vaddr in kernel space. */
 void set_pte_vaddr(unsigned long vaddr, pte_t pte);
=20
+struct mm_struct;
+void set_mm_pte_vaddr(struct mm_struct *mm, unsigned long vaddr, pte_t =
pte);
+
 #ifdef CONFIG_X86_32
 extern void native_pagetable_init(void);
 #else
diff --git a/arch/x86/include/asm/text-patching.h =
b/arch/x86/include/asm/text-patching.h
index 2ecd34e2d46c..cb364ea5b19d 100644
--- a/arch/x86/include/asm/text-patching.h
+++ b/arch/x86/include/asm/text-patching.h
@@ -38,4 +38,6 @@ extern void *text_poke(void *addr, const void *opcode, =
size_t len);
 extern int poke_int3_handler(struct pt_regs *regs);
 extern void *text_poke_bp(void *addr, const void *opcode, size_t len, =
void *handler);
=20
+extern struct mm_struct *patching_mm;
+
 #endif /* _ASM_X86_TEXT_PATCHING_H */
diff --git a/arch/x86/kernel/alternative.c =
b/arch/x86/kernel/alternative.c
index a481763a3776..fd8a950b0d62 100644
--- a/arch/x86/kernel/alternative.c
+++ b/arch/x86/kernel/alternative.c
@@ -11,6 +11,7 @@
 #include <linux/stop_machine.h>
 #include <linux/slab.h>
 #include <linux/kdebug.h>
+#include <linux/mmu_context.h>
 #include <asm/text-patching.h>
 #include <asm/alternative.h>
 #include <asm/sections.h>
@@ -701,8 +702,36 @@ void *text_poke(void *addr, const void *opcode, =
size_t len)
 		WARN_ON(!PageReserved(pages[0]));
 		pages[1] =3D virt_to_page(addr + PAGE_SIZE);
 	}
-	BUG_ON(!pages[0]);
+
 	local_irq_save(flags);
+	BUG_ON(!pages[0]);
+
+	/*
+	 * During initial boot, it is hard to initialize patching_mm due =
to
+	 * dependencies in boot order.
+	 */
+	if (patching_mm) {
+		pte_t pte;
+		temporary_mm_state_t prev;
+
+		prev =3D use_temporary_mm(patching_mm);
+		pte =3D mk_pte(pages[0], PAGE_KERNEL);
+		set_mm_pte_vaddr(patching_mm, TEXT_POKE_ADDR, pte);
+		pte =3D mk_pte(pages[1], PAGE_KERNEL);
+		set_mm_pte_vaddr(patching_mm, TEXT_POKE_ADDR + =
PAGE_SIZE, pte);
+
+		memcpy((void *)(TEXT_POKE_ADDR | ((unsigned long)addr & =
~PAGE_MASK)),
+		       opcode, len);
+
+		set_mm_pte_vaddr(patching_mm, TEXT_POKE_ADDR, __pte(0));
+		set_mm_pte_vaddr(patching_mm, TEXT_POKE_ADDR + =
PAGE_SIZE, __pte(0));
+		local_flush_tlb();
+		sync_core();
+
+		unuse_temporary_mm(prev);
+		goto out;
+	}
+
 	set_fixmap(FIX_TEXT_POKE0, page_to_phys(pages[0]));
 	if (pages[1])
 		set_fixmap(FIX_TEXT_POKE1, page_to_phys(pages[1]));
@@ -715,6 +744,7 @@ void *text_poke(void *addr, const void *opcode, =
size_t len)
 	sync_core();
 	/* Could also do a CLFLUSH here to speed up CPU recovery; but
 	   that causes hangs on some VIA CPUs. */
+out:
 	for (i =3D 0; i < len; i++)
 		BUG_ON(((char *)addr)[i] !=3D ((char *)opcode)[i]);
 	local_irq_restore(flags);
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index a688617c727e..bd0d629e3831 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -54,6 +54,7 @@
 #include <asm/init.h>
 #include <asm/uv/uv.h>
 #include <asm/setup.h>
+#include <asm/text-patching.h>
=20
 #include "mm_internal.h"
=20
@@ -285,14 +286,14 @@ void set_pte_vaddr_pud(pud_t *pud_page, unsigned =
long vaddr, pte_t new_pte)
 	__set_pte_vaddr(pud, vaddr, new_pte);
 }
=20
-void set_pte_vaddr(unsigned long vaddr, pte_t pteval)
+void set_mm_pte_vaddr(struct mm_struct *mm, unsigned long vaddr, pte_t =
pteval)
 {
 	pgd_t *pgd;
 	p4d_t *p4d_page;
=20
 	pr_debug("set_pte_vaddr %lx to %lx\n", vaddr, =
native_pte_val(pteval));
=20
-	pgd =3D pgd_offset_k(vaddr);
+	pgd =3D pgd_offset(mm, vaddr);
 	if (pgd_none(*pgd)) {
 		printk(KERN_ERR
 			"PGD FIXMAP MISSING, it should be setup in =
head.S!\n");
@@ -303,6 +304,11 @@ void set_pte_vaddr(unsigned long vaddr, pte_t =
pteval)
 	set_pte_vaddr_p4d(p4d_page, vaddr, pteval);
 }
=20
+void set_pte_vaddr(unsigned long vaddr, pte_t pteval)
+{
+	set_mm_pte_vaddr(&init_mm, vaddr, pteval);
+}
+
 pmd_t * __init populate_extra_pmd(unsigned long vaddr)
 {
 	pgd_t *pgd;
@@ -1399,6 +1405,17 @@ unsigned long memory_block_size_bytes(void)
 	return memory_block_size_probed;
 }
=20
+struct mm_struct *patching_mm;
+EXPORT_SYMBOL(patching_mm);
+
+void __init patching_mm_init(void)
+{
+	populate_extra_pte(TEXT_POKE_ADDR);
+	populate_extra_pte(TEXT_POKE_ADDR + PAGE_SIZE);
+
+	patching_mm =3D copy_init_mm();
+}
+
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 /*
  * Initialise the sparsemem vmemmap using huge-pages at the PMD level.
diff --git a/include/asm-generic/pgtable.h =
b/include/asm-generic/pgtable.h
index f59639afaa39..c95d2240c23a 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -1083,6 +1083,10 @@ int phys_mem_access_prot_allowed(struct file =
*file, unsigned long pfn,
 static inline void init_espfix_bsp(void) { }
 #endif
=20
+#ifndef patching_mm_init
+static inline void patching_mm_init(void) { }
+#endif
+
 #endif /* !__ASSEMBLY__ */
=20
 #ifndef io_remap_pfn_range
diff --git a/include/linux/sched/task.h b/include/linux/sched/task.h
index 108ede99e533..ac0a675678f5 100644
--- a/include/linux/sched/task.h
+++ b/include/linux/sched/task.h
@@ -74,6 +74,7 @@ extern void exit_itimers(struct signal_struct *);
 extern long _do_fork(unsigned long, unsigned long, unsigned long, int =
__user *, int __user *, unsigned long);
 extern long do_fork(unsigned long, unsigned long, unsigned long, int =
__user *, int __user *);
 struct task_struct *fork_idle(int);
+struct mm_struct *copy_init_mm(void);
 extern pid_t kernel_thread(int (*fn)(void *), void *arg, unsigned long =
flags);
 extern long kernel_wait4(pid_t, int __user *, int, struct rusage *);
=20
diff --git a/init/main.c b/init/main.c
index 3b4ada11ed52..9a313efc80a6 100644
--- a/init/main.c
+++ b/init/main.c
@@ -724,6 +724,7 @@ asmlinkage __visible void __init start_kernel(void)
 	taskstats_init_early();
 	delayacct_init();
=20
+	patching_mm_init();
 	check_bugs();
=20
 	acpi_subsystem_init();
diff --git a/kernel/fork.c b/kernel/fork.c
index 1b27babc4c78..325d1a5ca903 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1249,9 +1249,9 @@ void mm_release(struct task_struct *tsk, struct =
mm_struct *mm)
  * Allocate a new mm structure and copy contents from the
  * mm structure of the passed in task structure.
  */
-static struct mm_struct *dup_mm(struct task_struct *tsk)
+static struct mm_struct *dup_mm(struct task_struct *tsk, struct =
mm_struct *oldmm)
 {
-	struct mm_struct *mm, *oldmm =3D current->mm;
+	struct mm_struct *mm;
 	int err;
=20
 	mm =3D allocate_mm();
@@ -1317,7 +1317,7 @@ static int copy_mm(unsigned long clone_flags, =
struct task_struct *tsk)
 	}
=20
 	retval =3D -ENOMEM;
-	mm =3D dup_mm(tsk);
+	mm =3D dup_mm(tsk, current->mm);
 	if (!mm)
 		goto fail_nomem;
=20
@@ -2082,6 +2082,11 @@ struct task_struct *fork_idle(int cpu)
 	return task;
 }
=20
+struct mm_struct *copy_init_mm(void)
+{
+	return dup_mm(NULL, &init_mm);
+}
+
 /*
  *  Ok, this is the main fork-routine.
  *
--=20
2.17.1

namit@sc2-haas01-esx0118:~/dev/linux-mainline$=20
