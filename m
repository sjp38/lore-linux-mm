Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id AF8666B005D
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 08:22:40 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: Any reason to use put_page in slub.c?
Date: Fri, 27 Jul 2012 16:19:46 +0400
Message-Id: <1343391586-18837-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>

Hi,

I've recently came across a bug in my kmemcg slab implementation, where memory
wasn't being unaccounted every time I expected it to be.  (bugs found by myself
are becoming a lot lot rarer, for the record)

I tracked it down to be due to the fact that we are now unaccounting at the
page allocator by calling __free_accounted_pages instead of normal
__free_pages.

However, higher order kmalloc allocations in the slub doesn't do that.  They
call put_page() instead, and I missed the conversion spot when converting
__free_pages() to __free_accounted_pages().

Now, although of course I can come up with put_accounted_page(), this is a bit
more awkward: first, it is in everybody's interest in keeping changes to the
page allocator to a minimum; also, put_page will not necessarily free the page,
so the semantics can get a bit complicated.

Since we are not doing any kind of page sharing with those pages in the slub -
and are already doing compound checks ourselves, I was wondering why couldn't
we just use __free_pages() instead. I see no reason not to. Replacing it with
__free_page() seems to work - my patched kernel is up and running, and doing
fine.

But I am still wondering if there is anything I am overlooking.

Do you guys think the following patch is safe?

---
 mm/slub.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index a136a75..a8fffeb 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3399,7 +3399,7 @@ void kfree(const void *x)
 	if (unlikely(!PageSlab(page))) {
 		BUG_ON(!PageCompound(page));
 		kmemleak_free(x);
-		put_page(page);
+		__free_pages(page);
 		return;
 	}
 	slab_free(page->slab, page, object, _RET_IP_);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
