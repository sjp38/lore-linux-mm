Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5ECF96B003D
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 19:33:53 -0500 (EST)
Date: Thu, 7 Jan 2010 16:32:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND][mmotm][PATCH v2, 0/5] elf coredump: Add extended
 numbering support
Message-Id: <20100107163259.86165aee.akpm@linux-foundation.org>
In-Reply-To: <20100107162928.1d6eba76.akpm@linux-foundation.org>
References: <20100104.100607.189714443.d.hatayama@jp.fujitsu.com>
	<20100107162928.1d6eba76.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke HATAYAMA <d.hatayama@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhiramat@redhat.com, xiyou.wangcong@gmail.com, andi@firstfloor.org, jdike@addtoit.com, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jan 2010 16:29:28 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 04 Jan 2010 10:06:07 +0900 (JST)
> Daisuke HATAYAMA <d.hatayama@jp.fujitsu.com> wrote:
> 
> > The current ELF dumper can produce broken corefiles if program headers
> > exceed 65535. In particular, the program in 64-bit environment often
> > demands more than 65535 mmaps. If you google max_map_count, then you
> > can find many users facing this problem.
> > 
> > Solaris has already dealt with this issue, and other OSes have also
> > adopted the same method as in Solaris. Currently, Sun's document and
> > AMD 64 ABI include the description for the extension, where they call
> > the extension Extended Numbering. See Reference for further information.
> > 
> > I believe that linux kernel should adopt the same way as they did, so
> > I've written this patch.
> > 
> > I am also preparing for patches of GDB and binutils.
> 
> That's a beautifully presented patchset.  Thanks for doing all that
> work - it helps.
> 
> UML maintenance appears to have ceased in recent times, so if we wish
> to have these changes runtime tested (we should) then I think it would
> be best if you could find someone to do that please.
> 
> And no akpm code-review would be complete without: dump_seek() is
> waaaay to large to be inlined.  Is there some common .c file to where
> we could move it?
> 

Also, these patches made a bit of a mess of
mm-pass-mm-flags-as-a-coredump-parameter-for-consistency.patch.

I consider
mm-pass-mm-flags-as-a-coredump-parameter-for-consistency.patch to be
less important (although older) than this patch series so I've fixed up
mm-pass-mm-flags-as-a-coredump-parameter-for-consistency.patch and have
staged it after your patch series.  If this causes problems then I'll
drop mm-pass-mm-flags-as-a-coredump-parameter-for-consistency.patch,
sorry.


From: Masami Hiramatsu <mhiramat@redhat.com>

Pass mm->flags as a coredump parameter for consistency.

 ---
1787         if (mm->core_state || !get_dumpable(mm)) {  <- (1)
1788                 up_write(&mm->mmap_sem);
1789                 put_cred(cred);
1790                 goto fail;
1791         }
1792
[...]
1798         if (get_dumpable(mm) == 2) {    /* Setuid core dump mode */ <-(2)
1799                 flag = O_EXCL;          /* Stop rewrite attacks */
1800                 cred->fsuid = 0;        /* Dump root private */
1801         }
 ---

Since dumpable bits are not protected by lock, there is a chance to change
these bits between (1) and (2).

To solve this issue, this patch copies mm->flags to
coredump_params.mm_flags at the beginning of do_coredump() and uses it
instead of get_dumpable() while dumping core.

This copy is also passed to binfmt->core_dump, since elf*_core_dump() uses
dump_filter bits in mm->flags.

Signed-off-by: Masami Hiramatsu <mhiramat@redhat.com>
Acked-by: Roland McGrath <roland@redhat.com>
Cc: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/binfmt_elf.c         |   12 ++----------
 fs/binfmt_elf_fdpic.c   |   12 ++----------
 fs/exec.c               |   20 ++++++++++++++++----
 include/linux/binfmts.h |    1 +
 4 files changed, 21 insertions(+), 24 deletions(-)

diff -puN fs/binfmt_elf.c~mm-pass-mm-flags-as-a-coredump-parameter-for-consistency fs/binfmt_elf.c
--- a/fs/binfmt_elf.c~mm-pass-mm-flags-as-a-coredump-parameter-for-consistency
+++ a/fs/binfmt_elf.c
@@ -1905,7 +1905,6 @@ static int elf_core_dump(struct coredump
 	struct vm_area_struct *vma, *gate_vma;
 	struct elfhdr *elf = NULL;
 	loff_t offset = 0, dataoff, foffset;
-	unsigned long mm_flags;
 	struct elf_note_info info;
 	struct elf_phdr *phdr4note = NULL;
 	struct elf_shdr *shdr4extnum = NULL;
@@ -1980,13 +1979,6 @@ static int elf_core_dump(struct coredump
 
 	dataoff = offset = roundup(offset, ELF_EXEC_PAGESIZE);
 
-	/*
-	 * We must use the same mm->flags while dumping core to avoid
-	 * inconsistency between the program headers and bodies, otherwise an
-	 * unusable core file can be generated.
-	 */
-	mm_flags = current->mm->flags;
-
 	offset += elf_core_vma_data_size(gate_vma, mm_flags);
 	offset += elf_core_extra_data_size();
 	e_shoff = offset;
@@ -2018,7 +2010,7 @@ static int elf_core_dump(struct coredump
 		phdr.p_offset = offset;
 		phdr.p_vaddr = vma->vm_start;
 		phdr.p_paddr = 0;
-		phdr.p_filesz = vma_dump_size(vma, mm_flags);
+		phdr.p_filesz = vma_dump_size(vma, cprm->mm_flags);
 		phdr.p_memsz = vma->vm_end - vma->vm_start;
 		offset += phdr.p_filesz;
 		phdr.p_flags = vma->vm_flags & VM_READ ? PF_R : 0;
@@ -2053,7 +2045,7 @@ static int elf_core_dump(struct coredump
 		unsigned long addr;
 		unsigned long end;
 
-		end = vma->vm_start + vma_dump_size(vma, mm_flags);
+		end = vma->vm_start + vma_dump_size(vma, cprm->mm_flags);
 
 		for (addr = vma->vm_start; addr < end; addr += PAGE_SIZE) {
 			struct page *page;
diff -puN fs/binfmt_elf_fdpic.c~mm-pass-mm-flags-as-a-coredump-parameter-for-consistency fs/binfmt_elf_fdpic.c
--- a/fs/binfmt_elf_fdpic.c~mm-pass-mm-flags-as-a-coredump-parameter-for-consistency
+++ a/fs/binfmt_elf_fdpic.c
@@ -1623,7 +1623,6 @@ static int elf_fdpic_core_dump(struct co
 #endif
 	int thread_status_size = 0;
 	elf_addr_t *auxv;
-	unsigned long mm_flags;
 	struct elf_phdr *phdr4note = NULL;
 	struct elf_shdr *shdr4extnum = NULL;
 	Elf_Half e_phnum;
@@ -1766,13 +1765,6 @@ static int elf_fdpic_core_dump(struct co
 	/* Page-align dumped data */
 	dataoff = offset = roundup(offset, ELF_EXEC_PAGESIZE);
 
-	/*
-	 * We must use the same mm->flags while dumping core to avoid
-	 * inconsistency between the program headers and bodies, otherwise an
-	 * unusable core file can be generated.
-	 */
-	mm_flags = current->mm->flags;
-
 	offset += elf_core_vma_data_size(mm_flags);
 	offset += elf_core_extra_data_size();
 	e_shoff = offset;
@@ -1806,7 +1798,7 @@ static int elf_fdpic_core_dump(struct co
 		phdr.p_offset = offset;
 		phdr.p_vaddr = vma->vm_start;
 		phdr.p_paddr = 0;
-		phdr.p_filesz = maydump(vma, mm_flags) ? sz : 0;
+		phdr.p_filesz = maydump(vma, cprm->mm_flags) ? sz : 0;
 		phdr.p_memsz = sz;
 		offset += phdr.p_filesz;
 		phdr.p_flags = vma->vm_flags & VM_READ ? PF_R : 0;
@@ -1844,7 +1836,7 @@ static int elf_fdpic_core_dump(struct co
 		goto end_coredump;
 
 	if (elf_fdpic_dump_segments(cprm->file, &size, &cprm->limit,
-				    mm_flags) < 0)
+				    cprm->mm_flags) < 0)
 		goto end_coredump;
 
 	if (!elf_core_write_extra_data(cprm->file, &size, cprm->limit))
diff -puN fs/exec.c~mm-pass-mm-flags-as-a-coredump-parameter-for-consistency fs/exec.c
--- a/fs/exec.c~mm-pass-mm-flags-as-a-coredump-parameter-for-consistency
+++ a/fs/exec.c
@@ -1726,14 +1726,19 @@ void set_dumpable(struct mm_struct *mm, 
 	}
 }
 
-int get_dumpable(struct mm_struct *mm)
+static int __get_dumpable(unsigned long mm_flags)
 {
 	int ret;
 
-	ret = mm->flags & 0x3;
+	ret = mm_flags & MMF_DUMPABLE_MASK;
 	return (ret >= 2) ? 2 : ret;
 }
 
+int get_dumpable(struct mm_struct *mm)
+{
+	return __get_dumpable(mm->flags);
+}
+
 static void wait_for_dump_helpers(struct file *file)
 {
 	struct pipe_inode_info *pipe;
@@ -1777,6 +1782,12 @@ void do_coredump(long signr, int exit_co
 		.signr = signr,
 		.regs = regs,
 		.limit = current->signal->rlim[RLIMIT_CORE].rlim_cur,
+		/*
+		 * We must use the same mm->flags while dumping core to avoid
+		 * inconsistency of bit flags, since this flag is not protected
+		 * by any locks.
+		 */
+		.mm_flags = mm->flags,
 	};
 
 	audit_core_dumps(signr);
@@ -1795,7 +1806,7 @@ void do_coredump(long signr, int exit_co
 	/*
 	 * If another thread got here first, or we are not dumpable, bail out.
 	 */
-	if (mm->core_state || !get_dumpable(mm)) {
+	if (mm->core_state || !__get_dumpable(cprm.mm_flags)) {
 		up_write(&mm->mmap_sem);
 		put_cred(cred);
 		goto fail;
@@ -1806,7 +1817,8 @@ void do_coredump(long signr, int exit_co
 	 *	process nor do we know its entire history. We only know it
 	 *	was tainted so we dump it as root in mode 2.
 	 */
-	if (get_dumpable(mm) == 2) {	/* Setuid core dump mode */
+	if (__get_dumpable(cprm.mm_flags) == 2) {
+		/* Setuid core dump mode */
 		flag = O_EXCL;		/* Stop rewrite attacks */
 		cred->fsuid = 0;	/* Dump root private */
 	}
diff -puN include/linux/binfmts.h~mm-pass-mm-flags-as-a-coredump-parameter-for-consistency include/linux/binfmts.h
--- a/include/linux/binfmts.h~mm-pass-mm-flags-as-a-coredump-parameter-for-consistency
+++ a/include/linux/binfmts.h
@@ -74,6 +74,7 @@ struct coredump_params {
 	struct pt_regs *regs;
 	struct file *file;
 	unsigned long limit;
+	unsigned long mm_flags;
 };
 
 /*
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
