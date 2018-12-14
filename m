Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 86AC48E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 14:40:50 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id p21so6758257itb.8
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 11:40:50 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0087.hostedemail.com. [216.40.44.87])
        by mx.google.com with ESMTPS id u13si2636081ior.114.2018.12.14.11.40.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 11:40:49 -0800 (PST)
Message-ID: <0192c1984f42ad0a33e4c9aca04df90c97ebf412.camel@perches.com>
Subject: Re: [RFC 2/4] mm: separate memory allocation and actual work in
 alloc_vmap_area()
From: Joe Perches <joe@perches.com>
Date: Fri, 14 Dec 2018 11:40:45 -0800
In-Reply-To: <20181214181322.GC10600@bombadil.infradead.org>
References: <20181214180720.32040-1-guro@fb.com>
	 <20181214180720.32040-3-guro@fb.com>
	 <20181214181322.GC10600@bombadil.infradead.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Roman Gushchin <guroan@gmail.com>
Cc: linux-mm@kvack.org, Alexey Dobriyan <adobriyan@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, kernel-team@fb.com, Roman Gushchin <guro@fb.com>

On Fri, 2018-12-14 at 10:13 -0800, Matthew Wilcox wrote:
> On Fri, Dec 14, 2018 at 10:07:18AM -0800, Roman Gushchin wrote:
> > +/*
> > + * Allocate a region of KVA of the specified size and alignment, within the
> > + * vstart and vend.
> > + */
> > +static struct vmap_area *alloc_vmap_area(unsigned long size,
> > +					 unsigned long align,
> > +					 unsigned long vstart,
> > +					 unsigned long vend,
> > +					 int node, gfp_t gfp_mask)
> > +{
> > +	struct vmap_area *va;
> > +	int ret;
> > +
> > +	va = kmalloc_node(sizeof(struct vmap_area),
> > +			gfp_mask & GFP_RECLAIM_MASK, node);
> > +	if (unlikely(!va))
> > +		return ERR_PTR(-ENOMEM);
> > +
> > +	ret = init_vmap_area(va, size, align, vstart, vend, node, gfp_mask);
> > +	if (ret) {
> > +		kfree(va);
> > +		return ERR_PTR(ret);
> > +	}
> > +
> > +	return va;
> >  }
> >  
> > +
> 
> Another spurious blank line?

I don't think so.

I think it is the better style to separate
the error return from the normal return.

> With these two fixed,
> Reviewed-by: Matthew Wilcox <willy@infradead.org>
> 
