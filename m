Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 7C1706B0033
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 02:23:44 -0400 (EDT)
Date: Thu, 22 Aug 2013 15:24:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [resend] [PATCH V3] mm: vmscan: fix do_try_to_free_pages()
 livelock
Message-ID: <20130822062417.GF4665@bbox>
References: <89813612683626448B837EE5A0B6A7CB3B630BE80B@SC-VEXCH4.marvell.com>
 <20130805074146.GD10146@dhcp22.suse.cz>
 <89813612683626448B837EE5A0B6A7CB3B630BED6B@SC-VEXCH4.marvell.com>
 <20130806103543.GA31138@dhcp22.suse.cz>
 <89813612683626448B837EE5A0B6A7CB3B63175BCA@SC-VEXCH4.marvell.com>
 <20130808181426.GI715@cmpxchg.org>
 <89813612683626448B837EE5A0B6A7CB3B631767D7@SC-VEXCH4.marvell.com>
 <20130820151630.2a61ae9d88ea34a69e9d04bf@linux-foundation.org>
 <89813612683626448B837EE5A0B6A7CB3B6333D4CF@SC-VEXCH4.marvell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <89813612683626448B837EE5A0B6A7CB3B6333D4CF@SC-VEXCH4.marvell.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lisa Du <cldu@marvell.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Bob Liu <lliubbo@gmail.com>, Neil Zhang <zhangwm@marvell.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Aaditya Kumar <aaditya.kumar.30@gmail.com>, "yinghan@google.com" <yinghan@google.com>, "npiggin@gmail.com" <npiggin@gmail.com>, "riel@redhat.com" <riel@redhat.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "chunlingdu1@gmail.com" <chunlingdu1@gmail.com>

Hello Lisa,

Please fix your mail client.

On Wed, Aug 21, 2013 at 10:24:07PM -0700, Lisa Du wrote:
> >-----Original Message-----
> >From: Andrew Morton [mailto:akpm@linux-foundation.org]
> >Sent: 2013a1'8ae??21ae?JPY 6:17
> >To: Lisa Du
> >Cc: Johannes Weiner; Michal Hocko; linux-mm@kvack.org; Minchan Kim; KOSAKI Motohiro; Mel Gorman; Christoph Lameter; Bob Liu;
> >Neil Zhang; Russell King - ARM Linux; Aaditya Kumar; yinghan@google.com; npiggin@gmail.com; riel@redhat.com;
> >kamezawa.hiroyu@jp.fujitsu.com
> >Subject: Re: [resend] [PATCH V3] mm: vmscan: fix do_try_to_free_pages() livelock
> >
> >On Sun, 11 Aug 2013 18:46:08 -0700 Lisa Du <cldu@marvell.com> wrote:
> >
> >> In this version:
> >> Reorder the check in pgdat_balanced according Johannes's comment.
> >>
> >> >From 66a98566792b954e187dca251fbe3819aeb977b9 Mon Sep 17 00:00:00
> >> >2001
> >> From: Lisa Du <cldu@marvell.com>
> >> Date: Mon, 5 Aug 2013 09:26:57 +0800
> >> Subject: [PATCH] mm: vmscan: fix do_try_to_free_pages() livelock
> >>
> >> This patch is based on KOSAKI's work and I add a little more
> >> description, please refer https://lkml.org/lkml/2012/6/14/74.
> >>
> >> Currently, I found system can enter a state that there are lots of
> >> free pages in a zone but only order-0 and order-1 pages which means
> >> the zone is heavily fragmented, then high order allocation could make
> >> direct reclaim path's long stall(ex, 60 seconds) especially in no swap
> >> and no compaciton enviroment. This problem happened on v3.4, but it
> >> seems issue still lives in current tree, the reason is
> >> do_try_to_free_pages enter live lock:
> >>
> >> kswapd will go to sleep if the zones have been fully scanned and are
> >> still not balanced. As kswapd thinks there's little point trying all
> >> over again to avoid infinite loop. Instead it changes order from
> >> high-order to 0-order because kswapd think order-0 is the most
> >> important. Look at 73ce02e9 in detail. If watermarks are ok, kswapd
> >> will go back to sleep and may leave zone->all_unreclaimable = 0.
> >> It assume high-order users can still perform direct reclaim if they wish.
> >>
> >> Direct reclaim continue to reclaim for a high order which is not a
> >> COSTLY_ORDER without oom-killer until kswapd turn on zone->all_unreclaimble.
> >> This is because to avoid too early oom-kill. So it means
> >> direct_reclaim depends on kswapd to break this loop.
> >>
> >> In worst case, direct-reclaim may continue to page reclaim forever
> >> when kswapd sleeps forever until someone like watchdog detect and
> >> finally kill the process. As described in:
> >> http://thread.gmane.org/gmane.linux.kernel.mm/103737
> >>
> >> We can't turn on zone->all_unreclaimable from direct reclaim path
> >> because direct reclaim path don't take any lock and this way is racy.
> >
> >I don't see that this is correct.  Page reclaim does racy things quite often, in the knowledge that the effects of a race are
> >recoverable and small.
> Maybe Kosaki can give some comments, I think the mainly reason maybe direct reclaim don't take any lock.

You have to write the problem out in detail.
It doesn't related to lock and race.
The problem is kswapd could sleep in highly-fragemented case
if it was woke up by high-order alloc because kswapd don't want
to reclaim too many pages by high-order allocation so it just
check order-0 pages once it try to reclaim for high order
allocation.

         * Fragmentation may mean that the system cannot be rebalanced
         * for high-order allocations in all zones. If twice the
         * allocation size has been reclaimed and the zones are still
         * not balanced then recheck the watermarks at order-0 to
         * prevent kswapd reclaiming excessively. Assume that a
         * process requested a high-order can direct reclaim/compact.
         */
        if (order && sc.nr_reclaimed >= 2UL << order)
                order = sc.order = 0;

But direct reclaim cannot meet kswapd's expectation because
although it has lots of free pages, it couldn't reclaim at all
because it has no swap device but lots of anon pages so it
should stop scanning and kill someone and it depends on the logic

	/* top priority shrink_zones still had more to do? don't OOM, then */
	if (global_reclaim(sc) && !all_unreclaimable(zonelist, sc))
		return 1;

In addtion that, all_unreclaimable is just check zone->all_unreclaimable.
Then, who set it? kswapd. What is kswapd doing? Sleep.
So, do_try_free_pages return 1, in turn, direct reclaimer think there is
progress so do not kill anything. 

It's just an example from your log and we can see more potential bugs
and I agree with Michal that "all_unreclaimable was just a bad idea
from the very beginning". It's very subtle and error-prone.

> >
> >> Thus this patch removes zone->all_unreclaimable field completely and
> >> recalculates zone reclaimable state every time.
> >>
> >> Note: we can't take the idea that direct-reclaim see
> >> zone->pages_scanned directly and kswapd continue to use
> >> zone->all_unreclaimable. Because, it is racy. commit 929bea7c71
> >> (vmscan: all_unreclaimable() use
> >> zone->all_unreclaimable as a name) describes the detail.
> >>
> >> @@ -99,4 +100,23 @@ static __always_inline enum lru_list page_lru(struct page *page)
> >>  	return lru;
> >>  }
> >>
> >> +static inline unsigned long zone_reclaimable_pages(struct zone *zone)
> >> +{
> >> +	int nr;
> >> +
> >> +	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
> >> +	     zone_page_state(zone, NR_INACTIVE_FILE);
> >> +
> >> +	if (get_nr_swap_pages() > 0)
> >> +		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
> >> +		      zone_page_state(zone, NR_INACTIVE_ANON);
> >> +
> >> +	return nr;
> >> +}
> >> +
> >> +static inline bool zone_reclaimable(struct zone *zone) {
> >> +	return zone->pages_scanned < zone_reclaimable_pages(zone) * 6; }
> >
> >Inlining is often wrong.  Uninlining just these two funtions saves several hundred bytes of text in mm/.  That's three of someone
> >else's cachelines which we didn't need to evict.
> Would you explain more about why "inline is often wrong"? Thanks a lot!

Andrew said it increases binary size several hundred bytes.

Reclaim stuff is totally slow path in MM so normally, we don't buy such
bad deal. (code size VS speed)

> >
> >And what the heck is up with that magical "6"?  Why not "7"?  "42"?
> This magical number "6" was first defined in commit d1908362ae0.
> Hi, Minchan, do you remember why we set this number? Thanks!

Not me. It was introduced by [1] long time ago and long time ago,
it was just 4. I don't know who did at the first time.
Anyway, I agree it's very heuristic but have no idea because
some system might want to avoid OOM kill as slow as possible
because even a process killing is very critical for the system
while some system like android want to make OOM kill as soon as
possible because it prefers background process killing to system
slowness. So, IMHO, we would need a knob for tune.

[1] 4ff1ffb4870b007, [PATCH] oom: reclaim_mapped on oom.


> >
> >At a minimum it needs extensive documentation which describes why "6"
> >is the optimum value for all machines and workloads (good luck with
> >that) and which describes the effects of altering this number and which helps people understand why we didn't make it a runtime
> >tunable.
> >
> >I'll merge it for some testing (the lack of Tested-by's is conspicuous) but I don't want to put that random "6" into Linux core MM in
> >its current state.
> I did the test in kernel v3.4, it works fine and solve the endless loop in direct reclaim path, but not test with latest kernel version.
> >

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
