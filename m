Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 64A4C82F87
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 18:33:15 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so87170394pac.0
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 15:33:15 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id af8si11910079pbd.110.2015.10.01.15.33.14
        for <linux-mm@kvack.org>;
        Thu, 01 Oct 2015 15:33:14 -0700 (PDT)
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174913.AF5FEA6D@viggo.jf.intel.com>
 <20150920085554.GA21906@gmail.com> <55FF88BA.6080006@sr71.net>
 <20150924094956.GA30349@gmail.com> <56044A88.7030203@sr71.net>
 <20151001111718.GA25333@gmail.com>
 <CAGXu5j+j92EPEwv9O4cX92zJDTyBEz3WtQ2CDHT0KmqJ6bCmGQ@mail.gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <560DB4A6.6050107@sr71.net>
Date: Thu, 1 Oct 2015 15:33:10 -0700
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+j92EPEwv9O4cX92zJDTyBEz3WtQ2CDHT0KmqJ6bCmGQ@mail.gmail.com>
Content-Type: multipart/mixed;
 boundary="------------080603020207040402010001"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>, Ingo Molnar <mingo@kernel.org>
Cc: "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>

This is a multi-part message in MIME format.
--------------080603020207040402010001
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

On 10/01/2015 01:39 PM, Kees Cook wrote:
> On Thu, Oct 1, 2015 at 4:17 AM, Ingo Molnar <mingo@kernel.org> wrote:
>> So could we try to add an (opt-in) kernel option that enables this transparently
>> and automatically for all PROT_EXEC && !PROT_WRITE mappings, without any
>> user-space changes and syscalls necessary?
> 
> I would like this very much. :)

Here it is in a quite fugly form (well, it's not opt-in).  Init crashes
if I boot with this, though.

I'll see if I can turn it in to a bit more of an opt-in and see what's
actually going wrong.



--------------080603020207040402010001
Content-Type: text/x-patch;
 name="pkeys-95-rewire-mprotect-to-use-pkeys.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="pkeys-95-rewire-mprotect-to-use-pkeys.patch"



---

 b/arch/x86/include/asm/fpu/internal.h |    4 ++++
 b/arch/x86/kernel/fpu/core.c          |    4 ++++
 b/arch/x86/kernel/fpu/xstate.c        |   16 +++++++++++++++-
 b/arch/x86/mm/fault.c                 |    8 ++++++--
 b/include/linux/mm_types.h            |    1 +
 b/kernel/fork.c                       |    3 ++-
 b/kernel/sched/core.c                 |    3 +++
 b/mm/mmap.c                           |    8 +++++++-
 b/mm/mprotect.c                       |   27 ++++++++++++++++++++++++++-
 9 files changed, 68 insertions(+), 6 deletions(-)

diff -puN mm/mprotect.c~pkeys-95-rewire-mprotect-to-use-pkeys mm/mprotect.c
--- a/mm/mprotect.c~pkeys-95-rewire-mprotect-to-use-pkeys	2015-10-01 15:21:25.183874598 -0700
+++ b/mm/mprotect.c	2015-10-01 15:28:14.741262888 -0700
@@ -24,6 +24,7 @@
 #include <linux/migrate.h>
 #include <linux/perf_event.h>
 #include <linux/ksm.h>
+#include <linux/debugfs.h>
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 #include <asm/cacheflush.h>
@@ -453,10 +454,34 @@ out:
 	return error;
 }
 
+u32 __read_mostly mprotect_hack_pkey = 1;
+int mprotect_hack_pkey_init(void)
+{
+       debugfs_create_u32("mprotect_hack_pkey",  S_IRUSR | S_IWUSR,
+                       NULL, &mprotect_hack_pkey);
+       return 0;
+}
+late_initcall(mprotect_hack_pkey_init);
+
+int pkey_for_access_protect = 1;
+int pkey_for_write_protect = 2;
 SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 		unsigned long, prot)
 {
-	return do_mprotect_key(start, len, prot, 0);
+	int ret;
+	unsigned long newprot = prot;
+	u32 pkey_hack = READ_ONCE(mprotect_hack_pkey);
+	u16 pkey = 0;
+
+	if (!pkey_hack)
+		return do_mprotect_key(start, len, prot, 0);
+
+	if ((prot & PROT_EXEC) && !(prot & PROT_WRITE))
+		pkey = pkey_for_access_protect;
+
+	ret = do_mprotect_key(start, len, newprot, pkey);
+
+	return ret;
 }
 
 SYSCALL_DEFINE4(mprotect_key, unsigned long, start, size_t, len,
diff -puN include/linux/mm_types.h~pkeys-95-rewire-mprotect-to-use-pkeys include/linux/mm_types.h
--- a/include/linux/mm_types.h~pkeys-95-rewire-mprotect-to-use-pkeys	2015-10-01 15:21:25.185874687 -0700
+++ b/include/linux/mm_types.h	2015-10-01 15:21:25.227876573 -0700
@@ -486,6 +486,7 @@ struct mm_struct {
 	/* address of the bounds directory */
 	void __user *bd_addr;
 #endif
+	u32 fake_mprotect_pkey;
 };
 
 static inline void mm_init_cpumask(struct mm_struct *mm)
diff -puN kernel/fork.c~pkeys-95-rewire-mprotect-to-use-pkeys kernel/fork.c
--- a/kernel/fork.c~pkeys-95-rewire-mprotect-to-use-pkeys	2015-10-01 15:21:25.187874777 -0700
+++ b/kernel/fork.c	2015-10-01 15:21:25.228876618 -0700
@@ -927,6 +927,7 @@ static struct mm_struct *dup_mm(struct t
 
 	mm->hiwater_rss = get_mm_rss(mm);
 	mm->hiwater_vm = mm->total_vm;
+	mm->fake_mprotect_pkey = 0;
 
 	if (mm->binfmt && !try_module_get(mm->binfmt->module))
 		goto free_pt;
@@ -1700,7 +1701,7 @@ long _do_fork(unsigned long clone_flags,
 	struct task_struct *p;
 	int trace = 0;
 	long nr;
-
+	//printk("%s()\n", __func__);
 	/*
 	 * Determine whether and which event to report to ptracer.  When
 	 * called from kernel_thread or CLONE_UNTRACED is explicitly
diff -puN arch/x86/kernel/fpu/xstate.c~pkeys-95-rewire-mprotect-to-use-pkeys arch/x86/kernel/fpu/xstate.c
--- a/arch/x86/kernel/fpu/xstate.c~pkeys-95-rewire-mprotect-to-use-pkeys	2015-10-01 15:21:25.197875226 -0700
+++ b/arch/x86/kernel/fpu/xstate.c	2015-10-01 15:21:25.228876618 -0700
@@ -41,6 +41,17 @@ u64 xfeatures_mask __read_mostly;
 static unsigned int xstate_offsets[XFEATURE_MAX] = { [ 0 ... XFEATURE_MAX - 1] = -1};
 static unsigned int xstate_sizes[XFEATURE_MAX]   = { [ 0 ... XFEATURE_MAX - 1] = -1};
 static unsigned int xstate_comp_offsets[sizeof(xfeatures_mask)*8];
+void hack_fpstate_for_pkru(struct xregs_state *xstate)
+{
+        void *__pkru;
+        xstate->header.xfeatures |= XFEATURE_MASK_PKRU;
+        __pkru = ((char *)xstate) + xstate_offsets[XFEATURE_PKRU];
+	/*
+	 * Access disable PKEY 1 and
+	 * Write disable PKEY 2
+	 */
+        *(u32 *)__pkru = 0x00000024;
+}
 
 /*
  * Clear all of the X86_FEATURE_* bits that are unavailable
@@ -321,7 +332,10 @@ static void __init setup_init_fpu_buf(vo
 		init_fpstate.xsave.header.xcomp_bv = (u64)1 << 63 | xfeatures_mask;
 		init_fpstate.xsave.header.xfeatures = xfeatures_mask;
 	}
-
+	{
+		void hack_fpstate_for_pkru(struct xregs_state *xstate);
+		hack_fpstate_for_pkru(&init_fpstate.xsave);
+	}
 	/*
 	 * Init all the features state with header_bv being 0x0
 	 */
diff -puN arch/x86/mm/fault.c~pkeys-95-rewire-mprotect-to-use-pkeys arch/x86/mm/fault.c
--- a/arch/x86/mm/fault.c~pkeys-95-rewire-mprotect-to-use-pkeys	2015-10-01 15:21:25.204875540 -0700
+++ b/arch/x86/mm/fault.c	2015-10-01 15:21:25.229876663 -0700
@@ -902,8 +902,10 @@ static inline bool bad_area_access_from_
 {
 	if (!boot_cpu_has(X86_FEATURE_OSPKE))
 		return false;
-	if (error_code & PF_PK)
+	if (error_code & PF_PK) {
+		printk("%s() PF_PK\n", __func__);
 		return true;
+	}
 	/* this checks permission keys on the VMA: */
 	if (!arch_vma_access_permitted(vma, (error_code & PF_WRITE)))
 		return true;
@@ -1095,8 +1097,10 @@ access_error(unsigned long error_code, s
 	 * to, for instance, confuse a protection-key-denied
 	 * write with one for which we should do a COW.
 	 */
-	if (error_code & PF_PK)
+	if (error_code & PF_PK) {
+		printk("%s() PF_PK\n", __func__);
 		return 1;
+	}
 	/*
 	 * Make sure to check the VMA so that we do not perform
 	 * faults just to hit a PF_PK as soon as we fill in a
diff -puN arch/x86/kernel/fpu/core.c~pkeys-95-rewire-mprotect-to-use-pkeys arch/x86/kernel/fpu/core.c
--- a/arch/x86/kernel/fpu/core.c~pkeys-95-rewire-mprotect-to-use-pkeys	2015-10-01 15:21:25.207875675 -0700
+++ b/arch/x86/kernel/fpu/core.c	2015-10-01 15:21:25.229876663 -0700
@@ -262,6 +262,10 @@ static void fpu_copy(struct fpu *dst_fpu
 		fpregs_deactivate(src_fpu);
 	}
 	preempt_enable();
+	{
+		void hack_fpstate_for_pkru(struct xregs_state *xstate);
+		hack_fpstate_for_pkru(&dst_fpu->state.xsave);
+	}
 }
 
 int fpu__copy(struct fpu *dst_fpu, struct fpu *src_fpu)
diff -puN arch/x86/include/asm/fpu/internal.h~pkeys-95-rewire-mprotect-to-use-pkeys arch/x86/include/asm/fpu/internal.h
--- a/arch/x86/include/asm/fpu/internal.h~pkeys-95-rewire-mprotect-to-use-pkeys	2015-10-01 15:21:25.209875765 -0700
+++ b/arch/x86/include/asm/fpu/internal.h	2015-10-01 15:21:25.230876707 -0700
@@ -335,6 +335,10 @@ static inline void copy_xregs_to_kernel(
 
 	/* We should never fault when copying to a kernel buffer: */
 	WARN_ON_FPU(err);
+	{
+		void hack_fpstate_for_pkru(struct xregs_state *xstate);
+		hack_fpstate_for_pkru(xstate);
+	}
 }
 
 /*
diff -puN kernel/sched/core.c~pkeys-95-rewire-mprotect-to-use-pkeys kernel/sched/core.c
--- a/kernel/sched/core.c~pkeys-95-rewire-mprotect-to-use-pkeys	2015-10-01 15:21:25.216876079 -0700
+++ b/kernel/sched/core.c	2015-10-01 15:21:25.232876797 -0700
@@ -2644,6 +2644,9 @@ context_switch(struct rq *rq, struct tas
 	/* Here we just switch the register state and the stack. */
 	switch_to(prev, next, prev);
 	barrier();
+	if (read_pkru() && printk_ratelimit()) {
+		printk("pid: %d pkru: 0x%x\n", current->pid, read_pkru());
+	}
 
 	return finish_task_switch(prev);
 }
diff -puN mm/mmap.c~pkeys-95-rewire-mprotect-to-use-pkeys mm/mmap.c
--- a/mm/mmap.c~pkeys-95-rewire-mprotect-to-use-pkeys	2015-10-01 15:21:25.223876393 -0700
+++ b/mm/mmap.c	2015-10-01 15:25:44.327508557 -0700
@@ -1267,6 +1267,8 @@ unsigned long do_mmap(struct file *file,
 			unsigned long flags, vm_flags_t vm_flags,
 			unsigned long pgoff, unsigned long *populate)
 {
+	extern u16 pkey_for_access_protect;
+	u16 pkey = 0;
 	struct mm_struct *mm = current->mm;
 
 	*populate = 0;
@@ -1311,7 +1313,11 @@ unsigned long do_mmap(struct file *file,
 	 * to. we assume access permissions have been handled by the open
 	 * of the memory object, so we don't do any here.
 	 */
-	vm_flags |= calc_vm_prot_bits(prot, 0) | calc_vm_flag_bits(flags) |
+	if ((prot & PROT_EXEC) && !(prot & PROT_WRITE)) {
+		pkey = pkey_for_access_protect;
+		trace_printk("hacking mmap() to use pkey %d\n", pkey);
+	}
+	vm_flags |= calc_vm_prot_bits(prot, pkey) | calc_vm_flag_bits(flags) |
 			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
 
 	if (flags & MAP_LOCKED)
_

--------------080603020207040402010001--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
