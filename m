Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 23F756B0008
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 15:06:54 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id h10so2325893pgf.3
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 12:06:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j23sor1234573pff.125.2018.02.14.12.06.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Feb 2018 12:06:53 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 3/3] exec: Pin stack limit during exec
Date: Wed, 14 Feb 2018 12:06:36 -0800
Message-Id: <1518638796-20819-4-git-send-email-keescook@chromium.org>
In-Reply-To: <1518638796-20819-1-git-send-email-keescook@chromium.org>
References: <1518638796-20819-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Ben Hutchings <ben@decadent.org.uk>, Willy Tarreau <w@1wt.eu>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, "Jason A. Donenfeld" <Jason@zx2c4.com>, Rik van Riel <riel@redhat.com>, Laura Abbott <labbott@redhat.com>, Greg KH <greg@kroah.com>, Andy Lutomirski <luto@kernel.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

Since the stack rlimit is used in multiple places during exec and
it can be changed via other threads (via setrlimit()) or processes
(via prlimit()), the assumption that the value doesn't change cannot
be made. This leads to races with mm layout selection and argument size
calculations. This changes the exec path to use the rlimit stored in bprm
instead of in current. Before starting the thread, the bprm stack rlimit
is stored back to current.

Reported-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
Reported-by: Andy Lutomirski <luto@kernel.org>
Reported-by: Brad Spengler <spender@grsecurity.net>
Fixes: 64701dee4178e ("exec: Use sane stack rlimit under secureexec")
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 fs/exec.c               | 27 +++++++++++++++------------
 include/linux/binfmts.h |  2 ++
 2 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index e4ae20ff6278..806936ad9387 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -257,7 +257,7 @@ static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
 		 *    to work from.
 		 */
 		limit = _STK_LIM / 4 * 3;
-		limit = min(limit, rlimit(RLIMIT_STACK) / 4);
+		limit = min(limit, bprm->rlim_stack.rlim_cur / 4);
 		if (size > limit)
 			goto fail;
 	}
@@ -411,6 +411,11 @@ static int bprm_mm_init(struct linux_binprm *bprm)
 	if (!mm)
 		goto err;
 
+	/* Save current stack limit for all calculations made during exec. */
+	task_lock(current->group_leader);
+	bprm->rlim_stack = current->signal->rlim[RLIMIT_STACK];
+	task_unlock(current->group_leader);
+
 	err = __bprm_mm_init(bprm);
 	if (err)
 		goto err;
@@ -697,7 +702,7 @@ int setup_arg_pages(struct linux_binprm *bprm,
 
 #ifdef CONFIG_STACK_GROWSUP
 	/* Limit stack size */
-	stack_base = rlimit_max(RLIMIT_STACK);
+	stack_base = bprm->rlim_stack.rlim_max;
 	if (stack_base > STACK_SIZE_MAX)
 		stack_base = STACK_SIZE_MAX;
 
@@ -770,7 +775,7 @@ int setup_arg_pages(struct linux_binprm *bprm,
 	 * Align this down to a page boundary as expand_stack
 	 * will align it up.
 	 */
-	rlim_stack = rlimit(RLIMIT_STACK) & PAGE_MASK;
+	rlim_stack = bprm->rlim_stack.rlim_cur & PAGE_MASK;
 #ifdef CONFIG_STACK_GROWSUP
 	if (stack_size + stack_expand > rlim_stack)
 		stack_base = vma->vm_start + rlim_stack;
@@ -1323,8 +1328,6 @@ EXPORT_SYMBOL(would_dump);
 
 void setup_new_exec(struct linux_binprm * bprm)
 {
-	struct rlimit rlim_stack;
-
 	/*
 	 * Once here, prepare_binrpm() will not be called any more, so
 	 * the final state of setuid/setgid/fscaps can be merged into the
@@ -1343,15 +1346,11 @@ void setup_new_exec(struct linux_binprm * bprm)
 		 * RLIMIT_STACK, but after the point of no return to avoid
 		 * needing to clean up the change on failure.
 		 */
-		if (current->signal->rlim[RLIMIT_STACK].rlim_cur > _STK_LIM)
-			current->signal->rlim[RLIMIT_STACK].rlim_cur = _STK_LIM;
+		if (bprm->rlim_stack.rlim_cur > _STK_LIM)
+			bprm->rlim_stack.rlim_cur = _STK_LIM;
 	}
 
-	task_lock(current->group_leader);
-	rlim_stack = current->signal->rlim[RLIMIT_STACK];
-	task_unlock(current->group_leader);
-
-	arch_pick_mmap_layout(current->mm, &rlim_stack);
+	arch_pick_mmap_layout(current->mm, &bprm->rlim_stack);
 
 	current->sas_ss_sp = current->sas_ss_size = 0;
 
@@ -1387,6 +1386,10 @@ EXPORT_SYMBOL(setup_new_exec);
 /* Runs immediately before start_thread() takes over. */
 void finalize_exec(struct linux_binprm *bprm)
 {
+	/* Store any stack rlimit changes before starting thread. */
+	task_lock(current->group_leader);
+	current->signal->rlim[RLIMIT_STACK] = bprm->rlim_stack;
+	task_unlock(current->group_leader);
 }
 EXPORT_SYMBOL(finalize_exec);
 
diff --git a/include/linux/binfmts.h b/include/linux/binfmts.h
index 40e52afbb2b0..4955e0863b83 100644
--- a/include/linux/binfmts.h
+++ b/include/linux/binfmts.h
@@ -61,6 +61,8 @@ struct linux_binprm {
 	unsigned interp_flags;
 	unsigned interp_data;
 	unsigned long loader, exec;
+
+	struct rlimit rlim_stack; /* Saved RLIMIT_STACK used during exec. */
 } __randomize_layout;
 
 #define BINPRM_FLAGS_ENFORCE_NONDUMP_BIT 0
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
