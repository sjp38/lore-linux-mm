Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 737D46B0073
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 04:54:56 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kq14so6476568pab.5
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 01:54:56 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id jx1si241924pbd.192.2014.09.11.01.54.54
        for <linux-mm@kvack.org>;
        Thu, 11 Sep 2014 01:54:55 -0700 (PDT)
From: Qiaowei Ren <qiaowei.ren@intel.com>
Subject: [PATCH v8 10/10] x86, mpx: add documentation on Intel MPX
Date: Thu, 11 Sep 2014 16:46:50 +0800
Message-Id: <1410425210-24789-11-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Qiaowei Ren <qiaowei.ren@intel.com>

This patch adds the Documentation/x86/intel_mpx.txt file with some
information about Intel MPX.

Signed-off-by: Qiaowei Ren <qiaowei.ren@intel.com>
---
 Documentation/x86/intel_mpx.txt |  127 +++++++++++++++++++++++++++++++++++++++
 1 files changed, 127 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/x86/intel_mpx.txt

diff --git a/Documentation/x86/intel_mpx.txt b/Documentation/x86/intel_mpx.txt
new file mode 100644
index 0000000..ccffeee
--- /dev/null
+++ b/Documentation/x86/intel_mpx.txt
@@ -0,0 +1,127 @@
+1. Intel(R) MPX Overview
+========================
+
+Intel(R) Memory Protection Extensions (Intel(R) MPX) is a new
+capability introduced into Intel Architecture. Intel MPX provides
+hardware features that can be used in conjunction with compiler
+changes to check memory references, for those references whose
+compile-time normal intentions are usurped at runtime due to
+buffer overflow or underflow.
+
+For more information, please refer to Intel(R) Architecture
+Instruction Set Extensions Programming Reference, Chapter 9:
+Intel(R) Memory Protection Extensions.
+
+Note: Currently no hardware with MPX ISA is available but it is always
+possible to use SDE (Intel(R) Software Development Emulator) instead,
+which can be downloaded from
+http://software.intel.com/en-us/articles/intel-software-development-emulator
+
+
+2. How does MPX kernel code work
+================================
+
+Handling #BR faults caused by MPX
+---------------------------------
+
+When MPX is enabled, there are 2 new situations that can generate
+#BR faults.
+  * bounds violation caused by MPX instructions.
+  * new bounds tables (BT) need to be allocated to save bounds.
+
+We hook #BR handler to handle these two new situations.
+
+Decoding MPX instructions
+-------------------------
+
+If a #BR is generated due to a bounds violation caused by MPX.
+We need to decode MPX instructions to get violation address and
+set this address into extended struct siginfo.
+
+The _sigfault feild of struct siginfo is extended as follow:
+
+87		/* SIGILL, SIGFPE, SIGSEGV, SIGBUS */
+88		struct {
+89			void __user *_addr; /* faulting insn/memory ref. */
+90 #ifdef __ARCH_SI_TRAPNO
+91			int _trapno;	/* TRAP # which caused the signal */
+92 #endif
+93			short _addr_lsb; /* LSB of the reported address */
+94			struct {
+95				void __user *_lower;
+96				void __user *_upper;
+97			} _addr_bnd;
+98		} _sigfault;
+
+The '_addr' field refers to violation address, and new '_addr_and'
+field refers to the upper/lower bounds when a #BR is caused.
+
+Glibc will be also updated to support this new siginfo. So user
+can get violation address and bounds when bounds violations occur.
+
+Freeing unused bounds tables
+----------------------------
+
+When a BNDSTX instruction attempts to save bounds to a bounds directory
+entry marked as invalid, a #BR is generated. This is an indication that
+no bounds table exists for this entry. In this case the fault handler
+will allocate a new bounds table on demand.
+
+Since the kernel allocated those tables on-demand without userspace
+knowledge, it is also responsible for freeing them when the associated
+mappings go away.
+
+Here, the solution for this issue is to hook do_munmap() to check
+whether one process is MPX enabled. If yes, those bounds tables covered
+in the virtual address region which is being unmapped will be freed also.
+
+Adding new prctl commands
+-------------------------
+
+Runtime library in userspace is responsible for allocation of bounds
+directory. So kernel have to use XSAVE instruction to get the base
+of bounds directory from BNDCFG register.
+
+But XSAVE is expected to be very expensive. In order to do performance
+optimization, we have to add new prctl command to get the base of
+bounds directory to be used in future.
+
+Two new prctl commands are added to register and unregister MPX related
+resource.
+
+155	#define PR_MPX_REGISTER         43
+156	#define PR_MPX_UNREGISTER       44
+
+The base of the bounds directory is set into mm_struct during
+PR_MPX_REGISTER command execution. This member can be used to
+check whether one application is mpx enabled.
+
+
+3. Tips
+=======
+
+1) Users are not allowed to create bounds tables and point the bounds
+directory at them in the userspace. In fact, it is not also necessary
+for users to create bounds tables in the userspace.
+
+When #BR fault is produced due to invalid entry, bounds table will be
+created in kernel on demand and kernel will not transfer this fault to
+userspace. So usersapce can't receive #BR fault for invalid entry, and
+it is not also necessary for users to create bounds tables by themselves.
+
+Certainly users can allocate bounds tables and forcibly point the bounds
+directory at them through XSAVE instruction, and then set valid bit
+of bounds entry to have this entry valid. But we have no way to track
+the memory usage of these user-created bounds tables. In regard to this,
+this behaviour is outlawed here.
+
+2) We will not support the case that multiple bounds directory entries
+are pointed at the same bounds table.
+
+Users can be allowed to take multiple bounds directory entries and point
+them at the same bounds table. See more information "Intel(R) Architecture
+Instruction Set Extensions Programming Reference" (9.3.4).
+
+If userspace did this, it will be possible for kernel to unmap an in-use
+bounds table since it does not recognize sharing. So this behavior is
+also outlawed here.
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
