Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9AC2E828DF
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 13:17:52 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id ho8so45058020pac.2
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 10:17:52 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id g82si22729958pfj.135.2016.01.29.10.17.28
        for <linux-mm@kvack.org>;
        Fri, 29 Jan 2016 10:17:28 -0800 (PST)
Subject: [PATCH 28/31] x86, fpu: allow setting of XSAVE state
From: Dave Hansen <dave@sr71.net>
Date: Fri, 29 Jan 2016 10:17:23 -0800
References: <20160129181642.98E7D468@viggo.jf.intel.com>
In-Reply-To: <20160129181642.98E7D468@viggo.jf.intel.com>
Message-Id: <20160129181723.34A0D9EF@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

We want to modify the Protection Key rights inside the kernel, so
we need to change PKRU's contents.  But, if we do a plain
'wrpkru', when we return to userspace we might do an XRSTOR and
wipe out the kernel's 'wrpkru'.  So, we need to go after PKRU in
the xsave buffer.

We do this by:
1. Ensuring that we have the XSAVE registers (fpregs) in the
   kernel FPU buffer (fpstate)
2. Looking up the location of a given state in the buffer
3. Filling in the stat
4. Ensuring that the hardware knows that state is present there
   (basically that the 'init optimization' is not in place).
5. Copying the newly-modified state back to the registers if
   necessary.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---

 b/arch/x86/include/asm/fpu/internal.h |    2 
 b/arch/x86/kernel/fpu/core.c          |   63 +++++++++++++++++++++
 b/arch/x86/kernel/fpu/xstate.c        |   98 +++++++++++++++++++++++++++++++++-
 3 files changed, 161 insertions(+), 2 deletions(-)

diff -puN arch/x86/include/asm/fpu/internal.h~pkeys-76-xsave-set arch/x86/include/asm/fpu/internal.h
--- a/arch/x86/include/asm/fpu/internal.h~pkeys-76-xsave-set	2016-01-28 15:52:29.186808572 -0800
+++ b/arch/x86/include/asm/fpu/internal.h	2016-01-28 15:52:29.193808893 -0800
@@ -24,6 +24,8 @@
 extern void fpu__activate_curr(struct fpu *fpu);
 extern void fpu__activate_fpstate_read(struct fpu *fpu);
 extern void fpu__activate_fpstate_write(struct fpu *fpu);
+extern void fpu__current_fpstate_write_begin(void);
+extern void fpu__current_fpstate_write_end(void);
 extern void fpu__save(struct fpu *fpu);
 extern void fpu__restore(struct fpu *fpu);
 extern int  fpu__restore_sig(void __user *buf, int ia32_frame);
diff -puN arch/x86/kernel/fpu/core.c~pkeys-76-xsave-set arch/x86/kernel/fpu/core.c
--- a/arch/x86/kernel/fpu/core.c~pkeys-76-xsave-set	2016-01-28 15:52:29.188808664 -0800
+++ b/arch/x86/kernel/fpu/core.c	2016-01-28 15:52:29.194808939 -0800
@@ -352,6 +352,69 @@ void fpu__activate_fpstate_write(struct
 }
 
 /*
+ * This function must be called before we write the current
+ * task's fpstate.
+ *
+ * This call gets the current FPU register state and moves
+ * it in to the 'fpstate'.  Preemption is disabled so that
+ * no writes to the 'fpstate' can occur from context
+ * swiches.
+ *
+ * Must be followed by a fpu__current_fpstate_write_end().
+ */
+void fpu__current_fpstate_write_begin(void)
+{
+	struct fpu *fpu = &current->thread.fpu;
+
+	/*
+	 * Ensure that the context-switching code does not write
+	 * over the fpstate while we are doing our update.
+	 */
+	preempt_disable();
+
+	/*
+	 * Move the fpregs in to the fpu's 'fpstate'.
+	 */
+	fpu__activate_fpstate_read(fpu);
+
+	/*
+	 * The caller is about to write to 'fpu'.  Ensure that no
+	 * CPU thinks that its fpregs match the fpstate.  This
+	 * ensures we will not be lazy and skip a XRSTOR in the
+	 * future.
+	 */
+	fpu->last_cpu = -1;
+}
+
+/*
+ * This function must be paired with fpu__current_fpstate_write_begin()
+ *
+ * This will ensure that the modified fpstate gets placed back in
+ * the fpregs if necessary.
+ *
+ * Note: This function may be called whether or not an _actual_
+ * write to the fpstate occurred.
+ */
+void fpu__current_fpstate_write_end(void)
+{
+	struct fpu *fpu = &current->thread.fpu;
+
+	/*
+	 * 'fpu' now has an updated copy of the state, but the
+	 * registers may still be out of date.  Update them with
+	 * an XRSTOR if they are active.
+	 */
+	if (fpregs_active())
+		copy_kernel_to_fpregs(&fpu->state);
+
+	/*
+	 * Our update is done and the fpregs/fpstate are in sync
+	 * if necessary.  Context switches can happen again.
+	 */
+	preempt_enable();
+}
+
+/*
  * 'fpu__restore()' is called to copy FPU registers from
  * the FPU fpstate to the live hw registers and to activate
  * access to the hardware registers, so that FPU instructions
diff -puN arch/x86/kernel/fpu/xstate.c~pkeys-76-xsave-set arch/x86/kernel/fpu/xstate.c
--- a/arch/x86/kernel/fpu/xstate.c~pkeys-76-xsave-set	2016-01-28 15:52:29.190808756 -0800
+++ b/arch/x86/kernel/fpu/xstate.c	2016-01-28 15:52:29.194808939 -0800
@@ -679,6 +679,19 @@ void fpu__resume_cpu(void)
 }
 
 /*
+ * Given an xstate feature mask, calculate where in the xsave
+ * buffer the state is.  Callers should ensure that the buffer
+ * is valid.
+ *
+ * Note: does not work for compacted buffers.
+ */
+void *__raw_xsave_addr(struct xregs_state *xsave, int xstate_feature_mask)
+{
+	int feature_nr = fls64(xstate_feature_mask) - 1;
+
+	return (void *)xsave + xstate_comp_offsets[feature_nr];
+}
+/*
  * Given the xsave area and a state inside, this function returns the
  * address of the state.
  *
@@ -698,7 +711,6 @@ void fpu__resume_cpu(void)
  */
 void *get_xsave_addr(struct xregs_state *xsave, int xstate_feature)
 {
-	int feature_nr = fls64(xstate_feature) - 1;
 	/*
 	 * Do we even *have* xsave state?
 	 */
@@ -726,7 +738,7 @@ void *get_xsave_addr(struct xregs_state
 	if (!(xsave->header.xfeatures & xstate_feature))
 		return NULL;
 
-	return (void *)xsave + xstate_comp_offsets[feature_nr];
+	return __raw_xsave_addr(xsave, xstate_feature);
 }
 EXPORT_SYMBOL_GPL(get_xsave_addr);
 
@@ -761,3 +773,85 @@ const void *get_xsave_field_ptr(int xsav
 
 	return get_xsave_addr(&fpu->state.xsave, xsave_state);
 }
+
+
+/*
+ * Set xfeatures (aka XSTATE_BV) bit for a feature that we want
+ * to take out of its "init state".  This will ensure that an
+ * XRSTOR actually restores the state.
+ */
+static void fpu__xfeature_set_non_init(struct xregs_state *xsave,
+		int xstate_feature_mask)
+{
+	xsave->header.xfeatures |= xstate_feature_mask;
+}
+
+/*
+ * This function is safe to call whether the FPU is in use or not.
+ *
+ * Note that this only works on the current task.
+ *
+ * Inputs:
+ *	@xsave_state: state which is defined in xsave.h (e.g. XFEATURE_MASK_FP,
+ *	XFEATURE_MASK_SSE, etc...)
+ *	@xsave_state_ptr: a pointer to a copy of the state that you would
+ *	like written in to the current task's FPU xsave state.  This pointer
+ *	must not be located in the current tasks's xsave area.
+ * Output:
+ *	address of the state in the xsave area or NULL if the state
+ *	is not present or is in its 'init state'.
+ */
+static void fpu__xfeature_set_state(int xstate_feature_mask,
+		void *xstate_feature_src, size_t len)
+{
+	struct xregs_state *xsave = &current->thread.fpu.state.xsave;
+	struct fpu *fpu = &current->thread.fpu;
+	void *dst;
+
+	if (!boot_cpu_has(X86_FEATURE_XSAVE)) {
+		WARN_ONCE(1, "%s() attempted with no xsave support", __func__);
+		return;
+	}
+
+	/*
+	 * Tell the FPU code that we need the FPU state to be in
+	 * 'fpu' (not in the registers), and that we need it to
+	 * be stable while we write to it.
+	 */
+	fpu__current_fpstate_write_begin();
+
+	/*
+	 * This method *WILL* *NOT* work for compact-format
+	 * buffers.  If the 'xstate_feature_mask' is unset in
+	 * xcomp_bv then we may need to move other feature state
+	 * "up" in the buffer.
+	 */
+	if (xsave->header.xcomp_bv & xstate_feature_mask) {
+		WARN_ON_ONCE(1);
+		goto out;
+	}
+
+	/* find the location in the xsave buffer of the desired state */
+	dst = __raw_xsave_addr(&fpu->state.xsave, xstate_feature_mask);
+
+	/*
+	 * Make sure that the pointer being passed in did not
+	 * come from the xsave buffer itself.
+	 */
+	WARN_ONCE(xstate_feature_src == dst, "set from xsave buffer itself");
+
+	/* put the caller-provided data in the location */
+	memcpy(dst, xstate_feature_src, len);
+
+	/*
+	 * Mark the xfeature so that the CPU knows there is state
+	 * in the buffer now.
+	 */
+	fpu__xfeature_set_non_init(xsave, xstate_feature_mask);
+out:
+	/*
+	 * We are done writing to the 'fpu'.  Reenable preeption
+	 * and (possibly) move the fpstate back in to the fpregs.
+	 */
+	fpu__current_fpstate_write_end();
+}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
