Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7D77B6B0003
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 05:25:14 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id w1-v6so13215566plq.8
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 02:25:14 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j38-v6si7465971pgj.613.2018.07.23.02.25.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 02:25:13 -0700 (PDT)
Subject: Patch "x86/mm: Factor out LDT init from context init" has been added to the 4.4-stable tree
From: <gregkh@linuxfoundation.org>
Date: Mon, 23 Jul 2018 11:22:48 +0200
In-Reply-To: <153156071778.10043.13239124304280929230.stgit@srivatsa-ubuntu>
Message-ID: <153233776877128@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 20160212210234.DB34FCC5@viggo.jf.intel.com, akpm@linux-foundation.org, amakhalov@vmware.com, bp@alien8.de, brgerst@gmail.com, dave.hansen@linux.intel.com, dave@sr71.net, dvlasenk@redhat.com, ganb@vmware.com, gregkh@linuxfoundation.org, hpa@zytor.com, linux-mm@kvack.org, luto@amacapital.net, matt.helsley@gmail.com, mingo@kernel.org, peterz@infradead.org, riel@redhat.com, rostedt@goodmis.org, srivatsa@csail.mit.edu, srivatsab@vmware.com, tglx@linutronix.de, torvalds@linux-foundation.org
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86/mm: Factor out LDT init from context init

to the 4.4-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-mm-factor-out-ldt-init-from-context-init.patch
and it can be found in the queue-4.4 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


>From foo@baz Mon Jul 23 10:04:05 CEST 2018
From: "Srivatsa S. Bhat" <srivatsa@csail.mit.edu>
Date: Sat, 14 Jul 2018 02:31:57 -0700
Subject: x86/mm: Factor out LDT init from context init
To: gregkh@linuxfoundation.org, stable@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave@sr71.net>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, "Matt Helsley \(VMware\)" <matt.helsley@gmail.com>, Alexey Makhalov <amakhalov@vmware.com>, Bo Gan <ganb@vmware.com>, matt.helsley@gmail.com, rostedt@goodmis.org, amakhalov@vmware.com, ganb@vmware.com, srivatsa@csail.mit.edu, srivatsab@vmware.com
Message-ID: <153156071778.10043.13239124304280929230.stgit@srivatsa-ubuntu>

From: Dave Hansen <dave.hansen@linux.intel.com>

commit 39a0526fb3f7d93433d146304278477eb463f8af upstream

The arch-specific mm_context_t is a great place to put
protection-key allocation state.

But, we need to initialize the allocation state because pkey 0 is
always "allocated".  All of the runtime initialization of
mm_context_t is done in *_ldt() manipulation functions.  This
renames the existing LDT functions like this:

	init_new_context() -> init_new_context_ldt()
	destroy_context() -> destroy_context_ldt()

and makes init_new_context() and destroy_context() available for
generic use.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dave Hansen <dave@sr71.net>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/20160212210234.DB34FCC5@viggo.jf.intel.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Srivatsa S. Bhat <srivatsa@csail.mit.edu>
Reviewed-by: Matt Helsley (VMware) <matt.helsley@gmail.com>
Reviewed-by: Alexey Makhalov <amakhalov@vmware.com>
Reviewed-by: Bo Gan <ganb@vmware.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---

 arch/x86/include/asm/mmu_context.h |   21 ++++++++++++++++-----
 arch/x86/kernel/ldt.c              |    4 ++--
 2 files changed, 18 insertions(+), 7 deletions(-)

--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -52,15 +52,15 @@ struct ldt_struct {
 /*
  * Used for LDT copy/destruction.
  */
-int init_new_context(struct task_struct *tsk, struct mm_struct *mm);
-void destroy_context(struct mm_struct *mm);
+int init_new_context_ldt(struct task_struct *tsk, struct mm_struct *mm);
+void destroy_context_ldt(struct mm_struct *mm);
 #else	/* CONFIG_MODIFY_LDT_SYSCALL */
-static inline int init_new_context(struct task_struct *tsk,
-				   struct mm_struct *mm)
+static inline int init_new_context_ldt(struct task_struct *tsk,
+				       struct mm_struct *mm)
 {
 	return 0;
 }
-static inline void destroy_context(struct mm_struct *mm) {}
+static inline void destroy_context_ldt(struct mm_struct *mm) {}
 #endif
 
 static inline void load_mm_ldt(struct mm_struct *mm)
@@ -102,6 +102,17 @@ static inline void enter_lazy_tlb(struct
 		this_cpu_write(cpu_tlbstate.state, TLBSTATE_LAZY);
 }
 
+static inline int init_new_context(struct task_struct *tsk,
+				   struct mm_struct *mm)
+{
+	init_new_context_ldt(tsk, mm);
+	return 0;
+}
+static inline void destroy_context(struct mm_struct *mm)
+{
+	destroy_context_ldt(mm);
+}
+
 extern void switch_mm(struct mm_struct *prev, struct mm_struct *next,
 		      struct task_struct *tsk);
 
--- a/arch/x86/kernel/ldt.c
+++ b/arch/x86/kernel/ldt.c
@@ -119,7 +119,7 @@ static void free_ldt_struct(struct ldt_s
  * we do not have to muck with descriptors here, that is
  * done in switch_mm() as needed.
  */
-int init_new_context(struct task_struct *tsk, struct mm_struct *mm)
+int init_new_context_ldt(struct task_struct *tsk, struct mm_struct *mm)
 {
 	struct ldt_struct *new_ldt;
 	struct mm_struct *old_mm;
@@ -160,7 +160,7 @@ out_unlock:
  *
  * 64bit: Don't touch the LDT register - we're already in the next thread.
  */
-void destroy_context(struct mm_struct *mm)
+void destroy_context_ldt(struct mm_struct *mm)
 {
 	free_ldt_struct(mm->context.ldt);
 	mm->context.ldt = NULL;


Patches currently in stable-queue which might be from srivatsa@csail.mit.edu are

queue-4.4/x86-bugs-rename-_rds-to-_ssbd.patch
queue-4.4/x86-speculation-remove-skylake-c2-from-speculation-control-microcode-blacklist.patch
queue-4.4/documentation-spec_ctrl-do-some-minor-cleanups.patch
queue-4.4/x86-speculation-handle-ht-correctly-on-amd.patch
queue-4.4/x86-cpufeatures-add-x86_feature_rds.patch
queue-4.4/x86-speculation-fix-up-array_index_nospec_mask-asm-constraint.patch
queue-4.4/x86-bugs-remove-x86_spec_ctrl_set.patch
queue-4.4/x86-speculation-add-asm-msr-index.h-dependency.patch
queue-4.4/x86-cpu-intel-add-knights-mill-to-intel-family.patch
queue-4.4/x86-bugs-concentrate-bug-detection-into-a-separate-function.patch
queue-4.4/x86-bugs-fix-the-parameters-alignment-and-missing-void.patch
queue-4.4/x86-bugs-whitelist-allowed-spec_ctrl-msr-values.patch
queue-4.4/prctl-add-force-disable-speculation.patch
queue-4.4/x86-cpufeatures-add-intel-feature-bits-for-speculation-control.patch
queue-4.4/x86-speculation-use-synthetic-bits-for-ibrs-ibpb-stibp.patch
queue-4.4/x86-cpuid-fix-up-virtual-ibrs-ibpb-stibp-feature-bits-on-intel.patch
queue-4.4/x86-nospec-simplify-alternative_msr_write.patch
queue-4.4/x86-bugs-intel-set-proper-cpu-features-and-setup-rds.patch
queue-4.4/x86-speculation-use-indirect-branch-prediction-barrier-in-context-switch.patch
queue-4.4/x86-process-correct-and-optimize-tif_blockstep-switch.patch
queue-4.4/x86-speculation-use-ibrs-if-available-before-calling-into-firmware.patch
queue-4.4/x86-speculation-rework-speculative_store_bypass_update.patch
queue-4.4/x86-asm-entry-32-simplify-pushes-of-zeroed-pt_regs-regs.patch
queue-4.4/x86-bugs-make-cpu_show_common-static.patch
queue-4.4/seccomp-use-pr_spec_force_disable.patch
queue-4.4/x86-cpufeatures-disentangle-ssbd-enumeration.patch
queue-4.4/x86-cpu-amd-fix-erratum-1076-cpb-bit.patch
queue-4.4/x86-speculation-correct-speculation-control-microcode-blacklist-again.patch
queue-4.4/x86-cpu-rename-merrifield2-to-moorefield.patch
queue-4.4/x86-cpu-make-alternative_msr_write-work-for-32-bit-code.patch
queue-4.4/x86-cpufeatures-disentangle-msr_spec_ctrl-enumeration-from-ibrs.patch
queue-4.4/x86-cpufeatures-add-cpuid_7_edx-cpuid-leaf.patch
queue-4.4/x86-bugs-fix-__ssb_select_mitigation-return-type.patch
queue-4.4/x86-cpufeatures-add-feature_zen.patch
queue-4.4/xen-set-cpu-capabilities-from-xen_start_kernel.patch
queue-4.4/x86-bugs-rename-ssbd_no-to-ssb_no.patch
queue-4.4/x86-speculation-add-prctl-for-speculative-store-bypass-mitigation.patch
queue-4.4/x86-msr-add-definitions-for-new-speculation-control-msrs.patch
queue-4.4/seccomp-enable-speculation-flaw-mitigations.patch
queue-4.4/x86-spectre_v2-don-t-check-microcode-versions-when-running-under-hypervisors.patch
queue-4.4/selftest-seccomp-fix-the-seccomp-2-signature.patch
queue-4.4/proc-use-underscores-for-ssbd-in-status.patch
queue-4.4/x86-bugs-amd-add-support-to-disable-rds-on-famh-if-requested.patch
queue-4.4/x86-cpufeature-blacklist-spec_ctrl-pred_cmd-on-early-spectre-v2-microcodes.patch
queue-4.4/x86-bugs-rework-spec_ctrl-base-and-mask-logic.patch
queue-4.4/seccomp-add-filter-flag-to-opt-out-of-ssb-mitigation.patch
queue-4.4/x86-speculation-make-seccomp-the-default-mode-for-speculative-store-bypass.patch
queue-4.4/x86-bugs-kvm-support-the-combination-of-guest-and-host-ibrs.patch
queue-4.4/selftest-seccomp-fix-the-flag-name-seccomp_filter_flag_tsync.patch
queue-4.4/x86-mm-factor-out-ldt-init-from-context-init.patch
queue-4.4/x86-speculation-create-spec-ctrl.h-to-avoid-include-hell.patch
queue-4.4/x86-cpufeatures-clean-up-spectre-v2-related-cpuid-flags.patch
queue-4.4/x86-bugs-expose-sys-..-spec_store_bypass.patch
queue-4.4/nospec-allow-getting-setting-on-non-current-task.patch
queue-4.4/x86-speculation-clean-up-various-spectre-related-details.patch
queue-4.4/x86-bugs-concentrate-bug-reporting-into-a-separate-function.patch
queue-4.4/x86-pti-mark-constant-arrays-as-__initconst.patch
queue-4.4/x86-cpufeatures-add-amd-feature-bits-for-speculation-control.patch
queue-4.4/x86-pti-do-not-enable-pti-on-cpus-which-are-not-vulnerable-to-meltdown.patch
queue-4.4/x86-mm-give-each-mm-tlb-flush-generation-a-unique-id.patch
queue-4.4/seccomp-move-speculation-migitation-control-to-arch-code.patch
queue-4.4/x86-speculation-move-firmware_restrict_branch_speculation_-from-c-to-cpp.patch
queue-4.4/x86-xen-zero-msr_ia32_spec_ctrl-before-suspend.patch
queue-4.4/x86-amd-don-t-set-x86_bug_sysret_ss_attrs-when-running-under-xen.patch
queue-4.4/x86-bugs-kvm-extend-speculation-control-for-virt_spec_ctrl.patch
queue-4.4/prctl-add-speculation-control-prctls.patch
queue-4.4/x86-process-optimize-tif_notsc-switch.patch
queue-4.4/x86-process-allow-runtime-control-of-speculative-store-bypass.patch
queue-4.4/x86-bugs-unify-x86_spec_ctrl_-set_guest-restore_host.patch
queue-4.4/x86-bugs-expose-x86_spec_ctrl_base-directly.patch
queue-4.4/x86-bugs-provide-boot-parameters-for-the-spec_store_bypass_disable-mitigation.patch
queue-4.4/x86-speculation-update-speculation-control-microcode-blacklist.patch
queue-4.4/proc-provide-details-on-speculation-flaw-mitigations.patch
queue-4.4/x86-speculation-add-basic-ibpb-indirect-branch-prediction-barrier-support.patch
queue-4.4/x86-speculation-kvm-implement-support-for-virt_spec_ctrl-ls_cfg.patch
queue-4.4/x86-entry-64-compat-clear-registers-for-compat-syscalls-to-reduce-speculation-attack-surface.patch
queue-4.4/x86-process-optimize-tif-checks-in-__switch_to_xtra.patch
queue-4.4/x86-speculation-add-virtualized-speculative-store-bypass-disable-support.patch
queue-4.4/x86-bugs-read-spec_ctrl-msr-during-boot-and-re-use-reserved-bits.patch
