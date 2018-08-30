Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id AC78C6B524D
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 10:45:10 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 90-v6so4016190pla.18
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 07:45:10 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c15-v6si6092534plo.232.2018.08.30.07.43.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 07:43:44 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v3 05/24] Documentation/x86: Add CET description
Date: Thu, 30 Aug 2018 07:38:45 -0700
Message-Id: <20180830143904.3168-6-yu-cheng.yu@intel.com>
In-Reply-To: <20180830143904.3168-1-yu-cheng.yu@intel.com>
References: <20180830143904.3168-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

Explain how CET works and the no_cet_shstk/no_cet_ibt kernel
parameters.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 .../admin-guide/kernel-parameters.txt         |   6 +
 Documentation/index.rst                       |   1 +
 Documentation/x86/index.rst                   |  11 +
 Documentation/x86/intel_cet.rst               | 252 ++++++++++++++++++
 4 files changed, 270 insertions(+)
 create mode 100644 Documentation/x86/index.rst
 create mode 100644 Documentation/x86/intel_cet.rst

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 9871e649ffef..b090787188b4 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -2764,6 +2764,12 @@
 			noexec=on: enable non-executable mappings (default)
 			noexec=off: disable non-executable mappings
 
+	no_cet_ibt	[X86-64] Disable indirect branch tracking for user-mode
+			applications
+
+	no_cet_shstk	[X86-64] Disable shadow stack support for user-mode
+			applications
+
 	nosmap		[X86]
 			Disable SMAP (Supervisor Mode Access Prevention)
 			even if it is supported by processor.
diff --git a/Documentation/index.rst b/Documentation/index.rst
index 5db7e87c7cb1..1cdc139adb40 100644
--- a/Documentation/index.rst
+++ b/Documentation/index.rst
@@ -104,6 +104,7 @@ implementation.
    :maxdepth: 2
 
    sh/index
+   x86/index
 
 Filesystem Documentation
 ------------------------
diff --git a/Documentation/x86/index.rst b/Documentation/x86/index.rst
new file mode 100644
index 000000000000..9c34d8cbc8f0
--- /dev/null
+++ b/Documentation/x86/index.rst
@@ -0,0 +1,11 @@
+=======================
+X86 Documentation
+=======================
+
+Control Flow Enforcement
+========================
+
+.. toctree::
+   :maxdepth: 1
+
+   intel_cet
diff --git a/Documentation/x86/intel_cet.rst b/Documentation/x86/intel_cet.rst
new file mode 100644
index 000000000000..337baa1f6980
--- /dev/null
+++ b/Documentation/x86/intel_cet.rst
@@ -0,0 +1,252 @@
+=========================================
+Control Flow Enforcement Technology (CET)
+=========================================
+
+[1] Overview
+============
+
+Control Flow Enforcement Technology (CET) provides protection against
+return/jump-oriented programing (ROP) attacks.  It can be implemented
+to protect both the kernel and applications.  In the first phase,
+only the user-mode protection is implemented for the 64-bit kernel.
+Thirty-two bit applications are supported under the compatibility
+mode.
+
+CET includes shadow stack (SHSTK) and indirect branch tracking (IBT)
+and they are enabled from two kernel configuration options:
+
+    INTEL_X86_SHADOW_STACK_USER, and
+    INTEL_X86_BRANCH_TRACKING_USER.
+
+To build a CET-enabled kernel, Binutils v2.31 and GCC v8.1 or later
+are required.  To build a CET-enabled application, GLIBC v2.28 or
+later is also required.
+
+There are two command-line options for disabling CET features:
+
+    no_cet_shstk - disables SHSTK, and
+    no_cet_ibt - disables IBT.
+
+At run time, /proc/cpuinfo shows the availability of SHSTK and IBT.
+
+[2] CET assembly instructions
+=============================
+
+RDSSP %r
+    Read the SHSTK pointer into %r.
+
+INCSSP %r
+    Unwind (increment) the SHSTK pointer (0 ~ 255) steps as indicated
+    in the operand register.  The GLIBC longjmp uses INCSSP to unwind
+    the SHSTK until that matches the program stack.  When it is
+    necessary to unwind beyond 255 steps, longjmp divides and repeats
+    the process.
+
+RSTORSSP (%r)
+    Switch to the SHSTK indicated in the 'restore token' pointed by
+    the operand register and replace the 'restore token' with a new
+    token to be saved (with SAVEPREVSSP) for the outgoing SHSTK.
+
+::
+
+                               Before RSTORSSP
+
+             Incoming SHSTK                   Current/Outgoing SHSTK
+
+        |----------------------|             |----------------------|
+ addr=x |                      |       ssp-> |                      |
+        |----------------------|             |----------------------|
+ (%r)-> | rstor_token=(x|Lg)   |    addr=y-8 |                      |
+        |----------------------|             |----------------------|
+
+                               After RSTORSSP
+
+        |----------------------|             |----------------------|
+  ssp-> |                      |             |                      |
+        |----------------------|             |----------------------|
+        | rstor_token=(y|Bz|Lg)|    addr=y-8 |                      |
+        |----------------------|             |----------------------|
+
+    note:
+        1. Only valid addresses and restore tokens can be on the
+           user-mode SHSTK.
+        2. A token is always of type u64 and must align to u64.
+        3. The incoming SHSTK pointer in a rstor_token must point to
+           immediately above the token.
+        4. 'Lg' is bit[0] of a rstor_token indicating a 64-bit SHSTK.
+        5. 'Bz' is bit[1] of a rstor_token indicating the token is to
+           be used only for the next SAVEPREVSSP and invalid for the
+           RSTORSSP.
+
+SAVEPREVSSP
+    Store the SHSTK 'restore token' pointed by
+        (current_SHSTK_pointer + 8).
+
+::
+
+                             After SAVEPREVSSP
+
+        |----------------------|             |----------------------|
+  ssp-> |                      |             |                      |
+        |----------------------|             |----------------------|
+        | rstor_token=(y|Bz|Lg)|    addr=y-8 | rstor_token(y|Lg)    |
+        |----------------------|             |----------------------|
+
+WRUSS %r0, (%r1)
+    Write the value in %r0 to the SHSTK address pointed by (%r1).
+    This is a kernel-mode only instruction.
+
+ENDBR
+    The compiler inserts an ENDBR at all valid branch targets.  Any
+    CALL/JMP to a target without an ENDBR triggers a control
+    protection fault.
+
+[3] Application Enabling
+========================
+
+An application's CET capability is marked in its ELF header and can
+be verified from the following command output, in the
+NT_GNU_PROPERTY_TYPE_0 field:
+
+    readelf -n <application>
+
+If an application supports CET and is statically linked, it will run
+with CET protection.  If the application needs any shared libraries,
+the loader checks all dependencies and enables CET only when all
+requirements are met.
+
+[4] Legacy Libraries
+====================
+
+GLIBC provides a few tunables for backward compatibility.
+
+GLIBC_TUNABLES=glibc.tune.hwcaps=-SHSTK,-IBT
+    Turn off SHSTK/IBT for the current shell.
+
+GLIBC_TUNABLES=glibc.tune.x86_shstk=<on, permissive>
+    This controls how dlopen() handles SHSTK legacy libraries:
+        on: continue with SHSTK enabled;
+        permissive: continue with SHSTK off.
+
+[5] CET system calls
+====================
+
+The following arch_prctl() system calls are added for CET:
+
+arch_prctl(ARCH_CET_STATUS, unsigned long *addr)
+    Return CET feature status.
+
+    The parameter 'addr' is a pointer to a user buffer.
+    On returning to the caller, the kernel fills the following
+    information:
+
+    *addr = SHSTK/IBT status
+    *(addr + 1) = SHSTK base address
+    *(addr + 2) = SHSTK size
+
+arch_prctl(ARCH_CET_DISABLE, unsigned long features)
+    Disable SHSTK and/or IBT specified in 'features'.  Return -EPERM
+    if CET is locked.
+
+arch_prctl(ARCH_CET_LOCK)
+    Lock in CET feature.
+
+arch_prctl(ARCH_CET_ALLOC_SHSTK, unsigned long *addr)
+    Allocate a new SHSTK.
+
+    The parameter 'addr' is a pointer to a user buffer and indicates
+    the desired SHSTK size to allocate.  On returning to the caller
+    the buffer contains the address of the new SHSTK.
+
+arch_prctl(ARCH_CET_LEGACY_BITMAP, unsigned long *addr)
+    Allocate an IBT legacy code bitmap if the current task does not
+    have one.
+
+    The parameter 'addr' is a pointer to a user buffer.
+    On returning to the caller, the kernel fills the following
+    information:
+
+    *addr = IBT bitmap base address
+    *(addr + 1) = IBT bitmap size
+
+[6] The implementation of the SHSTK
+===================================
+
+SHSTK size
+----------
+
+A task's SHSTK is allocated from memory to a fixed size of
+RLIMIT_STACK.
+
+Signal
+------
+
+The main program and its signal handlers use the same SHSTK.  Because
+the SHSTK stores only return addresses, we can estimate a large
+enough SHSTK to cover the condition that both the program stack and
+the sigaltstack run out.
+
+The kernel creates a restore token at the SHSTK restoring address and
+verifies that token when restoring from the signal handler.
+
+Fork
+----
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
+When a pthread child is created, the kernel allocates a new SHSTK for
+the new thread.
+
+Setjmp/Longjmp
+--------------
+
+Longjmp unwinds SHSTK until it matches the program stack.
+
+Ucontext
+--------
+
+In GLIBC, getcontext/setcontext is implemented in similar way as
+setjmp/longjmp.
+
+When makecontext creates a new ucontext, a new SHSTK is allocated for
+that context with ARCH_CET_ALLOC_SHSTK the syscall.  The kernel
+creates a restore token at the top of the new SHSTK and the user-mode
+code switches to the new SHSTK with the RSTORSSP instruction.
+
+[7] The management of read-only & dirty PTEs for SHSTK
+======================================================
+
+A RO and dirty PTE exists in the following cases:
+
+(a) A page is modified and then shared with a fork()'ed child;
+(b) A R/O page that has been COW'ed;
+(c) A SHSTK page.
+
+The processor only checks the dirty bit for (c).  To prevent the use
+of non-SHSTK memory as SHSTK, we use a spare bit of the 64-bit PTE as
+DIRTY_SW for (a) and (b) above.  This results to the following PTE
+settings:
+
+Modified PTE:             (R/W + DIRTY_HW)
+Modified and shared PTE:  (R/O + DIRTY_SW)
+R/O PTE, COW'ed:          (R/O + DIRTY_SW)
+SHSTK PTE:                (R/O + DIRTY_HW)
+SHSTK PTE, COW'ed:        (R/O + DIRTY_HW)
+SHSTK PTE, shared:        (R/O + DIRTY_SW)
+
+Note that DIRTY_SW is only used in R/O PTEs but not R/W PTEs.
+
+[8] The implementation of IBT
+=============================
+
+The kernel provides IBT support in mmap() of the legacy code bit map.
+However, the management of the bitmap is done in the GLIBC or the
+application.
-- 
2.17.1
