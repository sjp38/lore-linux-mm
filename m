Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 0BC456B004D
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 15:15:52 -0500 (EST)
Date: Fri, 27 Jan 2012 12:15:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 6/9] readahead: add /debug/readahead/stats
Message-Id: <20120127121551.acd256aa.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1201271006480.16756@router.home>
References: <20120127030524.854259561@intel.com>
	<20120127031327.159293683@intel.com>
	<alpine.DEB.2.00.1201271006480.16756@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Fri, 27 Jan 2012 10:21:36 -0600 (CST)
Christoph Lameter <cl@linux.com> wrote:

> > +
> > +static void readahead_stats_reset(void)
> > +{
> > +	int i, j;
> > +
> > +	for (i = 0; i < RA_PATTERN_ALL; i++)
> > +		for (j = 0; j < RA_ACCOUNT_MAX; j++)
> > +			percpu_counter_set(&ra_stat[i][j], 0);
> 
> for_each_online(cpu)
> 	memset(per_cpu_ptr(&ra_stat, cpu), 0, sizeof(ra_stat));

for_each_possible_cpu().  And that's one reason to not open-code the
operation.  Another is so we don't have tiresome open-coded loops all
over the place.

But before doing either of those things we should choose boring old
atomic_inc().  Has it been shown that the cost of doing so is
unacceptable?  Bearing this in mind:

> The accounting code will be compiled in by default
> (CONFIG_READAHEAD_STATS=y), and will remain inactive by default.

I agree with those choices.  They effectively mean that the stats will
be a developer-only/debugger-only thing.  So even if the atomic_inc()
costs are measurable during these develop/debug sessions, is anyone
likely to care?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
