Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id AA9256B0062
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 10:20:37 -0400 (EDT)
Date: Wed, 20 Jun 2012 15:20:33 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 07/17] net: Introduce sk_gfp_atomic() to allow addition
 of GFP flags depending on the individual socket
Message-ID: <20120620142033.GJ4011@suse.de>
References: <1340192652-31658-1-git-send-email-mgorman@suse.de>
 <1340192652-31658-8-git-send-email-mgorman@suse.de>
 <1340193999.4604.867.camel@edumazet-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1340193999.4604.867.camel@edumazet-glaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>

On Wed, Jun 20, 2012 at 02:06:39PM +0200, Eric Dumazet wrote:
> On Wed, 2012-06-20 at 12:44 +0100, Mel Gorman wrote:
> > Introduce sk_gfp_atomic(), this function allows to inject sock specific
> > flags to each sock related allocation. It is only used on allocation
> > paths that may be required for writing pages back to network storage.
> > 
> > [davem@davemloft.net: Use sk_gfp_atomic only when necessary]
> > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > Acked-by: David S. Miller <davem@davemloft.net>
> > ---
> >  include/net/sock.h    |    5 +++++
> >  net/ipv4/tcp_output.c |    9 +++++----
> >  net/ipv6/tcp_ipv6.c   |    8 +++++---
> >  3 files changed, 15 insertions(+), 7 deletions(-)
> > 
> 
> > diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> > index 803cbfe..440b47e 100644
> > --- a/net/ipv4/tcp_output.c
> > +++ b/net/ipv4/tcp_output.c
> > @@ -2461,7 +2461,8 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
> >  
> >  	if (cvp != NULL && cvp->s_data_constant && cvp->s_data_desired)
> >  		s_data_desired = cvp->s_data_desired;
> > -	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15 + s_data_desired, 1, GFP_ATOMIC);
> > +	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15 + s_data_desired, 1,
> > +			   sk_gfp_atomic(sk, GFP_ATOMIC));
> >  	if (skb == NULL)
> >  
> 
> This bit no longer applies on net-next, sock_wmalloc() was changed to a
> mere alloc_skb()
> 

Thanks, I'll rebase and retest.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
