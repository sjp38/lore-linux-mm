Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CB8616B005A
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 05:29:53 -0400 (EDT)
Date: Fri, 12 Jun 2009 11:30:46 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: slab: setup allocators earlier in the boot sequence
Message-ID: <20090612093046.GG24044@wotan.suse.de>
References: <1244792079.7172.74.camel@pasglop> <1244792745.30512.13.camel@penberg-laptop> <20090612075427.GA24044@wotan.suse.de> <1244793592.30512.17.camel@penberg-laptop> <20090612080236.GB24044@wotan.suse.de> <1244793879.30512.19.camel@penberg-laptop> <1244796291.7172.87.camel@pasglop> <84144f020906120149k6cbe5177vef1944d9d216e8b2@mail.gmail.com> <20090612091304.GE24044@wotan.suse.de> <1244798660.7172.102.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1244798660.7172.102.camel@pasglop>
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, mingo@elte.hu, cl@linux-foundation.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 12, 2009 at 07:24:20PM +1000, Benjamin Herrenschmidt wrote:
> 
> > It's OK. I'd make it gfp_notsmellybits, and avoid the ~.
> > And read_mostly.
> 
> read_mostly is fine. gfp_notsmellybits isn't a nice name :-) Make it
> gfp_allowedbits then. I did it backward on purpose though as the risk of
> "missing" bits here (as we may add new ones) is higher and it seemed to
> me generally simpler to just explicit spell out the ones to forbid
> (also, on powerpc,  &~ is one instruction :-)

But just do the ~ in the assignment. No missing bits :)

  
> > Probably would be better to hide it in mm/ and then just
> > allow it to be modified with a couple of calls. OTOH if
> > it is only modified in a couple of places then maybe that's
> > overkill.
> 
> It might indeed be nicer to hide it behind an accessor.
> 
> > The whole problem comes about because we don't just restore
> > our previously saved flags here... I guess it probably adds
> > even more overhead to do that and make everything just work :(
> 
> Well... that's part of the equation. My solution has the advantage to
> also providing ground to forbid GFP_IO during suspend/resume etc...

Yeah but it doesn't do it in the page allocator so it isn't
really useful as a general allocator flags tweak. ATM it only
helps this case of slab allocator hackery.

In my slab allocator I'm going to actually look at what it
costs to keep track of flags properly. That would be far cleaner...
OTOH, SLUB is apparently much more sensitive about page allocator
performance so maybe the hack is worthwhile there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
