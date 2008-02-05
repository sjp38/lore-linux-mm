Subject: [PATCH] badness() dramatically overcounts memory
From: Jeff Davis <linux@j-davis.com>
Content-Type: multipart/mixed; boundary="=-nuNqpYQy4gUVwiyp56yI"
Date: Mon, 04 Feb 2008 19:34:40 -0800
Message-Id: <1202182480.24634.22.camel@dogma.ljc.laika.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-nuNqpYQy4gUVwiyp56yI
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


In oom_kill.c, one of the badness calculations is wildly inaccurate. If
memory is shared among child processes, that same memory will be counted
for each child, effectively multiplying the memory penalty by N, where N
is the number of children.

This makes it almost certain that the parent will always be chosen as
the victim of the OOM killer (assuming any substantial amount memory
shared among the children), even if the parent and children are well
behaved and have a reasonable and unchanging VM size.

Usually this does not actually alleviate the memory pressure because the
truly bad process is completely unrelated; and the OOM killer must later
kill the truly bad process.

This trivial patch corrects the calculation so that it does not count a
child's shared memory against the parent.

Regards,
	Jeff Davis

--=-nuNqpYQy4gUVwiyp56yI
Content-Disposition: attachment; filename=linux-badness.diff
Content-Type: text/x-patch; name=linux-badness.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

--- mm/oom_kill.c.orig	2007-08-01 10:41:53.000000000 -0700
+++ mm/oom_kill.c	2008-02-04 14:47:10.000000000 -0800
@@ -83,11 +83,14 @@
 	 * machine with an endless amount of children. In case a single
 	 * child is eating the vast majority of memory, adding only half
 	 * to the parents will make the child our kill candidate of choice.
+	 * When counting the children's vmsize against the parent, we
+	 * subtract shared_vm first, to avoid overcounting memory that is
+	 * shared among the child processes and the parent.
 	 */
 	list_for_each_entry(child, &p->children, sibling) {
 		task_lock(child);
 		if (child->mm != mm && child->mm)
-			points += child->mm->total_vm/2 + 1;
+			points += (child->mm->total_vm - child->mm->shared_vm)/2 + 1;
 		task_unlock(child);
 	}
 

--=-nuNqpYQy4gUVwiyp56yI--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
