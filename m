Received: from edge05.upc.biz ([192.168.13.212]) by viefep19-int.chello.at
          (InterMail vM.7.08.02.02 201-2186-121-104-20070414) with ESMTP
          id <20080812072229.SDPQ16862.viefep19-int.chello.at@edge05.upc.biz>
          for <linux-mm@kvack.org>; Tue, 12 Aug 2008 09:22:29 +0200
Subject: Re: [PATCH 05/30] mm: slb: add knowledge of reserve pages
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <18593.8466.965002.476705@notabene.brown>
References: <20080724140042.408642539@chello.nl>
	 <20080724141529.635920366@chello.nl>
	 <18593.8466.965002.476705@notabene.brown>
Content-Type: text/plain
Date: Tue, 12 Aug 2008 09:22:30 +0200
Message-Id: <1218525750.10800.156.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Brown <neilb@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-08-12 at 15:35 +1000, Neil Brown wrote:
> On Thursday July 24, a.p.zijlstra@chello.nl wrote:
> > Restrict objects from reserve slabs (ALLOC_NO_WATERMARKS) to allocation
> > contexts that are entitled to it. This is done to ensure reserve pages don't
> > leak out and get consumed.
> 
> This looks good (we are still missing slob though, aren't we :-( )

I actually have that now, just needs some testing..

> > @@ -1526,7 +1540,7 @@ load_freelist:
> >  	object = c->page->freelist;
> >  	if (unlikely(!object))
> >  		goto another_slab;
> > -	if (unlikely(SLABDEBUG && PageSlubDebug(c->page)))
> > +	if (unlikely(PageSlubDebug(c->page) || c->reserve))
> >  		goto debug;
> 
> This looks suspiciously like debugging code that you have left in.
> Is it??

Its not, we need to force slub into the debug slow path when we have a
reserve page, otherwise we cannot do the permission check on each
allocation.

> > @@ -265,7 +267,8 @@ struct array_cache {
> >  	unsigned int avail;
> >  	unsigned int limit;
> >  	unsigned int batchcount;
> > -	unsigned int touched;
> > +	unsigned int touched:1,
> > +		     reserve:1;
> 
> This sort of thing always worries me.
> It is a per-cpu data structure so you won't get SMP races corrupting
> fields.  But you do get read-modify-write in place of simple updates.
> I guess it's not a problem..  But it worries me :-)

Right,.. do people prefer I just add another int?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
