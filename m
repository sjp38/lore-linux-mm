Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 79B956B00B1
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 10:15:46 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v3 02/16] slub: use free_page instead of put_page for freeing kmalloc allocation
Date: Tue, 18 Sep 2012 18:11:56 +0400
Message-Id: <1347977530-29755-3-git-send-email-glommer@parallels.com>
In-Reply-To: <1347977530-29755-1-git-send-email-glommer@parallels.com>
References: <1347977530-29755-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>

When freeing objects, the slub allocator will most of the time free
empty pages by calling __free_pages(). But high-order kmalloc will be
diposed by means of put_page() instead. It makes no sense to call
put_page() in kernel pages that are provided by the object allocators,
so we shouldn't be doing this ourselves. Aside from the consistency
change, we don't change the flow too much. put_page()'s would call its
dtor function, which is __free_pages. We also already do all of the
Compound page tests ourselves, and the Mlock test we lose don't really
matter.

[v2: modified Changelog ]

Signed-off-by: Glauber Costa <glommer@parallels.com>
Acked-by: Christoph Lameter <cl@linux.com>
CC: David Rientjes <rientjes@google.com>
CC: Pekka Enberg <penberg@kernel.org>
---
 mm/slub.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 9f86353..09a91d0 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3451,7 +3451,7 @@ void kfree(const void *x)
 	if (unlikely(!PageSlab(page))) {
 		BUG_ON(!PageCompound(page));
 		kmemleak_free(x);
-		put_page(page);
+		__free_pages(page, compound_order(page));
 		return;
 	}
 	slab_free(page->slab, page, object, _RET_IP_);
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
