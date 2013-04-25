Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 9308C6B0032
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 08:21:16 -0400 (EDT)
Date: Thu, 25 Apr 2013 13:21:11 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130425122111.GE2144@suse.de>
References: <20130411170402.GB11656@suse.de>
 <20130411183512.GA12298@thunk.org>
 <20130411213335.GE9379@quack.suse.cz>
 <20130412025708.GB7445@thunk.org>
 <20130412045042.GA30622@dastard>
 <20130412151952.GA4944@thunk.org>
 <20130422143846.GA2675@suse.de>
 <x49a9oqmblc.fsf@segfault.boston.devel.redhat.com>
 <20130423140134.GA2108@suse.de>
 <x49ppxjeofa.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <x49ppxjeofa.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

On Wed, Apr 24, 2013 at 03:09:13PM -0400, Jeff Moyer wrote:
> Mel Gorman <mgorman@suse.de> writes:
> 
> >> I'll also note that even though your I/O is going all over the place
> >> (D2C is pretty bad, 14ms), most of the time is spent waiting for a
> >> struct request allocation or between Queue and Merge:
> >> 
> >> ==================== All Devices ====================
> >> 
> >>             ALL           MIN           AVG           MAX           N
> >> --------------- ------------- ------------- ------------- -----------
> >> 
> >> Q2Q               0.000000001   0.000992259   8.898375882     2300861
> >> Q2G               0.000000843  10.193261239 2064.079501935     1016463 <====
> >
> > This is not normally my sandbox so do you mind spelling this out?
> >
> > IIUC, the time to allocate the struct request from the slab cache is just a
> > small portion of this time. The bulk of the time is spent in get_request()
> > waiting for congestion to clear on the request list for either the sync or
> > async queue. Once a process goes to sleep on that waitqueue, it has to wait
> > until enough requests on that queue have been serviced before it gets woken
> > again at which point it gets priority access to prevent further starvation.
> > This is the Queue To Get Reqiest (Q2G) delay. What we may be seeing here
> > is that the async queue was congested and on average, we are waiting for
> > 10 seconds for it to clear. The maximum value may be bogus for reasons
> > explained later.
> >
> > Is that accurate?
> 
> Yes, without getting into excruciating detail.


Good enough, thanks.

> >> I'm not sure I believe that max value.  2064 seconds seems a bit high.
> >
> > It is so I looked closer at the timestamps and there is an one hour
> > correction about 4400 seconds into the test.  Daylight savings time kicked
> > in on March 31st and the machine is rarely rebooted until this test case
> > came along. It looks like there is a timezone or time misconfiguration
> > on the laptop that starts the machine with the wrong time. NTP must have
> > corrected the time which skewed the readings in that window severely :(
> 
> Not sure I'm buying that argument, as there are no gaps in the blkparse
> output.  The logging is not done using wallclock time.  I still haven't
> had sufficient time to dig into these numbers.
> 

Ok.

> > It's awkward but it's not like there are standard benchmarks lying around
> > and it seemed the best way to reproduce the problems I typically see early
> > in the lifetime of a system or when running a git checkout when the tree
> > has not been used in a few hours. Run the actual test with
> >
> > ./run-mmtests.sh --config configs/config-global-dhp__io-multiple-source-latency --run-monitor test-name-of-your-choice
> >
> > Results will be in work/log. You'll need to run this as root so it
> > can run blktrace and so it can drop_caches between git checkouts
> > (to force disk IO). If systemtap craps out on you, then edit
> > configs/config-global-dhp__io-multiple-source-latency and remove dstate
> > from MONITORS_GZIP
> 
> And how do I determine whether I've hit the problem?
> 

If systemtap is available then

cat work/log/dstate-TESTNAME-gitcheckout | subreport/stap-dstate-frequency

will give you a report on the worst stalls and the stack traces when those
stalls occurred. If the stalls are 10+ seconds then you've certainly hit
the problem.

Alternatively

cd work/log
../../compare-kernels.sh

Look at the average time it takes to run the git checkout. Is it
abnormally high in comparison to if there was no parallel IO? If you do
not know what the normal time is, run with

./run-mmtests.sh --config configs/config-global-dhp__io-multiple-source-latency --no-monitor test-name-no-monitor

The monitors are what's opening the maildir and generating the parallel
IO. If there is an excessive difference between the git checkout times,
then you've hit the problem.

Furthermore, look at the await times. If they do not appear in the
compare-kernels.sh output then

../../bin/compare-mmtests.pl -d . -b gitcheckout -n test-name-of-your-choice --print-monitor iostat

And look at the await times. Are they very high? If so, you hit the
problem. If you want a better look at the await figures over time,
either look at the iostat file or you can graph it with

../../bin/graph-mmtests.sh -d . -b gitcheckout -n test-name-of-your-choice --print-monitor iostat --sub-heading sda-await

where sda-await should be  substituted for whatever the disk is that
you're running the test one.


> > If you have trouble getting this running, ping me on IRC.
> 
> Yes, I'm having issues getting things to go, but you didn't provide me a
> time zone, an irc server or a nick to help me find you.  Was that
> intentional?  ;-)
> 

Not consciously :) . I'm in the IST timezone (GMT+1), OFTC IRC network
and #mm channel. If it's my evening I'm not always responsive so send me
the error output on email and I'll try fixing any problems that way.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
