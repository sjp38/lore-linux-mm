Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id BF2EC6B006E
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 11:42:24 -0500 (EST)
Date: Wed, 28 Nov 2012 16:42:18 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: kswapd craziness in 3.7
Message-ID: <20121128164217.GV8218@suse.de>
References: <1354049315-12874-1-git-send-email-hannes@cmpxchg.org>
 <CA+55aFywygqWUBNWtZYa+vk8G0cpURZbFdC7+tOzyWk6tLi=WA@mail.gmail.com>
 <50B52DC4.5000109@redhat.com>
 <20121127214928.GA20253@cmpxchg.org>
 <50B5387C.1030005@redhat.com>
 <20121127222637.GG2301@cmpxchg.org>
 <CA+55aFyrNRF8nWyozDPi4O1bdjzO189YAgMukyhTOZ9fwKqOpA@mail.gmail.com>
 <20121128101359.GT8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121128101359.GT8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, George Spelvin <linux@horizon.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, Tomas Racek <tracek@redhat.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Josh Boyer <jwboyer@gmail.com>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Jiri Slaby <jslaby@suse.cz>, Thorsten Leemhuis <fedora@leemhuis.info>, Zdenek Kabelac <zkabelac@redhat.com>, Bruno Wolff III <bruno@wolff.to>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Nov 28, 2012 at 10:13:59AM +0000, Mel Gorman wrote:
> On Tue, Nov 27, 2012 at 03:19:38PM -0800, Linus Torvalds wrote:
> > On Tue, Nov 27, 2012 at 2:26 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > > On Tue, Nov 27, 2012 at 05:02:36PM -0500, Rik van Riel wrote:
> > >>
> > >> Kswapd going crazy is certainly a large part of the problem.
> > >>
> > >> However, that leaves the issue of page_alloc.c waking up
> > >> kswapd when the system is not actually low on memory.
> > >>
> > >> Instead, kswapd is woken up because memory compaction failed,
> > >> potentially even due to lock contention during compaction!
> > >>
> > >> Ideally the allocation code would only wake up kswapd if
> > >> memory needs to be freed, or in order for kswapd to do
> > >> memory compaction (so the allocator does not have to).
> > >
> > > Maybe I missed something, but shouldn't this be solved with my patch?
> > 
> > Ok, guys. Cage fight!
> > 
> > The rules are simple: two men enter, one man leaves.
> > 
> 
> I'm fairly scorch damaged from this whole cycle already. I won't need a
> prop master to look the part for a thunderdome match.
> 
> > And the one who comes out gets to explain to me which patch(es) I
> > should apply, and which I should revert, if any.
> > 
> 
> Based on the reports I've seen I expect the following to work for 3.7
> 
> Keep
>   96710098 mm: revert "mm: vmscan: scale number of pages reclaimed by reclaim/compaction based on failures"
>   ef6c5be6 fix incorrect NR_FREE_PAGES accounting (appears like memory leak)
> 
> Revert
>   82b212f4 Revert "mm: remove __GFP_NO_KSWAPD"
> 
> Merge
>   mm: vmscan: fix kswapd endless loop on higher order allocation
>   mm: Avoid waking kswapd for THP allocations when compaction is deferred or contended
> 

and
    mm: compaction: Fix return value of capture_free_page

but this one may already be in flight from Andrew's tree as he picked it
up already.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
