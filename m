Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7C3CB8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 19:51:08 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 41D393EE0BD
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 09:51:04 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A47045DE5B
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 09:51:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 154D645DE59
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 09:51:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 09AE2E08001
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 09:51:04 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BADE5E18001
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 09:51:03 +0900 (JST)
Date: Tue, 8 Mar 2011 09:44:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: check zone->all_unreclaimable in
 all_unreclaimable()
Message-Id: <20110308094438.1ba05ed2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110307135831.9e0d7eaa.akpm@linux-foundation.org>
References: <1299325456-2687-1-git-send-email-avagin@openvz.org>
	<20110305152056.GA1918@barrios-desktop>
	<4D72580D.4000208@gmail.com>
	<20110305155316.GB1918@barrios-desktop>
	<4D7267B6.6020406@gmail.com>
	<20110305170759.GC1918@barrios-desktop>
	<20110307135831.9e0d7eaa.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Vagin <avagin@gmail.com>, Andrey Vagin <avagin@openvz.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 7 Mar 2011 13:58:31 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Sun, 6 Mar 2011 02:07:59 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
> 
> > On Sat, Mar 05, 2011 at 07:41:26PM +0300, Andrew Vagin wrote:
> > > On 03/05/2011 06:53 PM, Minchan Kim wrote:
> > > >On Sat, Mar 05, 2011 at 06:34:37PM +0300, Andrew Vagin wrote:
> > > >>On 03/05/2011 06:20 PM, Minchan Kim wrote:
> > > >>>On Sat, Mar 05, 2011 at 02:44:16PM +0300, Andrey Vagin wrote:
> > > >>>>Check zone->all_unreclaimable in all_unreclaimable(), otherwise the
> > > >>>>kernel may hang up, because shrink_zones() will do nothing, but
> > > >>>>all_unreclaimable() will say, that zone has reclaimable pages.
> > > >>>>
> > > >>>>do_try_to_free_pages()
> > > >>>>	shrink_zones()
> > > >>>>		 for_each_zone
> > > >>>>			if (zone->all_unreclaimable)
> > > >>>>				continue
> > > >>>>	if !all_unreclaimable(zonelist, sc)
> > > >>>>		return 1
> > > >>>>
> > > >>>>__alloc_pages_slowpath()
> > > >>>>retry:
> > > >>>>	did_some_progress = do_try_to_free_pages(page)
> > > >>>>	...
> > > >>>>	if (!page&&   did_some_progress)
> > > >>>>		retry;
> > > >>>>
> > > >>>>Signed-off-by: Andrey Vagin<avagin@openvz.org>
> > > >>>>---
> > > >>>>  mm/vmscan.c |    2 ++
> > > >>>>  1 files changed, 2 insertions(+), 0 deletions(-)
> > > >>>>
> > > >>>>diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > >>>>index 6771ea7..1c056f7 100644
> > > >>>>--- a/mm/vmscan.c
> > > >>>>+++ b/mm/vmscan.c
> > > >>>>@@ -2002,6 +2002,8 @@ static bool all_unreclaimable(struct zonelist *zonelist,
> > > >>>>
> > > >>>>  	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> > > >>>>  			gfp_zone(sc->gfp_mask), sc->nodemask) {
> > > >>>>+		if (zone->all_unreclaimable)
> > > >>>>+			continue;
> > > >>>>  		if (!populated_zone(zone))
> > > >>>>  			continue;
> > > >>>>  		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
> > > >>>zone_reclaimable checks it. Isn't it enough?
> > > >>I sent one more patch [PATCH] mm: skip zombie in OOM-killer.
> > > >>This two patches are enough.
> > > >Sorry if I confused you.
> > > >I mean zone->all_unreclaimable become true if !zone_reclaimable in balance_pgdat.
> > > >zone_reclaimable compares recent pages_scanned with the number of zone lru pages.
> > > >So too many page scanning in small lru pages makes the zone to unreclaimable zone.
> > > >
> > > >In all_unreclaimable, we calls zone_reclaimable to detect it.
> > > >It's the same thing with your patch.
> > > balance_pgdat set zone->all_unreclaimable, but the problem is that
> > > it is cleaned late.
> > 
> > Yes. It can be delayed by pcp so (zone->all_unreclaimable = true) is
> > a false alram since zone have a free page and it can be returned 
> > to free list by drain_all_pages in next turn.
> > 
> > > 
> > > The problem is that zone->all_unreclaimable = True, but
> > > zone_reclaimable() returns True too.
> > 
> > Why is it a problem? 
> > If zone->all_unreclaimable gives a false alram, we does need to check
> > it again by zone_reclaimable call.
> > 
> > If we believe a false alarm and give up the reclaim, maybe we have to make
> > unnecessary oom kill.
> > 
> > > 
> > > zone->all_unreclaimable will be cleaned in free_*_pages, but this
> > > may be late. It is enough allocate one page from page cache, that
> > > zone_reclaimable() returns True and zone->all_unreclaimable becomes
> > > True.
> > > >>>Does the hang up really happen or see it by code review?
> > > >>Yes. You can reproduce it for help the attached python program. It's
> > > >>not very clever:)
> > > >>It make the following actions in loop:
> > > >>1. fork
> > > >>2. mmap
> > > >>3. touch memory
> > > >>4. read memory
> > > >>5. munmmap
> > > >It seems the test program makes fork bombs and memory hogging.
> > > >If you applied this patch, the problem is gone?
> > > Yes.
> > 
> > Hmm.. Although it solves the problem, I think it's not a good idea that
> > depends on false alram and give up the retry.
> 
> Any alternative proposals?  We should get the livelock fixed if possible..

I agree with Minchan and can't think this is a real fix....
Andrey, I'm now trying your fix and it seems your fix for oom-killer,
'skip-zombie-process' works enough good for my environ.

What is your enviroment ? number of cpus ? architecture ? size of memory ?



Thanks,
-Kame

















--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
