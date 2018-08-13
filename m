Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9AAFE6B0005
	for <linux-mm@kvack.org>; Mon, 13 Aug 2018 02:58:12 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id v14-v6so3044868lfe.9
        for <linux-mm@kvack.org>; Sun, 12 Aug 2018 23:58:12 -0700 (PDT)
Received: from forwardcorp1o.cmail.yandex.net (forwardcorp1o.cmail.yandex.net. [2a02:6b8:0:1a72::290])
        by mx.google.com with ESMTPS id z5-v6si8337469lje.386.2018.08.12.23.58.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Aug 2018 23:58:10 -0700 (PDT)
Subject: [PATCH RFC 1/3] cgroup: list all subsystem states in debugfs files
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Mon, 13 Aug 2018 09:58:05 +0300
Message-ID: <153414348591.737150.14229960913953276515.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>

After removing cgroup subsystem state could leak or live in background
forever because it is pinned by some reference. For example memory cgroup
could be pinned by pages in cache or tmpfs.

This patch adds common debugfs interface for listing basic state for each
controller. Controller could define callback for dumping own attributes.

In file /sys/kernel/debug/cgroup/<controller> each line shows state in
format: <common_attr>=<value>... [-- <controller_attr>=<value>... ]

Common attributes:

css - css pointer
cgroup - cgroup pointer
id - css id
ino - cgroup inode
flags - css flags
refcnt - css atomic refcount, for online shows huge bias
path - cgroup path

This patch adds memcg attributes:

mem_id - 16-bit memory cgroup id
memory - charged pages
swap - charged swap

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 include/linux/cgroup-defs.h |    1 
 kernel/cgroup/cgroup.c      |   99 +++++++++++++++++++++++++++++++++++++++++++
 mm/memcontrol.c             |   12 +++++
 3 files changed, 112 insertions(+)

diff --git a/include/linux/cgroup-defs.h b/include/linux/cgroup-defs.h
index c0e68f903011..c828820e160f 100644
--- a/include/linux/cgroup-defs.h
+++ b/include/linux/cgroup-defs.h
@@ -595,6 +595,7 @@ struct cgroup_subsys {
 	void (*exit)(struct task_struct *task);
 	void (*free)(struct task_struct *task);
 	void (*bind)(struct cgroup_subsys_state *root_css);
+	void (*css_dump)(struct cgroup_subsys_state *css, struct seq_file *);
 
 	bool early_init:1;
 
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index 077370bf8964..b7be190daffe 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -39,6 +39,7 @@
 #include <linux/mount.h>
 #include <linux/pagemap.h>
 #include <linux/proc_fs.h>
+#include <linux/debugfs.h>
 #include <linux/rcupdate.h>
 #include <linux/sched.h>
 #include <linux/sched/task.h>
@@ -5978,3 +5979,101 @@ static int __init cgroup_sysfs_init(void)
 }
 subsys_initcall(cgroup_sysfs_init);
 #endif /* CONFIG_SYSFS */
+
+#ifdef CONFIG_DEBUG_FS
+void *css_debugfs_seqfile_start(struct seq_file *m, loff_t *pos)
+{
+	struct cgroup_subsys *ss = m->private;
+	struct cgroup_subsys_state *css;
+	int id = *pos;
+
+	rcu_read_lock();
+	css = idr_get_next(&ss->css_idr, &id);
+	*pos = id;
+	return css;
+}
+
+void *css_debugfs_seqfile_next(struct seq_file *m, void *v, loff_t *pos)
+{
+	struct cgroup_subsys *ss = m->private;
+	struct cgroup_subsys_state *css;
+	int id = *pos + 1;
+
+	css = idr_get_next(&ss->css_idr, &id);
+	*pos = id;
+	return css;
+}
+
+void css_debugfs_seqfile_stop(struct seq_file *m, void *v)
+{
+	rcu_read_unlock();
+}
+
+int css_debugfs_seqfile_show(struct seq_file *m, void *v)
+{
+	struct cgroup_subsys *ss = m->private;
+	struct cgroup_subsys_state *css = v;
+	size_t buflen;
+	char *buf;
+	int len;
+
+	seq_printf(m, "css=%pK cgroup=%pK id=%d ino=%lu flags=%#x refcnt=%lu path=",
+		   css, css->cgroup, css->id, cgroup_ino(css->cgroup),
+		   css->flags, atomic_long_read(&css->refcnt.count));
+
+	buflen = seq_get_buf(m, &buf);
+	if (buf) {
+		len = cgroup_path(css->cgroup, buf, buflen);
+		seq_commit(m, len < buflen ? len : -1);
+	}
+
+	if (ss->css_dump) {
+		seq_puts(m, " -- ");
+		ss->css_dump(css, m);
+	}
+
+	seq_puts(m, "\n");
+	return 0;
+}
+
+static const struct seq_operations css_debug_seq_ops = {
+	.start = css_debugfs_seqfile_start,
+	.next = css_debugfs_seqfile_next,
+	.stop = css_debugfs_seqfile_stop,
+	.show = css_debugfs_seqfile_show,
+};
+
+static int css_debugfs_open(struct inode *inode, struct file *file)
+{
+	int ret = seq_open(file, &css_debug_seq_ops);
+	struct seq_file *m = file->private_data;
+
+	if (!ret)
+		m->private = inode->i_private;
+	return ret;
+}
+
+static const struct file_operations css_debugfs_fops = {
+	.open = css_debugfs_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = seq_release,
+};
+
+static int __init css_debugfs_init(void)
+{
+	struct cgroup_subsys *ss;
+	struct dentry *dir;
+	int ssid;
+
+	dir = debugfs_create_dir("cgroup", NULL);
+	if (dir) {
+		for_each_subsys(ss, ssid)
+			debugfs_create_file(ss->name, 0644, dir, ss,
+					    &css_debugfs_fops);
+	}
+
+	return 0;
+}
+late_initcall(css_debugfs_init);
+#endif /* CONFIG_DEBUG_FS */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b2173f7e5164..19a4348974a4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4345,6 +4345,17 @@ static void mem_cgroup_css_reset(struct cgroup_subsys_state *css)
 	memcg_wb_domain_size_changed(memcg);
 }
 
+static void mem_cgroup_css_dump(struct cgroup_subsys_state *css,
+				struct seq_file *m)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+
+	seq_printf(m, "mem_id=%u memory=%lu swap=%lu",
+		   mem_cgroup_id(memcg),
+		   page_counter_read(&memcg->memory),
+		   page_counter_read(&memcg->swap));
+}
+
 #ifdef CONFIG_MMU
 /* Handlers for move charge at task migration. */
 static int mem_cgroup_do_precharge(unsigned long count)
@@ -5386,6 +5397,7 @@ struct cgroup_subsys memory_cgrp_subsys = {
 	.css_released = mem_cgroup_css_released,
 	.css_free = mem_cgroup_css_free,
 	.css_reset = mem_cgroup_css_reset,
+	.css_dump = mem_cgroup_css_dump,
 	.can_attach = mem_cgroup_can_attach,
 	.cancel_attach = mem_cgroup_cancel_attach,
 	.post_attach = mem_cgroup_move_task,
