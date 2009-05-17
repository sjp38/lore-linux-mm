Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 79EA26B004D
	for <linux-mm@kvack.org>; Sun, 17 May 2009 13:22:39 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC][PATCH 6/6] PM/Hibernate: Do not try to allocate too much memory too hard
Date: Sun, 17 May 2009 18:53:37 +0200
References: <200905070040.08561.rjw@sisk.pl> <200905171455.06120.rjw@sisk.pl> <20090517140712.GE3254@localhost>
In-Reply-To: <20090517140712.GE3254@localhost>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200905171853.38028.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: pm list <linux-pm@lists.linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>, Nigel Cunningham <nigel@tuxonice.net>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sunday 17 May 2009, Wu Fengguang wrote:
> On Sun, May 17, 2009 at 08:55:05PM +0800, Rafael J. Wysocki wrote:
> > On Sunday 17 May 2009, Wu Fengguang wrote:
> 
> > > > +static unsigned long minimum_image_size(unsigned long saveable)
> > > > +{
> > > > +	unsigned long size;
> > > > +
> > > > +	/* Compute the number of saveable pages we can free. */
> > > > +	size = global_page_state(NR_SLAB_RECLAIMABLE)
> > > > +		+ global_page_state(NR_ACTIVE_ANON)
> > > > +		+ global_page_state(NR_INACTIVE_ANON)
> > > > +		+ global_page_state(NR_ACTIVE_FILE)
> > > > +		+ global_page_state(NR_INACTIVE_FILE);
> > > 
> > > For example, we could drop the 1.25 ratio and calculate the above
> > > reclaimable size with more meaningful constraints:
> > > 
> > >         /* slabs are not easy to reclaim */
> > > 	size = global_page_state(NR_SLAB_RECLAIMABLE) / 2;
> > 
> > Why 1/2?
> 
> Also a very coarse value:
> - we don't want to stress icache/dcache too much
>   (unless they grow too large)
> - my experience was that the icache/dcache are scanned in a slower
>   pace than lru pages.

That doesn't really matter, we're talking about the minimum image size.

> - most importantly, inside the NR_SLAB_RECLAIMABLE pages, maybe half
>   of the pages are actually *in use* and cannot be freed:
>         % cat /proc/sys/fs/inode-nr     
>         30450   16605
>         % cat /proc/sys/fs/dentry-state 
>         41598   35731   45      0       0       0
>   See? More than half entries are in-use. Sure many of them will actually
>   become unused when dentries are freed, but in the mean time the internal
>   fragmentations in the slabs can go up.
> 
> > >         /* keep NR_ACTIVE_ANON */
> > > 	size += global_page_state(NR_INACTIVE_ANON);
> > 
> > Why exactly did you omit ACTIVE_ANON?
> 
> To keep the "core working set" :)
>   	
> > >         /* keep mapped files */
> > > 	size += global_page_state(NR_ACTIVE_FILE);
> > > 	size += global_page_state(NR_INACTIVE_FILE);
> > >         size -= global_page_state(NR_FILE_MAPPED);
> > > 
> > > That restores the hard core working set logic in the reverse way ;)
> > 
> > I think the 1/2 factor for NR_SLAB_RECLAIMABLE may be too high in some cases,
> > but I'm going to check that.
> 
> Yes, after updatedb. In that case simple magics numbers may not help.
> In that case we should really first call shrink_slab() in a loop to
> cut down the slab pages to a sane number.

Unfortunately your formula above doesn't also work after running
shrink_all_memory(<all saveable pages>), because the number given by it is
still too high in that case.  The resulting minimum image size is then too low.

OTOH, the number computed in accordance with my original 1.25 * (<sum>) formula
is fine in all cases I have checked (it actuall would be sufficient to take
1.2 * <sum>, but the difference is not really significant).

I don't think we can derive everything directly from the statistics collected
by the mm subsystem.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
