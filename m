Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A83DA6B01F1
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 12:20:28 -0400 (EDT)
Date: Mon, 30 Aug 2010 11:20:10 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 03/10] Use percpu stats
In-Reply-To: <1281374816-904-4-git-send-email-ngupta@vflare.org>
Message-ID: <alpine.DEB.2.00.1008301114460.10316@router.home>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org> <1281374816-904-4-git-send-email-ngupta@vflare.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 9 Aug 2010, Nitin Gupta wrote:

> -static void zram_stat_inc(u32 *v)
> +static void zram_add_stat(struct zram *zram,
> +			enum zram_stats_index idx, s64 val)
>  {
> -	*v = *v + 1;
> +	struct zram_stats_cpu *stats;
> +
> +	preempt_disable();
> +	stats = __this_cpu_ptr(zram->stats);
> +	u64_stats_update_begin(&stats->syncp);
> +	stats->count[idx] += val;
> +	u64_stats_update_end(&stats->syncp);
> +	preempt_enable();

Maybe do

#define zram_add_stat(zram, index, val)
		this_cpu_add(zram->stats->count[index], val)

instead? It creates an add in a single "atomic" per cpu instruction and
deals with the fallback scenarios for processors that cannot handle 64
bit adds.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
