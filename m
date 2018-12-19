Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id AACDE8E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 23:32:11 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id u63so435155oie.17
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 20:32:11 -0800 (PST)
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (mail-eopbgr710133.outbound.protection.outlook.com. [40.107.71.133])
        by mx.google.com with ESMTPS id v16si8087866otq.52.2018.12.18.20.32.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 18 Dec 2018 20:32:09 -0800 (PST)
From: Paul Burton <paul.burton@mips.com>
Subject: Re: Fixing MIPS delay slot emulation weakness?
Date: Wed, 19 Dec 2018 04:32:05 +0000
Message-ID: <20181219043155.nkaofln64lbp2gfz@pburton-laptop>
References: 
 <CALCETrWaWTupSp6V=XXhvExtFdS6ewx_0A7hiGfStqpeuqZn8g@mail.gmail.com>
In-Reply-To: 
 <CALCETrWaWTupSp6V=XXhvExtFdS6ewx_0A7hiGfStqpeuqZn8g@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <2767F97AF549844DA09ACB11DBD84E0A@namprd22.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Linux MIPS Mailing List <linux-mips@linux-mips.org>, LKML <linux-kernel@vger.kernel.org>, David Daney <david.daney@cavium.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Rich Felker <dalias@libc.org>

Hello,

On Sat, Dec 15, 2018 at 11:19:37AM -0800, Andy Lutomirski wrote:
> The really simple but possibly suboptimal fix is to get rid of
> VM_WRITE and to use get_user_pages(..., FOLL_FORCE) to write to it.

I actually wound up trying this route because it seemed like it would
produce a nice small patch that would be simple to backport, and we
could clean up mainline afterwards.

Unfortunately though things fail because get_user_pages() returns
-EFAULT for the delay slot emulation page, due to the !is_cow_mapping()
check in check_vma_flags(). This was introduced by commit cda540ace6a1
("mm: get_user_pages(write,force) refuse to COW in shared areas"). I'm a
little confused as to its behaviour...

is_cow_mapping() returns true if the VM_MAYWRITE flag is set and
VM_SHARED is not set - this suggests a private & potentially-writable
area, right? That fits in nicely with an area we'd want to COW. Why then
does check_vma_flags() use the inverse of this to indicate a shared
area? This fails if we have a private mapping where VM_MAYWRITE is not
set, but where FOLL_FORCE would otherwise provide a means of writing to
the memory.

If I remove this check in check_vma_flags() then I have a nice simple
patch which seems to work well, leaving the user mapping of the delay
slot emulation page non-writeable. I'm not sure I'm following the mm
innards here though - is there something I should change about the delay
slot page instead? Should I be marking it shared, even though it isn't
really? Or perhaps I'm misunderstanding what VM_MAYWRITE does & I should
set that - would that allow a user to use mprotect() to make the region
writeable..?

The work-in-progress patch can be seen below if it's helpful (and yes, I
realise that the modified condition in check_vma_flags() became
impossible & that removing it would be equivalent).

Or perhaps this is only confusing because it's 4:25am & I'm massively
jetlagged... :)

> A possibly nicer way to accomplish more or less the same thing would
> be to allocate the area with _install_special_mapping() and arrange to
> keep a reference to the struct page around.

I looked at this, but it ends up being a much bigger patch. Perhaps it
could be something to look into as a follow-on cleanup, though it
complicates things a little because we need to actually allocate the
page, preferrably only on demand, which is handled for us with the
current mmap_region() code.

Thanks,
    Paul

---
diff --git a/arch/mips/kernel/vdso.c b/arch/mips/kernel/vdso.c
index 48a9c6b90e07..9476efb54d18 100644
--- a/arch/mips/kernel/vdso.c
+++ b/arch/mips/kernel/vdso.c
@@ -126,8 +126,7 @@ int arch_setup_additional_pages(struct linux_binprm *bp=
rm, int uses_interp)
=20
 	/* Map delay slot emulation page */
 	base =3D mmap_region(NULL, STACK_TOP, PAGE_SIZE,
-			   VM_READ|VM_WRITE|VM_EXEC|
-			   VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
+			   VM_READ | VM_EXEC | VM_MAYREAD | VM_MAYEXEC,
 			   0, NULL);
 	if (IS_ERR_VALUE(base)) {
 		ret =3D base;
diff --git a/arch/mips/math-emu/dsemul.c b/arch/mips/math-emu/dsemul.c
index 5450f4d1c920..3aa8e3b90efb 100644
--- a/arch/mips/math-emu/dsemul.c
+++ b/arch/mips/math-emu/dsemul.c
@@ -67,11 +67,6 @@ struct emuframe {
=20
 static const int emupage_frame_count =3D PAGE_SIZE / sizeof(struct emufram=
e);
=20
-static inline __user struct emuframe *dsemul_page(void)
-{
-	return (__user struct emuframe *)STACK_TOP;
-}
-
 static int alloc_emuframe(void)
 {
 	mm_context_t *mm_ctx =3D &current->mm->context;
@@ -139,7 +134,7 @@ static void free_emuframe(int idx, struct mm_struct *mm=
)
=20
 static bool within_emuframe(struct pt_regs *regs)
 {
-	unsigned long base =3D (unsigned long)dsemul_page();
+	unsigned long base =3D STACK_TOP;
=20
 	if (regs->cp0_epc < base)
 		return false;
@@ -172,8 +167,8 @@ bool dsemul_thread_cleanup(struct task_struct *tsk)
=20
 bool dsemul_thread_rollback(struct pt_regs *regs)
 {
-	struct emuframe __user *fr;
-	int fr_idx;
+	struct emuframe fr;
+	int fr_idx, ret;
=20
 	/* Do nothing if we're not executing from a frame */
 	if (!within_emuframe(regs))
@@ -183,7 +178,12 @@ bool dsemul_thread_rollback(struct pt_regs *regs)
 	fr_idx =3D atomic_read(&current->thread.bd_emu_frame);
 	if (fr_idx =3D=3D BD_EMUFRAME_NONE)
 		return false;
-	fr =3D &dsemul_page()[fr_idx];
+
+	ret =3D access_process_vm(current,
+				STACK_TOP + (fr_idx * sizeof(fr)),
+				&fr, sizeof(fr), FOLL_FORCE);
+	if (WARN_ON(ret !=3D sizeof(fr)))
+		return false;
=20
 	/*
 	 * If the PC is at the emul instruction, roll back to the branch. If
@@ -192,9 +192,9 @@ bool dsemul_thread_rollback(struct pt_regs *regs)
 	 * then something is amiss & the user has branched into some other area
 	 * of the emupage - we'll free the allocated frame anyway.
 	 */
-	if (msk_isa16_mode(regs->cp0_epc) =3D=3D (unsigned long)&fr->emul)
+	if (msk_isa16_mode(regs->cp0_epc) =3D=3D (unsigned long)&fr.emul)
 		regs->cp0_epc =3D current->thread.bd_emu_branch_pc;
-	else if (msk_isa16_mode(regs->cp0_epc) =3D=3D (unsigned long)&fr->badinst=
)
+	else if (msk_isa16_mode(regs->cp0_epc) =3D=3D (unsigned long)&fr.badinst)
 		regs->cp0_epc =3D current->thread.bd_emu_cont_pc;
=20
 	atomic_set(&current->thread.bd_emu_frame, BD_EMUFRAME_NONE);
@@ -214,8 +214,8 @@ int mips_dsemul(struct pt_regs *regs, mips_instruction =
ir,
 {
 	int isa16 =3D get_isa16_mode(regs->cp0_epc);
 	mips_instruction break_math;
-	struct emuframe __user *fr;
-	int err, fr_idx;
+	struct emuframe fr;
+	int fr_idx, ret;
=20
 	/* NOP is easy */
 	if (ir =3D=3D 0)
@@ -250,27 +250,31 @@ int mips_dsemul(struct pt_regs *regs, mips_instructio=
n ir,
 		fr_idx =3D alloc_emuframe();
 	if (fr_idx =3D=3D BD_EMUFRAME_NONE)
 		return SIGBUS;
-	fr =3D &dsemul_page()[fr_idx];
=20
 	/* Retrieve the appropriately encoded break instruction */
 	break_math =3D BREAK_MATH(isa16);
=20
 	/* Write the instructions to the frame */
 	if (isa16) {
-		err =3D __put_user(ir >> 16,
-				 (u16 __user *)(&fr->emul));
-		err |=3D __put_user(ir & 0xffff,
-				  (u16 __user *)((long)(&fr->emul) + 2));
-		err |=3D __put_user(break_math >> 16,
-				  (u16 __user *)(&fr->badinst));
-		err |=3D __put_user(break_math & 0xffff,
-				  (u16 __user *)((long)(&fr->badinst) + 2));
+		union mips_instruction _emul =3D {
+			.halfword =3D { ir >> 16, ir }
+		};
+		union mips_instruction _badinst =3D {
+			.halfword =3D { break_math >> 16, break_math }
+		};
+
+		fr.emul =3D _emul.word;
+		fr.badinst =3D _badinst.word;
 	} else {
-		err =3D __put_user(ir, &fr->emul);
-		err |=3D __put_user(break_math, &fr->badinst);
+		fr.emul =3D ir;
+		fr.badinst =3D break_math;
 	}
=20
-	if (unlikely(err)) {
+	/* Write the frame to user memory */
+	ret =3D access_process_vm(current,
+				STACK_TOP + (fr_idx * sizeof(fr)),
+				&fr, sizeof(fr), FOLL_FORCE | FOLL_WRITE);
+	if (WARN_ON(ret !=3D sizeof(fr))) {
 		MIPS_FPU_EMU_INC_STATS(errors);
 		free_emuframe(fr_idx, current->mm);
 		return SIGBUS;
@@ -282,10 +286,7 @@ int mips_dsemul(struct pt_regs *regs, mips_instruction=
 ir,
 	atomic_set(&current->thread.bd_emu_frame, fr_idx);
=20
 	/* Change user register context to execute the frame */
-	regs->cp0_epc =3D (unsigned long)&fr->emul | isa16;
-
-	/* Ensure the icache observes our newly written frame */
-	flush_cache_sigtramp((unsigned long)&fr->emul);
+	regs->cp0_epc =3D (unsigned long)&fr.emul | isa16;
=20
 	return 0;
 }
diff --git a/mm/gup.c b/mm/gup.c
index f76e77a2d34b..9a1bc941dcb9 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -587,7 +587,7 @@ static int check_vma_flags(struct vm_area_struct *vma, =
unsigned long gup_flags)
 			 * Anon pages in shared mappings are surprising: now
 			 * just reject it.
 			 */
-			if (!is_cow_mapping(vm_flags))
+			if ((vm_flags & VM_SHARED) && !is_cow_mapping(vm_flags))
 				return -EFAULT;
 		}
 	} else if (!(vm_flags & VM_READ)) {
