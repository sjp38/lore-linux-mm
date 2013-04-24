Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id BF8846B0032
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 15:09:24 -0400 (EDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
References: <20130410105608.GC1910@suse.de> <20130410131245.GC4862@thunk.org>
	<20130411170402.GB11656@suse.de> <20130411183512.GA12298@thunk.org>
	<20130411213335.GE9379@quack.suse.cz>
	<20130412025708.GB7445@thunk.org> <20130412045042.GA30622@dastard>
	<20130412151952.GA4944@thunk.org> <20130422143846.GA2675@suse.de>
	<x49a9oqmblc.fsf@segfault.boston.devel.redhat.com>
	<20130423140134.GA2108@suse.de>
Date: Wed, 24 Apr 2013 15:09:13 -0400
In-Reply-To: <20130423140134.GA2108@suse.de> (Mel Gorman's message of "Tue, 23
	Apr 2013 15:01:34 +0100")
Message-ID: <x49ppxjeofa.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

Mel Gorman <mgorman@suse.de> writes:

>> I'll also note that even though your I/O is going all over the place
>> (D2C is pretty bad, 14ms), most of the time is spent waiting for a
>> struct request allocation or between Queue and Merge:
>> 
>> ==================== All Devices ====================
>> 
>>             ALL           MIN           AVG           MAX           N
>> --------------- ------------- ------------- ------------- -----------
>> 
>> Q2Q               0.000000001   0.000992259   8.898375882     2300861
>> Q2G               0.000000843  10.193261239 2064.079501935     1016463 <====
>
> This is not normally my sandbox so do you mind spelling this out?
>
> IIUC, the time to allocate the struct request from the slab cache is just a
> small portion of this time. The bulk of the time is spent in get_request()
> waiting for congestion to clear on the request list for either the sync or
> async queue. Once a process goes to sleep on that waitqueue, it has to wait
> until enough requests on that queue have been serviced before it gets woken
> again at which point it gets priority access to prevent further starvation.
> This is the Queue To Get Reqiest (Q2G) delay. What we may be seeing here
> is that the async queue was congested and on average, we are waiting for
> 10 seconds for it to clear. The maximum value may be bogus for reasons
> explained later.
>
> Is that accurate?

Yes, without getting into excruciating detail.

>> G2I               0.000000461   0.000044702   3.237065090     1015803
>> Q2M               0.000000101   8.203147238 2064.079367557     1311662
>> I2D               0.000002012   1.476824812 2064.089774419     1014890
>> M2D               0.000003283   6.994306138 283.573348664     1284872
>> D2C               0.000061889   0.014438316   0.857811758     2291996
>> Q2C               0.000072284  13.363007244 2064.092228625     2292191
>> 
>> ==================== Device Overhead ====================
>> 
>>        DEV |       Q2G       G2I       Q2M       I2D       D2C
>> ---------- | --------- --------- --------- --------- ---------
>>  (  8,  0) |  33.8259%   0.0001%  35.1275%   4.8932%   0.1080%
>> ---------- | --------- --------- --------- --------- ---------
>>    Overall |  33.8259%   0.0001%  35.1275%   4.8932%   0.1080%
>> 
>> I'm not sure I believe that max value.  2064 seconds seems a bit high.
>
> It is so I looked closer at the timestamps and there is an one hour
> correction about 4400 seconds into the test.  Daylight savings time kicked
> in on March 31st and the machine is rarely rebooted until this test case
> came along. It looks like there is a timezone or time misconfiguration
> on the laptop that starts the machine with the wrong time. NTP must have
> corrected the time which skewed the readings in that window severely :(

Not sure I'm buying that argument, as there are no gaps in the blkparse
output.  The logging is not done using wallclock time.  I still haven't
had sufficient time to dig into these numbers.

>> Also, Q2M should not be anywhere near that big, so more investigation is
>> required there.  A quick look over the data doesn't show any such delays
>> (making me question the tools), but I'll write some code tomorrow to
>> verify the btt output.
>> 
>
> It might be a single set of readings during a time correction that
> screwed it.

Again, I don't think so.

> I can reproduce it at will. Due to the nature of the test, the test
> results are variable and unfortunately it is one of the tricker mmtest
> configurations to setup.
>
> 1. Get access to a webserver
> 2. Close mmtests to your test machine
>    git clone https://github.com/gormanm/mmtests.git
> 3. Edit shellpacks/common-config.sh and set WEBROOT to a webserver path
> 4. Create a tar.gz of a large git tree and place it at $WEBROOT/linux-2.6.tar.gz
>    Alternatively place a compressed git tree anywhere and edit
>    configs/config-global-dhp__io-multiple-source-latency
>    and update GITCHECKOUT_SOURCETAR
> 5. Create a tar.gz of a large maildir directory and place it at
>    $WEBROOT/$WEBROOT/maildir.tar.gz
>    Alternatively, use an existing maildir folder and set
>    MONITOR_INBOX_OPEN_MAILDIR in
>    configs/config-global-dhp__io-multiple-source-latency
>
> It's awkward but it's not like there are standard benchmarks lying around
> and it seemed the best way to reproduce the problems I typically see early
> in the lifetime of a system or when running a git checkout when the tree
> has not been used in a few hours. Run the actual test with
>
> ./run-mmtests.sh --config configs/config-global-dhp__io-multiple-source-latency --run-monitor test-name-of-your-choice
>
> Results will be in work/log. You'll need to run this as root so it
> can run blktrace and so it can drop_caches between git checkouts
> (to force disk IO). If systemtap craps out on you, then edit
> configs/config-global-dhp__io-multiple-source-latency and remove dstate
> from MONITORS_GZIP

And how do I determine whether I've hit the problem?

> If you have trouble getting this running, ping me on IRC.

Yes, I'm having issues getting things to go, but you didn't provide me a
time zone, an irc server or a nick to help me find you.  Was that
intentional?  ;-)

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
