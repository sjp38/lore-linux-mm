Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3FF2E600068
	for <linux-mm@kvack.org>; Sun,  3 Jan 2010 20:20:23 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o041KJvT027624
	for <linux-mm@kvack.org> (envelope-from d.hatayama@jp.fujitsu.com);
	Mon, 4 Jan 2010 10:20:19 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4302A45DE55
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 10:20:19 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 14B1645DE4C
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 10:20:19 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id CFBF8E18001
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 10:20:18 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 74F841DB803C
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 10:20:18 +0900 (JST)
Date: Mon, 04 Jan 2010 10:20:17 +0900 (JST)
Message-Id: <20100104.102017.112621741.d.hatayama@jp.fujitsu.com>
Subject: [RESEND][mmotm][PATCH v2, 1/5] Unify dump_seek() implementations
 for each binfmt_*.c
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

There are three different definitions for dump_seek() functions in
binfmt_aout.c, binfmt_elf.c and binfmt_elf_fdpic.c, respectively.  The
difference comes from the fact that a lot of patches has been applied
only for binfmt_elf.c.

My next patch will move dump_seek() into a header file in order to
share the same implementations for dump_write() and dump_seek(). As
the first step, this patch unify these three definitions for
dump_seek() by applying the past commits that have been applied only
for binfmt_elf.c.

Specifically, the modification made here is part of the following
commits:

  * d025c9db7f31fc0554ce7fb2dfc78d35a77f3487
  * 7f14daa19ea36b200d237ad3ac5826ae25360461

This patch does not change a shape of corefiles.

Signed-off-by: Daisuke HATAYAMA <d.hatayama@jp.fujitsu.com>
---
 fs/binfmt_aout.c      |   31 ++++++++++++++++++++-----
 fs/binfmt_elf_fdpic.c |   59 +++++++++++++++++++++++++++++++-----------------
 2 files changed, 62 insertions(+), 28 deletions(-)

diff --git a/fs/binfmt_aout.c b/fs/binfmt_aout.c
index 3bd288c..10717fb 100644
--- a/fs/binfmt_aout.c
+++ b/fs/binfmt_aout.c
@@ -69,16 +69,32 @@ static int dump_write(struct file *file, const void *addr, int nr)
 	return file->f_op->write(file, addr, nr, &file->f_pos) == nr;
 }
 
+static int dump_seek(struct file *file, loff_t off)
+{
+	if (file->f_op->llseek && file->f_op->llseek != no_llseek) {
+		if (file->f_op->llseek(file, off, SEEK_CUR) < 0)
+			return 0;
+	} else {
+		char *buf = (char *)get_zeroed_page(GFP_KERNEL);
+		if (!buf)
+			return 0;
+		while (off > 0) {
+			unsigned long n = off;
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
 #define DUMP_WRITE(addr, nr)	\
 	if (!dump_write(file, (void *)(addr), (nr))) \
 		goto end_coredump;
 
-#define DUMP_SEEK(offset) \
-if (file->f_op->llseek) { \
-	if (file->f_op->llseek(file,(offset),0) != (offset)) \
- 		goto end_coredump; \
-} else file->f_pos = (offset)
-
 /*
  * Routine writes a core dump image in the current directory.
  * Currently only a stub-function.
@@ -132,7 +148,8 @@ static int aout_core_dump(struct coredump_params *cprm)
 /* struct user */
 	DUMP_WRITE(&dump,sizeof(dump));
 /* Now dump all of the user data.  Include malloced stuff as well */
-	DUMP_SEEK(PAGE_SIZE);
+	if (!dump_seek(cprm->file, PAGE_SIZE - sizeof(dump)))
+		goto end_coredump;
 /* now we start writing out the user space info */
 	set_fs(USER_DS);
 /* Dump the data area */
diff --git a/fs/binfmt_elf_fdpic.c b/fs/binfmt_elf_fdpic.c
index c25256a..ab9aa76 100644
--- a/fs/binfmt_elf_fdpic.c
+++ b/fs/binfmt_elf_fdpic.c
@@ -1214,11 +1214,22 @@ static int dump_write(struct file *file, const void *addr, int nr)
 
 static int dump_seek(struct file *file, loff_t off)
 {
-	if (file->f_op->llseek) {
-		if (file->f_op->llseek(file, off, SEEK_SET) != off)
+	if (file->f_op->llseek && file->f_op->llseek != no_llseek) {
+		if (file->f_op->llseek(file, off, SEEK_CUR) < 0)
 			return 0;
 	} else {
-		file->f_pos = off;
+		char *buf = (char *)get_zeroed_page(GFP_KERNEL);
+		if (!buf)
+			return 0;
+		while (off > 0) {
+			unsigned long n = off;
+			if (n > PAGE_SIZE)
+				n = PAGE_SIZE;
+			if (!dump_write(file, buf, n))
+				return 0;
+			off -= n;
+		}
+		free_page((unsigned long)buf);
 	}
 	return 1;
 }
@@ -1301,30 +1312,35 @@ static int notesize(struct memelfnote *en)
 
 /* #define DEBUG */
 
-#define DUMP_WRITE(addr, nr)	\
-	do { if (!dump_write(file, (addr), (nr))) return 0; } while(0)
-#define DUMP_SEEK(off)	\
-	do { if (!dump_seek(file, (off))) return 0; } while(0)
+#define DUMP_WRITE(addr, nr, foffset)	\
+	do { if (!dump_write(file, (addr), (nr))) return 0; *foffset += (nr); } while(0)
 
-static int writenote(struct memelfnote *men, struct file *file)
+static int alignfile(struct file *file, loff_t *foffset)
 {
-	struct elf_note en;
+	static const char buf[4] = { 0, };
+	DUMP_WRITE(buf, roundup(*foffset, 4) - *foffset, foffset);
+	return 1;
+}
 
+static int writenote(struct memelfnote *men, struct file *file,
+			loff_t *foffset)
+{
+	struct elf_note en;
 	en.n_namesz = strlen(men->name) + 1;
 	en.n_descsz = men->datasz;
 	en.n_type = men->type;
 
-	DUMP_WRITE(&en, sizeof(en));
-	DUMP_WRITE(men->name, en.n_namesz);
-	/* XXX - cast from long long to long to avoid need for libgcc.a */
-	DUMP_SEEK(roundup((unsigned long)file->f_pos, 4));	/* XXX */
-	DUMP_WRITE(men->data, men->datasz);
-	DUMP_SEEK(roundup((unsigned long)file->f_pos, 4));	/* XXX */
+	DUMP_WRITE(&en, sizeof(en), foffset);
+	DUMP_WRITE(men->name, en.n_namesz, foffset);
+	if (!alignfile(file, foffset))
+		return 0;
+	DUMP_WRITE(men->data, men->datasz, foffset);
+	if (!alignfile(file, foffset))
+		return 0;
 
 	return 1;
 }
 #undef DUMP_WRITE
-#undef DUMP_SEEK
 
 #define DUMP_WRITE(addr, nr)				\
 	if ((size += (nr)) > cprm->limit ||		\
@@ -1540,7 +1556,7 @@ static int elf_fdpic_dump_segments(struct file *file, size_t *size,
 					err = -EIO;
 				kunmap(page);
 				page_cache_release(page);
-			} else if (!dump_seek(file, file->f_pos + PAGE_SIZE))
+			} else if (!dump_seek(file, PAGE_SIZE))
 				err = -EFBIG;
 			if (err)
 				goto out;
@@ -1593,7 +1609,7 @@ static int elf_fdpic_core_dump(struct coredump_params *cprm)
 	int i;
 	struct vm_area_struct *vma;
 	struct elfhdr *elf = NULL;
-	loff_t offset = 0, dataoff;
+	loff_t offset = 0, dataoff, foffset;
 	int numnote;
 	struct memelfnote *notes = NULL;
 	struct elf_prstatus *prstatus = NULL;	/* NT_PRSTATUS */
@@ -1718,6 +1734,7 @@ static int elf_fdpic_core_dump(struct coredump_params *cprm)
 	DUMP_WRITE(elf, sizeof(*elf));
 	offset += sizeof(*elf);				/* Elf header */
 	offset += (segs+1) * sizeof(struct elf_phdr);	/* Program headers */
+	foffset = offset;
 
 	/* Write notes phdr entry */
 	{
@@ -1774,7 +1791,7 @@ static int elf_fdpic_core_dump(struct coredump_params *cprm)
 
  	/* write out the notes section */
 	for (i = 0; i < numnote; i++)
-		if (!writenote(notes + i, cprm->file))
+		if (!writenote(notes + i, cprm->file, &foffset))
 			goto end_coredump;
 
 	/* write out the thread status notes section */
@@ -1783,11 +1800,11 @@ static int elf_fdpic_core_dump(struct coredump_params *cprm)
 				list_entry(t, struct elf_thread_status, list);
 
 		for (i = 0; i < tmp->num_notes; i++)
-			if (!writenote(&tmp->notes[i], cprm->file))
+			if (!writenote(&tmp->notes[i], cprm->file, &foffset))
 				goto end_coredump;
 	}
 
-	if (!dump_seek(cprm->file, dataoff))
+	if (!dump_seek(cprm->file, dataoff - foffset))
 		goto end_coredump;
 
 	if (elf_fdpic_dump_segments(cprm->file, &size, &cprm->limit,
-- 
1.6.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
