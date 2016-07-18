Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id AEE076B0253
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 00:48:13 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ez1so204933205pab.0
        for <linux-mm@kvack.org>; Sun, 17 Jul 2016 21:48:13 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id p29si1297947pfj.147.2016.07.17.21.48.11
        for <linux-mm@kvack.org>;
        Sun, 17 Jul 2016 21:48:12 -0700 (PDT)
Date: Mon, 18 Jul 2016 13:52:18 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 04/31] mm, vmscan: begin reclaiming pages on a per-node
 basis
Message-ID: <20160718045218.GB9460@js1304-P5Q-DELUXE>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-5-git-send-email-mgorman@techsingularity.net>
 <20160707011211.GA27987@js1304-P5Q-DELUXE>
 <20160707094808.GP11498@techsingularity.net>
 <20160708022852.GA2370@js1304-P5Q-DELUXE>
 <20160708100532.GC11498@techsingularity.net>
 <20160714062836.GB29676@js1304-P5Q-DELUXE>
 <019f0906-e9b9-8fcb-cf92-f44a0293e150@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <019f0906-e9b9-8fcb-cf92-f44a0293e150@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 14, 2016 at 09:48:41AM +0200, Vlastimil Babka wrote:
> On 07/14/2016 08:28 AM, Joonsoo Kim wrote:
> >On Fri, Jul 08, 2016 at 11:05:32AM +0100, Mel Gorman wrote:
> >>On Fri, Jul 08, 2016 at 11:28:52AM +0900, Joonsoo Kim wrote:
> >>>On Thu, Jul 07, 2016 at 10:48:08AM +0100, Mel Gorman wrote:
> >>>>On Thu, Jul 07, 2016 at 10:12:12AM +0900, Joonsoo Kim wrote:
> >>>>>>@@ -1402,6 +1406,11 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> >>>>>>
> >>>>>> 		VM_BUG_ON_PAGE(!PageLRU(page), page);
> >>>>>>
> >>>>>>+		if (page_zonenum(page) > sc->reclaim_idx) {
> >>>>>>+			list_move(&page->lru, &pages_skipped);
> >>>>>>+			continue;
> >>>>>>+		}
> >>>>>>+
> >>>>>
> >>>>>I think that we don't need to skip LRU pages in active list. What we'd
> >>>>>like to do is just skipping actual reclaim since it doesn't make
> >>>>>freepage that we need. It's unrelated to skip the page in active list.
> >>>>>
> >>>>
> >>>>Why?
> >>>>
> >>>>The active aging is sometimes about simply aging the LRU list. Aging the
> >>>>active list based on the timing of when a zone-constrained allocation arrives
> >>>>potentially introduces the same zone-balancing problems we currently have
> >>>>and applying them to node-lru.
> >>>
> >>>Could you explain more? I don't understand why aging the active list
> >>>based on the timing of when a zone-constrained allocation arrives
> >>>introduces the zone-balancing problem again.
> >>>
> >>
> >>I mispoke. Avoid rotation of the active list based on the timing of a
> >>zone-constrained allocation is what I think potentially introduces problems.
> >>If there are zone-constrained allocations aging the active list then I worry
> >>that pages would be artificially preserved on the active list.  No matter
> >>what we do, there is distortion of the aging for zone-constrained allocation
> >>because right now, it may deactivate high zone pages sooner than expected.
> >>
> >>>I think that if above logic is applied to both the active/inactive
> >>>list, it could cause zone-balancing problem. LRU pages on lower zone
> >>>can be resident on memory with more chance.
> >>
> >>If anything, with node-based LRU, it's high zone pages that can be resident
> >>on memory for longer but only if there are zone-constrained allocations.
> >>If we always reclaim based on age regardless of allocation requirements
> >>then there is a risk that high zones are reclaimed far earlier than expected.
> >>
> >>Basically, whether we skip pages in the active list or not there are
> >>distortions with page aging and the impact is workload dependent. Right now,
> >>I see no clear advantage to special casing active aging.
> >>
> >>If we suspect this is a problem in the future, it would be a simple matter
> >>of adding an additional bool parameter to isolate_lru_pages.
> >
> >Okay. I agree that it would be a simple matter.
> >
> >>
> >>>>>And, I have a concern that if inactive LRU is full with higher zone's
> >>>>>LRU pages, reclaim with low reclaim_idx could be stuck.
> >>>>
> >>>>That is an outside possibility but unlikely given that it would require
> >>>>that all outstanding allocation requests are zone-contrained. If it happens
> >>>
> >>>I'm not sure that it is outside possibility. It can also happens if there
> >>>is zone-contrained allocation requestor and parallel memory hogger. In
> >>>this case, memory would be reclaimed by memory hogger but memory hogger would
> >>>consume them again so inactive LRU is continually full with higher
> >>>zone's LRU pages and zone-contrained allocation requestor cannot
> >>>progress.
> >>>
> >>
> >>The same memory hogger will also be reclaiming the highmem pages and
> >>reallocating highmem pages.
> >>
> >>>>It would be preferred to have an actual test case for this so the
> >>>>altered ratio can be tested instead of introducing code that may be
> >>>>useless or dead.
> >>>
> >>>Yes, actual test case would be preferred. I will try to implement
> >>>an artificial test case by myself but I'm not sure when I can do it.
> >>>
> >>
> >>That would be appreciated.
> >
> >I make an artificial test case and test this series by using next tree
> >(next-20160713) and found a regression.
> >
> 
> [...]
> 
> >Mem-Info:
> >active_anon:18779 inactive_anon:18 isolated_anon:0
> > active_file:91577 inactive_file:320615 isolated_file:0
> > unevictable:0 dirty:0 writeback:0 unstable:0
> > slab_reclaimable:6741 slab_unreclaimable:18124
> > mapped:389774 shmem:95 pagetables:18332 bounce:0
> > free:8194 free_pcp:140 free_cma:0
> >Node 0 active_anon:75116kB inactive_anon:72kB active_file:366308kB inactive_file:1282460kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:1559096kB dirty:0kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 380kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
> >Node 0 DMA free:2172kB min:204kB low:252kB high:300kB present:15992kB managed:15908kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:2380kB kernel_stack:1632kB pagetables:3632kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB node_pages_scanned:13673372
> >lowmem_reserve[]: 0 493 493 1955
> >Node 0 DMA32 free:6444kB min:6492kB low:8112kB high:9732kB present:2080632kB managed:508600kB mlocked:0kB slab_reclaimable:26964kB slab_unreclaimable:70116kB kernel_stack:30496kB pagetables:69696kB bounce:0kB free_pcp:316kB local_pcp:100kB free_cma:0kB node_pages_scanned:13673372
> >lowmem_reserve[]: 0 0 0 1462
> >Node 0 Normal free:0kB min:0kB low:0kB high:0kB present:18446744073708015752kB managed:0kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB node_pages_scanned:13673832
> 
> present:18446744073708015752kB
> 
> Although unlikely related to your report, that itself doesn't look
> right. Any idea if that's due to your configuration and would be
> printed also in the mainline kernel in case of OOM (or if
> /proc/zoneinfo has similarly bogus value), or is something caused by
> a patch in mmotm?

Wrong present count is due to a bug when enabling MOVABLE_ZONE.
v4.7-rc5 also has the same problems.

I testes above tests with work-around of this present count bug and
find that result is the same. v4.7-rc5 is okay but next-20160713 isn't okay.

As I said before, this setup just imitate highmem system and problem
would also exist on highmem system.

In addition, on above setup, I measured hackbench performance while
there is a concurrent file reader and found that hackbench slow down
roughly 10% with nodelru.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
