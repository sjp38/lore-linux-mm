Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5EDFC6B000A
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 17:08:48 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x17so11991287pfn.10
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 14:08:48 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id x1si11931857pgp.89.2018.04.17.14.08.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 14:08:46 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC PATCH] fs: introduce ST_HUGE flag and set it to tmpfs and hugetlbfs
Date: Wed, 18 Apr 2018 05:08:13 +0800
Message-Id: <1523999293-94152-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, nyc@holomorphy.com, mike.kravetz@oracle.com, kirill.shutemov@linux.intel.com, hughd@google.com, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Since tmpfs THP was supported in 4.8, hugetlbfs is not the only
filesystem with huge page support anymore. tmpfs can use huge page via
THP when mounting by "huge=" mount option.

When applications use huge page on hugetlbfs, it just need check the
filesystem magic number, but it is not enough for tmpfs. So, introduce
ST_HUGE flag to statfs if super block has SB_HUGE set which indicates
huge page is supported on the specific filesystem.

Some applications could benefit from this change, for example QEMU.
When use mmap file as guest VM backend memory, QEMU typically mmap the
file size plus one extra page. If the file is on hugetlbfs the extra
page is huge page size (i.e. 2MB), but it is still 4KB on tmpfs even
though THP is enabled. tmpfs THP requires VMA is huge page aligned, so
if 4KB page is used THP will not be used at all. The below /proc/meminfo
fragment shows the THP use of QEMU with 4K page:

ShmemHugePages:   679936 kB
ShmemPmdMapped:        0 kB

With ST_HUGE flag, QEMU can get huge page, then /proc/meminfo looks
like:

ShmemHugePages:    77824 kB
ShmemPmdMapped:     6144 kB

With this flag, the applications can know if huge page is supported on
the filesystem then optimize the behavior of the applications
accordingly. Although the similar function can be implemented in
applications by traversing the mount options, it looks more convenient
if kernel can provide such flag.

Even though ST_HUGE is set, f_bsize still returns 4KB for tmpfs since
THP could be split, and it also my fallback to 4KB page silently if
there is not enough huge page.

And, set the flag for hugetlbfs as well to keep the consistency, and the
applications don't have to know what filesystem is used to use huge
page, just need to check ST_HUGE flag.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Nadia Yvette Chambers <nyc@holomorphy.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
---
 fs/hugetlbfs/inode.c   | 1 +
 fs/statfs.c            | 2 ++
 include/linux/fs.h     | 1 +
 include/linux/statfs.h | 1 +
 mm/shmem.c             | 8 ++++++++
 5 files changed, 13 insertions(+)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index b9a254d..3754b45 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -1265,6 +1265,7 @@ static void init_once(void *foo)
 	sb->s_op = &hugetlbfs_ops;
 	sb->s_time_gran = 1;
 	sb->s_root = d_make_root(hugetlbfs_get_root(sb, &config));
+	sb->s_flags |= SB_HUGE;
 	if (!sb->s_root)
 		goto out_free;
 	return 0;
diff --git a/fs/statfs.c b/fs/statfs.c
index 5b2a24f..ac0403a 100644
--- a/fs/statfs.c
+++ b/fs/statfs.c
@@ -41,6 +41,8 @@ static int flags_by_sb(int s_flags)
 		flags |= ST_MANDLOCK;
 	if (s_flags & SB_RDONLY)
 		flags |= ST_RDONLY;
+	if (s_flags & SB_HUGE)
+		flags |= ST_HUGE;
 	return flags;
 }
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index c6baf76..df246e9 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1287,6 +1287,7 @@ struct fasync_struct {
 #define SB_SYNCHRONOUS	16	/* Writes are synced at once */
 #define SB_MANDLOCK	64	/* Allow mandatory locks on an FS */
 #define SB_DIRSYNC	128	/* Directory modifications are synchronous */
+#define SB_HUGE		256	/* Support hugepage/THP */
 #define SB_NOATIME	1024	/* Do not update access times. */
 #define SB_NODIRATIME	2048	/* Do not update directory access times */
 #define SB_SILENT	32768
diff --git a/include/linux/statfs.h b/include/linux/statfs.h
index 3142e98..79a634b 100644
--- a/include/linux/statfs.h
+++ b/include/linux/statfs.h
@@ -40,5 +40,6 @@ struct kstatfs {
 #define ST_NOATIME	0x0400	/* do not update access times */
 #define ST_NODIRATIME	0x0800	/* do not update directory access times */
 #define ST_RELATIME	0x1000	/* update atime relative to mtime/ctime */
+#define ST_HUGE		0x2000	/* support hugepage/thp */
 
 #endif
diff --git a/mm/shmem.c b/mm/shmem.c
index b859192..d5312ec 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -3632,6 +3632,11 @@ static int shmem_remount_fs(struct super_block *sb, int *flags, char *data)
 	sbinfo->max_inodes  = config.max_inodes;
 	sbinfo->free_inodes = config.max_inodes - inodes;
 
+	if (sbinfo->huge > 0)
+		sb->s_flags |= SB_HUGE;
+	else
+		sb->s_flags &= ~SB_HUGE;
+
 	/*
 	 * Preserve previous mempolicy unless mpol remount option was specified.
 	 */
@@ -3804,6 +3809,9 @@ int shmem_fill_super(struct super_block *sb, void *data, int silent)
 	}
 	sb->s_export_op = &shmem_export_ops;
 	sb->s_flags |= SB_NOSEC;
+
+	if (sbinfo->huge > 0)
+		sb->s_flags |= SB_HUGE;
 #else
 	sb->s_flags |= SB_NOUSER;
 #endif
-- 
1.8.3.1
