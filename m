Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B1D706B005A
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 18:13:32 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7BM7Lgg019213
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 18:07:21 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7BMDUXB111942
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 18:13:30 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7BMDUs0018985
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 18:13:30 -0400
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: [PATCH 2/3] Add MAP_LARGEPAGE for mmaping pseudo-anonymous huge page regions
Date: Tue, 11 Aug 2009 23:13:18 +0100
Message-Id: <a45eb555ca7d9e23e5eb051e27f757ae70a6b0c5.1249999949.git.ebmunson@us.ibm.com>
In-Reply-To: <2154e5ac91c7acd5505c5fc6c55665980cbc1bf8.1249999949.git.ebmunson@us.ibm.com>
References: <cover.1249999949.git.ebmunson@us.ibm.com>
 <2154e5ac91c7acd5505c5fc6c55665980cbc1bf8.1249999949.git.ebmunson@us.ibm.com>
In-Reply-To: <cover.1249999949.git.ebmunson@us.ibm.com>
References: <cover.1249999949.git.ebmunson@us.ibm.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: linux-man@vger.kernel.org, mtk.manpages@gmail.com, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This patch adds a flag for mmap that will be used to request a huge
page region that will look like anonymous memory to user space.  This
is accomplished by using a file on the internal vfsmount.  MAP_LARGEPAGE
is a modifier of MAP_ANONYMOUS and so must be specified with it.  The
region will behave the same as a MAP_ANONYMOUS region using small pages.

Signed-off-by: Eric B Munson <ebmunson@us.ibm.com>
---
 include/asm-generic/mman-common.h |    1 +
 include/linux/hugetlb.h           |    7 +++++++
 mm/mmap.c                         |   16 ++++++++++++++++
 3 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/include/asm-generic/mman-common.h b/include/asm-generic/mman-common.h
index 3b69ad3..60b6be7 100644
--- a/include/asm-generic/mman-common.h
+++ b/include/asm-generic/mman-common.h
@@ -19,6 +19,7 @@
 #define MAP_TYPE	0x0f		/* Mask for type of mapping */
 #define MAP_FIXED	0x10		/* Interpret addr exactly */
 #define MAP_ANONYMOUS	0x20		/* don't use a file */
+#define MAP_LARGEPAGE	0x40		/* create a large page mapping */
 
 #define MS_ASYNC	1		/* sync memory asynchronously */
 #define MS_INVALIDATE	2		/* invalidate the caches */
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 78b6ddf..b84361c 100644
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
 	HUGETLB_SHMFS_INODE     = 0x01,
+	/*
+	 * The file is being created on the internal vfs mount and shmfs
+	 * accounting rules do not apply
+	 */
+	HUGETLB_ANONHUGE_INODE  = 0x02,
 };
 
 #ifdef CONFIG_HUGETLBFS
diff --git a/mm/mmap.c b/mm/mmap.c
index 34579b2..c2c729a 100644
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
 
+	if (flags & MAP_LARGEPAGE) {
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
+			return -ENOMEM;
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
