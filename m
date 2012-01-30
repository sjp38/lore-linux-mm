Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id E3E186B004D
	for <linux-mm@kvack.org>; Sun, 29 Jan 2012 23:02:43 -0500 (EST)
Date: Mon, 30 Jan 2012 15:02:39 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 6/9] readahead: add /debug/readahead/stats
Message-ID: <20120130040239.GB9090@dastard>
References: <20120127030524.854259561@intel.com>
 <20120127031327.159293683@intel.com>
 <alpine.DEB.2.00.1201271006480.16756@router.home>
 <20120127121551.acd256aa.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120127121551.acd256aa.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Jan 27, 2012 at 12:15:51PM -0800, Andrew Morton wrote:
> On Fri, 27 Jan 2012 10:21:36 -0600 (CST)
> Christoph Lameter <cl@linux.com> wrote:
> 
> > > +
> > > +static void readahead_stats_reset(void)
> > > +{
> > > +	int i, j;
> > > +
> > > +	for (i = 0; i < RA_PATTERN_ALL; i++)
> > > +		for (j = 0; j < RA_ACCOUNT_MAX; j++)
> > > +			percpu_counter_set(&ra_stat[i][j], 0);
> > 
> > for_each_online(cpu)
> > 	memset(per_cpu_ptr(&ra_stat, cpu), 0, sizeof(ra_stat));
> 
> for_each_possible_cpu().  And that's one reason to not open-code the
> operation.  Another is so we don't have tiresome open-coded loops all
> over the place.

Amen, brother!

> But before doing either of those things we should choose boring old
> atomic_inc().  Has it been shown that the cost of doing so is
> unacceptable?  Bearing this in mind:

atomics for stats in the IO path have long been known not to scale
well enough - especially now we have PCIe SSDs that can do hundreds
of thousands of reads per second if you have enough CPU concurrency
to drive them that hard. Under that sort of workload, atomics won't
scale.

> 
> > The accounting code will be compiled in by default
> > (CONFIG_READAHEAD_STATS=y), and will remain inactive by default.
> 
> I agree with those choices.  They effectively mean that the stats will
> be a developer-only/debugger-only thing.  So even if the atomic_inc()
> costs are measurable during these develop/debug sessions, is anyone
> likely to care?

I do.  If I need the debugging stats, the overhead must not perturb
the behaviour I'm trying to understand/debug for them to be
useful....

Cheers,

Dave.

-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
