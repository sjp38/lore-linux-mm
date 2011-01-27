Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C50898D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 18:27:20 -0500 (EST)
Message-ID: <4D41FD2F.3050006@redhat.com>
Date: Thu, 27 Jan 2011 18:18:07 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: too big min_free_kbytes
References: <20110124150033.GB9506@random.random> <20110126141746.GS18984@csn.ul.ie> <20110126152302.GT18984@csn.ul.ie> <20110126154203.GS926@random.random> <20110126163655.GU18984@csn.ul.ie> <20110126174236.GV18984@csn.ul.ie> <20110127134057.GA32039@csn.ul.ie> <20110127152755.GB30919@random.random> <20110127160301.GA29291@csn.ul.ie> <20110127185215.GE16981@random.random> <20110127213106.GA25933@csn.ul.ie>
In-Reply-To: <20110127213106.GA25933@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>
List-ID: <linux-mm.kvack.org>

On 01/27/2011 04:31 PM, Mel Gorman wrote:

> Whatever the final solution, it both needs to prevent too much memory
> being reclaimed and allow kswapd to go to sleep if there is no
> indication from the page allocator that it should stay awake.

A third requirement:

If one zone has a lot lower memory pressure than another zone,
we want to do relatively more memory allocations from that zone,
than from a zone where the memory is heavily used.

If kswapd only ever goes up to the high watermark, and also uses
that as its sleep point, the allocations end up corresponding to
zone size alone and not to memory pressure.

Going a little bit above the high watermark (1% of zone size?
high + min watermark?) will help balance things out between zones.

>>   			if (!zone_watermark_ok_safe(zone, order,
>> -					8*high_wmark_pages(zone), end_zone, 0))
>> +					(zone->present_pages +
>> +					 KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
>> +					 KSWAPD_ZONE_BALANCE_GAP_RATIO +
>> +					high_wmark_pages(zone), end_zone, 0))
>
> Rik has already pointed out that this potentially is a very large gap
> but that is an addressable problem if the final decision goes this
> direction.

I was wrong.  I guess on some systems the min watermark can be less
than 1% and (high + min) may be better, but on most systems the
number of pages should be about the same.

Maybe we should use high_wmark_pages(zone) + low_wmark_pages(zone)
for easy readability?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
