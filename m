Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id ED2B76B0277
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 18:31:20 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id w11-v6so8763444pfk.14
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 15:31:20 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id t14-v6si14435357pgl.359.2018.07.10.15.31.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 15:31:19 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v2 27/27] x86/cet: Add arch_prctl functions for CET
Date: Tue, 10 Jul 2018 15:26:39 -0700
Message-Id: <20180710222639.8241-28-yu-cheng.yu@intel.com>
In-Reply-To: <20180710222639.8241-1-yu-cheng.yu@intel.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
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
    Disable SHSTK and/or IBT specified in 'features'.  Return -EPERM
    if CET is locked out.

arch_prctl(ARCH_CET_LOCK)
    Lock out CET feature.

arch_prctl(ARCH_CET_ALLOC_SHSTK, unsigned long *addr)
    Allocate a new SHSTK.

    The parameter 'addr' is a pointer to a user buffer and indicates
    the desired SHSTK size to allocate.  On returning to the caller
    the buffer contains the address of the new SHSTK.

arch_prctl(ARCH_CET_LEGACY_BITMAP, unsigned long *addr)
    Allocate an IBT legacy code bitmap if the current task does not
    have one.

    The parameter 'addr' is a pointer to a user buffer.
    On returning to the caller, the kernel fills the following
    information:

    *addr = IBT bitmap base address
    *(addr + 1) = IBT bitmap size

Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/cet.h        |   5 ++
 arch/x86/include/uapi/asm/prctl.h |   6 ++
 arch/x86/kernel/Makefile          |   2 +-
 arch/x86/kernel/cet.c             |  26 ++++++
 arch/x86/kernel/cet_prctl.c       | 141 ++++++++++++++++++++++++++++++
 arch/x86/kernel/elf.c             |   4 +
 arch/x86/kernel/process.c         |   6 ++
 7 files changed, 189 insertions(+), 1 deletion(-)
 create mode 100644 arch/x86/kernel/cet_prctl.c

diff --git a/arch/x86/include/asm/cet.h b/arch/x86/include/asm/cet.h
index d5737f3346f2..50b5284c6667 100644
--- a/arch/x86/include/asm/cet.h
+++ b/arch/x86/include/asm/cet.h
@@ -16,11 +16,14 @@ struct cet_status {
 	unsigned long	ibt_bitmap_size;
 	unsigned int	shstk_enabled:1;
 	unsigned int	ibt_enabled:1;
+	unsigned int	locked:1;
 };
 
 #ifdef CONFIG_X86_INTEL_CET
+int prctl_cet(int option, unsigned long arg2);
 int cet_setup_shstk(void);
 int cet_setup_thread_shstk(struct task_struct *p);
+int cet_alloc_shstk(unsigned long *arg);
 void cet_disable_shstk(void);
 void cet_disable_free_shstk(struct task_struct *p);
 int cet_restore_signal(unsigned long ssp);
@@ -29,8 +32,10 @@ int cet_setup_ibt(void);
 int cet_setup_ibt_bitmap(void);
 void cet_disable_ibt(void);
 #else
+static inline int prctl_cet(int option, unsigned long arg2) { return 0; }
 static inline int cet_setup_shstk(void) { return 0; }
 static inline int cet_setup_thread_shstk(struct task_struct *p) { return 0; }
+static inline int cet_alloc_shstk(unsigned long *arg) { return -EINVAL; }
 static inline void cet_disable_shstk(void) {}
 static inline void cet_disable_free_shstk(struct task_struct *p) {}
 static inline int cet_restore_signal(unsigned long ssp) { return 0; }
diff --git a/arch/x86/include/uapi/asm/prctl.h b/arch/x86/include/uapi/asm/prctl.h
index 5a6aac9fa41f..52ec04e443c5 100644
--- a/arch/x86/include/uapi/asm/prctl.h
+++ b/arch/x86/include/uapi/asm/prctl.h
@@ -14,4 +14,10 @@
 #define ARCH_MAP_VDSO_32	0x2002
 #define ARCH_MAP_VDSO_64	0x2003
 
+#define ARCH_CET_STATUS		0x3001
+#define ARCH_CET_DISABLE	0x3002
+#define ARCH_CET_LOCK		0x3003
+#define ARCH_CET_LEGACY_BITMAP	0x3004
+#define ARCH_CET_ALLOC_SHSTK	0x3005
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
index 2a366a5ccf20..20ce9ac8a0df 100644
--- a/arch/x86/kernel/cet.c
+++ b/arch/x86/kernel/cet.c
@@ -132,6 +132,32 @@ static unsigned long shstk_mmap(unsigned long addr, unsigned long len)
 	return addr;
 }
 
+int cet_alloc_shstk(unsigned long *arg)
+{
+	unsigned long len = *arg;
+	unsigned long addr;
+	unsigned long token;
+	unsigned long ssp;
+
+	addr = shstk_mmap(0, len);
+	if (addr >= TASK_SIZE_MAX)
+		return -ENOMEM;
+
+	/* Restore token is 8 bytes and aligned to 8 bytes */
+	ssp = addr + len;
+	token = ssp;
+
+	if (!in_ia32_syscall())
+		token |= 1;
+	ssp -=8;
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
index 000000000000..86bb78ae656d
--- /dev/null
+++ b/arch/x86/kernel/cet_prctl.c
@@ -0,0 +1,141 @@
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
+
+	if (current->thread.cet.shstk_enabled)
+		features |= GNU_PROPERTY_X86_FEATURE_1_SHSTK;
+	if (current->thread.cet.ibt_enabled)
+		features |= GNU_PROPERTY_X86_FEATURE_1_IBT;
+
+	shstk_base = current->thread.cet.shstk_base;
+	shstk_size = current->thread.cet.shstk_size;
+
+	if (in_ia32_syscall()) {
+		unsigned int buf[3];
+
+		buf[0] = features;
+		buf[1] = (unsigned int)shstk_base;
+		buf[2] = (unsigned int)shstk_size;
+		return copy_to_user((unsigned int __user *)arg2, buf,
+				    sizeof(buf));
+	} else {
+		unsigned long buf[3];
+
+		buf[0] = (unsigned long)features;
+		buf[1] = shstk_base;
+		buf[2] = shstk_size;
+		return copy_to_user((unsigned long __user *)arg2, buf,
+				    sizeof(buf));
+	}
+}
+
+static int handle_alloc_shstk(unsigned long arg2)
+{
+	int err = 0;
+	unsigned long shstk_size = 0;
+
+	if (in_ia32_syscall()) {
+		unsigned int size;
+
+		err = get_user(size, (unsigned int __user *)arg2);
+		if (!err)
+			shstk_size = size;
+	} else {
+		err = get_user(shstk_size, (unsigned long __user *)arg2);
+	}
+
+	if (err)
+		return -EFAULT;
+
+	err = cet_alloc_shstk(&shstk_size);
+	if (err)
+		return -err;
+
+	if (in_ia32_syscall()) {
+		if (put_user(shstk_size, (unsigned int __user *)arg2))
+			return -EFAULT;
+	} else {
+		if (put_user(shstk_size, (unsigned long __user *)arg2))
+			return -EFAULT;
+	}
+	return 0;
+}
+
+static int handle_bitmap(unsigned long arg2)
+{
+	unsigned long addr, size;
+
+	if (current->thread.cet.ibt_enabled) {
+		if (!current->thread.cet.ibt_bitmap_addr)
+			cet_setup_ibt_bitmap();
+		addr = current->thread.cet.ibt_bitmap_addr;
+		size = current->thread.cet.ibt_bitmap_size;
+	} else {
+		addr = 0;
+		size = 0;
+	}
+
+	if (in_compat_syscall()) {
+		if (put_user(addr, (unsigned int __user *)arg2) ||
+		    put_user(size, (unsigned int __user *)arg2 + 1))
+			return -EFAULT;
+	} else {
+		if (put_user(addr, (unsigned long __user *)arg2) ||
+		    put_user(size, (unsigned long __user *)arg2 + 1))
+		return -EFAULT;
+	}
+	return 0;
+}
+
+int prctl_cet(int option, unsigned long arg2)
+{
+	if (!cpu_feature_enabled(X86_FEATURE_SHSTK) &&
+	    !cpu_feature_enabled(X86_FEATURE_IBT))
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
+		if (arg2 & GNU_PROPERTY_X86_FEATURE_1_IBT)
+			cet_disable_ibt();
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
+	/*
+	 * Allocate legacy bitmap and return address & size to user.
+	 */
+	case ARCH_CET_LEGACY_BITMAP:
+		return handle_bitmap(arg2);
+
+	default:
+		return -EINVAL;
+	}
+}
diff --git a/arch/x86/kernel/elf.c b/arch/x86/kernel/elf.c
index 42e08d3b573e..3d4934fdac7f 100644
--- a/arch/x86/kernel/elf.c
+++ b/arch/x86/kernel/elf.c
@@ -8,7 +8,10 @@
 
 #include <asm/cet.h>
 #include <asm/elf_property.h>
+#include <asm/prctl.h>
+#include <asm/processor.h>
 #include <uapi/linux/elf-em.h>
+#include <uapi/linux/prctl.h>
 #include <linux/binfmts.h>
 #include <linux/elf.h>
 #include <linux/slab.h>
@@ -255,6 +258,7 @@ int arch_setup_features(void *ehdr_p, void *phdr_p,
 	current->thread.cet.ibt_enabled = 0;
 	current->thread.cet.ibt_bitmap_addr = 0;
 	current->thread.cet.ibt_bitmap_size = 0;
+	current->thread.cet.locked = 0;
 	if (cpu_feature_enabled(X86_FEATURE_SHSTK)) {
 		if (shstk) {
 			err = cet_setup_shstk();
diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index 43a57d284a22..259b92664981 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -795,6 +795,12 @@ long do_arch_prctl_common(struct task_struct *task, int option,
 		return get_cpuid_mode();
 	case ARCH_SET_CPUID:
 		return set_cpuid_mode(task, cpuid_enabled);
+	case ARCH_CET_STATUS:
+	case ARCH_CET_DISABLE:
+	case ARCH_CET_LOCK:
+	case ARCH_CET_ALLOC_SHSTK:
+	case ARCH_CET_LEGACY_BITMAP:
+		return prctl_cet(option, cpuid_enabled);
 	}
 
 	return -EINVAL;
-- 
2.17.1
