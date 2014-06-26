Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 474EF6B009C
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 13:45:18 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id q59so4063192wes.26
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 10:45:17 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lv17si10217916wic.36.2014.06.26.10.45.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Jun 2014 10:45:11 -0700 (PDT)
Date: Thu, 26 Jun 2014 18:45:00 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 6/6] cfq: Increase default value of target_latency
Message-ID: <20140626174500.GI10819@suse.de>
References: <1403683129-10814-1-git-send-email-mgorman@suse.de>
 <1403683129-10814-7-git-send-email-mgorman@suse.de>
 <x491tub65t9.fsf@segfault.boston.devel.redhat.com>
 <20140626161955.GH10819@suse.de>
 <x49simr4ntz.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <x49simr4ntz.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>, Dave Chinner <david@fromorbit.com>

On Thu, Jun 26, 2014 at 12:50:32PM -0400, Jeff Moyer wrote:
> Mel Gorman <mgorman@suse.de> writes:
> 
> > On Thu, Jun 26, 2014 at 11:36:50AM -0400, Jeff Moyer wrote:
> >> Right, and I guess I hadn't considered that case as I thought folks used
> >> more than one spinning disk for such workloads.
> >> 
> >
> > They probably are but by and large my IO testing is based on simple
> > storage. The reasoning is that if we get the simple case wrong then we
> > probably are getting the complex case wrong too or at least not performing
> > as well as we should. I also don't use SSD on my own machines for the
> > same reason.
> 
> A single disk is actually the hard case in this instance, but I
> understand what you're saying.  ;-)
> 
> >> My main reservation about this change is that you've only provided
> >> numbers for one benchmark. 
> >
> > The other obvious one to run would be pgbench workloads but it's a rathole of
> > arguing whether the configuration is valid and whether it's inappropriate
> > to test on simple storage. The tiobench tests alone take a long time to
> > complete -- 1.5 hours on a simple machine, 7 hours on a low-end NUMA machine.
> 
> And we should probably run our standard set of I/O exercisers at the
> very least.  But, like I said, it seems like wasted effort.
> 

Out of curiousity, what do you consider to be the standard set of I/O
exercisers? I have a whole battery of them that are run against major
releases to track performance over time -- tiobench (it's stupid, but too
many people use it), fsmark used in various configurations (single/multi
threaded, zero-sized and large files), postmark (file sizes fairly
small, working set 2xRAM), bonnie++ (2xRAM), ffsb used in a mail server
configuration (taken from btrfs tests), dbench3 (checking in-memory updates,
not a realistic IO benchmark), dbench4 (bit more realistic although high
thread counts it gets silly and overall it's not a stable predictor of
performance), sysbench in various configurations, pgbench used in limited
configurations, stutter which tends to hit the worse-case interactivity
issues experienced on desktops and kernel builds are the main ones. It
takes days to churn through the full set of tests which is why I don't do
it for a patch series.  I selected tiobench this time because it was the
most reliable test to cover both single and multiple-sources-of-IO cases.
If I merge a major change I'll usually then watch the next major release
and double check that nothing else broke.

> >> To bump the default target_latency, ideally
> >> we'd know how it affects other workloads.  However, I'm having a hard
> >> time justifying putting any time into this for a couple of reasons:
> >> 1) blk-mq pretty much does away with the i/o scheduler, and that is the
> >>    future
> >> 2) there is work in progress to convert cfq into bfq, and that will
> >>    essentially make any effort put into this irrelevant (so it might be
> >>    interesting to test your workload with bfq)
> >> 
> >
> > Ok, you've convinced me and I'll drop this patch. For anyone based on
> > kernels from around this time they can tune CFQ or buy a better disk.
> > Hopefully they will find this via Google.
> 
> Funny, I wasn't weighing in against your patch.  I was merely indicating
> that I personally wasn't going to invest the time to validate it.  But,
> if you're ok with dropping it, that's obviously fine with me.
> 

I fear the writing is on the wall that it'll never pass the "have you
tested every workload" test and no matter what a counter-example will be
found where it's the wrong setting. If CFQ is going to be irrelevant soon
it's just not worth wasting the electricity against a mainline kernel.

I'm still interested in what you consider your standard set of IO exercisers
though because I can slot any missing parts into the tests that run for
every mainline release.

The main one I'm missing is the postgres folks fsync benchmark. I wrote
the automation months ago but never activated it because there are enough
known problems already.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
