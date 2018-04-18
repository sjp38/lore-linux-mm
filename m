Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9EF5A6B0007
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 11:05:38 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id r2-v6so1089390ywh.8
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 08:05:38 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id r189-v6si358902ybf.19.2018.04.18.08.05.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 08:05:37 -0700 (PDT)
Date: Wed, 18 Apr 2018 11:05:31 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] SLUB: Do not fallback to mininum order if __GFP_NORETRY
 is set
In-Reply-To: <alpine.DEB.2.20.1804180944180.1062@nuc-kabylake>
Message-ID: <alpine.LRH.2.02.1804181102490.13213@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.DEB.2.20.1804180944180.1062@nuc-kabylake>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mike Snitzer <snitzer@redhat.com>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org



On Wed, 18 Apr 2018, Christopher Lameter wrote:

> Mikulas Patoka wants to ensure that no fallback to lower order happens. I
> think __GFP_NORETRY should work correctly in that case too and not fall
> back.
> 
> 
> 
> Allocating at a smaller order is a retry operation and should not
> be attempted.
> 
> If the caller does not want retries then respect that.
> 
> GFP_NORETRY allows callers to ensure that only maximum order
> allocations are attempted.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c
> +++ linux/mm/slub.c
> @@ -1598,7 +1598,7 @@ static struct page *allocate_slab(struct
>  		alloc_gfp = (alloc_gfp | __GFP_NOMEMALLOC) & ~(__GFP_RECLAIM|__GFP_NOFAIL);
> 
>  	page = alloc_slab_page(s, alloc_gfp, node, oo);
> -	if (unlikely(!page)) {
> +	if (unlikely(!page) && !(flags & __GFP_NORETRY)) {
>  		oo = s->min;
>  		alloc_gfp = flags;
>  		/*

No, this would hit NULL pointer dereference if page is NULL and 
__GFP_NORETRY is set. You want this:

---
 mm/slub.c |    2 ++
 1 file changed, 2 insertions(+)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2018-04-17 20:58:23.000000000 +0200
+++ linux-2.6/mm/slub.c	2018-04-18 17:04:01.000000000 +0200
@@ -1599,6 +1599,8 @@ static struct page *allocate_slab(struct
 
 	page = alloc_slab_page(s, alloc_gfp, node, oo);
 	if (unlikely(!page)) {
+		if (flags & __GFP_NORETRY)
+			goto out;
 		oo = s->min;
 		alloc_gfp = flags;
 		/*
