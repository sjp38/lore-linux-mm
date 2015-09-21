Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 730D06B0253
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 08:16:52 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so143328653wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 05:16:52 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com. [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id ft20si16708881wic.68.2015.09.21.05.16.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 05:16:51 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so143328017wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 05:16:51 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH] fs: fix data race on mnt.mnt_flags
Date: Mon, 21 Sep 2015 14:16:47 +0200
Message-Id: <1442837807-70839-1-git-send-email-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, riel@redhat.com, mhocko@suse.cz, oleg@redhat.com, sasha.levin@oracle.com, gang.chen.5i5j@gmail.com, pfeiner@google.com, aarcange@redhat.com, vishnu.ps@samsung.com, linux-mm@kvack.org
Cc: glider@google.com, kcc@google.com, andreyknvl@google.com, ktsan@googlegroups.com, paulmck@linux.vnet.ibm.com, Dmitry Vyukov <dvyukov@google.com>

do_remount() does:

mnt_flags |= mnt->mnt.mnt_flags & ~MNT_USER_SETTABLE_MASK;
mnt->mnt.mnt_flags = mnt_flags;

This can easily be compiled as:

mnt->mnt.mnt_flags &= ~MNT_USER_SETTABLE_MASK;
mnt->mnt.mnt_flags |= mnt_flags;

(also 2 memory accesses, less register pressure)
The flags are being concurrently read by e.g. do_mmap_pgoff()
which does:

if (file->f_path.mnt->mnt_flags & MNT_NOEXEC)

As the result we can allow to mmap a MNT_NOEXEC mount
as VM_EXEC.

Use WRITE_ONCE() to set new flags.

The data race was found with KernelThreadSanitizer (KTSAN).

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
---

For the record KTSAN report on 4.2:

ThreadSanitizer: data-race in do_mmap_pgoff

Read at 0xffff8800bb857e30 of size 4 by thread 1471 on CPU 0:
 [<ffffffff8121e770>] do_mmap_pgoff+0x4f0/0x590 mm/mmap.c:1341
 [<ffffffff811f8a6a>] vm_mmap_pgoff+0xaa/0xe0 mm/util.c:297
 [<ffffffff811f8b0c>] vm_mmap+0x6c/0x90 mm/util.c:315
 [<ffffffff812ea95c>] elf_map+0x13c/0x160 fs/binfmt_elf.c:365
 [<ffffffff812eb3cd>] load_elf_binary+0x91d/0x22b0 fs/binfmt_elf.c:955 (discriminator 9)
 [<ffffffff8126a712>] search_binary_handler+0x142/0x360 fs/exec.c:1422
 [<     inline     >] exec_binprm fs/exec.c:1464
 [<ffffffff8126c689>] do_execveat_common.isra.36+0x919/0xb40 fs/exec.c:1584
 [<     inline     >] do_execve fs/exec.c:1628
 [<     inline     >] SYSC_execve fs/exec.c:1709
 [<ffffffff8126cdc6>] SyS_execve+0x46/0x60 fs/exec.c:1704
 [<ffffffff81ee4145>] return_from_execve+0x0/0x23 arch/x86/entry/entry_64.S:428

Previous write at 0xffff8800bb857e30 of size 4 by thread 1468 on CPU 8:
 [<     inline     >] do_remount fs/namespace.c:2215
 [<ffffffff8129a157>] do_mount+0x637/0x1450 fs/namespace.c:2716
 [<     inline     >] SYSC_mount fs/namespace.c:2915
 [<ffffffff8129b4e3>] SyS_mount+0xa3/0x100 fs/namespace.c:2893
 [<ffffffff81ee3e11>] entry_SYSCALL_64_fastpath+0x31/0x95 arch/x86/entry/entry_64.S:188

Mutexes locked by thread 1471:
Mutex 228939 is locked here:
 [<ffffffff81edf7c2>] mutex_lock_interruptible+0x62/0xa0 kernel/locking/mutex.c:805
 [<ffffffff8126bd0f>] prepare_bprm_creds+0x4f/0xb0 fs/exec.c:1172
 [<ffffffff8126beaf>] do_execveat_common.isra.36+0x13f/0xb40 fs/exec.c:1517
 [<     inline     >] do_execve fs/exec.c:1628
 [<     inline     >] SYSC_execve fs/exec.c:1709
 [<ffffffff8126cdc6>] SyS_execve+0x46/0x60 fs/exec.c:1704
 [<ffffffff81ee4145>] return_from_execve+0x0/0x23 arch/x86/entry/entry_64.S:428

Mutex 223016 is locked here:
 [<ffffffff81ee0d45>] down_write+0x65/0x80 kernel/locking/rwsem.c:62
 [<ffffffff811f8a4c>] vm_mmap_pgoff+0x8c/0xe0 mm/util.c:296
 [<ffffffff811f8b0c>] vm_mmap+0x6c/0x90 mm/util.c:315
 [<ffffffff812ea95c>] elf_map+0x13c/0x160 fs/binfmt_elf.c:365
 [<ffffffff812eb3cd>] load_elf_binary+0x91d/0x22b0 fs/binfmt_elf.c:955 (discriminator 9)
 [<ffffffff8126a712>] search_binary_handler+0x142/0x360 fs/exec.c:1422
 [<     inline     >] exec_binprm fs/exec.c:1464
 [<ffffffff8126c689>] do_execveat_common.isra.36+0x919/0xb40 fs/exec.c:1584
 [<     inline     >] do_execve fs/exec.c:1628
 [<     inline     >] SYSC_execve fs/exec.c:1709
 [<ffffffff8126cdc6>] SyS_execve+0x46/0x60 fs/exec.c:1704
 [<ffffffff81ee4145>] return_from_execve+0x0/0x23 arch/x86/entry/entry_64.S:428

Mutexes locked by thread 1468:
Mutex 119619 is locked here:
 [<ffffffff81ee0d45>] down_write+0x65/0x80 kernel/locking/rwsem.c:62
 [<     inline     >] do_remount fs/namespace.c:2205
 [<ffffffff81299ff1>] do_mount+0x4d1/0x1450 fs/namespace.c:2716
 [<     inline     >] SYSC_mount fs/namespace.c:2915
 [<ffffffff8129b4e3>] SyS_mount+0xa3/0x100 fs/namespace.c:2893
 [<ffffffff81ee3e11>] entry_SYSCALL_64_fastpath+0x31/0x95 arch/x86/entry/entry_64.S:188

Mutex 193 is locked here:
 [<     inline     >] __raw_spin_lock include/linux/spinlock_api_smp.h:158
 [<ffffffff81ee37d0>] _raw_spin_lock+0x50/0x70 kernel/locking/spinlock.c:151
 [<     inline     >] spin_lock include/linux/spinlock.h:312
 [<     inline     >] write_seqlock include/linux/seqlock.h:470
 [<     inline     >] lock_mount_hash fs/mount.h:112
 [<     inline     >] do_remount fs/namespace.c:2213
 [<ffffffff8129a10e>] do_mount+0x5ee/0x1450 fs/namespace.c:2716
 [<     inline     >] SYSC_mount fs/namespace.c:2915
 [<ffffffff8129b4e3>] SyS_mount+0xa3/0x100 fs/namespace.c:2893
 [<ffffffff81ee3e11>] entry_SYSCALL_64_fastpath+0x31/0x95 arch/x86/entry/entry_64.S:188
---
 fs/namespace.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 0570729..d0040be 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2212,7 +2212,7 @@ static int do_remount(struct path *path, int flags, int mnt_flags,
 	if (!err) {
 		lock_mount_hash();
 		mnt_flags |= mnt->mnt.mnt_flags & ~MNT_USER_SETTABLE_MASK;
-		mnt->mnt.mnt_flags = mnt_flags;
+		WRITE_ONCE(mnt->mnt.mnt_flags, mnt_flags);
 		touch_mnt_namespace(mnt->mnt_ns);
 		unlock_mount_hash();
 	}
-- 
2.6.0.rc0.131.gf624c3d

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
