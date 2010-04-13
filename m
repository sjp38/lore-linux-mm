Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 85AE86B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 09:56:05 -0400 (EDT)
Date: Tue, 13 Apr 2010 14:55:43 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100413135543.GA25756@csn.ul.ie>
References: <4BC2CF8C.5090108@redhat.com> <20100412082844.GU5683@laptop> <4BC2E1D6.9040702@redhat.com> <20100412092615.GY5683@laptop> <4BC2EFBA.5080404@redhat.com> <20100412203829.871f1dee.akpm@linux-foundation.org> <20100413161802.498336ca@notabene.brown> <20100413133153.GO5583@random.random> <20100413134035.GY25756@csn.ul.ie> <20100413134456.GQ5583@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100413134456.GQ5583@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Neil Brown <neilb@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Avi Kivity <avi@redhat.com>, Nick Piggin <npiggin@suse.de>, Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael  S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 13, 2010 at 03:44:56PM +0200, Andrea Arcangeli wrote:
> On Tue, Apr 13, 2010 at 02:40:35PM +0100, Mel Gorman wrote:
> > On Tue, Apr 13, 2010 at 03:31:54PM +0200, Andrea Arcangeli wrote:
> > > Hi Neil!
> > > 
> > > On Tue, Apr 13, 2010 at 04:18:02PM +1000, Neil Brown wrote:
> > > > Actually I don't think that would be hard at all.
> > > > ->lookup can return a different dentry than the one passed in, usually using
> > > > d_splice_alias to find it.
> > > > So when you create an inode for a directory, create an anonymous dentry,
> > > > attach it via i_dentry, and it should "just work".
> > > > That is assuming this is still a "problem" that needs to be "fixed".
> > > 
> > > I'm not sure if changing the slab object will make a whole lot of
> > > difference, because antifrag will threat all unmovable stuff the
> > > same.
> > 
> > Anti-frag considers reclaimable slab caches to be different to unmovable
> > allocations. Slabs with the SLAB_RECLAIM_ACCOUNT use the __GFP_RECLAIMABLE
> > flag. It was to keep truly unmovable allocations in the same 2M pages where
> > possible.
> 
> As long as we keep the reclaimable separated from the "movable" that's
> fine.
> 

That already happens.

> > It also means that even with large bursts of kernel allocations due to big
> > filesystem loads, the system will still get some of those 2M blocks back
> > eventually when slab eventually ages and shrinks.
> 
> Only if the file isn't open... it's not really certain it's reclaimable.
> 

True. Christoph made a few stabs at being able to slab targetted reclaim
(called defragmentation, but it was about reclaim) but it was never completed
and merged. Even if it was merged, the slab reclaimable objects would
still be kept in their own 2M pageblocks though.

> > You can use /proc/pagetypeinfo to get a count of the 2M blocks of each
> > type for different types of workloads to see what the scenarios look like
> > from an anti-frag and compaction perspective but very loosly speaking,
> > with compaction applied, you'd expect to be able to covert all "Movable"
> > blocks to huge pages by either compacting or paging. You'll get some of the
> > "Reclaimable" blocks if slab is shrunk enough the unmovable blocks depends
> > on how many of the allocations are due to pagetables.
> 
> Awesome statistic!
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
