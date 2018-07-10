Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7D51F6B0006
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 09:48:22 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u18-v6so14005760pfh.21
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 06:48:22 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id r10-v6si15718933pgm.535.2018.07.10.06.48.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 06:48:20 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/2] mm: Fix vma_is_anonymous() false-positives
Date: Tue, 10 Jul 2018 16:48:20 +0300
Message-Id: <20180710134821.84709-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180710134821.84709-1-kirill.shutemov@linux.intel.com>
References: <20180710134821.84709-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, stable@vger.kernel.org

vma_is_anonymous() relies on ->vm_ops being NULL to detect anonymous
VMA. This is unreliable as ->mmap may not set ->vm_ops.

False-positive vma_is_anonymous() may lead to crashes:

	next ffff8801ce5e7040 prev ffff8801d20eca50 mm ffff88019c1e13c0
	prot 27 anon_vma ffff88019680cdd8 vm_ops 0000000000000000
	pgoff 0 file ffff8801b2ec2d00 private_data 0000000000000000
	flags: 0xff(read|write|exec|shared|mayread|maywrite|mayexec|mayshare)
	------------[ cut here ]------------
	kernel BUG at mm/memory.c:1422!
	invalid opcode: 0000 [#1] SMP KASAN
	CPU: 0 PID: 18486 Comm: syz-executor3 Not tainted 4.18.0-rc3+ #136
	Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google
	01/01/2011
	RIP: 0010:zap_pmd_range mm/memory.c:1421 [inline]
	RIP: 0010:zap_pud_range mm/memory.c:1466 [inline]
	RIP: 0010:zap_p4d_range mm/memory.c:1487 [inline]
	RIP: 0010:unmap_page_range+0x1c18/0x2220 mm/memory.c:1508
	Code: ff 31 ff 4c 89 e6 42 c6 04 33 f8 e8 92 dd d0 ff 4d 85 e4 0f 85 4a eb ff
	ff e8 54 dc d0 ff 48 8b bd 10 fc ff ff e8 82 95 fe ff <0f> 0b e8 41 dc d0 ff
	0f 0b 4c 89 ad 18 fc ff ff c7 85 7c fb ff ff
	RSP: 0018:ffff8801b0587330 EFLAGS: 00010286
	RAX: 000000000000013c RBX: 1ffff100360b0e9c RCX: ffffc90002620000
	RDX: 0000000000000000 RSI: ffffffff81631851 RDI: 0000000000000001
	RBP: ffff8801b05877c8 R08: ffff880199d40300 R09: ffffed003b5c4fc0
	R10: ffffed003b5c4fc0 R11: ffff8801dae27e07 R12: 0000000000000000
	R13: ffff88019c1e13c0 R14: dffffc0000000000 R15: 0000000020e01000
	FS:  00007fca32251700(0000) GS:ffff8801dae00000(0000) knlGS:0000000000000000
	CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
	CR2: 00007f04c540d000 CR3: 00000001ac1f0000 CR4: 00000000001426f0
	DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
	DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
	Call Trace:
	 unmap_single_vma+0x1a0/0x310 mm/memory.c:1553
	 zap_page_range_single+0x3cc/0x580 mm/memory.c:1644
	 unmap_mapping_range_vma mm/memory.c:2792 [inline]
	 unmap_mapping_range_tree mm/memory.c:2813 [inline]
	 unmap_mapping_pages+0x3a7/0x5b0 mm/memory.c:2845
	 unmap_mapping_range+0x48/0x60 mm/memory.c:2880
	 truncate_pagecache+0x54/0x90 mm/truncate.c:800
	 truncate_setsize+0x70/0xb0 mm/truncate.c:826
	 simple_setattr+0xe9/0x110 fs/libfs.c:409
	 notify_change+0xf13/0x10f0 fs/attr.c:335
	 do_truncate+0x1ac/0x2b0 fs/open.c:63
	 do_sys_ftruncate+0x492/0x560 fs/open.c:205
	 __do_sys_ftruncate fs/open.c:215 [inline]
	 __se_sys_ftruncate fs/open.c:213 [inline]
	 __x64_sys_ftruncate+0x59/0x80 fs/open.c:213
	 do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
	 entry_SYSCALL_64_after_hwframe+0x49/0xbe

Reproducer:

	#include <stdio.h>
	#include <stddef.h>
	#include <stdint.h>
	#include <stdlib.h>
	#include <string.h>
	#include <sys/types.h>
	#include <sys/stat.h>
	#include <sys/ioctl.h>
	#include <sys/mman.h>
	#include <unistd.h>
	#include <fcntl.h>

	#define KCOV_INIT_TRACE			_IOR('c', 1, unsigned long)
	#define KCOV_ENABLE			_IO('c', 100)
	#define KCOV_DISABLE			_IO('c', 101)
	#define COVER_SIZE			(1024<<10)

	#define KCOV_TRACE_PC  0
	#define KCOV_TRACE_CMP 1

	int main(int argc, char **argv)
	{
		int fd;
		unsigned long *cover;

		system("mount -t debugfs none /sys/kernel/debug");
		fd = open("/sys/kernel/debug/kcov", O_RDWR);
		ioctl(fd, KCOV_INIT_TRACE, COVER_SIZE);
		cover = mmap(NULL, COVER_SIZE * sizeof(unsigned long),
				PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
		munmap(cover, COVER_SIZE * sizeof(unsigned long));
		cover = mmap(NULL, COVER_SIZE * sizeof(unsigned long),
				PROT_READ | PROT_WRITE, MAP_PRIVATE, fd, 0);
		memset(cover, 0, COVER_SIZE * sizeof(unsigned long));
		ftruncate(fd, 3UL << 20);
		return 0;
	}

This can be fixed by assigning anonymous VMAs own vm_ops and not relying
on it being NULL.

If ->mmap() failed to set ->vm_ops, mmap_region() will set it to
dummy_vm_ops. This way we will have non-NULL ->vm_ops for all VMAs.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: syzbot+3f84280d52be9b7083cc@syzkaller.appspotmail.com
Cc: stable@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
---
 drivers/char/mem.c   |  1 +
 fs/exec.c            |  1 +
 fs/hugetlbfs/inode.c |  1 +
 include/linux/mm.h   |  5 ++++-
 mm/khugepaged.c      |  4 ++--
 mm/mmap.c            | 13 +++++++++++++
 mm/shmem.c           |  1 +
 7 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/drivers/char/mem.c b/drivers/char/mem.c
index ffeb60d3434c..f0a8b0b1768b 100644
--- a/drivers/char/mem.c
+++ b/drivers/char/mem.c
@@ -708,6 +708,7 @@ static int mmap_zero(struct file *file, struct vm_area_struct *vma)
 #endif
 	if (vma->vm_flags & VM_SHARED)
 		return shmem_zero_setup(vma);
+	vma->vm_ops = &anon_vm_ops;
 	return 0;
 }
 
diff --git a/fs/exec.c b/fs/exec.c
index 2d4e0075bd24..a1a246062561 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -307,6 +307,7 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
 	 * configured yet.
 	 */
 	BUILD_BUG_ON(VM_STACK_FLAGS & VM_STACK_INCOMPLETE_SETUP);
+	vma->vm_ops = &anon_vm_ops;
 	vma->vm_end = STACK_TOP_MAX;
 	vma->vm_start = vma->vm_end - PAGE_SIZE;
 	vma->vm_flags = VM_SOFTDIRTY | VM_STACK_FLAGS | VM_STACK_INCOMPLETE_SETUP;
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index d508c7844681..5ff73b1398ad 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -597,6 +597,7 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 	memset(&pseudo_vma, 0, sizeof(struct vm_area_struct));
 	pseudo_vma.vm_flags = (VM_HUGETLB | VM_MAYSHARE | VM_SHARED);
 	pseudo_vma.vm_file = file;
+	pseudo_vma.vm_ops = &dummy_vm_ops;
 
 	for (index = start; index < end; index++) {
 		/*
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a0fbb9ffe380..9a35362bbc92 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1536,9 +1536,12 @@ int clear_page_dirty_for_io(struct page *page);
 
 int get_cmdline(struct task_struct *task, char *buffer, int buflen);
 
+extern const struct vm_operations_struct anon_vm_ops;
+extern const struct vm_operations_struct dummy_vm_ops;
+
 static inline bool vma_is_anonymous(struct vm_area_struct *vma)
 {
-	return !vma->vm_ops;
+	return vma->vm_ops == &anon_vm_ops;
 }
 
 #ifdef CONFIG_SHMEM
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index d7b2a4bf8671..5ae34097aed1 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -440,7 +440,7 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
 		 * page fault if needed.
 		 */
 		return 0;
-	if (vma->vm_ops || (vm_flags & VM_NO_KHUGEPAGED))
+	if (!vma_is_anonymous(vma) || (vm_flags & VM_NO_KHUGEPAGED))
 		/* khugepaged not yet working on file or special mappings */
 		return 0;
 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
@@ -831,7 +831,7 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
 		return IS_ALIGNED((vma->vm_start >> PAGE_SHIFT) - vma->vm_pgoff,
 				HPAGE_PMD_NR);
 	}
-	if (!vma->anon_vma || vma->vm_ops)
+	if (!vma->anon_vma || !vma_is_anonymous(vma))
 		return false;
 	if (is_vma_temporary_stack(vma))
 		return false;
diff --git a/mm/mmap.c b/mm/mmap.c
index d1eb87ef4b1a..0729ed06b01c 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -71,6 +71,9 @@ int mmap_rnd_compat_bits __read_mostly = CONFIG_ARCH_MMAP_RND_COMPAT_BITS;
 static bool ignore_rlimit_data;
 core_param(ignore_rlimit_data, ignore_rlimit_data, bool, 0644);
 
+const struct vm_operations_struct anon_vm_ops = {};
+const struct vm_operations_struct dummy_vm_ops = {};
+
 static void unmap_region(struct mm_struct *mm,
 		struct vm_area_struct *vma, struct vm_area_struct *prev,
 		unsigned long start, unsigned long end);
@@ -561,6 +564,8 @@ static unsigned long count_vma_pages_range(struct mm_struct *mm,
 void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct rb_node **rb_link, struct rb_node *rb_parent)
 {
+	WARN_ONCE(!vma->vm_ops, "missing vma->vm_ops");
+
 	/* Update tracking information for the gap following the new vma. */
 	if (vma->vm_next)
 		vma_gap_update(vma->vm_next);
@@ -1774,12 +1779,19 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 		 */
 		WARN_ON_ONCE(addr != vma->vm_start);
 
+		/* All mappings must have ->vm_ops set */
+		if (!vma->vm_ops)
+			vma->vm_ops = &dummy_vm_ops;
+
 		addr = vma->vm_start;
 		vm_flags = vma->vm_flags;
 	} else if (vm_flags & VM_SHARED) {
 		error = shmem_zero_setup(vma);
 		if (error)
 			goto free_vma;
+	} else {
+		/* vma_is_anonymous() relies on this. */
+		vma->vm_ops = &anon_vm_ops;
 	}
 
 	vma_link(mm, vma, prev, rb_link, rb_parent);
@@ -2999,6 +3011,7 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
 
 	INIT_LIST_HEAD(&vma->anon_vma_chain);
 	vma->vm_mm = mm;
+	vma->vm_ops = &anon_vm_ops;
 	vma->vm_start = addr;
 	vma->vm_end = addr + len;
 	vma->vm_pgoff = pgoff;
diff --git a/mm/shmem.c b/mm/shmem.c
index 2cab84403055..db5c319161ca 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1424,6 +1424,7 @@ static void shmem_pseudo_vma_init(struct vm_area_struct *vma,
 	/* Bias interleave by inode number to distribute better across nodes */
 	vma->vm_pgoff = index + info->vfs_inode.i_ino;
 	vma->vm_policy = mpol_shared_policy_lookup(&info->policy, index);
+	vma->vm_ops = &dummy_vm_ops;
 }
 
 static void shmem_pseudo_vma_destroy(struct vm_area_struct *vma)
-- 
2.18.0
