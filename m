Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 8440A6B0164
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 06:54:57 -0400 (EDT)
Date: Fri, 22 Jun 2012 11:54:51 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 10/17] netvm: Allow skb allocation to use PFMEMALLOC
 reserves
Message-ID: <20120622105451.GC8271@suse.de>
References: <1340192652-31658-1-git-send-email-mgorman@suse.de>
 <1340192652-31658-11-git-send-email-mgorman@suse.de>
 <20120621163029.GB6045@breakpoint.cc>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120621163029.GB6045@breakpoint.cc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>

On Thu, Jun 21, 2012 at 06:30:29PM +0200, Sebastian Andrzej Siewior wrote:
> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > index 1d6ecc8..9a58dcc 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -167,14 +206,19 @@ static void skb_under_panic(struct sk_buff *skb, int sz, void *here)
> >   *	%GFP_ATOMIC.
> >   */
> >  struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
> > -			    int fclone, int node)
> > +			    int flags, int node)
> >  {
> >  	struct kmem_cache *cache;
> >  	struct skb_shared_info *shinfo;
> >  	struct sk_buff *skb;
> >  	u8 *data;
> > +	bool pfmemalloc;
> >  
> > -	cache = fclone ? skbuff_fclone_cache : skbuff_head_cache;
> > +	cache = (flags & SKB_ALLOC_FCLONE)
> > +		? skbuff_fclone_cache : skbuff_head_cache;
> > +
> > +	if (sk_memalloc_socks() && (flags & SKB_ALLOC_RX))
> > +		gfp_mask |= __GFP_MEMALLOC;
> >  
> >  	/* Get the HEAD */
> >  	skb = kmem_cache_alloc_node(cache, gfp_mask & ~__GFP_DMA, node);
> 
> This is mostly used by nic to refil their RX skb pool. You add the
> __GFP_MEMALLOC to the allocation to rise the change of a successfull refill
> for the swap case.
> A few drivers use build_skb() to create the skb. __netdev_alloc_skb()
> shouldn't be affected since the allocation happens with GFP_ATOMIC. Looking at
> TG3 it uses build_skb() and get_pages() / kmalloc(). Shouldn't this be some
> considered?
> 

While TG3 is not exactly as you describe after rebasing build_skb should
make a similar check to __alloc_skb. As it is always used for RX allocation
from the skbuff_head_cache cache the following should be suitable. Thanks.

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 9832001..063830c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -310,8 +310,12 @@ struct sk_buff *build_skb(void *data, unsigned int frag_size)
 	struct skb_shared_info *shinfo;
 	struct sk_buff *skb;
 	unsigned int size = frag_size ? : ksize(data);
+	gfp_t gfp_mask = GFP_ATOMIC;
 
-	skb = kmem_cache_alloc(skbuff_head_cache, GFP_ATOMIC);
+	if (sk_memalloc_socks())
+		gfp_mask |= __GFP_MEMALLOC;
+
+	skb = kmem_cache_alloc(skbuff_head_cache, gfp_mask);
 	if (!skb)
 		return NULL;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
