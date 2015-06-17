Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id A50D26B0074
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 19:03:02 -0400 (EDT)
Received: by iebmu5 with SMTP id mu5so43994832ieb.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 16:03:02 -0700 (PDT)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com. [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id f13si5056879igh.36.2015.06.17.16.03.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 16:03:02 -0700 (PDT)
Received: by igbiq7 with SMTP id iq7so78894092igb.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 16:03:02 -0700 (PDT)
Date: Wed, 17 Jun 2015 16:02:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC V3] net: don't wait for order-3 page allocation
In-Reply-To: <557AA834.8070503@suse.cz>
Message-ID: <alpine.DEB.2.10.1506171602300.8203@chino.kir.corp.google.com>
References: <0099265406c32b9b9057de100404a4148d602cdd.1434066549.git.shli@fb.com> <557AA834.8070503@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Shaohua Li <shli@fb.com>, netdev@vger.kernel.org, davem@davemloft.net, Kernel-team@fb.com, clm@fb.com, linux-mm@kvack.org, dbavatar@gmail.com, Eric Dumazet <edumazet@google.com>

On Fri, 12 Jun 2015, Vlastimil Babka wrote:

> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > index 3cfff2a..41ec022 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -4398,7 +4398,7 @@ struct sk_buff *alloc_skb_with_frags(unsigned long
> > header_len,
> > 
> >   		while (order) {
> >   			if (npages >= 1 << order) {
> > -				page = alloc_pages(gfp_mask |
> > +				page = alloc_pages((gfp_mask & ~__GFP_WAIT) |
> >   						   __GFP_COMP |
> >   						   __GFP_NOWARN |
> >   						   __GFP_NORETRY,
> 
> Note that __GFP_NORETRY is weaker than ~__GFP_WAIT and thus redundant. But it
> won't hurt anything leaving it there. And you might consider __GFP_NO_KSWAPD
> instead, as I said in the other thread.
> 

Yeah, I agreed with __GFP_NO_KSWAPD to avoid utilizing memory reserves for 
this.

> > diff --git a/net/core/sock.c b/net/core/sock.c
> > index 292f422..e9855a4 100644
> > --- a/net/core/sock.c
> > +++ b/net/core/sock.c
> > @@ -1883,7 +1883,7 @@ bool skb_page_frag_refill(unsigned int sz, struct
> > page_frag *pfrag, gfp_t gfp)
> > 
> >   	pfrag->offset = 0;
> >   	if (SKB_FRAG_PAGE_ORDER) {
> > -		pfrag->page = alloc_pages(gfp | __GFP_COMP |
> > +		pfrag->page = alloc_pages((gfp & ~__GFP_WAIT) | __GFP_COMP |
> >   					  __GFP_NOWARN | __GFP_NORETRY,
> >   					  SKB_FRAG_PAGE_ORDER);
> >   		if (likely(pfrag->page)) {
> > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
