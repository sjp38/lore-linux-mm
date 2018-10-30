Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 17FD46B04B4
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 21:29:23 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id s24-v6so7941605plp.12
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 18:29:23 -0700 (PDT)
Received: from mailgw02.mediatek.com ([210.61.82.184])
        by mx.google.com with ESMTPS id o12-v6si21144958plk.360.2018.10.29.18.29.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Oct 2018 18:29:21 -0700 (PDT)
Message-ID: <1540862950.12374.40.camel@mtkswgap22>
Subject: Re: [PATCH v3] mm/page_owner: use kvmalloc instead of kmalloc
From: Miles Chen <miles.chen@mediatek.com>
Date: Tue, 30 Oct 2018 09:29:10 +0800
In-Reply-To: <20181029081706.GC32673@dhcp22.suse.cz>
References: <1540790176-32339-1-git-send-email-miles.chen@mediatek.com>
	 <20181029080708.GA32673@dhcp22.suse.cz>
	 <20181029081706.GC32673@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joe Perches <joe@perches.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com

On Mon, 2018-10-29 at 09:17 +0100, Michal Hocko wrote:
> On Mon 29-10-18 09:07:08, Michal Hocko wrote:
> [...]
> > Besides that, the following doesn't make much sense to me. It simply
> > makes no sense to use vmalloc for sub page allocation regardless of
> > HIGHMEM.
> 
> OK, it is still early morning here. Now I get the point of the patch.
> You just want to (ab)use highmeme for smaller requests. I do not like
> this, to be honest. It causes an internal fragmentation and more
> importantly the VMALLOC space on 32b where HIGHMEM is enabled (do we
> have any 64b with HIGHMEM btw?) is quite small to be wasted like that.
> 
thanks for your comment. It looks like that using vmalloc fallback for
sub page allocation is not good here.

Your comment gave another idea:

1. force kbuf to PAGE_SIZE
2. allocate a page by alloc_page(GFP_KERNEL | __GFP_HIGHMEM); so we can
get a highmem page if possible
3. use kmap/kunmap pair to create mapping for this page. No vmalloc
space is used.
4. do not change kvmalloc logic.


> In any case such a changes should come with some numbers and as a
> separate patch for sure.
> 
> > > diff --git a/mm/util.c b/mm/util.c
> > > index 8bf08b5b5760..7b1c59b9bfbf 100644
> > > --- a/mm/util.c
> > > +++ b/mm/util.c
> > > @@ -416,10 +416,10 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
> > >  	ret = kmalloc_node(size, kmalloc_flags, node);
> > >  
> > >  	/*
> > > -	 * It doesn't really make sense to fallback to vmalloc for sub page
> > > -	 * requests
> > > +	 * It only makes sense to fallback to vmalloc for sub page
> > > +	 * requests if we might be able to allocate highmem pages.
> > >  	 */
> > > -	if (ret || size <= PAGE_SIZE)
> > > +	if (ret || (!IS_ENABLED(CONFIG_HIGHMEM) && size <= PAGE_SIZE))
> > >  		return ret;
> > >  
> > >  	return __vmalloc_node_flags_caller(size, node, flags,
> > > -- 
> > > 2.18.0
> > > 
> > 
> > -- 
> > Michal Hocko
> > SUSE Labs
> 
