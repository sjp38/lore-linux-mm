Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8C7486B025E
	for <linux-mm@kvack.org>; Sun,  8 Apr 2018 02:22:08 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id d6-v6so4312759plo.2
        for <linux-mm@kvack.org>; Sat, 07 Apr 2018 23:22:08 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x7si10795208pfk.311.2018.04.07.23.22.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 07 Apr 2018 23:22:07 -0700 (PDT)
Date: Sat, 7 Apr 2018 23:22:06 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH] z3fold: Use gfpflags_allow_blocking
Message-ID: <20180408062206.GC16007@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: linux-mm@kvack.org

From: Matthew Wilcox <mawilcox@microsoft.com>

We have a perfectly good macro to determine whether the gfp flags allow
you to sleep or not; use it instead of trying to infer it.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

diff --git a/mm/z3fold.c b/mm/z3fold.c
index d589d318727f..46fed640a956 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -533,7 +533,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 	struct z3fold_header *zhdr = NULL;
 	struct page *page = NULL;
 	enum buddy bud;
-	bool can_sleep = (gfp & __GFP_RECLAIM) == __GFP_RECLAIM;
+	bool can_sleep = gfpflags_allow_blocking(gfp);
 
 	if (!size || (gfp & __GFP_HIGHMEM))
 		return -EINVAL;
