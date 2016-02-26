Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id D26426B0254
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 01:01:35 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id ho8so46714804pac.2
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:01:35 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id b24si17594953pfj.52.2016.02.25.22.01.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 22:01:35 -0800 (PST)
Received: by mail-pa0-x22a.google.com with SMTP id ho8so46714656pac.2
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:01:35 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH v2 01/17] mm/slab: fix stale code comment
Date: Fri, 26 Feb 2016 15:01:08 +0900
Message-Id: <1456466484-3442-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

This patchset implements new freed object management way, that is,
OBJFREELIST_SLAB.  Purpose of it is to reduce memory overhead in SLAB.

SLAB needs a array to manage freed objects in a slab.  If there is
leftover after objects are packed into a slab, we can use it as a
management array, and, in this case, there is no memory waste.  But, in
the other cases, we need to allocate extra memory for a management array
or utilize dedicated internal memory in a slab for it.  Both cases causes
memory waste so it's not good.

With this patchset, freed object itself can be used for a management
array.  So, memory waste could be reduced.  Detailed idea and numbers are
described in last patch's commit description.  Please refer it.

In fact, I tested another idea implementing OBJFREELIST_SLAB with
extendable linked array through another freed object.  It can remove
memory waste completely but it causes more computational overhead in
critical lock path and it seems that overhead outweigh benefit.  So, this
patchset doesn't include it.  I will attach prototype just for a
reference.

This patch (of 16):

We use freelist_idx_t type for free object management whose size would be
smaller than size of unsigned int.  Fix it.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/slab.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index b3eca03..23fc4b0 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -537,7 +537,7 @@ static void cache_estimate(unsigned long gfporder, size_t buffer_size,
 	 * on it. For the latter case, the memory allocated for a
 	 * slab is used for:
 	 *
-	 * - One unsigned int for each object
+	 * - One freelist_idx_t for each object
 	 * - Padding to respect alignment of @align
 	 * - @buffer_size bytes for each object
 	 *
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
