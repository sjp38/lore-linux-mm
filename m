Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id BC69C8D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 05:36:06 -0500 (EST)
Date: Fri, 28 Jan 2011 10:35:39 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: too big min_free_kbytes
Message-ID: <20110128103539.GA14669@csn.ul.ie>
References: <20110126152302.GT18984@csn.ul.ie> <20110126154203.GS926@random.random> <20110126163655.GU18984@csn.ul.ie> <20110126174236.GV18984@csn.ul.ie> <20110127134057.GA32039@csn.ul.ie> <20110127152755.GB30919@random.random> <20110127160301.GA29291@csn.ul.ie> <20110127185215.GE16981@random.random> <20110127213106.GA25933@csn.ul.ie> <4D41FD2F.3050006@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4D41FD2F.3050006@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 27, 2011 at 06:18:07PM -0500, Rik van Riel wrote:
> On 01/27/2011 04:31 PM, Mel Gorman wrote:
>
>> Whatever the final solution, it both needs to prevent too much memory
>> being reclaimed and allow kswapd to go to sleep if there is no
>> indication from the page allocator that it should stay awake.
>
> A third requirement:
>
> If one zone has a lot lower memory pressure than another zone,
> we want to do relatively more memory allocations from that zone,
> than from a zone where the memory is heavily used.
>

Risky. Allocations could end up using a lower zone than required causing
a form of lowmem pressure when highmem should have been used. Worse,
it'll be unnoticable on x86-64 but potentially cause problems on x86-32
that are easily missed.

> If kswapd only ever goes up to the high watermark, and also uses
> that as its sleep point, the allocations end up corresponding to
> zone size alone and not to memory pressure.
>

hmm.

> Going a little bit above the high watermark (1% of zone size?
> high + min watermark?) will help balance things out between zones.
>
>>>   			if (!zone_watermark_ok_safe(zone, order,
>>> -					8*high_wmark_pages(zone), end_zone, 0))
>>> +					(zone->present_pages +
>>> +					 KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
>>> +					 KSWAPD_ZONE_BALANCE_GAP_RATIO +
>>> +					high_wmark_pages(zone), end_zone, 0))
>>
>> Rik has already pointed out that this potentially is a very large gap
>> but that is an addressable problem if the final decision goes this
>> direction.
>
> I was wrong.  I guess on some systems the min watermark can be less
> than 1% and (high + min) may be better, but on most systems the
> number of pages should be about the same.
>
> Maybe we should use high_wmark_pages(zone) + low_wmark_pages(zone)
> for easy readability?
>

I'd be ok with high+low as a starting point to solve the immediate
problem of way too much memory being free and then treat "kswapd must go
to sleep" as a separate problem. I'm less keen on 1% but only because it
could be too large a value.

-- 
Mel Gorman
Linux Technology Center
IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
