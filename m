Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1B6456B034B
	for <linux-mm@kvack.org>; Wed, 16 May 2018 13:56:33 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id bd7-v6so972537plb.20
        for <linux-mm@kvack.org>; Wed, 16 May 2018 10:56:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x1-v6sor1999073plb.71.2018.05.16.10.56.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 May 2018 10:56:31 -0700 (PDT)
From: Omar Sandoval <osandov@osandov.com>
Subject: [PATCH] mm: fix nr_rotate_swap leak in swapon() error case
Date: Wed, 16 May 2018 10:56:22 -0700
Message-Id: <b6fe6b879f17fa68eee6cbd876f459f6e5e33495.1526491581.git.osandov@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, kernel-team@fb.com

From: Omar Sandoval <osandov@fb.com>

If swapon() fails after incrementing nr_rotate_swap, we don't decrement
it and thus effectively leak it. Make sure we decrement it if we
incremented it.

Fixes: 81a0298bdfab ("mm, swap: don't use VMA based swap readahead if HDD is used as swap")
Signed-off-by: Omar Sandoval <osandov@fb.com>
---
Based on v4.17-rc5.

 mm/swapfile.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index cc2cf04d9018..78a015fcec3b 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -3112,6 +3112,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	unsigned long *frontswap_map = NULL;
 	struct page *page = NULL;
 	struct inode *inode = NULL;
+	bool inced_nr_rotate_swap = false;
 
 	if (swap_flags & ~SWAP_FLAGS_VALID)
 		return -EINVAL;
@@ -3215,8 +3216,10 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 			cluster = per_cpu_ptr(p->percpu_cluster, cpu);
 			cluster_set_null(&cluster->index);
 		}
-	} else
+	} else {
 		atomic_inc(&nr_rotate_swap);
+		inced_nr_rotate_swap = true;
+	}
 
 	error = swap_cgroup_swapon(p->type, maxpages);
 	if (error)
@@ -3307,6 +3310,8 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	vfree(swap_map);
 	kvfree(cluster_info);
 	kvfree(frontswap_map);
+	if (inced_nr_rotate_swap)
+		atomic_dec(&nr_rotate_swap);
 	if (swap_file) {
 		if (inode && S_ISREG(inode->i_mode)) {
 			inode_unlock(inode);
-- 
2.17.0
