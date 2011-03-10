Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 10E3A8D0039
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 12:27:54 -0500 (EST)
Date: Thu, 10 Mar 2011 18:19:14 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH v2 1/1] select_bad_process: improve the PF_EXITING check
Message-ID: <20110310171914.GB2687@redhat.com>
References: <20110303100030.B936.A69D9226@jp.fujitsu.com> <20110308134233.GA26884@redhat.com> <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com> <20110309110606.GA16719@redhat.com> <alpine.DEB.2.00.1103091222420.13353@chino.kir.corp.google.com> <20110310120519.GA18415@redhat.com> <20110310154032.GA29044@redhat.com> <20110310163652.GA345@redhat.com> <20110310164000.GC345@redhat.com> <20110310171852.GA2687@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110310171852.GA2687@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrey Vagin <avagin@openvz.org>

The current PF_EXITING check in select_bad_process() is very limited,
it only works if the task is single-threaded.

Add the new helper which tries to handle the mt case. It is not exactly
clear what should we actually check in this case. This patch checks
PF_EXITING, but perhaps we can take signal_group_exit() into account.
In this case select_bad_process() could detect the exiting process even
before every thread calls exit().

Note:

	- "if (p != current)" check is obviously wrong in mt case too.

	- with or without this change, we should probably check
	  mm->core_state == NULL. We shouldn't assume that is is going
	  to exit "soon" otherwise. But this needs other changes anyway,
	  and in the common case when we do not share ->mm with another
	  process the false positive is not possible.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---

 mm/oom_kill.c |   17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

--- 38/mm/oom_kill.c~detect_exiting	2011-03-10 16:08:51.000000000 +0100
+++ 38/mm/oom_kill.c	2011-03-10 18:12:35.000000000 +0100
@@ -282,6 +282,21 @@ static enum oom_constraint constrained_a
 }
 #endif
 
+static bool mm_is_exiting(struct task_struct *p)
+{
+	struct task_struct *t;
+	bool has_mm = false;
+
+	do {
+		if (!(t->flags & PF_EXITING))
+			return false;
+		if (t->mm)
+			has_mm = true;
+	} while_each_thread(p, t);
+
+	return has_mm;
+}
+
 /*
  * Simple selection loop. We chose the process with the highest
  * number of 'points'. We expect the caller will lock the tasklist.
@@ -324,7 +339,7 @@ static struct task_struct *select_bad_pr
 		 * the process of exiting and releasing its resources.
 		 * Otherwise we could get an easy OOM deadlock.
 		 */
-		if (thread_group_empty(p) && (p->flags & PF_EXITING) && p->mm) {
+		if (mm_is_exiting(p)) {
 			if (p != current)
 				return ERR_PTR(-1UL);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
