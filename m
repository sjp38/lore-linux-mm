Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 57B246B0358
	for <linux-mm@kvack.org>; Sun, 28 Oct 2018 22:30:31 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id v88-v6so6400603pfk.19
        for <linux-mm@kvack.org>; Sun, 28 Oct 2018 19:30:31 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f88-v6si19641334pfe.243.2018.10.28.19.30.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 28 Oct 2018 19:30:30 -0700 (PDT)
Date: Sun, 28 Oct 2018 19:30:26 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCHv2] mm/page_owner: use kvmalloc instead of kmalloc
Message-ID: <20181029023026.GC28520@bombadil.infradead.org>
References: <1540779403-27622-1-git-send-email-miles.chen@mediatek.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1540779403-27622-1-git-send-email-miles.chen@mediatek.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: miles.chen@mediatek.com
Cc: Matthias Brugger <matthias.bgg@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wsd_upstream@mediatek.com, linux-mediatek@lists.infradead.org, linux-arm-kernel@lists.infradead.org, Joe Perches <joe@perches.com>, Michal Hocko <mhocko@kernel.org>

On Mon, Oct 29, 2018 at 10:16:43AM +0800, miles.chen@mediatek.com wrote:
> The kbuf used by page owner is allocated by kmalloc(), which means it
> can use only normal memory and there might be a "out of memory"
> issue when we're out of normal memory.
> 
> Use kvmalloc() so we can also allocate kbuf from
> normal/hihghmem on 32bit kernel.

That's a misconception:

        ret = kmalloc_node(size, kmalloc_flags, node);

        /*
         * It doesn't really make sense to fallback to vmalloc for sub page
         * requests
         */
        if (ret || size <= PAGE_SIZE)
                return ret;

Now, maybe this is an opportunity for us to improve kvmalloc.  Maybe like
this ...

diff --git a/mm/util.c b/mm/util.c
index 8bf08b5b5760..fdf5b34d2c28 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -416,10 +416,10 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
 	ret = kmalloc_node(size, kmalloc_flags, node);
 
 	/*
-	 * It doesn't really make sense to fallback to vmalloc for sub page
-	 * requests
+	 * It only makes sense to fallback to vmalloc for sub page
+	 * requests if we might be able to allocate highmem pages.
 	 */
-	if (ret || size <= PAGE_SIZE)
+	if (ret || (!IS_ENABLED(CONFIG_HIGHMEM) && size <= PAGE_SIZE))
 		return ret;
 
 	return __vmalloc_node_flags_caller(size, node, flags,
