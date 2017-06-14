Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 416B76B02FA
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 02:40:48 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id b13so97636279pgn.4
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 23:40:48 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id s9si12752pgd.34.2017.06.13.23.40.46
        for <linux-mm@kvack.org>;
        Tue, 13 Jun 2017 23:40:47 -0700 (PDT)
Date: Wed, 14 Jun 2017 15:40:45 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2] mm: use slab size in the slab shrinking ratio
 calculation
Message-ID: <20170614064045.GA19843@bbox>
References: <1496949546-2223-1-git-send-email-jbacik@fb.com>
 <20170613052802.GA16061@bbox>
 <20170613120156.GA16003@destiny>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170613120156.GA16003@destiny>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, kernel-team@fb.com, Josef Bacik <jbacik@fb.com>

On Tue, Jun 13, 2017 at 08:01:57AM -0400, Josef Bacik wrote:
> On Tue, Jun 13, 2017 at 02:28:02PM +0900, Minchan Kim wrote:
> > Hello,
> > 
> > On Thu, Jun 08, 2017 at 03:19:05PM -0400, josef@toxicpanda.com wrote:
> > > From: Josef Bacik <jbacik@fb.com>
> > > 
> > > When testing a slab heavy workload I noticed that we often would barely
> > > reclaim anything at all from slab when kswapd started doing reclaim.
> > > This is because we use the ratio of nr_scanned / nr_lru to determine how
> > > much of slab we should reclaim.  But in a slab only/mostly workload we
> > > will not have much page cache to reclaim, and thus our ratio will be
> > > really low and not at all related to where the memory on the system is.
> > 
> > I want to understand this clearly.
> > Why nr_scanned / nr_lru is low if system doesnt' have much page cache?
> > Could you elaborate it a bit?
> > 
> 
> Yeah so for example on my freshly booted test box I have this
> 
> Active:            58840 kB
> Inactive:          46860 kB
> 
> Every time we do a get_scan_count() we do this
> 
> scan = size >> sc->priority
> 
> where sc->priority starts at DEF_PRIORITY, which is 12.  The first loop through
> reclaim would result in a scan target of 2 pages to 11715 total inactive pages,
> and 3 pages to 14710 total active pages.  This is a really really small target
> for a system that is entirely slab pages.  And this is super optimistic, this
> assumes we even get to scan these pages.  We don't increment sc->nr_scanned
> unless we 1) isolate the page, which assumes it's not in use, and 2) can lock
> the page.  Under pressure these numbers could probably go down, I'm sure there's
> some random pages from daemons that aren't actually in use, so the targets get
> even smaller.
> 
> We have to get sc->priority down a lot before we start to get to the 1:1 ratio
> that would even start to be useful for reclaim in this scenario.  Add to this
> that most shrinkable slabs have this idea that their objects have to loop
> through the LRU twice (no longer icache/dcache as Al took my patch to fix that
> thankfully) and you end up spending a lot of time looping and reclaiming
> nothing.  Basing it on actual slab usage makes more sense logically and avoids
> this kind of problem.  Thanks,

Thanks. I got understood now.

As I see your change, it seems to be rather aggressive to me.

        node_slab = lruvec_page_state(lruvec, NR_SLAB_RECLAIMABLE);
        shrink_slab(,,, node_slab >> sc->priority, node_slab);

The point is when we finish reclaiming from direct/background(ie, kswapd),
it makes sure that VM scanned slab object up to twice of the size which
is consistent with LRU pages.

What do you think about this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
