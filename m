Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2DE656B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 19:32:47 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so10919836pac.2
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 16:32:46 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 13si2781267pdb.141.2015.06.11.16.32.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 11 Jun 2015 16:32:46 -0700 (PDT)
Date: Thu, 11 Jun 2015 16:32:35 -0700
From: Shaohua Li <shli@fb.com>
Subject: Re: [RFC v2] net: use atomic allocation for order-3 page allocation
Message-ID: <20150611233235.GA667489@devbig257.prn2.facebook.com>
References: <71a20cf185c485fa23d9347bd846a6f4e9753405.1434053941.git.shli@fb.com>
 <1434063184.27504.60.camel@edumazet-glaptop2.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1434063184.27504.60.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, Kernel-team@fb.com, clm@fb.com, linux-mm@kvack.org, dbavatar@gmail.com, Eric Dumazet <edumazet@google.com>

On Thu, Jun 11, 2015 at 03:53:04PM -0700, Eric Dumazet wrote:
> On Thu, 2015-06-11 at 15:27 -0700, Shaohua Li wrote:
> > We saw excessive direct memory compaction triggered by skb_page_frag_refill.
> > This causes performance issues and add latency. Commit 5640f7685831e0
> > introduces the order-3 allocation. According to the changelog, the order-3
> > allocation isn't a must-have but to improve performance. But direct memory
> > compaction has high overhead. The benefit of order-3 allocation can't
> > compensate the overhead of direct memory compaction.
> > 
> > This patch makes the order-3 page allocation atomic. If there is no memory
> > pressure and memory isn't fragmented, the alloction will still success, so we
> > don't sacrifice the order-3 benefit here. If the atomic allocation fails,
> > direct memory compaction will not be triggered, skb_page_frag_refill will
> > fallback to order-0 immediately, hence the direct memory compaction overhead is
> > avoided. In the allocation failure case, kswapd is waken up and doing
> > compaction, so chances are allocation could success next time.
> > 
> > The mellanox driver does similar thing, if this is accepted, we must fix
> > the driver too.
> > 
> > V2: make the changelog clearer
> > 
> > Cc: Eric Dumazet <edumazet@google.com>
> > Signed-off-by: Shaohua Li <shli@fb.com>
> > ---
> >  net/core/sock.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/net/core/sock.c b/net/core/sock.c
> > index 292f422..e9855a4 100644
> > --- a/net/core/sock.c
> > +++ b/net/core/sock.c
> > @@ -1883,7 +1883,7 @@ bool skb_page_frag_refill(unsigned int sz, struct page_frag *pfrag, gfp_t gfp)
> >  
> >  	pfrag->offset = 0;
> >  	if (SKB_FRAG_PAGE_ORDER) {
> > -		pfrag->page = alloc_pages(gfp | __GFP_COMP |
> > +		pfrag->page = alloc_pages((gfp & ~__GFP_WAIT) | __GFP_COMP |
> >  					  __GFP_NOWARN | __GFP_NORETRY,
> >  					  SKB_FRAG_PAGE_ORDER);
> >  		if (likely(pfrag->page)) {
> 
> 
> OK, now what about alloc_skb_with_frags() ?
> 
> This should have same problem right ?

Ok, looks similar, added. Didn't trigger this one though.
