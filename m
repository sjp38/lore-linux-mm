Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 030636B026D
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 10:28:50 -0500 (EST)
Date: Tue, 13 Dec 2011 16:28:43 +0100
From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>
Subject: Re: [patch 3/4] mm: bootmem: drop superfluous range check when
 freeing pages in bulk
Message-ID: <20111213152843.GD4585@pengutronix.de>
References: <1323784711-1937-1-git-send-email-hannes@cmpxchg.org>
 <1323784711-1937-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1323784711-1937-4-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello Johannes,

On Tue, Dec 13, 2011 at 02:58:30PM +0100, Johannes Weiner wrote:
> The area node_bootmem_map represents is aligned to BITS_PER_LONG, and
> all bits in any aligned word of that map valid.  When the represented
> area extends beyond the end of the node, the non-existant pages will
> be marked as reserved.
> 
> As a result, when freeing a page block, doing an explicit range check
> for whether that block is within the node's range is redundant as the
> bitmap is consulted anyway to see whether all pages in the block are
> unreserved.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
I suggest to drop my patch then and add something like

	Reported-by: $me

to this one instead.

Other than that I will give your series a spin on my ARM machine later
today.

Best regards
Uwe

> ---
>  mm/bootmem.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/bootmem.c b/mm/bootmem.c
> index 3e6f152..1aea171 100644
> --- a/mm/bootmem.c
> +++ b/mm/bootmem.c
> @@ -197,7 +197,7 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
>  		idx = start - bdata->node_min_pfn;
>  		vec = ~map[idx / BITS_PER_LONG];
>  
> -		if (aligned && vec == ~0UL && start + BITS_PER_LONG <= end) {
> +		if (aligned && vec == ~0UL) {
>  			int order = ilog2(BITS_PER_LONG);
>  
>  			__free_pages_bootmem(pfn_to_page(start), order);
> -- 
> 1.7.7.3
> 
> 

-- 
Pengutronix e.K.                           | Uwe Kleine-Konig            |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
