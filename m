Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A011690010D
	for <linux-mm@kvack.org>; Sun, 15 May 2011 18:22:44 -0400 (EDT)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH v2 8/9] proc: make struct proc_maps_private truly private
Date: Sun, 15 May 2011 18:20:28 -0400
Message-Id: <1305498029-11677-9-git-send-email-wilsons@start.ca>
In-Reply-To: <1305498029-11677-1-git-send-email-wilsons@start.ca>
References: <1305498029-11677-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Stephen Wilson <wilsons@start.ca>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Alexey Dobriyan <adobriyan@gmail.com>, Christoph Lameter <cl@linux-foundation.org>

Now that mm/mempolicy.c is no longer implementing /proc/pid/numa_maps
there is no need to export struct proc_maps_private to the world.  Move
it to fs/proc/internal.h instead.

Signed-off-by: Stephen Wilson <wilsons@start.ca>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
---
 fs/proc/internal.h      |    7 +++++++
 include/linux/proc_fs.h |    8 --------
 2 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 96245a1..360223f 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -137,3 +137,10 @@ int proc_setattr(struct dentry *dentry, struct iattr *attr);
 extern const struct inode_operations proc_ns_dir_inode_operations;
 extern const struct file_operations proc_ns_dir_operations;
 
+struct proc_maps_private {
+	struct pid *pid;
+	struct task_struct *task;
+#ifdef CONFIG_MMU
+	struct vm_area_struct *tail_vma;
+#endif
+};
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 5bdfd39..6ba9e31 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -288,12 +288,4 @@ static inline struct net *PDE_NET(struct proc_dir_entry *pde)
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
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
