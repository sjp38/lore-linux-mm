Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E87BF6B0287
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 10:41:33 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j25-v6so3547103pfi.9
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 07:41:33 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id i74-v6si8716254pgc.188.2018.06.07.07.41.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 07:41:32 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH 05/10] x86/cet: ELF header parsing of Control Flow Enforcement
Date: Thu,  7 Jun 2018 07:38:02 -0700
Message-Id: <20180607143807.3611-6-yu-cheng.yu@intel.com>
In-Reply-To: <20180607143807.3611-1-yu-cheng.yu@intel.com>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

Look in .note.gnu.property of an ELF file and check if shadow stack needs
to be enabled for the task.

Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/Kconfig                         |   4 +
 arch/x86/include/asm/elf.h               |   5 +
 arch/x86/include/uapi/asm/elf_property.h |  16 +++
 arch/x86/kernel/Makefile                 |   2 +
 arch/x86/kernel/elf.c                    | 220 +++++++++++++++++++++++++++++++
 fs/binfmt_elf.c                          |  16 +++
 include/uapi/linux/elf.h                 |   1 +
 7 files changed, 264 insertions(+)
 create mode 100644 arch/x86/include/uapi/asm/elf_property.h
 create mode 100644 arch/x86/kernel/elf.c

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index dd580d4910fc..24339a5299da 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1931,12 +1931,16 @@ config X86_INTEL_CET
 config ARCH_HAS_SHSTK
 	def_bool n
 
+config ARCH_HAS_PROGRAM_PROPERTIES
+	def_bool n
+
 config X86_INTEL_SHADOW_STACK_USER
 	prompt "Intel Shadow Stack for user-mode"
 	def_bool n
 	depends on CPU_SUP_INTEL && X86_64
 	select X86_INTEL_CET
 	select ARCH_HAS_SHSTK
+	select ARCH_HAS_PROGRAM_PROPERTIES
 	---help---
 	  Shadow stack provides hardware protection against program stack
 	  corruption.  Only when all the following are true will an application
diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
index 0d157d2a1e2a..5b5f169c5c07 100644
--- a/arch/x86/include/asm/elf.h
+++ b/arch/x86/include/asm/elf.h
@@ -382,4 +382,9 @@ struct va_alignment {
 
 extern struct va_alignment va_align;
 extern unsigned long align_vdso_addr(unsigned long);
+
+#ifdef CONFIG_ARCH_HAS_PROGRAM_PROPERTIES
+extern int arch_setup_features(void *ehdr, void *phdr, struct file *file,
+			       bool interp);
+#endif
 #endif /* _ASM_X86_ELF_H */
diff --git a/arch/x86/include/uapi/asm/elf_property.h b/arch/x86/include/uapi/asm/elf_property.h
new file mode 100644
index 000000000000..343a871b8fc1
--- /dev/null
+++ b/arch/x86/include/uapi/asm/elf_property.h
@@ -0,0 +1,16 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef _UAPI_ASM_X86_ELF_PROPERTY_H
+#define _UAPI_ASM_X86_ELF_PROPERTY_H
+
+/*
+ * pr_type
+ */
+#define GNU_PROPERTY_X86_FEATURE_1_AND (0xc0000002)
+
+/*
+ * Bits for GNU_PROPERTY_X86_FEATURE_1_AND
+ */
+#define GNU_PROPERTY_X86_FEATURE_1_SHSTK	(0x00000002)
+#define GNU_PROPERTY_X86_FEATURE_1_IBT		(0x00000001)
+
+#endif /* _UAPI_ASM_X86_ELF_PROPERTY_H */
diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index 7ea5e099d558..cbf983f44b61 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -140,6 +140,8 @@ obj-$(CONFIG_UNWINDER_GUESS)		+= unwind_guess.o
 
 obj-$(CONFIG_X86_INTEL_CET)		+= cet.o
 
+obj-$(CONFIG_ARCH_HAS_PROGRAM_PROPERTIES) += elf.o
+
 ###
 # 64 bit specific files
 ifeq ($(CONFIG_X86_64),y)
diff --git a/arch/x86/kernel/elf.c b/arch/x86/kernel/elf.c
new file mode 100644
index 000000000000..8e2719d8dc86
--- /dev/null
+++ b/arch/x86/kernel/elf.c
@@ -0,0 +1,220 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * Look at an ELF file's .note.gnu.property and determine if the file
+ * supports shadow stack and/or indirect branch tracking.
+ * The path from the ELF header to the note section is the following:
+ * elfhdr->elf_phdr->elf_note->x86_note_gnu_property[].
+ */
+
+#include <asm/cet.h>
+#include <asm/elf_property.h>
+#include <uapi/linux/elf-em.h>
+#include <linux/binfmts.h>
+#include <linux/elf.h>
+#include <linux/slab.h>
+#include <linux/fs.h>
+#include <linux/uaccess.h>
+#include <linux/string.h>
+
+#define ELF_NOTE_DESC_OFFSET(n, align) \
+	round_up(sizeof(*n) + n->n_namesz, (align))
+
+#define ELF_NOTE_NEXT_OFFSET(n, align) \
+	round_up(ELF_NOTE_DESC_OFFSET(n, align) + n->n_descsz, (align))
+
+static int find_cet(u8 *buf, u32 size, u32 align, int *shstk, int *ibt)
+{
+	unsigned long start = (unsigned long)buf;
+	struct elf_note *note = (struct elf_note *)buf;
+
+	*shstk = 0;
+	*ibt = 0;
+
+	/*
+	 * Go through the x86_note_gnu_property array pointed by
+	 * buf and look for shadow stack and indirect branch
+	 * tracking features.
+	 * The GNU_PROPERTY_X86_FEATURE_1_AND entry contains only
+	 * one u32 as data.  Do not go beyond buf_size.
+	 */
+
+	while ((unsigned long) (note + 1) - start < size) {
+		/* Find the NT_GNU_PROPERTY_TYPE_0 note. */
+		if (note->n_namesz == 4 &&
+		    note->n_type == NT_GNU_PROPERTY_TYPE_0 &&
+		    memcmp(note + 1, "GNU", 4) == 0) {
+			u8 *ptr, *ptr_end;
+
+			/* Check for invalid property. */
+			if (note->n_descsz < 8 ||
+			   (note->n_descsz % align) != 0)
+				return 0;
+
+			/* Start and end of property array. */
+			ptr = (u8 *)(note + 1) + 4;
+			ptr_end = ptr + note->n_descsz;
+
+			while (1) {
+				u32 type = *(u32 *)ptr;
+				u32 datasz = *(u32 *)(ptr + 4);
+
+				ptr += 8;
+				if ((ptr + datasz) > ptr_end)
+					break;
+
+				if (type == GNU_PROPERTY_X86_FEATURE_1_AND &&
+				    datasz == 4) {
+					u32 p = *(u32 *)ptr;
+
+					if (p & GNU_PROPERTY_X86_FEATURE_1_SHSTK)
+						*shstk = 1;
+					if (p & GNU_PROPERTY_X86_FEATURE_1_IBT)
+						*ibt = 1;
+					return 1;
+				}
+			}
+		}
+
+		/*
+		 * Note sections like .note.ABI-tag and .note.gnu.build-id
+		 * are aligned to 4 bytes in 64-bit ELF objects.
+		 */
+		note = (void *)note + ELF_NOTE_NEXT_OFFSET(note, align);
+	}
+
+	return 0;
+}
+
+static int check_pt_note_segment(struct file *file,
+				 unsigned long note_size, loff_t *pos,
+				 u32 align, int *shstk, int *ibt)
+{
+	int retval;
+	char *note_buf;
+
+	/*
+	 * Try to read in the whole PT_NOTE segment.
+	 */
+	note_buf = kmalloc(note_size, GFP_KERNEL);
+	if (!note_buf)
+		return -ENOMEM;
+	retval = kernel_read(file, note_buf, note_size, pos);
+	if (retval != note_size) {
+		kfree(note_buf);
+		return (retval < 0) ? retval : -EIO;
+	}
+
+	retval = find_cet(note_buf, note_size, align, shstk, ibt);
+	kfree(note_buf);
+	return retval;
+}
+
+#ifdef CONFIG_COMPAT
+static int check_pt_note_32(struct file *file, struct elf32_phdr *phdr,
+			    int phnum, int *shstk, int *ibt)
+{
+	int i;
+	int found = 0;
+
+	/*
+	 * Go through all PT_NOTE segments and find NT_GNU_PROPERTY_TYPE_0.
+	 */
+	for (i = 0; i < phnum; i++, phdr++) {
+		loff_t pos;
+
+		/*
+		 * NT_GNU_PROPERTY_TYPE_0 note is aligned to 4 bytes
+		 * in 32-bit binaries.
+		 */
+		if ((phdr->p_type != PT_NOTE) || (phdr->p_align != 4))
+			continue;
+
+		pos = phdr->p_offset;
+		found = check_pt_note_segment(file, phdr->p_filesz,
+					      &pos, phdr->p_align,
+					      shstk, ibt);
+		if (found)
+			break;
+	}
+	return found;
+}
+#endif
+
+#ifdef CONFIG_X86_64
+static int check_pt_note_64(struct file *file, struct elf64_phdr *phdr,
+			    int phnum, int *shstk, int *ibt)
+{
+	int found = 0;
+
+	/*
+	 * Go through all PT_NOTE segments and find NT_GNU_PROPERTY_TYPE_0.
+	 */
+	for (; phnum > 0; phnum--, phdr++) {
+		loff_t pos;
+
+		/*
+		 * NT_GNU_PROPERTY_TYPE_0 note is aligned to 8 bytes
+		 * in 64-bit binaries.
+		 */
+		if ((phdr->p_type != PT_NOTE) || (phdr->p_align != 8))
+			continue;
+
+		pos = phdr->p_offset;
+		found = check_pt_note_segment(file, phdr->p_filesz,
+					      &pos, phdr->p_align,
+					      shstk, ibt);
+
+		if (found)
+			break;
+	}
+	return found;
+}
+#endif
+
+int arch_setup_features(void *ehdr_p, void *phdr_p,
+			struct file *file, bool interp)
+{
+	int err = 0;
+	int shstk = 0;
+	int ibt = 0;
+
+	struct elf64_hdr *ehdr64 = ehdr_p;
+
+	if (!cpu_feature_enabled(X86_FEATURE_SHSTK))
+		return 0;
+
+	if (ehdr64->e_ident[EI_CLASS] == ELFCLASS64) {
+		struct elf64_phdr *phdr64 = phdr_p;
+
+		err = check_pt_note_64(file, phdr64, ehdr64->e_phnum,
+				       &shstk, &ibt);
+		if (err < 0)
+			goto out;
+	} else {
+#ifdef CONFIG_COMPAT
+		struct elf32_hdr *ehdr32 = ehdr_p;
+
+		if (ehdr32->e_ident[EI_CLASS] == ELFCLASS32) {
+			struct elf32_phdr *phdr32 = phdr_p;
+
+			err = check_pt_note_32(file, phdr32, ehdr32->e_phnum,
+					       &shstk, &ibt);
+			if (err < 0)
+				goto out;
+		}
+#endif
+	}
+
+	current->thread.cet.shstk_enabled = 0;
+	current->thread.cet.shstk_base = 0;
+	current->thread.cet.shstk_size = 0;
+	if (cpu_feature_enabled(X86_FEATURE_SHSTK)) {
+		if (shstk) {
+			err = cet_setup_shstk();
+			if (err < 0)
+				goto out;
+		}
+	}
+out:
+	return err;
+}
diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 4ad6f669fe34..9ddc6d01e779 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -1081,6 +1081,22 @@ static int load_elf_binary(struct linux_binprm *bprm)
 		goto out_free_dentry;
 	}
 
+#ifdef CONFIG_ARCH_HAS_PROGRAM_PROPERTIES
+
+	if (interpreter) {
+		retval = arch_setup_features(&loc->interp_elf_ex,
+					     interp_elf_phdata,
+					     interpreter, true);
+	} else {
+		retval = arch_setup_features(&loc->elf_ex,
+					     elf_phdata,
+					     bprm->file, false);
+	}
+
+	if (retval < 0)
+		goto out_free_dentry;
+#endif
+
 	if (elf_interpreter) {
 		unsigned long interp_map_addr = 0;
 
diff --git a/include/uapi/linux/elf.h b/include/uapi/linux/elf.h
index e2535d6dcec7..f69ed8702271 100644
--- a/include/uapi/linux/elf.h
+++ b/include/uapi/linux/elf.h
@@ -372,6 +372,7 @@ typedef struct elf64_shdr {
 #define NT_PRFPREG	2
 #define NT_PRPSINFO	3
 #define NT_TASKSTRUCT	4
+#define NT_GNU_PROPERTY_TYPE_0 5
 #define NT_AUXV		6
 /*
  * Note to userspace developers: size of NT_SIGINFO note may increase
-- 
2.15.1
