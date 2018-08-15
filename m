Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 418A16B0005
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 14:50:14 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id w11-v6so1123489plq.8
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 11:50:14 -0700 (PDT)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id a35-v6si20538241pla.27.2018.08.15.11.50.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Aug 2018 11:50:12 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC v8 PATCH 3/5] mm: mmap: zap pages with read mmap_sem in munmap
Date: Thu, 16 Aug 2018 02:49:48 +0800
Message-Id: <1534358990-85530-4-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1534358990-85530-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1534358990-85530-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, vbabka@suse.cz, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org
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
unmapping large mapping, it may take long time (take ~18 seconds to
unmap 320GB mapping with every single page mapped on an idle machine).

Zapping pages is the most time consuming part, according to the
suggestion from Michal Hocko [1], zapping pages can be done with holding
read mmap_sem, like what MADV_DONTNEED does. Then re-acquire write
mmap_sem to cleanup vmas.

But, some part may need write mmap_sem, for example, vma splitting. So,
the design is as follows:
        acquire write mmap_sem
        lookup vmas (find and split vmas)
        deal with special mappings
        detach vmas
        downgrade_write

        zap pages
        free page tables
        release mmap_sem

The vm events with read mmap_sem may come in during page zapping, but
since vmas have been detached before, they, i.e. page fault, gup, etc,
will not be able to find valid vma, then just return SIGSEGV or -EFAULT
as expected.

If the vma has VM_HUGETLB | VM_PFNMAP or uprobe, they are considered as
special mappings. They will be handled by falling back to regular
do_munmap() with exclusive mmap_sem held in this patch since they may
update vm flags.
But, with the "detach vmas first" approach, the vmas have been detached
when vm flags are updated, so it sounds safe to update vm flags with
read mmap_sem for this specific case. So, VM_HUGETLB and VM_PFNMAP will
be handled by using the optimized path in the following separate patches
for bisectable sake. However, uprobes mappings will keep using regular
do_munmap() since unmapping uprobe areas may need update mm flags. It
might be not safe with just holding read mmap_sem even though affected
vmas have been detached.

With the "detach vmas first" approach we don't have to re-acquire
mmap_sem again to clean up vmas to avoid race window which might get the
address space changed since downgrade_write() doesn't release the lock
to lead regression, which simply downgrades to read lock.

And, since the lock acquire/release cost is managed to the minimum and
almost as same as before, the optimization could be extended to any size
of mapping without incurring significant penalty to small mappings.

For the time being, just do this in munmap syscall path. Other
vm_munmap() or do_munmap() call sites (i.e mmap, mremap, etc) remain
intact due to some implementation difficulties since they acquire write
mmap_sem from very beginning and hold it until the end, do_munmap()
might be called in the middle. But, the optimized do_munmap would like
to be called without mmap_sem held so that we can do the optimization.
So, if we want to do the similar optimization for mmap/mremap path, I'm
afraid we would have to redesign them. mremap might be called on very
large area depending on the usecases, the optimization to it will be
considered in the future.

With the patches, exclusive mmap_sem hold time when munmap a 80GB
address space on a machine with 32 cores of E5-2680 @ 2.70GHz dropped to
us level from second.

munmap_test-15002 [008]   594.380138: funcgraph_entry: |
vm_munmap_zap_rlock() {
munmap_test-15002 [008]   594.380146: funcgraph_entry:      !2485684 us
|    unmap_region();
munmap_test-15002 [008]   596.865836: funcgraph_exit:       !2485692 us
|  }

Here the excution time of unmap_region() is used to evaluate the time of
holding read mmap_sem, then the remaining time is used with holding
exclusive lock.

[1] https://lwn.net/Articles/753269/

Suggested-by: Michal Hocko <mhocko@kernel.org>
Suggested-by: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/mmap.c | 97 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 95 insertions(+), 2 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index f05f49b..e92f680 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2768,6 +2768,89 @@ static inline void munlock_vmas(struct vm_area_struct *vma,
 	}
 }
 
+/*
+ * Zap pages with read mmap_sem held
+ *
+ * uf is the list for userfaultfd
+ */
+static int do_munmap_zap_rlock(struct mm_struct *mm, unsigned long start,
+			       size_t len, struct list_head *uf)
+{
+	unsigned long end;
+	struct vm_area_struct *start_vma, *prev, *vma;
+	int ret = 0;
+
+	if (!addr_ok(start, len))
+		return -EINVAL;
+
+	len = PAGE_ALIGN(len);
+
+	end = start + len;
+
+	/*
+	 * Need write mmap_sem to split vmas and detach vmas
+	 * splitting vma up-front to save PITA to clean if it is failed
+	 */
+	if (down_write_killable(&mm->mmap_sem))
+		return -EINTR;
+
+	start_vma = munmap_lookup_vma(mm, start, end);
+	if (!start_vma)
+		goto out;
+	if (IS_ERR(start_vma)) {
+		ret = PTR_ERR(start_vma);
+		goto out;
+	}
+
+	prev = start_vma->vm_prev;
+
+	if (unlikely(uf)) {
+		ret = userfaultfd_unmap_prep(start_vma, start, end, uf);
+		if (ret)
+			goto out;
+	}
+
+	/*
+	 * Unmapping vmas, which have:
+	 *   VM_HUGETLB or
+	 *   VM_PFNMAP or
+	 *   uprobes
+	 * need get done with write mmap_sem held since they may update
+	 * vm_flags. Deal with such mappings with regular do_munmap() call.
+	 */
+	for (vma = start_vma; vma && vma->vm_start < end; vma = vma->vm_next) {
+		if ((vma->vm_file &&
+		    has_uprobes(vma, vma->vm_start, vma->vm_end)) ||
+		    (vma->vm_flags & (VM_HUGETLB | VM_PFNMAP)))
+			goto regular_path;
+	}
+
+	/* Handle mlocked vmas */
+	if (mm->locked_vm)
+		munlock_vmas(start_vma, end);
+
+	/* Detach vmas from rbtree */
+	detach_vmas_to_be_unmapped(mm, start_vma, prev, end);
+
+	downgrade_write(&mm->mmap_sem);
+
+	/* Zap mappings with read mmap_sem */
+	unmap_region(mm, start_vma, prev, start, end);
+
+	arch_unmap(mm, start_vma, start, end);
+	remove_vma_list(mm, start_vma);
+	up_read(&mm->mmap_sem);
+
+	return 0;
+
+regular_path:
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
@@ -2829,6 +2912,17 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 	return 0;
 }
 
+static int vm_munmap_zap_rlock(unsigned long start, size_t len)
+{
+	int ret;
+	struct mm_struct *mm = current->mm;
+	LIST_HEAD(uf);
+
+	ret = do_munmap_zap_rlock(mm, start, len, &uf);
+	userfaultfd_unmap_complete(mm, &uf);
+	return ret;
+}
+
 int vm_munmap(unsigned long start, size_t len)
 {
 	int ret;
@@ -2848,10 +2942,9 @@ int vm_munmap(unsigned long start, size_t len)
 SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
 {
 	profile_munmap(addr);
-	return vm_munmap(addr, len);
+	return vm_munmap_zap_rlock(addr, len);
 }
 
-
 /*
  * Emulation of deprecated remap_file_pages() syscall.
  */
-- 
1.8.3.1
