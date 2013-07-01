Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 425DD6B0068
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 07:58:21 -0400 (EDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC 13/13] mm: shmem: enable saving to PRAM
Date: Mon, 1 Jul 2013 15:57:48 +0400
Message-ID: <b01def5f38aa0eb44a7291230e035755aa035613.1372582756.git.vdavydov@parallels.com>
In-Reply-To: <cover.1372582754.git.vdavydov@parallels.com>
References: <cover.1372582754.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, criu@openvz.org, devel@openvz.org, xemul@parallels.com, khorenko@parallels.com

This patch illustrates how PRAM API can be used for making tmpfs
'persistent'. It adds 'pram=' option to tmpfs, which specifies the PRAM
node to load/save FS tree from/to.

If the option is passed on mount, shmem will look for the corresponding
PRAM node and load the FS tree from it. On the subsequent unmount, it
will save FS tree to that PRAM node.

A typical usage scenario looks like:

 # mount -t tmpfs -o pram=mytmpfs none /mnt
 # echo something > /mnt/smth
 # umount /mnt
 <possibly kexec>
 # mount -t tmpfs -o pram=mytmpfs none /mnt
 # cat /mnt/smth

Each FS tree is saved into two PRAM nodes, one acting as a byte stream
and the other acting as a page stream. The byte stream is used for
saving files metadata (name, permissions, etc) and data page offsets
while the page stream accommodates file content pages.

Current implementation serves for demonstration purposes and so is quite
simplified: it supports only regular files in the root directory without
multiple hard links, and it does not save swapped out files aborting if
any. However, it can be elaborated to fully support tmpfs.
---
 include/linux/shmem_fs.h |   26 ++++
 mm/Makefile              |    2 +-
 mm/shmem.c               |   29 +++-
 mm/shmem_pram.c          |  378 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 430 insertions(+), 5 deletions(-)
 create mode 100644 mm/shmem_pram.c

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index da63308..0408421 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -23,6 +23,11 @@ struct shmem_inode_info {
 	struct inode		vfs_inode;
 };
 
+#define SHMEM_PRAM_NAME_MAX	128
+struct shmem_pram_info {
+	char name[SHMEM_PRAM_NAME_MAX];
+};
+
 struct shmem_sb_info {
 	unsigned long max_blocks;   /* How many blocks are allowed */
 	struct percpu_counter used_blocks;  /* How many are allocated */
@@ -33,6 +38,7 @@ struct shmem_sb_info {
 	kgid_t gid;		    /* Mount gid for root directory */
 	umode_t mode;		    /* Mount mode for root directory */
 	struct mempolicy *mpol;     /* default memory policy for mappings */
+	struct shmem_pram_info *pram;
 };
 
 static inline struct shmem_inode_info *SHMEM_I(struct inode *inode)
@@ -62,7 +68,27 @@ static inline struct page *shmem_read_mapping_page(
 					mapping_gfp_mask(mapping));
 }
 
+struct pagevec;
+
 extern int shmem_insert_page(struct inode *inode,
 		pgoff_t index, struct page *page, bool on_lru);
+extern unsigned shmem_find_get_pages_and_swap(struct address_space *mapping,
+					pgoff_t start, unsigned int nr_pages,
+					struct page **pages, pgoff_t *indices);
+extern void shmem_deswap_pagevec(struct pagevec *pvec);
+
+#ifdef CONFIG_PRAM
+extern int shmem_parse_pram(const char *str, struct shmem_pram_info **pram);
+extern void shmem_show_pram(struct seq_file *seq, struct shmem_pram_info *pram);
+extern void shmem_save_pram(struct super_block *sb);
+extern void shmem_load_pram(struct super_block *sb);
+#else
+static inline int shmem_parse_pram(const char *str,
+			struct shmem_pram_info **pram) { return 1; }
+static inline void shmem_show_pram(struct seq_file *seq,
+			struct shmem_pram_info *pram) { }
+static inline void shmem_save_pram(struct super_block *sb) { }
+static inline void shmem_load_pram(struct super_block *sb) { }
+#endif
 
 #endif
diff --git a/mm/Makefile b/mm/Makefile
index 33ad952..6a8c61d 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -58,4 +58,4 @@ obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
 obj-$(CONFIG_CLEANCACHE) += cleancache.o
 obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
-obj-$(CONFIG_PRAM) += pram.o
+obj-$(CONFIG_PRAM) += pram.o shmem_pram.o
diff --git a/mm/shmem.c b/mm/shmem.c
index 71fac31..2d6b618 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -399,7 +399,7 @@ out:
 /*
  * Like find_get_pages, but collecting swap entries as well as pages.
  */
-static unsigned shmem_find_get_pages_and_swap(struct address_space *mapping,
+unsigned shmem_find_get_pages_and_swap(struct address_space *mapping,
 					pgoff_t start, unsigned int nr_pages,
 					struct page **pages, pgoff_t *indices)
 {
@@ -465,7 +465,7 @@ static int shmem_free_swap(struct address_space *mapping,
 /*
  * Pagevec may contain swap entries, so shuffle up pages before releasing.
  */
-static void shmem_deswap_pagevec(struct pagevec *pvec)
+void shmem_deswap_pagevec(struct pagevec *pvec)
 {
 	int i, j;
 
@@ -2535,6 +2535,10 @@ static int shmem_parse_options(char *options, struct shmem_sb_info *sbinfo,
 			mpol = NULL;
 			if (mpol_parse_str(value, &mpol))
 				goto bad_val;
+		} else if (!strcmp(this_char,"pram")) {
+			kfree(sbinfo->pram);
+			if (shmem_parse_pram(value, &sbinfo->pram))
+				goto bad_val;
 		} else {
 			printk(KERN_ERR "tmpfs: Bad mount option %s\n",
 			       this_char);
@@ -2561,6 +2565,7 @@ static int shmem_remount_fs(struct super_block *sb, int *flags, char *data)
 	int error = -EINVAL;
 
 	config.mpol = NULL;
+	config.pram = NULL;
 	if (shmem_parse_options(data, &config, true))
 		return error;
 
@@ -2592,6 +2597,9 @@ static int shmem_remount_fs(struct super_block *sb, int *flags, char *data)
 		mpol_put(sbinfo->mpol);
 		sbinfo->mpol = config.mpol;	/* transfers initial ref */
 	}
+
+	kfree(sbinfo->pram);
+	sbinfo->pram = config.pram;
 out:
 	spin_unlock(&sbinfo->stat_lock);
 	return error;
@@ -2615,6 +2623,7 @@ static int shmem_show_options(struct seq_file *seq, struct dentry *root)
 		seq_printf(seq, ",gid=%u",
 				from_kgid_munged(&init_user_ns, sbinfo->gid));
 	shmem_show_mpol(seq, sbinfo->mpol);
+	shmem_show_pram(seq, sbinfo->pram);
 	return 0;
 }
 #endif /* CONFIG_TMPFS */
@@ -2625,6 +2634,7 @@ static void shmem_put_super(struct super_block *sb)
 
 	percpu_counter_destroy(&sbinfo->used_blocks);
 	mpol_put(sbinfo->mpol);
+	kfree(sbinfo->pram);
 	kfree(sbinfo);
 	sb->s_fs_info = NULL;
 }
@@ -2838,14 +2848,25 @@ static const struct vm_operations_struct shmem_vm_ops = {
 static struct dentry *shmem_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *data)
 {
-	return mount_nodev(fs_type, flags, data, shmem_fill_super);
+	struct dentry *root;
+	
+	root = mount_nodev(fs_type, flags, data, shmem_fill_super);
+	if (!IS_ERR(root))
+		shmem_load_pram(root->d_sb);
+	return root;
+}
+
+static void shmem_kill_sb(struct super_block *sb)
+{
+	shmem_save_pram(sb);
+	kill_litter_super(sb);
 }
 
 static struct file_system_type shmem_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "tmpfs",
 	.mount		= shmem_mount,
-	.kill_sb	= kill_litter_super,
+	.kill_sb	= shmem_kill_sb,
 	.fs_flags	= FS_USERNS_MOUNT,
 };
 
diff --git a/mm/shmem_pram.c b/mm/shmem_pram.c
new file mode 100644
index 0000000..9a01040
--- /dev/null
+++ b/mm/shmem_pram.c
@@ -0,0 +1,378 @@
+#include <linux/dcache.h>
+#include <linux/err.h>
+#include <linux/fs.h>
+#include <linux/gfp.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/mm.h>
+#include <linux/mount.h>
+#include <linux/mutex.h>
+#include <linux/namei.h>
+#include <linux/pagemap.h>
+#include <linux/pagevec.h>
+#include <linux/pram.h>
+#include <linux/seq_file.h>
+#include <linux/shmem_fs.h>
+#include <linux/spinlock.h>
+#include <linux/string.h>
+#include <linux/time.h>
+#include <linux/types.h>
+#include <linux/uaccess.h>
+
+#define META_ID		1
+#define DATA_ID		2
+
+#define EOF_MARK	((__u64)~0ULL)
+
+struct file_header {
+	__u32	mode;
+	__u32	uid;
+	__u32	gid;
+	__u32	namelen;
+	__u64	size;
+	__u64	atime;
+	__u64	mtime;
+	__u64	ctime;
+};
+
+int shmem_parse_pram(const char *str, struct shmem_pram_info **pram)
+{
+	struct shmem_pram_info *new;
+	size_t len;
+
+	len = strlen(str);
+	if (!len || len >= SHMEM_PRAM_NAME_MAX)
+		return 1;
+	new = kzalloc(sizeof(*new), GFP_KERNEL);
+	if (!new)
+		return 1;
+	strcpy(new->name, str);
+	*pram = new;
+	return 0;
+}
+
+void shmem_show_pram(struct seq_file *seq, struct shmem_pram_info *pram)
+{
+	if (pram)
+		seq_printf(seq, ",pram=%s", pram->name);
+}
+
+static int shmem_pram_name(char *buf, size_t bufsize,
+			   struct shmem_sb_info *sbinfo, int id)
+{
+	if (snprintf(buf, bufsize, "shmem-%d-%s", id,
+		     sbinfo->pram->name) >= bufsize)
+		return -ENAMETOOLONG;
+	return 0;
+}
+
+static int save_page(struct page *page,
+		struct pram_stream *psmeta, struct pram_stream *psdata)
+{
+	__u64 val;
+	ssize_t ret;
+	int err = 0;
+
+	if (page) {
+		val = page->index;
+		err = pram_save_page(psdata, page, PRAM_PAGE_LRU);
+	} else
+		val = EOF_MARK;
+	if (!err) {
+		ret = pram_write(psmeta, &val, sizeof(val));
+		if (ret < 0)
+			err = ret;
+	}
+	return err;
+}
+
+static int save_file_content(struct address_space *mapping,
+		struct pram_stream *psmeta, struct pram_stream *psdata)
+{
+	struct pagevec pvec;
+	pgoff_t indices[PAGEVEC_SIZE];
+	pgoff_t index = 0;
+	struct page *page;
+	int i, err = 0;
+
+	pagevec_init(&pvec, 0);
+	for ( ; ; ) {
+		pvec.nr = shmem_find_get_pages_and_swap(mapping,
+				index, PAGEVEC_SIZE, pvec.pages, indices);
+		if (!pvec.nr)
+			break;
+		for (i = 0; i < pagevec_count(&pvec); i++) {
+			page = pvec.pages[i];
+			index = indices[i];
+
+			if (radix_tree_exceptional_entry(page)) {
+				err = -ENOSYS;
+				break;
+			}
+
+			lock_page(page);
+			if (likely(page->mapping == mapping))
+				save_page(page, psmeta, psdata);
+			unlock_page(page);
+			if (err)
+				break;
+		}
+		shmem_deswap_pagevec(&pvec);
+		pagevec_release(&pvec);
+		if (err)
+			break;
+		cond_resched();
+		index++;
+	}
+	if (!err)
+		err = save_page(NULL, psmeta, psdata); /* eof */
+	return err;
+}
+
+static int save_file(struct dentry *dentry,
+		struct pram_stream *psmeta, struct pram_stream *psdata)
+{
+	struct inode *inode = dentry->d_inode;
+	umode_t mode = inode->i_mode;
+	struct file_header hdr;
+	ssize_t ret;
+
+	if (!S_ISREG(mode))
+		return -ENOSYS;
+	if (inode->i_nlink > 1)
+		return -ENOSYS;
+
+	hdr.mode = mode;
+	hdr.uid = inode->i_uid;
+	hdr.gid = inode->i_gid;
+	hdr.namelen = dentry->d_name.len;
+	hdr.size = i_size_read(inode);
+	hdr.atime = timespec_to_ns(&inode->i_atime);
+	hdr.mtime = timespec_to_ns(&inode->i_mtime);
+	hdr.ctime = timespec_to_ns(&inode->i_ctime);
+
+	ret = pram_write(psmeta, &hdr, sizeof(hdr));
+	if (ret < 0)
+		return ret;
+	ret = pram_write(psmeta, dentry->d_name.name, dentry->d_name.len);
+	if (ret < 0)
+		return ret;
+	return save_file_content(inode->i_mapping, psmeta, psdata);
+}
+
+static int save_tree(struct super_block *sb,
+		struct pram_stream *psmeta, struct pram_stream *psdata)
+{
+	struct dentry *dentry, *root = sb->s_root;
+	int err = 0;
+
+	mutex_lock(&root->d_inode->i_mutex);
+	spin_lock(&root->d_lock);
+	list_for_each_entry(dentry, &root->d_subdirs, d_u.d_child) {
+		if (d_unhashed(dentry) || !dentry->d_inode)
+			continue;
+		dget(dentry);
+		spin_unlock(&root->d_lock);
+
+		err = save_file(dentry, psmeta, psdata);
+
+		spin_lock(&root->d_lock);
+		dput(dentry);
+		if (err)
+			break;
+	}
+	spin_unlock(&root->d_lock);
+	mutex_unlock(&root->d_inode->i_mutex);
+
+	return err;
+}
+
+void shmem_save_pram(struct super_block *sb)
+{
+	struct shmem_sb_info *sbinfo = sb->s_fs_info;
+	struct pram_stream psmeta, psdata;
+	char *buf;
+	int err = -ENOMEM;
+
+	if (!sbinfo || !sbinfo->pram)
+		return;
+
+	buf = (void *)__get_free_page(GFP_TEMPORARY);
+	if (!buf)
+		goto out;
+
+	err = shmem_pram_name(buf, PAGE_SIZE, sbinfo, META_ID);
+	if (!err)
+		err = pram_prepare_save(&psmeta, buf,
+					PRAM_BYTE_STREAM, GFP_KERNEL);
+	if (err)
+		goto out_free_buf;
+
+	err = shmem_pram_name(buf, PAGE_SIZE, sbinfo, DATA_ID);
+	if (!err)
+		err = pram_prepare_save(&psdata, buf,
+					PRAM_PAGE_STREAM, GFP_HIGHUSER);
+	if (err)
+		goto out_discard_meta_save;
+
+	err = save_tree(sb, &psmeta, &psdata);
+	if (err)
+		goto out_discard_data_save;
+
+	pram_finish_save(&psmeta);
+	pram_finish_save(&psdata);
+	goto out_free_buf;
+
+out_discard_data_save:
+	pram_discard_save(&psdata);
+out_discard_meta_save:
+	pram_discard_save(&psmeta);
+out_free_buf:
+	free_page((unsigned long)buf);
+out:
+	if (err)
+		pr_err("SHMEM: PRAM save failed: %d\n", err);
+}
+
+static struct page *load_page(unsigned long *index, int *flags,
+		struct pram_stream *psmeta, struct pram_stream *psdata)
+{
+	__u64 val;
+	struct page *page;
+
+	if (pram_read(psmeta, &val, sizeof(val)) != sizeof(val))
+		return ERR_PTR(-EINVAL);
+	if (val == EOF_MARK)
+		return NULL;
+	*index = val;
+	page = pram_load_page(psdata, flags);
+	return page ?: ERR_PTR(-EINVAL);
+}
+
+static int load_file_content(struct address_space *mapping,
+		struct pram_stream *psmeta, struct pram_stream *psdata)
+{
+	struct page *page;
+	unsigned long index;
+	int flags, err;
+
+next:
+	page = load_page(&index, &flags, psmeta, psdata);
+	if (IS_ERR_OR_NULL(page))
+		return PTR_ERR(page);
+	err = shmem_insert_page(mapping->host, index, page,
+				flags & PRAM_PAGE_LRU);
+	put_page(page);
+	if (err)
+		return err;
+	goto next;
+}
+
+static int load_file(struct dentry *parent,
+		struct pram_stream *psmeta, struct pram_stream *psdata,
+		char *buf, size_t bufsize)
+{
+	struct dentry *dentry;
+	struct inode *inode;
+	struct file_header hdr;
+	size_t ret;
+	umode_t mode;
+	int namelen;
+	int err;
+
+	ret = pram_read(psmeta, &hdr, sizeof(hdr));
+	if (!ret)
+		return 0;
+	if (ret != sizeof(hdr))
+		return -EINVAL;
+
+	mode = hdr.mode;
+	namelen = hdr.namelen;
+	if (!S_ISREG(mode) || namelen > bufsize)
+		return -EINVAL;
+	if (pram_read(psmeta, buf, namelen) != namelen)
+		return -EINVAL;
+
+	mutex_lock_nested(&parent->d_inode->i_mutex, I_MUTEX_PARENT);
+
+	dentry = lookup_one_len(buf, parent, namelen);
+	if (IS_ERR(dentry)) {
+		err = PTR_ERR(dentry);
+		goto out_unlock;
+	}
+
+	err = vfs_create(parent->d_inode, dentry, mode, NULL);
+	dput(dentry); /* on success shmem pinned it */
+	if (err)
+		goto out_unlock;
+
+	inode = dentry->d_inode;
+	inode->i_mode = mode;
+	inode->i_uid = hdr.uid;
+	inode->i_gid = hdr.gid;
+	inode->i_atime = ns_to_timespec(hdr.atime);
+	inode->i_mtime = ns_to_timespec(hdr.mtime);
+	inode->i_ctime = ns_to_timespec(hdr.ctime);
+	i_size_write(inode, hdr.size);
+
+	err = load_file_content(inode->i_mapping, psmeta, psdata);
+out_unlock:
+	mutex_unlock(&parent->d_inode->i_mutex);
+	if (err)
+		return err;
+	return 1;
+}
+
+static int load_tree(struct super_block *sb,
+		struct pram_stream *psmeta, struct pram_stream *psdata,
+		char *buf, size_t bufsize)
+{
+	int ret;
+
+next:
+	ret = load_file(sb->s_root, psmeta, psdata, buf, PAGE_SIZE);
+	if (ret <= 0)
+		return ret;
+	goto next;
+}
+
+void shmem_load_pram(struct super_block *sb)
+{
+	struct shmem_sb_info *sbinfo = sb->s_fs_info;
+	struct pram_stream psmeta, psdata;
+	char *buf;
+	int err = -ENOMEM;
+
+	if (!sbinfo->pram)
+		return;
+
+	buf = (void *)__get_free_page(GFP_TEMPORARY);
+	if (!buf)
+		goto out;
+
+	err = shmem_pram_name(buf, PAGE_SIZE, sbinfo, META_ID);
+	if (!err)
+		err = pram_prepare_load(&psmeta, buf, PRAM_BYTE_STREAM);
+	if (err) {
+		if (err == -ENOENT)
+			err = 0;
+		goto out_free_buf;
+	}
+
+	err = shmem_pram_name(buf, PAGE_SIZE, sbinfo, DATA_ID);
+	if (!err)
+		err = pram_prepare_load(&psdata, buf, PRAM_PAGE_STREAM);
+	if (err)
+		goto out_finish_meta_load;
+
+	err = load_tree(sb, &psmeta, &psdata, buf, PAGE_SIZE);
+
+	pram_finish_load(&psmeta);
+out_finish_meta_load:
+	pram_finish_load(&psdata);
+out_free_buf:
+	free_page((unsigned long)buf);
+out:
+	if (err)
+		pr_err("SHMEM: PRAM load failed: %d\n", err);
+}
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
