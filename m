Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id E9F886B004D
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 06:44:09 -0400 (EDT)
Message-ID: <5093A3F4.8090108@redhat.com>
Date: Fri, 02 Nov 2012 11:44:04 +0100
From: Zdenek Kabelac <zkabelac@redhat.com>
MIME-Version: 1.0
Subject: Re: kswapd0: excessive CPU usage
References: <507688CC.9000104@suse.cz> <106695.1349963080@turing-police.cc.vt.edu> <5076E700.2030909@suse.cz> <118079.1349978211@turing-police.cc.vt.edu> <50770905.5070904@suse.cz> <119175.1349979570@turing-police.cc.vt.edu> <5077434D.7080008@suse.cz> <50780F26.7070007@suse.cz> <20121012135726.GY29125@suse.de> <507BDD45.1070705@suse.cz> <20121015110937.GE29125@suse.de>
In-Reply-To: <20121015110937.GE29125@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis.Kletnieks@vt.edu, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Dne 15.10.2012 13:09, Mel Gorman napsal(a):
> On Mon, Oct 15, 2012 at 11:54:13AM +0200, Jiri Slaby wrote:
>> On 10/12/2012 03:57 PM, Mel Gorman wrote:
>>> mm: vmscan: scale number of pages reclaimed by reclaim/compaction only in direct reclaim
>>>
>>> Jiri Slaby reported the following:
>>>
>>> 	(It's an effective revert of "mm: vmscan: scale number of pages
>>> 	reclaimed by reclaim/compaction based on failures".)
>>> 	Given kswapd had hours of runtime in ps/top output yesterday in the
>>> 	morning and after the revert it's now 2 minutes in sum for the last 24h,
>>> 	I would say, it's gone.
>>>
>>> The intention of the patch in question was to compensate for the loss of
>>> lumpy reclaim. Part of the reason lumpy reclaim worked is because it
>>> aggressively reclaimed pages and this patch was meant to be a
>>> sane compromise.
>>>
>>> When compaction fails, it gets deferred and both compaction and
>>> reclaim/compaction is deferred avoid excessive reclaim. However, since
>>> commit c6543459 (mm: remove __GFP_NO_KSWAPD), kswapd is woken up each time
>>> and continues reclaiming which was not taken into account when the patch
>>> was developed.
>>>
>>> As it is not taking deferred compaction into account in this path it scans
>>> aggressively before falling out and making the compaction_deferred check in
>>> compaction_ready. This patch avoids kswapd scaling pages for reclaim and
>>> leaves the aggressive reclaim to the process attempting the THP
>>> allocation.
>>>
>>> Signed-off-by: Mel Gorman <mgorman@suse.de>
>>> ---
>>>   mm/vmscan.c |   10 ++++++++--
>>>   1 file changed, 8 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>> index 2624edc..2b7edfa 100644
>>> --- a/mm/vmscan.c
>>> +++ b/mm/vmscan.c
>>> @@ -1763,14 +1763,20 @@ static bool in_reclaim_compaction(struct scan_control *sc)
>>>   #ifdef CONFIG_COMPACTION
>>>   /*
>>>    * If compaction is deferred for sc->order then scale the number of pages
>>> - * reclaimed based on the number of consecutive allocation failures
>>> + * reclaimed based on the number of consecutive allocation failures. This
>>> + * scaling only happens for direct reclaim as it is about to attempt
>>> + * compaction. If compaction fails, future allocations will be deferred
>>> + * and reclaim avoided. On the other hand, kswapd does not take compaction
>>> + * deferral into account so if it scaled, it could scan excessively even
>>> + * though allocations are temporarily not being attempted.
>>>    */
>>>   static unsigned long scale_for_compaction(unsigned long pages_for_compaction,
>>>   			struct lruvec *lruvec, struct scan_control *sc)
>>>   {
>>>   	struct zone *zone = lruvec_zone(lruvec);
>>>
>>> -	if (zone->compact_order_failed <= sc->order)
>>> +	if (zone->compact_order_failed <= sc->order &&
>>> +	    !current_is_kswapd())
>>>   		pages_for_compaction <<= zone->compact_defer_shift;
>>>   	return pages_for_compaction;
>>>   }
>>
>> Yes, applying this instead of the revert fixes the issue as well.
>>
>


I've applied this patch on 3.7.0-rc3 kernel - and I still see excessive CPU 
usage - mainly  after  suspend/resume

Here is just simple  kswapd backtrace from running kernel:

kswapd0         R  running task        0    30      2 0x00000000
  ffff8801331ddae8 0000000000000082 ffff880135b8a340 0000000000000008
  ffff880135b8a340 ffff8801331ddfd8 ffff8801331ddfd8 ffff8801331ddfd8
  ffff880071db8000 ffff880135b8a340 0000000000000286 ffff8801331dc000
Call Trace:
  [<ffffffff81555cd2>] preempt_schedule+0x42/0x60
  [<ffffffff81557b75>] _raw_spin_unlock+0x55/0x60
  [<ffffffff811929d1>] put_super+0x31/0x40
  [<ffffffff81192aa2>] drop_super+0x22/0x30
  [<ffffffff81193be9>] prune_super+0x149/0x1b0
  [<ffffffff81141e2a>] shrink_slab+0xba/0x510
  [<ffffffff81185baa>] ? mem_cgroup_iter+0x17a/0x2e0
  [<ffffffff81185afa>] ? mem_cgroup_iter+0xca/0x2e0
  [<ffffffff811450f9>] balance_pgdat+0x629/0x7f0
  [<ffffffff81145434>] kswapd+0x174/0x620
  [<ffffffff8106fd20>] ? __init_waitqueue_head+0x60/0x60
  [<ffffffff811452c0>] ? balance_pgdat+0x7f0/0x7f0
  [<ffffffff8106f50b>] kthread+0xdb/0xe0
  [<ffffffff8106f430>] ? kthread_create_on_node+0x140/0x140
  [<ffffffff8155fb1c>] ret_from_fork+0x7c/0xb0
  [<ffffffff8106f430>] ? kthread_create_on_node+0x140/0x140


Zdenek


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
