Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B5E6D6B0253
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 05:03:01 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t25so222021356pfg.3
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 02:03:01 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id p63si34679705pfd.219.2016.10.18.02.03.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Oct 2016 02:03:00 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3] shmem: avoid huge pages for small files
Date: Tue, 18 Oct 2016 12:02:36 +0300
Message-Id: <20161018090236.183045-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Huge pages are detrimental for small file: they causes noticible
overhead on both allocation performance and memory footprint.

This patch aimed to address this issue by avoiding huge pages until file
grown to specified size. This would cover most of the cases where huge
pages causes regressions in performance.

By default the minimal file size to allocate huge pages is equal to size
of huge page.

Depending on how well CPU microarchitecture deals with huge pages, you
might need to set it higher in order to balance out overhead with benefit
of huge pages.

In other case, if it's known in advance that specific mount would be
populated with large files, you might want to set it to zero to get huge
pages allocated from the beginning.

We add two handle to specify minimal file size for huge pages:

  - mount option 'huge_min_size';

  - sysfs file /sys/kernel/mm/transparent_hugepage/shmem_min_size for
    in-kernel tmpfs mount;

Few notes:

  - if shmem_enabled is set to 'force', the limit is ignored. We still
    want to generate as many pages as possible for functional testing.

  - the limit doesn't affect khugepaged behaviour: it still can collapse
    pages based on its settings;

  - remount of the filesystem doesn't affect previously allocated pages,
    but the limit is applied for new allocations;

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/vm/transhuge.txt |  6 +++++
 include/linux/huge_mm.h        |  1 +
 include/linux/shmem_fs.h       |  1 +
 mm/huge_memory.c               |  1 +
 mm/shmem.c                     | 56 ++++++++++++++++++++++++++++++++++++++----
 5 files changed, 60 insertions(+), 5 deletions(-)

diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
index 2ec6adb5a4ce..2d861d72e135 100644
--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -238,6 +238,12 @@ values:
   - "force":
     Force the huge option on for all - very useful for testing;
 
+There's limit on minimal file size before kernel starts allocate huge
+pages for it. By default it's size of huge page.
+
+You can adjust the limit using "huge_min_size=" mount option or
+/sys/kernel/mm/transparent_hugepage/shmem_min_size for in-kernel mount.
+
 == Need of application restart ==
 
 The transparent_hugepage/enabled values and tmpfs mount option only affect
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 9b9f65d99873..515b96a5a592 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -52,6 +52,7 @@ extern ssize_t single_hugepage_flag_show(struct kobject *kobj,
 				struct kobj_attribute *attr, char *buf,
 				enum transparent_hugepage_flag flag);
 extern struct kobj_attribute shmem_enabled_attr;
+extern struct kobj_attribute shmem_min_size_attr;
 
 #define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
 #define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index ff078e7043b6..e7c3bddc6335 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -31,6 +31,7 @@ struct shmem_sb_info {
 	spinlock_t stat_lock;	    /* Serialize shmem_sb_info changes */
 	umode_t mode;		    /* Mount mode for root directory */
 	unsigned char huge;	    /* Whether to try for hugepages */
+	loff_t huge_min_size;       /* No hugepages if i_size less than this */
 	kuid_t uid;		    /* Mount uid for root directory */
 	kgid_t gid;		    /* Mount gid for root directory */
 	struct mempolicy *mpol;     /* default memory policy for mappings */
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index cdcd25cb30fe..fa133eb5bf62 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -309,6 +309,7 @@ static struct attribute *hugepage_attr[] = {
 	&use_zero_page_attr.attr,
 #if defined(CONFIG_SHMEM) && defined(CONFIG_TRANSPARENT_HUGE_PAGECACHE)
 	&shmem_enabled_attr.attr,
+	&shmem_min_size_attr.attr,
 #endif
 #ifdef CONFIG_DEBUG_VM
 	&debug_cow_attr.attr,
diff --git a/mm/shmem.c b/mm/shmem.c
index ad7813d73ea7..c15eee0eb885 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -369,6 +369,7 @@ static bool shmem_confirm_swap(struct address_space *mapping,
 /* ifdef here to avoid bloating shmem.o when not necessary */
 
 int shmem_huge __read_mostly;
+unsigned long long shmem_huge_min_size __read_mostly = HPAGE_PMD_SIZE;
 
 static int shmem_parse_huge(const char *str)
 {
@@ -1668,6 +1669,8 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 		swap_free(swap);
 
 	} else {
+		loff_t i_size;
+
 		/* shmem_symlink() */
 		if (mapping->a_ops != &shmem_aops)
 			goto alloc_nohuge;
@@ -1675,14 +1678,17 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 			goto alloc_nohuge;
 		if (shmem_huge == SHMEM_HUGE_FORCE)
 			goto alloc_huge;
+		i_size = i_size_read(inode);
+		if (i_size < sbinfo->huge_min_size &&
+				index < (sbinfo->huge_min_size >> PAGE_SHIFT))
+			goto alloc_nohuge;
 		switch (sbinfo->huge) {
-			loff_t i_size;
 			pgoff_t off;
 		case SHMEM_HUGE_NEVER:
 			goto alloc_nohuge;
 		case SHMEM_HUGE_WITHIN_SIZE:
 			off = round_up(index, HPAGE_PMD_NR);
-			i_size = round_up(i_size_read(inode), PAGE_SIZE);
+			i_size = round_up(i_size, PAGE_SIZE);
 			if (i_size >= HPAGE_PMD_SIZE &&
 					i_size >> PAGE_SHIFT >= off)
 				goto alloc_huge;
@@ -3349,6 +3355,10 @@ static int shmem_parse_options(char *options, struct shmem_sb_info *sbinfo,
 					huge != SHMEM_HUGE_NEVER)
 				goto bad_val;
 			sbinfo->huge = huge;
+		} else if (!strcmp(this_char, "huge_min_size")) {
+			sbinfo->huge_min_size = memparse(value, &rest);
+			if (*rest)
+				goto bad_val;
 #endif
 #ifdef CONFIG_NUMA
 		} else if (!strcmp(this_char,"mpol")) {
@@ -3382,6 +3392,8 @@ static int shmem_remount_fs(struct super_block *sb, int *flags, char *data)
 	int error = -EINVAL;
 
 	config.mpol = NULL;
+	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE))
+		config.huge_min_size = HPAGE_PMD_SIZE;
 	if (shmem_parse_options(data, &config, true))
 		return error;
 
@@ -3403,6 +3415,7 @@ static int shmem_remount_fs(struct super_block *sb, int *flags, char *data)
 
 	error = 0;
 	sbinfo->huge = config.huge;
+	sbinfo->huge_min_size = config.huge_min_size;
 	sbinfo->max_blocks  = config.max_blocks;
 	sbinfo->max_inodes  = config.max_inodes;
 	sbinfo->free_inodes = config.max_inodes - inodes;
@@ -3438,8 +3451,10 @@ static int shmem_show_options(struct seq_file *seq, struct dentry *root)
 				from_kgid_munged(&init_user_ns, sbinfo->gid));
 #ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
 	/* Rightly or wrongly, show huge mount option unmasked by shmem_huge */
-	if (sbinfo->huge)
+	if (sbinfo->huge) {
 		seq_printf(seq, ",huge=%s", shmem_format_huge(sbinfo->huge));
+		seq_printf(seq, ",huge_min_size=%llu", sbinfo->huge_min_size);
+	}
 #endif
 	shmem_show_mpol(seq, sbinfo->mpol);
 	return 0;
@@ -3542,6 +3557,8 @@ int shmem_fill_super(struct super_block *sb, void *data, int silent)
 	sbinfo->mode = S_IRWXUGO | S_ISVTX;
 	sbinfo->uid = current_fsuid();
 	sbinfo->gid = current_fsgid();
+	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE))
+		sbinfo->huge_min_size = HPAGE_PMD_SIZE;
 	sb->s_fs_info = sbinfo;
 
 #ifdef CONFIG_TMPFS
@@ -3780,9 +3797,10 @@ int __init shmem_init(void)
 	}
 
 #ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
-	if (has_transparent_hugepage() && shmem_huge < SHMEM_HUGE_DENY)
+	if (has_transparent_hugepage() && shmem_huge < SHMEM_HUGE_DENY) {
 		SHMEM_SB(shm_mnt->mnt_sb)->huge = shmem_huge;
-	else
+		SHMEM_SB(shm_mnt->mnt_sb)->huge_min_size = shmem_huge_min_size;
+	} else
 		shmem_huge = 0; /* just in case it was patched */
 #endif
 	return 0;
@@ -3848,6 +3866,34 @@ static ssize_t shmem_enabled_store(struct kobject *kobj,
 
 struct kobj_attribute shmem_enabled_attr =
 	__ATTR(shmem_enabled, 0644, shmem_enabled_show, shmem_enabled_store);
+
+static ssize_t shmem_min_size_show(struct kobject *kobj,
+		struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%llu\n", shmem_huge_min_size);
+}
+
+
+static ssize_t shmem_min_size_store(struct kobject *kobj,
+		struct kobj_attribute *attr, const char *buf, size_t count)
+{
+	unsigned long long size;
+	char *end;
+
+	size = memparse(buf, &end);
+	if (end == buf)
+		return  -EINVAL;
+	if (*end == '\n')
+		end++;
+	if (*end != '\0')
+		return -EINVAL;
+	shmem_huge_min_size = size;
+	SHMEM_SB(shm_mnt->mnt_sb)->huge_min_size = size;
+	return end - buf;
+}
+
+struct kobj_attribute shmem_min_size_attr =
+	__ATTR(shmem_min_size, 0644, shmem_min_size_show, shmem_min_size_store);
 #endif /* CONFIG_TRANSPARENT_HUGE_PAGECACHE && CONFIG_SYSFS */
 
 #ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
