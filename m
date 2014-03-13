Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 570AA6B0039
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 17:40:31 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id l18so1419591wgh.19
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 14:40:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id t13si2459599wju.91.2014.03.13.14.40.28
        for <linux-mm@kvack.org>;
        Thu, 13 Mar 2014 14:40:29 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 4/6] fs/proc/page.c: introduce /proc/kpagecache interface
Date: Thu, 13 Mar 2014 17:39:44 -0400
Message-Id: <1394746786-6397-5-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1394746786-6397-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1394746786-6397-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org

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
 fs/proc/page.c     | 106 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/fs.h |  11 ++++--
 2 files changed, 113 insertions(+), 4 deletions(-)

diff --git v3.14-rc6.orig/fs/proc/page.c v3.14-rc6/fs/proc/page.c
index e647c55275d9..4be6f72783d3 100644
--- v3.14-rc6.orig/fs/proc/page.c
+++ v3.14-rc6/fs/proc/page.c
@@ -9,6 +9,8 @@
 #include <linux/seq_file.h>
 #include <linux/hugetlb.h>
 #include <linux/kernel-page-flags.h>
+#include <linux/path.h>
+#include <linux/namei.h>
 #include <asm/uaccess.h>
 #include "internal.h"
 
@@ -212,10 +214,114 @@ static const struct file_operations proc_kpageflags_operations = {
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
+	struct address_space *mapping;
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
diff --git v3.14-rc6.orig/include/linux/fs.h v3.14-rc6/include/linux/fs.h
index 1e8966919044..6bf7ddcfc138 100644
--- v3.14-rc6.orig/include/linux/fs.h
+++ v3.14-rc6/include/linux/fs.h
@@ -472,12 +472,15 @@ struct block_device {
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
 #ifdef CONFIG_MEMORY_FAILURE
-#define PAGECACHE_TAG_HWPOISON	3
+	PAGECACHE_TAG_HWPOISON,
 #endif
+	__NR_PAGECACHE_TAGS,
+};
 
 int mapping_tagged(struct address_space *mapping, int tag);
 
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
