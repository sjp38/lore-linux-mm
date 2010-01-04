Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B9588600068
	for <linux-mm@kvack.org>; Sun,  3 Jan 2010 20:20:38 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o041KZvV017903
	for <linux-mm@kvack.org> (envelope-from d.hatayama@jp.fujitsu.com);
	Mon, 4 Jan 2010 10:20:35 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D59845DE51
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 10:20:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 404A245DE4E
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 10:20:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 24C291DB803C
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 10:20:33 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A42751DB803F
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 10:20:32 +0900 (JST)
Date: Mon, 04 Jan 2010 10:20:31 +0900 (JST)
Message-Id: <20100104.102031.39158950.d.hatayama@jp.fujitsu.com>
Subject: [RESEND][mmotm][PATCH v2, 3/5] elf coredump: replace
 ELF_CORE_EXTRA_* macros by functions
From: Daisuke HATAYAMA <d.hatayama@jp.fujitsu.com>
In-Reply-To: <20100104.100607.189714443.d.hatayama@jp.fujitsu.com>
References: <20100104.100607.189714443.d.hatayama@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mhiramat@redhat.com, xiyou.wangcong@gmail.com, andi@firstfloor.org, jdike@addtoit.com, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

elf_core_dump() and elf_fdpic_core_dump() use #ifdef and the
corresponding macro for hiding _multiline_ logics in functions. This
patch removes #ifdef and replaces ELF_CORE_EXTRA_* by corresponding
functions. For architectures not implemeonting ELF_CORE_EXTRA_*, we
use weak functions in order to reduce a range of modification.

This cleanup is for my next patches, but I think this cleanup itself
is worth doing regardless of my firnal purpose.

Signed-off-by: Daisuke HATAYAMA <d.hatayama@jp.fujitsu.com>
---
 arch/ia64/ia32/binfmt_elf32.c |    1 +
 arch/ia64/ia32/elfcore32.h    |   17 ++++++++++
 arch/ia64/include/asm/elf.h   |   48 -----------------------------
 arch/ia64/kernel/Makefile     |    2 +
 arch/ia64/kernel/elfcore.c    |   64 +++++++++++++++++++++++++++++++++++++++
 arch/um/sys-i386/Makefile     |    2 +
 arch/um/sys-i386/asm/elf.h    |   43 --------------------------
 arch/um/sys-i386/elfcore.c    |   67 +++++++++++++++++++++++++++++++++++++++++
 fs/binfmt_elf.c               |   14 +++-----
 fs/binfmt_elf_fdpic.c         |   14 +++-----
 include/linux/elf.h           |    2 +
 include/linux/elfcore.h       |   16 ++++++++++
 kernel/Makefile               |    2 +
 kernel/elfcore.c              |   23 ++++++++++++++
 14 files changed, 206 insertions(+), 109 deletions(-)
 create mode 100644 arch/ia64/kernel/elfcore.c
 create mode 100644 arch/um/sys-i386/elfcore.c
 create mode 100644 kernel/elfcore.c

diff --git a/arch/ia64/ia32/binfmt_elf32.c b/arch/ia64/ia32/binfmt_elf32.c
index c69552b..2328f44 100644
--- a/arch/ia64/ia32/binfmt_elf32.c
+++ b/arch/ia64/ia32/binfmt_elf32.c
@@ -43,6 +43,7 @@ randomize_stack_top(unsigned long stack_top);
 #undef SET_PERSONALITY
 #define SET_PERSONALITY(ex)	elf32_set_personality()
 
+#undef elf_read_implies_exec
 #define elf_read_implies_exec(ex, have_pt_gnu_stack)	(!(have_pt_gnu_stack))
 
 /* Ugly but avoids duplication */
diff --git a/arch/ia64/ia32/elfcore32.h b/arch/ia64/ia32/elfcore32.h
index 6577257..7877601 100644
--- a/arch/ia64/ia32/elfcore32.h
+++ b/arch/ia64/ia32/elfcore32.h
@@ -8,6 +8,8 @@
 #ifndef _ELFCORE32_H_
 #define _ELFCORE32_H_
 
+#include <linux/elf.h>
+
 #include <asm/intrinsics.h>
 #include <asm/uaccess.h>
 
@@ -145,4 +147,19 @@ elf_core_copy_task_xfpregs(struct task_struct *tsk, elf_fpxregset_t *xfpu)
 	return 1;
 }
 
+/*
+ * These functions parameterize elf_core_dump in fs/binfmt_elf.c to write out
+ * extra segments containing the gate DSO contents.  Dumping its
+ * contents makes post-mortem fully interpretable later without matching up
+ * the same kernel and hardware config to see what PC values meant.
+ * Dumping its extra ELF program headers includes all the other information
+ * a debugger needs to easily find how the gate DSO was being used.
+ */
+extern Elf32_Half elf_core_extra_phdrs(void);
+extern int
+elf_core_write_extra_phdrs(struct file *file, loff_t offset, size_t *size,
+			   unsigned long limit);
+extern int
+elf_core_write_extra_data(struct file *file, size_t *size, unsigned long limit);
+
 #endif /* _ELFCORE32_H_ */
diff --git a/arch/ia64/include/asm/elf.h b/arch/ia64/include/asm/elf.h
index e14108b..60af1ef 100644
--- a/arch/ia64/include/asm/elf.h
+++ b/arch/ia64/include/asm/elf.h
@@ -217,54 +217,6 @@ do {										\
 	NEW_AUX_ENT(AT_SYSINFO_EHDR, (unsigned long) GATE_EHDR);		\
 } while (0)
 
-
-/*
- * These macros parameterize elf_core_dump in fs/binfmt_elf.c to write out
- * extra segments containing the gate DSO contents.  Dumping its
- * contents makes post-mortem fully interpretable later without matching up
- * the same kernel and hardware config to see what PC values meant.
- * Dumping its extra ELF program headers includes all the other information
- * a debugger needs to easily find how the gate DSO was being used.
- */
-#define ELF_CORE_EXTRA_PHDRS		(GATE_EHDR->e_phnum)
-#define ELF_CORE_WRITE_EXTRA_PHDRS						\
-do {										\
-	const struct elf_phdr *const gate_phdrs =			      \
-		(const struct elf_phdr *) (GATE_ADDR + GATE_EHDR->e_phoff);   \
-	int i;									\
-	Elf64_Off ofs = 0;						      \
-	for (i = 0; i < GATE_EHDR->e_phnum; ++i) {				\
-		struct elf_phdr phdr = gate_phdrs[i];			      \
-		if (phdr.p_type == PT_LOAD) {					\
-			phdr.p_memsz = PAGE_ALIGN(phdr.p_memsz);	      \
-			phdr.p_filesz = phdr.p_memsz;			      \
-			if (ofs == 0) {					      \
-				ofs = phdr.p_offset = offset;		      \
-			offset += phdr.p_filesz;				\
-		}							      \
-		else							      \
-				phdr.p_offset = ofs;			      \
-		}							      \
-		else							      \
-			phdr.p_offset += ofs;					\
-		phdr.p_paddr = 0; /* match other core phdrs */			\
-		DUMP_WRITE(&phdr, sizeof(phdr));				\
-	}									\
-} while (0)
-#define ELF_CORE_WRITE_EXTRA_DATA					\
-do {									\
-	const struct elf_phdr *const gate_phdrs =			      \
-		(const struct elf_phdr *) (GATE_ADDR + GATE_EHDR->e_phoff);   \
-	int i;								\
-	for (i = 0; i < GATE_EHDR->e_phnum; ++i) {			\
-		if (gate_phdrs[i].p_type == PT_LOAD) {			      \
-			DUMP_WRITE((void *) gate_phdrs[i].p_vaddr,	      \
-				   PAGE_ALIGN(gate_phdrs[i].p_memsz));	      \
-			break;						      \
-		}							      \
-	}								\
-} while (0)
-
 /*
  * format for entries in the Global Offset Table
  */
diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index 2a75e93..1b3d65a 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -51,6 +51,8 @@ endif
 obj-$(CONFIG_DMAR)		+= pci-dma.o
 obj-$(CONFIG_SWIOTLB)		+= pci-swiotlb.o
 
+obj-$(CONFIG_BINFMT_ELF)	+= elfcore.o
+
 # fp_emulate() expects f2-f5,f16-f31 to contain the user-level state.
 CFLAGS_traps.o  += -mfixed-range=f2-f5,f16-f31
 
diff --git a/arch/ia64/kernel/elfcore.c b/arch/ia64/kernel/elfcore.c
new file mode 100644
index 0000000..57a2298
--- /dev/null
+++ b/arch/ia64/kernel/elfcore.c
@@ -0,0 +1,64 @@
+#include <linux/elf.h>
+#include <linux/coredump.h>
+#include <linux/fs.h>
+#include <linux/mm.h>
+
+#include <asm/elf.h>
+
+
+Elf64_Half elf_core_extra_phdrs(void)
+{
+	return GATE_EHDR->e_phnum;
+}
+
+int elf_core_write_extra_phdrs(struct file *file, loff_t offset, size_t *size,
+			       unsigned long limit)
+{
+	const struct elf_phdr *const gate_phdrs =
+		(const struct elf_phdr *) (GATE_ADDR + GATE_EHDR->e_phoff);
+	int i;
+	Elf64_Off ofs = 0;
+
+	for (i = 0; i < GATE_EHDR->e_phnum; ++i) {
+		struct elf_phdr phdr = gate_phdrs[i];
+
+		if (phdr.p_type == PT_LOAD) {
+			phdr.p_memsz = PAGE_ALIGN(phdr.p_memsz);
+			phdr.p_filesz = phdr.p_memsz;
+			if (ofs == 0) {
+				ofs = phdr.p_offset = offset;
+				offset += phdr.p_filesz;
+			} else {
+				phdr.p_offset = ofs;
+			}
+		} else {
+			phdr.p_offset += ofs;
+		}
+		phdr.p_paddr = 0; /* match other core phdrs */
+		*size += sizeof(phdr);
+		if (*size > limit || !dump_write(file, &phdr, sizeof(phdr)))
+			return 0;
+	}
+	return 1;
+}
+
+int elf_core_write_extra_data(struct file *file, size_t *size,
+			      unsigned long limit)
+{
+	const struct elf_phdr *const gate_phdrs =
+		(const struct elf_phdr *) (GATE_ADDR + GATE_EHDR->e_phoff);
+	int i;
+
+	for (i = 0; i < GATE_EHDR->e_phnum; ++i) {
+		if (gate_phdrs[i].p_type == PT_LOAD) {
+			void *addr = (void *)gate_phdrs[i].p_vaddr;
+			size_t memsz = PAGE_ALIGN(gate_phdrs[i].p_memsz);
+
+			*size += memsz;
+			if (*size > limit || !dump_write(file, addr, memsz))
+				return 0;
+			break;
+		}
+	}
+	return 1;
+}
diff --git a/arch/um/sys-i386/Makefile b/arch/um/sys-i386/Makefile
index 1b549bc..804b28d 100644
--- a/arch/um/sys-i386/Makefile
+++ b/arch/um/sys-i386/Makefile
@@ -6,6 +6,8 @@ obj-y = bug.o bugs.o checksum.o delay.o fault.o ksyms.o ldt.o ptrace.o \
 	ptrace_user.o setjmp.o signal.o stub.o stub_segv.o syscalls.o sysrq.o \
 	sys_call_table.o tls.o
 
+obj-$(CONFIG_BINFMT_ELF) += elfcore.o
+
 subarch-obj-y = lib/semaphore_32.o lib/string_32.o
 subarch-obj-$(CONFIG_HIGHMEM) += mm/highmem_32.o
 subarch-obj-$(CONFIG_MODULES) += kernel/module.o
diff --git a/arch/um/sys-i386/asm/elf.h b/arch/um/sys-i386/asm/elf.h
index 7708854..e64cd41 100644
--- a/arch/um/sys-i386/asm/elf.h
+++ b/arch/um/sys-i386/asm/elf.h
@@ -116,47 +116,4 @@ do {								\
 	}							\
 } while (0)
 
-/*
- * These macros parameterize elf_core_dump in fs/binfmt_elf.c to write out
- * extra segments containing the vsyscall DSO contents.  Dumping its
- * contents makes post-mortem fully interpretable later without matching up
- * the same kernel and hardware config to see what PC values meant.
- * Dumping its extra ELF program headers includes all the other information
- * a debugger needs to easily find how the vsyscall DSO was being used.
- */
-#define ELF_CORE_EXTRA_PHDRS						      \
-	(vsyscall_ehdr ? (((struct elfhdr *)vsyscall_ehdr)->e_phnum) : 0 )
-
-#define ELF_CORE_WRITE_EXTRA_PHDRS					      \
-if ( vsyscall_ehdr ) {							      \
-	const struct elfhdr *const ehdrp = (struct elfhdr *)vsyscall_ehdr;    \
-	const struct elf_phdr *const phdrp =				      \
-		(const struct elf_phdr *) (vsyscall_ehdr + ehdrp->e_phoff);   \
-	int i;								      \
-	Elf32_Off ofs = 0;						      \
-	for (i = 0; i < ehdrp->e_phnum; ++i) {				      \
-		struct elf_phdr phdr = phdrp[i];			      \
-		if (phdr.p_type == PT_LOAD) {				      \
-			ofs = phdr.p_offset = offset;			      \
-			offset += phdr.p_filesz;			      \
-		}							      \
-		else							      \
-			phdr.p_offset += ofs;				      \
-		phdr.p_paddr = 0; /* match other core phdrs */		      \
-		DUMP_WRITE(&phdr, sizeof(phdr));			      \
-	}								      \
-}
-#define ELF_CORE_WRITE_EXTRA_DATA					      \
-if ( vsyscall_ehdr ) {							      \
-	const struct elfhdr *const ehdrp = (struct elfhdr *)vsyscall_ehdr;    \
-	const struct elf_phdr *const phdrp =				      \
-		(const struct elf_phdr *) (vsyscall_ehdr + ehdrp->e_phoff);   \
-	int i;								      \
-	for (i = 0; i < ehdrp->e_phnum; ++i) {				      \
-		if (phdrp[i].p_type == PT_LOAD)				      \
-			DUMP_WRITE((void *) phdrp[i].p_vaddr,		      \
-				   phdrp[i].p_filesz);			      \
-	}								      \
-}
-
 #endif
diff --git a/arch/um/sys-i386/elfcore.c b/arch/um/sys-i386/elfcore.c
new file mode 100644
index 0000000..30cac52
--- /dev/null
+++ b/arch/um/sys-i386/elfcore.c
@@ -0,0 +1,67 @@
+#include <linux/elf.h>
+#include <linux/coredump.h>
+#include <linux/fs.h>
+#include <linux/mm.h>
+
+#include <asm/elf.h>
+
+
+Elf32_Half elf_core_extra_phdrs(void)
+{
+	return vsyscall_ehdr ? (((struct elfhdr *)vsyscall_ehdr)->e_phnum) : 0;
+}
+
+int elf_core_write_extra_phdrs(struct file *file, loff_t offset, size_t *size,
+			       unsigned long limit)
+{
+	if ( vsyscall_ehdr ) {
+		const struct elfhdr *const ehdrp =
+			(struct elfhdr *) vsyscall_ehdr;
+		const struct elf_phdr *const phdrp =
+			(const struct elf_phdr *) (vsyscall_ehdr + ehdrp->e_phoff);
+		int i;
+		Elf32_Off ofs = 0;
+
+		for (i = 0; i < ehdrp->e_phnum; ++i) {
+			struct elf_phdr phdr = phdrp[i];
+
+			if (phdr.p_type == PT_LOAD) {
+				ofs = phdr.p_offset = offset;
+				offset += phdr.p_filesz;
+			} else {
+				phdr.p_offset += ofs;
+			}
+			phdr.p_paddr = 0; /* match other core phdrs */
+			*size += sizeof(phdr);
+			if (*size > limit
+			    || !dump_write(file, &phdr, sizeof(phdr)))
+				return 0;
+		}
+	}
+	return 1;
+}
+
+int elf_core_write_extra_data(struct file *file, size_t *size,
+			      unsigned long limit)
+{
+	if ( vsyscall_ehdr ) {
+		const struct elfhdr *const ehdrp =
+			(struct elfhdr *) vsyscall_ehdr;
+		const struct elf_phdr *const phdrp =
+			(const struct elf_phdr *) (vsyscall_ehdr + ehdrp->e_phoff);
+		int i;
+
+		for (i = 0; i < ehdrp->e_phnum; ++i) {
+			if (phdrp[i].p_type == PT_LOAD) {
+				void *addr = (void *) phdrp[i].p_vaddr;
+				size_t filesz = phdrp[i].p_filesz;
+
+				*size += filesz;
+				if (*size > limit
+				    || !dump_write(file, addr, filesz))
+					return 0;
+			}
+		}
+	}
+	return 1;
+}
diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index a0fe475..1b7e9de 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -1901,9 +1901,7 @@ static int elf_core_dump(struct coredump_params *cprm)
 	 * Please check DEFAULT_MAX_MAP_COUNT definition when you modify here.
 	 */
 	segs = current->mm->map_count;
-#ifdef ELF_CORE_EXTRA_PHDRS
-	segs += ELF_CORE_EXTRA_PHDRS;
-#endif
+	segs += elf_core_extra_phdrs();
 
 	gate_vma = get_gate_vma(current);
 	if (gate_vma != NULL)
@@ -1981,9 +1979,8 @@ static int elf_core_dump(struct coredump_params *cprm)
 			goto end_coredump;
 	}
 
-#ifdef ELF_CORE_WRITE_EXTRA_PHDRS
-	ELF_CORE_WRITE_EXTRA_PHDRS;
-#endif
+	if (!elf_core_write_extra_phdrs(cprm->file, offset, &size, cprm->limit))
+		goto end_coredump;
 
  	/* write out the notes section */
 	if (!write_note_info(&info, cprm->file, &foffset))
@@ -2022,9 +2019,8 @@ static int elf_core_dump(struct coredump_params *cprm)
 		}
 	}
 
-#ifdef ELF_CORE_WRITE_EXTRA_DATA
-	ELF_CORE_WRITE_EXTRA_DATA;
-#endif
+	if (!elf_core_write_extra_data(cprm->file, &size, cprm->limit))
+		goto end_coredump;
 
 end_coredump:
 	set_fs(fs);
diff --git a/fs/binfmt_elf_fdpic.c b/fs/binfmt_elf_fdpic.c
index d928e5f..4c16ff6 100644
--- a/fs/binfmt_elf_fdpic.c
+++ b/fs/binfmt_elf_fdpic.c
@@ -1652,9 +1652,7 @@ static int elf_fdpic_core_dump(struct coredump_params *cprm)
 	elf_core_copy_regs(&prstatus->pr_reg, cprm->regs);
 
 	segs = current->mm->map_count;
-#ifdef ELF_CORE_EXTRA_PHDRS
-	segs += ELF_CORE_EXTRA_PHDRS;
-#endif
+	segs += elf_core_extra_phdrs();
 
 	/* Set up header */
 	fill_elf_fdpic_header(elf, segs + 1);	/* including notes section */
@@ -1761,9 +1759,8 @@ static int elf_fdpic_core_dump(struct coredump_params *cprm)
 			goto end_coredump;
 	}
 
-#ifdef ELF_CORE_WRITE_EXTRA_PHDRS
-	ELF_CORE_WRITE_EXTRA_PHDRS;
-#endif
+	if (!elf_core_write_extra_phdrs(cprm->file, offset, &size, cprm->limit))
+		goto end_coredump;
 
  	/* write out the notes section */
 	for (i = 0; i < numnote; i++)
@@ -1787,9 +1784,8 @@ static int elf_fdpic_core_dump(struct coredump_params *cprm)
 				    mm_flags) < 0)
 		goto end_coredump;
 
-#ifdef ELF_CORE_WRITE_EXTRA_DATA
-	ELF_CORE_WRITE_EXTRA_DATA;
-#endif
+	if (!elf_core_write_extra_data(cprm->file, &size, cprm->limit))
+		goto end_coredump;
 
 	if (file->f_pos != offset) {
 		/* Sanity check */
diff --git a/include/linux/elf.h b/include/linux/elf.h
index 90a4ed0..d103127 100644
--- a/include/linux/elf.h
+++ b/include/linux/elf.h
@@ -386,6 +386,7 @@ extern Elf32_Dyn _DYNAMIC [];
 #define elf_phdr	elf32_phdr
 #define elf_note	elf32_note
 #define elf_addr_t	Elf32_Off
+#define Elf_Half	Elf32_Half
 
 #else
 
@@ -394,6 +395,7 @@ extern Elf64_Dyn _DYNAMIC [];
 #define elf_phdr	elf64_phdr
 #define elf_note	elf64_note
 #define elf_addr_t	Elf64_Off
+#define Elf_Half	Elf64_Half
 
 #endif
 
diff --git a/include/linux/elfcore.h b/include/linux/elfcore.h
index 00d6a68..cfda74f 100644
--- a/include/linux/elfcore.h
+++ b/include/linux/elfcore.h
@@ -8,6 +8,8 @@
 #include <linux/user.h>
 #endif
 #include <linux/ptrace.h>
+#include <linux/elf.h>
+#include <linux/fs.h>
 
 struct elf_siginfo
 {
@@ -150,5 +152,19 @@ static inline int elf_core_copy_task_xfpregs(struct task_struct *t, elf_fpxregse
 
 #endif /* __KERNEL__ */
 
+/*
+ * These functions parameterize elf_core_dump in fs/binfmt_elf.c to write out
+ * extra segments containing the gate DSO contents.  Dumping its
+ * contents makes post-mortem fully interpretable later without matching up
+ * the same kernel and hardware config to see what PC values meant.
+ * Dumping its extra ELF program headers includes all the other information
+ * a debugger needs to easily find how the gate DSO was being used.
+ */
+extern Elf_Half elf_core_extra_phdrs(void);
+extern int
+elf_core_write_extra_phdrs(struct file *file, loff_t offset, size_t *size,
+			   unsigned long limit);
+extern int
+elf_core_write_extra_data(struct file *file, size_t *size, unsigned long limit);
 
 #endif /* _LINUX_ELFCORE_H */
diff --git a/kernel/Makefile b/kernel/Makefile
index 01435e5..b6d297d 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -102,6 +102,8 @@ obj-$(CONFIG_SLOW_WORK_DEBUG) += slow-work-debugfs.o
 obj-$(CONFIG_PERF_EVENTS) += perf_event.o
 obj-$(CONFIG_HAVE_HW_BREAKPOINT) += hw_breakpoint.o
 obj-$(CONFIG_USER_RETURN_NOTIFIER) += user-return-notifier.o
+obj-$(CONFIG_BINFMT_ELF) += elfcore.o
+obj-$(CONFIG_BINFMT_ELF_FDPIC) += elfcore.o
 
 ifneq ($(CONFIG_SCHED_OMIT_FRAME_POINTER),y)
 # According to Alan Modra <alan@linuxcare.com.au>, the -fno-omit-frame-pointer is
diff --git a/kernel/elfcore.c b/kernel/elfcore.c
new file mode 100644
index 0000000..5445741
--- /dev/null
+++ b/kernel/elfcore.c
@@ -0,0 +1,23 @@
+#include <linux/elf.h>
+#include <linux/fs.h>
+#include <linux/mm.h>
+
+#include <asm/elf.h>
+
+
+Elf_Half __weak elf_core_extra_phdrs(void)
+{
+	return 0;
+}
+
+int __weak elf_core_write_extra_phdrs(struct file *file, loff_t offset, size_t *size,
+				      unsigned long limit)
+{
+	return 1;
+}
+
+int __weak elf_core_write_extra_data(struct file *file, size_t *size,
+				     unsigned long limit)
+{
+	return 1;
+}
-- 
1.6.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
