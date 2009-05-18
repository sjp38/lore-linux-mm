Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id F31896B004F
	for <linux-mm@kvack.org>; Mon, 18 May 2009 04:32:35 -0400 (EDT)
Date: Mon, 18 May 2009 16:32:46 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH 6/6] PM/Hibernate: Do not try to allocate too much
	memory too hard
Message-ID: <20090518083246.GA10033@localhost>
References: <200905070040.08561.rjw@sisk.pl> <200905171455.06120.rjw@sisk.pl> <20090517140712.GE3254@localhost> <200905171853.38028.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200905171853.38028.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: pm list <linux-pm@lists.linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>, Nigel Cunningham <nigel@tuxonice.net>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, May 18, 2009 at 12:53:37AM +0800, Rafael J. Wysocki wrote:
> On Sunday 17 May 2009, Wu Fengguang wrote:
> > On Sun, May 17, 2009 at 08:55:05PM +0800, Rafael J. Wysocki wrote:
> > > On Sunday 17 May 2009, Wu Fengguang wrote:
> > 
> > > > > +static unsigned long minimum_image_size(unsigned long saveable)
> > > > > +{
> > > > > +	unsigned long size;
> > > > > +
> > > > > +	/* Compute the number of saveable pages we can free. */
> > > > > +	size = global_page_state(NR_SLAB_RECLAIMABLE)
> > > > > +		+ global_page_state(NR_ACTIVE_ANON)
> > > > > +		+ global_page_state(NR_INACTIVE_ANON)
> > > > > +		+ global_page_state(NR_ACTIVE_FILE)
> > > > > +		+ global_page_state(NR_INACTIVE_FILE);
> > > > 
> > > > For example, we could drop the 1.25 ratio and calculate the above
> > > > reclaimable size with more meaningful constraints:
> > > > 
> > > >         /* slabs are not easy to reclaim */
> > > > 	size = global_page_state(NR_SLAB_RECLAIMABLE) / 2;
> > > 
> > > Why 1/2?
> > 
> > Also a very coarse value:
> > - we don't want to stress icache/dcache too much
> >   (unless they grow too large)
> > - my experience was that the icache/dcache are scanned in a slower
> >   pace than lru pages.
> 
> That doesn't really matter, we're talking about the minimum image size.

Have you dropped to goal to keep the minimal working set?

OK, even we only care about the success of page allocation,
NR_SLAB_RECLAIMABLE is not really all reclaimable, not even close.
In my desktop, 34MB pages are actually unreclaimable:

        echo 2 > /proc/sys/vm/drop_caches

        Slab:              69864 kB
        SReclaimable:      34052 kB

But on the other hand, updatedb can make it really huge:

        Slab:            1700852 kB
        SReclaimable:    1664456 kB

> > - most importantly, inside the NR_SLAB_RECLAIMABLE pages, maybe half
> >   of the pages are actually *in use* and cannot be freed:
> >         % cat /proc/sys/fs/inode-nr     
> >         30450   16605
> >         % cat /proc/sys/fs/dentry-state 
> >         41598   35731   45      0       0       0
> >   See? More than half entries are in-use. Sure many of them will actually
> >   become unused when dentries are freed, but in the mean time the internal
> >   fragmentations in the slabs can go up.
> > 
> > > >         /* keep NR_ACTIVE_ANON */
> > > > 	size += global_page_state(NR_INACTIVE_ANON);
> > > 
> > > Why exactly did you omit ACTIVE_ANON?
> > 
> > To keep the "core working set" :)
>
> > > >         /* keep mapped files */
> > > > 	size += global_page_state(NR_ACTIVE_FILE);
> > > > 	size += global_page_state(NR_INACTIVE_FILE);
> > > >         size -= global_page_state(NR_FILE_MAPPED);
> > > > 
> > > > That restores the hard core working set logic in the reverse way ;)
> > > 
> > > I think the 1/2 factor for NR_SLAB_RECLAIMABLE may be too high in some cases,
> > > but I'm going to check that.
> > 
> > Yes, after updatedb. In that case simple magics numbers may not help.
> > In that case we should really first call shrink_slab() in a loop to
> > cut down the slab pages to a sane number.
> 
> Unfortunately your formula above doesn't also work after running
> shrink_all_memory(<all saveable pages>), because the number given by it is
> still too high in that case.  The resulting minimum image size is then too low.

That means more items should be preserved, hehe.

> OTOH, the number computed in accordance with my original 1.25 * (<sum>) formula
> is fine in all cases I have checked (it actuall would be sufficient to take
> 1.2 * <sum>, but the difference is not really significant).
> 
> I don't think we can derive everything directly from the statistics collected
> by the mm subsystem.

I agree that the numbers only reflects a coarse outline of the lru cache
contents and can grow large in abnormal situations. We shall not be
too dependent on them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
