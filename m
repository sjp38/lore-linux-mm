Date: Fri, 18 Apr 2008 11:55:29 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: get_task_mm() should not succeed if mm_users = 0.
Message-ID: <Pine.LNX.4.64.0804181154480.25690@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, holt@sgi.com
List-ID: <linux-mm.kvack.org>

get_task_mm should not succeed if mmput() is running and has reduced
the mm_users count to zero. This can occur if a processor follows
a tasks pointer to an mm struct because that pointer is only cleared
after the mmput().

If get_task_mm() succeeds after mmput() reduced the mm_users to zero then
we have the lovely situation that one portion of the kernel is doing
all the teardown work for an mm while another portion is happily using
it.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 kernel/fork.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c	2008-04-17 13:25:15.000000000 -0700
+++ linux-2.6/kernel/fork.c	2008-04-17 13:27:13.000000000 -0700
@@ -440,7 +440,8 @@ struct mm_struct *get_task_mm(struct tas
 		if (task->flags & PF_BORROWED_MM)
 			mm = NULL;
 		else
-			atomic_inc(&mm->mm_users);
+			if (!atomic_inc_not_zero(&mm->mm_users))
+				mm = NULL;
 	}
 	task_unlock(task);
 	return mm;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
