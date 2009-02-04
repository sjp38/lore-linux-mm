Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 23FF16B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 05:22:33 -0500 (EST)
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id n14ALO7L378720
	for <linux-mm@kvack.org>; Wed, 4 Feb 2009 10:21:24 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n14ALOra3584194
	for <linux-mm@kvack.org>; Wed, 4 Feb 2009 10:21:24 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n14ALNH0014859
	for <linux-mm@kvack.org>; Wed, 4 Feb 2009 10:21:24 GMT
Date: Wed, 4 Feb 2009 11:21:21 +0100
From: Carsten Otte <cotte@de.ibm.com>
Subject: [PATCH] ext2/xip: refuse to change xip flag during remount with
 busy inodes
Message-ID: <20090204112121.4d03c20e@cotte.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>
Cc: Jared Hulbert <jaredeh@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, os@de.ibm.com
List-ID: <linux-mm.kvack.org>

For a reason that I was unable to understand in three months
of debugging, mount ext2 -o remount stopped working properly when
remounting from regular operation to xip, or the other way around.
According to a git bisect search, the problem was introduced with
the VM_MIXEDMAP/PTE_SPECIAL rework in the vm:
commit 70688e4dd1647f0ceb502bbd5964fa344c5eb411
Author: Nick Piggin <npiggin@suse.de>
Date:   Mon Apr 28 02:13:02 2008 -0700
    xip: support non-struct page backed memory
Signed-off-by: Nick Piggin <npiggin@suse.de>
Acked-by: Carsten Otte <cotte@de.ibm.com>
Cc: Jared Hulbert <jaredeh@gmail.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

In the failing scenario, the filesystem is mounted read only via root=
kernel parameter on s390x. During remount (in rc.sysinit), the inodes of
the bash binary and its libraries are busy and cannot be invalidated
(the bash which is running rc.sysinit resides on subject filesystem).
Afterwards, another bash process (running ifup-eth) recurses into a
subshell, runs dup_mm (via fork). Some of the mappings in this bash
process were created from inodes that could not be invalidated during
remount.
Both parent and child process crash some time later due
to inconsistencies in their address spaces. The issue seems to
be timing sensitive, various attempts to recreate it have failed.

This patch refuses to change the xip flag during remount in case
some inodes cannot be invalidated. This patch keeps users from running
into that issue.

Signed-off-by: Carsten Otte <cotte@de.ibm.com>
---
diff --git a/fs/ext2/super.c b/fs/ext2/super.c
index da8bdea..1add0fe 100644
--- a/fs/ext2/super.c
+++ b/fs/ext2/super.c
@@ -1185,9 +1185,12 @@ static int ext2_remount (struct super_block * sb, int * flags, char * data)
 	es = sbi->s_es;
 	if (((sbi->s_mount_opt & EXT2_MOUNT_XIP) !=
 	    (old_mount_opt & EXT2_MOUNT_XIP)) &&
-	    invalidate_inodes(sb))
-		ext2_warning(sb, __func__, "busy inodes while remounting "\
-			     "xip remain in cache (no functional problem)");
+	    invalidate_inodes(sb)) {
+		ext2_warning(sb, __func__, "refusing change of xip flag "\
+			     "with busy inodes while remounting");
+		sbi->s_mount_opt &= ~EXT2_MOUNT_XIP;
+		sbi->s_mount_opt |= old_mount_opt & EXT2_MOUNT_XIP;
+	}
 	if ((*flags & MS_RDONLY) == (sb->s_flags & MS_RDONLY))
 		return 0;
 	if (*flags & MS_RDONLY) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
