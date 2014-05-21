Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 09CEC6B0035
	for <linux-mm@kvack.org>; Tue, 20 May 2014 22:27:04 -0400 (EDT)
Received: by mail-lb0-f171.google.com with SMTP id 10so1079438lbg.16
        for <linux-mm@kvack.org>; Tue, 20 May 2014 19:27:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ti10si1939327lbb.52.2014.05.20.19.27.02
        for <linux-mm@kvack.org>;
        Tue, 20 May 2014 19:27:03 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 2/4] fs/proc/page.c: introduce /proc/kpagecache interface
Date: Tue, 20 May 2014 22:26:32 -0400
Message-Id: <1400639194-3743-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1400639194-3743-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1400639194-3743-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>

/proc/pid/pagemap is one of powerful analyzing and testing features about
page mapping. This is also useful to know about page status combined with
/proc/kpageflag or /proc/kpagecount. One missing is the similar interface to
scan over pagecache of a given file without opening it or mapping it to
virtual address, which could impact other workloads. So this patch provides it.

Usage is simple: 1) write a file path to be scanned into the interface,
and 2) read 64-bit entries, each of which is associated with the page on
each page index.

Good in-kernel tree example is tools/vm/page-types.c (some code added on
it in the later patch.)

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 fs/proc/page.c     | 105 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/fs.h |   9 +++--
 2 files changed, 111 insertions(+), 3 deletions(-)

diff --git v3.15-rc5.orig/fs/proc/page.c v3.15-rc5/fs/proc/page.c
index e647c55275d9..d6fe458016e0 100644
--- v3.15-rc5.orig/fs/proc/page.c
+++ v3.15-rc5/fs/proc/page.c
@@ -9,6 +9,8 @@
 #include <linux/seq_file.h>
 #include <linux/hugetlb.h>
 #include <linux/kernel-page-flags.h>
+#include <linux/path.h>
+#include <linux/namei.h>
 #include <asm/uaccess.h>
 #include "internal.h"
 
@@ -212,10 +214,113 @@ static const struct file_operations proc_kpageflags_operations = {
 	.read = kpageflags_read,
 };
 
+static struct path kpagecache_path;
+
+#define KPC_TAGS_BITS	__NR_PAGECACHE_TAGS
+#define KPC_TAGS_OFFSET	(64 - KPC_TAGS_BITS)
+#define KPC_TAGS_MASK	(((1LL << KPC_TAGS_BITS) - 1) << KPC_TAGS_OFFSET)
+#define KPC_TAGS(bits)	(((bits) << KPC_TAGS_OFFSET) & KPC_TAGS_MASK)
+/* a few bits remaining between two fields. */
+#define KPC_PFN_BITS	(64 - PAGE_CACHE_SHIFT)
+#define KPC_PFN_MASK	((1LL << KPC_PFN_BITS) - 1)
+#define KPC_PFN(pfn)	((pfn) & KPC_PFN_MASK)
+
+static u64 get_pagecache_tags(struct radix_tree_root *root, unsigned long index)
+{
+	int i;
+	unsigned long tags = 0;
+	for (i = 0; i < __NR_PAGECACHE_TAGS; i++)
+		if (radix_tree_tag_get(root, index, i))
+			tags |=  1 << i;
+	return KPC_TAGS(tags);
+}
+
+static ssize_t kpagecache_read(struct file *file, char __user *buf,
+				size_t count, loff_t *ppos)
+{
+	u64 __user *out = (u64 __user *)buf;
+	unsigned long src = *ppos;
+	struct address_space *mapping;
+	loff_t size;
+	pgoff_t index;
+	struct radix_tree_iter iter;
+	void **slot;
+	ssize_t ret = 0;
+
+	if (!kpagecache_path.dentry)
+		return 0;
+	if (src & KPMMASK || count & KPMMASK)
+		return -EINVAL;
+	mapping = kpagecache_path.dentry->d_inode->i_mapping;
+	size = i_size_read(mapping->host);
+	if (!size)
+		return 0;
+	size = (size - 1) >> PAGE_CACHE_SHIFT;
+	index = src / KPMSIZE;
+	count = min_t(unsigned long, count, ((size + 1) * KPMSIZE) - src);
+
+	rcu_read_lock();
+	radix_tree_for_each_slot(slot, &mapping->page_tree,
+				 &iter, index, index + count / KPMSIZE - 1) {
+		struct page *page = radix_tree_deref_slot(slot);
+		u64 entry;
+		if (unlikely(!page))
+			continue;
+		entry = get_pagecache_tags(&mapping->page_tree, iter.index);
+		entry |= KPC_PFN(page_to_pfn(page));
+		count = (iter.index - index + 1) * KPMSIZE;
+		if (put_user(entry, out + iter.index - index))
+			break;
+	}
+	rcu_read_unlock();
+	*ppos += count;
+	if (!ret)
+		ret = count;
+	return ret;
+}
+
+static ssize_t kpagecache_write(struct file *file, const char __user *pathname,
+			       size_t count, loff_t *ppos)
+{
+	struct path path;
+	int err;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	if (!pathname) {
+		if (kpagecache_path.dentry) {
+			path_put(&kpagecache_path);
+			kpagecache_path.mnt = NULL;
+			kpagecache_path.dentry = NULL;
+		}
+		return count;
+	}
+
+	err = user_path_at(AT_FDCWD, pathname, LOOKUP_FOLLOW, &path);
+	if (err)
+		return -EINVAL;
+	if (kpagecache_path.dentry != path.dentry) {
+		path_put(&kpagecache_path);
+		kpagecache_path.mnt = path.mnt;
+		kpagecache_path.dentry = path.dentry;
+	} else
+		path_put(&path);
+	return count;
+}
+
+static const struct file_operations proc_kpagecache_operations = {
+	.llseek		= mem_lseek,
+	.read		= kpagecache_read,
+	.write		= kpagecache_write,
+};
+
 static int __init proc_page_init(void)
 {
 	proc_create("kpagecount", S_IRUSR, NULL, &proc_kpagecount_operations);
 	proc_create("kpageflags", S_IRUSR, NULL, &proc_kpageflags_operations);
+	proc_create("kpagecache", S_IRUSR|S_IWUSR, NULL,
+			&proc_kpagecache_operations);
 	return 0;
 }
 fs_initcall(proc_page_init);
diff --git v3.15-rc5.orig/include/linux/fs.h v3.15-rc5/include/linux/fs.h
index 878031227c57..5b489df9d964 100644
--- v3.15-rc5.orig/include/linux/fs.h
+++ v3.15-rc5/include/linux/fs.h
@@ -447,9 +447,12 @@ struct block_device {
  * Radix-tree tags, for tagging dirty and writeback pages within the pagecache
  * radix trees
  */
-#define PAGECACHE_TAG_DIRTY	0
-#define PAGECACHE_TAG_WRITEBACK	1
-#define PAGECACHE_TAG_TOWRITE	2
+enum {
+	PAGECACHE_TAG_DIRTY,
+	PAGECACHE_TAG_WRITEBACK,
+	PAGECACHE_TAG_TOWRITE,
+	__NR_PAGECACHE_TAGS,
+};
 
 int mapping_tagged(struct address_space *mapping, int tag);
 
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
