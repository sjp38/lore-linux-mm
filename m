Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DA05C6B000A
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 10:40:00 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id w1-v6so3577075pgr.7
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 07:40:00 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 88-v6si53306702pla.315.2018.06.07.07.39.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 07:39:59 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH 5/5] Documentation/x86: Add CET description
Date: Thu,  7 Jun 2018 07:35:44 -0700
Message-Id: <20180607143544.3477-6-yu-cheng.yu@intel.com>
In-Reply-To: <20180607143544.3477-1-yu-cheng.yu@intel.com>
References: <20180607143544.3477-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

Explain how CET works and the noshstk/noibt kernel parameters.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 Documentation/admin-guide/kernel-parameters.txt |   6 +
 Documentation/x86/intel_cet.txt                 | 161 ++++++++++++++++++++++++
 2 files changed, 167 insertions(+)
 create mode 100644 Documentation/x86/intel_cet.txt

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index f2040d46f095..c9a94bec1519 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -2649,6 +2649,12 @@
 			noexec=on: enable non-executable mappings (default)
 			noexec=off: disable non-executable mappings
 
+	noibt		[X86-64] Disable indirect branch tracking for user-mode
+			applications
+
+	noshstk		[X86-64] Disable shadow stack support for user-mode
+			applications
+
 	nosmap		[X86]
 			Disable SMAP (Supervisor Mode Access Prevention)
 			even if it is supported by processor.
diff --git a/Documentation/x86/intel_cet.txt b/Documentation/x86/intel_cet.txt
new file mode 100644
index 000000000000..1b902a6c49f4
--- /dev/null
+++ b/Documentation/x86/intel_cet.txt
@@ -0,0 +1,161 @@
+-----------------------------------------
+Control Flow Enforcement Technology (CET)
+-----------------------------------------
+
+[1] Overview
+
+Control Flow Enforcement Technology (CET) provides protection against
+return/jump-oriented programing (ROP) attacks.  It can be implemented to
+protect both the kernel and applications.  In the first phase, only the
+user-mode protection is implemented for the 64-bit kernel.  Thirty-two bit
+applications are supported under the compatibility mode.
+
+CET includes shadow stack (SHSTK) and indirect branch tracking (IBT) and
+they are enabled from two kernel configuration options:
+
+  INTEL_X86_SHADOW_STACK_USER, and
+  INTEL_X86_BRANCH_TRACKING_USER.
+
+There are two command-line options for disabling CET features:
+
+  noshstk - disables shadow stack, and
+  noibt - disables indirect branch tracking.
+
+At run time, /proc/cpuinfo shows the availability of SHSTK and IBT.
+
+[2] Application Enabling
+
+The design of CET user-mode interface provides maximum overall coverage
+and compatibility with existing applications.
+
+To verify the CET capability of an application, use the following command
+and look for SHSTK/IBT in the NT_GNU_PROPERTY_TYPE_0 field:
+
+  readelf -n <application>
+
+CET features are opt-in by each application.  To build a CET-capable
+application, the following tools are needed: Binutils v2.30, GCC v8.1,
+and GLIBC v2.29 (or later).
+
+If an application has CET capabilities, is statically linked, and the
+kernel supports CET, it will run with CET enabled.  If an application
+needs any shared libraries, the loader checks all dependencies and enables
+CET only when all requirements are met.  Once an application starts with
+CET enabled, the protection cannot be turned off until the next exec().
+
+[3] CET system calls
+
+The following arch_prctl() system calls are added for CET:
+
+(3a) arch_prctl(ARCH_CET_STATUS, unsigned long *addr)
+
+     Return CET feature status.
+
+     The parameter 'addr' is a pointer to a user buffer.
+     On returning to the caller, the kernel fills the following
+     information:
+
+     *addr = SHSTK/IBT status
+     *(addr + 1) = SHSTK/IBT default setting on exec()
+     *(addr + 2) = default SHSTK size on exec()
+
+(3b) arch_prctl(ARCH_CET_DISABLE, unsigned long features)
+
+     Disable SHSTK and/or IBT specified in 'features'.  Return -EPERM
+     if CET is locked out.
+
+(3c) arch_prctl(ARCH_CET_LOCK)
+
+     Lock out CET features; disable turning off of SHSTK/IBT.
+
+(3d) arch_prctl(ARCH_CET_EXEC, unsigned long *addr)
+
+     Control how CET features should be enabled upon exec() a new
+     image.
+
+     The parameter 'addr' is a pointer to a user buffer.
+
+     *addr = a bitmap indicating which features are being changed
+     *(addr + 1) = how CET should be enabled upon exec().
+                      0: Check ELF header
+                      1: Always disable
+                      2: Always enable
+     *(addr + 2) = default SHSTK size on exec()
+
+(3e) arch_prctl(ARCH_CET_ALLOC_SHSTK, unsigned long *addr)
+
+     Allocate a new SHSTK.
+
+     The parameter 'addr' is a pointer to a user buffer and indicates
+     the desired SHSTK size to allocate.  On returning to the caller
+     the buffer contains the address of the new SHSTK.
+
+(3f) arch_prctl(ARCH_CET_PUSH_SHSTK, unsigned long *addr)
+
+     Push a value onto the SHSTK.
+
+     The parameter 'addr' is a pointer to a user buffer.
+
+     *addr = the SHSTK pointer
+     *(addr + 1) = the value to push (a function return address)
+
+Note: ARCH_CET_ALLOC_SHSTK and ARCH_CET_PUSH_SHSTK are intended for
+      the implementation of GLIBC getcontext(), setcontext(),
+      makecontext(), and swapcontext().
+
+(3g) arch_prctl(ARCH_CET_LEGACY_BITMAP, unsigned long *addr)
+
+     If the current task does not have a legacy bitmap, setup one.
+     Return bitmap information as the following:
+
+     *addr = bitmap base address
+     *(addr + 1) = bitmap size
+
+[4] The implementation of the SHSTK
+
+A task's SHSTK is allocated from memory to a fixed size that can
+support 32 KB nested function calls; that is 256 KB for a 64-bit
+application and 128 KB for a 32-bit application.  The system admin
+can change the size with the CET command line utility.
+
+The main program and its signal handlers use the same shadow stack.
+
+The SHSTK's vma has VM_SHSTK flag set; its PTEs are required to be
+read-only and dirty.  When a SHSTK PTE is not present, RO, and dirty,
+a SHSTK access triggers a page fault with an additional SHSTK bit set
+in the page fault error code.
+
+When a task forks a child, its SHSTK PTEs are copied and both the
+parent's and the child's SHSTK PTEs are cleared of the dirty bit.
+Upon the next SHSTK access, the resulting SHSTK page fault is handled
+by page copy/re-use.
+
+When a pthread child is created, a separate SHSTK is created for the
+child.
+
+[5] The management of read-only & dirty PTEs for SHSTK
+
+A RO and dirty PTE exists in the following cases:
+
+(5a) A page is modified and then shared with a fork()'ed child;
+(5b) access_remote_vm with (FOLL_WRITE | FOLL_FORCE) on a RO page;
+(5c) A SHSTK page.
+
+The processor does not read the dirty bit for (5a) and (5b), but
+checks the dirty bit for (5c).  To prevent accidental use of non-
+SHSTK memory as SHSTK, we introduce the use of a spare bit of the
+64-bit PTE as _PAGE_BIT_DIRTY_SW and exchange it with the dirty
+bit for (5a) and (5b).  This results to the following possible
+PTE settings:
+
+Modified PTE:		  (R/W + DIRTY_HW)
+Modified and shared PTE:  (R/O + DIRTY_SW)
+R/O PTE was (FOLL_FORCE | FOLL_WRITE): (R/O + DIRTY_SW)
+SHSTK stack PTE:	  (R/O + DIRTY_HW)
+Shared SHSTK PTE:	  (R/O + DIRTY_SW)
+
+[6] The implementation of IBT
+
+The kernel provides IBT support in mmap() of the legacy code bit map.
+However, the management of the bitmap is done in the GLIBC or the
+application.
-- 
2.15.1
