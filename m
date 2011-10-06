Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 3AABE6B02A4
	for <linux-mm@kvack.org>; Thu,  6 Oct 2011 12:29:56 -0400 (EDT)
Message-ID: <4E8DD64D.2010107@parallels.com>
Date: Thu, 06 Oct 2011 20:24:45 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH 5/5] slab_id: Show the task's mm ID in proc
References: <4E8DD5B9.4060905@parallels.com>
In-Reply-To: <4E8DD5B9.4060905@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
Cc: Glauber Costa <glommer@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>

This is just an example of how to use the slab IDs infrastructure.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 fs/proc/array.c    |   17 +++++++++++++++++
 fs/proc/base.c     |    6 ++++++
 fs/proc/internal.h |    2 ++
 kernel/fork.c      |    2 +-
 4 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/fs/proc/array.c b/fs/proc/array.c
index 3a1dafd..77eb2ba 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -357,6 +357,23 @@ int proc_pid_status(struct seq_file *m, struct pid_namespace *ns,
 	return 0;
 }
 
+#ifdef CONFIG_SLAB_OBJECT_IDS
+int proc_pid_objects(struct seq_file *m, struct pid_namespace *ns,
+		struct pid *pid, struct task_struct *task)
+{
+	u64 id[2];
+
+	task_lock(task);
+
+	k_object_id(task->mm, id);
+	seq_printf(m, "mm: %016Lx%016Lx\n", id[0], id[1]);
+
+	task_unlock(task);
+
+	return 0;
+}
+#endif
+
 static int do_task_stat(struct seq_file *m, struct pid_namespace *ns,
 			struct pid *pid, struct task_struct *task, int whole)
 {
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 5eb0206..4ffc31c 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2792,6 +2792,9 @@ static const struct pid_entry tgid_base_stuff[] = {
 #endif
 	REG("environ",    S_IRUSR, proc_environ_operations),
 	INF("auxv",       S_IRUSR, proc_pid_auxv),
+#ifdef CONFIG_SLAB_OBJECT_IDS
+	ONE("objects",    S_IRUGO, proc_pid_objects),
+#endif
 	ONE("status",     S_IRUGO, proc_pid_status),
 	ONE("personality", S_IRUGO, proc_pid_personality),
 	INF("limits",	  S_IRUGO, proc_pid_limits),
@@ -3141,6 +3144,9 @@ static const struct pid_entry tid_base_stuff[] = {
 	DIR("ns",	 S_IRUSR|S_IXUGO, proc_ns_dir_inode_operations, proc_ns_dir_operations),
 	REG("environ",   S_IRUSR, proc_environ_operations),
 	INF("auxv",      S_IRUSR, proc_pid_auxv),
+#ifdef CONFIG_SLAB_OBJECT_IDS
+	ONE("objects",    S_IRUGO, proc_pid_objects),
+#endif
 	ONE("status",    S_IRUGO, proc_pid_status),
 	ONE("personality", S_IRUGO, proc_pid_personality),
 	INF("limits",	 S_IRUGO, proc_pid_limits),
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 7838e5c..ac19d98 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -49,6 +49,8 @@ extern int proc_tgid_stat(struct seq_file *m, struct pid_namespace *ns,
 				struct pid *pid, struct task_struct *task);
 extern int proc_pid_status(struct seq_file *m, struct pid_namespace *ns,
 				struct pid *pid, struct task_struct *task);
+extern int proc_pid_objects(struct seq_file *m, struct pid_namespace *ns,
+				struct pid *pid, struct task_struct *task);
 extern int proc_pid_statm(struct seq_file *m, struct pid_namespace *ns,
 				struct pid *pid, struct task_struct *task);
 extern loff_t mem_lseek(struct file *file, loff_t offset, int orig);
diff --git a/kernel/fork.c b/kernel/fork.c
index 8e6b6f4..853e96e 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1597,7 +1597,7 @@ void __init proc_caches_init(void)
 	 */
 	mm_cachep = kmem_cache_create("mm_struct",
 			sizeof(struct mm_struct), ARCH_MIN_MMSTRUCT_ALIGN,
-			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_NOTRACK, NULL);
+			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_NOTRACK|SLAB_WANT_OBJIDS, NULL);
 	vm_area_cachep = KMEM_CACHE(vm_area_struct, SLAB_PANIC);
 	mmap_init();
 	nsproxy_cache_init();
-- 
1.5.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
