Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D7E3A6007F3
	for <linux-mm@kvack.org>; Sun, 18 Jul 2010 04:44:36 -0400 (EDT)
Received: by wyj26 with SMTP id 26so3870004wyj.14
        for <linux-mm@kvack.org>; Sun, 18 Jul 2010 01:44:34 -0700 (PDT)
Subject: Re: [PATCH 2/8] Basic zcache functionality
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <1279283870-18549-3-git-send-email-ngupta@vflare.org>
References: <1279283870-18549-1-git-send-email-ngupta@vflare.org>
	 <1279283870-18549-3-git-send-email-ngupta@vflare.org>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 18 Jul 2010 10:44:31 +0200
Message-ID: <1279442671.2476.34.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Christoph Hellwig <hch@infradead.org>, Minchan Kim <minchan.kim@gmail.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Le vendredi 16 juillet 2010 A  18:07 +0530, Nitin Gupta a A(C)crit :

> This particular patch implemets basic functionality only:
> +static u64 zcache_get_stat(struct zcache_pool *zpool,
> +		enum zcache_pool_stats_index idx)
> +{
> +	int cpu;
> +	s64 val = 0;
> +
> +	for_each_possible_cpu(cpu) {
> +		unsigned int start;
> +		struct zcache_pool_stats_cpu *stats;
> +
> +		stats = per_cpu_ptr(zpool->stats, cpu);
> +		do {
> +			start = u64_stats_fetch_begin(&stats->syncp);
> +			val += stats->count[idx];
> +		} while (u64_stats_fetch_retry(&stats->syncp, start));
> +	}
> +
> +	BUG_ON(val < 0);
> +	return val;
> +}

Sorry this is wrong.

Inside the fetch/retry block you should not do the addition to val, only
a read of value to a temporary variable, since this might be done
several times.

You want something like :

static u64 zcache_get_stat(struct zcache_pool *zpool,
			   enum zcache_pool_stats_index idx)
{
	int cpu;
	s64 temp, val = 0;

	for_each_possible_cpu(cpu) {
		unsigned int start;
		struct zcache_pool_stats_cpu *stats;

		stats = per_cpu_ptr(zpool->stats, cpu);
		do {
			start = u64_stats_fetch_begin(&stats->syncp);
			temp = stats->count[idx];
		} while (u64_stats_fetch_retry(&stats->syncp, start));
		val += temp;
	}

...
}



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
