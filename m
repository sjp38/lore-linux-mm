Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4698E8E0002
	for <linux-mm@kvack.org>; Sat, 19 Jan 2019 22:31:12 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id s22so11600741pgv.8
        for <linux-mm@kvack.org>; Sat, 19 Jan 2019 19:31:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l30sor12519399plg.17.2019.01.19.19.31.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 19 Jan 2019 19:31:10 -0800 (PST)
From: Xiongchun Duan <duanxiongchun@bytedance.com>
Subject: [PATCH 5/5] Memcgroup:add cgroup fs to show offline memcgroup status
Date: Sat, 19 Jan 2019 22:30:21 -0500
Message-Id: <1547955021-11520-6-git-send-email-duanxiongchun@bytedance.com>
In-Reply-To: <1547955021-11520-1-git-send-email-duanxiongchun@bytedance.com>
References: <1547955021-11520-1-git-send-email-duanxiongchun@bytedance.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: shy828301@gmail.com, mhocko@kernel.org, tj@kernel.org, hannes@cmpxchg.org, zhangyongsu@bytedance.com, liuxiaozhou@bytedance.com, zhengfeiran@bytedance.com, wangdongdong.6@bytedance.com, Xiongchun Duan <duanxiongchun@bytedance.com>

Add cgroups_wait_empty proc file to show wait force empty memcgroup Add
cgroup_empty_fail file to show memcgroup which had try many time still did
not release. you can echo 0 > /proc/cgroup_empty_fail to manualy trigger
force empty this memcgroup

Signed-off-by: Xiongchun Duan <duanxiongchun@bytedance.com>
---
 mm/memcontrol.c | 140 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 140 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 21b4432..1529549 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -57,6 +57,7 @@
 #include <linux/sort.h>
 #include <linux/fs.h>
 #include <linux/seq_file.h>
+#include <linux/proc_fs.h>
 #include <linux/vmpressure.h>
 #include <linux/mm_inline.h>
 #include <linux/swap_cgroup.h>
@@ -6440,6 +6441,140 @@ void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 	refill_stock(memcg, nr_pages);
 }
 
+#ifdef CONFIG_PROC_FS
+static void print_memcg_header(struct seq_file *m)
+{
+	seq_puts(m, "address,css_ref,mem_ref,current_retry,max_retry\n");
+}
+
+static void memcgroup_show(struct mem_cgroup *memcg,
+		struct seq_file *m, bool header)
+{
+	if (header)
+		print_memcg_header(m);
+	seq_printf(m, "%p,%lu,%lu,%d,%d\n", memcg,
+			atomic_long_read(&memcg->css.refcnt.count),
+			page_counter_read(&memcg->memory),
+			memcg->current_retry, memcg->max_retry);
+}
+
+void *fail_start(struct seq_file *m, loff_t *pos)
+{
+	mutex_lock(&offline_cgroup_mutex);
+	return seq_list_start(&empty_fail_list, *pos);
+}
+
+void *fail_next(struct seq_file *m, void *p, loff_t *pos)
+{
+	return seq_list_next(p, &empty_fail_list, pos);
+}
+
+void fail_stop(struct seq_file *m, void *p)
+{
+	mutex_unlock(&offline_cgroup_mutex);
+}
+
+static int fail_show(struct seq_file *m, void *p)
+{
+	struct mem_cgroup *memcg = list_entry(p, struct mem_cgroup,
+			empty_fail_node);
+	if (p == empty_fail_list.next)
+		memcgroup_show(memcg, m, true);
+	else
+		memcgroup_show(memcg, m, false);
+
+	return 0;
+}
+
+static const struct seq_operations fail_list_op = {
+	.start = fail_start,
+	.next = fail_next,
+	.stop = fail_stop,
+	.show = fail_show,
+};
+
+static int fail_list_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &fail_list_op);
+}
+
+ssize_t fail_list_write(struct file *file, const char __user *buffer,
+	size_t count, loff_t *ppos)
+{
+	struct list_head *pos, *n;
+	struct mem_cgroup *memcg;
+
+	mutex_lock(&offline_cgroup_mutex);
+	list_for_each_safe(pos, n, &empty_fail_list) {
+		memcg = container_of(pos, struct mem_cgroup, empty_fail_node);
+		if (atomic_long_add_unless(&memcg->css.refcnt.count,
+					1, 0) == 0) {
+			continue;
+		} else if (!queue_work(memcg_force_empty_wq,
+					&memcg->force_empty_work)) {
+			css_put(&memcg->css);
+		}
+	}
+	mutex_unlock(&offline_cgroup_mutex);
+	return count;
+}
+
+static const struct file_operations proc_fail_list_operations = {
+	.open = fail_list_open,
+	.read = seq_read,
+	.write = fail_list_write,
+	.llseek = seq_lseek,
+	.release = seq_release,
+};
+
+void *empty_start(struct seq_file *m, loff_t *pos)
+{
+	mutex_lock(&offline_cgroup_mutex);
+	return seq_list_start(&force_empty_list, *pos);
+}
+
+void *empty_next(struct seq_file *m, void *p, loff_t *pos)
+{
+	return seq_list_next(p, &force_empty_list, pos);
+}
+
+void empty_stop(struct seq_file *m, void *p)
+{
+	mutex_unlock(&offline_cgroup_mutex);
+}
+
+static int empty_show(struct seq_file *m, void *p)
+{
+	struct mem_cgroup *memcg = list_entry(p,
+			struct mem_cgroup, force_empty_node);
+	if (p == force_empty_list.next)
+		memcgroup_show(memcg, m, true);
+	else
+		memcgroup_show(memcg, m, false);
+
+	return 0;
+}
+
+static const struct seq_operations empty_list_op = {
+	.start = empty_start,
+	.next = empty_next,
+	.stop = empty_stop,
+	.show = empty_show,
+};
+
+static int empty_list_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &empty_list_op);
+}
+
+static const struct file_operations proc_empty_list_operations = {
+	.open = empty_list_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = seq_release,
+};
+#endif
+
 static int __init cgroup_memory(char *s)
 {
 	char *token;
@@ -6483,6 +6618,11 @@ static int __init mem_cgroup_init(void)
 	INIT_WORK(&timer_poll_work, trigger_force_empty);
 	timer_setup(&empty_trigger, empty_timer_trigger, 0);
 
+#ifdef CONFIG_PROC_FS
+	proc_create("cgroups_wait_empty", 0, NULL, &proc_empty_list_operations);
+	proc_create("cgroups_empty_fail", 0, NULL, &proc_fail_list_operations);
+#endif
+
 	cpuhp_setup_state_nocalls(CPUHP_MM_MEMCQ_DEAD, "mm/memctrl:dead", NULL,
 				  memcg_hotplug_cpu_dead);
 
-- 
1.8.3.1
