Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 361F96B0055
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 10:09:02 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e39.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7EE44kT022780
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 08:04:04 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7EE8wnj139686
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 08:08:58 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7EE8vjP004461
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 08:08:57 -0600
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: [PATCH 2/3] Add MAP_HUGETLB for mmaping pseudo-anonymous huge page regions V3
Date: Fri, 14 Aug 2009 15:08:48 +0100
Message-Id: <cf4bcaaa502168605af7b556bb4e8110033c44e6.1250258125.git.ebmunson@us.ibm.com>
In-Reply-To: <d2e4f6625a147c1ef6cb26de66849875f57a8155.1250258125.git.ebmunson@us.ibm.com>
References: <cover.1250258125.git.ebmunson@us.ibm.com>
 <d2e4f6625a147c1ef6cb26de66849875f57a8155.1250258125.git.ebmunson@us.ibm.com>
In-Reply-To: <cover.1250258125.git.ebmunson@us.ibm.com>
References: <cover.1250258125.git.ebmunson@us.ibm.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: linux-man@vger.kernel.org, akpm@linux-foundation.org, mtk.manpages@gmail.com, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This patch adds a flag for mmap that will be used to request a huge
page region that will look like anonymous memory to user space.  This
is accomplished by using a file on the internal vfsmount.  MAP_HUGETLB
is a modifier of MAP_ANONYMOUS and so must be specified with it.  The
region will behave the same as a MAP_ANONYMOUS region using small pages.

Signed-off-by: Eric B Munson <ebmunson@us.ibm.com>
---
Changes from V2:
 Rebase to newest linux-2.6 tree
 Use base 10 value for HUGETLB_ANONHUGE_INODE instead of hex
 Return error value from hugetlb_file_setup instead of hard coding ENOMEM

Changes from V1:
 Rebase to newest linux-2.6 tree
 Rename MAP_LARGEPAGE to MAP_HUGETLB to match flag name for huge page shm

 include/asm-generic/mman-common.h |    1 +
 include/linux/hugetlb.h           |    7 +++++++
 mm/mmap.c                         |   16 ++++++++++++++++
 3 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/include/asm-generic/mman-common.h b/include/asm-generic/mman-common.h
index 3b69ad3..12f5982 100644
--- a/include/asm-generic/mman-common.h
+++ b/include/asm-generic/mman-common.h
@@ -19,6 +19,7 @@
 #define MAP_TYPE	0x0f		/* Mask for type of mapping */
 #define MAP_FIXED	0x10		/* Interpret addr exactly */
 #define MAP_ANONYMOUS	0x20		/* don't use a file */
+#define MAP_HUGETLB	0x40		/* create a huge page mapping */
 
 #define MS_ASYNC	1		/* sync memory asynchronously */
 #define MS_INVALIDATE	2		/* invalidate the caches */
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 3c48a63..e2b01e6 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -109,12 +109,19 @@ static inline void hugetlb_report_meminfo(struct seq_file *m)
 
 #endif /* !CONFIG_HUGETLB_PAGE */
 
+#define HUGETLB_ANON_FILE "anon_hugepage"
+
 enum {
 	/*
 	 * The file will be used as an shm file so shmfs accounting rules
 	 * apply
 	 */
 	HUGETLB_SHMFS_INODE     = 1,
+	/*
+	 * The file is being created on the internal vfs mount and shmfs
+	 * accounting rules do not apply
+	 */
+	HUGETLB_ANONHUGE_INODE  = 2,
 };
 
 #ifdef CONFIG_HUGETLBFS
diff --git a/mm/mmap.c b/mm/mmap.c
index 34579b2..69dbe99 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -29,6 +29,7 @@
 #include <linux/rmap.h>
 #include <linux/mmu_notifier.h>
 #include <linux/perf_counter.h>
+#include <linux/hugetlb.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -954,6 +955,21 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	if (mm->map_count > sysctl_max_map_count)
 		return -ENOMEM;
 
+	if (flags & MAP_HUGETLB) {
+		if (file)
+			return -EINVAL;
+
+		/*
+		 * VM_NORESERVE is used because the reservations will be
+		 * taken when vm_ops->mmap() is called
+		 */
+		len = ALIGN(len, huge_page_size(&default_hstate));
+		file = hugetlb_file_setup(HUGETLB_ANON_FILE, len, VM_NORESERVE,
+						HUGETLB_ANONHUGE_INODE);
+		if (IS_ERR(file))
+			return PTR_ERR(file);
+	}
+
 	/* Obtain the address to map to. we verify (or select) it and ensure
 	 * that it represents a valid section of the address space.
 	 */
-- 
1.6.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
