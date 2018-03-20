Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 30C5D6B0003
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 17:32:01 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id k13-v6so1453970oib.4
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 14:32:01 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id d61-v6si766641otb.408.2018.03.20.14.31.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 14:31:59 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC PATCH 1/8] mm: mmap: unmap large mapping by section
Date: Wed, 21 Mar 2018 05:31:19 +0800
Message-Id: <1521581486-99134-2-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
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

It is because munmap holds mmap_sem from very beginning to all the way
down to the end, and doesn't release it in the middle. When unmapping
large mapping, it may take long time (take ~18 seconds to unmap 320GB
mapping with every single page mapped on an idle machine).

Since unmapping does't require any atomicity, so here unmap large
mapping (> HPAGE_PUD_SIZE) section by section, and release mmap_sem for
unmapping every HPAGE_PUD_SIZE if mmap_sem is contended and the call
path is fine to be interrupted controlled by "atomic", newly added
parameter to do_munmap(). "false" means it is fine to do unlock/relock
to mmap_sem in the middle.

Not only munmap may benefit from this change, but also
mremap/shm since they all call do_munmap() to do the real work.

The below is some regression and performance data collected on a machine
with 32 cores of E5-2680 @ 2.70GHz and 384GB memory.

Measurement of SyS_munmap() execution time:
  size        pristine        patched        delta
  80GB       5008377 us      4905841 us       -2%
  160GB      9129243 us      9145306 us       +0.18%
  320GB      17915310 us     17990174 us      +0.42%

Throughput of page faults (#/s) with vm-scalability:
                    pristine         patched         delta
mmap-pread-seq       554894           563517         +1.6%
mmap-pread-seq-mt    581232           580772         -0.079%
mmap-xread-seq-mt    99182            105400         +6.3%

Throughput of page faults (#/s) with the below stress-ng test:
stress-ng --mmap 0 --mmap-bytes 80G --mmap-file --metrics --perf
--timeout 600s
        pristine         patched          delta
         100165           108396          +8.2%

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/mm.h |  2 +-
 mm/mmap.c          | 40 ++++++++++++++++++++++++++++++++++++++--
 2 files changed, 39 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ad06d42..2e447d4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2212,7 +2212,7 @@ extern unsigned long do_mmap(struct file *file, unsigned long addr,
 	vm_flags_t vm_flags, unsigned long pgoff, unsigned long *populate,
 	struct list_head *uf);
 extern int do_munmap(struct mm_struct *, unsigned long, size_t,
-		     struct list_head *uf);
+		     struct list_head *uf, bool atomic);
 
 static inline unsigned long
 do_mmap_pgoff(struct file *file, unsigned long addr,
diff --git a/mm/mmap.c b/mm/mmap.c
index 9efdc021..ad6ae7a 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2632,8 +2632,8 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
  * work.  This now handles partial unmappings.
  * Jeremy Fitzhardinge <jeremy@goop.org>
  */
-int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
-	      struct list_head *uf)
+static int do_munmap_range(struct mm_struct *mm, unsigned long start,
+			   size_t len, struct list_head *uf)
 {
 	unsigned long end;
 	struct vm_area_struct *vma, *prev, *last;
@@ -2733,6 +2733,42 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 	return 0;
 }
 
+int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
+	      struct list_head *uf, bool atomic)
+{
+	int ret = 0;
+	size_t step = HPAGE_PUD_SIZE;
+
+	/*
+	 * unmap large mapping (> huge pud size) section by section
+	 * in order to give mmap_sem waiters a chance to acquire it.
+	 */
+	if (len <= step)
+		ret = do_munmap_range(mm, start, len, uf);
+	else {
+		do {
+			ret = do_munmap_range(mm, start, step, uf);
+			if (ret < 0)
+				break;
+
+			if (rwsem_is_contended(&mm->mmap_sem) && !atomic &&
+			    need_resched()) {
+				VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
+				up_write(&mm->mmap_sem);
+				cond_resched();
+				down_write(&mm->mmap_sem);
+			}
+
+			start += step;
+			len -= step;
+			if (len <= step)
+				step = len;
+		} while (len > 0);
+	}
+
+	return ret;
+}
+
 int vm_munmap(unsigned long start, size_t len)
 {
 	int ret;
-- 
1.8.3.1
