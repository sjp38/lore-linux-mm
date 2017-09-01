Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0C8766B0292
	for <linux-mm@kvack.org>; Fri,  1 Sep 2017 04:33:56 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n7so8416003pfi.7
        for <linux-mm@kvack.org>; Fri, 01 Sep 2017 01:33:56 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d130sor1119595pgc.264.2017.09.01.01.33.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Sep 2017 01:33:55 -0700 (PDT)
Date: Fri, 1 Sep 2017 01:33:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: kvfree the swap cluster info if the swap file is
 unsatisfactory
In-Reply-To: <20170831233515.GR3775@magnolia>
Message-ID: <alpine.DEB.2.10.1709010123020.102682@chino.kir.corp.google.com>
References: <20170831233515.GR3775@magnolia>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 31 Aug 2017, Darrick J. Wong wrote:

> If initializing a small swap file fails because the swap file has a
> problem (holes, etc.) then we need to free the cluster info as part of
> cleanup.  Unfortunately a previous patch changed the code to use
> kvzalloc but did not change all the vfree calls to use kvfree.
> 

Hopefully this can make it into 4.13.

Fixes: 54f180d3c181 ("mm, swap: use kvzalloc to allocate some swap data structures")
Cc: stable@vger.kernel.org [4.12]

> Found by running generic/357 from xfstests.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>

Acked-by: David Rientjes <rientjes@google.com>

But I think there's also a memory leak and we need this on top of your 
fix:


mm, swapfile: fix swapon frontswap_map memory leak on error 

Free frontswap_map if an error is encountered before enable_swap_info().

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/swapfile.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/swapfile.c b/mm/swapfile.c
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -3053,6 +3053,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	spin_unlock(&swap_lock);
 	vfree(swap_map);
 	kvfree(cluster_info);
+	kvfree(frontswap_map);
 	if (swap_file) {
 		if (inode && S_ISREG(inode->i_mode)) {
 			inode_unlock(inode);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
