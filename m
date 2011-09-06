Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 338D46B00EE
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 11:52:07 -0400 (EDT)
Received: by gyf1 with SMTP id 1so3079996gyf.14
        for <linux-mm@kvack.org>; Tue, 06 Sep 2011 08:52:04 -0700 (PDT)
Date: Wed, 7 Sep 2011 00:51:41 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] vmscan: Do reclaim stall in case of mlocked page.
Message-ID: <20110906155141.GB1589@barrios-fedora.local>
References: <1321285043-3470-1-git-send-email-minchan.kim@gmail.com>
 <20110831173031.GA21571@redhat.com>
 <CAEwNFnDcNqLvo=oyXXkxgFxs8wNc+WTLwot0qeru1VfQKmUYDQ@mail.gmail.com>
 <20110905083321.GA15935@redhat.com>
 <20110906151140.GA1589@barrios-fedora.local>
 <20110906153903.GU14369@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110906153903.GU14369@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <jweiner@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Tue, Sep 06, 2011 at 04:39:03PM +0100, Mel Gorman wrote:
> On Wed, Sep 07, 2011 at 12:11:40AM +0900, Minchan Kim wrote:
> > > > <SNIP>
> > > > If we consider that, we have to fix other reset_reclaim_mode cases as
> > > > well as mlocked pages.
> > > > Or
> > > > fix isolataion logic for the lumpy? (When we find the page isn't able
> > > > to isolate, rollback the pages in the lumpy block to the LRU)
> > > > Or
> > > > Nothing and wait to remove lumpy completely.
> > > > 
> > > > What do you think about it?
> > > 
> > > The rollback may be overkill and we already abort clustering the
> > > isolation when one of the pages fails.
> > 
> > I think abort isn't enough
> > Because we know the chace to make a bigger page is gone when we isolate page.
> > But we still try to reclaim pages to make bigger space in a vain.
> > It causes unnecessary unmap operation by try_to_unmap which is costly operation
> > , evict some working set pages and make reclaim latency long.
> > 
> > As a matter of fact, I though as follows patch to solve this problem(Totally, untested)
> > 
> 
> I confess I haven't read this patch carefully or given it much
> thought. I agree with you in principal that it would be preferred if
> lumpy reclaim disrupted the LRU lists as little as possible but I'm
> wary about making lumpy reclaim more complex when it is preferred that
> compaction is used and we expect lumpy reclaim to go away eventually.

Agreed.
But I think the concept of the patch could be applied to compaction for high order pages.
If we know some block has a pinned page when we do compaction for high order pages,
migration of the pages isolated in the block is pointless.

> 
> > > <SNIP{>
> > > 
> > > I would go with the last option.  Lumpy reclaim is on its way out and
> > > already disabled for a rather common configuration, so I would defer
> > > non-obvious fixes like these until actual bug reports show up.
> > 
> > It's hard to report above problem as it might not make big difference on normal worklaod.
> 
> I doubt it makes a noticable difference as lumpy reclaim disrupts
> the system quite heavily.

Yes. I don't know such workload but I think it apparently could make relcaim latency
long with be not able to make bigger page.

> 
> > But I agree last option, too. Then, when does we suppose to remove lumpy?
> > Mel, Could you have a any plan?
> > 
> 
> I think it should be removed after all the major distributions release
> with a kernel with compaction enabled. At that point,  we'll know
> that lumpy reclaim is not being depended upon.

It does make sense.

> 
> -- 
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
