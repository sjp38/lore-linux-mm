Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 517EF6B0022
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 19:37:56 -0400 (EDT)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH 7/8] proc: make struct proc_maps_private truly private
Date: Wed, 27 Apr 2011 19:35:48 -0400
Message-Id: <1303947349-3620-8-git-send-email-wilsons@start.ca>
In-Reply-To: <1303947349-3620-1-git-send-email-wilsons@start.ca>
References: <1303947349-3620-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Now that mm/mempolicy.c is no longer implementing /proc/pid/numa_maps
there is no need to export struct proc_maps_private to the world.  Move
it to fs/proc/internal.h instead.

Signed-off-by: Stephen Wilson <wilsons@start.ca>
---
 fs/proc/internal.h      |    8 ++++++++
 include/linux/proc_fs.h |    8 --------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index c03e8d3..3c39863 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -119,3 +119,11 @@ struct inode *proc_get_inode(struct super_block *, struct proc_dir_entry *);
  */
 int proc_readdir(struct file *, void *, filldir_t);
 struct dentry *proc_lookup(struct inode *, struct dentry *, struct nameidata *);
+
+struct proc_maps_private {
+	struct pid *pid;
+	struct task_struct *task;
+#ifdef CONFIG_MMU
+	struct vm_area_struct *tail_vma;
+#endif
+};
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 838c114..55ff594 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -286,12 +286,4 @@ static inline struct net *PDE_NET(struct proc_dir_entry *pde)
 	return pde->parent->data;
 }
 
-struct proc_maps_private {
-	struct pid *pid;
-	struct task_struct *task;
-#ifdef CONFIG_MMU
-	struct vm_area_struct *tail_vma;
-#endif
-};
-
 #endif /* _LINUX_PROC_FS_H */
-- 
1.7.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
