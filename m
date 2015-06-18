Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 79DA06B0074
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 10:30:25 -0400 (EDT)
Received: by labko7 with SMTP id ko7so55764013lab.2
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 07:30:24 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h15si14230529wjq.149.2015.06.18.07.30.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 18 Jun 2015 07:30:23 -0700 (PDT)
Date: Thu, 18 Jun 2015 16:30:19 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC V3] net: don't wait for order-3 page allocation
Message-ID: <20150618143019.GE5858@dhcp22.suse.cz>
References: <0099265406c32b9b9057de100404a4148d602cdd.1434066549.git.shli@fb.com>
 <557AA834.8070503@suse.cz>
 <alpine.DEB.2.10.1506171602300.8203@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1506171602300.8203@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Shaohua Li <shli@fb.com>, netdev@vger.kernel.org, davem@davemloft.net, Kernel-team@fb.com, clm@fb.com, linux-mm@kvack.org, dbavatar@gmail.com, Eric Dumazet <edumazet@google.com>

On Wed 17-06-15 16:02:59, David Rientjes wrote:
> On Fri, 12 Jun 2015, Vlastimil Babka wrote:
> 
> > > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > > index 3cfff2a..41ec022 100644
> > > --- a/net/core/skbuff.c
> > > +++ b/net/core/skbuff.c
> > > @@ -4398,7 +4398,7 @@ struct sk_buff *alloc_skb_with_frags(unsigned long
> > > header_len,
> > > 
> > >   		while (order) {
> > >   			if (npages >= 1 << order) {
> > > -				page = alloc_pages(gfp_mask |
> > > +				page = alloc_pages((gfp_mask & ~__GFP_WAIT) |
> > >   						   __GFP_COMP |
> > >   						   __GFP_NOWARN |
> > >   						   __GFP_NORETRY,
> > 
> > Note that __GFP_NORETRY is weaker than ~__GFP_WAIT and thus redundant. But it
> > won't hurt anything leaving it there. And you might consider __GFP_NO_KSWAPD
> > instead, as I said in the other thread.
> > 
> 
> Yeah, I agreed with __GFP_NO_KSWAPD to avoid utilizing memory reserves for 
> this.

Abusing __GFP_NO_KSWAPD is a wrong way to go IMHO. It is true that the
_current_ implementation of the allocator has this nasty and very subtle
side effect but that doesn't mean it should be abused outside of the mm
proper. Why shouldn't this path wake the kswapd and let it compact
memory on the background to increase the success rate for the later
high order allocations?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
