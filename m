Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2E5B38E0019
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 11:10:28 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id n17-v6so6668351pff.17
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 08:10:28 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id z3-v6si26822954pgh.557.2018.09.21.08.10.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 08:10:26 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v4 26/27] x86/cet/shstk: Add arch_prctl functions for Shadow Stack
Date: Fri, 21 Sep 2018 08:03:50 -0700
Message-Id: <20180921150351.20898-27-yu-cheng.yu@intel.com>
In-Reply-To: <20180921150351.20898-1-yu-cheng.yu@intel.com>
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

arch_prctl(ARCH_CET_STATUS, unsigned long *addr)
    Return CET feature status.

    The parameter 'addr' is a pointer to a user buffer.
    On returning to the caller, the kernel fills the following
    information:

    *addr = SHSTK/IBT status
    *(addr + 1) = SHSTK base address
    *(addr + 2) = SHSTK size

arch_prctl(ARCH_CET_DISABLE, unsigned long features)
    Disable CET features specified in 'features'.  Return
    -EPERM if CET is locked.

arch_prctl(ARCH_CET_LOCK)
    Lock in CET feature.

arch_prctl(ARCH_CET_ALLOC_SHSTK, unsigned long *addr)
    Allocate a new SHSTK.

    The parameter 'addr' is a pointer to a user buffer and indicates
    the desired SHSTK size to allocate.  On returning to the caller
    the buffer contains the address of the new SHSTK.

Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/cet.h        |  5 ++
 arch/x86/include/uapi/asm/prctl.h |  5 ++
 arch/x86/kernel/Makefile          |  2 +-
 arch/x86/kernel/cet.c             | 27 +++++++++++
 arch/x86/kernel/cet_prctl.c       | 79 +++++++++++++++++++++++++++++++
 arch/x86/kernel/process.c         |  5 ++
 6 files changed, 122 insertions(+), 1 deletion(-)
 create mode 100644 arch/x86/kernel/cet_prctl.c

diff --git a/arch/x86/include/asm/cet.h b/arch/x86/include/asm/cet.h
index b7b33e1026bb..212bd68e31d3 100644
--- a/arch/x86/include/asm/cet.h
+++ b/arch/x86/include/asm/cet.h
@@ -12,19 +12,24 @@ struct task_struct;
 struct cet_status {
 	unsigned long	shstk_base;
 	unsigned long	shstk_size;
+	unsigned int	locked:1;
 	unsigned int	shstk_enabled:1;
 };
 
 #ifdef CONFIG_X86_INTEL_CET
+int prctl_cet(int option, unsigned long arg2);
 int cet_setup_shstk(void);
 int cet_setup_thread_shstk(struct task_struct *p);
+int cet_alloc_shstk(unsigned long *arg);
 void cet_disable_shstk(void);
 void cet_disable_free_shstk(struct task_struct *p);
 int cet_restore_signal(unsigned long ssp);
 int cet_setup_signal(bool ia32, unsigned long rstor, unsigned long *new_ssp);
 #else
+static inline int prctl_cet(int option, unsigned long arg2) { return 0; }
 static inline int cet_setup_shstk(void) { return 0; }
 static inline int cet_setup_thread_shstk(struct task_struct *p) { return 0; }
+static inline int cet_alloc_shstk(unsigned long *arg) { return -EINVAL; }
 static inline void cet_disable_shstk(void) {}
 static inline void cet_disable_free_shstk(struct task_struct *p) {}
 static inline int cet_restore_signal(unsigned long ssp) { return 0; }
diff --git a/arch/x86/include/uapi/asm/prctl.h b/arch/x86/include/uapi/asm/prctl.h
index 5a6aac9fa41f..3aec1088e01d 100644
--- a/arch/x86/include/uapi/asm/prctl.h
+++ b/arch/x86/include/uapi/asm/prctl.h
@@ -14,4 +14,9 @@
 #define ARCH_MAP_VDSO_32	0x2002
 #define ARCH_MAP_VDSO_64	0x2003
 
+#define ARCH_CET_STATUS		0x3001
+#define ARCH_CET_DISABLE	0x3002
+#define ARCH_CET_LOCK		0x3003
+#define ARCH_CET_ALLOC_SHSTK	0x3004
+
 #endif /* _ASM_X86_PRCTL_H */
diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index 36b14ef410c8..b9e6cdc6b4f7 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -139,7 +139,7 @@ obj-$(CONFIG_UNWINDER_ORC)		+= unwind_orc.o
 obj-$(CONFIG_UNWINDER_FRAME_POINTER)	+= unwind_frame.o
 obj-$(CONFIG_UNWINDER_GUESS)		+= unwind_guess.o
 
-obj-$(CONFIG_X86_INTEL_CET)		+= cet.o
+obj-$(CONFIG_X86_INTEL_CET)		+= cet.o cet_prctl.o
 
 obj-$(CONFIG_ARCH_HAS_PROGRAM_PROPERTIES) += elf.o
 
diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
index ce0b3b7b1160..1c2689738604 100644
--- a/arch/x86/kernel/cet.c
+++ b/arch/x86/kernel/cet.c
@@ -110,6 +110,33 @@ static int create_rstor_token(bool ia32, unsigned long ssp,
 	return 0;
 }
 
+int cet_alloc_shstk(unsigned long *arg)
+{
+	unsigned long len = *arg;
+	unsigned long addr;
+	unsigned long token;
+	unsigned long ssp;
+
+	addr = do_mmap_locked(0, len, PROT_READ,
+			      MAP_ANONYMOUS | MAP_PRIVATE, VM_SHSTK);
+	if (addr >= TASK_SIZE_MAX)
+		return -ENOMEM;
+
+	/* Restore token is 8 bytes and aligned to 8 bytes */
+	ssp = addr + len;
+	token = ssp;
+
+	if (!in_ia32_syscall())
+		token |= 1;
+	ssp -= 8;
+
+	if (write_user_shstk_64(ssp, token))
+		return -EINVAL;
+
+	*arg = addr;
+	return 0;
+}
+
 int cet_setup_shstk(void)
 {
 	unsigned long addr, size;
diff --git a/arch/x86/kernel/cet_prctl.c b/arch/x86/kernel/cet_prctl.c
new file mode 100644
index 000000000000..c4b7c19f5040
--- /dev/null
+++ b/arch/x86/kernel/cet_prctl.c
@@ -0,0 +1,79 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+
+#include <linux/errno.h>
+#include <linux/uaccess.h>
+#include <linux/prctl.h>
+#include <linux/compat.h>
+#include <asm/processor.h>
+#include <asm/prctl.h>
+#include <asm/elf.h>
+#include <asm/elf_property.h>
+#include <asm/cet.h>
+
+/* See Documentation/x86/intel_cet.txt. */
+
+static int handle_get_status(unsigned long arg2)
+{
+	unsigned int features = 0;
+	unsigned long shstk_base, shstk_size;
+	unsigned long buf[3];
+
+	if (current->thread.cet.shstk_enabled)
+		features |= GNU_PROPERTY_X86_FEATURE_1_SHSTK;
+
+	shstk_base = current->thread.cet.shstk_base;
+	shstk_size = current->thread.cet.shstk_size;
+
+	buf[0] = (unsigned long)features;
+	buf[1] = shstk_base;
+	buf[2] = shstk_size;
+	return copy_to_user((unsigned long __user *)arg2, buf,
+			    sizeof(buf));
+}
+
+static int handle_alloc_shstk(unsigned long arg2)
+{
+	int err = 0;
+	unsigned long shstk_size = 0;
+
+	if (get_user(shstk_size, (unsigned long __user *)arg2))
+		return -EFAULT;
+
+	err = cet_alloc_shstk(&shstk_size);
+	if (err)
+		return err;
+
+	if (put_user(shstk_size, (unsigned long __user *)arg2))
+		return -EFAULT;
+
+	return 0;
+}
+
+int prctl_cet(int option, unsigned long arg2)
+{
+	if (!cpu_feature_enabled(X86_FEATURE_SHSTK))
+		return -EINVAL;
+
+	switch (option) {
+	case ARCH_CET_STATUS:
+		return handle_get_status(arg2);
+
+	case ARCH_CET_DISABLE:
+		if (current->thread.cet.locked)
+			return -EPERM;
+		if (arg2 & GNU_PROPERTY_X86_FEATURE_1_SHSTK)
+			cet_disable_free_shstk(current);
+
+		return 0;
+
+	case ARCH_CET_LOCK:
+		current->thread.cet.locked = 1;
+		return 0;
+
+	case ARCH_CET_ALLOC_SHSTK:
+		return handle_alloc_shstk(arg2);
+
+	default:
+		return -EINVAL;
+	}
+}
diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index 440f012ef925..251b8714f9a3 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -792,6 +792,11 @@ long do_arch_prctl_common(struct task_struct *task, int option,
 		return get_cpuid_mode();
 	case ARCH_SET_CPUID:
 		return set_cpuid_mode(task, cpuid_enabled);
+	case ARCH_CET_STATUS:
+	case ARCH_CET_DISABLE:
+	case ARCH_CET_LOCK:
+	case ARCH_CET_ALLOC_SHSTK:
+		return prctl_cet(option, cpuid_enabled);
 	}
 
 	return -EINVAL;
-- 
2.17.1
