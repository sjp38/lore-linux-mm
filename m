Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5CFB46B005A
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 05:12:45 -0400 (EDT)
Date: Fri, 12 Jun 2009 11:13:04 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: slab: setup allocators earlier in the boot sequence
Message-ID: <20090612091304.GE24044@wotan.suse.de>
References: <1244783235.7172.61.camel@pasglop> <Pine.LNX.4.64.0906120913460.26843@melkki.cs.Helsinki.FI> <1244792079.7172.74.camel@pasglop> <1244792745.30512.13.camel@penberg-laptop> <20090612075427.GA24044@wotan.suse.de> <1244793592.30512.17.camel@penberg-laptop> <20090612080236.GB24044@wotan.suse.de> <1244793879.30512.19.camel@penberg-laptop> <1244796291.7172.87.camel@pasglop> <84144f020906120149k6cbe5177vef1944d9d216e8b2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f020906120149k6cbe5177vef1944d9d216e8b2@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, mingo@elte.hu, cl@linux-foundation.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 12, 2009 at 11:49:31AM +0300, Pekka Enberg wrote:
> On Fri, Jun 12, 2009 at 11:44 AM, Benjamin
> Herrenschmidt<benh@kernel.crashing.org> wrote:
> > On Fri, 2009-06-12 at 11:04 +0300, Pekka Enberg wrote:
> >> Hi Nick,
> >>
> >> On Fri, 2009-06-12 at 10:02 +0200, Nick Piggin wrote:
> >> > Fair enough, but this can be done right down in the synchronous
> >> > reclaim path in the page allocator. This will catch more cases
> >> > of code using the page allocator directly, and should be not
> >> > as hot as the slab allocator.
> >>
> >> So you want to push the local_irq_enable() to the page allocator too? We
> >> can certainly do that but I think we ought to wait for Andrew to merge
> >> Mel's patches to mainline first, OK?
> >
> > Doesn't my patch take care of all the cases in a much more simple way ?
> 
> Nick, the patch Ben is talking about is here:
> 
> http://patchwork.kernel.org/patch/29700/

It's OK. I'd make it gfp_notsmellybits, and avoid the ~.
And read_mostly.
 
> The biggest problem with the patch is that the gfp_smellybits is wide
> open for abuse. Hmm.

Probably would be better to hide it in mm/ and then just
allow it to be modified with a couple of calls. OTOH if
it is only modified in a couple of places then maybe that's
overkill.

The whole problem comes about because we don't just restore
our previously saved flags here... I guess it probably adds
even more overhead to do that and make everything just work :(


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
