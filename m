Date: Thu, 3 Jul 2008 21:50:31 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 2.6.26-rc8-mm1] memrlimit: fix mmap_sem deadlock
Message-ID: <Pine.LNX.4.64.0807032143110.10641@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"ps -f" hung after "killall make" of make -j20 kernel builds.  It's
generally considered bad manners to down_write something you already
have down_read.  exit_mm up_reads before calling mm_update_next_owner,
so I guess exec_mmap can safely do so too.  (And with that repositioning
there's not much point in mm_need_new_owner allowing for NULL mm.)

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
Fix to memrlimit-cgroup-mm-owner-callback-changes-to-add-task-info.patch
quite independent of its recent sleeping-inside-spinlock fix; could even
be applied to 2.6.26, though no deadlock there.  Gosh, I see those patches
have spawned "Reviewed-by" tags in my name: sorry, no, just "Bug-found-by".

 fs/exec.c     |    2 +-
 kernel/exit.c |    2 --
 2 files changed, 1 insertion(+), 3 deletions(-)

--- 2.6.26-rc8-mm1/fs/exec.c	2008-07-03 11:35:20.000000000 +0100
+++ linux/fs/exec.c	2008-07-03 20:27:20.000000000 +0100
@@ -738,11 +738,11 @@ static int exec_mmap(struct mm_struct *m
 	tsk->active_mm = mm;
 	activate_mm(active_mm, mm);
 	task_unlock(tsk);
-	mm_update_next_owner(old_mm);
 	arch_pick_mmap_layout(mm);
 	if (old_mm) {
 		up_read(&old_mm->mmap_sem);
 		BUG_ON(active_mm != old_mm);
+		mm_update_next_owner(old_mm);
 		mmput(old_mm);
 		return 0;
 	}
--- 2.6.26-rc8-mm1/kernel/exit.c	2008-07-03 11:35:37.000000000 +0100
+++ linux/kernel/exit.c	2008-07-03 20:28:35.000000000 +0100
@@ -588,8 +588,6 @@ mm_need_new_owner(struct mm_struct *mm, 
 	 * If there are other users of the mm and the owner (us) is exiting
 	 * we need to find a new owner to take on the responsibility.
 	 */
-	if (!mm)
-		return 0;
 	if (atomic_read(&mm->mm_users) <= 1)
 		return 0;
 	if (mm->owner != p)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
