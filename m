From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] vmscan: Force kswapd to take notice faster when
 high-order watermarks are being hit
Date: Tue, 27 Oct 2009 13:19:05 -0700
Message-ID: <20091027131905.410ec04a.akpm@linux-foundation.org>
References: <1256650833-15516-1-git-send-email-mel@csn.ul.ie>
	<1256650833-15516-4-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756800AbZJ0UTk@vger.kernel.org>
In-Reply-To: <1256650833-15516-4-git-send-email-mel@csn.ul.ie>
Sender: linux-kernel-owner@vger.kernel.org
Cc: stable@kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org\"" <linux-mm@kvack.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-Id: linux-mm.kvack.org

On Tue, 27 Oct 2009 13:40:33 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> When a high-order allocation fails, kswapd is kicked so that it reclaims
> at a higher-order to avoid direct reclaimers stall and to help GFP_ATOMIC
> allocations. Something has changed in recent kernels that affect the timing
> where high-order GFP_ATOMIC allocations are now failing with more frequency,
> particularly under pressure. This patch forces kswapd to notice sooner that
> high-order allocations are occuring.
> 

"something has changed"?  Shouldn't we find out what that is?

> ---
>  mm/vmscan.c |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 64e4388..7eceb02 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2016,6 +2016,15 @@ loop_again:
>  					priority != DEF_PRIORITY)
>  				continue;
>  
> +			/*
> +			 * Exit the function now and have kswapd start over
> +			 * if it is known that higher orders are required
> +			 */
> +			if (pgdat->kswapd_max_order > order) {
> +				all_zones_ok = 1;
> +				goto out;
> +			}
> +
>  			if (!zone_watermark_ok(zone, order,
>  					high_wmark_pages(zone), end_zone, 0))
>  				all_zones_ok = 0;

So this handles the case where some concurrent thread or interrupt
increases pgdat->kswapd_max_order while kswapd was running
balance_pgdat(), yes?

Does that actually happen much?  Enough for this patch to make any
useful difference?

If one where to whack a printk in that `if' block, how often would it
trigger, and under what circumstances?


If the -stable maintainers were to ask me "why did you send this" then
right now my answer would have to be "I have no idea".  Help.
