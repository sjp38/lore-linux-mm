Message-Id: <20071004040005.850376534@sgi.com>
References: <20071004035935.042951211@sgi.com>
Date: Wed, 03 Oct 2007 20:59:53 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [18/18] SLUB: Use fallback for table of callers/freers of a slab cache
Content-Disposition: inline; filename=vcompound_slub_safe
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The caller table can get quite large if there are many call sites for a
particular slab. Add GFP_FALLBACK allows falling back to vmalloc in case
the caller table gets too big and memory is fragmented. Currently we
would fail the operation.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2007-10-03 20:00:23.000000000 -0700
+++ linux-2.6/mm/slub.c	2007-10-03 20:01:12.000000000 -0700
@@ -3003,7 +3003,8 @@ static int alloc_loc_track(struct loc_tr
 
 	order = get_order(sizeof(struct location) * max);
 
-	l = (void *)__get_free_pages(flags, order);
+	l = (void *)__get_free_pages(flags | __GFP_COMP | __GFP_VFALLBACK,
+								order);
 	if (!l)
 		return 0;
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
