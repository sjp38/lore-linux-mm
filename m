Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A93A6B02AA
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 11:22:54 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id d69-v6so6188674pgc.22
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 08:22:54 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id g9-v6si6571810plo.328.2018.10.11.08.21.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Oct 2018 08:21:00 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH v5 23/27] x86/cet/shstk: ELF header parsing of Shadow Stack
Date: Thu, 11 Oct 2018 08:15:19 -0700
Message-Id: <20181011151523.27101-24-yu-cheng.yu@intel.com>
In-Reply-To: <20181011151523.27101-1-yu-cheng.yu@intel.com>
References: <20181011151523.27101-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

Look in .note.gnu.property of an ELF file and check if Shadow Stack needs
to be enabled for the task.

Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/Kconfig                         |   4 +
 arch/x86/include/asm/elf.h               |   5 +
 arch/x86/include/uapi/asm/elf_property.h |  15 +
 arch/x86/kernel/Makefile                 |   2 +
 arch/x86/kernel/elf.c                    | 341 +++++++++++++++++++++++
 fs/binfmt_elf.c                          |  15 +
 include/uapi/linux/elf.h                 |   1 +
 7 files changed, 383 insertions(+)
 create mode 100644 arch/x86/include/uapi/asm/elf_property.h
 create mode 100644 arch/x86/kernel/elf.c

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 5f73335b7a3a..ac2244896a18 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1919,6 +1919,9 @@ config X86_INTEL_CET
 config ARCH_HAS_SHSTK
 	def_bool n
 
+config ARCH_HAS_PROGRAM_PROPERTIES
+	def_bool n
+
 config X86_INTEL_SHADOW_STACK_USER
 	prompt "Intel Shadow Stack for user-mode"
 	def_bool n
@@ -1927,6 +1930,7 @@ config X86_INTEL_SHADOW_STACK_USER
 	select X86_INTEL_CET
 	select ARCH_HAS_SHSTK
 	select VM_AREA_GUARD
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
index 000000000000..af361207718c
--- /dev/null
+++ b/arch/x86/include/uapi/asm/elf_property.h
@@ -0,0 +1,15 @@
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
index 000000000000..2e2030a0462b
--- /dev/null
+++ b/arch/x86/kernel/elf.c
@@ -0,0 +1,341 @@
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
+#include <asm/prctl.h>
+#include <asm/processor.h>
+#include <uapi/linux/elf-em.h>
+#include <uapi/linux/prctl.h>
+#include <linux/binfmts.h>
+#include <linux/elf.h>
+#include <linux/slab.h>
+#include <linux/fs.h>
+#include <linux/uaccess.h>
+#include <linux/string.h>
+#include <linux/compat.h>
+
+/*
+ * The .note.gnu.property layout:
+ *
+ *	struct elf_note {
+ *		u32 n_namesz; --> sizeof(n_name[]); always (4)
+ *		u32 n_ndescsz;--> sizeof(property[])
+ *		u32 n_type;   --> always NT_GNU_PROPERTY_TYPE_0
+ *	};
+ *	char n_name[4]; --> always 'GNU\0'
+ *
+ *	struct {
+ *		struct property_x86 {
+ *			u32 pr_type;
+ *			u32 pr_datasz;
+ *		};
+ *		u8 pr_data[pr_datasz];
+ *	}[];
+ */
+
+#define BUF_SIZE (PAGE_SIZE / 4)
+
+struct property_x86 {
+	u32 pr_type;
+	u32 pr_datasz;
+};
+
+typedef bool (test_fn)(void *buf, u32 *arg);
+typedef void *(next_fn)(void *buf, u32 *arg);
+
+static inline bool test_note_type_0(void *buf, u32 *arg)
+{
+	struct elf_note *n = buf;
+
+	return ((n->n_namesz == 4) && (memcmp(n + 1, "GNU", 4) == 0) &&
+		(n->n_type == NT_GNU_PROPERTY_TYPE_0));
+}
+
+static inline void *next_note(void *buf, u32 *arg)
+{
+	struct elf_note *n = buf;
+	u32 align = *arg;
+	int size;
+
+	size = round_up(sizeof(*n) + n->n_namesz, align);
+	size = round_up(size + n->n_descsz, align);
+
+	if (buf + size < buf)
+		return NULL;
+	else
+		return (buf + size);
+}
+
+static inline bool test_property_x86(void *buf, u32 *arg)
+{
+	struct property_x86 *pr = buf;
+	u32 max_type = *arg;
+
+	if (pr->pr_type > max_type)
+		*arg = pr->pr_type;
+
+	return (pr->pr_type == GNU_PROPERTY_X86_FEATURE_1_AND);
+}
+
+static inline void *next_property(void *buf, u32 *arg)
+{
+	struct property_x86 *pr = buf;
+	u32 max_type = *arg;
+
+	if ((buf + sizeof(*pr) +  pr->pr_datasz < buf) ||
+	    (pr->pr_type > GNU_PROPERTY_X86_FEATURE_1_AND) ||
+	    (pr->pr_type > max_type))
+		return NULL;
+	else
+		return (buf + sizeof(*pr) + pr->pr_datasz);
+}
+
+/*
+ * Scan 'buf' for a pattern; return true if found.
+ * *pos is the distance from the beginning of buf to where
+ * the searched item or the next item is located.
+ */
+static int scan(u8 *buf, u32 buf_size, int item_size,
+		 test_fn test, next_fn next, u32 *arg, u32 *pos)
+{
+	int found = 0;
+	u8 *p, *max;
+
+	max = buf + buf_size;
+	if (max < buf)
+		return 0;
+
+	p = buf;
+
+	while ((p + item_size < max) && (p + item_size > buf)) {
+		if (test(p, arg)) {
+			found = 1;
+			break;
+		}
+
+		p = next(p, arg);
+	}
+
+	*pos = (p + item_size <= buf) ? 0 : (u32)(p - buf);
+	return found;
+}
+
+/*
+ * Search a NT_GNU_PROPERTY_TYPE_0 for GNU_PROPERTY_X86_FEATURE_1_AND.
+ */
+static int find_feature_x86(struct file *file, unsigned long desc_size,
+			    loff_t file_offset, u8 *buf, u32 *feature)
+{
+	u32 buf_pos;
+	unsigned long read_size;
+	unsigned long done;
+	int found = 0;
+	int ret = 0;
+	u32 last_pr = 0;
+
+	*feature = 0;
+	buf_pos = 0;
+
+	for (done = 0; done < desc_size; done += buf_pos) {
+		read_size = desc_size - done;
+		if (read_size > BUF_SIZE)
+			read_size = BUF_SIZE;
+
+		ret = kernel_read(file, buf, read_size, &file_offset);
+
+		if (ret != read_size)
+			return (ret < 0) ? ret : -EIO;
+
+		ret = 0;
+		found = scan(buf, read_size, sizeof(struct property_x86),
+			     test_property_x86, next_property,
+			     &last_pr, &buf_pos);
+
+		if ((!buf_pos) || found)
+			break;
+
+		file_offset += buf_pos - read_size;
+	}
+
+	if (found) {
+		struct property_x86 *pr =
+			(struct property_x86 *)(buf + buf_pos);
+
+		if (pr->pr_datasz == 4) {
+			u32 *max =  (u32 *)(buf + read_size);
+			u32 *data = (u32 *)((u8 *)pr + sizeof(*pr));
+
+			if (data + 1 <= max) {
+				*feature = *data;
+			} else {
+				file_offset += buf_pos - read_size;
+				file_offset += sizeof(*pr);
+				ret = kernel_read(file, feature, 4,
+						  &file_offset);
+			}
+		}
+	}
+
+	return ret;
+}
+
+/*
+ * Search a PT_NOTE segment for NT_GNU_PROPERTY_TYPE_0.
+ */
+static int find_note_type_0(struct file *file, unsigned long note_size,
+			    loff_t file_offset, u32 align, u32 *feature)
+{
+	u8 *buf;
+	u32 buf_pos;
+	unsigned long read_size;
+	unsigned long done;
+	int found = 0;
+	int ret = 0;
+
+	buf = kmalloc(BUF_SIZE, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	*feature = 0;
+	buf_pos = 0;
+
+	for (done = 0; done < note_size; done += buf_pos) {
+		read_size = note_size - done;
+		if (read_size > BUF_SIZE)
+			read_size = BUF_SIZE;
+
+		ret = kernel_read(file, buf, read_size, &file_offset);
+
+		if (ret != read_size) {
+			ret = (ret < 0) ? ret : -EIO;
+			kfree(buf);
+			return ret;
+		}
+
+		/*
+		 * item_size = sizeof(struct elf_note) + elf_note.n_namesz.
+		 * n_namesz is 4 for the note type we look for.
+		 */
+		ret = scan(buf, read_size, sizeof(struct elf_note) + 4,
+			      test_note_type_0, next_note,
+			      &align, &buf_pos);
+
+		file_offset += buf_pos - read_size;
+
+		if (ret && !found) {
+			struct elf_note *n =
+				(struct elf_note *)(buf + buf_pos);
+			u32 start = round_up(sizeof(*n) + n->n_namesz, align);
+			u32 total = round_up(start + n->n_descsz, align);
+
+			ret = find_feature_x86(file, n->n_descsz,
+					       file_offset + start,
+					       buf, feature);
+			found++;
+			file_offset += total;
+			buf_pos += total;
+		} else if (!buf_pos || ret) {
+			ret = 0;
+			*feature = 0;
+			break;
+		}
+	}
+
+	kfree(buf);
+	return ret;
+}
+
+#ifdef CONFIG_COMPAT
+static int check_notes_32(struct file *file, struct elf32_phdr *phdr,
+			  int phnum, u32 *feature)
+{
+	int i;
+	int err = 0;
+
+	for (i = 0; i < phnum; i++, phdr++) {
+		if ((phdr->p_type != PT_NOTE) || (phdr->p_align != 4))
+			continue;
+
+		err = find_note_type_0(file, phdr->p_filesz, phdr->p_offset,
+				       phdr->p_align, feature);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+#endif
+
+#ifdef CONFIG_X86_64
+static int check_notes_64(struct file *file, struct elf64_phdr *phdr,
+			  int phnum, u32 *feature)
+{
+	int i;
+	int err = 0;
+
+	for (i = 0; i < phnum; i++, phdr++) {
+		if ((phdr->p_type != PT_NOTE) || (phdr->p_align != 8))
+			continue;
+
+		err = find_note_type_0(file, phdr->p_filesz, phdr->p_offset,
+				       phdr->p_align, feature);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+#endif
+
+int arch_setup_features(void *ehdr_p, void *phdr_p,
+			struct file *file, bool interp)
+{
+	int err = 0;
+	u32 feature = 0;
+
+	struct elf64_hdr *ehdr64 = ehdr_p;
+
+	if (!cpu_x86_cet_enabled())
+		return 0;
+
+	if (ehdr64->e_ident[EI_CLASS] == ELFCLASS64) {
+		struct elf64_phdr *phdr64 = phdr_p;
+
+		err = check_notes_64(file, phdr64, ehdr64->e_phnum,
+				     &feature);
+		if (err < 0)
+			goto out;
+	} else {
+#ifdef CONFIG_COMPAT
+		struct elf32_hdr *ehdr32 = ehdr_p;
+
+		if (ehdr32->e_ident[EI_CLASS] == ELFCLASS32) {
+			struct elf32_phdr *phdr32 = phdr_p;
+
+			err = check_notes_32(file, phdr32, ehdr32->e_phnum,
+					     &feature);
+			if (err < 0)
+				goto out;
+		}
+#endif
+	}
+
+	memset(&current->thread.cet, 0, sizeof(struct cet_status));
+
+	if (cpu_feature_enabled(X86_FEATURE_SHSTK)) {
+		if (feature & GNU_PROPERTY_X86_FEATURE_1_SHSTK) {
+			err = cet_setup_shstk();
+			if (err < 0)
+				goto out;
+		}
+	}
+
+out:
+	return err;
+}
diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index efae2fb0930a..b891aa292b46 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -1081,6 +1081,21 @@ static int load_elf_binary(struct linux_binprm *bprm)
 		goto out_free_dentry;
 	}
 
+#ifdef CONFIG_ARCH_HAS_PROGRAM_PROPERTIES
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
index c5358e0ae7c5..5ef25a565e88 100644
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
