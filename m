Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DAF196B004F
	for <linux-mm@kvack.org>; Wed, 21 Oct 2009 17:20:39 -0400 (EDT)
Received: by fxm20 with SMTP id 20so8088189fxm.38
        for <linux-mm@kvack.org>; Wed, 21 Oct 2009 14:20:37 -0700 (PDT)
Date: Wed, 21 Oct 2009 23:20:34 +0200
From: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Subject: Re: [PATCH] SLUB: Don't drop __GFP_NOFAIL completely from
	allocate_slab() (was: Re: [Bug #14265] ifconfig: page allocation
	failure. order:5,ode:0x8020 w/ e100)
Message-ID: <20091021212034.GB2987@bizet.domek.prywatny>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <COE24pZSBH.A.rP.2MTxKB@chimera> <20091021200442.GA2987@bizet.domek.prywatny> <alpine.DEB.2.00.0910211400140.20010@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0910211400140.20010@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Karol Lewandowski <karol.k.lewandowski@gmail.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>, Frans Pop <elendil@planet.nl>, Pekka Enberg <penberg@cs.helsinki.fi>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org, jens.axboe@oracle.com, Tobias Oetiker <tobi@oetiker.ch>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 21, 2009 at 02:06:41PM -0700, David Rientjes wrote:
> On Wed, 21 Oct 2009, Karol Lewandowski wrote:
> 
> > commit d6849591e042bceb66f1b4513a1df6740d2ad762
> > Author: Karol Lewandowski <karol.k.lewandowski@gmail.com>
> > Date:   Wed Oct 21 21:01:20 2009 +0200
> > 
> >     SLUB: Don't drop __GFP_NOFAIL completely from allocate_slab()
> >     
> >     Commit ba52270d18fb17ce2cf176b35419dab1e43fe4a3 unconditionally
> >     cleared __GFP_NOFAIL flag on all allocations.
> >     
> 
> No, it clears __GFP_NOFAIL from the first allocation of oo_order(s->oo).  
> If that fails (and it's easy to fail, it has __GFP_NORETRY), another 
> allocation is attempted with oo_order(s->min), for which __GFP_NOFAIL 
> would be preserved if that's the slab cache's allocflags.

Right, patch is junk.

However, I haven't been able to trigger failures since I've switched
to SLAB allocator.  That patch seemed related (and wrong), but it
wasn't.

> >  		 */
> > -		page = alloc_slab_page(flags, node, oo);
> > +		page = alloc_slab_page(flags | nofail, node, oo);
> >  		if (!page)
> >  			return NULL;
> >  
> > 
> 
> This does nothing.  You may have missed that the lower order allocation is 
> passing 'flags' (which is a union of the gfp flags passed to 
> allocate_slab() based on the allocation context and the cache's 
> allocflags), and not alloc_gfp where __GFP_NOFAIL is masked.

Right, I missed that.

> Nack.
> 
> Note: slub isn't going to be a culprit in order 5 allocation failures 
> since they have kmalloc passthrough to the page allocator.

However, it might change fragmentation somewhat I guess.  This might
make problem more/less visible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
