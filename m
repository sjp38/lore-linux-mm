Date: Thu, 26 Aug 2004 23:39:07 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: rss-ulimit-enforcement.patch
Message-Id: <20040826233907.3726e2fa.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Guys, I'm reluctant to proceed with this until we've actually been able to
demonstrate that it does something, let alone something useful.  I was not
able to demonstrate this, in some brief+lame testing.



From: Rik van Riel <riel@redhat.com>

The patch below implements RSS ulimit enforcement.

It works in a very simple way: if a process has more resident memory than
its RSS limit allows, we pretend it didn't access any of its pages, making
it easy for the pageout code to evict the pages.

In addition to this, we don't allow a process that exceeds its RSS limit to
have the swapout protection token.

I have tested the patch on my system here and it appears to be working
fine.

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/fs/exec.c                 |    5 +++++
 25-akpm/include/linux/init_task.h |    2 ++
 25-akpm/include/linux/sched.h     |    2 +-
 25-akpm/kernel/sys.c              |    8 ++++++++
 25-akpm/mm/rmap.c                 |    3 +++
 25-akpm/mm/thrash.c               |    8 +++++---
 6 files changed, 24 insertions(+), 4 deletions(-)

diff -puN fs/exec.c~rss-ulimit-enforcement fs/exec.c
--- 25/fs/exec.c~rss-ulimit-enforcement	2004-08-24 22:09:24.447573472 -0700
+++ 25-akpm/fs/exec.c	2004-08-24 22:09:24.458571800 -0700
@@ -1125,6 +1125,11 @@ int do_execve(char * filename,
 	retval = init_new_context(current, bprm.mm);
 	if (retval < 0)
 		goto out_mm;
+	if (likely(current->mm)) {
+		bprm.mm->rlimit_rss = current->mm->rlimit_rss;
+	} else {
+		bprm.mm->rlimit_rss = init_mm.rlimit_rss;
+	}
 
 	bprm.argc = count(argv, bprm.p / sizeof(void *));
 	if ((retval = bprm.argc) < 0)
diff -puN include/linux/init_task.h~rss-ulimit-enforcement include/linux/init_task.h
--- 25/include/linux/init_task.h~rss-ulimit-enforcement	2004-08-24 22:09:24.449573168 -0700
+++ 25-akpm/include/linux/init_task.h	2004-08-24 22:09:24.459571648 -0700
@@ -2,6 +2,7 @@
 #define _LINUX__INIT_TASK_H
 
 #include <linux/file.h>
+#include <asm/resource.h>
 
 #define INIT_FILES \
 { 							\
@@ -42,6 +43,7 @@
 	.mmlist		= LIST_HEAD_INIT(name.mmlist),		\
 	.cpu_vm_mask	= CPU_MASK_ALL,				\
 	.default_kioctx = INIT_KIOCTX(name.default_kioctx, name),	\
+	.rlimit_rss	= RLIM_INFINITY,			\
 }
 
 #define INIT_SIGNALS(sig) {	\
diff -puN include/linux/sched.h~rss-ulimit-enforcement include/linux/sched.h
--- 25/include/linux/sched.h~rss-ulimit-enforcement	2004-08-24 22:09:24.450573016 -0700
+++ 25-akpm/include/linux/sched.h	2004-08-24 22:09:24.460571496 -0700
@@ -224,7 +224,7 @@ struct mm_struct {
 	unsigned long start_code, end_code, start_data, end_data;
 	unsigned long start_brk, brk, start_stack;
 	unsigned long arg_start, arg_end, env_start, env_end;
-	unsigned long rss, total_vm, locked_vm;
+	unsigned long rlimit_rss, rss, total_vm, locked_vm;
 	unsigned long def_flags;
 
 	unsigned long saved_auxv[40]; /* for /proc/PID/auxv */
diff -puN kernel/sys.c~rss-ulimit-enforcement kernel/sys.c
--- 25/kernel/sys.c~rss-ulimit-enforcement	2004-08-24 22:09:24.452572712 -0700
+++ 25-akpm/kernel/sys.c	2004-08-24 22:09:24.461571344 -0700
@@ -1527,6 +1527,14 @@ asmlinkage long sys_setrlimit(unsigned i
 	if (retval)
 		return retval;
 
+	/* The rlimit is specified in bytes, convert to pages for mm. */
+	if (resource == RLIMIT_RSS && current->mm) {
+		unsigned long pages = RLIM_INFINITY;
+		if (new_rlim.rlim_cur != RLIM_INFINITY)
+			pages = new_rlim.rlim_cur >> PAGE_SHIFT;
+		current->mm->rlimit_rss = pages;
+	}
+
 	*old_rlim = new_rlim;
 	return 0;
 }
diff -puN mm/rmap.c~rss-ulimit-enforcement mm/rmap.c
--- 25/mm/rmap.c~rss-ulimit-enforcement	2004-08-24 22:09:24.453572560 -0700
+++ 25-akpm/mm/rmap.c	2004-08-24 22:09:24.462571192 -0700
@@ -291,6 +291,9 @@ static int page_referenced_one(struct pa
 	if (mm != current->mm && has_swap_token(mm))
 		referenced++;
 
+	if (mm->rss > mm->rlimit_rss)
+		referenced = 0;
+
 	(*mapcount)--;
 
 out_unmap:
diff -puN mm/thrash.c~rss-ulimit-enforcement mm/thrash.c
--- 25/mm/thrash.c~rss-ulimit-enforcement	2004-08-24 22:09:24.454572408 -0700
+++ 25-akpm/mm/thrash.c	2004-08-24 22:09:24.462571192 -0700
@@ -24,7 +24,7 @@ struct mm_struct * swap_token_mm = &init
 /*
  * Take the token away if the process had no page faults
  * in the last interval, or if it has held the token for
- * too long.
+ * too long, or if the process exceeds its RSS limit.
  */
 #define SWAP_TOKEN_ENOUGH_RSS 1
 #define SWAP_TOKEN_TIMED_OUT 2
@@ -35,6 +35,8 @@ static int should_release_swap_token(str
 		ret = SWAP_TOKEN_ENOUGH_RSS;
 	else if (time_after(jiffies, swap_token_timeout))
 		ret = SWAP_TOKEN_TIMED_OUT;
+	else if (mm->rss > mm->rlimit_rss)
+		ret = SWAP_TOKEN_ENOUGH_RSS;
 	mm->recent_pagein = 0;
 	return ret;
 }
@@ -59,8 +61,8 @@ void grab_swap_token(void)
 	if (time_after(jiffies, swap_token_check)) {
 
 		/* Can't get swapout protection if we exceed our RSS limit. */
-		// if (current->mm->rss > current->mm->rlimit_rss)
-		//	return;
+		if (current->mm->rss > current->mm->rlimit_rss)
+			return;
 
 		/* ... or if we recently held the token. */
 		if (time_before(jiffies, current->mm->swap_token_time))
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
