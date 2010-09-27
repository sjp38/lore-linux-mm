Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6BDF76B0047
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 14:49:41 -0400 (EDT)
Date: Mon, 27 Sep 2010 11:49:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: do not print backtraces on GFP_ATOMIC failures
Message-Id: <20100927114911.bc95ac87.akpm@linux-foundation.org>
In-Reply-To: <20100927110723.6B37.A69D9226@jp.fujitsu.com>
References: <20100921094638.9910add0.akpm@linux-foundation.org>
	<1285088427.2617.723.camel@edumazet-laptop>
	<20100927110723.6B37.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 27 Sep 2010 11:17:19 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > > > @@ -72,7 +72,7 @@ struct vm_area_struct;
> > > >  /* This equals 0, but use constants in case they ever change */
> > > >  #define GFP_NOWAIT	(GFP_ATOMIC & ~__GFP_HIGH)
> > > >  /* GFP_ATOMIC means both !wait (__GFP_WAIT not set) and use emergency pool */
> > > > -#define GFP_ATOMIC	(__GFP_HIGH)
> > > > +#define GFP_ATOMIC	(__GFP_HIGH | __GFP_NOWARN)
> > > >  #define GFP_NOIO	(__GFP_WAIT)
> > > >  #define GFP_NOFS	(__GFP_WAIT | __GFP_IO)
> > > >  #define GFP_KERNEL	(__GFP_WAIT | __GFP_IO | __GFP_FS)
> > > 
> > > A much finer-tuned implementation would be to add __GFP_NOWARN just to
> > > the networking call sites.  I asked about this in June and it got
> > > nixed:
> > > 
> > > http://www.spinics.net/lists/netdev/msg131965.html
> > > --
> > 
> > Yes, I remember this particular report was useful to find and correct a
> > bug.
> > 
> > I dont know what to say.
> > 
> > Being silent or verbose, it really depends on the context ?
> 
> At least, MM developers don't want to track network allocation failure
> issue. We don't have enough knowledge in this area. To be honest, We 
> are unhappy current bad S/N bug report rate ;)
> 
> Traditionally, We hoped this warnings help to debug VM issue.

Well, no, not really.  I thought that the main reason for having that
warning was to debug _callers_ of the memory allocator.

Firstly it tells us when callsites are being too optimistic: asking for
large amounts of contiguous pages, sometimes from atomic context. 
Quite a number of such callsites have been fixed as a result.

Secondly, memory allocation failures are a rare event, so the calling
code's error paths are not well tested.  This warning turns the bug
report "hey, my computer locked up" into the much better "hey, I got
this error message and then my computer locked up".  This allows us to
go and look at the offending code and see if it is handling ENOMEM
correctly.  However I don't recall this scenario ever having actually
happened.

> but
> It haven't happen. We haven't detect VM issue from this allocation
> failure report. Instead, We've received a lot of network allocation
> failure report.
> 
> Recently, The S/N ratio became more bad. If the network device enable
> jumbo frame feature, order-2 GFP_ATOMIC allocation is called frequently.
> Anybody don't have to assume order-2 allocation can success anytime.
> 
> I'm not against accurate warning at all. but I cant tolerate this
> semi-random warning steal our time. If anyone will not make accurate
> warning, I hope to remove this one completely instead.

We can disable the warning for only net drivers quite easily.  I don't
have any strong opinions, really - yes, we get quite a few such bug
reports but most of them end up in my lap anyway and it can't be more
than one per week, shrug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
