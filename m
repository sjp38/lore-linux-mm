Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAT7kTMe019636
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sat, 29 Nov 2008 16:46:29 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id EACC045DE4F
	for <linux-mm@kvack.org>; Sat, 29 Nov 2008 16:46:28 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id CFDAE45DE4E
	for <linux-mm@kvack.org>; Sat, 29 Nov 2008 16:46:28 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B80331DB803A
	for <linux-mm@kvack.org>; Sat, 29 Nov 2008 16:46:28 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FC3F1DB803F
	for <linux-mm@kvack.org>; Sat, 29 Nov 2008 16:46:25 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [rfc] vmscan: serialize aggressive reclaimers
In-Reply-To: <20081127173610.GA1781@cmpxchg.org>
References: <20081124145057.4211bd46@bree.surriel.com> <20081127173610.GA1781@cmpxchg.org>
Message-Id: <20081129164322.8131.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sat, 29 Nov 2008 16:46:24 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> Since we have to pull through a reclaim cycle once we commited to it,
> what do you think about serializing the lower priority levels
> completely?
> 
> The idea is that when one reclaimer has done a low priority level
> iteration with a huge reclaim target, chances are that succeeding
> reclaimers don't even need to drop to lower levels at all because
> enough memory has already been freed.
> 
> My testprogram maps and faults in a file that is about as large as my
> physical memory.  Then it spawns off n processes that try allocate
> 1/2n of total memory in anon pages, i.e. half of it in sum.  After it
> ran, I check how much memory has been reclaimed.  But my zone sizes
> are too small to induce enormous reclaim targets so I don't see vast
> over-reclaims.
> 
> I have measured the time of other tests on an SMP machine with 4 cores
> and the following patch applied.  I couldn't see any performance
> degradation.  But since the bug is not triggerable here, I can not
> prove it helps the original problem, either.

I wonder why nobody of vmscan folks write actual performance improvement value
in patch description.

I think this patch point to right direction.
but, unfortunately, this implementation isn't fast as I mesured as.


> 
> The level where it starts serializing is chosen pretty arbitrarily.
> Suggestions welcome :)
> 
> 	Hannes
> 
> ---
> 
> Prevent over-reclaiming by serializing direct reclaimers below a
> certain priority level.
> 
> Over-reclaiming happens when the sum of the reclaim targets of all
> reclaiming processes is larger than the sum of the needed free pages,
> thus leading to excessive eviction of more cache and anonymous pages
> than required.
> 
> A scan iteration over all zones can not be aborted intermittently when
> enough pages are reclaimed because that would mess up the scan balance
> between the zones.  Instead, prevent that too many processes
> simultaneously commit themselves to lower priority level scans in the
> first place.
> 
> Chances are that after the exclusive reclaimer has finished, enough
> memory has been freed that succeeding scanners don't need to drop to
> lower priority levels at all anymore.
> 
> Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
> ---
>  mm/vmscan.c |   20 ++++++++++++++++++++
>  1 file changed, 20 insertions(+)
> 
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -35,6 +35,7 @@
>  #include <linux/notifier.h>
>  #include <linux/rwsem.h>
>  #include <linux/delay.h>
> +#include <linux/wait.h>
>  #include <linux/kthread.h>
>  #include <linux/freezer.h>
>  #include <linux/memcontrol.h>
> @@ -42,6 +43,7 @@
>  #include <linux/sysctl.h>
>  
>  #include <asm/tlbflush.h>
> +#include <asm/atomic.h>
>  #include <asm/div64.h>
>  
>  #include <linux/swapops.h>
> @@ -1546,10 +1548,15 @@ static unsigned long shrink_zones(int pr
>   * returns:	0, if no pages reclaimed
>   * 		else, the number of pages reclaimed
>   */
> +
> +static DECLARE_WAIT_QUEUE_HEAD(reclaim_wait);
> +static atomic_t reclaim_exclusive = ATOMIC_INIT(0);
> +
>  static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  					struct scan_control *sc)
>  {
>  	int priority;
> +	int exclusive = 0;
>  	unsigned long ret = 0;
>  	unsigned long total_scanned = 0;
>  	unsigned long nr_reclaimed = 0;
> @@ -1580,6 +1587,14 @@ static unsigned long do_try_to_free_page
>  		sc->nr_scanned = 0;
>  		if (!priority)
>  			disable_swap_token();
> +		/*
> +		 * Serialize aggressive reclaimers
> +		 */
> +		if (priority <= DEF_PRIORITY / 2 && !exclusive) {

On large machine, DEF_PRIORITY / 2 is really catastrophe situation.
2^6 = 64. 
if zone has 64GB memory, it mean 1GB reclaim.
I think more early restriction is better.


> +			wait_event(reclaim_wait,
> +				!atomic_cmpxchg(&reclaim_exclusive, 0, 1));
> +			exclusive = 1;
> +		}

if you want to restrict to one task, you can use mutex.
and this wait_queue should put on global variable. it should be zone variable.

In addision, you don't consider recursive relaim and several task can't sleep there.


please believe me. I have richest experience about reclaim throttling in the planet.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
