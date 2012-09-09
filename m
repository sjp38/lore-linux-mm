Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id BD8B86B0044
	for <linux-mm@kvack.org>; Sat,  8 Sep 2012 23:42:40 -0400 (EDT)
Received: by iagk10 with SMTP id k10so1014997iag.14
        for <linux-mm@kvack.org>; Sat, 08 Sep 2012 20:42:40 -0700 (PDT)
Date: Sat, 8 Sep 2012 20:42:03 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH mmotm] slub: zero page to fix boot crashes
Message-ID: <alpine.LSU.2.00.1209082032100.2213@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

Latest mmotm rarely boots if SLUB is enabled: earlyprintk=vga shows
it crashing with various backtraces.  The memset has now been removed
from kmem_cache_open(), so kmem_cache_init() needs to zero its page.
This gets SLUB booting reliably again.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/slub.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- mmotm/mm/slub.c	2012-09-07 12:39:38.136019730 -0700
+++ fixed/mm/slub.c	2012-09-08 19:37:38.608993123 -0700
@@ -3712,7 +3712,7 @@ void __init kmem_cache_init(void)
 	/* Allocate two kmem_caches from the page allocator */
 	kmalloc_size = ALIGN(kmem_size, cache_line_size());
 	order = get_order(2 * kmalloc_size);
-	kmem_cache = (void *)__get_free_pages(GFP_NOWAIT, order);
+	kmem_cache = (void *)__get_free_pages(GFP_NOWAIT | __GFP_ZERO, order);
 
 	/*
 	 * Must first have the slab cache available for the allocations of the

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
