Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3F485280031
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 04:07:48 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id rd3so7178271pab.41
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 01:07:47 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id ha1si5667756pbd.206.2014.10.31.01.07.46
        for <linux-mm@kvack.org>;
        Fri, 31 Oct 2014 01:07:47 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH] mm/slab: reverse iteration on find_mergeable()
Date: Fri, 31 Oct 2014 17:09:14 +0900
Message-Id: <1414742954-14889-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Markos Chandras <Markos.Chandras@imgtec.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Unlike the SLUB, sometimes, object isn't started at the beginning of
the slab in the SLAB. This causes the unalignment problem when
after slab merging is supported by commit 12220dea07f1 ("mm/slab:
support slab merge"). Alignment mismatch check is introduced ("mm/slab:
fix unalignment problem on Malta with EVA due to slab merge") to prevent
merge in this case.

This causes undesirable result that merging happens between
infrequently used kmem_caches if there are kmem_caches with same size and
different alignment. For example, kmem_caches whose object size
is 256 bytes, are merged into pool_workqueue rather than kmalloc-256,
because kmem_caches for kmalloc are at the tail of the list.

To prevent this situation, this patch reverses iteration order in
find_mergeable() to find frequently used kmem_caches. This change
helps to merge kmem_cache to frequently used kmem_caches, such as
kmalloc kmem_caches.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab_common.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 2657084..f6510d9 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -250,7 +250,7 @@ struct kmem_cache *find_mergeable(size_t size, size_t align,
 	size = ALIGN(size, align);
 	flags = kmem_cache_flags(size, flags, name, NULL);
 
-	list_for_each_entry(s, &slab_caches, list) {
+	list_for_each_entry_reverse(s, &slab_caches, list) {
 		if (slab_unmergeable(s))
 			continue;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
