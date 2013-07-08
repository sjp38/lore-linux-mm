Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <51DA96BE.5080008@cn.fujitsu.com>
Date: Mon, 08 Jul 2013 18:38:54 +0800
From: Gu Zheng <guz.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 1/2] fs/anon_inode: Introduce a new lib function, anon_inode_getfile_private()
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Al Viro <viro@zeniv.linux.org.uk>, Benjamin <bcrl@kvack.org>
Cc: tangchen <tangchen@cn.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>

Introduce a new lib function anon_inode_getfile_private(), it creates a new file
instance by hooking it up to an anonymous inode, and a dentry that describe the
"class" of the file, similar to anon_inode_getfile(), but each file holds a
single inode. Furthermore, anyone who wants to create a private anon file will
benefit from this change.

Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 fs/anon_inodes.c            |   66 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/anon_inodes.h |    3 ++
 2 files changed, 69 insertions(+), 0 deletions(-)

diff --git a/fs/anon_inodes.c b/fs/anon_inodes.c
index 47a65df..85c9618 100644
--- a/fs/anon_inodes.c
+++ b/fs/anon_inodes.c
@@ -109,6 +109,72 @@ static struct file_system_type anon_inode_fs_type = {
 };

 /**
+ * anon_inode_getfile_private - creates a new file instance by hooking it up to an
+ *                      anonymous inode, and a dentry that describe the "class"
+ *                      of the file
+ *
+ * @name:    [in]    name of the "class" of the new file
+ * @fops:    [in]    file operations for the new file
+ * @priv:    [in]    private data for the new file (will be file's private_data)
+ * @flags:   [in]    flags
+ *
+ *
+ * Similar to anon_inode_getfile, but each file holds a single inode.
+ *
+ */
+struct file *anon_inode_getfile_private(const char *name,
+					const struct file_operations *fops,
+					void *priv, int flags)
+{
+	struct qstr this;
+	struct path path;
+	struct file *file;
+	struct inode *inode;
+
+	if (fops->owner && !try_module_get(fops->owner))
+		return ERR_PTR(-ENOENT);
+
+	inode = anon_inode_mkinode(anon_inode_mnt->mnt_sb);
+	if (IS_ERR(inode)) {
+		file = ERR_PTR(-ENOMEM);
+		goto err_module;
+	}
+
+	/*
+	 * Link the inode to a directory entry by creating a unique name
+	 * using the inode sequence number.
+	 */
+	file = ERR_PTR(-ENOMEM);
+	this.name = name;
+	this.len = strlen(name);
+	this.hash = 0;
+	path.dentry = d_alloc_pseudo(anon_inode_mnt->mnt_sb, &this);
+	if (!path.dentry)
+		goto err_module;
+
+	path.mnt = mntget(anon_inode_mnt);
+
+	d_instantiate(path.dentry, inode);
+
+	file = alloc_file(&path, OPEN_FMODE(flags), fops);
+	if (IS_ERR(file))
+		goto err_dput;
+
+	file->f_mapping = inode->i_mapping;
+	file->f_flags = flags & (O_ACCMODE | O_NONBLOCK);
+	file->private_data = priv;
+
+	return file;
+
+err_dput:
+	path_put(&path);
+err_module:
+	module_put(fops->owner);
+	return file;
+}
+EXPORT_SYMBOL_GPL(anon_inode_getfile_private);
+
+/**
  * anon_inode_getfile - creates a new file instance by hooking it up to an
  *                      anonymous inode, and a dentry that describe the "class"
  *                      of the file
diff --git a/include/linux/anon_inodes.h b/include/linux/anon_inodes.h
index 8013a45..cf573c2 100644
--- a/include/linux/anon_inodes.h
+++ b/include/linux/anon_inodes.h
@@ -13,6 +13,9 @@ struct file_operations;
 struct file *anon_inode_getfile(const char *name,
 				const struct file_operations *fops,
 				void *priv, int flags);
+struct file *anon_inode_getfile_private(const char *name,
+				const struct file_operations *fops,
+				void *priv, int flags);
 int anon_inode_getfd(const char *name, const struct file_operations *fops,
 		     void *priv, int flags);

-- 
1.7.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
