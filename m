Date: Thu, 08 May 2008 08:55:45 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] on CONFIG_MM_OWNER=y, kernel panic is possible. take2
In-Reply-To: <6599ad830805062037n221ef8e2n9ee7ac33417ab499@mail.gmail.com>
References: <20080506153943.AC69.KOSAKI.MOTOHIRO@jp.fujitsu.com> <6599ad830805062037n221ef8e2n9ee7ac33417ab499@mail.gmail.com>
Message-Id: <20080508083808.4A78.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>, balbir@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> I'd word it as
> 
> /*
>  * "owner" points to a task that is regarded as the canonical
>  * user/owner of this mm. All of the following must be true in
>  * order for it to be changed:
>  *
>  * current == mm->owner
>  * current->mm != mm
>  * new_owner->mm == mm
>  * new_owner->alloc_lock is held
>  */

Wow, Thank you a lot!
new version attached.

Cheers!


-----------------------------------------------------------
When mm destruct happend, We should pass mm_update_next_owner() 
old mm.
but unfortunately new mm is passed in exec_mmap().

thus, kernel panic is possible when multi thread process use exec().


and, owner member comment description is wrong.
mm->owner don't not necessarily point to thread group leader.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Balbir Singh <balbir@linux.vnet.ibm.com>
CC: "Paul Menage" <menage@google.com>
CC: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>

---
 fs/exec.c                |    2 +-
 include/linux/mm_types.h |   13 +++++++++++--
 2 files changed, 12 insertions(+), 3 deletions(-)

Index: b/fs/exec.c
===================================================================
--- a/fs/exec.c	2008-05-04 22:57:09.000000000 +0900
+++ b/fs/exec.c	2008-05-06 15:40:35.000000000 +0900
@@ -735,7 +735,7 @@ static int exec_mmap(struct mm_struct *m
 	tsk->active_mm = mm;
 	activate_mm(active_mm, mm);
 	task_unlock(tsk);
-	mm_update_next_owner(mm);
+	mm_update_next_owner(old_mm);
 	arch_pick_mmap_layout(mm);
 	if (old_mm) {
 		up_read(&old_mm->mmap_sem);
Index: b/include/linux/mm_types.h
===================================================================
--- a/include/linux/mm_types.h	2008-05-08 09:20:13.000000000 +0900
+++ b/include/linux/mm_types.h	2008-05-08 09:22:13.000000000 +0900
@@ -231,8 +231,17 @@ struct mm_struct {
 	rwlock_t		ioctx_list_lock;	/* aio lock */
 	struct kioctx		*ioctx_list;
 #ifdef CONFIG_MM_OWNER
-	struct task_struct *owner;	/* The thread group leader that */
-					/* owns the mm_struct.		*/
+        /*
+         * "owner" points to a task that is regarded as the canonical
+         * user/owner of this mm. All of the following must be true in
+         * order for it to be changed:
+         *
+         * current == mm->owner
+         * current->mm != mm
+         * new_owner->mm == mm
+         * new_owner->alloc_lock is held
+         */
+	struct task_struct *owner;
 #endif
 
 #ifdef CONFIG_PROC_FS




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
