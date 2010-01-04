Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2D201600068
	for <linux-mm@kvack.org>; Sun,  3 Jan 2010 20:20:31 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o041KSum017873
	for <linux-mm@kvack.org> (envelope-from d.hatayama@jp.fujitsu.com);
	Mon, 4 Jan 2010 10:20:28 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 09A7B45DE79
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 10:20:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D2E8245DE6F
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 10:20:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B1C0C1DB803B
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 10:20:27 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 571D61DB803F
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 10:20:27 +0900 (JST)
Date: Mon, 04 Jan 2010 10:20:25 +0900 (JST)
Message-Id: <20100104.102025.183025489.d.hatayama@jp.fujitsu.com>
Subject: [RESEND][mmotm][PATCH v2, 2/5] Move dump_write() and dump_seek()
 into a header file
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

My next patch will replace ELF_CORE_EXTRA_* macros by functions,
putting them into other newly created *.c files. Then, each files will
contain dump_write(), where each pair of binfmt_*.c and elfcore.c
should be the same. So, this patch moves them into a header file with
dump_seek(). Also, the patch deletes confusing DUMP_WRITE macros in
each files.

Signed-off-by: Daisuke HATAYAMA <d.hatayama@jp.fujitsu.com>
---
 fs/binfmt_aout.c         |   49 +++++++----------------------------------
 fs/binfmt_elf.c          |   52 ++++++++++++--------------------------------
 fs/binfmt_elf_fdpic.c    |   54 ++++++++++++---------------------------------
 include/linux/coredump.h |   41 ++++++++++++++++++++++++++++++++++
 4 files changed, 79 insertions(+), 117 deletions(-)
 create mode 100644 include/linux/coredump.h

diff --git a/fs/binfmt_aout.c b/fs/binfmt_aout.c
index 10717fb..75954e8 100644
--- a/fs/binfmt_aout.c
+++ b/fs/binfmt_aout.c
@@ -24,6 +24,7 @@
 #include <linux/binfmts.h>
 #include <linux/personality.h>
 #include <linux/init.h>
+#include <linux/coredump.h>
 
 #include <asm/system.h>
 #include <asm/uaccess.h>
@@ -60,42 +61,6 @@ static int set_brk(unsigned long start, unsigned long end)
 }
 
 /*
- * These are the only things you should do on a core-file: use only these
- * macros to write out all the necessary info.
- */
-
-static int dump_write(struct file *file, const void *addr, int nr)
-{
-	return file->f_op->write(file, addr, nr, &file->f_pos) == nr;
-}
-
-static int dump_seek(struct file *file, loff_t off)
-{
-	if (file->f_op->llseek && file->f_op->llseek != no_llseek) {
-		if (file->f_op->llseek(file, off, SEEK_CUR) < 0)
-			return 0;
-	} else {
-		char *buf = (char *)get_zeroed_page(GFP_KERNEL);
-		if (!buf)
-			return 0;
-		while (off > 0) {
-			unsigned long n = off;
-			if (n > PAGE_SIZE)
-				n = PAGE_SIZE;
-			if (!dump_write(file, buf, n))
-				return 0;
-			off -= n;
-		}
-		free_page((unsigned long)buf);
-	}
-	return 1;
-}
-
-#define DUMP_WRITE(addr, nr)	\
-	if (!dump_write(file, (void *)(addr), (nr))) \
-		goto end_coredump;
-
-/*
  * Routine writes a core dump image in the current directory.
  * Currently only a stub-function.
  *
@@ -146,7 +111,8 @@ static int aout_core_dump(struct coredump_params *cprm)
 
 	set_fs(KERNEL_DS);
 /* struct user */
-	DUMP_WRITE(&dump,sizeof(dump));
+	if (!dump_write(file, &dump, sizeof(dump)))
+		goto end_coredump;
 /* Now dump all of the user data.  Include malloced stuff as well */
 	if (!dump_seek(cprm->file, PAGE_SIZE - sizeof(dump)))
 		goto end_coredump;
@@ -156,17 +122,20 @@ static int aout_core_dump(struct coredump_params *cprm)
 	if (dump.u_dsize != 0) {
 		dump_start = START_DATA(dump);
 		dump_size = dump.u_dsize << PAGE_SHIFT;
-		DUMP_WRITE(dump_start,dump_size);
+		if (!dump_write(file, dump_start, dump_size))
+			goto end_coredump;
 	}
 /* Now prepare to dump the stack area */
 	if (dump.u_ssize != 0) {
 		dump_start = START_STACK(dump);
 		dump_size = dump.u_ssize << PAGE_SHIFT;
-		DUMP_WRITE(dump_start,dump_size);
+		if (!dump_write(file, dump_start, dump_size))
+			goto end_coredump;
 	}
 /* Finally dump the task struct.  Not be used by gdb, but could be useful */
 	set_fs(KERNEL_DS);
-	DUMP_WRITE(current,sizeof(*current));
+	if (!dump_write(file, current, sizeof(*current)))
+		goto end_coredump;
 end_coredump:
 	set_fs(fs);
 	return has_dumped;
diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index edd90c4..a0fe475 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -31,6 +31,7 @@
 #include <linux/random.h>
 #include <linux/elf.h>
 #include <linux/utsname.h>
+#include <linux/coredump.h>
 #include <asm/uaccess.h>
 #include <asm/param.h>
 #include <asm/page.h>
@@ -1108,36 +1109,6 @@ out:
  * Modelled on fs/exec.c:aout_core_dump()
  * Jeremy Fitzhardinge <jeremy@sw.oz.au>
  */
-/*
- * These are the only things you should do on a core-file: use only these
- * functions to write out all the necessary info.
- */
-static int dump_write(struct file *file, const void *addr, int nr)
-{
-	return file->f_op->write(file, addr, nr, &file->f_pos) == nr;
-}
-
-static int dump_seek(struct file *file, loff_t off)
-{
-	if (file->f_op->llseek && file->f_op->llseek != no_llseek) {
-		if (file->f_op->llseek(file, off, SEEK_CUR) < 0)
-			return 0;
-	} else {
-		char *buf = (char *)get_zeroed_page(GFP_KERNEL);
-		if (!buf)
-			return 0;
-		while (off > 0) {
-			unsigned long n = off;
-			if (n > PAGE_SIZE)
-				n = PAGE_SIZE;
-			if (!dump_write(file, buf, n))
-				return 0;
-			off -= n;
-		}
-		free_page((unsigned long)buf);
-	}
-	return 1;
-}
 
 /*
  * Decide what to dump of a segment, part, all or none.
@@ -1272,11 +1243,6 @@ static int writenote(struct memelfnote *men, struct file *file,
 }
 #undef DUMP_WRITE
 
-#define DUMP_WRITE(addr, nr)				\
-	if ((size += (nr)) > cprm->limit ||		\
-	    !dump_write(cprm->file, (addr), (nr)))	\
-		goto end_coredump;
-
 static void fill_elf_header(struct elfhdr *elf, int segs,
 			    u16 machine, u32 flags, u8 osabi)
 {
@@ -1957,7 +1923,10 @@ static int elf_core_dump(struct coredump_params *cprm)
 	fs = get_fs();
 	set_fs(KERNEL_DS);
 
-	DUMP_WRITE(elf, sizeof(*elf));
+	size += sizeof(*elf);
+	if (size > cprm->limit || !dump_write(cprm->file, elf, sizeof(*elf)))
+		goto end_coredump;
+
 	offset += sizeof(*elf);				/* Elf header */
 	offset += (segs + 1) * sizeof(struct elf_phdr); /* Program headers */
 	foffset = offset;
@@ -1971,7 +1940,11 @@ static int elf_core_dump(struct coredump_params *cprm)
 
 		fill_elf_note_phdr(&phdr, sz, offset);
 		offset += sz;
-		DUMP_WRITE(&phdr, sizeof(phdr));
+
+		size += sizeof(phdr);
+		if (size > cprm->limit
+		    || !dump_write(cprm->file, &phdr, sizeof(phdr)))
+			goto end_coredump;
 	}
 
 	dataoff = offset = roundup(offset, ELF_EXEC_PAGESIZE);
@@ -2002,7 +1975,10 @@ static int elf_core_dump(struct coredump_params *cprm)
 			phdr.p_flags |= PF_X;
 		phdr.p_align = ELF_EXEC_PAGESIZE;
 
-		DUMP_WRITE(&phdr, sizeof(phdr));
+		size += sizeof(phdr);
+		if (size > cprm->limit
+		    || !dump_write(cprm->file, &phdr, sizeof(phdr)))
+			goto end_coredump;
 	}
 
 #ifdef ELF_CORE_WRITE_EXTRA_PHDRS
diff --git a/fs/binfmt_elf_fdpic.c b/fs/binfmt_elf_fdpic.c
index ab9aa76..d928e5f 100644
--- a/fs/binfmt_elf_fdpic.c
+++ b/fs/binfmt_elf_fdpic.c
@@ -34,6 +34,7 @@
 #include <linux/elf.h>
 #include <linux/elf-fdpic.h>
 #include <linux/elfcore.h>
+#include <linux/coredump.h>
 
 #include <asm/uaccess.h>
 #include <asm/param.h>
@@ -1204,37 +1205,6 @@ static int elf_fdpic_map_file_by_direct_mmap(struct elf_fdpic_params *params,
 #ifdef CONFIG_ELF_CORE
 
 /*
- * These are the only things you should do on a core-file: use only these
- * functions to write out all the necessary info.
- */
-static int dump_write(struct file *file, const void *addr, int nr)
-{
-	return file->f_op->write(file, addr, nr, &file->f_pos) == nr;
-}
-
-static int dump_seek(struct file *file, loff_t off)
-{
-	if (file->f_op->llseek && file->f_op->llseek != no_llseek) {
-		if (file->f_op->llseek(file, off, SEEK_CUR) < 0)
-			return 0;
-	} else {
-		char *buf = (char *)get_zeroed_page(GFP_KERNEL);
-		if (!buf)
-			return 0;
-		while (off > 0) {
-			unsigned long n = off;
-			if (n > PAGE_SIZE)
-				n = PAGE_SIZE;
-			if (!dump_write(file, buf, n))
-				return 0;
-			off -= n;
-		}
-		free_page((unsigned long)buf);
-	}
-	return 1;
-}
-
-/*
  * Decide whether a segment is worth dumping; default is yes to be
  * sure (missing info is worse than too much; etc).
  * Personally I'd include everything, and use the coredump limit...
@@ -1342,11 +1312,6 @@ static int writenote(struct memelfnote *men, struct file *file,
 }
 #undef DUMP_WRITE
 
-#define DUMP_WRITE(addr, nr)				\
-	if ((size += (nr)) > cprm->limit ||		\
-	    !dump_write(cprm->file, (addr), (nr)))	\
-		goto end_coredump;
-
 static inline void fill_elf_fdpic_header(struct elfhdr *elf, int segs)
 {
 	memcpy(elf->e_ident, ELFMAG, SELFMAG);
@@ -1731,7 +1696,11 @@ static int elf_fdpic_core_dump(struct coredump_params *cprm)
 	fs = get_fs();
 	set_fs(KERNEL_DS);
 
-	DUMP_WRITE(elf, sizeof(*elf));
+	size += sizeof(*elf);
+	if (size > cprm->limit
+	    || !dump_write(cprm->file, elf, sizeof(*elf)))
+		goto end_coredump;
+
 	offset += sizeof(*elf);				/* Elf header */
 	offset += (segs+1) * sizeof(struct elf_phdr);	/* Program headers */
 	foffset = offset;
@@ -1748,7 +1717,11 @@ static int elf_fdpic_core_dump(struct coredump_params *cprm)
 
 		fill_elf_note_phdr(&phdr, sz, offset);
 		offset += sz;
-		DUMP_WRITE(&phdr, sizeof(phdr));
+
+		size += sizeof(phdr);
+		if (size > cprm->limit
+		    || !dump_write(cprm->file, &phdr, sizeof(phdr)))
+			goto end_coredump;
 	}
 
 	/* Page-align dumped data */
@@ -1782,7 +1755,10 @@ static int elf_fdpic_core_dump(struct coredump_params *cprm)
 			phdr.p_flags |= PF_X;
 		phdr.p_align = ELF_EXEC_PAGESIZE;
 
-		DUMP_WRITE(&phdr, sizeof(phdr));
+		size += sizeof(phdr);
+		if (size > cprm->limit
+		    || !dump_write(cprm->file, &phdr, sizeof(phdr)))
+			goto end_coredump;
 	}
 
 #ifdef ELF_CORE_WRITE_EXTRA_PHDRS
diff --git a/include/linux/coredump.h b/include/linux/coredump.h
new file mode 100644
index 0000000..b3c91d7
--- /dev/null
+++ b/include/linux/coredump.h
@@ -0,0 +1,41 @@
+#ifndef _LINUX_COREDUMP_H
+#define _LINUX_COREDUMP_H
+
+#include <linux/types.h>
+#include <linux/mm.h>
+#include <linux/fs.h>
+
+/*
+ * These are the only things you should do on a core-file: use only these
+ * functions to write out all the necessary info.
+ */
+static inline int dump_write(struct file *file, const void *addr, int nr)
+{
+	return file->f_op->write(file, addr, nr, &file->f_pos) == nr;
+}
+
+static inline int dump_seek(struct file *file, loff_t off)
+{
+	if (file->f_op->llseek && file->f_op->llseek != no_llseek) {
+		if (file->f_op->llseek(file, off, SEEK_CUR) < 0)
+			return 0;
+	} else {
+		char *buf = (char *)get_zeroed_page(GFP_KERNEL);
+
+		if (!buf)
+			return 0;
+		while (off > 0) {
+			unsigned long n = off;
+
+			if (n > PAGE_SIZE)
+				n = PAGE_SIZE;
+			if (!dump_write(file, buf, n))
+				return 0;
+			off -= n;
+		}
+		free_page((unsigned long)buf);
+	}
+	return 1;
+}
+
+#endif /* _LINUX_COREDUMP_H */
-- 
1.6.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
