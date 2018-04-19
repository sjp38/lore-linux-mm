Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D60F6B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 07:00:58 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b64so1097676pfl.13
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 04:00:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n23si2715068pgc.359.2018.04.19.04.00.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Apr 2018 04:00:57 -0700 (PDT)
Date: Thu, 19 Apr 2018 13:00:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] SLUB: Do not fallback to mininum order if __GFP_NORETRY
 is set
Message-ID: <20180419110051.GB16083@dhcp22.suse.cz>
References: <alpine.DEB.2.20.1804180944180.1062@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1804180944180.1062@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mikulas Patocka <mpatocka@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Wed 18-04-18 09:45:39, Cristopher Lameter wrote:
> Mikulas Patoka wants to ensure that no fallback to lower order happens. I
> think __GFP_NORETRY should work correctly in that case too and not fall
> back.

Overriding __GFP_NORETRY is just a bad idea. It will make the semantic
of the flag just more confusing. Note there are users who use
__GFP_NORETRY as a way to suppress heavy memory pressure and/or the OOM
killer. You do not want to change the semantic for them.

Besides that the changelog is less than optimal. What is the actual
problem? Why somebody doesn't want a fallback? Is there a configuration
that could prevent the same?

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

-- 
Michal Hocko
SUSE Labs
