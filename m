Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id D83D86B0033
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 15:43:09 -0400 (EDT)
Date: Tue, 27 Aug 2013 12:43:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [resend] [PATCH V3] mm: vmscan: fix do_try_to_free_pages()
 livelock
Message-Id: <20130827124307.63259439a80042bd81f27684@linux-foundation.org>
In-Reply-To: <89813612683626448B837EE5A0B6A7CB3B631767D7@SC-VEXCH4.marvell.com>
References: <89813612683626448B837EE5A0B6A7CB3B630BE80B@SC-VEXCH4.marvell.com>
	<20130805074146.GD10146@dhcp22.suse.cz>
	<89813612683626448B837EE5A0B6A7CB3B630BED6B@SC-VEXCH4.marvell.com>
	<20130806103543.GA31138@dhcp22.suse.cz>
	<89813612683626448B837EE5A0B6A7CB3B63175BCA@SC-VEXCH4.marvell.com>
	<20130808181426.GI715@cmpxchg.org>
	<89813612683626448B837EE5A0B6A7CB3B631767D7@SC-VEXCH4.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lisa Du <cldu@marvell.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Bob Liu <lliubbo@gmail.com>, Neil Zhang <zhangwm@marvell.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Aaditya Kumar <aaditya.kumar.30@gmail.com>, "yinghan@google.com" <yinghan@google.com>, "npiggin@gmail.com" <npiggin@gmail.com>, "riel@redhat.com" <riel@redhat.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>

On Sun, 11 Aug 2013 18:46:08 -0700 Lisa Du <cldu@marvell.com> wrote:

> This patch is based on KOSAKI's work and I add a little more
> description, please refer https://lkml.org/lkml/2012/6/14/74.
> 
> Currently, I found system can enter a state that there are lots
> of free pages in a zone but only order-0 and order-1 pages which
> means the zone is heavily fragmented, then high order allocation
> could make direct reclaim path's long stall(ex, 60 seconds)
> especially in no swap and no compaciton enviroment. This problem
> happened on v3.4, but it seems issue still lives in current tree,
> the reason is do_try_to_free_pages enter live lock:
> 
> kswapd will go to sleep if the zones have been fully scanned
> and are still not balanced. As kswapd thinks there's little point
> trying all over again to avoid infinite loop. Instead it changes
> order from high-order to 0-order because kswapd think order-0 is the
> most important. Look at 73ce02e9 in detail. If watermarks are ok,
> kswapd will go back to sleep and may leave zone->all_unreclaimable = 0.
> It assume high-order users can still perform direct reclaim if they wish.
> 
> Direct reclaim continue to reclaim for a high order which is not a
> COSTLY_ORDER without oom-killer until kswapd turn on zone->all_unreclaimble.
> This is because to avoid too early oom-kill. So it means direct_reclaim
> depends on kswapd to break this loop.
> 
> In worst case, direct-reclaim may continue to page reclaim forever
> when kswapd sleeps forever until someone like watchdog detect and finally
> kill the process. As described in:
> http://thread.gmane.org/gmane.linux.kernel.mm/103737
> 
> We can't turn on zone->all_unreclaimable from direct reclaim path
> because direct reclaim path don't take any lock and this way is racy.
> Thus this patch removes zone->all_unreclaimable field completely and
> recalculates zone reclaimable state every time.
> 
> Note: we can't take the idea that direct-reclaim see zone->pages_scanned
> directly and kswapd continue to use zone->all_unreclaimable. Because, it
> is racy. commit 929bea7c71 (vmscan: all_unreclaimable() use
> zone->all_unreclaimable as a name) describes the detail.

I did this to fix the build:

--- a/mm/migrate.c~mm-vmscan-fix-do_try_to_free_pages-livelock-fix-2
+++ a/mm/migrate.c
@@ -1471,7 +1471,7 @@ static bool migrate_balanced_pgdat(struc
 		if (!populated_zone(zone))
 			continue;
 
-		if (zone->all_unreclaimable)
+		if (!zone_reclaimable(zone))
 			continue;
 
 		/* Avoid waking kswapd by allocating pages_to_migrate pages. */

Please review and runtime test it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
