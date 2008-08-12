Received: from edge04.upc.biz ([192.168.13.239]) by viefep17-int.chello.at
          (InterMail vM.7.08.02.00 201-2186-121-20061213) with ESMTP
          id <20080812073307.DZIL16026.viefep17-int.chello.at@edge04.upc.biz>
          for <linux-mm@kvack.org>; Tue, 12 Aug 2008 09:33:07 +0200
Subject: Re: [PATCH 02/30] mm: gfp_to_alloc_flags()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <18593.6448.132048.150818@notabene.brown>
References: <20080724140042.408642539@chello.nl>
	 <20080724141529.408041430@chello.nl>
	 <18593.6448.132048.150818@notabene.brown>
Content-Type: text/plain
Date: Tue, 12 Aug 2008 09:33:05 +0200
Message-Id: <1218526385.10800.165.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Brown <neilb@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-08-12 at 15:01 +1000, Neil Brown wrote:
> On Thursday July 24, a.p.zijlstra@chello.nl wrote:
> > Factor out the gfp to alloc_flags mapping so it can be used in other places.
> > 
> > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > ---
> >  mm/internal.h   |   10 +++++
> >  mm/page_alloc.c |   95 +++++++++++++++++++++++++++++++-------------------------
> >  2 files changed, 64 insertions(+), 41 deletions(-)
> 
> This patch all looks "obviously correct" and a nice factorisation of
> code, except the last little bit:
> 
> > @@ -1618,6 +1627,10 @@ nofail_alloc:
> >  	if (!wait)
> >  		goto nopage;
> >  
> > +	/* Avoid recursion of direct reclaim */
> > +	if (p->flags & PF_MEMALLOC)
> > +		goto nopage;
> > +
> >  	cond_resched();
> >  
> >  	/* We now go into synchronous reclaim */
> > 
> > -- 
> 
> I don't remember seeing it before (though my memory is imperfect) and
> it doesn't seem to fit with the rest of the patch (except spatially).
> 
> There is a test above for PF_MEMALLOC which will result in a "goto"
> somewhere else unless "in_interrupt()".
> There is immediately above a test for "!wait".
> So the only way this test can fire is when in_interrupt and wait.
> But if that happens, then the
> 	might_sleep_if(wait)
> at the top should have thrown a warning...  It really shouldn't happen.
> 
> So it looks like it is useless code:  there is already protection
> against recursion in this case.
> 
> Did I miss something?
> If I did, maybe more text in the changelog entry (or the comment)
> would help.

Ok, so the old code did:

  if (((p->flags & PF_MEMALLOC) || ...) && !in_interrupt) {
    ....
    goto nopage;
  }

which avoid anything that has PF_MEMALLOC set from entering into direct
reclaim, right?

Now, the new code reads:

  if (alloc_flags & ALLOC_NO_WATERMARK) {
  }

Which might be false, even though we have PF_MEMALLOC set -
__GFP_NOMEMALLOC comes to mind.

So we have to stop that recursion from happening.

so we add:

  if (p->flags & PF_MEMALLOC)
    goto nopage;

Now, if it were done before the !wait check, we'd have to consider
atomic contexts, but as those are - as you rightly pointed out - handled
by the !wait case, we can plainly do this check.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
