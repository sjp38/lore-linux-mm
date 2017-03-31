Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id A4B196B0390
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 12:40:32 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id j127so9809637itj.17
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 09:40:32 -0700 (PDT)
Received: from mail-pg0-x22f.google.com (mail-pg0-x22f.google.com. [2607:f8b0:400e:c05::22f])
        by mx.google.com with ESMTPS id i21si6859368ioi.48.2017.03.31.09.40.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Mar 2017 09:40:32 -0700 (PDT)
Received: by mail-pg0-x22f.google.com with SMTP id 21so76159080pgg.1
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 09:40:31 -0700 (PDT)
Date: Fri, 31 Mar 2017 09:40:28 -0700
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] mm: Add additional consistency check
Message-ID: <20170331164028.GA118828@beast>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

As found in PaX, this adds a cheap check on heap consistency, just to
notice if things have gotten corrupted in the page lookup.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 mm/slab.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/slab.h b/mm/slab.h
index 65e7c3fcac72..64447640b70c 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -384,6 +384,7 @@ static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
 		return s;
 
 	page = virt_to_head_page(x);
+	BUG_ON(!PageSlab(page));
 	cachep = page->slab_cache;
 	if (slab_equal_or_root(cachep, s))
 		return cachep;
-- 
2.7.4


-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
