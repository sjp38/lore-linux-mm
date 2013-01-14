Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 1532A6B0071
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 14:53:13 -0500 (EST)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] mm: fix BUG on madvise early failure
Date: Mon, 14 Jan 2013 14:50:56 -0500
Message-Id: <1358193076-10635-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Roland McGrath <roland@hack.frob.com>, Hugh Dickins <hughd@google.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Shaohua Li <shli@fusionio.com>, Rik van Riel <riel@redhat.com>

Commit "mm: make madvise(MADV_WILLNEED) support swap file prefetch" has
allowed a situation where blk_finish_plug() would be called without
blk_start_plug() being called before that, which would lead to a BUG:

[   57.320031] kernel BUG at block/blk-core.c:2981!
[   57.320031] invalid opcode: 0000 [#3] PREEMPT SMP DEBUG_PAGEALLOC
[   57.320031] Modules linked in:
[   57.320031] CPU 4
[   57.320031] Pid: 7013, comm: trinity Tainted: G      D W    3.8.0-rc3-next-20130114-sasha-00016-ga107525-dirty #261
[   57.320031] RIP: 0010:[<ffffffff819e3bfa>]  [<ffffffff819e3bfa>] blk_flush_plug_list+0x2a/0x270
[   57.320031] RSP: 0018:ffff880014cc5e68  EFLAGS: 00010297
[   57.320031] RAX: 0000000091827364 RBX: ffff880014cc5e78 RCX: 0000000000000001
[   57.320031] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff880014cc5f18
[   57.340707] RBP: ffff880014cc5ec8 R08: 0000000000000002 R09: 0000000000000000
[   57.340707] R10: 0000000000000000 R11: 0000000000000246 R12: 000000000000000a
[   57.340707] R13: 000000000000001c R14: ffff880014cc5f18 R15: ffff880014cc5f18
[   57.340707] FS:  00007f2ba9ee4700(0000) GS:ffff880013c00000(0000) knlGS:0000000000000000
[   57.340707] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   57.340707] CR2: 00000000008db558 CR3: 0000000014d0a000 CR4: 00000000000406e0
[   57.340707] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   57.340707] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   57.340707] Process trinity (pid: 7013, threadinfo ffff880014cc4000, task ffff880014ed8000)
[   57.340707] Stack:
[   57.340707]  ffffffff8123b2e4 00007f2ba9ee46a8 ffff880014cc5e78 ffff880014cc5e78
[   57.340707]  ffff880014c240b0 ffff880014c24110 ffffffff00000001 ffff880014cc5f18
[   57.340707]  000000000000000a 000000000000001c 0000000000000aec ffff880014cc5f18
[   57.340707] Call Trace:
[   57.340707]  [<ffffffff8123b2e4>] ? sys_madvise+0x2a4/0x2e0
[   57.340707]  [<ffffffff819e3e53>] blk_finish_plug+0x13/0x40
[   57.340707]  [<ffffffff8123b268>] sys_madvise+0x228/0x2e0
[   57.340707]  [<ffffffff8107df14>] ? syscall_trace_enter+0x24/0x2e0
[   57.340707]  [<ffffffff83d33d58>] tracesys+0xe1/0xe6
[   57.340707] Code: 00 55 b8 64 73 82 91 48 89 e5 41 57 41 56 49 89 fe 41 55 41 54 53 48 8d 5d b0 48 83 ec 38 48 89 5d b0 48 39 07 48 89 5d b8 74 06 <0f> 0b 0f 1f 40 00 48 8d 45 c0 44 0f b6 e6 48 8b 57 18 48 89 45
[   57.340707] RIP  [<ffffffff819e3bfa>] blk_flush_plug_list+0x2a/0x270
[   57.340707]  RSP <ffff880014cc5e68>

Cc: Shaohua Li <shli@fusionio.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/madvise.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index e560253..c58c94b 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -509,14 +509,14 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 		/* Still start < end. */
 		error = -ENOMEM;
 		if (!vma)
-			goto out;
+			goto out_plug;
 
 		/* Here start < (end|vma->vm_end). */
 		if (start < vma->vm_start) {
 			unmapped_error = -ENOMEM;
 			start = vma->vm_start;
 			if (start >= end)
-				goto out;
+				goto out_plug;
 		}
 
 		/* Here vma->vm_start <= start < (end|vma->vm_end) */
@@ -527,20 +527,21 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
 		error = madvise_vma(vma, &prev, start, tmp, behavior);
 		if (error)
-			goto out;
+			goto out_plug;
 		start = tmp;
 		if (prev && start < prev->vm_end)
 			start = prev->vm_end;
 		error = unmapped_error;
 		if (start >= end)
-			goto out;
+			goto out_plug;
 		if (prev)
 			vma = prev->vm_next;
 		else	/* madvise_remove dropped mmap_sem */
 			vma = find_vma(current->mm, start);
 	}
-out:
+out_plug:
 	blk_finish_plug(&plug);
+out:
 	if (write)
 		up_write(&current->mm->mmap_sem);
 	else
-- 
1.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
