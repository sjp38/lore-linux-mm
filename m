Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A259C6B0087
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:05 -0500 (EST)
Received: from int-mx03.intmail.prod.int.phx2.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o1QK94DI010132
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:04 -0500
Message-Id: <20100226200902.884271827@redhat.com>
Date: Fri, 26 Feb 2010 21:04:58 +0100
From: aarcange@redhat.com
Subject: [patch 25/35] _GFP_NO_KSWAPD
References: <20100226200433.516502198@redhat.com>
Content-Disposition: inline; filename=gfp_no_kswapd
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Transparent hugepage allocations must be allowed not to invoke kswapd or any
other kind of indirect reclaim (especially when the defrag sysfs is control
disabled). It's unacceptable to swap out anonymous pages (potentially
anonymous transparent hugepages) in order to create new transparent hugepages.
This is true for the MADV_HUGEPAGE areas too (swapping out a kvm virtual
machine and so having it suffer an unbearable slowdown, so another one with
guest physical memory marked MADV_HUGEPAGE can run 30% faster if it is running
memory intensive workloads, makes no sense). If a transparent hugepage
allocation fails the slowdown is minor and there is total fallback, so kswapd
should never be asked to swapout memory to allow the high order allocation to
succeed.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
---
 include/linux/gfp.h |    4 +++-
 mm/page_alloc.c     |    3 ++-
 2 files changed, 5 insertions(+), 2 deletions(-)

--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -59,13 +59,15 @@ struct vm_area_struct;
 #define __GFP_NOTRACK	((__force gfp_t)0)
 #endif
 
+#define __GFP_NO_KSWAPD	((__force gfp_t)0x400000u)
+
 /*
  * This may seem redundant, but it's a way of annotating false positives vs.
  * allocations that simply cannot be supported (e.g. page tables).
  */
 #define __GFP_NOTRACK_FALSE_POSITIVE (__GFP_NOTRACK)
 
-#define __GFP_BITS_SHIFT 22	/* Room for 22 __GFP_FOO bits */
+#define __GFP_BITS_SHIFT 23	/* Room for 23 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
 
 /* This equals 0, but use constants in case they ever change */
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1865,7 +1865,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, u
 		goto nopage;
 
 restart:
-	wake_all_kswapd(order, zonelist, high_zoneidx);
+	if (!(gfp_mask & __GFP_NO_KSWAPD))
+		wake_all_kswapd(order, zonelist, high_zoneidx);
 
 	/*
 	 * OK, we're below the kswapd watermark and have kicked background

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
