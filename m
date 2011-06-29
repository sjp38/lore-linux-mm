Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3437F6B010D
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 06:58:28 -0400 (EDT)
Message-ID: <4E0B052C.7000500@draigBrady.com>
Date: Wed, 29 Jun 2011 11:57:48 +0100
From: =?ISO-8859-1?Q?P=E1draig_Brady?= <P@draigBrady.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] mm: vmscan: Correct check for kswapd sleeping in
 sleeping_prematurely
References: <1308926697-22475-1-git-send-email-mgorman@suse.de>	<1308926697-22475-2-git-send-email-mgorman@suse.de> <20110628144900.b33412c6.akpm@linux-foundation.org>
In-Reply-To: <20110628144900.b33412c6.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, James Bottomley <James.Bottomley@HansenPartnership.com>, Colin King <colin.king@canonical.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Lutomirski <luto@mit.edu>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On 28/06/11 22:49, Andrew Morton wrote:
> On Fri, 24 Jun 2011 15:44:54 +0100
> Mel Gorman <mgorman@suse.de> wrote:
> 
>> During allocator-intensive workloads, kswapd will be woken frequently
>> causing free memory to oscillate between the high and min watermark.
>> This is expected behaviour.
>>
>> A problem occurs if the highest zone is small.  balance_pgdat()
>> only considers unreclaimable zones when priority is DEF_PRIORITY
>> but sleeping_prematurely considers all zones. It's possible for this
>> sequence to occur
>>
>>   1. kswapd wakes up and enters balance_pgdat()
>>   2. At DEF_PRIORITY, marks highest zone unreclaimable
>>   3. At DEF_PRIORITY-1, ignores highest zone setting end_zone
>>   4. At DEF_PRIORITY-1, calls shrink_slab freeing memory from
>>         highest zone, clearing all_unreclaimable. Highest zone
>>         is still unbalanced
>>   5. kswapd returns and calls sleeping_prematurely
>>   6. sleeping_prematurely looks at *all* zones, not just the ones
>>      being considered by balance_pgdat. The highest small zone
>>      has all_unreclaimable cleared but but the zone is not
>>      balanced. all_zones_ok is false so kswapd stays awake
>>
>> This patch corrects the behaviour of sleeping_prematurely to check
>> the zones balance_pgdat() checked.
> 
> But kswapd is making progress: it's reclaiming slab.  Eventually that
> won't work any more and all_unreclaimable will not be cleared and the
> condition will fix itself up?
> 
> 
> 
> btw,
> 
> 	if (!sleeping_prematurely(...))
> 		sleep();
> 
> hurts my brain.  My brain would prefer
> 
> 	if (kswapd_should_sleep(...))
> 		sleep();
> 
> no?
> 
>> Reported-and-tested-by: Padraig Brady <P@draigBrady.com>
> 
> But what were the before-and-after observations?  I don't understand
> how this can cause a permanent cpuchew by kswapd.

Context:
  http://marc.info/?t=130865025500001&r=1&w=2
  https://bugzilla.redhat.com/show_bug.cgi?id=712019

Summary:

This will spin kswapd0 on my SNB laptop with 3GB RAM (with small normal zone):

    dd bs=1M count=3000 if=/dev/zero of=spin.test

Basically once a certain amount of data is cached,
kswapd0 will start spinning, until the data
is removed from cache (by `rm spin.test` for example).

cheers,
Padraig.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
