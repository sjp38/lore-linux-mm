Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id DAD946B0005
	for <linux-mm@kvack.org>; Sun,  3 Jan 2016 02:12:50 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id f206so142031999wmf.0
        for <linux-mm@kvack.org>; Sat, 02 Jan 2016 23:12:50 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id h7si137069557wjy.46.2016.01.02.23.12.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 02 Jan 2016 23:12:49 -0800 (PST)
Date: Sun, 3 Jan 2016 07:12:47 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: __vmalloc() vs. GFP_NOIO/GFP_NOFS
Message-ID: <20160103071246.GK9938@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Dave Chinner <david@fromorbit.com>, Ming Lei <ming.lei@canonical.com>

	While trying to write documentation on allocator choice, I've run
into something odd:
        /*
         * __vmalloc() will allocate data pages and auxillary structures (e.g.
         * pagetables) with GFP_KERNEL, yet we may be under GFP_NOFS context
         * here. Hence we need to tell memory reclaim that we are in such a
         * context via PF_MEMALLOC_NOIO to prevent memory reclaim re-entering
         * the filesystem here and potentially deadlocking.
         */
in XFS kmem_zalloc_large().  The comment is correct - __vmalloc() (actually,
map_vm_area() called from __vmalloc_area_node()) ignores gfp_flags; prior
to that point it does take care to pass __GFP_IO/__GFP_FS to page allocator,
but once the data pages are allocated and we get around to inserting them
into page tables those are ignored.

Allocation page tables doesn't have gfp argument at all.  Trying to propagate
it down there could be done, but it's not attractive.

Another approach is memalloc_noio_save(), actually used by XFS and some other
__vmalloc() callers that might be getting GFP_NOIO or GFP_NOFS.  That
works, but not all such callers are using that mechanism.  For example,
drbd bm_realloc_pages() has GFP_NOIO __vmalloc() with no memalloc_noio_...
in sight.  Either that GFP_NOIO is not needed there (quite possible) or
there's a deadlock in that code.  The same goes for ipoib.c ipoib_cm_tx_init();
again, either that GFP_NOIO is not needed, or it can deadlock.

Those, AFAICS, are such callers with GFP_NOIO; however, there's a shitload
of GFP_NOFS ones.  XFS uses memalloc_noio_save(), but a _lot_ of other
callers do not.  For example, all call chains leading to ceph_kvmalloc()
pass GFP_NOFS and none of them is under memalloc_noio_save().  The same
goes for GFS2 __vmalloc() callers, etc.  Again, quite a few of those probably
do not need GFP_NOFS at all, but those that do would appear to have
hard-to-trigger deadlocks.

Why do we do that in callers, though?  I.e. why not do something like this:

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 8e3c9c5..412c5d6 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1622,6 +1622,16 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 			cond_resched();
 	}
 
+	if (unlikely(!(gfp_mask & __GFP_IO))) {
+		unsigned flags = memalloc_noio_save();
+		if (map_vm_area(area, prot, pages)) {
+			memalloc_noio_restore(flags);
+			goto fail;
+		}
+		memalloc_noio_restore(flags);
+		return area->addr;
+	}
+
 	if (map_vm_area(area, prot, pages))
 		goto fail;
 	return area->addr;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
