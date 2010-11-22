Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E66556B0071
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 18:07:48 -0500 (EST)
Date: Mon, 22 Nov 2010 15:06:42 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Pass priority to shrink_slab
Message-Id: <20101122150642.eec5f776.akpm@linux-foundation.org>
In-Reply-To: <AANLkTi=EnNqEDoWn6OiR04TaTBskNEZx4z8MOAYH8nK1@mail.gmail.com>
References: <1290054891-6097-1-git-send-email-yinghan@google.com>
	<20101118085921.GA11314@amd>
	<20101119142552.df0e351c.akpm@linux-foundation.org>
	<AANLkTi=EnNqEDoWn6OiR04TaTBskNEZx4z8MOAYH8nK1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@gmail.com>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, 19 Nov 2010 19:23:22 -0800
Ying Han <yinghan@google.com> wrote:

> On Fri, Nov 19, 2010 at 2:25 PM, Andrew Morton <akpm@linux-foundation.org>wrote:
> 
> > On Thu, 18 Nov 2010 19:59:21 +1100
> > Nick Piggin <npiggin@kernel.dk> wrote:
> >
> ...
> > To satisfy a GFP_KERNEL or GFP_USER allocation request, we need to free
> > up some of that lowmem.  But none of those inodes are reclaimable,
> > because of their attached highmem pagecache.  So in this case we very
> > much want to shoot down those inodes' pagecache within the icache
> > shrinker, so we can get those inodes reclaimed.
> >
> 
> 
> With the proposed change, that reclaim won't be happening until vmscan
> > has reached a higher priority.  Which means that the VM will instead go
> > nuts reclaiming *other* lowmem objects.  That means all the other slabs
> > which have shrinkers.  It also means lowmem pagecache: those inodes
> > will cause all your filesystem metadata to get evicted.  It also means
> > that anonymous memory which happened to land in lowmem will get swapped
> > out, and program text which is in lowmem will be unmapped and evicted.
> >
> Thanks Andrew for your comments. The example makes sense to me although it
> seems to
> little bit rare.

mmm, not really rare.  i386 boxes aren't exactly extinct, and
many-small-files workloads are pretty common.

The patch will change behaviour on 64-bit machines as well.  The kernel
will reclaim less pages via shrink_icache() and presumably more via the
LRU scans.  Hence pages will be reclaimed in different orders at least
(hopefully in *better* order).

And I suspect we'll end up changing the pagecache-vs-slab-object
weighting, in the direction of "the kernel reclaims pages more than it
used to, and slab objects less than it used to".

Also I suspect that more non-icache objects will be reclaimed via the
slab shrinkers.

Whether this change in behaviour on 64-bit is good, bad or undetectable
I do not know!

> On the page reclaim path, we always try the page lru first and then the
> shrink slab since the latter one
> has no guarantee of freeing page. If the lowmem has user pages on the lru
> which could be reclaimed,
> preserving the slabs might not be a bed idea? And if the page lru has hard
> time to reclaim those pages,
> it will raise up the priority and in turn will affect the shrinker after the
> change.

I don't know whether the change is a net improvement or a net
deterioration.  But it _is_ a change, and we should find out.

And the behavioural change on 64-bit machines should be understood and
assessed as well.

> > And yes, we need a struct shrinker_control so we can fiddle with the
> > argument passing without having to edit lots of files each time.
> >
> 
> Yes, and it would be much easier later to add a small feature (like this
> one) w/o
> touching so many files of the shrinkers. I am thinking if we can extend the
> scan_control
> from page reclaim and pass it down to the shrinker ?

Yes, that might work.  All callers of shrink_slab() already have a
scan_control on the stack, so passing all that extra info to the
shrinkers (along with some extra fields if needed) is pretty cheap, and
I don't see a great downside to exposing unneeded fields to the
shrinkers, given they're already on the stack somewhere.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
