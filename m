Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 0D8056B0070
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 22:49:36 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so186598pad.22
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 19:49:36 -0700 (PDT)
Received: from relay.sgi.com (relay2.sgi.com. [192.48.180.65])
        by mx.google.com with ESMTP id e10si456074pdo.79.2014.10.22.19.49.34
        for <linux-mm@kvack.org>;
        Wed, 22 Oct 2014 19:49:35 -0700 (PDT)
From: Alex Thorlton <athorlton@sgi.com>
Subject: [PATCH 4/4] Add /proc files to expose per-mm pgcollapse stats
Date: Wed, 22 Oct 2014 21:49:27 -0500
Message-Id: <1414032567-109765-5-git-send-email-athorlton@sgi.com>
In-Reply-To: <1414032567-109765-1-git-send-email-athorlton@sgi.com>
References: <1414032567-109765-1-git-send-email-athorlton@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, athorlton@sgi.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>, David Rientjes <rientjes@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, Kees Cook <keescook@chromium.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Vladimir Davydov <vdavydov@parallels.com>, linux-kernel@vger.kernel.org

This patch adds a /proc file to read out the information that we've added to the
task_struct.  I'll need to split the information out to separate files, probably
in a subdirectory, change a few of the files to allow us to modify their values,
and it will need appropriate locks.

Signed-off-by: Alex Thorlton <athorlton@sgi.com>
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
 fs/proc/base.c | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 772efa4..7c5aca2 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2466,6 +2466,25 @@ static const struct file_operations proc_projid_map_operations = {
 };
 #endif /* CONFIG_USER_NS */
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+int proc_pgcollapse_show(struct seq_file *m, struct pid_namespace *ns,
+		     struct pid *pid, struct task_struct *tsk)
+{
+	/* need locks here */
+	seq_printf(m, "pages_to_scan: %u\n", tsk->pgcollapse_pages_to_scan);
+	seq_printf(m, "pages_collapsed: %u\n", tsk->pgcollapse_pages_collapsed);
+	seq_printf(m, "full_scans: %u\n", tsk->pgcollapse_full_scans);
+	seq_printf(m, "scan_sleep_millisecs: %u\n",
+		   tsk->pgcollapse_scan_sleep_millisecs);
+	seq_printf(m, "alloc_sleep_millisecs: %u\n", 
+		   tsk->pgcollapse_alloc_sleep_millisecs);
+	seq_printf(m, "last_scan: %lu\n", tsk->pgcollapse_last_scan);
+	seq_printf(m, "scan_address: 0x%0lx\n", tsk->pgcollapse_scan_address);
+
+	return 0;
+}
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+
 static int proc_pid_personality(struct seq_file *m, struct pid_namespace *ns,
 				struct pid *pid, struct task_struct *task)
 {
@@ -2576,6 +2595,9 @@ static const struct pid_entry tgid_base_stuff[] = {
 #ifdef CONFIG_CHECKPOINT_RESTORE
 	REG("timers",	  S_IRUGO, proc_timers_operations),
 #endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	ONE("pgcollapse", S_IRUGO, proc_pgcollapse_show),
+#endif
 };
 
 static int proc_tgid_base_readdir(struct file *file, struct dir_context *ctx)
@@ -2914,6 +2936,9 @@ static const struct pid_entry tid_base_stuff[] = {
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
