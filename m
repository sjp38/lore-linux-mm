Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3B2076B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 04:26:06 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id t7-v6so1724641wmg.3
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 01:26:06 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.130])
        by mx.google.com with ESMTPS id s1-v6si1774455wrr.426.2018.06.20.01.26.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jun 2018 01:26:04 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] shmem: use monotonic time for i_generation
Date: Wed, 20 Jun 2018 10:25:39 +0200
Message-Id: <20180620082556.581543-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: y2038@lists.linaro.org, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

get_seconds() is deprecated because it will lead to a 32-bit overflow
in 2038 or 2106. We don't need the i_generation to be strictly
monotonic anyway, and other file systems like ext4 and xfs just use
prandom_u32(), so let's use the same one here.

If this is considered too slow, we could also use ktime_get_seconds()
or ktime_get_real_seconds() to keep the previous behavior.
Both of these return a time64_t and are not deprecated, but only
return a unique value once per second, and are predictable.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 mm/shmem.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 2cab84403055..387ae5323f56 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -29,6 +29,7 @@
 #include <linux/pagemap.h>
 #include <linux/file.h>
 #include <linux/mm.h>
+#include <linux/random.h>
 #include <linux/sched/signal.h>
 #include <linux/export.h>
 #include <linux/swap.h>
@@ -2187,7 +2188,7 @@ static struct inode *shmem_get_inode(struct super_block *sb, const struct inode
 		inode_init_owner(inode, dir, mode);
 		inode->i_blocks = 0;
 		inode->i_atime = inode->i_mtime = inode->i_ctime = current_time(inode);
-		inode->i_generation = get_seconds();
+		inode->i_generation = prandom_u32();
 		info = SHMEM_I(inode);
 		memset(info, 0, (char *)inode - (char *)info);
 		spin_lock_init(&info->lock);
-- 
2.9.0
