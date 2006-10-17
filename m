Message-ID: <45347B91.20404@google.com>
Date: Mon, 16 Oct 2006 23:43:29 -0700
From: "Martin J. Bligh" <mbligh@google.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Use min of two prio settings in calculating distress
 for reclaim
References: <4534323F.5010103@google.com> <45347951.3050907@yahoo.com.au>
In-Reply-To: <45347951.3050907@yahoo.com.au>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Martin Bligh wrote:
> 
>> Another bug is that if try_to_free_pages / balance_pgdat are called
>> with a gfp_mask specifying GFP_IO and/or GFP_FS, they may reclaim
>> the requisite number of pages, and reset prev_priority to DEF_PRIORITY.
>>
>> However, another reclaimer without those gfp_mask flags set may still
>> be struggling to reclaim pages. The easy fix for this is to key the
>> distress calculation not off zone->prev_priority, but also take into
>> account the local caller's priority by using:
>> min(zone->prev_priority, sc->priority)
> 
> 
> Does it really matter who is doing the actual reclaiming? IMO, if the
> non-crippled (GFP_IO|GFP_FS) reclaimer is making progress, the other
> guy doesn't need to start swapping, and should soon notice that some
> pages are getting freed up.

That's not what happens though. We walk down the priorities, fail to
reclaim anything (in this case, move anything from active to inactive)
and the OOM killer fires. Perhaps the other pages being freed are
being stolen ... we're in direct reclaim here. we're meant to be
getting our own pages.

Why would we ever want distress to be based off a priority that's
higher than our current one? That's just silly.

> Workloads where non GFP_IO or GFP_FS reclaimers are having a lot of
> trouble indicates that either it is very swappy or page writeback has
> broken down and lots of dirty pages are being reclaimed off the LRU.
> In either case, they are likely to continue to have problems, even if
> they are now able to unmap the odd page.

We scanned 122,000 odd pages. Of which we skipped over over 100,000
of them because they were mapped, and we didn't think we had to try
very hard, because distress was 0.

> What are the empirical effects of this patch? What's the numbers? And
> what have you done to akpm? ;)

Showed him a real trace of a production system blowing up?
Demonstrated that the current heuristics are broken?
That sort of thing.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
