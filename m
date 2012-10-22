Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 6CD886B0062
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 08:04:23 -0400 (EDT)
Received: by mail-gg0-f169.google.com with SMTP id i1so483246ggm.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 05:04:22 -0700 (PDT)
From: Ezequiel Garcia <elezegarcia@gmail.com>
Subject: [PATCH 1/2] mm/slob: Mark zone page state to get slab usage at /proc/meminfo
Date: Mon, 22 Oct 2012 09:03:54 -0300
Message-Id: <1350907434-2202-1-git-send-email-elezegarcia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Tim Bird <tim.bird@am.sony.com>, Ezequiel Garcia <elezegarcia@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On page allocations, SLAB and SLUB modify zone page state counters
NR_SLAB_UNRECLAIMABLE or NR_SLAB_RECLAIMABLE.
This allows to obtain slab usage information at /proc/meminfo.

Without this patch, /proc/meminfo will show zero Slab usage for SLOB.

Since SLOB discards SLAB_RECLAIM_ACCOUNT flag, we always use
NR_SLAB_UNRECLAIMABLE zone state item.

Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Matt Mackall <mpm@selenic.com>
Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
---
 mm/slob.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
index fffbc82..a65e802 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -320,6 +320,9 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 		sp = virt_to_page(b);
 		__SetPageSlab(sp);
 
+		/* Slob allocations are never flagged reclaimable */
+		inc_zone_page_state(sp, NR_SLAB_UNRECLAIMABLE);
+
 		spin_lock_irqsave(&slob_lock, flags);
 		sp->units = SLOB_UNITS(PAGE_SIZE);
 		sp->freelist = b;
@@ -361,6 +364,9 @@ static void slob_free(void *block, int size)
 			clear_slob_page_free(sp);
 		spin_unlock_irqrestore(&slob_lock, flags);
 		__ClearPageSlab(sp);
+
+		dec_zone_page_state(sp, NR_SLAB_UNRECLAIMABLE);
+
 		reset_page_mapcount(sp);
 		slob_free_pages(b, 0);
 		return;
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
