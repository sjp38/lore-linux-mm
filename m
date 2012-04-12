Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 854896B004D
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 04:09:57 -0400 (EDT)
Received: by lbao2 with SMTP id o2so1775888lba.14
        for <linux-mm@kvack.org>; Thu, 12 Apr 2012 01:09:55 -0700 (PDT)
Subject: [PATCH 2/2] mm: call complete_vfork_done() after clearing child_tid
 and flushing rss-counters
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 12 Apr 2012 12:09:53 +0400
Message-ID: <20120412080952.26401.2025.stgit@zurg>
In-Reply-To: <20120409200336.8368.63793.stgit@zurg>
References: <20120409200336.8368.63793.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Markus Trippelsdorf <markus@trippelsdorf.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Child should wake ups parent from vfork() only after finishing all operations with
shared mm. There is no sense to use CLONE_CHILD_CLEARTID together with CLONE_VFORK,
but it looks more accurate now.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Oleg Nesterov <oleg@redhat.com>
---
 kernel/fork.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 326bb5b..f10ac1d 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -728,9 +728,6 @@ void mm_release(struct task_struct *tsk, struct mm_struct *mm)
 	/* Get rid of any cached register state */
 	deactivate_mm(tsk, mm);
 
-	if (tsk->vfork_done)
-		complete_vfork_done(tsk);
-
 	/*
 	 * If we're exiting normally, clear a user-space tid field if
 	 * requested.  We leave this alone when dying by signal, to leave
@@ -759,6 +756,13 @@ void mm_release(struct task_struct *tsk, struct mm_struct *mm)
 	 */
 	if (mm)
 		sync_mm_rss(mm);
+
+	/*
+	 * All done, finally we can wake up parent and return this mm to him.
+	 * Also kthread_stop() uses this completion for synchronization.
+	 */
+	if (tsk->vfork_done)
+		complete_vfork_done(tsk);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
