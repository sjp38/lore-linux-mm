Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id F16C56B0253
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 01:39:44 -0400 (EDT)
Received: by pabrc13 with SMTP id rc13so43591273pab.0
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 22:39:44 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id iv8si10574954pbc.11.2015.10.13.22.39.44
        for <linux-mm@kvack.org>;
        Tue, 13 Oct 2015 22:39:44 -0700 (PDT)
Message-ID: <561DE9F3.504@intel.com>
Date: Wed, 14 Oct 2015 13:36:51 +0800
From: Pan Xinhui <xinhuix.pan@intel.com>
MIME-Version: 1.0
Subject: [PATCH] gfp: GFP_RECLAIM_MASK should include __GFP_NO_KSWAPD
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, vbabka@suse.cz, rientjes@google.com, hannes@cmpxchg.org, mhocko@suse.cz, nasa4836@gmail.com, mgorman@suse.de, alexander.h.duyck@redhat.com, aneesh.kumar@linux.vnet.ibm.com, "yanmin_zhang@linux.intel.com" <yanmin_zhang@linux.intel.com>

From: Pan Xinhui <xinhuix.pan@intel.com>

GFP_RECLAIM_MASK was introduced in commit 6cb062296f73 ("Categorize GFP
flags"). In slub subsystem, this macro controls slub's allocation
behavior. In particular, some flags which are not in GFP_RECLAIM_MASK
will be cleared. So when slub pass this new gfp_flag into page
allocator, we might lost some very important flags.

There are some mistakes when we introduce __GFP_NO_KSWAPD. This flag is
used to avoid any scheduler-related codes recursive.  But it seems like
patch author forgot to add it into GFP_RECLAIM_MASK. So lets add it now.

Signed-off-by: Pan Xinhui <xinhuix.pan@intel.com>
---
 include/linux/gfp.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index f92cbd2..9ebad4d 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -130,7 +130,8 @@ struct vm_area_struct;
 /* Control page allocator reclaim behavior */
 #define GFP_RECLAIM_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS|\
 			__GFP_NOWARN|__GFP_REPEAT|__GFP_NOFAIL|\
-			__GFP_NORETRY|__GFP_MEMALLOC|__GFP_NOMEMALLOC)
+			__GFP_NORETRY|__GFP_MEMALLOC|__GFP_NOMEMALLOC|\
+			__GFP_NO_KSWAPD)
 
 /* Control slab gfp mask during early boot */
 #define GFP_BOOT_MASK (__GFP_BITS_MASK & ~(__GFP_WAIT|__GFP_IO|__GFP_FS))
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
