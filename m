Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id AC7568D0039
	for <linux-mm@kvack.org>; Mon, 14 Feb 2011 14:18:14 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH] mm: grab rcu read lock in move_pages()
Date: Mon, 14 Feb 2011 11:17:26 -0800
Message-Id: <1297711046-4046-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>

The move_pages() usage of find_task_by_vpid() requires rcu_read_lock()
to prevent free_pid() from reclaiming the pid.

Without this patch, RCU warnings are printed in v2.6.38-rc4 move_pages()
with:
  CONFIG_LOCKUP_DETECTOR=y
  CONFIG_PREEMPT=y
  CONFIG_LOCKDEP=y
  CONFIG_PROVE_LOCKING=y
  CONFIG_PROVE_RCU=y

Previously, migrate_pages() went through a similar transformation
replacing usage of tasklist_lock with rcu read lock:
  commit 55cfaa3cbdd29c4919ecb5fb8965c310f357e48c
  Author: Zeng Zhaoming <zengzm.kernel@gmail.com>
  Date:   Thu Dec 2 14:31:13 2010 -0800

      mm/mempolicy.c: add rcu read lock to protect pid structure

  commit 1e50df39f6e2c3a4a3394df62baa8a213df16c54
  Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
  Date:   Thu Jan 13 15:46:14 2011 -0800

      mempolicy: remove tasklist_lock from migrate_pages

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 mm/migrate.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 7661152..352de555 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1287,14 +1287,14 @@ SYSCALL_DEFINE6(move_pages, pid_t, pid, unsigned long, nr_pages,
 		return -EPERM;
 
 	/* Find the mm_struct */
-	read_lock(&tasklist_lock);
+	rcu_read_lock();
 	task = pid ? find_task_by_vpid(pid) : current;
 	if (!task) {
-		read_unlock(&tasklist_lock);
+		rcu_read_unlock();
 		return -ESRCH;
 	}
 	mm = get_task_mm(task);
-	read_unlock(&tasklist_lock);
+	rcu_read_unlock();
 
 	if (!mm)
 		return -EINVAL;
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
