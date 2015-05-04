Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 298126B006E
	for <linux-mm@kvack.org>; Mon,  4 May 2015 04:23:21 -0400 (EDT)
Received: by widdi4 with SMTP id di4so101909064wid.0
        for <linux-mm@kvack.org>; Mon, 04 May 2015 01:23:20 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id tm3si21526108wjc.126.2015.05.04.01.23.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 04 May 2015 01:23:18 -0700 (PDT)
From: Juergen Gross <jgross@suse.com>
Subject: [RESEND Patch V3 01/15] xen: sync with xen headers
Date: Mon,  4 May 2015 10:23:01 +0200
Message-Id: <1430727795-25133-2-git-send-email-jgross@suse.com>
In-Reply-To: <1430727795-25133-1-git-send-email-jgross@suse.com>
References: <1430727795-25133-1-git-send-email-jgross@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Juergen Gross <jgross@suse.com>

Use the newest headers from the xen tree to get some new structure
layouts.

Signed-off-by: Juergen Gross <jgross@suse.com>
Reviewed-by: David Vrabel <david.vrabel@citrix.com>
---
 arch/x86/include/asm/xen/interface.h | 96 ++++++++++++++++++++++++++++++++----
 include/xen/interface/xen.h          | 10 ++--
 2 files changed, 93 insertions(+), 13 deletions(-)

diff --git a/arch/x86/include/asm/xen/interface.h b/arch/x86/include/asm/xen/interface.h
index 3400dba..3b88eea 100644
--- a/arch/x86/include/asm/xen/interface.h
+++ b/arch/x86/include/asm/xen/interface.h
@@ -3,12 +3,38 @@
  *
  * Guest OS interface to x86 Xen.
  *
- * Copyright (c) 2004, K A Fraser
+ * Permission is hereby granted, free of charge, to any person obtaining a copy
+ * of this software and associated documentation files (the "Software"), to
+ * deal in the Software without restriction, including without limitation the
+ * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
+ * sell copies of the Software, and to permit persons to whom the Software is
+ * furnished to do so, subject to the following conditions:
+ *
+ * The above copyright notice and this permission notice shall be included in
+ * all copies or substantial portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
+ * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
+ * DEALINGS IN THE SOFTWARE.
+ *
+ * Copyright (c) 2004-2006, K A Fraser
  */
 
 #ifndef _ASM_X86_XEN_INTERFACE_H
 #define _ASM_X86_XEN_INTERFACE_H
 
+/*
+ * XEN_GUEST_HANDLE represents a guest pointer, when passed as a field
+ * in a struct in memory.
+ * XEN_GUEST_HANDLE_PARAM represent a guest pointer, when passed as an
+ * hypercall argument.
+ * XEN_GUEST_HANDLE_PARAM and XEN_GUEST_HANDLE are the same on X86 but
+ * they might not be on other architectures.
+ */
 #ifdef __XEN__
 #define __DEFINE_GUEST_HANDLE(name, type) \
     typedef struct { type *p; } __guest_handle_ ## name
@@ -88,13 +114,16 @@ DEFINE_GUEST_HANDLE(xen_ulong_t);
  * start of the GDT because some stupid OSes export hard-coded selector values
  * in their ABI. These hard-coded values are always near the start of the GDT,
  * so Xen places itself out of the way, at the far end of the GDT.
+ *
+ * NB The LDT is set using the MMUEXT_SET_LDT op of HYPERVISOR_mmuext_op
  */
 #define FIRST_RESERVED_GDT_PAGE  14
 #define FIRST_RESERVED_GDT_BYTE  (FIRST_RESERVED_GDT_PAGE * 4096)
 #define FIRST_RESERVED_GDT_ENTRY (FIRST_RESERVED_GDT_BYTE / 8)
 
 /*
- * Send an array of these to HYPERVISOR_set_trap_table()
+ * Send an array of these to HYPERVISOR_set_trap_table().
+ * Terminate the array with a sentinel entry, with traps[].address==0.
  * The privilege level specifies which modes may enter a trap via a software
  * interrupt. On x86/64, since rings 1 and 2 are unavailable, we allocate
  * privilege levels as follows:
@@ -118,10 +147,41 @@ struct trap_info {
 DEFINE_GUEST_HANDLE_STRUCT(trap_info);
 
 struct arch_shared_info {
-    unsigned long max_pfn;                  /* max pfn that appears in table */
-    /* Frame containing list of mfns containing list of mfns containing p2m. */
-    unsigned long pfn_to_mfn_frame_list_list;
-    unsigned long nmi_reason;
+	/*
+	 * Number of valid entries in the p2m table(s) anchored at
+	 * pfn_to_mfn_frame_list_list and/or p2m_vaddr.
+	 */
+	unsigned long max_pfn;
+	/*
+	 * Frame containing list of mfns containing list of mfns containing p2m.
+	 * A value of 0 indicates it has not yet been set up, ~0 indicates it
+	 * has been set to invalid e.g. due to the p2m being too large for the
+	 * 3-level p2m tree. In this case the linear mapper p2m list anchored
+	 * at p2m_vaddr is to be used.
+	 */
+	xen_pfn_t pfn_to_mfn_frame_list_list;
+	unsigned long nmi_reason;
+	/*
+	 * Following three fields are valid if p2m_cr3 contains a value
+	 * different from 0.
+	 * p2m_cr3 is the root of the address space where p2m_vaddr is valid.
+	 * p2m_cr3 is in the same format as a cr3 value in the vcpu register
+	 * state and holds the folded machine frame number (via xen_pfn_to_cr3)
+	 * of a L3 or L4 page table.
+	 * p2m_vaddr holds the virtual address of the linear p2m list. All
+	 * entries in the range [0...max_pfn[ are accessible via this pointer.
+	 * p2m_generation will be incremented by the guest before and after each
+	 * change of the mappings of the p2m list. p2m_generation starts at 0
+	 * and a value with the least significant bit set indicates that a
+	 * mapping update is in progress. This allows guest external software
+	 * (e.g. in Dom0) to verify that read mappings are consistent and
+	 * whether they have changed since the last check.
+	 * Modifying a p2m element in the linear p2m list is allowed via an
+	 * atomic write only.
+	 */
+	unsigned long p2m_cr3;		/* cr3 value of the p2m address space */
+	unsigned long p2m_vaddr;	/* virtual address of the p2m list */
+	unsigned long p2m_generation;	/* generation count of p2m mapping */
 };
 #endif	/* !__ASSEMBLY__ */
 
@@ -137,13 +197,31 @@ struct arch_shared_info {
 /*
  * The following is all CPU context. Note that the fpu_ctxt block is filled
  * in by FXSAVE if the CPU has feature FXSR; otherwise FSAVE is used.
+ *
+ * Also note that when calling DOMCTL_setvcpucontext and VCPU_initialise
+ * for HVM and PVH guests, not all information in this structure is updated:
+ *
+ * - For HVM guests, the structures read include: fpu_ctxt (if
+ * VGCT_I387_VALID is set), flags, user_regs, debugreg[*]
+ *
+ * - PVH guests are the same as HVM guests, but additionally use ctrlreg[3] to
+ * set cr3. All other fields not used should be set to 0.
  */
 struct vcpu_guest_context {
     /* FPU registers come first so they can be aligned for FXSAVE/FXRSTOR. */
     struct { char x[512]; } fpu_ctxt;       /* User-level FPU registers     */
-#define VGCF_I387_VALID (1<<0)
-#define VGCF_HVM_GUEST  (1<<1)
-#define VGCF_IN_KERNEL  (1<<2)
+#define VGCF_I387_VALID                (1<<0)
+#define VGCF_IN_KERNEL                 (1<<2)
+#define _VGCF_i387_valid               0
+#define VGCF_i387_valid                (1<<_VGCF_i387_valid)
+#define _VGCF_in_kernel                2
+#define VGCF_in_kernel                 (1<<_VGCF_in_kernel)
+#define _VGCF_failsafe_disables_events 3
+#define VGCF_failsafe_disables_events  (1<<_VGCF_failsafe_disables_events)
+#define _VGCF_syscall_disables_events  4
+#define VGCF_syscall_disables_events   (1<<_VGCF_syscall_disables_events)
+#define _VGCF_online                   5
+#define VGCF_online                    (1<<_VGCF_online)
     unsigned long flags;                    /* VGCF_* flags                 */
     struct cpu_user_regs user_regs;         /* User-level CPU registers     */
     struct trap_info trap_ctxt[256];        /* Virtual IDT                  */
diff --git a/include/xen/interface/xen.h b/include/xen/interface/xen.h
index a483789..da16a73 100644
--- a/include/xen/interface/xen.h
+++ b/include/xen/interface/xen.h
@@ -641,10 +641,12 @@ struct start_info {
 };
 
 /* These flags are passed in the 'flags' field of start_info_t. */
-#define SIF_PRIVILEGED    (1<<0)  /* Is the domain privileged? */
-#define SIF_INITDOMAIN    (1<<1)  /* Is this the initial control domain? */
-#define SIF_MULTIBOOT_MOD (1<<2)  /* Is mod_start a multiboot module? */
-#define SIF_MOD_START_PFN (1<<3)  /* Is mod_start a PFN? */
+#define SIF_PRIVILEGED      (1<<0)  /* Is the domain privileged? */
+#define SIF_INITDOMAIN      (1<<1)  /* Is this the initial control domain? */
+#define SIF_MULTIBOOT_MOD   (1<<2)  /* Is mod_start a multiboot module? */
+#define SIF_MOD_START_PFN   (1<<3)  /* Is mod_start a PFN? */
+#define SIF_VIRT_P2M_4TOOLS (1<<4)  /* Do Xen tools understand a virt. mapped */
+				    /* P->M making the 3 level tree obsolete? */
 #define SIF_PM_MASK       (0xFF<<8) /* reserve 1 byte for xen-pm options */
 
 /*
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
