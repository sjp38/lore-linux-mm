Date: Fri, 8 Sep 2006 10:24:59 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/8] Avoiding fragmentation with subzone groupings v25
In-Reply-To: <1157704232.17799.48.camel@lappy>
Message-ID: <Pine.LNX.4.64.0609081020490.7094@skynet.skynet.ie>
References: <20060907190342.6166.49732.sendpatchset@skynet.skynet.ie>
 <20060907175848.63379fe1.akpm@osdl.org> <1157704232.17799.48.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 8 Sep 2006, Peter Zijlstra wrote:

> On Thu, 2006-09-07 at 17:58 -0700, Andrew Morton wrote:
>> On Thu,  7 Sep 2006 20:03:42 +0100 (IST)
>> Mel Gorman <mel@csn.ul.ie> wrote:
>>
>>> When a page is allocated, the page-flags
>>> are updated with a value indicating it's type of reclaimability so that it
>>> is placed on the correct list on free.
>>
>> We're getting awful tight on page-flags.
>>
>> Would it be possible to avoid adding the flag?  Say, have a per-zone bitmap
>> of size (zone->present_pages/(1<<MAX_ORDER)) bits, then do a lookup in
>> there to work out whether a particular page is within a MAX_ORDER clump of
>> easy-reclaimable pages?
>
> That would not actually work, the fallback allocation path can move
> blocks smaller than MAX_ORDER to another recaim type.
>

Believe it or not, it may be desirably to have a whole block represented 
by one or two bits. If a fallback allocation occurs and I move blocks 
between lists, I want pages that free later to be freed to the new list as 
well. Currently that doesn't happen because the flags are set per-page but 
it used to happen in an early version of anti-frag.

> But yeah, page flags are getting right, perhaps Rafael can use his
> recently introduced bitmaps to rid us of the swsusp flags?
>
>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
