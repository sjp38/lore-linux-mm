Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 004946B0055
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 16:29:34 -0400 (EDT)
Subject: Re: [PATCH] Hugepages should be accounted as unevictable pages.
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1245785335.24110.19.camel@alok-dev1>
References: <20090623093459.2204.A69D9226@jp.fujitsu.com>
	 <1245732411.18339.6.camel@alok-dev1>
	 <20090623135017.220D.A69D9226@jp.fujitsu.com>
	 <20090623141147.8f2cef18.kamezawa.hiroyu@jp.fujitsu.com>
	 <1245736441.18339.21.camel@alok-dev1>
	 <20090623150630.31c0dff5.kamezawa.hiroyu@jp.fujitsu.com>
	 <1245785335.24110.19.camel@alok-dev1>
Content-Type: text/plain
Date: Tue, 23 Jun 2009 16:30:23 -0400
Message-Id: <1245789023.6280.32.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akataria@vmware.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-06-23 at 12:28 -0700, Alok Kataria wrote:
> On Mon, 2009-06-22 at 23:06 -0700, KAMEZAWA Hiroyuki wrote:
> > On Mon, 22 Jun 2009 22:54:01 -0700
> > Alok Kataria <akataria@vmware.com> wrote:
> > 
> > > > > 
> > > > > I don't have any strong oppose reason, but I also don't have any strong
> > > > > agree reason.
> > > > > 
> > > > I think "don't include Hugepage" is sane. Hugepage is something _special_, now.
> > > > 
> > > Kamezawa-san, 
> > > 
> > > I agree that hugepages are special in the sense that they are
> > > implemented specially and don't actually reside on the LRU like any
> > > other locked memory. But, both of these memory types (mlocked and
> > > hugepages) are actually unevictable and can't be reclaimed back, so i
> > > don't see a reason why should accounting not reflect that.
> > > 
> > 
> > I bet we should rename "Unevictable" to "Mlocked" or "Pinned" rather than
> > take nr_hugepages into account. I think this "Unevictable" in meminfo means
> > - pages which are evictable in their nature (because in LRU) but a user pinned it -
> > 
> > How about rename "Unevictable" to "Pinned" or "Locked" ?
> > (Mlocked + locked shmem's + ramfs?)
> > 
> 
> As Lee also pointed out, i don't see why is this # of pages on
> unevictable_lru important for the user.
> IMO, it doesn't give any useful information, other than confusing us to
> believe that only these are unevictable.

Ah.  I meant to respond to Kame-san's mail this am, but got distracted.

Please note that "Unevictable" includes more than mlocked pages.  It
also includes SHM_LOCKED pages and ramfs pages.  So if one were to
rename it, I'd prefer "Pinned" to "Mlocked".

Also, it occurs to me that because of lazy culling of unevictable pages
of any type, the "Unevictable" stat does not necessarily correspond to
the actual number of unevictable pages of any order.  Some unevictable
pages will not be noticed until vmscan actually tries to reclaim them.
So, even discounting kernel/sl*b pages, and even with Alok's patch,
"Unevictable" may not show all unevictable memory.  Under memory
pressure, it should be close, tho', modulo kernel/sl*b pages.

> 
> Is there something else that I am missing here ?

Probably just a matter of preference.  As the code currently stands, a
user/admin would need to add <hugepage-size-in-KB> * nr_hugepages to the
"Unevictable" to get non-kernel unevictable memory.  With your patch, a
developer wanting to know the amount of memory on the unevictable LRU
[for whatever reason], would need to do the math.  Putting on my
"Fraternal Order of the Friends of Users" hat, I can see the benefit of
your approach.  But, still no strong feelings either way as long as the
meanings of the fields are documented somewhere and sufficient
information exists for the needs of users and developers.

> 
> > We have other "unevictable" pages other than Hugepage anyway.
> >  - page table
> >  - some slab
> >  - kernel's page
> >  - anon pages in swapless system
> >  etc...
> 
> I agree there are these other pages which are unevictable, but they are
> pages used by the kernel itself, and they will always be locked/utilized
> by the kernel. 
> The unevictable pages (hugepages and mlocked and others) on the other
> hand are pages which the user explicitly asked to be locked/pinned.
> 
> So i think, these other-evictable pages that you mentioned, are
> different in a way. 
> 
> > 
> > BTW, I use following calculation for quick check if I want all "Unevicatable" pages.
> > 
> > Unevictable = Total - (Active+Inactive) + (50-70%? of slab)
> > 
> > This # of is not-reclaimable memory.
> 
> I don't see how this would get the correct value either, mlocked or
> hugepages are not accounted by either of the Active or Inactive regions.
> 
> 
> Thanks,
> Alok
> 
> > 
> > Thanks,
> > -Kame
> > 
> > 
> > > Thanks,
> > > Alok
> > > 
> > > > Thanks,
> > > > -Kame
> > > > 
> > > 
> > > 
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
