Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 475116B0044
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 06:12:14 -0500 (EST)
Date: Thu, 20 Dec 2012 11:12:08 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: do not sleep in balance_pgdat if there's no i/o
 congestion
Message-ID: <20121220111208.GD10819@suse.de>
References: <50D24AF3.1050809@iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <50D24AF3.1050809@iskon.hr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zlatko Calusic <zlatko.calusic@iskon.hr>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Dec 20, 2012 at 12:17:07AM +0100, Zlatko Calusic wrote:
> On a 4GB RAM machine, where Normal zone is much smaller than
> DMA32 zone, the Normal zone gets fragmented in time. This requires
> relatively more pressure in balance_pgdat to get the zone above the
> required watermark. Unfortunately, the congestion_wait() call in there
> slows it down for a completely wrong reason, expecting that there's
> a lot of writeback/swapout, even when there's none (much more common).
> After a few days, when fragmentation progresses, this flawed logic
> translates to a very high CPU iowait times, even though there's no
> I/O congestion at all. If THP is enabled, the problem occurs sooner,
> but I was able to see it even on !THP kernels, just by giving it a bit
> more time to occur.
> 
> The proper way to deal with this is to not wait, unless there's
> congestion. Thanks to Mel Gorman, we already have the function that
> perfectly fits the job. The patch was tested on a machine which
> nicely revealed the problem after only 1 day of uptime, and it's been
> working great.
> ---
>  mm/vmscan.c |   12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 

Acked-by: Mel Gorman <mgorman@suse.de

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
