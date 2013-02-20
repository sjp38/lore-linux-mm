Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 2446B6B0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 02:11:52 -0500 (EST)
Received: by mail-qc0-f201.google.com with SMTP id o22so751872qcr.2
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 23:11:51 -0800 (PST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH 1/2] tmpfs: fix use-after-free of mempolicy object
Date: Tue, 19 Feb 2013 23:11:41 -0800
Message-Id: <1361344302-26565-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>

The tmpfs remount logic preserves filesystem mempolicy if the mpol=M
option is not specified in the remount request.  A new policy can be
specified if mpol=M is given.

Before this patch remounting an mpol bound tmpfs without specifying
mpol= mount option in the remount request would set the filesystem's
mempolicy object to a freed mempolicy object.

To reproduce the problem boot a DEBUG_PAGEALLOC kernel and run:
    # mkdir /tmp/x

    # mount -t tmpfs -o size=100M,mpol=interleave nodev /tmp/x

    # grep /tmp/x /proc/mounts
    nodev /tmp/x tmpfs rw,relatime,size=102400k,mpol=interleave:0-3 0 0

    # mount -o remount,size=200M nodev /tmp/x

    # grep /tmp/x /proc/mounts
    nodev /tmp/x tmpfs rw,relatime,size=204800k,mpol=??? 0 0
        # note ? garbage in mpol=... output above

    # dd if=/dev/zero of=/tmp/x/f count=1
        # panic here

Panic:
    BUG: unable to handle kernel NULL pointer dereference at           (null)
    IP: [<          (null)>]           (null)
    [...]
    Oops: 0010 [#1] SMP DEBUG_PAGEALLOC
    Call Trace:
     [<ffffffff81186ead>] ? mpol_set_nodemask+0x8d/0x100
     [<ffffffff811895ef>] ? mpol_shared_policy_init+0x8f/0x160
     [<ffffffff81189605>] mpol_shared_policy_init+0xa5/0x160
     [<ffffffff811580e1>] ? shmem_get_inode+0x1e1/0x270
     [<ffffffff811580e1>] ? shmem_get_inode+0x1e1/0x270
     [<ffffffff810db15d>] ? trace_hardirqs_on+0xd/0x10
     [<ffffffff81158109>] shmem_get_inode+0x209/0x270
     [<ffffffff811581ae>] shmem_mknod+0x3e/0xf0
     [<ffffffff811582b8>] shmem_create+0x18/0x20
     [<ffffffff811af5d5>] vfs_create+0xb5/0x130
     [<ffffffff811afff1>] do_last+0x9a1/0xea0
     [<ffffffff811ac77a>] ? link_path_walk+0x7a/0x930
     [<ffffffff811b05a3>] path_openat+0xb3/0x4d0
     [<ffffffff811be831>] ? __alloc_fd+0x31/0x160
     [<ffffffff811b0de2>] do_filp_open+0x42/0xa0
     [<ffffffff811be8e0>] ? __alloc_fd+0xe0/0x160
     [<ffffffff811a066e>] do_sys_open+0xfe/0x1e0
     [<ffffffff811f0aeb>] compat_sys_open+0x1b/0x20
     [<ffffffff815d6055>] cstar_dispatch+0x7/0x1f

Non-debug kernels will not crash immediately because referencing the
dangling mpol will not cause a fault.  Instead the filesystem will
reference a freed mempolicy object, which will cause unpredictable
behavior.

The problem boils down to a dropped mpol reference below if
shmem_parse_options() does not allocate a new mpol:
    config = *sbinfo
    shmem_parse_options(data, &config, true)
    mpol_put(sbinfo->mpol)
    sbinfo->mpol = config.mpol  /* BUG: saves unreferenced mpol */

This patch avoids the crash by not releasing the mempolicy if
shmem_parse_options() doesn't create a new mpol.

How far back does this issue go?  I see it in both 2.6.36 and 3.3.  I
did not look back further.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 mm/shmem.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 5dd56f6..efd0b3a 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2487,6 +2487,7 @@ static int shmem_remount_fs(struct super_block *sb, int *flags, char *data)
 	unsigned long inodes;
 	int error = -EINVAL;
 
+	config.mpol = NULL;
 	if (shmem_parse_options(data, &config, true))
 		return error;
 
@@ -2511,8 +2512,13 @@ static int shmem_remount_fs(struct super_block *sb, int *flags, char *data)
 	sbinfo->max_inodes  = config.max_inodes;
 	sbinfo->free_inodes = config.max_inodes - inodes;
 
-	mpol_put(sbinfo->mpol);
-	sbinfo->mpol        = config.mpol;	/* transfers initial ref */
+	/*
+	 * Preserve previous mempolicy unless mpol remount option was specified.
+	 */
+	if (config.mpol) {
+		mpol_put(sbinfo->mpol);
+		sbinfo->mpol = config.mpol;	/* transfers initial ref */
+	}
 out:
 	spin_unlock(&sbinfo->stat_lock);
 	return error;
-- 
1.8.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
