Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id BF1316B003B
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 00:23:24 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id uo1so4507332pbc.17
        for <linux-mm@kvack.org>; Tue, 11 Jun 2013 21:23:24 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 6/8] vrange: Add GFP_NO_VRANGE allocation flag
Date: Tue, 11 Jun 2013 21:22:49 -0700
Message-Id: <1371010971-15647-7-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1371010971-15647-1-git-send-email-john.stultz@linaro.org>
References: <1371010971-15647-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dgiani@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Stultz <john.stultz@linaro.org>

From: Minchan Kim <minchan@kernel.org>

In cloning the vroot tree during a fork, we have to
allocate memory while hold the vroot lock. This is problematic,
as the memory allocation can trigger reclaim, which might require
grabbing a vroot lock in order to find purgable pages.

Thus this patch introduces GFP_NO_VRANGE which will allow
us to avoid having a allocation for vrange to trigger any
volatile range purging.

XXX: We're not yet using this flag in the later purge paths, so
we still get the lockdep warnings.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Andrea Righi <andrea@betterlinux.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: Dhaval Giani <dgiani@mozilla.com>
Cc: Jan Kara <jack@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
[jstultz: Split out from a different patch, created new commit message]
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 include/linux/gfp.h | 7 +++++--
 mm/vrange.c         | 2 +-
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 0f615eb..fa52199 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -35,6 +35,7 @@ struct vm_area_struct;
 #define ___GFP_NO_KSWAPD	0x400000u
 #define ___GFP_OTHER_NODE	0x800000u
 #define ___GFP_WRITE		0x1000000u
+#define ___GFP_NO_VRANGE	0x2000000u
 /* If the above are modified, __GFP_BITS_SHIFT may need updating */
 
 /*
@@ -70,6 +71,7 @@ struct vm_area_struct;
 #define __GFP_HIGH	((__force gfp_t)___GFP_HIGH)	/* Should access emergency pools? */
 #define __GFP_IO	((__force gfp_t)___GFP_IO)	/* Can start physical IO? */
 #define __GFP_FS	((__force gfp_t)___GFP_FS)	/* Can call down to low-level FS? */
+#define __GFP_NO_VRANGE ((__force gfp_t)___GFP_NO_VRANGE) /* Can't reclaim volatile pages */
 #define __GFP_COLD	((__force gfp_t)___GFP_COLD)	/* Cache-cold page required */
 #define __GFP_NOWARN	((__force gfp_t)___GFP_NOWARN)	/* Suppress page allocation failure warning */
 #define __GFP_REPEAT	((__force gfp_t)___GFP_REPEAT)	/* See above */
@@ -99,7 +101,7 @@ struct vm_area_struct;
  */
 #define __GFP_NOTRACK_FALSE_POSITIVE (__GFP_NOTRACK)
 
-#define __GFP_BITS_SHIFT 25	/* Room for N __GFP_FOO bits */
+#define __GFP_BITS_SHIFT 26	/* Room for N __GFP_FOO bits */
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
 
 /* This equals 0, but use constants in case they ever change */
@@ -134,7 +136,8 @@ struct vm_area_struct;
 /* Control page allocator reclaim behavior */
 #define GFP_RECLAIM_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS|\
 			__GFP_NOWARN|__GFP_REPEAT|__GFP_NOFAIL|\
-			__GFP_NORETRY|__GFP_MEMALLOC|__GFP_NOMEMALLOC)
+			__GFP_NORETRY|__GFP_MEMALLOC|__GFP_NOMEMALLOC|\
+			__GFP_NO_VRANGE)
 
 /* Control slab gfp mask during early boot */
 #define GFP_BOOT_MASK (__GFP_BITS_MASK & ~(__GFP_WAIT|__GFP_IO|__GFP_FS))
diff --git a/mm/vrange.c b/mm/vrange.c
index f3c2465..5278939 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -204,7 +204,7 @@ int vrange_fork(struct mm_struct *new_mm, struct mm_struct *old_mm)
 		range = vrange_entry(next);
 		next = rb_next(next);
 
-		new_range = __vrange_alloc(GFP_KERNEL);
+		new_range = __vrange_alloc(GFP_KERNEL|__GFP_NO_VRANGE);
 		if (!new_range)
 			goto fail;
 		__vrange_set(new_range, range->node.start,
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
