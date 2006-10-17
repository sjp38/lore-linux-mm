Message-ID: <45347951.3050907@yahoo.com.au>
Date: Tue, 17 Oct 2006 16:33:53 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] Use min of two prio settings in calculating distress
 for reclaim
References: <4534323F.5010103@google.com>
In-Reply-To: <4534323F.5010103@google.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Bligh <mbligh@google.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Martin Bligh wrote:

> Another bug is that if try_to_free_pages / balance_pgdat are called
> with a gfp_mask specifying GFP_IO and/or GFP_FS, they may reclaim
> the requisite number of pages, and reset prev_priority to DEF_PRIORITY.
>
> However, another reclaimer without those gfp_mask flags set may still
> be struggling to reclaim pages. The easy fix for this is to key the
> distress calculation not off zone->prev_priority, but also take into
> account the local caller's priority by using:
> min(zone->prev_priority, sc->priority)


Does it really matter who is doing the actual reclaiming? IMO, if the
non-crippled (GFP_IO|GFP_FS) reclaimer is making progress, the other
guy doesn't need to start swapping, and should soon notice that some
pages are getting freed up.

Workloads where non GFP_IO or GFP_FS reclaimers are having a lot of
trouble indicates that either it is very swappy or page writeback has
broken down and lots of dirty pages are being reclaimed off the LRU.
In either case, they are likely to continue to have problems, even if
they are now able to unmap the odd page.

What are the empirical effects of this patch? What's the numbers? And
what have you done to akpm? ;)
--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
