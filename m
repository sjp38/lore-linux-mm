Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 528216B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 09:46:16 -0400 (EDT)
Date: Tue, 13 Apr 2010 15:44:56 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100413134456.GQ5583@random.random>
References: <20100412071525.GR5683@laptop>
 <4BC2CF8C.5090108@redhat.com>
 <20100412082844.GU5683@laptop>
 <4BC2E1D6.9040702@redhat.com>
 <20100412092615.GY5683@laptop>
 <4BC2EFBA.5080404@redhat.com>
 <20100412203829.871f1dee.akpm@linux-foundation.org>
 <20100413161802.498336ca@notabene.brown>
 <20100413133153.GO5583@random.random>
 <20100413134035.GY25756@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100413134035.GY25756@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Neil Brown <neilb@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Avi Kivity <avi@redhat.com>, Nick Piggin <npiggin@suse.de>, Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael  S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 13, 2010 at 02:40:35PM +0100, Mel Gorman wrote:
> On Tue, Apr 13, 2010 at 03:31:54PM +0200, Andrea Arcangeli wrote:
> > Hi Neil!
> > 
> > On Tue, Apr 13, 2010 at 04:18:02PM +1000, Neil Brown wrote:
> > > Actually I don't think that would be hard at all.
> > > ->lookup can return a different dentry than the one passed in, usually using
> > > d_splice_alias to find it.
> > > So when you create an inode for a directory, create an anonymous dentry,
> > > attach it via i_dentry, and it should "just work".
> > > That is assuming this is still a "problem" that needs to be "fixed".
> > 
> > I'm not sure if changing the slab object will make a whole lot of
> > difference, because antifrag will threat all unmovable stuff the
> > same.
> 
> Anti-frag considers reclaimable slab caches to be different to unmovable
> allocations. Slabs with the SLAB_RECLAIM_ACCOUNT use the __GFP_RECLAIMABLE
> flag. It was to keep truly unmovable allocations in the same 2M pages where
> possible.

As long as we keep the reclaimable separated from the "movable" that's
fine.

> It also means that even with large bursts of kernel allocations due to big
> filesystem loads, the system will still get some of those 2M blocks back
> eventually when slab eventually ages and shrinks.

Only if the file isn't open... it's not really certain it's reclaimable.

> You can use /proc/pagetypeinfo to get a count of the 2M blocks of each
> type for different types of workloads to see what the scenarios look like
> from an anti-frag and compaction perspective but very loosly speaking,
> with compaction applied, you'd expect to be able to covert all "Movable"
> blocks to huge pages by either compacting or paging. You'll get some of the
> "Reclaimable" blocks if slab is shrunk enough the unmovable blocks depends
> on how many of the allocations are due to pagetables.

Awesome statistic!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
