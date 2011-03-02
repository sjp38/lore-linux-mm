Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id ED7728D0040
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 11:36:12 -0500 (EST)
Date: Wed, 2 Mar 2011 17:27:32 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH v3 2/4] exec: introduce struct conditional_ptr
Message-ID: <20110302162732.GC26810@redhat.com>
References: <20101201182747.GB6143@redhat.com> <20110225175202.GA19059@redhat.com> <20110225175314.GD19059@redhat.com> <AANLkTik8epq5cx8n=k6ocMUfbg9kkUAZ8KL7ZiG4UuoU@mail.gmail.com> <20110226123731.GC4416@redhat.com> <AANLkTinFVCR_znYtyVuJcjFQq_fgMp+ozbSz54UKzvQ_@mail.gmail.com> <20110226174408.GA17442@redhat.com> <20110301204739.GA30406@redhat.com> <AANLkTikVecxcGoZ9a4hmkoi4wynrNfH9_AU7Vb+hOvbH@mail.gmail.com> <20110302162650.GA26810@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110302162650.GA26810@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>

No functional changes, preparation.

Introduce struct conditional_ptr, change do_execve() paths to use it
instead of "char __user * const __user *argv".

This makes the argv/envp arguments opaque, we are ready to handle the
compat case which needs argv pointing to compat_uptr_t.

Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---

 fs/exec.c |   42 ++++++++++++++++++++++++++++++------------
 1 file changed, 30 insertions(+), 12 deletions(-)

--- 38/fs/exec.c~2_typedef_for_argv	2011-03-02 15:40:22.000000000 +0100
+++ 38/fs/exec.c	2011-03-02 15:40:44.000000000 +0100
@@ -395,12 +395,15 @@ err:
 	return err;
 }
 
-static const char __user *
-get_arg_ptr(const char __user * const __user *argv, int argc)
+struct conditional_ptr {
+	const char __user *const __user *native;
+};
+
+static const char __user *get_arg_ptr(struct conditional_ptr argv, int argc)
 {
 	const char __user *ptr;
 
-	if (get_user(ptr, argv + argc))
+	if (get_user(ptr, argv.native + argc))
 		return ERR_PTR(-EFAULT);
 
 	return ptr;
@@ -409,11 +412,11 @@ get_arg_ptr(const char __user * const __
 /*
  * count() counts the number of strings in array ARGV.
  */
-static int count(const char __user * const __user * argv, int max)
+static int count(struct conditional_ptr argv, int max)
 {
 	int i = 0;
 
-	if (argv != NULL) {
+	if (argv.native != NULL) {
 		for (;;) {
 			const char __user *p = get_arg_ptr(argv, i);
 
@@ -439,7 +442,7 @@ static int count(const char __user * con
  * processes's memory to the new process's stack.  The call to get_user_pages()
  * ensures the destination page is created and not swapped out.
  */
-static int copy_strings(int argc, const char __user *const __user *argv,
+static int copy_strings(int argc, struct conditional_ptr argv,
 			struct linux_binprm *bprm)
 {
 	struct page *kmapped_page = NULL;
@@ -530,14 +533,19 @@ out:
 /*
  * Like copy_strings, but get argv and its values from kernel memory.
  */
-int copy_strings_kernel(int argc, const char *const *argv,
+int copy_strings_kernel(int argc, const char *const *__argv,
 			struct linux_binprm *bprm)
 {
 	int r;
 	mm_segment_t oldfs = get_fs();
+	struct conditional_ptr argv = {
+		.native = (const char __user *const  __user *)__argv,
+	};
+
 	set_fs(KERNEL_DS);
-	r = copy_strings(argc, (const char __user *const  __user *)argv, bprm);
+	r = copy_strings(argc, argv, bprm);
 	set_fs(oldfs);
+
 	return r;
 }
 EXPORT_SYMBOL(copy_strings_kernel);
@@ -1387,10 +1395,10 @@ EXPORT_SYMBOL(search_binary_handler);
 /*
  * sys_execve() executes a new program.
  */
-int do_execve(const char * filename,
-	const char __user *const __user *argv,
-	const char __user *const __user *envp,
-	struct pt_regs * regs)
+static int do_execve_common(const char *filename,
+				struct conditional_ptr argv,
+				struct conditional_ptr envp,
+				struct pt_regs *regs)
 {
 	struct linux_binprm *bprm;
 	struct file *file;
@@ -1497,6 +1505,16 @@ out_ret:
 	return retval;
 }
 
+int do_execve(const char *filename,
+	const char __user *const __user *__argv,
+	const char __user *const __user *__envp,
+	struct pt_regs *regs)
+{
+	struct conditional_ptr argv = { .native = __argv };
+	struct conditional_ptr envp = { .native = __envp };
+	return do_execve_common(filename, argv, envp, regs);
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
