Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5555D6B0270
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 18:31:19 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v25-v6so6693461pfm.11
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 15:31:19 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id e6-v6si18699657pfa.217.2018.07.10.15.31.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 15:31:17 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v2 20/27] x86/cet/shstk: ELF header parsing of CET
Date: Tue, 10 Jul 2018 15:26:32 -0700
Message-Id: <20180710222639.8241-21-yu-cheng.yu@intel.com>
In-Reply-To: <20180710222639.8241-1-yu-cheng.yu@intel.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

Look in .note.gnu.property of an ELF file and check if shadow stack needs
to be enabled for the task.

Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/Kconfig                         |   4 +
 arch/x86/include/asm/elf.h               |   5 +
 arch/x86/include/uapi/asm/elf_property.h |  16 ++
 arch/x86/kernel/Makefile                 |   2 +
 arch/x86/kernel/elf.c                    | 262 +++++++++++++++++++++++
 fs/binfmt_elf.c                          |  16 ++
 include/uapi/linux/elf.h                 |   1 +
 7 files changed, 306 insertions(+)
 create mode 100644 arch/x86/include/uapi/asm/elf_property.h
 create mode 100644 arch/x86/kernel/elf.c

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 44af5e1aaa4a..768343768643 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1923,12 +1923,16 @@ config X86_INTEL_CET
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
index fbb2d91fb756..36b14ef410c8 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -141,6 +141,8 @@ obj-$(CONFIG_UNWINDER_GUESS)		+= unwind_guess.o
 
 obj-$(CONFIG_X86_INTEL_CET)		+= cet.o
 
+obj-$(CONFIG_ARCH_HAS_PROGRAM_PROPERTIES) += elf.o
+
 ###
 # 64 bit specific files
 ifeq ($(CONFIG_X86_64),y)
diff --git a/arch/x86/kernel/elf.c b/arch/x86/kernel/elf.c
new file mode 100644
index 000000000000..233f6dad9c1f
--- /dev/null
+++ b/arch/x86/kernel/elf.c
@@ -0,0 +1,262 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * Look at an ELF file's .note.gnu.property and determine if the file
+ * supports shadow stack and/or indirect branch tracking.
+ * The path from the ELF header to the note section is the following:
+ * elfhdr->elf_phdr->elf_note->property[].
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
+/*
+ * The .note.gnu.property layout:
+ *
+ *	struct elf_note {
+ *		u32 n_namesz; --> sizeof(n_name[]); always (4)
+ *		u32 n_ndescsz;--> sizeof(property[])
+ *		u32 n_type;   --> always NT_GNU_PROPERTY_TYPE_0
+ *	};
+ *
+ *	char n_name[4]; --> always 'GNU\0'
+ *
+ *	struct {
+ *		u32 pr_type;
+ *		u32 pr_datasz;--> sizeof(pr_data[])
+ *		u8  pr_data[pr_datasz];
+ *	} property[];
+ */
+
+#define ELF_NOTE_DESC_OFFSET(n, align) \
+	round_up(sizeof(*n) + n->n_namesz, (align))
+
+#define ELF_NOTE_NEXT_OFFSET(n, align) \
+	round_up(ELF_NOTE_DESC_OFFSET(n, align) + n->n_descsz, (align))
+
+#define NOTE_PROPERTY_TYPE_0(n) \
+	((n->n_namesz == 4) && (memcmp(n + 1, "GNU", 4) == 0) && \
+	 (n->n_type == NT_GNU_PROPERTY_TYPE_0))
+
+#define NOTE_SIZE_BAD(n, align, max) \
+	((n->n_descsz < 8) || ((n->n_descsz % align) != 0) || \
+	 (((u8 *)(n + 1) + 4 + n->n_descsz) > (max)))
+
+/*
+ * Go through the property array and look for the one
+ * with pr_type of GNU_PROPERTY_X86_FEATURE_1_AND.
+ */
+static u32 find_x86_feature_1(u8 *buf, u32 size, u32 align)
+{
+	u8 *end = buf + size;
+	u8 *ptr = buf;
+
+	while (1) {
+		u32 pr_type, pr_datasz;
+
+		if ((ptr + 4) >= end)
+			break;
+
+		pr_type = *(u32 *)ptr;
+		pr_datasz = *(u32 *)(ptr + 4);
+		ptr += 8;
+
+		if ((ptr + pr_datasz) >= end)
+			break;
+
+		if (pr_type == GNU_PROPERTY_X86_FEATURE_1_AND &&
+		    pr_datasz == 4)
+			return *(u32 *)ptr;
+
+		ptr += pr_datasz;
+	}
+	return 0;
+}
+
+static int find_cet(u8 *buf, u32 size, u32 align, int *shstk, int *ibt)
+{
+	struct elf_note *note = (struct elf_note *)buf;
+	*shstk = 0;
+	*ibt = 0;
+
+	/*
+	 * Go through the note section and find the note
+	 * with n_type of NT_GNU_PROPERTY_TYPE_0.
+	 */
+	while ((unsigned long)(note + 1) - (unsigned long)buf < size) {
+		if (NOTE_PROPERTY_TYPE_0(note)) {
+			u32 p;
+
+			if (NOTE_SIZE_BAD(note, align, buf + size))
+				return 0;
+
+			/*
+			 * Found the note; look at its property array.
+			 */
+			p = find_x86_feature_1((u8 *)(note + 1) + 4,
+					       note->n_descsz, align);
+
+			if (p & GNU_PROPERTY_X86_FEATURE_1_SHSTK)
+				*shstk = 1;
+			if (p & GNU_PROPERTY_X86_FEATURE_1_IBT)
+				*ibt = 1;
+			return 1;
+		}
+
+		/*
+		 * Note sections like .note.ABI-tag and .note.gnu.build-id
+		 * are aligned to 4 bytes in 64-bit ELF objects.  So always
+		 * use phdr->p_align.
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
+	 * PT_NOTE segment is small.  Read at most
+	 * PAGE_SIZE.
+	 */
+	if (note_size > PAGE_SIZE)
+		note_size = PAGE_SIZE;
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
+	 * Go through all PT_NOTE segments.
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
index 0ac456b52bdd..3395f6a631d5 100644
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
index 4e12c423b9fe..dc93982b9664 100644
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
2.17.1
