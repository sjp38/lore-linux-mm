Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CB2926B004A
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 09:23:33 -0400 (EDT)
Received: by pxi10 with SMTP id 10so2818888pxi.8
        for <linux-mm@kvack.org>; Mon, 06 Jun 2011 06:23:32 -0700 (PDT)
Date: Mon, 6 Jun 2011 22:23:21 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-ID: <20110606132321.GA1686@barrios-laptop>
References: <20110601214018.GC7306@suse.de>
 <20110601233036.GZ19505@random.random>
 <20110602010352.GD7306@suse.de>
 <20110602132954.GC19505@random.random>
 <20110602145019.GG7306@suse.de>
 <20110602153754.GF19505@random.random>
 <20110603020920.GA26753@suse.de>
 <20110603144941.GI7306@suse.de>
 <20110604065853.GA4114@barrios-laptop>
 <20110606104345.GE5247@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110606104345.GE5247@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>, akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org

On Mon, Jun 06, 2011 at 11:43:45AM +0100, Mel Gorman wrote:
> On Sat, Jun 04, 2011 at 03:58:53PM +0900, Minchan Kim wrote:
> > On Fri, Jun 03, 2011 at 03:49:41PM +0100, Mel Gorman wrote:
> > > On Fri, Jun 03, 2011 at 03:09:20AM +0100, Mel Gorman wrote:
> > > > On Thu, Jun 02, 2011 at 05:37:54PM +0200, Andrea Arcangeli wrote:
> > > > > > There is an explanation in here somewhere because as I write this,
> > > > > > the test machine has survived 14 hours under continual stress without
> > > > > > the isolated counters going negative with over 128 million pages
> > > > > > successfully migrated and a million pages failed to migrate due to
> > > > > > direct compaction being called 80,000 times. It's possible it's a
> > > > > > co-incidence but it's some co-incidence!
> > > > > 
> > > > > No idea...
> > > > 
> > > > I wasn't able to work on this most of the day but was looking at this
> > > > closer this evening again and I think I might have thought of another
> > > > theory that could cause this problem.
> > > > 
> > > > When THP is isolating pages, it accounts for the pages isolated against
> > > > the zone of course. If it backs out, it finds the pages from the PTEs.
> > > > On !SMP but PREEMPT, we may not have adequate protection against a new
> > > > page from a different zone being inserted into the PTE causing us to
> > > > decrement against the wrong zone. While the global counter is fine,
> > > > the per-zone counters look corrupted. You'd still think it was the
> > > > anon counter tht got screwed rather than the file one if it really was
> > > > THP unfortunately so it's not the full picture. I'm going to start
> > > > a test monitoring both zoneinfo and vmstat to see if vmstat looks
> > > > fine while the per-zone counters that are negative are offset by a
> > > > positive count on the other zones that when added together become 0.
> > > > Hopefully it'll actually trigger overnight :/
> > > > 
> > > 
> > > Right idea of the wrong zone being accounted for but wrong place. I
> > > think the following patch should fix the problem;
> > > 
> > > ==== CUT HERE ===
> > > mm: compaction: Ensure that the compaction free scanner does not move to the next zone
> > > 
> > > Compaction works with two scanners, a migration and a free
> > > scanner. When the scanners crossover, migration within the zone is
> > > complete. The location of the scanner is recorded on each cycle to
> > > avoid excesive scanning.
> > > 
> > > When a zone is small and mostly reserved, it's very easy for the
> > > migration scanner to be close to the end of the zone. Then the following
> > > situation can occurs
> > > 
> > >   o migration scanner isolates some pages near the end of the zone
> > >   o free scanner starts at the end of the zone but finds that the
> > >     migration scanner is already there
> > >   o free scanner gets reinitialised for the next cycle as
> > >     cc->migrate_pfn + pageblock_nr_pages
> > >     moving the free scanner into the next zone
> > >   o migration scanner moves into the next zone but continues accounting
> > >     against the old zone
> > > 
> > > When this happens, NR_ISOLATED accounting goes haywire because some
> > > of the accounting happens against the wrong zone. One zones counter
> > > remains positive while the other goes negative even though the overall
> > > global count is accurate. This was reported on X86-32 with !SMP because
> > > !SMP allows the negative counters to be visible. The fact that it is
> > > difficult to reproduce on X86-64 is probably just a co-incidence as
> > 
> > I guess it's related to zone sizes.
> > X86-64 has small DMA and large DMA32 zones for fallback of NORMAL while
> > x86 has just a small DMA(16M) zone.
> > 
> 
> Yep, this is a possibility as well as the use of lowmem reserves.
> 
> > I think DMA zone in x86 is easily full of non-LRU or non-movable pages.
> 
> Maybe not full, but it has more PageReserved pages than anywhere else

Yeb. It's very possible. 

> and few MIGRATE_MOVABLE blocks. MIGRATE_MOVABLE gets skipped during
				  non-MIGRATE_MOVABLE gets skipped during
To be clear for someone in future, let's fix typo.

> async compaction we could easily reach the end of the DMA zone quickly.

-- 
Kind regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
