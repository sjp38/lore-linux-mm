Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 47B156B007E
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 05:40:18 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C30093EE0C7
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 18:40:14 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A78F745DE66
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 18:40:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7906E45DE62
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 18:40:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 695BAE08001
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 18:40:14 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2AC1E1DB8037
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 18:40:14 +0900 (JST)
Message-ID: <4E1C1684.4090706@jp.fujitsu.com>
Date: Tue, 12 Jul 2011 18:40:20 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: vmscan: Do use use PF_SWAPWRITE from zone_reclaim
References: <1310389274-13995-1-git-send-email-mgorman@suse.de>	<1310389274-13995-2-git-send-email-mgorman@suse.de> <CAEwNFnATXiQsmbfuvZNEtcpcVZkyZKRFB1SKbkEREaCW4S-aUg@mail.gmail.com>
In-Reply-To: <CAEwNFnATXiQsmbfuvZNEtcpcVZkyZKRFB1SKbkEREaCW4S-aUg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan.kim@gmail.com
Cc: mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux.com

(2011/07/12 18:27), Minchan Kim wrote:
> Hi Mel,
> 
> On Mon, Jul 11, 2011 at 10:01 PM, Mel Gorman <mgorman@suse.de> wrote:
>> Zone reclaim is similar to direct reclaim in a number of respects.
>> PF_SWAPWRITE is used by kswapd to avoid a write-congestion check
>> but it's set also set for zone_reclaim which is inappropriate.
>> Setting it potentially allows zone_reclaim users to cause large IO
>> stalls which is worse than remote memory accesses.
> 
> As I read zone_reclaim_mode in vm.txt, I think it's intentional.
> It has meaning of throttle the process which are writing large amounts
> of data. The point is to prevent use of remote node's free memory.
> 
> And we has still the comment. If you're right, you should remove comment.
> "         * and we also need to be able to write out pages for RECLAIM_WRITE
>          * and RECLAIM_SWAP."
> 
> 
> And at least, we should Cc Christoph and KOSAKI.

Of course, I'll take full ack this. Do you remember I posted the same patch
about one year ago. At that time, Mel disagreed me and I'm glad to see he changed
the mind. :)



> 
>>
>> Signed-off-by: Mel Gorman <mgorman@suse.de>
>> ---
>>  mm/vmscan.c |    4 ++--
>>  1 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 4f49535..ebef213 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -3063,7 +3063,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>>         * and we also need to be able to write out pages for RECLAIM_WRITE
>>         * and RECLAIM_SWAP.
>>         */
>> -       p->flags |= PF_MEMALLOC | PF_SWAPWRITE;
>> +       p->flags |= PF_MEMALLOC;
>>        lockdep_set_current_reclaim_state(gfp_mask);
>>        reclaim_state.reclaimed_slab = 0;
>>        p->reclaim_state = &reclaim_state;
>> @@ -3116,7 +3116,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>>        }
>>
>>        p->reclaim_state = NULL;
>> -       current->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE);
>> +       current->flags &= ~PF_MEMALLOC;
>>        lockdep_clear_current_reclaim_state();
>>        return sc.nr_reclaimed >= nr_pages;
>>  }
>> --
>> 1.7.3.4
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
> 
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
