Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8BB94600068
	for <linux-mm@kvack.org>; Sun,  3 Jan 2010 20:20:46 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o041KeCJ014291
	for <linux-mm@kvack.org> (envelope-from d.hatayama@jp.fujitsu.com);
	Mon, 4 Jan 2010 10:20:40 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 25B092AEA90
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 10:20:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DD1B745DE4F
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 10:20:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B5BBC1DB8042
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 10:20:39 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 548631DB803E
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 10:20:39 +0900 (JST)
Date: Mon, 04 Jan 2010 10:20:38 +0900 (JST)
Message-Id: <20100104.102038.59657110.d.hatayama@jp.fujitsu.com>
Subject: [RESEND][mmotm][PATCH v2, 4/5] elf coredump: make offset
 calculation process and writing process explicit
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

By the next patch, elf_core_dump() and elf_fdpic_core_dump() will
support extended numbering and so will produce the corefiles with
section header table in a special case.

The problem is the process of writing a file header offset of the
section header table into e_shoff field of the ELF header. ELF header
is positioned at the beginning of the corefile, while section header
at the end. So, we need to take which of the following ways:

 1. Seek backward to retry writing operation for ELF header
    after writing process for a whole part

 2. Make offset calculation process and writing process
    totally sequential

The clause 1. is not always possible: one cannot assume that file
system supports seek function. Consider the no_llseek case.

Therefore, this patch adopts the clause 2.

Signed-off-by: Daisuke HATAYAMA <d.hatayama@jp.fujitsu.com>
---
 fs/binfmt_elf.c       |   27 ++++++++++++++++-----------
 fs/binfmt_elf_fdpic.c |   29 ++++++++++++++++-------------
 2 files changed, 32 insertions(+), 24 deletions(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 1b7e9de..b1ded32 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -1879,6 +1879,7 @@ static int elf_core_dump(struct coredump_params *cprm)
 	loff_t offset = 0, dataoff, foffset;
 	unsigned long mm_flags;
 	struct elf_note_info info;
+	struct elf_phdr *phdr4note = NULL;
 
 	/*
 	 * We no longer stop all VM operations.
@@ -1921,28 +1922,22 @@ static int elf_core_dump(struct coredump_params *cprm)
 	fs = get_fs();
 	set_fs(KERNEL_DS);
 
-	size += sizeof(*elf);
-	if (size > cprm->limit || !dump_write(cprm->file, elf, sizeof(*elf)))
-		goto end_coredump;
-
 	offset += sizeof(*elf);				/* Elf header */
 	offset += (segs + 1) * sizeof(struct elf_phdr); /* Program headers */
 	foffset = offset;
 
 	/* Write notes phdr entry */
 	{
-		struct elf_phdr phdr;
 		size_t sz = get_note_info_size(&info);
 
 		sz += elf_coredump_extra_notes_size();
 
-		fill_elf_note_phdr(&phdr, sz, offset);
-		offset += sz;
-
-		size += sizeof(phdr);
-		if (size > cprm->limit
-		    || !dump_write(cprm->file, &phdr, sizeof(phdr)))
+		phdr4note = kmalloc(sizeof(*phdr4note), GFP_KERNEL);
+		if (!phdr4note)
 			goto end_coredump;
+
+		fill_elf_note_phdr(phdr4note, sz, offset);
+		offset += sz;
 	}
 
 	dataoff = offset = roundup(offset, ELF_EXEC_PAGESIZE);
@@ -1954,6 +1949,15 @@ static int elf_core_dump(struct coredump_params *cprm)
 	 */
 	mm_flags = current->mm->flags;
 
+	size += sizeof(*elf);
+	if (size > cprm->limit || !dump_write(cprm->file, elf, sizeof(*elf)))
+		goto end_coredump;
+
+	size += sizeof(*phdr4note);
+	if (size > cprm->limit
+	    || !dump_write(cprm->file, phdr4note, sizeof(*phdr4note)))
+		goto end_coredump;
+
 	/* Write program headers for segments dump */
 	for (vma = first_vma(current, gate_vma); vma != NULL;
 			vma = next_vma(vma, gate_vma)) {
@@ -2027,6 +2031,7 @@ end_coredump:
 
 cleanup:
 	free_note_info(&info);
+	kfree(phdr4note);
 	kfree(elf);
 out:
 	return has_dumped;
diff --git a/fs/binfmt_elf_fdpic.c b/fs/binfmt_elf_fdpic.c
index 4c16ff6..cbfa34e 100644
--- a/fs/binfmt_elf_fdpic.c
+++ b/fs/binfmt_elf_fdpic.c
@@ -1588,6 +1588,7 @@ static int elf_fdpic_core_dump(struct coredump_params *cprm)
 	int thread_status_size = 0;
 	elf_addr_t *auxv;
 	unsigned long mm_flags;
+	struct elf_phdr *phdr4note = NULL;
 
 	/*
 	 * We no longer stop all VM operations.
@@ -1694,18 +1695,12 @@ static int elf_fdpic_core_dump(struct coredump_params *cprm)
 	fs = get_fs();
 	set_fs(KERNEL_DS);
 
-	size += sizeof(*elf);
-	if (size > cprm->limit
-	    || !dump_write(cprm->file, elf, sizeof(*elf)))
-		goto end_coredump;
-
 	offset += sizeof(*elf);				/* Elf header */
 	offset += (segs+1) * sizeof(struct elf_phdr);	/* Program headers */
 	foffset = offset;
 
 	/* Write notes phdr entry */
 	{
-		struct elf_phdr phdr;
 		int sz = 0;
 
 		for (i = 0; i < numnote; i++)
@@ -1713,13 +1708,12 @@ static int elf_fdpic_core_dump(struct coredump_params *cprm)
 
 		sz += thread_status_size;
 
-		fill_elf_note_phdr(&phdr, sz, offset);
-		offset += sz;
-
-		size += sizeof(phdr);
-		if (size > cprm->limit
-		    || !dump_write(cprm->file, &phdr, sizeof(phdr)))
+		phdr4note = kmalloc(sizeof(*phdr4note), GFP_KERNEL);
+		if (!phdr4note)
 			goto end_coredump;
+
+		fill_elf_note_phdr(phdr4note, sz, offset);
+		offset += sz;
 	}
 
 	/* Page-align dumped data */
@@ -1732,6 +1726,15 @@ static int elf_fdpic_core_dump(struct coredump_params *cprm)
 	 */
 	mm_flags = current->mm->flags;
 
+	size += sizeof(*elf);
+	if (size > cprm->limit || !dump_write(cprm->file, elf, sizeof(*elf)))
+		goto end_coredump;
+
+	size += sizeof(*phdr4note);
+	if (size > cprm->limit
+	    || !dump_write(cprm->file, phdr4note, sizeof(*phdr4note)))
+		goto end_coredump;
+
 	/* write program headers for segments dump */
 	for (vma = current->mm->mmap; vma; vma = vma->vm_next) {
 		struct elf_phdr phdr;
@@ -1803,7 +1806,7 @@ cleanup:
 		list_del(tmp);
 		kfree(list_entry(tmp, struct elf_thread_status, list));
 	}
-
+	kfree(phdr4note);
 	kfree(elf);
 	kfree(prstatus);
 	kfree(psinfo);
-- 
1.6.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
