Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 50EC68D003B
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 13:01:18 -0500 (EST)
Date: Fri, 25 Feb 2011 18:52:49 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 2/5] exec: introduce "bool compat" argument
Message-ID: <20110225175249.GC19059@redhat.com>
References: <20101130200129.GG11905@redhat.com> <compat-not-unlikely@mdm.bga.com> <20101201182747.GB6143@redhat.com> <20110225175202.GA19059@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110225175202.GA19059@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>

No functional changes, preparation to simplify the review.

And the new (and currently unused) "bool compat" argument to
get_arg_ptr(), count(), and copy_strings().

Add this argument to do_execve() as well, and rename it to
do_execve_common().

Reintroduce do_execve() as a trivial wrapper() on top of
do_execve_common(compat => false).

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---

 fs/exec.c |   33 +++++++++++++++++++++------------
 1 file changed, 21 insertions(+), 12 deletions(-)

--- 38/fs/exec.c~2_is_compat_arg	2011-02-25 18:04:50.000000000 +0100
+++ 38/fs/exec.c	2011-02-25 18:05:05.000000000 +0100
@@ -396,7 +396,7 @@ err:
 }
 
 static const char __user *
-get_arg_ptr(const char __user * const __user *argv, int argc)
+get_arg_ptr(const char __user * const __user *argv, int argc, bool compat)
 {
 	const char __user *ptr;
 
@@ -409,13 +409,13 @@ get_arg_ptr(const char __user * const __
 /*
  * count() counts the number of strings in array ARGV.
  */
-static int count(const char __user * const __user * argv, int max)
+static int count(const char __user * const __user *argv, int max, bool compat)
 {
 	int i = 0;
 
 	if (argv != NULL) {
 		for (;;) {
-			const char __user *p = get_arg_ptr(argv, i);
+			const char __user *p = get_arg_ptr(argv, i, compat);
 
 			if (!p)
 				break;
@@ -440,7 +440,7 @@ static int count(const char __user * con
  * ensures the destination page is created and not swapped out.
  */
 static int copy_strings(int argc, const char __user *const __user *argv,
-			struct linux_binprm *bprm)
+			struct linux_binprm *bprm, bool compat)
 {
 	struct page *kmapped_page = NULL;
 	char *kaddr = NULL;
@@ -453,7 +453,7 @@ static int copy_strings(int argc, const 
 		unsigned long pos;
 
 		ret = -EFAULT;
-		str = get_arg_ptr(argv, argc);
+		str = get_arg_ptr(argv, argc, compat);
 		if (IS_ERR(str))
 			goto out;
 
@@ -536,7 +536,8 @@ int copy_strings_kernel(int argc, const 
 	int r;
 	mm_segment_t oldfs = get_fs();
 	set_fs(KERNEL_DS);
-	r = copy_strings(argc, (const char __user *const  __user *)argv, bprm);
+	r = copy_strings(argc, (const char __user *const  __user *)argv,
+				bprm, false);
 	set_fs(oldfs);
 	return r;
 }
@@ -1387,10 +1388,10 @@ EXPORT_SYMBOL(search_binary_handler);
 /*
  * sys_execve() executes a new program.
  */
-int do_execve(const char * filename,
+static int do_execve_common(const char *filename,
 	const char __user *const __user *argv,
 	const char __user *const __user *envp,
-	struct pt_regs * regs)
+	struct pt_regs *regs, bool compat)
 {
 	struct linux_binprm *bprm;
 	struct file *file;
@@ -1432,11 +1433,11 @@ int do_execve(const char * filename,
 	if (retval)
 		goto out_file;
 
-	bprm->argc = count(argv, MAX_ARG_STRINGS);
+	bprm->argc = count(argv, MAX_ARG_STRINGS, compat);
 	if ((retval = bprm->argc) < 0)
 		goto out;
 
-	bprm->envc = count(envp, MAX_ARG_STRINGS);
+	bprm->envc = count(envp, MAX_ARG_STRINGS, compat);
 	if ((retval = bprm->envc) < 0)
 		goto out;
 
@@ -1449,11 +1450,11 @@ int do_execve(const char * filename,
 		goto out;
 
 	bprm->exec = bprm->p;
-	retval = copy_strings(bprm->envc, envp, bprm);
+	retval = copy_strings(bprm->envc, envp, bprm, compat);
 	if (retval < 0)
 		goto out;
 
-	retval = copy_strings(bprm->argc, argv, bprm);
+	retval = copy_strings(bprm->argc, argv, bprm, compat);
 	if (retval < 0)
 		goto out;
 
@@ -1497,6 +1498,14 @@ out_ret:
 	return retval;
 }
 
+int do_execve(const char *filename,
+	const char __user *const __user *argv,
+	const char __user *const __user *envp,
+	struct pt_regs *regs)
+{
+	return do_execve_common(filename, argv, envp, regs, false);
+}
+
 void set_binfmt(struct linux_binfmt *new)
 {
 	struct mm_struct *mm = current->mm;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
