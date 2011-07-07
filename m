Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 446839000C2
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 15:12:41 -0400 (EDT)
Date: Thu, 7 Jul 2011 14:12:37 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: reduce overhead of slub_debug
In-Reply-To: <1310064771.21902.55.camel@jaguar>
Message-ID: <alpine.DEB.2.00.1107071402490.24248@router.home>
References: <20110626193918.GA3339@joi.lan>  <alpine.DEB.2.00.1107072106560.6693@tiger>  <alpine.DEB.2.00.1107071314320.21719@router.home> <1310064771.21902.55.camel@jaguar>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Marcin Slusarz <marcin.slusarz@gmail.com>, Matt Mackall <mpm@selenic.com>, LKML <linux-kernel@vger.kernel.org>, rientjes@google.com, linux-mm@kvack.org

On Thu, 7 Jul 2011, Pekka Enberg wrote:

> On Thu, 7 Jul 2011, Pekka Enberg wrote:
> > > Looks good to me. Christoph, David, ?
>
> On Thu, 2011-07-07 at 13:17 -0500, Christoph Lameter wrote:
> > The reason debug code is there is because it is useless overhead typically
> > not needed. There is no point in optimizing the code that is not run in
> > production environments unless there are gross performance issues that
> > make debugging difficult. A performance patch for debugging would have to
> > cause significant performance improvements. This patch does not do that
> > nor was there such an issue to be addressed in the first place.
>
> Is there something technically wrong with the patch? Quoting the patch
> email:
>
>   (Compiling some project with different options)
>                                  make -j12    make clean
>   slub_debug disabled:             1m 27s       1.2 s
>   slub_debug enabled:              1m 46s       7.6 s
>   slub_debug enabled + this patch: 1m 33s       3.2 s
>
>   check_bytes still shows up high, but not always at the top.
>
> That's significant enough speedup for me!

Ok. I had a different set of numbers in mind from earlier posts.

The benefit here comes from accessing memory in larger (word) chunks
instead of byte wise. This is a form of memscan() with inverse matching.

Isnt there an asm optimized version that can do this much better (there is
one for memscan())? Optimizing this in core code by codeing something as
generic as that is not that good since the arch code can deliver better
performance and it seems that this is functionality that could be useful
elsewhere.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
