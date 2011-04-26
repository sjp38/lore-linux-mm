Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 245399000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 07:33:52 -0400 (EDT)
Subject: Re: [PATCH 02/13] mm: sl[au]b: Add knowledge of PFMEMALLOC reserve
 pages
From: Mel Gorman <mgorman@suse.de>
In-Reply-To: <20110426211500.02d6a5a6@notabene.brown>
References: <1303803414-5937-1-git-send-email-mgorman@suse.de>
	 <1303803414-5937-3-git-send-email-mgorman@suse.de>
	 <20110426211500.02d6a5a6@notabene.brown>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Tue, 26 Apr 2011 12:33:48 +0100
Message-ID: <1303817628.5593.6.camel@machina.109elm.lan>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Tue, 2011-04-26 at 21:15 +1000, NeilBrown wrote:
> On Tue, 26 Apr 2011 08:36:43 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > +bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
> > +{
> > +	return gfp_to_alloc_flags(gfp_mask) & ALLOC_PFMEMALLOC;
> > +}
> > +
> >  static inline struct page *
> >  __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  	struct zonelist *zonelist, enum zone_type high_zoneidx,
> > @@ -2202,8 +2211,16 @@ nopage:
> >  got_pg:
> >  	if (kmemcheck_enabled)
> >  		kmemcheck_pagealloc_alloc(page, order, gfp_mask);
> > -	return page;
> >  
> > +	/*
> > +	 * page->pfmemalloc is set when the caller had PFMEMALLOC set or is
> > +	 * been OOM killed. The expectation is that the caller is taking
> > +	 * steps that will free more memory. The caller should avoid the
> > +	 * page being used for !PFMEMALLOC purposes.
> > +	 */
> > +	page->pfmemalloc = (alloc_flags & ALLOC_PFMEMALLOC);
> > +
> > +	return page;
> 
> Linus doesn't seem to be a fan of this construct:
>    https://lkml.org/lkml/2011/4/1/255
> 

There is confusion around this topic. Andrew prefers bool for true/false
values and it's self-documenting. I tend to prefer it myself for
readability and there is a slow conversion in the VM from
ints-used-as-bools to bools and my understanding of bool is that any
non-zero value will be treated as true (just as it is for int).

> pfmemalloc is a bool, and the value on the right is either 0 or 0x1000.
> 
> If bool happens to be typedefed to 'char' or even 'short', pfmemalloc would
> always be set to 0.

It is typedeffed as _Bool though which I thought was able to handle the
cast appropriately or is that wrong?

> Ditto for the gfp_pfmemalloc_allowed function.
> 
> Prefixing with '!!' would make it safe.
> 

Will do that to avoid any oddities. Thanks

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
