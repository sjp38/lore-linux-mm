Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id D29946B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 10:45:42 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id g138so1229770qke.22
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 07:45:42 -0700 (PDT)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id m88-v6si1733855qte.103.2018.04.18.07.45.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 07:45:41 -0700 (PDT)
Date: Wed, 18 Apr 2018 09:45:39 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: [PATCH] SLUB: Do not fallback to mininum order if __GFP_NORETRY is
 set
Message-ID: <alpine.DEB.2.20.1804180944180.1062@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

Mikulas Patoka wants to ensure that no fallback to lower order happens. I
think __GFP_NORETRY should work correctly in that case too and not fall
back.



Allocating at a smaller order is a retry operation and should not
be attempted.

If the caller does not want retries then respect that.

GFP_NORETRY allows callers to ensure that only maximum order
allocations are attempted.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -1598,7 +1598,7 @@ static struct page *allocate_slab(struct
 		alloc_gfp = (alloc_gfp | __GFP_NOMEMALLOC) & ~(__GFP_RECLAIM|__GFP_NOFAIL);

 	page = alloc_slab_page(s, alloc_gfp, node, oo);
-	if (unlikely(!page)) {
+	if (unlikely(!page) && !(flags & __GFP_NORETRY)) {
 		oo = s->min;
 		alloc_gfp = flags;
 		/*
