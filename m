Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id EFAD36B02A6
	for <linux-mm@kvack.org>; Wed, 11 Aug 2010 13:17:24 -0400 (EDT)
Date: Wed, 11 Aug 2010 10:18:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 03/10] Use percpu stats
Message-Id: <20100811101854.1dc3a510.akpm@linux-foundation.org>
In-Reply-To: <4C62D241.2040208@vflare.org>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>
	<1281374816-904-4-git-send-email-ngupta@vflare.org>
	<20100809213431.d7699d46.akpm@linux-foundation.org>
	<4C62D241.2040208@vflare.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Aug 2010 22:09:29 +0530 Nitin Gupta <ngupta@vflare.org> wrote:

> On 08/10/2010 10:04 AM, Andrew Morton wrote:
> > On Mon,  9 Aug 2010 22:56:49 +0530 Nitin Gupta <ngupta@vflare.org> wrote:
> > 
> >> +/*
> >> + * Individual percpu values can go negative but the sum across all CPUs
> >> + * must always be positive (we store various counts). So, return sum as
> >> + * unsigned value.
> >> + */
> >> +static u64 zram_get_stat(struct zram *zram, enum zram_stats_index idx)
> >>  {
> >> -	u64 val;
> >> -
> >> -	spin_lock(&zram->stat64_lock);
> >> -	val = *v;
> >> -	spin_unlock(&zram->stat64_lock);
> >> +	int cpu;
> >> +	s64 val = 0;
> >> +
> >> +	for_each_possible_cpu(cpu) {
> >> +		s64 temp;
> >> +		unsigned int start;
> >> +		struct zram_stats_cpu *stats;
> >> +
> >> +		stats = per_cpu_ptr(zram->stats, cpu);
> >> +		do {
> >> +			start = u64_stats_fetch_begin(&stats->syncp);
> >> +			temp = stats->count[idx];
> >> +		} while (u64_stats_fetch_retry(&stats->syncp, start));
> >> +		val += temp;
> >> +	}
> >>  
> >> +	WARN_ON(val < 0);
> >>  	return val;
> >>  }
> > 
> > That reimplements include/linux/percpu_counter.h, poorly.
> > 
> > Please see the June discussion "[PATCH v2 1/2] tmpfs: Quick token
> > library to allow scalable retrieval of tokens from token jar" for some
> > discussion.
> > 
> > 
> 
> I read the discussion you pointed out but still fail to see how percpu_counters,
> with all their overhead,

What overhead?  Send numbers.  Then extrapolate those numbers to a
machine which has 128 possible CPUs and 4 present CPUs.

> are better than simple pcpu variable used in current
> version. What is the advantage?

Firstly, they'd have saved all the time you spent duplicating them.

Secondly, getting additional users of the standard facility results in
more testing and perhaps enhancement of that facility, thus benefiting
other users too.

Thirdly, using the standard facility permits your code to leverage
enhancements which others add. 

Fourthly, they would result in a smaller kernel.

You didn't really need me to teach you the benefits of code reuse did
you?


Please do not merge this code unless there is a good reason to do so
and it has been shown that the standard facility cannot be suitably
fixed or enhanced to address the deficiency.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
