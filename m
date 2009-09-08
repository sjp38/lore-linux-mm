Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E2CF96B007E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 07:00:41 -0400 (EDT)
Date: Tue, 8 Sep 2009 12:00:41 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: ipw2200: firmware DMA loading rework
Message-ID: <20090908110041.GE28127@csn.ul.ie>
References: <riPp5fx5ECC.A.2IG.qsGlKB@chimera> <1251430951.3704.181.camel@debian> <200908301437.42133.bzolnier@gmail.com> <200909021948.13262.bzolnier@gmail.com> <43e72e890909021102g7f844c79xefccf305f5f5c5b6@mail.gmail.com> <20090903124913.GA26110@csn.ul.ie> <20090905142837.GI16217@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090905142837.GI16217@mit.edu>
Sender: owner-linux-mm@kvack.org
To: Theodore Tso <tytso@mit.edu>, "Luis R. Rodriguez" <mcgrof@gmail.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Zhu Yi <yi.zhu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Pekka Enberg <penberg@cs.helsinki.fi>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Mel Gorman <mel@skynet.ie>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, James Ketrenos <jketreno@linux.intel.com>, "Chatre, Reinette" <reinette.chatre@intel.com>, "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>, "ipw2100-devel@lists.sourceforge.net" <ipw2100-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Sat, Sep 05, 2009 at 10:28:37AM -0400, Theodore Tso wrote:
> On Thu, Sep 03, 2009 at 01:49:14PM +0100, Mel Gorman wrote:
> > > 
> > > This looks very similar to the kmemleak ext4 reports upon a mount. If
> > > it is the same issue, which from the trace it seems it is, then this
> > > is due to an extra kmalloc() allocation and this apparently will not
> > > get fixed on 2.6.31 due to the closeness of the merge window and the
> > > non-criticalness this issue has been deemed.
> 
> No, it's a different problem.
> 
> > I suspect the more pressing concern is why is this kmalloc() resulting in
> > an order-5 allocation request? What size is the buffer being requested?
> > Was that expected?  What is the contents of /proc/slabinfo in case a buffer
> > that should have required order-1 or order-2 is using a higher order for
> > some reason.
> 
> It's allocating 68,000 bytes for the mb_history structure, which is
> used for debugging purposes.  That's why it's optional and we continue
> if it's not allocated.  We should fix it to use vmalloc()

You could call with kmalloc(FLAGS|GFP_NOWARN) with a fallback to
vmalloc() and a disable if vmalloc() fails as well.  Maybe check out what
kernel/profile.c#profile_init() to allocate a large buffer and do something
similar?

> and I'm
> inclined to turn it off by default since it's not worth the overhead,
> and most ext4 users won't find it useful or interesting.
> 

I can't comment as I don't know what sort of debugging it's useful for.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
