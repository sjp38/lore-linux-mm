Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9B9B68E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 13:04:11 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id v9-v6so3066762pff.4
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 10:04:11 -0700 (PDT)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id 5-v6si22253504plt.342.2018.09.19.10.04.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Sep 2018 10:04:09 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [v11 PATCH 1/3] mm: mmap: zap pages with read mmap_sem in munmap
Date: Thu, 20 Sep 2018 01:03:39 +0800
Message-Id: <1537376621-51150-2-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1537376621-51150-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1537376621-51150-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, vbabka@suse.cz, kirill@shutemov.name, akpm@linux-foundation.org
Cc: dave.hansen@intel.com, oleg@redhat.com, srikar@linux.vnet.ibm.com, yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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

If the vma has VM_HUGETLB | VM_PFNMAP, they are considered as special
mappings. They will be handled by without downgrading mmap_sem in this
patch since they may update vm flags.

But, with the "detach vmas first" approach, the vmas have been detached
when vm flags are updated, so it sounds safe to update vm flags with
read mmap_sem for this specific case. So, VM_HUGETLB and VM_PFNMAP will
be handled by using the optimized path in the following separate patches
for bisectable sake.

Unmapping uprobe areas may need update mm flags (MMF_RECALC_UPROBES).
However it is fine to have false-positive MMF_RECALC_UPROBES according
to uprobes developer.

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
__vm_munmap() {
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
Suggested-by: Matthew Wilcox <willy@infradead.org>
Reviewed-by: Matthew Wilcox <willy@infradead.org>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/mmap.c | 59 ++++++++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 48 insertions(+), 11 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 5f2b2b1..982dd00 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2687,8 +2687,8 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
  * work.  This now handles partial unmappings.
  * Jeremy Fitzhardinge <jeremy@goop.org>
  */
-int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
-	      struct list_head *uf)
+static int __do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
+		       struct list_head *uf, bool downgrade)
 {
 	unsigned long end;
 	struct vm_area_struct *vma, *prev, *last;
@@ -2770,25 +2770,47 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 				mm->locked_vm -= vma_pages(tmp);
 				munlock_vma_pages_all(tmp);
 			}
+
+			/*
+			 * Unmapping vmas, which have VM_HUGETLB or VM_PFNMAP,
+			 * need get done with write mmap_sem held since they may
+			 * update vm_flags.
+			 */
+			if (downgrade &&
+			    (tmp->vm_flags & (VM_HUGETLB | VM_PFNMAP)))
+				downgrade = false;
+
 			tmp = tmp->vm_next;
 		}
 	}
 
-	/*
-	 * Remove the vma's, and unmap the actual pages
-	 */
+	/* Detach vmas from rbtree */
 	detach_vmas_to_be_unmapped(mm, vma, prev, end);
-	unmap_region(mm, vma, prev, start, end);
 
+	/*
+	 * mpx unmap needs to be called with mmap_sem held for write.
+	 * It is safe to call it before unmap_region().
+	 */
 	arch_unmap(mm, vma, start, end);
 
+	if (downgrade)
+		downgrade_write(&mm->mmap_sem);
+
+	unmap_region(mm, vma, prev, start, end);
+
 	/* Fix up all other VM information */
 	remove_vma_list(mm, vma);
 
-	return 0;
+	return downgrade ? 1 : 0;
 }
 
-int vm_munmap(unsigned long start, size_t len)
+int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
+	      struct list_head *uf)
+{
+	return __do_munmap(mm, start, len, uf, false);
+}
+
+static int __vm_munmap(unsigned long start, size_t len, bool downgrade)
 {
 	int ret;
 	struct mm_struct *mm = current->mm;
@@ -2797,17 +2819,32 @@ int vm_munmap(unsigned long start, size_t len)
 	if (down_write_killable(&mm->mmap_sem))
 		return -EINTR;
 
-	ret = do_munmap(mm, start, len, &uf);
-	up_write(&mm->mmap_sem);
+	ret = __do_munmap(mm, start, len, &uf, downgrade);
+	/*
+	 * Returning 1 indicates mmap_sem is downgraded.
+	 * But 1 is not legal return value of vm_munmap() and munmap(), reset
+	 * it to 0 before return.
+	 */
+	if (ret == 1) {
+		up_read(&mm->mmap_sem);
+		ret = 0;
+	} else
+		up_write(&mm->mmap_sem);
+
 	userfaultfd_unmap_complete(mm, &uf);
 	return ret;
 }
+
+int vm_munmap(unsigned long start, size_t len)
+{
+	return __vm_munmap(start, len, false);
+}
 EXPORT_SYMBOL(vm_munmap);
 
 SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
 {
 	profile_munmap(addr);
-	return vm_munmap(addr, len);
+	return __vm_munmap(addr, len, true);
 }
 
 
-- 
1.8.3.1
