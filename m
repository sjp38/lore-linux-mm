Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 25A9E9000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 06:53:43 -0400 (EDT)
Date: Tue, 26 Apr 2011 20:53:30 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 03/13] mm: Introduce __GFP_MEMALLOC to allow access to
 emergency reserves
Message-ID: <20110426205330.539a2766@notabene.brown>
In-Reply-To: <20110426103646.GD4658@suse.de>
References: <1303803414-5937-1-git-send-email-mgorman@suse.de>
	<1303803414-5937-4-git-send-email-mgorman@suse.de>
	<20110426194947.764e048a@notabene.brown>
	<20110426103646.GD4658@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Tue, 26 Apr 2011 11:36:46 +0100 Mel Gorman <mgorman@suse.de> wrote:

> On Tue, Apr 26, 2011 at 07:49:47PM +1000, NeilBrown wrote:

> > Maybe a
> >    WARN_ON((gfp_mask & __GFP_MEMALLOC) && (gfp_mask & __GFP_NOMEMALLOC));
> > might be wise?
> > 
> 
> Both MEMALLOC and NOMEMALLOC are related to PFMEMALLOC reserves so
> it's reasonable for them to have similar names. This warning will
> also trigger because it's a combination of flags that does happen.
> 
> Consider for example
> 
> any interrupt
>   -> __netdev_alloc_skb		(mask == GFP_ATOMIC)
>     -> __alloc_skb		(mask == GFP_ATOMIC)
>        if (sk_memalloc_socks() && (flags & SKB_ALLOC_RX))
>                gfp_mask |= __GFP_MEMALLOC;
> 				(mask == GFP_ATOMIC|__GFP_NOMEMALLOC)
>       -> __kmalloc_reserve
> 		First attempt tries to avoid reserves so adds __GFP_MEMALLOC
> 				(mask == GFP_ATOMIC|__GFP_NOMEMALLOC|__GFP_MEMALLOC)
> 

You have the "NO"s mixed up a bit which confused me for a while :-)
But I see your point - I guess the WARN_ON isn't really needed.


> You're right in that __GFP_NOMEMALLOC overrides __GFP_MEMALLOC so that
> could do with a note.
> 

Thanks,

NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
