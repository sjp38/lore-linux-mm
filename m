Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id E9FF16B007E
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 00:08:17 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id vv3so101641911pab.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 21:08:17 -0700 (PDT)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id wg1si9172257pab.52.2016.04.27.21.08.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 21:08:17 -0700 (PDT)
Received: by mail-pf0-x22a.google.com with SMTP id c189so28644178pfb.3
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 21:08:17 -0700 (PDT)
Date: Thu, 28 Apr 2016 13:09:49 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/zswap: use workqueue to destroy pool
Message-ID: <20160428040949.GA529@swordfish>
References: <1461619210-10057-1-git-send-email-ddstreet@ieee.org>
 <1461704891-15272-1-git-send-email-ddstreet@ieee.org>
 <20160427005853.GD4782@swordfish>
 <CALZtONArGwmaWNcHJODmY1uXm306NiqeZtRekfCFgZsMz_cngw@mail.gmail.com>
 <20160428014028.GA594@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160428014028.GA594@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Dan Streetman <ddstreet@ieee.org>, Yu Zhao <yuzhao@google.com>, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@redhat.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Linux-MM <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <dan.streetman@canonical.com>

On (04/28/16 10:40), Sergey Senozhatsky wrote:
[..]
> the bigger issue here (and I was thinking at some point of fixing it,
> but then I grepped to see how many API users are in there, and I gave
> up) is that it seems we have no way to check if the dir exists in debugfs.

well, unless we want to do something like below. but I don't think Greg
will not buy it and the basic rule is to be careful in the driver code
and avoid any collisions.

---

 fs/debugfs/inode.c      | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/debugfs.h |  7 +++++++
 2 files changed, 55 insertions(+)

diff --git a/fs/debugfs/inode.c b/fs/debugfs/inode.c
index 8580831..76cf851 100644
--- a/fs/debugfs/inode.c
+++ b/fs/debugfs/inode.c
@@ -709,6 +709,54 @@ exit:
 EXPORT_SYMBOL_GPL(debugfs_rename);
 
 /**
+ * debugfs_entry_exists - lookup file/directory name
+ *
+ * @name: a pointer to a string containing the name of the file/directory
+ *        to lookup.
+ * @parent: a pointer to the parent dentry.  This should be a directory
+ *          dentry if set. If this parameter is NULL, then the root of the
+ *          debugfs filesystem will be used.
+ *
+ * This function lookup a file/directory name in debugfs. If the
+ * name corresponds to positive dentry, the function will return %0.
+ *
+ * If debugfs is not enabled in the kernel, the value -%ENODEV will be
+ * returned.
+ */
+int debugfs_entry_exists(const char *name, struct dentry *parent)
+{
+	struct dentry *dentry;
+	int error;
+
+	if (IS_ERR(parent))
+		return PTR_ERR(parent);
+
+	error = simple_pin_fs(&debug_fs_type, &debugfs_mount,
+			      &debugfs_mount_count);
+	if (error)
+		return error;
+
+	if (!parent)
+		parent = debugfs_mount->mnt_root;
+
+	error = -EINVAL;
+	inode_lock(d_inode(parent));
+	dentry = lookup_one_len(name, parent, strlen(name));
+	if (IS_ERR(dentry)) {
+		error = PTR_ERR(dentry);
+	} else {
+		if (d_really_is_positive(dentry))
+			error = 0;
+		dput(dentry);
+	}
+
+	inode_unlock(d_inode(parent));
+	simple_release_fs(&debugfs_mount, &debugfs_mount_count);
+	return error;
+}
+EXPORT_SYMBOL_GPL(debugfs_entry_exists);
+
+/**
  * debugfs_initialized - Tells whether debugfs has been registered
  */
 bool debugfs_initialized(void)
diff --git a/include/linux/debugfs.h b/include/linux/debugfs.h
index 981e53a..5b6321e 100644
--- a/include/linux/debugfs.h
+++ b/include/linux/debugfs.h
@@ -124,6 +124,8 @@ ssize_t debugfs_read_file_bool(struct file *file, char __user *user_buf,
 ssize_t debugfs_write_file_bool(struct file *file, const char __user *user_buf,
 				size_t count, loff_t *ppos);
 
+int debugfs_entry_exists(const char *name, struct dentry *parent);
+
 #else
 
 #include <linux/err.h>
@@ -312,6 +314,11 @@ static inline ssize_t debugfs_write_file_bool(struct file *file,
 	return -ENODEV;
 }
 
+static inline int debugfs_entry_exists(const char *name, struct dentry *parent)
+{
+	return -ENODEV;
+}
+
 #endif
 
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
