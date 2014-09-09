Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id 9A0726B006C
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 11:00:56 -0400 (EDT)
Received: by mail-yk0-f173.google.com with SMTP id 19so1295227ykq.18
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 08:00:56 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id k106si10180438yhq.126.2014.09.09.08.00.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 09 Sep 2014 08:00:55 -0700 (PDT)
From: Junxiao Bi <junxiao.bi@oracle.com>
Subject: [PATCH v2] mm: clear __GFP_FS when PF_MEMALLOC_NOIO is set
Date: Tue,  9 Sep 2014 22:59:43 +0800
Message-Id: <1410274783-25735-1-git-send-email-junxiao.bi@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: david@fromorbit.com, xuejiufei@huawei.com, ming.lei@canonical.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, trond.myklebust@primarydata.com

commit 21caf2fc1931 ("mm: teach mm by current context info to not do I/O during memory allocation")
introduces PF_MEMALLOC_NOIO flag to avoid doing I/O inside memory allocation, __GFP_IO is cleared
when this flag is set, but __GFP_FS implies __GFP_IO, it should also be cleared. Or it may still
run into I/O, like in superblock shrinker. And this will make the kernel run into the deadlock case
described in that commit.

See Dave Chinner's comment about io in superblock shrinker:

Filesystem shrinkers do indeed perform IO from the superblock
shrinker and have for years. Even clean inodes can require IO before
they can be freed - e.g. on an orphan list, need truncation of
post-eof blocks, need to wait for ordered operations to complete
before it can be freed, etc.

IOWs, Ext4, btrfs and XFS all can issue and/or block on
arbitrary amounts of IO in the superblock shrinker context. XFS, in
particular, has been doing transactions and IO from the VFS inode
cache shrinker since it was first introduced....

Fix this by clearing __GFP_FS in memalloc_noio_flags(), this function
has masked all the gfp_mask that will be passed into fs for the processes
setting PF_MEMALLOC_NOIO in the direct reclaim path.

v1 thread at:
https://lkml.org/lkml/2014/9/3/32

v2 changes:
patch log update to make the issue more clear.

Signed-off-by: Junxiao Bi <junxiao.bi@oracle.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: joyce.xue <xuejiufei@huawei.com>
Cc: Ming Lei <ming.lei@canonical.com>
Cc: <stable@vger.kernel.org>
---
 include/linux/sched.h |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 5c2c885..2fb2c47 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1936,11 +1936,13 @@ extern void thread_group_cputime_adjusted(struct task_struct *p, cputime_t *ut,
 #define tsk_used_math(p) ((p)->flags & PF_USED_MATH)
 #define used_math() tsk_used_math(current)
 
-/* __GFP_IO isn't allowed if PF_MEMALLOC_NOIO is set in current->flags */
+/* __GFP_IO isn't allowed if PF_MEMALLOC_NOIO is set in current->flags
+ * __GFP_FS is also cleared as it implies __GFP_IO.
+ */
 static inline gfp_t memalloc_noio_flags(gfp_t flags)
 {
 	if (unlikely(current->flags & PF_MEMALLOC_NOIO))
-		flags &= ~__GFP_IO;
+		flags &= ~(__GFP_IO | __GFP_FS);
 	return flags;
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
