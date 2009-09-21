Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 01FFC6B0161
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 09:37:02 -0400 (EDT)
Date: Mon, 21 Sep 2009 14:37:04 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: ipw2200: firmware DMA loading rework
Message-ID: <20090921133704.GO12726@csn.ul.ie>
References: <riPp5fx5ECC.A.2IG.qsGlKB@chimera> <200909211246.34774.bzolnier@gmail.com> <1253530608.5216.17.camel@penberg-laptop> <200909211512.14785.bzolnier@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <200909211512.14785.bzolnier@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Luis R. Rodriguez" <mcgrof@gmail.com>, Tso Ted <tytso@mit.edu>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Zhu Yi <yi.zhu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Mel Gorman <mel@skynet.ie>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, James Ketrenos <jketreno@linux.intel.com>, "Chatre, Reinette" <reinette.chatre@intel.com>, "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>, "ipw2100-devel@lists.sourceforge.net" <ipw2100-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 21, 2009 at 03:12:14PM +0200, Bartlomiej Zolnierkiewicz wrote:
> On Monday 21 September 2009 12:56:48 Pekka Enberg wrote:
> > On Mon, 2009-09-21 at 12:46 +0200, Bartlomiej Zolnierkiewicz wrote:
> > > > > I don't know why people don't see it but for me it has a memory management
> > > > > regression and reliability issue written all over it.
> > > > 
> > > > Possibly but drivers that reload their firmware as a response to an
> > > > error condition is relatively new and loading network drivers while the
> > > > system is already up and running a long time does not strike me as
> > > > typical system behaviour.
> > > 
> > > Loading drivers after boot is a typical desktop/laptop behavior, please
> > > think about hotplug (the hardware in question is an USB dongle).
> > 
> > Yeah, I wonder what broke things. Did the wireless stack change in
> > 2.6.31-rc1 too? IIRC Mel ruled out page allocator changes as a suspect.
> 
> The thing is that the mm behavior change has been narrowed down already
> over a month ago to -mm merge in 2.6.31-rc1 (as has been noted in my initial
> reports), I first though that that it was -next breakage but it turned out
> that it came the other way around (because -mm is not even pulled into -next
> currently -- great way to set an example for other kernel maintainers BTW).
> 

Is there a reliable reproduction case for this that narrowed it down to
2.6.31-rc1? That is the window where a number of page-allocator optimisation
patches made it in. None of them should have affected the allocator from a
fragmentation perspective though.

If you have a reliable reproduction case, testing between commits
d239171e4f6efd58d7e423853056b1b6a74f1446..a1dd268cf6306565a31a48deff8bf4f6b4b105f7
would be nice, particularly if it can be bisected within that small
window rather than a full bisect of an rc1 which I know can be a major
mess.

> I understand that behavior change may be justified and technically correct
> in itself.  I also completely agree that high order allocations in certain
> drivers need fixing anyway.
> 
> However there is something wrong with the big picture and the way changes
> are happening.  I'm not saying that I'm surprised though, especially given
> the recent decline in the quality assurance and the paradigm shift that
> I'm seeing (some influential top level people talking that -rc1 is fine for
> testing new code now or the "new kernel new hardware" thing).
> 

The quality assurance comment is a bit unfair with respect to the page
allocator. There are a lot of things that can have changed that would hose
order-6 atomic allocations. Furthermore, test cases used for mm patches
would not have taken into account such allocations as being critical. Even
if it was considered, it would have been dismissed as "it makes no sense
for drivers to be doing order-6 GFP_ATOMIC" allocations.

> Sorry but I have no more time currently to narrow down the issue some more
> (guess what, there are other kernel bugs standing in the way to bisect it
> and I would have to provide some reliable way to reproduce it first) so I
> see no more point in wasting people's time on this.  I can certainly get by
> with allocation failure here and there.  Not a big deal for me personally..
> 

That is somewhat unfortunate. Even testing within the window above if
possible would be very helpful if you get the chance.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
