Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id B24396B002C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 17:31:24 -0500 (EST)
Date: Wed, 8 Feb 2012 16:13:15 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 02/15] mm: sl[au]b: Add knowledge of PFMEMALLOC reserve
 pages
In-Reply-To: <20120208212323.GM5938@suse.de>
Message-ID: <alpine.DEB.2.00.1202081557540.5970@router.home>
References: <1328568978-17553-1-git-send-email-mgorman@suse.de> <1328568978-17553-3-git-send-email-mgorman@suse.de> <alpine.DEB.2.00.1202071025050.30652@router.home> <20120208144506.GI5938@suse.de> <alpine.DEB.2.00.1202080907320.30248@router.home>
 <20120208163421.GL5938@suse.de> <alpine.DEB.2.00.1202081338210.32060@router.home> <20120208212323.GM5938@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, 8 Feb 2012, Mel Gorman wrote:

> On Wed, Feb 08, 2012 at 01:49:05PM -0600, Christoph Lameter wrote:
> > On Wed, 8 Feb 2012, Mel Gorman wrote:
> >
> > > Ok, I looked into what is necessary to replace these with checking a page
> > > flag and the cost shifts quite a bit and ends up being more expensive.
> >
> > That is only true if you go the slab route.
>
> Well, yes but both slab and slub have to be supported. I see no reason
> why I would choose to make this a slab-only or slub-only feature. Slob is
> not supported because it's not expected that a platform using slob is also
> going to use network-based swap.

I think so far the patches in particular to slab.c are pretty significant
in impact.

> > Slab suffers from not having
> > the page struct pointer readily available. The changes are likely already
> > impacting slab performance without the virt_to_page patch.
> >
>
> The performance impact only comes into play when swap is on a network
> device and pfmemalloc reserves are in use. The rest of the time the check
> on ac avoids all the cost and there is a micro-optimisation later to avoid
> calling a function (patch 12).

We have been down this road too many times. Logic is added to critical
paths and memory structures grow. This is not free. And for NBD swap
support? Pretty exotic use case.

> Ok, are you asking that I use the page flag for slub and leave kmem_cache_cpu
> alone in the slub case? I can certainly check it out if that's what you
> are asking for.

No I am not asking for something. Still thinking about the best way to
address the issues. I think we can easily come up with a minimally
invasive patch for slub. Not sure about slab at this point. I think we
could avoid most of the new fields but this requires some tinkering. I
have a day @ home tomorrow which hopefully gives me a chance to
put some focus on this issue.

> I did come up with a way: the necessary information is in ac and slabp
> on slab :/ . There are not exactly many ways that the information can
> be recorded.

Wish we had something that would not involve increasing the number of
fields in these slab structures.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
