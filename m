Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 60CED6B00AB
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 17:25:34 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id z11so6090982lbi.7
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 14:25:33 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id df2si19371972lac.21.2014.09.09.14.25.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Sep 2014 14:25:32 -0700 (PDT)
Date: Tue, 9 Sep 2014 23:25:28 +0200 (CEST)
From: Jiri Kosina <jkosina@suse.cz>
Subject: [PATCH] mm/sl[aou]b: make kfree() aware of error pointers
Message-ID: <alpine.LNX.2.00.1409092319370.5523@pobox.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Carpenter <dan.carpenter@oracle.com>, Theodore Ts'o <tytso@mit.edu>

kfree() is happy to accept NULL pointer and does nothing in such case. 
It's reasonable to expect it to behave the same if ERR_PTR is passed to 
it.

Inspired by a9cfcd63e8d ("ext4: avoid trying to kfree an ERR_PTR 
pointer").

Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---
 mm/slab.c | 2 +-
 mm/slob.c | 2 +-
 mm/slub.c | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index a467b30..1a256ac 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3612,7 +3612,7 @@ void kfree(const void *objp)
 
 	trace_kfree(_RET_IP_, objp);
 
-	if (unlikely(ZERO_OR_NULL_PTR(objp)))
+	if (unlikely(ZERO_OR_NULL_PTR(objp) || IS_ERR(objp)))
 		return;
 	local_irq_save(flags);
 	kfree_debugcheck(objp);
diff --git a/mm/slob.c b/mm/slob.c
index 21980e0..3abc42c 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -489,7 +489,7 @@ void kfree(const void *block)
 
 	trace_kfree(_RET_IP_, block);
 
-	if (unlikely(ZERO_OR_NULL_PTR(block)))
+	if (unlikely(ZERO_OR_NULL_PTR(block) || IS_ERR(objp)))
 		return;
 	kmemleak_free(block);
 
diff --git a/mm/slub.c b/mm/slub.c
index 3e8afcc..46d18ce 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3338,7 +3338,7 @@ void kfree(const void *x)
 
 	trace_kfree(_RET_IP_, x);
 
-	if (unlikely(ZERO_OR_NULL_PTR(x)))
+	if (unlikely(ZERO_OR_NULL_PTR(x) || IS_ERR(objp)))
 		return;
 
 	page = virt_to_head_page(x);

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
