Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 34ACB6B0071
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 15:02:58 -0500 (EST)
Date: Tue, 30 Nov 2010 20:56:02 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 2/2] exec: copy-and-paste the fixes into compat_do_execve()
	paths
Message-ID: <20101130195602.GC11905@redhat.com>
References: <20101125140253.GA29371@redhat.com> <20101125193659.GA14510@redhat.com> <20101129093803.829F.A69D9226@jp.fujitsu.com> <20101129113357.GA30657@redhat.com> <20101129182332.GA21470@redhat.com> <20101130195456.GA11905@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101130195456.GA11905@redhat.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Note: this patch targets 2.6.37 and tries to be as simple as possible.
That is why it adds more copy-and-paste horror into fs/compat.c and
uglifies fs/exec.c, this will be cleanuped later.

compat_copy_strings() plays with bprm->vma/mm directly and thus has
two problems: it lacks the RLIMIT_STACK check and argv/envp memory
is not visible to oom killer.

Export acct_arg_size() and get_arg_page(), change compat_copy_strings()
to use get_arg_page(), change compat_do_execve() to do acct_arg_size(0)
as do_execve() does.

Add the fatal_signal_pending/cond_resched checks into compat_count() and
compat_copy_strings(), this matches the code in fs/exec.c and certainly
makes sense.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---

 include/linux/binfmts.h |    4 ++++
 fs/exec.c               |    8 ++++----
 fs/compat.c             |   28 +++++++++++++++-------------
 3 files changed, 23 insertions(+), 17 deletions(-)

--- K/include/linux/binfmts.h~compat_get_arg_page	2010-11-30 18:28:54.000000000 +0100
+++ K/include/linux/binfmts.h	2010-11-30 18:30:45.000000000 +0100
@@ -60,6 +60,10 @@ struct linux_binprm{
 	unsigned long loader, exec;
 };
 
+extern void acct_arg_size(struct linux_binprm *bprm, unsigned long pages);
+extern struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
+					int write);
+
 #define BINPRM_FLAGS_ENFORCE_NONDUMP_BIT 0
 #define BINPRM_FLAGS_ENFORCE_NONDUMP (1 << BINPRM_FLAGS_ENFORCE_NONDUMP_BIT)
 
--- K/fs/exec.c~compat_get_arg_page	2010-11-30 18:28:54.000000000 +0100
+++ K/fs/exec.c	2010-11-30 18:30:45.000000000 +0100
@@ -164,7 +164,7 @@ out:
 
 #ifdef CONFIG_MMU
 
-static void acct_arg_size(struct linux_binprm *bprm, unsigned long pages)
+void acct_arg_size(struct linux_binprm *bprm, unsigned long pages)
 {
 	struct mm_struct *mm = current->mm;
 	long diff = (long)(pages - bprm->vma_pages);
@@ -183,7 +183,7 @@ static void acct_arg_size(struct linux_b
 #endif
 }
 
-static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
+struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
 		int write)
 {
 	struct page *page;
@@ -297,11 +297,11 @@ static bool valid_arg_len(struct linux_b
 
 #else
 
-static inline void acct_arg_size(struct linux_binprm *bprm, unsigned long pages)
+void acct_arg_size(struct linux_binprm *bprm, unsigned long pages)
 {
 }
 
-static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
+struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
 		int write)
 {
 	struct page *page;
--- K/fs/compat.c~compat_get_arg_page	2010-11-30 17:55:20.000000000 +0100
+++ K/fs/compat.c	2010-11-30 18:30:45.000000000 +0100
@@ -1350,6 +1350,10 @@ static int compat_count(compat_uptr_t __
 			argv++;
 			if (i++ >= max)
 				return -E2BIG;
+
+			if (fatal_signal_pending(current))
+				return -ERESTARTNOHAND;
+			cond_resched();
 		}
 	}
 	return i;
@@ -1391,6 +1395,12 @@ static int compat_copy_strings(int argc,
 		while (len > 0) {
 			int offset, bytes_to_copy;
 
+			if (fatal_signal_pending(current)) {
+				ret = -ERESTARTNOHAND;
+				goto out;
+			}
+			cond_resched();
+
 			offset = pos % PAGE_SIZE;
 			if (offset == 0)
 				offset = PAGE_SIZE;
@@ -1407,18 +1417,8 @@ static int compat_copy_strings(int argc,
 			if (!kmapped_page || kpos != (pos & PAGE_MASK)) {
 				struct page *page;
 
-#ifdef CONFIG_STACK_GROWSUP
-				ret = expand_stack_downwards(bprm->vma, pos);
-				if (ret < 0) {
-					/* We've exceed the stack rlimit. */
-					ret = -E2BIG;
-					goto out;
-				}
-#endif
-				ret = get_user_pages(current, bprm->mm, pos,
-						     1, 1, 1, &page, NULL);
-				if (ret <= 0) {
-					/* We've exceed the stack rlimit. */
+				page = get_arg_page(bprm, pos, 1);
+				if (!page) {
 					ret = -E2BIG;
 					goto out;
 				}
@@ -1539,8 +1539,10 @@ int compat_do_execve(char * filename,
 	return retval;
 
 out:
-	if (bprm->mm)
+	if (bprm->mm) {
+		acct_arg_size(bprm, 0);
 		mmput(bprm->mm);
+	}
 
 out_file:
 	if (bprm->file) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
