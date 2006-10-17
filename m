Message-ID: <45351877.9030107@google.com>
Date: Tue, 17 Oct 2006 10:52:55 -0700
From: Martin Bligh <mbligh@google.com>
MIME-Version: 1.0
Subject: Re: [RFC] Remove temp_priority
References: <45351423.70804@google.com> <4535160E.2010908@yahoo.com.au>
In-Reply-To: <4535160E.2010908@yahoo.com.au>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Martin Bligh wrote:
> 
>> This is not tested yet. What do you think?
>>
>> This patch removes temp_priority, as it is racy. We're setting
>> prev_priority from it, and yet temp_priority could have been
>> set back to DEF_PRIORITY by another reclaimer.
> 
> 
> I like it.

OK, I think that should fix most of it, and I'll admit it's cleaner
than the first one.

> I wonder if we should get kswapd to stick its priority
> into the zone at the point where zone_watermark_ok becomes true,
> rather than setting all zones to the lowest priority? That would
> require a bit more logic though I guess.
 >
> For that matter (going off the topic a bit), I wonder if
> try_to_free_pages should have a watermark check there too? This
> might help reduce the latency issue you brought up where one process
> has reclaimed a lot of pages, but another isn't making any progress
> and has to go through the full priority range? Maybe that's
> statistically pretty unlikely?

I've been mulling over how to kill prev_priority (and make everyone
happy, including akpm). My original thought was to keep a different
min_priority for each of GFP_IO, GFP_IO|GFP_FS, and the no IO ones.
But we still have the problem of how to accurately set the min back
up when we are sucessful.

Perhaps we should be a little more radical, and treat everyone apart
from kswapd as independant. Keep a kswapd_priority in the zone
structure, and all the direct reclaimers have their own local priority.
Then we set distress from min(kswap_priority, priority). All that does
is kick the direct reclaimers up a bit faster - kswapd has the easiest
time reclaiming pages, so that should never be too low.

M.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
