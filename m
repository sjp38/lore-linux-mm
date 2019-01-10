Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 831DB8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 17:08:03 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id 202so7156413pgb.6
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 14:08:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 30sor547374pgz.10.2019.01.10.14.08.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 14:08:02 -0800 (PST)
From: Suren Baghdasaryan <surenb@google.com>
Subject: [PATCH v2 1/5] fs: kernfs: add poll file operation
Date: Thu, 10 Jan 2019 14:07:14 -0800
Message-Id: <20190110220718.261134-2-surenb@google.com>
In-Reply-To: <20190110220718.261134-1-surenb@google.com>
References: <20190110220718.261134-1-surenb@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org
Cc: tj@kernel.org, lizefan@huawei.com, hannes@cmpxchg.org, axboe@kernel.dk, dennis@kernel.org, dennisszhou@gmail.com, mingo@redhat.com, peterz@infradead.org, akpm@linux-foundation.org, corbet@lwn.net, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@android.com, Suren Baghdasaryan <surenb@google.com>

From: Johannes Weiner <hannes@cmpxchg.org>

Kernfs has a standardized poll/notification mechanism for waking all
pollers on all fds when a filesystem node changes. To allow polling
for custom events, add a .poll callback that can override the default.

This is in preparation for pollable cgroup pressure files which have
per-fd trigger configurations.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Suren Baghdasaryan <surenb@google.com>
---
 fs/kernfs/file.c       | 31 ++++++++++++++++++++-----------
 include/linux/kernfs.h |  6 ++++++
 2 files changed, 26 insertions(+), 11 deletions(-)

diff --git a/fs/kernfs/file.c b/fs/kernfs/file.c
index dbf5bc250bfd..2d8b91f4475d 100644
--- a/fs/kernfs/file.c
+++ b/fs/kernfs/file.c
@@ -832,26 +832,35 @@ void kernfs_drain_open_files(struct kernfs_node *kn)
  * to see if it supports poll (Neither 'poll' nor 'select' return
  * an appropriate error code).  When in doubt, set a suitable timeout value.
  */
+__poll_t kernfs_generic_poll(struct kernfs_open_file *of, poll_table *wait)
+{
+	struct kernfs_node *kn = kernfs_dentry_node(of->file->f_path.dentry);
+	struct kernfs_open_node *on = kn->attr.open;
+
+	poll_wait(of->file, &on->poll, wait);
+
+	if (of->event != atomic_read(&on->event))
+		return DEFAULT_POLLMASK|EPOLLERR|EPOLLPRI;
+
+	return DEFAULT_POLLMASK;
+}
+
 static __poll_t kernfs_fop_poll(struct file *filp, poll_table *wait)
 {
 	struct kernfs_open_file *of = kernfs_of(filp);
 	struct kernfs_node *kn = kernfs_dentry_node(filp->f_path.dentry);
-	struct kernfs_open_node *on = kn->attr.open;
+	__poll_t ret;
 
 	if (!kernfs_get_active(kn))
-		goto trigger;
+		return DEFAULT_POLLMASK|EPOLLERR|EPOLLPRI;
 
-	poll_wait(filp, &on->poll, wait);
+	if (kn->attr.ops->poll)
+		ret = kn->attr.ops->poll(of, wait);
+	else
+		ret = kernfs_generic_poll(of, wait);
 
 	kernfs_put_active(kn);
-
-	if (of->event != atomic_read(&on->event))
-		goto trigger;
-
-	return DEFAULT_POLLMASK;
-
- trigger:
-	return DEFAULT_POLLMASK|EPOLLERR|EPOLLPRI;
+	return ret;
 }
 
 static void kernfs_notify_workfn(struct work_struct *work)
diff --git a/include/linux/kernfs.h b/include/linux/kernfs.h
index 5b36b1287a5a..0cac1207bb00 100644
--- a/include/linux/kernfs.h
+++ b/include/linux/kernfs.h
@@ -25,6 +25,7 @@ struct seq_file;
 struct vm_area_struct;
 struct super_block;
 struct file_system_type;
+struct poll_table_struct;
 
 struct kernfs_open_node;
 struct kernfs_iattrs;
@@ -261,6 +262,9 @@ struct kernfs_ops {
 	ssize_t (*write)(struct kernfs_open_file *of, char *buf, size_t bytes,
 			 loff_t off);
 
+	__poll_t (*poll)(struct kernfs_open_file *of,
+			 struct poll_table_struct *pt);
+
 	int (*mmap)(struct kernfs_open_file *of, struct vm_area_struct *vma);
 
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
@@ -350,6 +354,8 @@ int kernfs_remove_by_name_ns(struct kernfs_node *parent, const char *name,
 int kernfs_rename_ns(struct kernfs_node *kn, struct kernfs_node *new_parent,
 		     const char *new_name, const void *new_ns);
 int kernfs_setattr(struct kernfs_node *kn, const struct iattr *iattr);
+__poll_t kernfs_generic_poll(struct kernfs_open_file *of,
+			     struct poll_table_struct *pt);
 void kernfs_notify(struct kernfs_node *kn);
 
 const void *kernfs_super_ns(struct super_block *sb);
-- 
2.20.1.97.g81188d93c3-goog
