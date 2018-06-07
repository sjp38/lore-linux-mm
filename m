Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9E3826B0288
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 10:41:34 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j25-v6so3547114pfi.9
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 07:41:34 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id i74-v6si8716254pgc.188.2018.06.07.07.41.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 07:41:33 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH 06/10] x86/cet: Add arch_prctl functions for shadow stack
Date: Thu,  7 Jun 2018 07:38:03 -0700
Message-Id: <20180607143807.3611-7-yu-cheng.yu@intel.com>
In-Reply-To: <20180607143807.3611-1-yu-cheng.yu@intel.com>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

The following operations are provided.

ARCH_CET_STATUS:
	return the current CET status

ARCH_CET_DISABLE:
	disable CET features

ARCH_CET_LOCK:
	lock out CET features

ARCH_CET_EXEC:
	set CET features for exec()

ARCH_CET_ALLOC_SHSTK:
	allocate a new shadow stack

ARCH_CET_PUSH_SHSTK:
	put a return address on shadow stack

ARCH_CET_ALLOC_SHSTK and ARCH_CET_PUSH_SHSTK are intended only for
the implementation of GLIBC ucontext related APIs.

Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/cet.h        |   7 ++
 arch/x86/include/uapi/asm/prctl.h |  15 +++
 arch/x86/kernel/Makefile          |   2 +-
 arch/x86/kernel/cet.c             |  18 +++-
 arch/x86/kernel/cet_prctl.c       | 203 ++++++++++++++++++++++++++++++++++++++
 arch/x86/kernel/elf.c             |  24 ++++-
 arch/x86/kernel/process.c         |   7 ++
 7 files changed, 270 insertions(+), 6 deletions(-)
 create mode 100644 arch/x86/kernel/cet_prctl.c

diff --git a/arch/x86/include/asm/cet.h b/arch/x86/include/asm/cet.h
index c8fd87e13859..a2a53fe4d5e6 100644
--- a/arch/x86/include/asm/cet.h
+++ b/arch/x86/include/asm/cet.h
@@ -12,24 +12,31 @@ struct task_struct;
 struct cet_stat {
 	unsigned long	shstk_base;
 	unsigned long	shstk_size;
+	unsigned long	exec_shstk_size;
 	unsigned int	shstk_enabled:1;
+	unsigned int	locked:1;
+	unsigned int	exec_shstk:2;
 };
 
 #ifdef CONFIG_X86_INTEL_CET
+int prctl_cet(int option, unsigned long arg2);
 unsigned long cet_get_shstk_ptr(void);
 int cet_push_shstk(int ia32, unsigned long ssp, unsigned long val);
 int cet_setup_shstk(void);
 int cet_setup_thread_shstk(struct task_struct *p);
+int cet_alloc_shstk(unsigned long *arg);
 void cet_disable_shstk(void);
 void cet_disable_free_shstk(struct task_struct *p);
 int cet_restore_signal(unsigned long ssp);
 int cet_setup_signal(int ia32, unsigned long addr);
 #else
+static inline int prctl_cet(int option, unsigned long arg2) { return 0; }
 static inline unsigned long cet_get_shstk_ptr(void) { return 0; }
 static inline int cet_push_shstk(int ia32, unsigned long ssp,
 				 unsigned long val) { return 0; }
 static inline int cet_setup_shstk(void) { return 0; }
 static inline int cet_setup_thread_shstk(struct task_struct *p) { return 0; }
+static inline int cet_alloc_shstk(unsigned long *arg) { return -EINVAL; }
 static inline void cet_disable_shstk(void) {}
 static inline void cet_disable_free_shstk(struct task_struct *p) {}
 static inline int cet_restore_signal(unsigned long ssp) { return 0; }
diff --git a/arch/x86/include/uapi/asm/prctl.h b/arch/x86/include/uapi/asm/prctl.h
index 5a6aac9fa41f..f9965403b655 100644
--- a/arch/x86/include/uapi/asm/prctl.h
+++ b/arch/x86/include/uapi/asm/prctl.h
@@ -14,4 +14,19 @@
 #define ARCH_MAP_VDSO_32	0x2002
 #define ARCH_MAP_VDSO_64	0x2003
 
+#define ARCH_CET_STATUS		0x3001
+#define ARCH_CET_DISABLE	0x3002
+#define ARCH_CET_LOCK		0x3003
+#define ARCH_CET_EXEC		0x3004
+#define ARCH_CET_ALLOC_SHSTK	0x3005
+#define ARCH_CET_PUSH_SHSTK	0x3006
+
+/*
+ * Settings for ARCH_CET_EXEC
+ */
+#define CET_EXEC_ELF_PROPERTY	0
+#define CET_EXEC_ALWAYS_OFF	1
+#define CET_EXEC_ALWAYS_ON	2
+#define CET_EXEC_MAX CET_EXEC_ALWAYS_ON
+
 #endif /* _ASM_X86_PRCTL_H */
diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index cbf983f44b61..80464f925a6a 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -138,7 +138,7 @@ obj-$(CONFIG_UNWINDER_ORC)		+= unwind_orc.o
 obj-$(CONFIG_UNWINDER_FRAME_POINTER)	+= unwind_frame.o
 obj-$(CONFIG_UNWINDER_GUESS)		+= unwind_guess.o
 
-obj-$(CONFIG_X86_INTEL_CET)		+= cet.o
+obj-$(CONFIG_X86_INTEL_CET)		+= cet.o cet_prctl.o
 
 obj-$(CONFIG_ARCH_HAS_PROGRAM_PROPERTIES) += elf.o
 
diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
index 156f5d88ffd5..1b7089dcf1ea 100644
--- a/arch/x86/kernel/cet.c
+++ b/arch/x86/kernel/cet.c
@@ -83,6 +83,19 @@ static unsigned long shstk_mmap(unsigned long addr, unsigned long len)
 	return addr;
 }
 
+int cet_alloc_shstk(unsigned long *arg)
+{
+	unsigned long size = *arg;
+	unsigned long addr;
+
+	addr = shstk_mmap(0, size);
+	if (addr >= TASK_SIZE)
+		return -ENOMEM;
+
+	*arg = addr;
+	return 0;
+}
+
 int cet_setup_shstk(void)
 {
 	unsigned long addr, size;
@@ -90,7 +103,10 @@ int cet_setup_shstk(void)
 	if (!cpu_feature_enabled(X86_FEATURE_SHSTK))
 		return -EOPNOTSUPP;
 
-	size = SHSTK_SIZE;
+	size = current->thread.cet.exec_shstk_size;
+	if ((size > TASK_SIZE) || (size == 0))
+		size = SHSTK_SIZE;
+
 	addr = shstk_mmap(0, size);
 
 	if (addr >= TASK_SIZE)
diff --git a/arch/x86/kernel/cet_prctl.c b/arch/x86/kernel/cet_prctl.c
new file mode 100644
index 000000000000..326996e2ea80
--- /dev/null
+++ b/arch/x86/kernel/cet_prctl.c
@@ -0,0 +1,203 @@
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
+/*
+ * Handler of prctl for CET:
+ *
+ * ARCH_CET_STATUS: return the current status
+ * ARCH_CET_DISABLE: disable features
+ * ARCH_CET_LOCK: lock out cet features until exec()
+ * ARCH_CET_EXEC: set default features for exec()
+ * ARCH_CET_ALLOC_SHSTK: allocate shadow stack
+ * ARCH_CET_PUSH_SHSTK: put a return address on shadow stack
+ */
+
+static int handle_get_status(unsigned long arg2)
+{
+	unsigned int features = 0, cet_exec = 0;
+	unsigned long shstk_size = 0;
+
+	if (current->thread.cet.shstk_enabled)
+		features |= GNU_PROPERTY_X86_FEATURE_1_SHSTK;
+	if (current->thread.cet.exec_shstk == CET_EXEC_ALWAYS_ON)
+		cet_exec |= GNU_PROPERTY_X86_FEATURE_1_SHSTK;
+	shstk_size = current->thread.cet.exec_shstk_size;
+
+	if (in_compat_syscall()) {
+		unsigned int buf[3];
+
+		buf[0] = features;
+		buf[1] = cet_exec;
+		buf[2] = (unsigned int)shstk_size;
+		return copy_to_user((unsigned int __user *)arg2, buf,
+				    sizeof(buf));
+	} else {
+		unsigned long buf[3];
+
+		buf[0] = (unsigned long)features;
+		buf[1] = (unsigned long)cet_exec;
+		buf[2] = shstk_size;
+		return copy_to_user((unsigned long __user *)arg2, buf,
+				    sizeof(buf));
+	}
+}
+
+static int handle_set_exec(unsigned long arg2)
+{
+	unsigned int features = 0, cet_exec = 0;
+	unsigned long shstk_size = 0;
+	int err = 0;
+
+	if (in_compat_syscall()) {
+		unsigned int buf[3];
+
+		err = copy_from_user(buf, (unsigned int __user *)arg2,
+				     sizeof(buf));
+		if (!err) {
+			features = buf[0];
+			cet_exec = buf[1];
+			shstk_size = (unsigned long)buf[2];
+		}
+	} else {
+		unsigned long buf[3];
+
+		err = copy_from_user(buf, (unsigned long __user *)arg2,
+				     sizeof(buf));
+		if (!err) {
+			features = (unsigned int)buf[0];
+			cet_exec = (unsigned int)buf[1];
+			shstk_size = buf[2];
+		}
+	}
+
+	if (err)
+		return -EFAULT;
+	if (cet_exec > CET_EXEC_MAX)
+		return -EINVAL;
+	if (shstk_size >= TASK_SIZE)
+		return -EINVAL;
+
+	if (features & GNU_PROPERTY_X86_FEATURE_1_SHSTK) {
+		if (!cpu_feature_enabled(X86_FEATURE_SHSTK))
+			return -EINVAL;
+		if ((current->thread.cet.exec_shstk == CET_EXEC_ALWAYS_ON) &&
+		    (cet_exec != CET_EXEC_ALWAYS_ON))
+			return -EPERM;
+	}
+
+	if (features & GNU_PROPERTY_X86_FEATURE_1_SHSTK)
+		current->thread.cet.exec_shstk = cet_exec;
+
+	current->thread.cet.exec_shstk_size = shstk_size;
+	return 0;
+}
+
+static int handle_push_shstk(unsigned long arg2)
+{
+	unsigned long ssp = 0, ret_addr = 0;
+	int ia32, err;
+
+	ia32 = in_ia32_syscall();
+
+	if (ia32) {
+		unsigned int buf[2];
+
+		err = copy_from_user(buf, (unsigned int __user *)arg2,
+				     sizeof(buf));
+		if (!err) {
+			ssp = (unsigned long)buf[0];
+			ret_addr = (unsigned long)buf[1];
+		}
+	} else {
+		unsigned long buf[2];
+
+		err = copy_from_user(buf, (unsigned long __user *)arg2,
+				     sizeof(buf));
+		if (!err) {
+			ssp = buf[0];
+			ret_addr = buf[1];
+		}
+	}
+	if (err)
+		return -EFAULT;
+	err = cet_push_shstk(ia32, ssp, ret_addr);
+	if (err)
+		return -err;
+	return 0;
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
+	case ARCH_CET_EXEC:
+		return handle_set_exec(arg2);
+
+	case ARCH_CET_ALLOC_SHSTK:
+		return handle_alloc_shstk(arg2);
+
+	case ARCH_CET_PUSH_SHSTK:
+		return handle_push_shstk(arg2);
+
+	default:
+		return -EINVAL;
+	}
+}
diff --git a/arch/x86/kernel/elf.c b/arch/x86/kernel/elf.c
index 8e2719d8dc86..de08d41971f6 100644
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
@@ -208,13 +211,26 @@ int arch_setup_features(void *ehdr_p, void *phdr_p,
 	current->thread.cet.shstk_enabled = 0;
 	current->thread.cet.shstk_base = 0;
 	current->thread.cet.shstk_size = 0;
+	current->thread.cet.locked = 0;
 	if (cpu_feature_enabled(X86_FEATURE_SHSTK)) {
-		if (shstk) {
-			err = cet_setup_shstk();
-			if (err < 0)
-				goto out;
+		int exec = current->thread.cet.exec_shstk;
+
+		if (exec != CET_EXEC_ALWAYS_OFF) {
+			if (shstk || (exec == CET_EXEC_ALWAYS_ON)) {
+				err = cet_setup_shstk();
+				if (err < 0)
+					goto out;
+			}
 		}
 	}
+
+	/*
+	 * Lockout CET features if no interpreter
+	 */
+	if (!interp)
+		current->thread.cet.locked = 1;
+
+	err = 0;
 out:
 	return err;
 }
diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index ae56caee41f9..54ad1863c6d2 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -794,6 +794,13 @@ long do_arch_prctl_common(struct task_struct *task, int option,
 		return get_cpuid_mode();
 	case ARCH_SET_CPUID:
 		return set_cpuid_mode(task, cpuid_enabled);
+	case ARCH_CET_STATUS:
+	case ARCH_CET_DISABLE:
+	case ARCH_CET_LOCK:
+	case ARCH_CET_EXEC:
+	case ARCH_CET_ALLOC_SHSTK:
+	case ARCH_CET_PUSH_SHSTK:
+		return prctl_cet(option, cpuid_enabled);
 	}
 
 	return -EINVAL;
-- 
2.15.1
