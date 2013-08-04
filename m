Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 7C8556B0034
	for <linux-mm@kvack.org>; Sun,  4 Aug 2013 12:07:37 -0400 (EDT)
Received: by mail-qe0-f54.google.com with SMTP id 1so1261158qee.41
        for <linux-mm@kvack.org>; Sun, 04 Aug 2013 09:07:36 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 2/5] cgroup: export __cgroup_from_dentry() and __cgroup_dput()
Date: Sun,  4 Aug 2013 12:07:23 -0400
Message-Id: <1375632446-2581-3-git-send-email-tj@kernel.org>
In-Reply-To: <1375632446-2581-1-git-send-email-tj@kernel.org>
References: <1375632446-2581-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com, hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>

cgroup_event will no longer be supported as cgroup generic mechanism
and be moved to memcg.  To enable the relocation, implement and export
__cgroup_from_dentry() which combines cgroup file dentry -> croup
mapping and cft discovery, and prefix cgroup_dput() with __ and export
it.

These functions exist and are exported only to enable moving
cgroup_event implementation to memcg and shouldn't grow any new users
and thus the __ prefix.

This patch is pure reorganization and doesn't introduce any functional
difference.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 include/linux/cgroup.h |  4 ++++
 kernel/cgroup.c        | 31 +++++++++++++++++--------------
 2 files changed, 21 insertions(+), 14 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 30d6ec4..2ac1021 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -923,6 +923,10 @@ bool css_is_ancestor(struct cgroup_subsys_state *cg,
 unsigned short css_id(struct cgroup_subsys_state *css);
 struct cgroup_subsys_state *cgroup_css_from_dir(struct file *f, int id);
 
+/* do not add new users of the following two functions */
+struct cgroup *__cgroup_from_dentry(struct dentry *dentry, struct cftype **cftp);
+void __cgroup_dput(struct cgroup *cgrp);
+
 #else /* !CONFIG_CGROUPS */
 
 static inline int cgroup_init_early(void) { return 0; }
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 1b87e2b..2583b7b 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2661,15 +2661,18 @@ static struct dentry *cgroup_lookup(struct inode *dir, struct dentry *dentry, un
 	return NULL;
 }
 
-/*
- * Check if a file is a control file
- */
-static inline struct cftype *__file_cft(struct file *file)
+/* do not add new users */
+struct cgroup *__cgroup_from_dentry(struct dentry *dentry, struct cftype **cftp)
 {
-	if (file_inode(file)->i_fop != &cgroup_file_operations)
-		return ERR_PTR(-EINVAL);
-	return __d_cft(file->f_dentry);
+	if (!dentry->d_inode ||
+	    dentry->d_inode->i_op != &cgroup_file_inode_operations)
+		return NULL;
+
+	if (cftp)
+		*cftp = __d_cft(dentry);
+	return __d_cgrp(dentry->d_parent);
 }
+EXPORT_SYMBOL_GPL(__cgroup_from_dentry);
 
 static int cgroup_create_file(struct dentry *dentry, umode_t mode,
 				struct super_block *sb)
@@ -3953,7 +3956,7 @@ static int cgroup_write_notify_on_release(struct cgroup_subsys_state *css,
  *
  * That's why we hold a reference before dput() and drop it right after.
  */
-static void cgroup_dput(struct cgroup *cgrp)
+void __cgroup_dput(struct cgroup *cgrp)
 {
 	struct super_block *sb = cgrp->root->sb;
 
@@ -3961,6 +3964,7 @@ static void cgroup_dput(struct cgroup *cgrp)
 	dput(cgrp->dentry);
 	deactivate_super(sb);
 }
+EXPORT_SYMBOL_GPL(__cgroup_dput);
 
 /*
  * Unregister event and free resources.
@@ -3983,7 +3987,7 @@ static void cgroup_event_remove(struct work_struct *work)
 
 	eventfd_ctx_put(event->eventfd);
 	kfree(event);
-	cgroup_dput(cgrp);
+	__cgroup_dput(cgrp);
 }
 
 /*
@@ -4095,9 +4099,9 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *css,
 	if (ret < 0)
 		goto out_put_cfile;
 
-	event->cft = __file_cft(cfile);
-	if (IS_ERR(event->cft)) {
-		ret = PTR_ERR(event->cft);
+	cgrp_cfile = __cgroup_from_dentry(cfile->f_dentry, &event->cft);
+	if (!cgrp_cfile) {
+		ret = -EINVAL;
 		goto out_put_cfile;
 	}
 
@@ -4105,7 +4109,6 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *css,
 	 * The file to be monitored must be in the same cgroup as
 	 * cgroup.event_control is.
 	 */
-	cgrp_cfile = __d_cgrp(cfile->f_dentry->d_parent);
 	if (cgrp_cfile != cgrp) {
 		ret = -EINVAL;
 		goto out_put_cfile;
@@ -4272,7 +4275,7 @@ static void css_dput_fn(struct work_struct *work)
 	struct cgroup_subsys_state *css =
 		container_of(work, struct cgroup_subsys_state, dput_work);
 
-	cgroup_dput(css->cgroup);
+	__cgroup_dput(css->cgroup);
 }
 
 static void css_release(struct percpu_ref *ref)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
