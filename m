Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E558E8D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 10:50:22 -0400 (EDT)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH v2 resend 10/12] proc: hold cred_guard_mutex in check_mem_permission()
Date: Wed, 23 Mar 2011 10:43:59 -0400
Message-Id: <1300891441-16280-11-git-send-email-wilsons@start.ca>
In-Reply-To: <1300891441-16280-1-git-send-email-wilsons@start.ca>
References: <1300891441-16280-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michel Lespinasse <walken@google.com>, Andi Kleen <ak@linux.intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Stephen Wilson <wilsons@start.ca>

Avoid a potential race when task exec's and we get a new ->mm but check against
the old credentials in ptrace_may_access().

Holding of the mutex is implemented by factoring out the body of the code into a
helper function __check_mem_permission().  Performing this factorization now
simplifies upcoming changes and minimizes churn in the diff's.

Signed-off-by: Stephen Wilson <wilsons@start.ca>
---
 fs/proc/base.c |   26 ++++++++++++++++++++++----
 1 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 13c5e8c..084d046 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -191,10 +191,7 @@ static int proc_root_link(struct inode *inode, struct path *path)
 	return result;
 }
 
-/*
- * Return zero if current may access user memory in @task, -error if not.
- */
-static int check_mem_permission(struct task_struct *task)
+static int __check_mem_permission(struct task_struct *task)
 {
 	/*
 	 * A task can always look at itself, in case it chooses
@@ -222,6 +219,27 @@ static int check_mem_permission(struct task_struct *task)
 	return -EPERM;
 }
 
+/*
+ * Return zero if current may access user memory in @task, -error if not.
+ */
+static int check_mem_permission(struct task_struct *task)
+{
+	int err;
+
+	/*
+	 * Avoid racing if task exec's as we might get a new mm but validate
+	 * against old credentials.
+	 */
+	err = mutex_lock_killable(&task->signal->cred_guard_mutex);
+	if (err)
+		return err;
+
+	err = __check_mem_permission(task);
+	mutex_unlock(&task->signal->cred_guard_mutex);
+
+	return err;
+}
+
 struct mm_struct *mm_for_maps(struct task_struct *task)
 {
 	struct mm_struct *mm;
-- 
1.7.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
