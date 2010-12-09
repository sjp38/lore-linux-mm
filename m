Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E0F4C6B0087
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 19:48:17 -0500 (EST)
Message-ID: <4D002730.7050504@redhat.com>
Date: Wed, 08 Dec 2010 19:47:44 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch] mm: skip rebalance of hopeless zones
References: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org> <20101208141909.5c9c60e8.akpm@linux-foundation.org>
In-Reply-To: <20101208141909.5c9c60e8.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 12/08/2010 05:19 PM, Andrew Morton wrote:

> presumably in certain cases that's a bit more efficient than doing the
> scan and using ->all_unreclaimable.  But the scanner shouldn't have got
> stuck!  That's a regresion which got added, and I don't think that new
> code of this nature was needed to fix that regression.
>
> Did this zone end up with ->all_unreclaimable set?  If so, why was
> kswapd stuck in a loop scanning an all-unreclaimable zone?

IIRC kswapd does not get stuck, but the page allocator
keeps waking it up. That also results in near 100% CPU use.

> Also, if I'm understanding the new logic then if the "goal" is 100
> pages and zone_reclaimable_pages() says "50 pages potentially
> reclaimable" then kswapd won't reclaim *any* pages.  If so, is that
> good behaviour?  Should we instead attempt to reclaim some of those 50
> pages and then give up?  That sounds like a better strategy if we want
> to keep (say) network Rx happening in a tight memory situation.

Actually, given the number of reports on how the VM keeps
trying to hard and the system stalls for minutes before an
OOM kill happens, giving up earlier is probably the right
thing to do.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
