Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id A62356B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 09:11:09 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH] slub: use free_page instead of put_page for freeing kmalloc allocation
Date: Thu,  2 Aug 2012 17:11:05 +0400
Message-Id: <1343913065-14631-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Glauber Costa <glommer@parallels.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

The slab allocators provide its users with memory regions, with very few
placement guarantees. No user should assume an actual page is given by
kmalloc calls that are multiple of a page in size. This means that we
can be sure that every sane user of the interface would not mess with
the page reference counting of the underlying page.

When freeing objects, the slub allocator will most of the time free
empty pages by calling __free_pages(). But high-order kmalloc will be
diposed by means of put_page() instead.

It makes no sense to call put_page() in kernel pages that are not
reference counted, which is the case here.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: David Rientjes <rientjes@google.com>
CC: Pekka Enberg <penberg@kernel.org>
CC: Christoph Lameter <cl@linux.com>
---
 mm/slub.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index e517d43..9ca4e20 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3453,7 +3453,7 @@ void kfree(const void *x)
 	if (unlikely(!PageSlab(page))) {
 		BUG_ON(!PageCompound(page));
 		kmemleak_free(x);
-		put_page(page);
+		__free_pages(page, compound_order(page));
 		return;
 	}
 	slab_free(page->slab, page, object, _RET_IP_);
-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
