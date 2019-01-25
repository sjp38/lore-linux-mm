Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5CF978E00DF
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 12:38:47 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id a2so6752971pgt.11
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 09:38:47 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m64si25262468pfb.224.2019.01.25.09.38.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 25 Jan 2019 09:38:44 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH] mm: Prevent mapping slab pages to userspace
Date: Fri, 25 Jan 2019 09:38:27 -0800
Message-Id: <20190125173827.2658-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>, Michael Ellerman <mpe@ellerman.id.au>

It's never appropriate to map a page allocated by SLAB into userspace.
A buggy device driver might try this, or an attacker might be able to
find a way to make it happen.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 mm/memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index e11ca9dd823f..ce8c90b752be 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1451,7 +1451,7 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
 	spinlock_t *ptl;
 
 	retval = -EINVAL;
-	if (PageAnon(page))
+	if (PageAnon(page) || PageSlab(page))
 		goto out;
 	retval = -ENOMEM;
 	flush_dcache_page(page);
-- 
2.20.1
