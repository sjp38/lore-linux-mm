Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 140E26B02C3
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 19:35:25 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id w42so1735989uaw.2
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 16:35:25 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 16si402734vkl.292.2017.08.31.16.35.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Aug 2017 16:35:24 -0700 (PDT)
Date: Thu, 31 Aug 2017 16:35:15 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: [PATCH] mm: kvfree the swap cluster info if the swap file is
 unsatisfactory
Message-ID: <20170831233515.GR3775@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, ying.huang@intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

If initializing a small swap file fails because the swap file has a
problem (holes, etc.) then we need to free the cluster info as part of
cleanup.  Unfortunately a previous patch changed the code to use
kvzalloc but did not change all the vfree calls to use kvfree.

Found by running generic/357 from xfstests.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 mm/swapfile.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 6ba4aab..c1deb01 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -3052,7 +3052,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	p->flags = 0;
 	spin_unlock(&swap_lock);
 	vfree(swap_map);
-	vfree(cluster_info);
+	kvfree(cluster_info);
 	if (swap_file) {
 		if (inode && S_ISREG(inode->i_mode)) {
 			inode_unlock(inode);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
