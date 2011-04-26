Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id AA65690010D
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 19:22:14 -0400 (EDT)
Date: Wed, 27 Apr 2011 09:22:03 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 09/13] netvm: Set PF_MEMALLOC as appropriate during SKB
 processing
Message-ID: <20110427092203.659fbc25@notabene.brown>
In-Reply-To: <20110426141048.GG4658@suse.de>
References: <1303803414-5937-1-git-send-email-mgorman@suse.de>
	<1303803414-5937-10-git-send-email-mgorman@suse.de>
	<20110426222157.33a461f8@notabene.brown>
	<20110426141048.GG4658@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Tue, 26 Apr 2011 15:10:48 +0100 Mel Gorman <mgorman@suse.de> wrote:

> On Tue, Apr 26, 2011 at 10:21:57PM +1000, NeilBrown wrote:
> > On Tue, 26 Apr 2011 08:36:50 +0100 Mel Gorman <mgorman@suse.de> wrote:
> > 
> > > diff --git a/net/core/dev.c b/net/core/dev.c
> > > index 3871bf6..2d79a20 100644
> > > --- a/net/core/dev.c
> > > +++ b/net/core/dev.c
> > > @@ -3095,6 +3095,27 @@ static void vlan_on_bond_hook(struct sk_buff *skb)
> > >  	}
> > >  }
> > >  
> > > +/*
> > > + * Limit which protocols can use the PFMEMALLOC reserves to those that are
> > > + * expected to be used for communication with swap.
> > > + */
> > > +static bool skb_pfmemalloc_protocol(struct sk_buff *skb)
> > > +{
> > > +	if (skb_pfmemalloc(skb))
> > > +		switch (skb->protocol) {
> > > +		case __constant_htons(ETH_P_ARP):
> > > +		case __constant_htons(ETH_P_IP):
> > > +		case __constant_htons(ETH_P_IPV6):
> > > +		case __constant_htons(ETH_P_8021Q):
> > > +			break;
> > > +
> > > +		default:
> > > +			return false;
> > > +		}
> > > +
> > > +	return true;
> > > +}
> > 
> > This sort of thing really bugs me :-)
> > Neither the comment nor the function name actually describe what the function
> > is doing.  The function is checking *2* things.
> >    is_pfmemalloc_skb_or_pfmemalloc_protocol()
> > might be a more correct name, but is too verbose.
> > 
> > I would prefer the skb_pfmemalloc test were removed from here and ....
> > 
> > > +	if (!skb_pfmemalloc_protocol(skb))
> > > +		goto drop;
> > > +
> > 
> > ...added here so this becomes:
> > 
> >       if (!skb_pfmemalloc(skb) && !skb_pfmemalloc_protocol(skb))
> >                 goto drop;
> > 
> > which actually makes sense.
> > 
> 
> Moving the check is neater but that check should be
> 
> 	if (skb_pfmemalloc(skb) && !skb_pfmemalloc_protocol(skb))
> 
> ? It's only if the skb was allocated from emergency reserves that we
> need to consider dropping it to make way for other packets to be
> received.
> 

Correct.  I got my Boolean algebra all confused. Sorry 'bout that.

NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
