Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BC1718D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 15:57:24 -0500 (EST)
Date: Tue, 1 Mar 2011 21:48:50 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH v2 3/5] exec: introduce conditional_user_ptr_t
Message-ID: <20110301204850.GD30406@redhat.com>
References: <20101130200129.GG11905@redhat.com> <compat-not-unlikely@mdm.bga.com> <20101201182747.GB6143@redhat.com> <20110225175202.GA19059@redhat.com> <20110225175314.GD19059@redhat.com> <AANLkTik8epq5cx8n=k6ocMUfbg9kkUAZ8KL7ZiG4UuoU@mail.gmail.com> <20110226123731.GC4416@redhat.com> <AANLkTinFVCR_znYtyVuJcjFQq_fgMp+ozbSz54UKzvQ_@mail.gmail.com> <20110226174408.GA17442@redhat.com> <20110301204739.GA30406@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110301204739.GA30406@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>

No functional changes, preparation.

Introduce conditional_user_ptr_t, change do_execve() paths to use it
instead of "char __user * const __user *argv".

This makes the argv/envp arguments opaque, we are ready to handle the
compat case which needs argv pointing to compat_uptr_t.

Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---

 fs/exec.c |   33 +++++++++++++++++++++------------
 1 file changed, 21 insertions(+), 12 deletions(-)

--- 38/fs/exec.c~3_typdef_for_argv	2011-03-01 21:17:46.000000000 +0100
+++ 38/fs/exec.c	2011-03-01 21:17:46.000000000 +0100
@@ -395,12 +395,16 @@ err:
 	return err;
 }
 
+typedef union {
+	const char __user *const __user *native;
+} conditional_user_ptr_t;
+
 static const char __user *
-get_arg_ptr(const char __user * const __user *argv, int argc, bool compat)
+get_arg_ptr(conditional_user_ptr_t argv, int argc, bool compat)
 {
 	const char __user *ptr;
 
-	if (get_user(ptr, argv + argc))
+	if (get_user(ptr, argv.native + argc))
 		return ERR_PTR(-EFAULT);
 
 	return ptr;
@@ -409,11 +413,11 @@ get_arg_ptr(const char __user * const __
 /*
  * count() counts the number of strings in array ARGV.
  */
-static int count(const char __user * const __user *argv, int max, bool compat)
+static int count(conditional_user_ptr_t argv, int max, bool compat)
 {
 	int i = 0;
 
-	if (argv != NULL) {
+	if (argv.native != NULL) {
 		for (;;) {
 			const char __user *p = get_arg_ptr(argv, i, compat);
 
@@ -439,7 +443,7 @@ static int count(const char __user * con
  * processes's memory to the new process's stack.  The call to get_user_pages()
  * ensures the destination page is created and not swapped out.
  */
-static int copy_strings(int argc, const char __user *const __user *argv,
+static int copy_strings(int argc, conditional_user_ptr_t argv,
 			struct linux_binprm *bprm, bool compat)
 {
 	struct page *kmapped_page = NULL;
@@ -530,15 +534,19 @@ out:
 /*
  * Like copy_strings, but get argv and its values from kernel memory.
  */
-int copy_strings_kernel(int argc, const char *const *argv,
+int copy_strings_kernel(int argc, const char *const *ptr,
 			struct linux_binprm *bprm)
 {
 	int r;
 	mm_segment_t oldfs = get_fs();
+	conditional_user_ptr_t argv = {
+		.native = (const char __user *const  __user *)ptr,
+	};
+
 	set_fs(KERNEL_DS);
-	r = copy_strings(argc, (const char __user *const  __user *)argv,
-				bprm, false);
+	r = copy_strings(argc, argv, bprm, false);
 	set_fs(oldfs);
+
 	return r;
 }
 EXPORT_SYMBOL(copy_strings_kernel);
@@ -1389,8 +1397,7 @@ EXPORT_SYMBOL(search_binary_handler);
  * sys_execve() executes a new program.
  */
 static int do_execve_common(const char *filename,
-	const char __user *const __user *argv,
-	const char __user *const __user *envp,
+	conditional_user_ptr_t argv, conditional_user_ptr_t envp,
 	struct pt_regs *regs, bool compat)
 {
 	struct linux_binprm *bprm;
@@ -1499,10 +1506,12 @@ out_ret:
 }
 
 int do_execve(const char *filename,
-	const char __user *const __user *argv,
-	const char __user *const __user *envp,
+	const char __user *const __user *__argv,
+	const char __user *const __user *__envp,
 	struct pt_regs *regs)
 {
+	conditional_user_ptr_t argv = { .native = __argv };
+	conditional_user_ptr_t envp = { .native = __envp };
 	return do_execve_common(filename, argv, envp, regs, false);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
