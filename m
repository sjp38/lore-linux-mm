Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7206D8D0001
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 15:08:04 -0500 (EST)
Date: Tue, 30 Nov 2010 21:01:29 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 3/4] exec: unify compat_do_execve() code
Message-ID: <20101130200129.GG11905@redhat.com>
References: <20101125140253.GA29371@redhat.com> <20101125193659.GA14510@redhat.com> <20101129093803.829F.A69D9226@jp.fujitsu.com> <20101129113357.GA30657@redhat.com> <20101129182332.GA21470@redhat.com> <20101130195456.GA11905@redhat.com> <20101130200016.GD11905@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101130200016.GD11905@redhat.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

Teach get_arg_ptr() to handle compat = T case correctly.

This allows us to remove the compat_do_execve() code from fs/compat.c
and reimplement compat_do_execve() as the trivial wrapper on top of
do_execve_common(compat => true).

In fact, this fixes another (minor) bug. "compat_uptr_t str" can
overflow after "str += len" in compat_copy_strings() if a 64bit
application execs via sys32_execve().

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---

 fs/exec.c   |   25 ++++++
 fs/compat.c |  235 ------------------------------------------------------------
 2 files changed, 25 insertions(+), 235 deletions(-)

--- K/fs/exec.c~3_use_compat	2010-11-30 19:47:24.000000000 +0100
+++ K/fs/exec.c	2010-11-30 20:15:11.000000000 +0100
@@ -55,6 +55,7 @@
 #include <linux/fs_struct.h>
 #include <linux/pipe_fs_i.h>
 #include <linux/oom.h>
+#include <linux/compat.h>
 
 #include <asm/uaccess.h>
 #include <asm/mmu_context.h>
@@ -395,6 +396,18 @@ get_arg_ptr(const char __user * const __
 {
 	const char __user *ptr;
 
+#ifdef CONFIG_COMPAT
+	if (unlikely(compat)) {
+		compat_uptr_t __user *a = (void __user*)argv;
+		compat_uptr_t p;
+
+		if (get_user(p, a + argc))
+			return ERR_PTR(-EFAULT);
+
+		return compat_ptr(p);
+	}
+#endif
+
 	if (get_user(ptr, argv + argc))
 		return ERR_PTR(-EFAULT);
 
@@ -1501,6 +1514,18 @@ int do_execve(const char *filename,
 	return do_execve_common(filename, argv, envp, regs, false);
 }
 
+#ifdef CONFIG_COMPAT
+int compat_do_execve(char * filename,
+	compat_uptr_t __user *argv,
+	compat_uptr_t __user *envp,
+	struct pt_regs * regs)
+{
+	return do_execve_common(filename,
+				(void __user*)argv, (void __user*)envp,
+				regs, true);
+}
+#endif
+
 void set_binfmt(struct linux_binfmt *new)
 {
 	struct mm_struct *mm = current->mm;
--- K/fs/compat.c~3_use_compat	2010-11-30 18:30:45.000000000 +0100
+++ K/fs/compat.c	2010-11-30 20:17:28.000000000 +0100
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
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
