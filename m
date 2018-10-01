Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6F8156B000C
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 05:53:08 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id f89-v6so15731059pff.7
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 02:53:08 -0700 (PDT)
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTPS id g9-v6si11844678plo.23.2018.10.01.02.53.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Oct 2018 02:53:06 -0700 (PDT)
From: <miles.chen@mediatek.com>
Subject: [RFC/PATCH] mm/shmem: add a NULL pointer test to shmem_free_inode
Date: Mon, 1 Oct 2018 17:52:55 +0800
Message-ID: <1538387575-28914-1-git-send-email-miles.chen@mediatek.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, wsd_upstream@mediatek.com, linux-mediatek@lists.infradead.org, Mark Salyzyn <salyzyn@google.com>, Miles Chen <miles.chen@mediatek.com>

From: Miles Chen <miles.chen@mediatek.com>

We noticed a kernel panic when unmounting tmpfs. It looks like a
race condition in the following scenario:

shmem_put_super() set sb->s_fs_info to NULL and shmem_evict_inode() tries
to access sb->s_fs_info right after the sb->s_fs_info becomes NULL.

CPU1				CPU2

work_pending			work_pending
do_notify_resume		do_notify_resume
____fput			task_work_run
__fput				__cleanup_mnt
inotify_release			cleanup_mnt
fsnotify_destroy_group		deactivate_super
fsnotify_detach_group_marks	deactivate_locked_super
fsnotify_detach_mark		kill_litter_super /* sb->s_fs_info = NULL */
iput
evict /* use sb->s_fs_info */

Add a NULL pointer test in shmem_evict_inode(). We have stress-tested
the patch for 5 days with no panic.

Please note that this patch is a band-aid patch.

VFS: Busy inodes after unmount of tmpfs. Self-destruct in 5 seconds.
Have a nice day...
[name:traps&]Internal error: Accessing user space memory outside uaccess.h
routines:
[name:aee&]disable aee kernel api
[name:mrdump&]Kernel Offset: 0x1326000000 from 0xffffff8008000000
[name:mrdump&]Non-crashing CPUs did not react to IPI
CPU: 7 PID: 552 Comm: HwBinder:426_1 Tainted: G        W  O    4.9.117+ #2
Hardware name: MT6765 (DT)
task: ffffffc62d340000 task.stack: ffffffc62d2b4000
PC is at shmem_evict_inode+0x150/0x19c
LR is at evict+0xa4/0x1f4
[<ffffff932e083148>] el1_da+0x24/0x40
[<ffffff932e2acbac>] evict+0xa4/0x1f4
[<ffffff932e2aadc8>] iput+0x338/0x384
[<ffffff932e2db110>] fsnotify_detach_mark+0xac/0xe0
[<ffffff932e2dba20>] fsnotify_detach_group_marks+0x78/0xdc
[<ffffff932e2daac4>] fsnotify_destroy_group+0x34/0x98
[<ffffff932e2dd810>] inotify_release+0x28/0x5c
[<ffffff932e289614>] __fput+0xcc/0x1c8
[<ffffff932e2894f4>] ____fput+0xc/0x14
[<ffffff932e0da7cc>] task_work_run+0x88/0x11c
[<ffffff932e08b53c>] do_notify_resume+0x5c/0x165c
[<ffffff932e083c54>] work_pending+0x8/0x14

If we put a BUG() after after "VFS: Busy inodes after unmount of tmpfs.
Self-destruct in 5 seconds.  Have a nice day...", we can get another
backtrace:
[<ffffff94de6830e8>] el1_dbg+0x18/0xb8
[<ffffff94de8875ec>] kill_litter_super+0x28/0x74
[<ffffff94de885b40>] deactivate_locked_super+0x58/0x110
[<ffffff94de885c64>] deactivate_super+0x6c/0x78
[<ffffff94de8b20a0>] cleanup_mnt+0xb4/0x130
[<ffffff94de8b1fe4>] __cleanup_mnt+0x10/0x18
[<ffffff94de6d9bd0>] task_work_run+0x88/0x11c
[<ffffff94de68ad64>] do_notify_resume+0x5c/0x1664
[<ffffff94de683a28>] work_pending+0x8/0x14

Signed-off-by: Miles Chen <miles.chen@mediatek.com>
---
 mm/shmem.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 4469426..a50a2c8 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -257,7 +257,7 @@ static int shmem_reserve_inode(struct super_block *sb)
 static void shmem_free_inode(struct super_block *sb)
 {
 	struct shmem_sb_info *sbinfo = SHMEM_SB(sb);
-	if (sbinfo->max_inodes) {
+	if (sbinfo && sbinfo->max_inodes) {
 		spin_lock(&sbinfo->stat_lock);
 		sbinfo->free_inodes++;
 		spin_unlock(&sbinfo->stat_lock);
-- 
1.9.1
