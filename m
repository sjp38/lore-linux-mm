Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 6FC9F6B004F
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 11:21:40 -0500 (EST)
Date: Fri, 27 Jan 2012 10:21:36 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 6/9] readahead: add /debug/readahead/stats
In-Reply-To: <20120127031327.159293683@intel.com>
Message-ID: <alpine.DEB.2.00.1201271006480.16756@router.home>
References: <20120127030524.854259561@intel.com> <20120127031327.159293683@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Fri, 27 Jan 2012, Wu Fengguang wrote:

> +
> +#define RA_STAT_BATCH	(INT_MAX / 2)
> +static struct percpu_counter ra_stat[RA_PATTERN_ALL][RA_ACCOUNT_MAX];

Why use percpu counter here? The stats structures are not dynamically
allocated so you can just use a DECLARE_PER_CPU statement. That way you do
not have the overhead of percpu counter calls. Instead simple instructions
are generated to deal with the counter.

There are also no calls to any of the fast access functions for percpu
counter so percpu_counter has to always having to loop over all
counters anyways to get the results. The batching of the percpu_counters
is therefore not used.

Its simpler to just do a loop that sums over all counters when displaying
the results.

> +static inline void add_ra_stat(int i, int j, s64 amount)
> +{
> +	__percpu_counter_add(&ra_stat[i][j], amount, RA_STAT_BATCH);

	__this_cpu_add(ra_stat[i][j], amount);

> +}

> +
> +static void readahead_stats_reset(void)
> +{
> +	int i, j;
> +
> +	for (i = 0; i < RA_PATTERN_ALL; i++)
> +		for (j = 0; j < RA_ACCOUNT_MAX; j++)
> +			percpu_counter_set(&ra_stat[i][j], 0);

for_each_online(cpu)
	memset(per_cpu_ptr(&ra_stat, cpu), 0, sizeof(ra_stat));

> +}
> +
> +static void
> +readahead_stats_sum(long long ra_stats[RA_PATTERN_MAX][RA_ACCOUNT_MAX])
> +{
> +	int i, j;
> +
> +	for (i = 0; i < RA_PATTERN_ALL; i++)
> +		for (j = 0; j < RA_ACCOUNT_MAX; j++) {
> +			s64 n = percpu_counter_sum(&ra_stat[i][j]);
> +			ra_stats[i][j] += n;
> +			ra_stats[RA_PATTERN_ALL][j] += n;
> +		}
> +}

Define a function stats instead?

static long get_stat_sum(long __per_cpu *x)
{
	int cpu;
	long sum;

	for_each_online(cpu)
		sum += *per_cpu_ptr(x, cpu);

	return sum;
}

> +
> +static int readahead_stats_show(struct seq_file *s, void *_)
> +{

> +	readahead_stats_sum(ra_stats);
> +
> +	for (i = 0; i < RA_PATTERN_MAX; i++) {
> +		unsigned long count = ra_stats[i][RA_ACCOUNT_COUNT];

			= get_stats(&ra_stats[i][RA_ACCOUNT]);

...

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
