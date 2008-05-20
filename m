Date: Tue, 20 May 2008 18:08:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/3] memcg:: seq_ops support for cgroup
Message-Id: <20080520180841.f292beef.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080520180552.601da567.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080520180552.601da567.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

Does anyone have a better idea ?
==
 
Currently, cgroup's seq_file interface just supports single_open.
This patch allows arbitrary seq_ops if passed.

For example, "status per cpu, status per node" can be very big
in general and they tend to use its own start/next/stop ops.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---
 include/linux/cgroup.h |    9 +++++++++
 kernel/cgroup.c        |   32 +++++++++++++++++++++++++++++---
 2 files changed, 38 insertions(+), 3 deletions(-)

Index: mm-2.6.26-rc2-mm1/include/linux/cgroup.h
===================================================================
--- mm-2.6.26-rc2-mm1.orig/include/linux/cgroup.h
+++ mm-2.6.26-rc2-mm1/include/linux/cgroup.h
@@ -232,6 +232,11 @@ struct cftype {
 	 */
 	int (*read_seq_string) (struct cgroup *cont, struct cftype *cft,
 			 struct seq_file *m);
+	/*
+	 * If this is not NULL, read ops will use this instead of
+	 * single_open(). Useful for showing very large data.
+	 */
+	struct seq_operations *seq_ops;
 
 	ssize_t (*write) (struct cgroup *cgrp, struct cftype *cft,
 			  struct file *file,
@@ -285,6 +290,10 @@ int cgroup_path(const struct cgroup *cgr
 
 int cgroup_task_count(const struct cgroup *cgrp);
 
+
+struct cgroup *cgroup_of_seqfile(struct seq_file *m);
+struct cftype *cftype_of_seqfile(struct seq_file *m);
+
 /* Return true if the cgroup is a descendant of the current cgroup */
 int cgroup_is_descendant(const struct cgroup *cgrp);
 
Index: mm-2.6.26-rc2-mm1/kernel/cgroup.c
===================================================================
--- mm-2.6.26-rc2-mm1.orig/kernel/cgroup.c
+++ mm-2.6.26-rc2-mm1/kernel/cgroup.c
@@ -1540,6 +1540,16 @@ struct cgroup_seqfile_state {
 	struct cgroup *cgroup;
 };
 
+struct cgroup *cgroup_of_seqfile(struct seq_file *m)
+{
+	return ((struct cgroup_seqfile_state *)m->private)->cgroup;
+}
+
+struct cftype *cftype_of_seqfile(struct seq_file *m)
+{
+	return  ((struct cgroup_seqfile_state *)m->private)->cft;
+}
+
 static int cgroup_map_add(struct cgroup_map_cb *cb, const char *key, u64 value)
 {
 	struct seq_file *sf = cb->state;
@@ -1563,8 +1573,14 @@ static int cgroup_seqfile_show(struct se
 static int cgroup_seqfile_release(struct inode *inode, struct file *file)
 {
 	struct seq_file *seq = file->private_data;
+	struct cgroup_seqfile_state *state = seq->private;
+	struct cftype *cft = state->cft;
+
 	kfree(seq->private);
-	return single_release(inode, file);
+	if (!cft->seq_ops)
+		return single_release(inode, file);
+	else
+		return seq_release(inode, file);
 }
 
 static struct file_operations cgroup_seqfile_operations = {
@@ -1585,7 +1601,7 @@ static int cgroup_file_open(struct inode
 	cft = __d_cft(file->f_dentry);
 	if (!cft)
 		return -ENODEV;
-	if (cft->read_map || cft->read_seq_string) {
+	if (cft->read_map || cft->read_seq_string || cft->seq_ops) {
 		struct cgroup_seqfile_state *state =
 			kzalloc(sizeof(*state), GFP_USER);
 		if (!state)
@@ -1593,7 +1609,17 @@ static int cgroup_file_open(struct inode
 		state->cft = cft;
 		state->cgroup = __d_cgrp(file->f_dentry->d_parent);
 		file->f_op = &cgroup_seqfile_operations;
-		err = single_open(file, cgroup_seqfile_show, state);
+
+		if (!cft->seq_ops)
+			err = single_open(file, cgroup_seqfile_show, state);
+		else {
+			err = seq_open(file, cft->seq_ops);
+			if (!err) {
+				struct seq_file *sf;
+				sf = ((struct seq_file *)file->private_data);
+				sf->private = state;
+			}
+		}
 		if (err < 0)
 			kfree(state);
 	} else if (cft->open)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
