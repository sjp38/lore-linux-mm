Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id F2AA06B00F3
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 02:57:17 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so872729bkw.14
        for <linux-mm@kvack.org>; Tue, 20 Mar 2012 23:57:17 -0700 (PDT)
Subject: [PATCH 15/16] mm: cast vm_flags_t to u64 before printing
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Wed, 21 Mar 2012 10:57:14 +0400
Message-ID: <20120321065714.13852.12470.stgit@zurg>
In-Reply-To: <20120321065140.13852.52315.stgit@zurg>
References: <20120321065140.13852.52315.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Let's always print vm_flags_t as u64, thus now we can freely change
vm_flags_t's size depending on target achitecture or config options.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 arch/sh/mm/tlbflush_64.c                         |    2 +-
 drivers/infiniband/hw/ipath/ipath_file_ops.c     |    6 ++++--
 drivers/infiniband/hw/qib/qib_file_ops.c         |    6 ++++--
 drivers/staging/android/binder.c                 |   15 ++++++++------
 drivers/staging/tidspbridge/core/tiomap3430.c    |   13 ++++++------
 drivers/staging/tidspbridge/rmgr/drv_interface.c |    4 ++--
 fs/binfmt_elf_fdpic.c                            |   24 ++++++++++++++--------
 mm/memory.c                                      |    5 +++--
 8 files changed, 45 insertions(+), 30 deletions(-)

diff --git a/arch/sh/mm/tlbflush_64.c b/arch/sh/mm/tlbflush_64.c
index e3430e0..b798e7f 100644
--- a/arch/sh/mm/tlbflush_64.c
+++ b/arch/sh/mm/tlbflush_64.c
@@ -48,7 +48,7 @@ static inline void print_vma(struct vm_area_struct *vma)
 	printk("vma end   0x%08lx\n", vma->vm_end);
 
 	print_prots(vma->vm_page_prot);
-	printk("vm_flags 0x%08lx\n", vma->vm_flags);
+	printk("vm_flags 0x%08llx\n", (__force u64)vma->vm_flags);
 }
 
 static inline void print_task(struct task_struct *tsk)
diff --git a/drivers/infiniband/hw/ipath/ipath_file_ops.c b/drivers/infiniband/hw/ipath/ipath_file_ops.c
index 736d9ed..b3dfa21 100644
--- a/drivers/infiniband/hw/ipath/ipath_file_ops.c
+++ b/drivers/infiniband/hw/ipath/ipath_file_ops.c
@@ -1115,7 +1115,8 @@ static int mmap_rcvegrbufs(struct vm_area_struct *vma,
 
 	if (vma->vm_flags & VM_WRITE) {
 		dev_info(&dd->pcidev->dev, "Can't map eager buffers as "
-			 "writable (flags=%lx)\n", vma->vm_flags);
+			 "writable (flags=%llx)\n",
+			 (__force u64)vma->vm_flags);
 		ret = -EPERM;
 		goto bail;
 	}
@@ -1204,7 +1205,8 @@ static int mmap_kvaddr(struct vm_area_struct *vma, u64 pgaddr,
                 if (vma->vm_flags & VM_WRITE) {
                         dev_info(&dd->pcidev->dev,
                                  "Can't map eager buffers as "
-                                 "writable (flags=%lx)\n", vma->vm_flags);
+				 "writable (flags=%llx)\n",
+				 (__force u64)vma->vm_flags);
                         ret = -EPERM;
                         goto bail;
                 }
diff --git a/drivers/infiniband/hw/qib/qib_file_ops.c b/drivers/infiniband/hw/qib/qib_file_ops.c
index a740324..0fe928d 100644
--- a/drivers/infiniband/hw/qib/qib_file_ops.c
+++ b/drivers/infiniband/hw/qib/qib_file_ops.c
@@ -857,7 +857,8 @@ static int mmap_rcvegrbufs(struct vm_area_struct *vma,
 
 	if (vma->vm_flags & VM_WRITE) {
 		qib_devinfo(dd->pcidev, "Can't map eager buffers as "
-			 "writable (flags=%lx)\n", vma->vm_flags);
+			 "writable (flags=%llx)\n",
+			 (__force u64)vma->vm_flags);
 		ret = -EPERM;
 		goto bail;
 	}
@@ -946,7 +947,8 @@ static int mmap_kvaddr(struct vm_area_struct *vma, u64 pgaddr,
 		if (vma->vm_flags & VM_WRITE) {
 			qib_devinfo(dd->pcidev,
 				 "Can't map eager buffers as "
-				 "writable (flags=%lx)\n", vma->vm_flags);
+				 "writable (flags=%llx)\n",
+				 (__force u64)vma->vm_flags);
 			ret = -EPERM;
 			goto bail;
 		}
diff --git a/drivers/staging/android/binder.c b/drivers/staging/android/binder.c
index c283212..b0d03e0 100644
--- a/drivers/staging/android/binder.c
+++ b/drivers/staging/android/binder.c
@@ -2761,9 +2761,10 @@ static void binder_vma_open(struct vm_area_struct *vma)
 {
 	struct binder_proc *proc = vma->vm_private_data;
 	binder_debug(BINDER_DEBUG_OPEN_CLOSE,
-		     "binder: %d open vm area %lx-%lx (%ld K) vma %lx pagep %lx\n",
+		     "binder: %d open vm area %lx-%lx (%ld K) vma %llx pagep %lx\n",
 		     proc->pid, vma->vm_start, vma->vm_end,
-		     (vma->vm_end - vma->vm_start) / SZ_1K, vma->vm_flags,
+		     (vma->vm_end - vma->vm_start) / SZ_1K,
+		     (__force u64)vma->vm_flags,
 		     (unsigned long)pgprot_val(vma->vm_page_prot));
 }
 
@@ -2771,9 +2772,10 @@ static void binder_vma_close(struct vm_area_struct *vma)
 {
 	struct binder_proc *proc = vma->vm_private_data;
 	binder_debug(BINDER_DEBUG_OPEN_CLOSE,
-		     "binder: %d close vm area %lx-%lx (%ld K) vma %lx pagep %lx\n",
+		     "binder: %d close vm area %lx-%lx (%ld K) vma %llx pagep %lx\n",
 		     proc->pid, vma->vm_start, vma->vm_end,
-		     (vma->vm_end - vma->vm_start) / SZ_1K, vma->vm_flags,
+		     (vma->vm_end - vma->vm_start) / SZ_1K,
+		     (__force u64)vma->vm_flags,
 		     (unsigned long)pgprot_val(vma->vm_page_prot));
 	proc->vma = NULL;
 	proc->vma_vm_mm = NULL;
@@ -2797,9 +2799,10 @@ static int binder_mmap(struct file *filp, struct vm_area_struct *vma)
 		vma->vm_end = vma->vm_start + SZ_4M;
 
 	binder_debug(BINDER_DEBUG_OPEN_CLOSE,
-		     "binder_mmap: %d %lx-%lx (%ld K) vma %lx pagep %lx\n",
+		     "binder_mmap: %d %lx-%lx (%ld K) vma %llx pagep %lx\n",
 		     proc->pid, vma->vm_start, vma->vm_end,
-		     (vma->vm_end - vma->vm_start) / SZ_1K, vma->vm_flags,
+		     (vma->vm_end - vma->vm_start) / SZ_1K,
+		     (__force u64)vma->vm_flags,
 		     (unsigned long)pgprot_val(vma->vm_page_prot));
 
 	if (vma->vm_flags & FORBIDDEN_MMAP_FLAGS) {
diff --git a/drivers/staging/tidspbridge/core/tiomap3430.c b/drivers/staging/tidspbridge/core/tiomap3430.c
index 7862513..328a9ab 100644
--- a/drivers/staging/tidspbridge/core/tiomap3430.c
+++ b/drivers/staging/tidspbridge/core/tiomap3430.c
@@ -1216,9 +1216,9 @@ static int bridge_brd_mem_map(struct bridge_dev_context *dev_ctxt,
 	if (vma)
 		dev_dbg(bridge,
 			"VMAfor UserBuf: ul_mpu_addr=%x, ul_num_bytes=%x, "
-			"vm_start=%lx, vm_end=%lx, vm_flags=%lx\n", ul_mpu_addr,
+			"vm_start=%lx, vm_end=%lx, vm_flags=%llx\n", ul_mpu_addr,
 			ul_num_bytes, vma->vm_start, vma->vm_end,
-			vma->vm_flags);
+			(__force u64)vma->vm_flags);
 
 	/*
 	 * It is observed that under some circumstances, the user buffer is
@@ -1230,9 +1230,9 @@ static int bridge_brd_mem_map(struct bridge_dev_context *dev_ctxt,
 		vma = find_vma(mm, vma->vm_end + 1);
 		dev_dbg(bridge,
 			"VMA for UserBuf ul_mpu_addr=%x ul_num_bytes=%x, "
-			"vm_start=%lx, vm_end=%lx, vm_flags=%lx\n", ul_mpu_addr,
+			"vm_start=%lx, vm_end=%lx, vm_flags=%llx\n", ul_mpu_addr,
 			ul_num_bytes, vma->vm_start, vma->vm_end,
-			vma->vm_flags);
+			(__force u64)vma->vm_flags);
 	}
 	if (!vma) {
 		pr_err("%s: Failed to get VMA region for 0x%x (%d)\n",
@@ -1302,11 +1302,12 @@ static int bridge_brd_mem_map(struct bridge_dev_context *dev_ctxt,
 			} else {
 				pr_err("DSPBRIDGE: get_user_pages FAILED,"
 				       "MPU addr = 0x%x,"
-				       "vma->vm_flags = 0x%lx,"
+				       "vma->vm_flags = 0x%llx,"
 				       "get_user_pages Err"
 				       "Value = %d, Buffer"
 				       "size=0x%x\n", ul_mpu_addr,
-				       vma->vm_flags, pg_num, ul_num_bytes);
+				       (__force u64)vma->vm_flags,
+				       pg_num, ul_num_bytes);
 				status = -EPERM;
 				break;
 			}
diff --git a/drivers/staging/tidspbridge/rmgr/drv_interface.c b/drivers/staging/tidspbridge/rmgr/drv_interface.c
index 3cac014..f7ea4af 100644
--- a/drivers/staging/tidspbridge/rmgr/drv_interface.c
+++ b/drivers/staging/tidspbridge/rmgr/drv_interface.c
@@ -265,9 +265,9 @@ static int bridge_mmap(struct file *filp, struct vm_area_struct *vma)
 	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
 
 	dev_dbg(bridge, "%s: vm filp %p start %lx end %lx page_prot %ulx "
-		"flags %lx\n", __func__, filp,
+		"flags %llx\n", __func__, filp,
 		vma->vm_start, vma->vm_end, vma->vm_page_prot,
-		vma->vm_flags);
+		(__force u64)vma->vm_flags);
 
 	status = remap_pfn_range(vma, vma->vm_start, vma->vm_pgoff,
 				 vma->vm_end - vma->vm_start,
diff --git a/fs/binfmt_elf_fdpic.c b/fs/binfmt_elf_fdpic.c
index c64bf5e..49a85b7 100644
--- a/fs/binfmt_elf_fdpic.c
+++ b/fs/binfmt_elf_fdpic.c
@@ -1215,7 +1215,8 @@ static int maydump(struct vm_area_struct *vma, unsigned long mm_flags)
 
 	/* Do not dump I/O mapped devices or special mappings */
 	if (vma->vm_flags & (VM_IO | VM_RESERVED)) {
-		kdcore("%08lx: %08lx: no (IO)", vma->vm_start, vma->vm_flags);
+		kdcore("%08lx: %08llx: no (IO)", vma->vm_start,
+		       (__force u64)vma->vm_flags);
 		return 0;
 	}
 
@@ -1223,7 +1224,8 @@ static int maydump(struct vm_area_struct *vma, unsigned long mm_flags)
 	 * them either. "dump_write()" can't handle it anyway.
 	 */
 	if (!(vma->vm_flags & VM_READ)) {
-		kdcore("%08lx: %08lx: no (!read)", vma->vm_start, vma->vm_flags);
+		kdcore("%08lx: %08llx: no (!read)", vma->vm_start,
+		       (__force u64)vma->vm_flags);
 		return 0;
 	}
 
@@ -1231,14 +1233,16 @@ static int maydump(struct vm_area_struct *vma, unsigned long mm_flags)
 	if (vma->vm_flags & VM_SHARED) {
 		if (vma->vm_file->f_path.dentry->d_inode->i_nlink == 0) {
 			dump_ok = test_bit(MMF_DUMP_ANON_SHARED, &mm_flags);
-			kdcore("%08lx: %08lx: %s (share)", vma->vm_start,
-			       vma->vm_flags, dump_ok ? "yes" : "no");
+			kdcore("%08lx: %08llx: %s (share)", vma->vm_start,
+			       (__force u64)vma->vm_flags,
+			       dump_ok ? "yes" : "no");
 			return dump_ok;
 		}
 
 		dump_ok = test_bit(MMF_DUMP_MAPPED_SHARED, &mm_flags);
-		kdcore("%08lx: %08lx: %s (share)", vma->vm_start,
-		       vma->vm_flags, dump_ok ? "yes" : "no");
+		kdcore("%08lx: %08llx: %s (share)", vma->vm_start,
+		       (__force u64)vma->vm_flags,
+		       dump_ok ? "yes" : "no");
 		return dump_ok;
 	}
 
@@ -1246,14 +1250,16 @@ static int maydump(struct vm_area_struct *vma, unsigned long mm_flags)
 	/* By default, if it hasn't been written to, don't write it out */
 	if (!vma->anon_vma) {
 		dump_ok = test_bit(MMF_DUMP_MAPPED_PRIVATE, &mm_flags);
-		kdcore("%08lx: %08lx: %s (!anon)", vma->vm_start,
-		       vma->vm_flags, dump_ok ? "yes" : "no");
+		kdcore("%08lx: %08llx: %s (!anon)", vma->vm_start,
+		       (__force u64)vma->vm_flags,
+		       dump_ok ? "yes" : "no");
 		return dump_ok;
 	}
 #endif
 
 	dump_ok = test_bit(MMF_DUMP_ANON_PRIVATE, &mm_flags);
-	kdcore("%08lx: %08lx: %s", vma->vm_start, vma->vm_flags,
+	kdcore("%08lx: %08llx: %s", vma->vm_start,
+	       (__force u64)vma->vm_flags,
 	       dump_ok ? "yes" : "no");
 	return dump_ok;
 }
diff --git a/mm/memory.c b/mm/memory.c
index b1c7c98..ee85fc4 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -705,8 +705,9 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
 	if (page)
 		dump_page(page);
 	printk(KERN_ALERT
-		"addr:%p vm_flags:%08lx anon_vma:%p mapping:%p index:%lx\n",
-		(void *)addr, vma->vm_flags, vma->anon_vma, mapping, index);
+		"addr:%p vm_flags:%08llx anon_vma:%p mapping:%p index:%lx\n",
+		(void *)addr, (__force u64)vma->vm_flags,
+		vma->anon_vma, mapping, index);
 	/*
 	 * Choose text because data symbols depend on CONFIG_KALLSYMS_ALL=y
 	 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
