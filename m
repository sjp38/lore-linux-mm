Message-ID: <416CE423.3000607@cyberone.com.au>
Date: Wed, 13 Oct 2004 18:15:31 +1000
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: Page cache write performance issue
References: <20041013054452.GB1618@frodo> <20041012231945.2aff9a00.akpm@osdl.org> <20041013063955.GA2079@frodo> <20041013000206.680132ad.akpm@osdl.org> <20041013172352.B4917536@wobbly.melbourne.sgi.com>
In-Reply-To: <20041013172352.B4917536@wobbly.melbourne.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nathan Scott <nathans@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>


Nathan Scott wrote:

>On Wed, Oct 13, 2004 at 12:02:06AM -0700, Andrew Morton wrote:
>
>>Well something else if fishy: how can you possibly achieve only 4MB/sec? 
>>
>
>These are 1K writes too remember, so it feels a bit like we
>write 'em out one at a time, sync (though no O_SYNC, or fsync,
>or such involved here).  This is on an i686, so 4K pages, and
>using 4K filesystem blocksizes (both xfs and ext2).
>
>

Still shouldn't cause such a big slowdown. Seems like they
might be getting written off the end of the page reclaim
LRU (although in that case it is a bit odd that increasing
the dirty thresholds are improving performance).

I don't think we have any vmscan metrics for this... kswapd
definitely has become more active in 2.6.9-rc. If you're stuck
for ideas, try editing mm/vmscan.c:may_write_to_queue - comment
out the if(current_is_kswapd()) check.

It is a long shot though. Andrew probably has better ideas.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
