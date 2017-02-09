Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5801828089F
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 20:02:50 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 204so214081915pfx.1
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 17:02:50 -0800 (PST)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id f15si2122212pln.260.2017.02.08.17.02.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 17:02:49 -0800 (PST)
Received: by mail-pf0-x22a.google.com with SMTP id 189so45501936pfu.3
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 17:02:49 -0800 (PST)
Date: Wed, 8 Feb 2017 17:02:39 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: remove shmem_mapping() shmem_zero_setup() duplicates
Message-ID: <alpine.LSU.2.11.1702081658250.1549@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Simek <monstr@monstr.eu>, Michael Ellerman <mpe@ellerman.id.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Remove the prototypes for shmem_mapping() and shmem_zero_setup() from
linux/mm.h, since they are already provided in linux/shmem_fs.h.  But
shmem_fs.h must then provide the inline stub for shmem_mapping() when
CONFIG_SHMEM is not set, and a few more cfiles now need to #include it.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
Diff'ed to apply in mmotm somewhere after
lib-show_memc-teach-show_mem-to-work-with-the-given-nodemask.patch
since that modifies a neighbouring line of include/linux/mm.h;
otherwise, applies just as well to 4.10-rc7.

 arch/microblaze/pci/pci-common.c |    1 +
 arch/powerpc/kernel/pci-common.c |    1 +
 include/linux/mm.h               |   10 ----------
 include/linux/shmem_fs.h         |    7 +++++++
 mm/madvise.c                     |    1 +
 mm/memcontrol.c                  |    1 +
 mm/mincore.c                     |    1 +
 mm/truncate.c                    |    1 +
 mm/workingset.c                  |    1 +
 9 files changed, 14 insertions(+), 10 deletions(-)

--- 4.10-rc7-mm1/arch/microblaze/pci/pci-common.c	2016-12-11 11:17:54.000000000 -0800
+++ linux/arch/microblaze/pci/pci-common.c	2017-02-08 16:30:39.924378838 -0800
@@ -22,6 +22,7 @@
 #include <linux/init.h>
 #include <linux/bootmem.h>
 #include <linux/mm.h>
+#include <linux/shmem_fs.h>
 #include <linux/list.h>
 #include <linux/syscalls.h>
 #include <linux/irq.h>
--- 4.10-rc7-mm1/arch/powerpc/kernel/pci-common.c	2016-12-11 11:17:54.000000000 -0800
+++ linux/arch/powerpc/kernel/pci-common.c	2017-02-08 16:30:39.928378872 -0800
@@ -25,6 +25,7 @@
 #include <linux/of_address.h>
 #include <linux/of_pci.h>
 #include <linux/mm.h>
+#include <linux/shmem_fs.h>
 #include <linux/list.h>
 #include <linux/syscalls.h>
 #include <linux/irq.h>
--- 4.10-rc7-mm1/include/linux/mm.h	2017-02-08 10:56:22.931334986 -0800
+++ linux/include/linux/mm.h	2017-02-08 16:30:39.928378872 -0800
@@ -1168,16 +1168,6 @@ extern void pagefault_out_of_memory(void
 
 extern void show_free_areas(unsigned int flags, nodemask_t *nodemask);
 
-int shmem_zero_setup(struct vm_area_struct *);
-#ifdef CONFIG_SHMEM
-bool shmem_mapping(struct address_space *mapping);
-#else
-static inline bool shmem_mapping(struct address_space *mapping)
-{
-	return false;
-}
-#endif
-
 extern bool can_do_mlock(void);
 extern int user_shm_lock(size_t, struct user_struct *);
 extern void user_shm_unlock(size_t, struct user_struct *);
--- 4.10-rc7-mm1/include/linux/shmem_fs.h	2017-02-08 10:56:22.999338725 -0800
+++ linux/include/linux/shmem_fs.h	2017-02-08 16:30:39.928378872 -0800
@@ -57,7 +57,14 @@ extern int shmem_zero_setup(struct vm_ar
 extern unsigned long shmem_get_unmapped_area(struct file *, unsigned long addr,
 		unsigned long len, unsigned long pgoff, unsigned long flags);
 extern int shmem_lock(struct file *file, int lock, struct user_struct *user);
+#ifdef CONFIG_SHMEM
 extern bool shmem_mapping(struct address_space *mapping);
+#else
+static inline bool shmem_mapping(struct address_space *mapping)
+{
+	return false;
+}
+#endif /* CONFIG_SHMEM */
 extern void shmem_unlock_mapping(struct address_space *mapping);
 extern struct page *shmem_read_mapping_page_gfp(struct address_space *mapping,
 					pgoff_t index, gfp_t gfp_mask);
--- 4.10-rc7-mm1/mm/madvise.c	2017-02-08 10:56:23.319356319 -0800
+++ linux/mm/madvise.c	2017-02-08 16:30:39.932378905 -0800
@@ -21,6 +21,7 @@
 #include <linux/backing-dev.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/shmem_fs.h>
 #include <linux/mmu_notifier.h>
 
 #include <asm/tlb.h>
--- 4.10-rc7-mm1/mm/memcontrol.c	2017-02-08 10:56:23.319356319 -0800
+++ linux/mm/memcontrol.c	2017-02-08 16:30:39.932378905 -0800
@@ -35,6 +35,7 @@
 #include <linux/memcontrol.h>
 #include <linux/cgroup.h>
 #include <linux/mm.h>
+#include <linux/shmem_fs.h>
 #include <linux/hugetlb.h>
 #include <linux/pagemap.h>
 #include <linux/smp.h>
--- 4.10-rc7-mm1/mm/mincore.c	2016-12-25 18:40:50.838453325 -0800
+++ linux/mm/mincore.c	2017-02-08 16:30:39.932378905 -0800
@@ -14,6 +14,7 @@
 #include <linux/syscalls.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/shmem_fs.h>
 #include <linux/hugetlb.h>
 
 #include <linux/uaccess.h>
--- 4.10-rc7-mm1/mm/truncate.c	2017-02-08 10:56:23.359358518 -0800
+++ linux/mm/truncate.c	2017-02-08 16:30:39.932378905 -0800
@@ -20,6 +20,7 @@
 #include <linux/task_io_accounting_ops.h>
 #include <linux/buffer_head.h>	/* grr. try_to_release_page,
 				   do_invalidatepage */
+#include <linux/shmem_fs.h>
 #include <linux/cleancache.h>
 #include <linux/rmap.h>
 #include "internal.h"
--- 4.10-rc7-mm1/mm/workingset.c	2017-02-08 10:56:23.367358958 -0800
+++ linux/mm/workingset.c	2017-02-08 16:30:39.932378905 -0800
@@ -6,6 +6,7 @@
 
 #include <linux/memcontrol.h>
 #include <linux/writeback.h>
+#include <linux/shmem_fs.h>
 #include <linux/pagemap.h>
 #include <linux/atomic.h>
 #include <linux/module.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
