Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id EB2B48E0007
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 16:25:05 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id z72-v6so5387068itc.8
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 13:25:05 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id b72-v6si1236866jad.122.2018.09.12.13.25.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 13:25:04 -0700 (PDT)
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Subject: [PATCH V2 3/6] Provide process address range to numa node id mapping
Date: Wed, 12 Sep 2018 13:24:01 -0700
Message-Id: <1536783844-4145-4-git-send-email-prakash.sangappa@oracle.com>
In-Reply-To: <1536783844-4145-1-git-send-email-prakash.sangappa@oracle.com>
References: <1536783844-4145-1-git-send-email-prakash.sangappa@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: dave.hansen@intel.com, mhocko@suse.com, nao.horiguchi@gmail.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, khandual@linux.vnet.ibm.com, steven.sistare@oracle.com, prakash.sangappa@oracle.com

This patch provides process address range to numa node information
thru /proc/<pid>/numa_vamaps file. For address ranges not having
any pages mapped, a '-' is printed instead of the numa node id.

Following is the sample of the file format

00400000-00410000 N1
00410000-0047f000 N0
0047f000-00480000 N2
00480000-00481000 -
00481000-004a0000 N0
004a0000-004a2000 -
004a2000-004aa000 N2
004aa000-004ad000 N0
004ad000-004ae000 -
..

Signed-off-by: Prakash Sangappa <prakash.sangappa@oracle.com>
Reviewed-by: Steve Sistare <steven.sistare@oracle.com>
---
 fs/proc/task_mmu.c | 158 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 158 insertions(+)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 02b553c..1371e379 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1845,6 +1845,162 @@ static int show_numa_map(struct seq_file *m, void *v)
 	return 0;
 }
 
+static int gather_hole_info_vamap(unsigned long start, unsigned long end,
+			struct mm_walk *walk)
+{
+       struct numa_maps *md = walk->private;
+       struct vm_area_struct *vma = walk->vma;
+
+       /*
+	* If in a nid, end walk at hole start.
+	* If no nid and vma changes, end walk at next vma start.
+	*/
+	if (md->nid >= 0 || vma != find_vma(walk->mm, start)) {
+		md->nextaddr = start;
+		return 1;
+	}
+
+	if (md->nid == NUMA_VAMAPS_NID_NONE)
+		md->nid = NUMA_VAMAPS_NID_NOPAGES;
+
+	return 0;
+}
+
+static int vamap_vprintf(struct numa_vamaps_private *nvm, const char *f, ...)
+{
+	va_list args;
+	int len, space;
+
+	space = NUMA_VAMAPS_BUFSZ - nvm->count;
+	va_start(args, f);
+	len = vsnprintf(nvm->buf + nvm->count, space, f, args);
+	va_end(args);
+	if (len < space) {
+		nvm->count += len;
+		return 0;
+	}
+	return 1;
+}
+
+/*
+ * Display va-range to numa node info via /proc
+ */
+static ssize_t numa_vamaps_read(struct file *file, char __user *buf,
+	size_t count, loff_t *ppos)
+{
+	struct numa_vamaps_private *nvm = file->private_data;
+	struct vm_area_struct *vma, *tailvma;
+	struct numa_maps *md = &nvm->md;
+	struct mm_struct *mm = nvm->mm;
+	u64 vm_start = nvm->vm_start;
+	size_t ucount;
+	struct mm_walk walk = {
+		.hugetlb_entry = gather_hugetlb_stats,
+		.pmd_entry = gather_pte_stats,
+		.pte_hole = gather_hole_info_vamap,
+		.private = md,
+		.mm = mm,
+	};
+	int ret = 0, copied = 0, done = 0;
+
+	if (!mm || !mmget_not_zero(mm))
+		return 0;
+
+	if (count <= 0)
+		goto out_mm;
+
+	/* First copy leftover contents in buffer */
+	if (nvm->from)
+		goto docopy;
+
+repeat:
+	down_read(&mm->mmap_sem);
+	vma = find_vma(mm, vm_start);
+	if (!vma) {
+		done = 1;
+		goto out;
+	}
+
+	if (vma->vm_start > vm_start)
+		vm_start = vma->vm_start;
+
+	while (nvm->count < count) {
+		u64 vm_end;
+
+		/* Ensure we start with an empty numa_maps statistics */
+		memset(md, 0, sizeof(*md));
+		md->nid = NUMA_VAMAPS_NID_NONE; /* invalid nodeid at start */
+		md->nextaddr = 0;
+		md->isvamaps = 1;
+
+		 if (walk_page_range(vm_start, vma->vm_end, &walk) < 0)
+			break;
+
+		/* nextaddr ends the range. if 0, reached the vma end */
+		vm_end = (md->nextaddr ? md->nextaddr : vma->vm_end);
+
+		 /* break if buffer full */
+		if (md->nid >= 0 && md->node[md->nid]) {
+		   if (vamap_vprintf(nvm, "%08lx-%08lx N%ld\n", vm_start,
+			vm_end, md->nid))
+			break;
+		} else if (vamap_vprintf(nvm, "%08lx-%08lx - \n", vm_start,
+			vm_end)) {
+			break;
+		}
+
+		/* advance to next VA */
+		vm_start = vm_end;
+		if (vm_end == vma->vm_end) {
+			vma = vma->vm_next;
+			if (!vma) {
+				done = 1;
+				break;
+			}
+			vm_start = vma->vm_start;
+		}
+	}
+out:
+	/* last, add gate vma details */
+	if (!vma && (tailvma = get_gate_vma(mm)) != NULL &&
+		vm_start < tailvma->vm_end) {
+		done = 0;
+		if (!vamap_vprintf(nvm, "%08lx-%08lx - \n",
+		   tailvma->vm_start, tailvma->vm_end)) {
+			done = 1;
+			vm_start = tailvma->vm_end;
+		}
+	}
+
+	up_read(&mm->mmap_sem);
+docopy:
+	ucount = min(count, nvm->count);
+	if (ucount && copy_to_user(buf, nvm->buf + nvm->from, ucount)) {
+		ret = -EFAULT;
+		goto out_mm;;
+	}
+	copied += ucount;
+	count -= ucount;
+	nvm->count -= ucount;
+	buf += ucount;
+	if (!done && count) {
+		nvm->from = 0;
+		goto repeat;
+	}
+	/* somthing left in the buffer */
+	if (nvm->count)
+		nvm->from += ucount;
+	else
+		nvm->from = 0;
+
+	nvm->vm_start = vm_start;
+	ret = copied;
+	*ppos +=  copied;
+out_mm:
+	mmput(mm);
+	return ret;
+}
+
 static const struct seq_operations proc_pid_numa_maps_op = {
 	.start  = m_start,
 	.next   = m_next,
@@ -1895,6 +2051,8 @@ const struct file_operations proc_pid_numa_maps_operations = {
 
 const struct file_operations proc_numa_vamaps_operations = {
 	.open		= numa_vamaps_open,
+	.read		= numa_vamaps_read,
+	.llseek		= noop_llseek,
 	.release	= numa_vamaps_release,
 };
 #endif /* CONFIG_NUMA */
-- 
2.7.4
