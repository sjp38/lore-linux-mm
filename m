Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0E1D78D0040
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 12:12:09 -0500 (EST)
Date: Wed, 2 Mar 2011 17:27:53 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH v3 3/4] exec: unify do_execve/compat_do_execve code
Message-ID: <20110302162753.GD26810@redhat.com>
References: <20101201182747.GB6143@redhat.com> <20110225175202.GA19059@redhat.com> <20110225175314.GD19059@redhat.com> <AANLkTik8epq5cx8n=k6ocMUfbg9kkUAZ8KL7ZiG4UuoU@mail.gmail.com> <20110226123731.GC4416@redhat.com> <AANLkTinFVCR_znYtyVuJcjFQq_fgMp+ozbSz54UKzvQ_@mail.gmail.com> <20110226174408.GA17442@redhat.com> <20110301204739.GA30406@redhat.com> <AANLkTikVecxcGoZ9a4hmkoi4wynrNfH9_AU7Vb+hOvbH@mail.gmail.com> <20110302162650.GA26810@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110302162650.GA26810@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>

Add the appropriate members into struct conditional_ptr and teach
get_arg_ptr() to handle is_compat = T case correctly.

This allows us to remove the compat_do_execve() code from fs/compat.c
and reimplement compat_do_execve() as the trivial wrapper on top of
do_execve_common(is_compat => true).

In fact, this fixes another (minor) bug. "compat_uptr_t str" can
overflow after "str += len" in compat_copy_strings() if a 64bit
application execs via sys32_execve().

Unexport acct_arg_size() and get_arg_page(), fs/compat.c doesn't
need them any longer.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---

 include/linux/binfmts.h |    4 
 fs/exec.c               |   58 +++++++++--
 fs/compat.c             |  235 ------------------------------------------------
 3 files changed, 46 insertions(+), 251 deletions(-)

--- 38/include/linux/binfmts.h~3_handle_compat_case	2011-03-02 15:15:25.000000000 +0100
+++ 38/include/linux/binfmts.h	2011-03-02 15:47:15.000000000 +0100
@@ -60,10 +60,6 @@ struct linux_binprm {
 	unsigned long loader, exec;
 };
 
-extern void acct_arg_size(struct linux_binprm *bprm, unsigned long pages);
-extern struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
-					int write);
-
 #define BINPRM_FLAGS_ENFORCE_NONDUMP_BIT 0
 #define BINPRM_FLAGS_ENFORCE_NONDUMP (1 << BINPRM_FLAGS_ENFORCE_NONDUMP_BIT)
 
--- 38/fs/exec.c~3_handle_compat_case	2011-03-02 15:40:44.000000000 +0100
+++ 38/fs/exec.c	2011-03-02 16:21:57.000000000 +0100
@@ -55,6 +55,7 @@
 #include <linux/fs_struct.h>
 #include <linux/pipe_fs_i.h>
 #include <linux/oom.h>
+#include <linux/compat.h>
 
 #include <asm/uaccess.h>
 #include <asm/mmu_context.h>
@@ -164,7 +165,7 @@ out:
 
 #ifdef CONFIG_MMU
 
-void acct_arg_size(struct linux_binprm *bprm, unsigned long pages)
+static void acct_arg_size(struct linux_binprm *bprm, unsigned long pages)
 {
 	struct mm_struct *mm = current->mm;
 	long diff = (long)(pages - bprm->vma_pages);
@@ -183,7 +184,7 @@ void acct_arg_size(struct linux_binprm *
 #endif
 }
 
-struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
+static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
 		int write)
 {
 	struct page *page;
@@ -302,11 +303,11 @@ static bool valid_arg_len(struct linux_b
 
 #else
 
-void acct_arg_size(struct linux_binprm *bprm, unsigned long pages)
+static inline void acct_arg_size(struct linux_binprm *bprm, unsigned long pages)
 {
 }
 
-struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
+static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
 		int write)
 {
 	struct page *page;
@@ -396,17 +397,34 @@ err:
 }
 
 struct conditional_ptr {
-	const char __user *const __user *native;
+#ifdef CONFIG_COMPAT
+	bool is_compat;
+#endif
+	union {
+		const char __user *const __user *native;
+		compat_uptr_t __user *compat;
+	} ptr;
 };
 
 static const char __user *get_arg_ptr(struct conditional_ptr argv, int argc)
 {
-	const char __user *ptr;
+	const char __user *native;
 
-	if (get_user(ptr, argv.native + argc))
+#ifdef CONFIG_COMPAT
+	if (unlikely(argv.is_compat)) {
+		compat_uptr_t compat;
+
+		if (get_user(compat, argv.ptr.compat + argc))
+			return ERR_PTR(-EFAULT);
+
+		return compat_ptr(compat);
+	}
+#endif
+
+	if (get_user(native, argv.ptr.native + argc))
 		return ERR_PTR(-EFAULT);
 
-	return ptr;
+	return native;
 }
 
 /*
@@ -416,7 +434,7 @@ static int count(struct conditional_ptr 
 {
 	int i = 0;
 
-	if (argv.native != NULL) {
+	if (argv.ptr.native != NULL) {
 		for (;;) {
 			const char __user *p = get_arg_ptr(argv, i);
 
@@ -539,7 +557,7 @@ int copy_strings_kernel(int argc, const 
 	int r;
 	mm_segment_t oldfs = get_fs();
 	struct conditional_ptr argv = {
-		.native = (const char __user *const  __user *)__argv,
+		.ptr.native = (const char __user *const  __user *)__argv,
 	};
 
 	set_fs(KERNEL_DS);
@@ -1510,11 +1528,27 @@ int do_execve(const char *filename,
 	const char __user *const __user *__envp,
 	struct pt_regs *regs)
 {
-	struct conditional_ptr argv = { .native = __argv };
-	struct conditional_ptr envp = { .native = __envp };
+	struct conditional_ptr argv = { .ptr.native = __argv };
+	struct conditional_ptr envp = { .ptr.native = __envp };
 	return do_execve_common(filename, argv, envp, regs);
 }
 
+#ifdef CONFIG_COMPAT
+int compat_do_execve(char *filename,
+	compat_uptr_t __user *__argv,
+	compat_uptr_t __user *__envp,
+	struct pt_regs *regs)
+{
+	struct conditional_ptr argv = {
+		.is_compat = true, .ptr.compat = __argv,
+	};
+	struct conditional_ptr envp = {
+		.is_compat = true, .ptr.compat = __envp,
+	};
+	return do_execve_common(filename, argv, envp, regs);
+}
+#endif
+
 void set_binfmt(struct linux_binfmt *new)
 {
 	struct mm_struct *mm = current->mm;
--- 38/fs/compat.c~3_handle_compat_case	2011-03-02 15:15:25.000000000 +0100
+++ 38/fs/compat.c	2011-03-02 15:47:15.000000000 +0100
@@ -1330,241 +1330,6 @@ compat_sys_openat(unsigned int dfd, cons
 	return do_sys_open(dfd, filename, flags, mode);
 }
 
-/*
- * compat_count() counts the number of arguments/envelopes. It is basically
- * a copy of count() from fs/exec.c, except that it works with 32 bit argv
- * and envp pointers.
- */
-static int compat_count(compat_uptr_t __user *argv, int max)
-{
-	int i = 0;
-
-	if (argv != NULL) {
-		for (;;) {
-			compat_uptr_t p;
-
-			if (get_user(p, argv))
-				return -EFAULT;
-			if (!p)
-				break;
-			argv++;
-			if (i++ >= max)
-				return -E2BIG;
-
-			if (fatal_signal_pending(current))
-				return -ERESTARTNOHAND;
-			cond_resched();
-		}
-	}
-	return i;
-}
-
-/*
- * compat_copy_strings() is basically a copy of copy_strings() from fs/exec.c
- * except that it works with 32 bit argv and envp pointers.
- */
-static int compat_copy_strings(int argc, compat_uptr_t __user *argv,
-				struct linux_binprm *bprm)
-{
-	struct page *kmapped_page = NULL;
-	char *kaddr = NULL;
-	unsigned long kpos = 0;
-	int ret;
-
-	while (argc-- > 0) {
-		compat_uptr_t str;
-		int len;
-		unsigned long pos;
-
-		if (get_user(str, argv+argc) ||
-		    !(len = strnlen_user(compat_ptr(str), MAX_ARG_STRLEN))) {
-			ret = -EFAULT;
-			goto out;
-		}
-
-		if (len > MAX_ARG_STRLEN) {
-			ret = -E2BIG;
-			goto out;
-		}
-
-		/* We're going to work our way backwords. */
-		pos = bprm->p;
-		str += len;
-		bprm->p -= len;
-
-		while (len > 0) {
-			int offset, bytes_to_copy;
-
-			if (fatal_signal_pending(current)) {
-				ret = -ERESTARTNOHAND;
-				goto out;
-			}
-			cond_resched();
-
-			offset = pos % PAGE_SIZE;
-			if (offset == 0)
-				offset = PAGE_SIZE;
-
-			bytes_to_copy = offset;
-			if (bytes_to_copy > len)
-				bytes_to_copy = len;
-
-			offset -= bytes_to_copy;
-			pos -= bytes_to_copy;
-			str -= bytes_to_copy;
-			len -= bytes_to_copy;
-
-			if (!kmapped_page || kpos != (pos & PAGE_MASK)) {
-				struct page *page;
-
-				page = get_arg_page(bprm, pos, 1);
-				if (!page) {
-					ret = -E2BIG;
-					goto out;
-				}
-
-				if (kmapped_page) {
-					flush_kernel_dcache_page(kmapped_page);
-					kunmap(kmapped_page);
-					put_page(kmapped_page);
-				}
-				kmapped_page = page;
-				kaddr = kmap(kmapped_page);
-				kpos = pos & PAGE_MASK;
-				flush_cache_page(bprm->vma, kpos,
-						 page_to_pfn(kmapped_page));
-			}
-			if (copy_from_user(kaddr+offset, compat_ptr(str),
-						bytes_to_copy)) {
-				ret = -EFAULT;
-				goto out;
-			}
-		}
-	}
-	ret = 0;
-out:
-	if (kmapped_page) {
-		flush_kernel_dcache_page(kmapped_page);
-		kunmap(kmapped_page);
-		put_page(kmapped_page);
-	}
-	return ret;
-}
-
-/*
- * compat_do_execve() is mostly a copy of do_execve(), with the exception
- * that it processes 32 bit argv and envp pointers.
- */
-int compat_do_execve(char * filename,
-	compat_uptr_t __user *argv,
-	compat_uptr_t __user *envp,
-	struct pt_regs * regs)
-{
-	struct linux_binprm *bprm;
-	struct file *file;
-	struct files_struct *displaced;
-	bool clear_in_exec;
-	int retval;
-
-	retval = unshare_files(&displaced);
-	if (retval)
-		goto out_ret;
-
-	retval = -ENOMEM;
-	bprm = kzalloc(sizeof(*bprm), GFP_KERNEL);
-	if (!bprm)
-		goto out_files;
-
-	retval = prepare_bprm_creds(bprm);
-	if (retval)
-		goto out_free;
-
-	retval = check_unsafe_exec(bprm);
-	if (retval < 0)
-		goto out_free;
-	clear_in_exec = retval;
-	current->in_execve = 1;
-
-	file = open_exec(filename);
-	retval = PTR_ERR(file);
-	if (IS_ERR(file))
-		goto out_unmark;
-
-	sched_exec();
-
-	bprm->file = file;
-	bprm->filename = filename;
-	bprm->interp = filename;
-
-	retval = bprm_mm_init(bprm);
-	if (retval)
-		goto out_file;
-
-	bprm->argc = compat_count(argv, MAX_ARG_STRINGS);
-	if ((retval = bprm->argc) < 0)
-		goto out;
-
-	bprm->envc = compat_count(envp, MAX_ARG_STRINGS);
-	if ((retval = bprm->envc) < 0)
-		goto out;
-
-	retval = prepare_binprm(bprm);
-	if (retval < 0)
-		goto out;
-
-	retval = copy_strings_kernel(1, &bprm->filename, bprm);
-	if (retval < 0)
-		goto out;
-
-	bprm->exec = bprm->p;
-	retval = compat_copy_strings(bprm->envc, envp, bprm);
-	if (retval < 0)
-		goto out;
-
-	retval = compat_copy_strings(bprm->argc, argv, bprm);
-	if (retval < 0)
-		goto out;
-
-	retval = search_binary_handler(bprm, regs);
-	if (retval < 0)
-		goto out;
-
-	/* execve succeeded */
-	current->fs->in_exec = 0;
-	current->in_execve = 0;
-	acct_update_integrals(current);
-	free_bprm(bprm);
-	if (displaced)
-		put_files_struct(displaced);
-	return retval;
-
-out:
-	if (bprm->mm) {
-		acct_arg_size(bprm, 0);
-		mmput(bprm->mm);
-	}
-
-out_file:
-	if (bprm->file) {
-		allow_write_access(bprm->file);
-		fput(bprm->file);
-	}
-
-out_unmark:
-	if (clear_in_exec)
-		current->fs->in_exec = 0;
-	current->in_execve = 0;
-
-out_free:
-	free_bprm(bprm);
-
-out_files:
-	if (displaced)
-		reset_files_struct(displaced);
-out_ret:
-	return retval;
-}
-
 #define __COMPAT_NFDBITS       (8 * sizeof(compat_ulong_t))
 
 static int poll_select_copy_remaining(struct timespec *end_time, void __user *p,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
