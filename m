Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id A4EF682F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 15:13:38 -0400 (EDT)
Received: by oifu63 with SMTP id u63so46829896oif.2
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 12:13:38 -0700 (PDT)
Received: from mail-oi0-x236.google.com (mail-oi0-x236.google.com. [2607:f8b0:4003:c06::236])
        by mx.google.com with ESMTPS id qu7si1974136oeb.68.2015.10.29.12.13.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Oct 2015 12:13:38 -0700 (PDT)
Received: by oiao187 with SMTP id o187so46505136oia.3
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 12:13:38 -0700 (PDT)
Date: Thu, 29 Oct 2015 12:13:35 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] tmpfs: avoid a little creat and stat slowdown
Message-ID: <alpine.LSU.2.11.1510291208000.3475@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Josef Bacik <jbacik@fb.com>, Yu Zhao <yuzhao@google.com>, Ying Huang <ying.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

LKP reports that v4.2 commit afa2db2fb6f1 ("tmpfs: truncate prealloc
blocks past i_size") causes a 14.5% slowdown in the AIM9 creat-clo
benchmark.

creat-clo does just what you'd expect from the name, and creat's O_TRUNC
on 0-length file does indeed get into more overhead now shmem_setattr()
tests "0 <= 0" instead of "0 < 0".

I'm not sure how much we care, but I think it would not be too VW-like
to add in a check for whether any pages (or swap) are allocated: if none
are allocated, there's none to remove from the radix_tree.  At first I
thought that check would be good enough for the unmaps too, but no: we
should not skip the unlikely case of unmapping pages beyond the new EOF,
which were COWed from holes which have now been reclaimed, leaving none.

This gives me an 8.5% speedup: on Haswell instead of LKP's Westmere,
and running a debug config before and after: I hope those account for
the lesser speedup.

And probably someone has a benchmark where a thousand threads keep on
stat'ing the same file repeatedly: forestall that report by adjusting
v4.3 commit 44a30220bc0a ("shmem: recalculate file inode when fstat")
not to take the spinlock in shmem_getattr() when there's no work to do.

Reported-by: Ying Huang <ying.huang@linux.intel.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/shmem.c |   22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

--- 4.3-rc7/mm/shmem.c	2015-09-12 18:30:20.857039763 -0700
+++ linux/mm/shmem.c	2015-10-25 11:49:19.931973850 -0700
@@ -548,12 +548,12 @@ static int shmem_getattr(struct vfsmount
 	struct inode *inode = dentry->d_inode;
 	struct shmem_inode_info *info = SHMEM_I(inode);
 
-	spin_lock(&info->lock);
-	shmem_recalc_inode(inode);
-	spin_unlock(&info->lock);
-
+	if (info->alloced - info->swapped != inode->i_mapping->nrpages) {
+		spin_lock(&info->lock);
+		shmem_recalc_inode(inode);
+		spin_unlock(&info->lock);
+	}
 	generic_fillattr(inode, stat);
-
 	return 0;
 }
 
@@ -586,10 +586,16 @@ static int shmem_setattr(struct dentry *
 		}
 		if (newsize <= oldsize) {
 			loff_t holebegin = round_up(newsize, PAGE_SIZE);
-			unmap_mapping_range(inode->i_mapping, holebegin, 0, 1);
-			shmem_truncate_range(inode, newsize, (loff_t)-1);
+			if (oldsize > holebegin)
+				unmap_mapping_range(inode->i_mapping,
+							holebegin, 0, 1);
+			if (info->alloced)
+				shmem_truncate_range(inode,
+							newsize, (loff_t)-1);
 			/* unmap again to remove racily COWed private pages */
-			unmap_mapping_range(inode->i_mapping, holebegin, 0, 1);
+			if (oldsize > holebegin)
+				unmap_mapping_range(inode->i_mapping,
+							holebegin, 0, 1);
 		}
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
