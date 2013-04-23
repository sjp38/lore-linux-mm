Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id D63846B0002
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 10:01:39 -0400 (EDT)
Date: Tue, 23 Apr 2013 15:01:34 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130423140134.GA2108@suse.de>
References: <20130410105608.GC1910@suse.de>
 <20130410131245.GC4862@thunk.org>
 <20130411170402.GB11656@suse.de>
 <20130411183512.GA12298@thunk.org>
 <20130411213335.GE9379@quack.suse.cz>
 <20130412025708.GB7445@thunk.org>
 <20130412045042.GA30622@dastard>
 <20130412151952.GA4944@thunk.org>
 <20130422143846.GA2675@suse.de>
 <x49a9oqmblc.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <x49a9oqmblc.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

On Mon, Apr 22, 2013 at 06:42:23PM -0400, Jeff Moyer wrote:
> > 3. The blktrace indicates that reads can starve writes from flusher
> >
> >    While there are people that can look at a blktrace and find problems
> >    like they are rain man, I'm more like an ADHD squirrel when looking at
> >    a trace.  I wrote a script to look for what unrelated requests completed
> >    while an request got stalled for over a second. It seemed like something
> >    that a tool shoudl already exist for but I didn't find one unless btt
> >    can give the information somehow.
> 
> Care to share that script?
> 

I would have preferred not to because it is an ugly hatchet job churned
out in a few minutes. It's written in perl and uses the text output from
blkparse making it slow. It uses an excessive amount of memory because I was
taking shortcuts so is resource heavy. It ignores most of the information
from blkparse and so there are gaps in what it reports. Even though it's
dogshit, it was useful in this particular case so I added it to mmtests
anyway. Be aware that it takes ages to run and you might want to break
the blkparse output into pieces

It's used something like

blkparse -i blktrace-log > blkparse-log
cat blkparse-log | $PATH_TO_MMTESTS/subreport/blktrace-queue-watch.pl

> [snip]
> 
> > I recognise that the output will have a WTF reaction but the key
> > observations to me are
> >
> > a) a single write request from flusher took over a second to complete
> > b) at the time it was queued, it was mostly other writes that were in
> >    the queue at the same time
> > c) The write request and the parallel writes were all asynchronous write
> >    requests
> > D) at the time the request completed, there were a LARGE number of
> >    other requested queued and completed at the same time.
> >
> > Of the requests queued and completed in the meantime the breakdown was
> >
> >      22 RM
> >      31 RA
> >      82 W
> >     445 R
> >
> > If I'm reading this correctly, it is saying that 22 reads were merged (RM),
> > 31 reads were remapped to another device (RA) which is probably reads from
> > the dm-crypt partition, 82 were writes (W) which is not far off the number
> > of writes that were in the queue and 445 were other reads. The delay was
> > dominated by reads that were queued after the write request and completed
> > before it.
> 
> RM == Read Meta
> RA == Read Ahead  (remapping, by the way, does not happen across
>                    devices, just into partitions)
> W and R you understood correctly.
> 

Thanks for those corrections. I misread the meaning of the action
identifiers section of the blkparse manual. I should have double checked
the source.

> >> <SNIP>
> >> The thing is, we do want to make ext4 work well with cfq, and
> >> prioritizing non-readahead read requests ahead of data writeback does
> >> make sense.  The issue is with is that metadata writes going through
> >> the block device could in some cases effectively cause a priority
> >> inversion when what had previously been an asynchronous writeback
> >> starts blocking a foreground, user-visible process.
> >> 
> >> At least, that's the theory;
> >
> > I *think* the data more or less confirms the theory but it'd be nice if
> > someone else double checked in case I'm seeing what I want to see
> > instead of what is actually there.
> 
> Looks sane.  You can also see a lot of "preempt"s in the blkparse
> output, which indicates exactly what you're saying.  Any sync request
> gets priority over the async requests.
> 

Good to know.

> I'll also note that even though your I/O is going all over the place
> (D2C is pretty bad, 14ms), most of the time is spent waiting for a
> struct request allocation or between Queue and Merge:
> 
> ==================== All Devices ====================
> 
>             ALL           MIN           AVG           MAX           N
> --------------- ------------- ------------- ------------- -----------
> 
> Q2Q               0.000000001   0.000992259   8.898375882     2300861
> Q2G               0.000000843  10.193261239 2064.079501935     1016463 <====

This is not normally my sandbox so do you mind spelling this out?

IIUC, the time to allocate the struct request from the slab cache is just a
small portion of this time. The bulk of the time is spent in get_request()
waiting for congestion to clear on the request list for either the sync or
async queue. Once a process goes to sleep on that waitqueue, it has to wait
until enough requests on that queue have been serviced before it gets woken
again at which point it gets priority access to prevent further starvation.
This is the Queue To Get Reqiest (Q2G) delay. What we may be seeing here
is that the async queue was congested and on average, we are waiting for
10 seconds for it to clear. The maximum value may be bogus for reasons
explained later.

Is that accurate?

> G2I               0.000000461   0.000044702   3.237065090     1015803
> Q2M               0.000000101   8.203147238 2064.079367557     1311662
> I2D               0.000002012   1.476824812 2064.089774419     1014890
> M2D               0.000003283   6.994306138 283.573348664     1284872
> D2C               0.000061889   0.014438316   0.857811758     2291996
> Q2C               0.000072284  13.363007244 2064.092228625     2292191
> 
> ==================== Device Overhead ====================
> 
>        DEV |       Q2G       G2I       Q2M       I2D       D2C
> ---------- | --------- --------- --------- --------- ---------
>  (  8,  0) |  33.8259%   0.0001%  35.1275%   4.8932%   0.1080%
> ---------- | --------- --------- --------- --------- ---------
>    Overall |  33.8259%   0.0001%  35.1275%   4.8932%   0.1080%
> 
> I'm not sure I believe that max value.  2064 seconds seems a bit high.

It is so I looked closer at the timestamps and there is an one hour
correction about 4400 seconds into the test.  Daylight savings time kicked
in on March 31st and the machine is rarely rebooted until this test case
came along. It looks like there is a timezone or time misconfiguration
on the laptop that starts the machine with the wrong time. NTP must have
corrected the time which skewed the readings in that window severely :(

Normally on my test machines these services are disabled to avoid
exactly this sort of problem.

> Also, Q2M should not be anywhere near that big, so more investigation is
> required there.  A quick look over the data doesn't show any such delays
> (making me question the tools), but I'll write some code tomorrow to
> verify the btt output.
> 

It might be a single set of readings during a time correction that
screwed it.

> Jan, if I were to come up with a way of promoting a particular async
> queue to the front of the line, where would I put such a call in the
> ext4/jbd2 code to be effective?
> 
> Mel, can you reproduce this at will?  Do you have a reproducer that I
> could run so I'm not constantly bugging you?
> 

I can reproduce it at will. Due to the nature of the test, the test
results are variable and unfortunately it is one of the tricker mmtest
configurations to setup.

1. Get access to a webserver
2. Close mmtests to your test machine
   git clone https://github.com/gormanm/mmtests.git
3. Edit shellpacks/common-config.sh and set WEBROOT to a webserver path
4. Create a tar.gz of a large git tree and place it at $WEBROOT/linux-2.6.tar.gz
   Alternatively place a compressed git tree anywhere and edit
   configs/config-global-dhp__io-multiple-source-latency
   and update GITCHECKOUT_SOURCETAR
5. Create a tar.gz of a large maildir directory and place it at
   $WEBROOT/$WEBROOT/maildir.tar.gz
   Alternatively, use an existing maildir folder and set
   MONITOR_INBOX_OPEN_MAILDIR in
   configs/config-global-dhp__io-multiple-source-latency

It's awkward but it's not like there are standard benchmarks lying around
and it seemed the best way to reproduce the problems I typically see early
in the lifetime of a system or when running a git checkout when the tree
has not been used in a few hours. Run the actual test with

./run-mmtests.sh --config configs/config-global-dhp__io-multiple-source-latency --run-monitor test-name-of-your-choice

Results will be in work/log. You'll need to run this as root so it
can run blktrace and so it can drop_caches between git checkouts
(to force disk IO). If systemtap craps out on you, then edit
configs/config-global-dhp__io-multiple-source-latency and remove dstate
from MONITORS_GZIP

If you have trouble getting this running, ping me on IRC.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
