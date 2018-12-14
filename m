Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4FE0D8E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 14:45:04 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id d18so5243909pfe.0
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 11:45:04 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v190si4994567pfv.8.2018.12.14.11.45.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 14 Dec 2018 11:45:03 -0800 (PST)
Date: Fri, 14 Dec 2018 11:45:00 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC 2/4] mm: separate memory allocation and actual work in
 alloc_vmap_area()
Message-ID: <20181214194500.GF10600@bombadil.infradead.org>
References: <20181214180720.32040-1-guro@fb.com>
 <20181214180720.32040-3-guro@fb.com>
 <20181214181322.GC10600@bombadil.infradead.org>
 <0192c1984f42ad0a33e4c9aca04df90c97ebf412.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0192c1984f42ad0a33e4c9aca04df90c97ebf412.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Roman Gushchin <guroan@gmail.com>, linux-mm@kvack.org, Alexey Dobriyan <adobriyan@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, kernel-team@fb.com, Roman Gushchin <guro@fb.com>

On Fri, Dec 14, 2018 at 11:40:45AM -0800, Joe Perches wrote:
> On Fri, 2018-12-14 at 10:13 -0800, Matthew Wilcox wrote:
> > On Fri, Dec 14, 2018 at 10:07:18AM -0800, Roman Gushchin wrote:
> > > +/*
> > > + * Allocate a region of KVA of the specified size and alignment, within the
> > > + * vstart and vend.
> > > + */
> > > +static struct vmap_area *alloc_vmap_area(unsigned long size,
> > > +					 unsigned long align,
> > > +					 unsigned long vstart,
> > > +					 unsigned long vend,
> > > +					 int node, gfp_t gfp_mask)
> > > +{
> > > +	struct vmap_area *va;
> > > +	int ret;
> > > +
> > > +	va = kmalloc_node(sizeof(struct vmap_area),
> > > +			gfp_mask & GFP_RECLAIM_MASK, node);
> > > +	if (unlikely(!va))
> > > +		return ERR_PTR(-ENOMEM);
> > > +
> > > +	ret = init_vmap_area(va, size, align, vstart, vend, node, gfp_mask);
> > > +	if (ret) {
> > > +		kfree(va);
> > > +		return ERR_PTR(ret);
> > > +	}
> > > +
> > > +	return va;
> > >  }
> > >  
> > > +
> > 
> > Another spurious blank line?
> 
> I don't think so.
> 
> I think it is the better style to separate
> the error return from the normal return.

Umm ... this blank line changed the file from having one blank line
after the function to having two blank lines after the function.
