Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 507666B009D
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 05:01:59 -0500 (EST)
Date: Wed, 14 Nov 2012 10:01:54 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [3.6 regression?] THP + migration/compaction livelock (I think)
Message-ID: <20121114100154.GI8218@suse.de>
References: <CALCETrVgbx-8Ex1Q6YgEYv-Oxjoa1oprpsQE-Ww6iuwf7jFeGg@mail.gmail.com>
 <alpine.DEB.2.00.1211131507370.17623@chino.kir.corp.google.com>
 <CALCETrU=7+pk_rMKKuzgW1gafWfv6v7eQtVw3p8JryaTkyVQYQ@mail.gmail.com>
 <alpine.DEB.2.00.1211131530020.17623@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1211131530020.17623@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Marc Duponcheel <marc@offline.be>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Nov 13, 2012 at 03:41:02PM -0800, David Rientjes wrote:
> On Tue, 13 Nov 2012, Andy Lutomirski wrote:
> 
> > It just happened again.
> > 
> > $ grep -E "compact_|thp_" /proc/vmstat
> > compact_blocks_moved 8332448774
> > compact_pages_moved 21831286
> > compact_pagemigrate_failed 211260
> > compact_stall 13484
> > compact_fail 6717
> > compact_success 6755
> > thp_fault_alloc 150665
> > thp_fault_fallback 4270
> > thp_collapse_alloc 19771
> > thp_collapse_alloc_failed 2188
> > thp_split 19600
> > 
> 
> Two of the patches from the list provided at
> http://marc.info/?l=linux-mm&m=135179005510688 are already in your 3.6.3 
> kernel:
> 
> 	mm: compaction: abort compaction loop if lock is contended or run too long
> 	mm: compaction: acquire the zone->lock as late as possible
> 
> and all have not made it to the 3.6 stable kernel yet, so would it be 
> possible to try with 3.7-rc5 to see if it fixes the issue?  If so, it will 
> indicate that the entire series is a candidate to backport to 3.6.

Thanks David once again.

The full list of compaction-related patches I believe are necessary for
this particular problem are

e64c5237cf6ff474cb2f3f832f48f2b441dd9979 mm: compaction: abort compaction loop if lock is contended or run too long
3cc668f4e30fbd97b3c0574d8cac7a83903c9bc7 mm: compaction: move fatal signal check out of compact_checklock_irqsave
661c4cb9b829110cb68c18ea05a56be39f75a4d2 mm: compaction: Update try_to_compact_pages()kerneldoc comment
2a1402aa044b55c2d30ab0ed9405693ef06fb07c mm: compaction: acquire the zone->lru_lock as late as possible
f40d1e42bb988d2a26e8e111ea4c4c7bac819b7e mm: compaction: acquire the zone->lock as late as possible
753341a4b85ff337487b9959c71c529f522004f4 revert "mm: have order > 0 compaction start off where it left"
bb13ffeb9f6bfeb301443994dfbf29f91117dfb3 mm: compaction: cache if a pageblock was scanned and no pages were isolated
c89511ab2f8fe2b47585e60da8af7fd213ec877e mm: compaction: Restart compaction from near where it left off
62997027ca5b3d4618198ed8b1aba40b61b1137b mm: compaction: clear PG_migrate_skip based on compaction and reclaim activity
0db63d7e25f96e2c6da925c002badf6f144ddf30 mm: compaction: correct the nr_strict va isolated check for CMA

If we can get confirmation that these fix the problem in 3.6 kernels then
I can backport them to -stable. This fixing a problem where "many processes
stall, all in an isolation-related function". This started happening after
lumpy reclaim was removed because we depended on that to aggressively
reclaim with less compaction. Now compaction is depended upon more.

The full 3.7-rc5 kernel has a different problem on top of this and it's
important the problems do not get conflacted. It has these fixes *but*
GFP_NO_KSWAPD has been removed and there is a patch that scales reclaim
with THP failures that is causing problem. With them, kswapd can get
stuck in a 100% loop where it is neither reclaiming nor reaching its exit
conditions. The correct fix would be to identify why this happens but I
have not got around to it yet. To test with 3.7-rc5 then apply either

1) https://lkml.org/lkml/2012/11/5/308
2) https://lkml.org/lkml/2012/11/12/113

or

1) https://lkml.org/lkml/2012/11/5/308
3) https://lkml.org/lkml/2012/11/12/151

on top of 3.7-rc5. So it's a lot of work but there are three tests I'm
interested in hearing about. The results of each determine what happens
in -stable or mainline

Test 1: 3.6 + the last of commits above	(should fix processes stick in isolate)
Test 2: 3.7-rc5 + (1+2) above (should fix kswapd stuck at 100%)
Test 3: 3.7-rc5 + (1+3) above (should fix kswapd stuck at 100% but better)

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
