Date: Sun, 18 May 2008 21:00:54 +0400
From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: [PATCH 1/3] uml: activate_mm: remove the dead PF_BORROWED_MM check
Message-ID: <20080518170054.GA25872@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@elte.hu>, Jeff Dike <jdike@addtoit.com>, Linus Torvalds <torvalds@linux-foundation.org>, Roland McGrath <roland@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

use_mm() was changed to use switch_mm() instead of activate_mm(), since then
nobody calls (and nobody should call) activate_mm() with PF_BORROWED_MM bit
set.

As Jeff Dike pointed out, we can also remove the "old != new" check, it is
always true.

Signed-off-by: Oleg Nesterov <oleg@tv-sign.ru>

--- 26-rc2/include/asm-um/mmu_context.h~1_UML_KILL_PFBMM	2008-02-15 16:59:17.000000000 +0300
+++ 26-rc2/include/asm-um/mmu_context.h	2008-05-18 17:26:37.000000000 +0400
@@ -22,16 +22,10 @@ extern void force_flush_all(void);
 static inline void activate_mm(struct mm_struct *old, struct mm_struct *new)
 {
 	/*
-	 * This is called by fs/exec.c and fs/aio.c. In the first case, for an
-	 * exec, we don't need to do anything as we're called from userspace
-	 * and thus going to use a new host PID. In the second, we're called
-	 * from a kernel thread, and thus need to go doing the mmap's on the
-	 * host. Since they're very expensive, we want to avoid that as far as
-	 * possible.
+	 * This is called by fs/exec.c and sys_unshare()
+	 * when the new ->mm is used for the first time.
 	 */
-	if (old != new && (current->flags & PF_BORROWED_MM))
-		__switch_mm(&new->context.id);
-
+	__switch_mm(&new->context.id);
 	arch_dup_mmap(old, new);
 }
 
--- 26-rc2/fs/aio.c~1_UML_KILL_PFBMM	2008-05-18 15:43:59.000000000 +0400
+++ 26-rc2/fs/aio.c	2008-05-18 17:20:42.000000000 +0400
@@ -591,10 +591,6 @@ static void use_mm(struct mm_struct *mm)
 	atomic_inc(&mm->mm_count);
 	tsk->mm = mm;
 	tsk->active_mm = mm;
-	/*
-	 * Note that on UML this *requires* PF_BORROWED_MM to be set, otherwise
-	 * it won't work. Update it accordingly if you change it here
-	 */
 	switch_mm(active_mm, mm, tsk);
 	task_unlock(tsk);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
