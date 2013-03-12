Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 4CC8A6B0039
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 03:38:57 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC v7 04/11] add proc/pid/vrange information
Date: Tue, 12 Mar 2013 16:38:28 +0900
Message-Id: <1363073915-25000-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1363073915-25000-1-git-send-email-minchan@kernel.org>
References: <1363073915-25000-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, John Stultz <john.stultz@linaro.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>

Add vrange per perocess information.
It would help debugging.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 fs/proc/base.c     |   1 +
 fs/proc/internal.h |   6 +++
 fs/proc/task_mmu.c | 129 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/vrange.c        |   2 +-
 4 files changed, 137 insertions(+), 1 deletion(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 69078c7..c1a8506 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2523,6 +2523,7 @@ static const struct pid_entry tgid_base_stuff[] = {
 	ONE("stat",       S_IRUGO, proc_tgid_stat),
 	ONE("statm",      S_IRUGO, proc_pid_statm),
 	REG("maps",       S_IRUGO, proc_pid_maps_operations),
+	REG("vrange",     S_IRUGO, proc_pid_vrange_operations),
 #ifdef CONFIG_NUMA
 	REG("numa_maps",  S_IRUGO, proc_pid_numa_maps_operations),
 #endif
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 85ff3a4..0584035 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -60,6 +60,7 @@ extern loff_t mem_lseek(struct file *file, loff_t offset, int orig);
 
 extern const struct file_operations proc_tid_children_operations;
 extern const struct file_operations proc_pid_maps_operations;
+extern const struct file_operations proc_pid_vrange_operations;
 extern const struct file_operations proc_tid_maps_operations;
 extern const struct file_operations proc_pid_numa_maps_operations;
 extern const struct file_operations proc_tid_numa_maps_operations;
@@ -82,6 +83,11 @@ struct proc_maps_private {
 #endif
 };
 
+struct proc_vrange_private {
+	struct pid *pid;
+	struct task_struct *task;
+};
+
 void proc_init_inodecache(void);
 
 static inline struct pid *proc_pid(struct inode *inode)
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 3e636d8..df009f0 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -11,6 +11,7 @@
 #include <linux/rmap.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/vrange.h>
 
 #include <asm/elf.h>
 #include <asm/uaccess.h>
@@ -370,6 +371,134 @@ static int show_tid_map(struct seq_file *m, void *v)
 	return show_map(m, v, 0);
 }
 
+static void *v_start(struct seq_file *m, loff_t *pos)
+{
+	struct vrange *range;
+	struct mm_struct *mm;
+	struct rb_root *root;
+	struct rb_node *next;
+	struct proc_vrange_private *priv = m->private;
+	loff_t n = *pos;
+
+	/* Clear the per syscall fields in priv */
+	priv->task = NULL;
+
+	priv->task = get_pid_task(priv->pid, PIDTYPE_PID);
+	if (!priv->task)
+		return ERR_PTR(-ESRCH);
+
+	mm = mm_access(priv->task, PTRACE_MODE_READ);
+	if (!mm || IS_ERR(mm))
+		return mm;
+
+	vrange_lock(mm);
+	root = &mm->v_rb;
+
+	if (RB_EMPTY_ROOT(&mm->v_rb))
+		goto out;
+
+	next = rb_first(&mm->v_rb);
+	range = vrange_entry(next);
+	while(n > 0 && range) {
+		n--;
+		next = rb_next(next);
+		if (next)
+			range = vrange_entry(next);
+		else
+			range = NULL;
+	}
+	if (!n)
+		return range;
+out:
+	return NULL;
+}
+
+static void *v_next(struct seq_file *m, void *v, loff_t *pos)
+{
+	struct vrange *range = v;
+	struct rb_node *next;
+
+	(*pos)++;
+	next = rb_next(&range->node.rb);
+	if (next) {
+		range = vrange_entry(next);
+		return range;
+	}
+	return NULL;
+}
+
+static void v_stop(struct seq_file *m, void *v)
+{
+	struct proc_vrange_private *priv = m->private;
+	if (priv->task) {
+		struct mm_struct *mm = priv->task->mm;
+		vrange_unlock(mm);
+		mmput(mm);
+		put_task_struct(priv->task);
+	}
+}
+
+static int show_vrange(struct seq_file *m, void *v, int is_pid)
+{
+
+	unsigned long start, end;
+	bool purged;
+	struct vrange *range = v;
+
+	start = range->node.start;
+	end = range->node.last;
+	purged = range->purged;
+
+	seq_printf(m, "%08lx-%08lx %c\n",
+			start,
+			end,
+			purged ? 'p' : 'v');
+	return 0;
+}
+
+static int show_vrange_map(struct seq_file *m, void *v)
+{
+	return show_vrange(m, v, 1);
+}
+
+static const struct seq_operations proc_pid_vrange_op = {
+	.start	= v_start,
+	.next	= v_next,
+	.stop	= v_stop,
+	.show	= show_vrange_map
+};
+
+static int do_vrange_open(struct inode *inode, struct file *file,
+		const struct seq_operations *ops)
+{
+	struct proc_vrange_private *priv;
+	int ret = -ENOMEM;
+	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
+	if (priv) {
+		priv->pid = proc_pid(inode);
+		ret = seq_open(file, ops);
+		if (!ret) {
+			struct seq_file *m = file->private_data;
+			m->private = priv;
+		} else {
+			kfree(priv);
+		}
+	}
+	return ret;
+}
+
+static int pid_vrange_open(struct inode *inode, struct file *file)
+{
+	return do_vrange_open(inode, file, &proc_pid_vrange_op);
+}
+
+const struct file_operations proc_pid_vrange_operations = {
+	.open		= pid_vrange_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release_private,
+};
+
 static const struct seq_operations proc_pid_maps_op = {
 	.start	= m_start,
 	.next	= m_next,
diff --git a/mm/vrange.c b/mm/vrange.c
index 2f77d89..f8b6f0e 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -199,7 +199,7 @@ SYSCALL_DEFINE4(vrange, unsigned long, start,
 	if (!len)
 		goto out;
 
-	end = start  len;
+	end = start + len;
 	if (end < start)
 		goto out;
 
-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
