Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 731C06B026E
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 19:35:21 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g26-v6so12205493pfo.7
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 16:35:21 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id 7-v6si17937241plc.179.2018.07.10.16.35.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 16:35:19 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC v4 PATCH 3/3] mm: mmap: zap pages with read mmap_sem for large mapping
Date: Wed, 11 Jul 2018 07:34:09 +0800
Message-Id: <1531265649-93433-4-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1531265649-93433-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1531265649-93433-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When running some mmap/munmap scalability tests with large memory (i.e.
> 300GB), the below hung task issue may happen occasionally.

INFO: task ps:14018 blocked for more than 120 seconds.
       Tainted: G            E 4.9.79-009.ali3000.alios7.x86_64 #1
 "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
message.
 ps              D    0 14018      1 0x00000004
  ffff885582f84000 ffff885e8682f000 ffff880972943000 ffff885ebf499bc0
  ffff8828ee120000 ffffc900349bfca8 ffffffff817154d0 0000000000000040
  00ffffff812f872a ffff885ebf499bc0 024000d000948300 ffff880972943000
 Call Trace:
  [<ffffffff817154d0>] ? __schedule+0x250/0x730
  [<ffffffff817159e6>] schedule+0x36/0x80
  [<ffffffff81718560>] rwsem_down_read_failed+0xf0/0x150
  [<ffffffff81390a28>] call_rwsem_down_read_failed+0x18/0x30
  [<ffffffff81717db0>] down_read+0x20/0x40
  [<ffffffff812b9439>] proc_pid_cmdline_read+0xd9/0x4e0
  [<ffffffff81253c95>] ? do_filp_open+0xa5/0x100
  [<ffffffff81241d87>] __vfs_read+0x37/0x150
  [<ffffffff812f824b>] ? security_file_permission+0x9b/0xc0
  [<ffffffff81242266>] vfs_read+0x96/0x130
  [<ffffffff812437b5>] SyS_read+0x55/0xc0
  [<ffffffff8171a6da>] entry_SYSCALL_64_fastpath+0x1a/0xc5

It is because munmap holds mmap_sem exclusively from very beginning to
all the way down to the end, and doesn't release it in the middle. When
unmapping large mapping, it may take long time (take ~18 seconds to unmap
320GB mapping with every single page mapped on an idle machine).

Zapping pages is the most time consuming part, according to the
suggestion from Michal Hocko [1], zapping pages can be done with holding
read mmap_sem, like what MADV_DONTNEED does. Then re-acquire write
mmap_sem to cleanup vmas.

But, some part may need write mmap_sem, for example, vma splitting. So,
the design is as follows:
	acquire write mmap_sem
	lookup vmas (find and split vmas)
	set VM_DEAD flags
	deal with special mappings
	downgrade_write

	zap pages
	release mmap_sem

	retake mmap_sem exclusively
	cleanup vmas
	release mmap_sem

Define large mapping size thresh as PUD size, just zap pages with read
mmap_sem for mappings which are >= PUD_SIZE. So, unmapping less than
PUD_SIZE area still goes with the regular path.

All vmas which will be zapped soon will have VM_DEAD flag set. Since PF
may race with munmap, may just return the right content or SIGSEGV before
the optimization, but with the optimization, it may return a zero page.
Here use this flag to mark PF to this area is unstable, will trigger
SIGSEGV, in order to prevent from the unexpected 3rd state.

If the vma has VM_LOCKED | VM_HUGETLB | VM_PFNMAP or uprobe, they are
considered as special mappings. They will be dealt with before zapping
pages with write mmap_sem held. Basically, just update vm_flags.

And, since they are also manipulated by unmap_single_vma() which is
called by zap_page_range() with read mmap_sem held in this case, to
prevent from updating vm_flags in read critical section and considering
the complexity of coding, just check if VM_DEAD is set, then skip any
VM_DEAD area since they should be handled before.

When cleaning up vmas, just call do_munmap() without carrying vmas from
the above to avoid race condition, since the address space might be
already changed under our feet after retaking exclusive lock.

For the time being, just do this in munmap syscall path. Other
vm_munmap() or do_munmap() call sites (i.e mmap, mremap, etc) remain intact
for stability reason. And, this optimization is 64 bit only.

With the patches, exclusive mmap_sem hold time when munmap a 80GB
address space on a machine with 32 cores of E5-2680 @ 2.70GHz dropped to us
level from second.

		w/o		w/
do_munmap    2165433 us      35148.923 us
SyS_munmap   2165369 us      2166535 us

Here the excution time of do_munmap is used to evaluate the time of
holding exclusive lock.

[1] https://lwn.net/Articles/753269/

Cc: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/memory.c |  18 +++++++++--
 mm/mmap.c   | 101 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 115 insertions(+), 4 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 250547f..d343130 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1556,10 +1556,10 @@ static void unmap_single_vma(struct mmu_gather *tlb,
 	if (end <= vma->vm_start)
 		return;
 
-	if (vma->vm_file)
+	if (vma->vm_file && !(vma->vm_flags & VM_DEAD))
 		uprobe_munmap(vma, start, end);
 
-	if (unlikely(vma->vm_flags & VM_PFNMAP))
+	if (unlikely(vma->vm_flags & VM_PFNMAP) && !(vma->vm_flags & VM_DEAD))
 		untrack_pfn(vma, 0, 0);
 
 	if (start != end) {
@@ -1577,7 +1577,19 @@ static void unmap_single_vma(struct mmu_gather *tlb,
 			 */
 			if (vma->vm_file) {
 				i_mmap_lock_write(vma->vm_file->f_mapping);
-				__unmap_hugepage_range_final(tlb, vma, start, end, NULL);
+				if (vma->vm_flags & VM_DEAD)
+					/*
+					 * The vma is being unmapped with read
+					 * mmap_sem.
+					 * Can't update vm_flags, it has been
+					 * updated before with exclusive lock
+					 * held.
+					 */
+					__unmap_hugepage_range(tlb, vma, start,
+							       end, NULL);
+				else
+					__unmap_hugepage_range_final(tlb, vma,
+							start, end, NULL);
 				i_mmap_unlock_write(vma->vm_file->f_mapping);
 			}
 		} else
diff --git a/mm/mmap.c b/mm/mmap.c
index 2504094..169b143 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2778,6 +2778,91 @@ static inline void munmap_mlock_vma(struct vm_area_struct *vma,
 	}
 }
 
+/*
+ * Unmap large mapping early with acquiring read mmap_sem
+ *
+ * uf is the list for userfaultfd
+ */
+static int do_munmap_zap_early(struct mm_struct *mm, unsigned long start,
+			       size_t len, struct list_head *uf)
+{
+	unsigned long end = 0;
+	struct vm_area_struct *start_vma = NULL, *prev, *vma;
+	int ret = 0;
+
+	if (!munmap_addr_sanity(start, len))
+		return -EINVAL;
+
+	len = PAGE_ALIGN(len);
+
+	end = start + len;
+
+	if (len >= PUD_SIZE) {
+		/*
+		 * need write mmap_sem to split vma and set VM_DEAD flag
+		 * splitting vma up-front to save PITA to clean if it is failed
+		 */
+		if (down_write_killable(&mm->mmap_sem))
+			return -EINTR;
+
+		ret = munmap_lookup_vma(mm, &start_vma, &prev, start, end);
+		if (ret != 1)
+			goto out;
+
+		/* This ret value might be returned, so reset it */
+		ret = 0;
+
+		if (unlikely(uf)) {
+			ret = userfaultfd_unmap_prep(start_vma, start, end, uf);
+			if (ret)
+				goto out;
+		}
+
+		/* Handle mlocked vmas */
+		if (mm->locked_vm)
+			munmap_mlock_vma(start_vma, end);
+
+		/*
+		 * set VM_DEAD flag before tear down them.
+		 * page fault on VM_DEAD vma will trigger SIGSEGV.
+		 *
+		 * And, clear uprobe, VM_PFNMAP and hugetlb mapping in advance.
+		 */
+		vma = start_vma;
+		for ( ; vma && vma->vm_start < end; vma = vma->vm_next) {
+			vma->vm_flags |= VM_DEAD;
+
+			if (vma->vm_file)
+				uprobe_munmap(vma, vma->vm_start, vma->vm_end);
+			if (unlikely(vma->vm_flags & VM_PFNMAP))
+				untrack_pfn(vma, 0, 0);
+			if (is_vm_hugetlb_page(vma))
+				vma->vm_flags &= ~VM_MAYSHARE;
+		}
+
+		downgrade_write(&mm->mmap_sem);
+
+		/* zap mappings with read mmap_sem */
+		zap_page_range(start_vma, start, len);
+		/* indicates early zap is success */
+		up_read(&mm->mmap_sem);
+	}
+
+	/* hold write mmap_sem for vma cleanup or regular path */
+	if (down_write_killable(&mm->mmap_sem))
+		return -EINTR;
+	/*
+	 * call do_munmap() for vma cleanup too in order to not carry vma
+	 * to here since the address space might be changed under our
+	 * feet before we retake the exclusive lock.
+	 */
+	ret = do_munmap(mm, start, len, uf);
+
+out:
+	up_write(&mm->mmap_sem);
+	return ret;
+}
+
 /* Munmap is split into 2 main parts -- this part which finds
  * what needs doing, and the areas themselves, which do the
  * work.  This now handles partial unmappings.
@@ -2836,6 +2921,17 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 	return 0;
 }
 
+static int vm_munmap_zap_early(unsigned long start, size_t len)
+{
+	int ret;
+	struct mm_struct *mm = current->mm;
+	LIST_HEAD(uf);
+
+	ret = do_munmap_zap_early(mm, start, len, &uf);
+	userfaultfd_unmap_complete(mm, &uf);
+	return ret;
+}
+
 int vm_munmap(unsigned long start, size_t len)
 {
 	int ret;
@@ -2855,10 +2951,13 @@ int vm_munmap(unsigned long start, size_t len)
 SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
 {
 	profile_munmap(addr);
+#ifdef CONFIG_64BIT
+	return vm_munmap_zap_early(addr, len);
+#else
 	return vm_munmap(addr, len);
+#endif
 }
 
-
 /*
  * Emulation of deprecated remap_file_pages() syscall.
  */
-- 
1.8.3.1
