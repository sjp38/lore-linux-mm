Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8CE275F0001
	for <linux-mm@kvack.org>; Sat, 11 Apr 2009 08:11:53 -0400 (EDT)
References: <m1skkf761y.fsf@fess.ebiederm.org>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 11 Apr 2009 05:11:59 -0700
In-Reply-To: <m1skkf761y.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Sat\, 11 Apr 2009 05\:01\:29 -0700")
Message-ID: <m1ws9r5r00.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: [RFC][PATCH 7/9] vfs: Optimize fops_read_lock
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>


After seeing fget_light and the justification for it in the commit
log I did not want to introduce something into the common read/write
path of file descriptors that could have a significant measurable impact
on I/O speed.

commit f6435db01709533f270b2dce1e5914770dbc65de
Author: akpm <akpm>
Date:   Thu May 8 05:19:50 2003 +0000

    [PATCH] reduced overheads in fget/fput

    From: Dipankar Sarma <dipankar@in.ibm.com>

    fget() shows up on profiles, especially on SMP.  Dipankar's patch
    special-cases the situation wherein there are no sharers of current->files.

    In this situation we know that no other process can close this file, so it
    is not necessary to increment the file's refcount.

    It's ugly as sin, but makes a substantial difference.

    The test is

        dd if=/dev/zero of=foo bs=1 count=1M

    On 4CPU P3 xeon with 1MB L2 cache and 512MB ram:

        kernel           sys time     std-dev
        ------------     --------     -------

        UP - vanilla     2.104        0.028
        UP - file        1.867        0.019

        SMP - vanilla    2.976        0.023
        SMP - file       2.719        0.026

    BKrev: 3eb9e8f6Db0nMWoSx5IdHx6SBal8aw

My test case was:
    dd if=/dev/zero of=/dev/null bs=1 count=1M.

As writing to a real file turned out to cover the cost.

Without the optimization I am seeing 2.4 - 2.5 MB/s on my
idle core2 single socket quad core.

With this optimization I am seeing 2.9 - 3.0 MB/s on the
same machine.  Maybe 2% slower than before I introduced
fops_read_lock.

The common case is that there is only one thread and so
the fget_light optimization applies and f_count remains
at 1.  Which implies that there is only a single process
performing operations through the file descriptor.

In that case because there is no possible contention
it is possible safely skip the atomic operations, gaining all
of the benefits of rcu without requiring a per cpu variable.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/file_table.c |   18 ++++++++++++++----
 1 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/fs/file_table.c b/fs/file_table.c
index d216557..634d44c 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -495,15 +495,25 @@ void file_kill(struct file *file)
 int fops_read_lock(struct file *file)
 {
 	int revoked = (file->f_mode & FMODE_REVOKED);
-	if (likely(!revoked))
-		atomic_long_inc(&file->f_use);
+	if (likely(!revoked)) {
+		if (likely(atomic_long_read(&file->f_count) == 1))
+			atomic_long_set(&file->f_use,
+				atomic_long_read(&file->f_use) + 1);
+		else
+			atomic_long_inc(&file->f_use);
+	}
 	return revoked;
 }
 
 void fops_read_unlock(struct file *file, int revoked)
 {
-	if (likely(!revoked))
-		atomic_long_dec(&file->f_use);
+	if (likely(!revoked)) {
+		if (likely(atomic_long_read(&file->f_count) == 1))
+			atomic_long_set(&file->f_use,
+				atomic_long_read(&file->f_use) - 1);
+		else
+			atomic_long_dec(&file->f_use);
+	}
 }
 
 int fs_may_remount_ro(struct super_block *sb)
-- 
1.6.1.2.350.g88cc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
