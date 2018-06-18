Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 84CE16B0008
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 19:34:52 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id o19-v6so5685118pgn.14
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 16:34:52 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id x3-v6si15747508plb.478.2018.06.18.16.34.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 16:34:51 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC v2 PATCH 2/2] mm: mmap: zap pages with read mmap_sem for large mapping
Date: Tue, 19 Jun 2018 07:34:16 +0800
Message-Id: <1529364856-49589-3-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1529364856-49589-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1529364856-49589-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org
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

Zapping pages is the most time consuming part, according to the
suggestion from Michal Hock [1], zapping pages can be done with holding
read mmap_sem, like what MADV_DONTNEED does. Then re-acquire write
mmap_sem to manipulate vmas.

Define large mapping size thresh as PUD size or 1GB, just zap pages with
read mmap_sem for mappings which are >= thresh value.

If the vma has VM_LOCKED | VM_HUGETLB | VM_PFNMAP or uprobe, then just
fallback to regular path since unmapping those mappings need acquire
write mmap_sem.

For the time being, just do this in munmap syscall path. Other
vm_munmap() or do_munmap() call sites remain intact since it sounds the
complexity to handle race conditions outpace the benefits.

The below is some regression and performance data collected on a machine
with 32 cores of E5-2680 @ 2.70GHz and 384GB memory.

With the patched kernel, write mmap_sem hold time is dropped to us level
from second.

Throughput of page faults (#/s) with the below stress-ng test:
stress-ng --mmap 0 --mmap-bytes 80G --mmap-file --metrics --perf
--timeout 600s
        pristine         patched          delta
       89.41K/sec       97.29K/sec        +8.8%

[1] https://lwn.net/Articles/753269/

Cc: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/mmap.c | 148 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 147 insertions(+), 1 deletion(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index fc41c05..e84f80c 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2686,6 +2686,141 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 	return __split_vma(mm, vma, addr, new_below);
 }
 
+/* Consider PUD size or 1GB mapping as large mapping */
+#ifdef HPAGE_PUD_SIZE
+#define LARGE_MAP_THRESH	HPAGE_PUD_SIZE
+#else
+#define LARGE_MAP_THRESH	(1 * 1024 * 1024 * 1024)
+#endif
+
+/* Unmap large mapping early with acquiring read mmap_sem */
+static int do_munmap_zap_early(struct mm_struct *mm, unsigned long start,
+			       size_t len, struct list_head *uf)
+{
+	unsigned long end = 0;
+	struct vm_area_struct *vma = NULL, *prev, *last, *tmp;
+	bool success = false;
+	int ret = 0;
+
+	if ((offset_in_page(start)) || start > TASK_SIZE || len > TASK_SIZE - start)
+		return -EINVAL;
+
+	len = (PAGE_ALIGN(len));
+	if (len == 0)
+		return -EINVAL;
+
+	/* Just deal with uf in regular path */
+	if (unlikely(uf))
+		goto regular_path;
+
+	if (len >= LARGE_MAP_THRESH) {
+		down_read(&mm->mmap_sem);
+		vma = find_vma(mm, start);
+		if (!vma) {
+			up_read(&mm->mmap_sem);
+			return 0;
+		}
+
+		prev = vma->vm_prev;
+
+		end = start + len;
+		if (vma->vm_start > end) {
+			up_read(&mm->mmap_sem);
+			return 0;
+		}
+
+		if (start > vma->vm_start) {
+			int error;
+
+			if (end < vma->vm_end &&
+			    mm->map_count > sysctl_max_map_count) {
+				up_read(&mm->mmap_sem);
+				return -ENOMEM;
+			}
+
+			error = __split_vma(mm, vma, start, 0);
+			if (error) {
+				up_read(&mm->mmap_sem);
+				return error;
+			}
+			prev = vma;
+		}
+
+		last = find_vma(mm, end);
+		if (last && end > last->vm_start) {
+			int error = __split_vma(mm, last, end, 1);
+
+			if (error) {
+				up_read(&mm->mmap_sem);
+				return error;
+			}
+		}
+		vma = prev ? prev->vm_next : mm->mmap;
+
+		/*
+		 * Unmapping vmas, which has VM_LOCKED|VM_HUGETLB|VM_PFNMAP
+		 * flag set or has uprobes set, need acquire write map_sem,
+		 * so skip them in early zap. Just deal with such mapping in
+		 * regular path.
+		 * Borrow can_madv_dontneed_vma() to check the conditions.
+		 */
+		tmp = vma;
+		while (tmp && tmp->vm_start < end) {
+			if (!can_madv_dontneed_vma(tmp) ||
+			    vma_has_uprobes(tmp, start, end))
+				goto sem_drop;
+			tmp = tmp->vm_next;
+		}
+
+		unmap_region(mm, vma, prev, start, end);
+		/* indicates early zap is success */
+		success = true;
+
+sem_drop:
+		up_read(&mm->mmap_sem);
+	}
+
+regular_path:
+	/* hold write mmap_sem for vma manipulation or regular path */
+	if (down_write_killable(&mm->mmap_sem))
+		return -EINTR;
+	if (success) {
+		/* vmas have been zapped, here just deal with loose end */
+		detach_vmas_to_be_unmapped(mm, vma, prev, end);
+		arch_unmap(mm, vma, start, end);
+		remove_vma_list(mm, vma);
+	} else {
+		/* vma is VM_LOCKED|VM_HUGETLB|VM_PFNMAP or has uprobe */
+		if (vma) {
+			if (unlikely(uf)) {
+				int ret = userfaultfd_unmap_prep(vma, start,
+							end, uf);
+				if (ret)
+					goto out;
+			}
+			if (mm->locked_vm) {
+				tmp = vma;
+				while (tmp && tmp->vm_start < end) {
+					if (tmp->vm_flags & VM_LOCKED) {
+						mm->locked_vm -= vma_pages(tmp);
+						munlock_vma_pages_all(tmp);
+					}
+					tmp = tmp->vm_next;
+				}
+			}
+			detach_vmas_to_be_unmapped(mm, vma, prev, end);
+			unmap_region(mm, vma, prev, start, end);
+			remove_vma_list(mm, vma);
+		} else
+			/* When mapping size < LARGE_MAP_THRESH */
+			ret = do_munmap(mm, start, len, uf);
+	}
+
+out:
+	up_write(&mm->mmap_sem);
+	return ret;
+}
+
 /* Munmap is split into 2 main parts -- this part which finds
  * what needs doing, and the areas themselves, which do the
  * work.  This now handles partial unmappings.
@@ -2792,6 +2927,17 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
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
@@ -2811,7 +2957,7 @@ int vm_munmap(unsigned long start, size_t len)
 SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
 {
 	profile_munmap(addr);
-	return vm_munmap(addr, len);
+	return vm_munmap_zap_early(addr, len);
 }
 
 
-- 
1.8.3.1
