Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4E8946B0069
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 23:07:02 -0400 (EDT)
Received: by mail-ie0-f170.google.com with SMTP id tp5so175571ieb.15
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 20:07:02 -0700 (PDT)
Received: from relay.sgi.com (relay3.sgi.com. [192.48.152.1])
        by mx.google.com with ESMTP id f3si1100053ice.21.2014.10.22.20.07.01
        for <linux-mm@kvack.org>;
        Wed, 22 Oct 2014 20:07:01 -0700 (PDT)
From: Alex Thorlton <athorlton@sgi.com>
Subject: [PATCH 2/2] Add /proc files to expose per-mm pgcollapse stats
Date: Wed, 22 Oct 2014 22:06:26 -0500
Message-Id: <1414033586-185593-2-git-send-email-athorlton@sgi.com>
In-Reply-To: <1414032567-109765-1-git-send-email-athorlton@sgi.com>
References: <1414032567-109765-1-git-send-email-athorlton@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Alex Thorlton <athorlton@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>, David Rientjes <rientjes@google.com>, "Eric W . Biederman" <ebiederm@xmission.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, Kees Cook <keescook@chromium.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Vladimir Davydov <vdavydov@parallels.com>, linux-kernel@vger.kernel.org

Just add a proc file to expose the stat counter I added.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Bob Liu <lliubbo@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org

---
 fs/proc/base.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 772efa4..7517bf4 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2466,6 +2466,16 @@ static const struct file_operations proc_projid_map_operations = {
 };
 #endif /* CONFIG_USER_NS */
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+int proc_pgcollapse_show(struct seq_file *m, struct pid_namespace *ns,
+		     struct pid *pid, struct task_struct *tsk)
+{
+	seq_printf(m, "pages_collapsed: %u\n", tsk->pgcollapse_pages_collapsed);
+
+	return 0;
+}
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+
 static int proc_pid_personality(struct seq_file *m, struct pid_namespace *ns,
 				struct pid *pid, struct task_struct *task)
 {
@@ -2576,6 +2586,9 @@ static const struct pid_entry tgid_base_stuff[] = {
 #ifdef CONFIG_CHECKPOINT_RESTORE
 	REG("timers",	  S_IRUGO, proc_timers_operations),
 #endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	ONE("pgcollapse", S_IRUGO, proc_pgcollapse_show),
+#endif
 };
 
 static int proc_tgid_base_readdir(struct file *file, struct dir_context *ctx)
@@ -2914,6 +2927,9 @@ static const struct pid_entry tid_base_stuff[] = {
 	REG("gid_map",    S_IRUGO|S_IWUSR, proc_gid_map_operations),
 	REG("projid_map", S_IRUGO|S_IWUSR, proc_projid_map_operations),
 #endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	ONE("pgcollapse", S_IRUGO, proc_pgcollapse_show),
+#endif
 };
 
 static int proc_tid_base_readdir(struct file *file, struct dir_context *ctx)
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
