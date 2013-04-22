Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 7E3F96B0002
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 18:42:34 -0400 (EDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
References: <20130402142717.GH32241@suse.de>
	<20130402150651.GB31577@thunk.org> <20130410105608.GC1910@suse.de>
	<20130410131245.GC4862@thunk.org> <20130411170402.GB11656@suse.de>
	<20130411183512.GA12298@thunk.org>
	<20130411213335.GE9379@quack.suse.cz>
	<20130412025708.GB7445@thunk.org> <20130412045042.GA30622@dastard>
	<20130412151952.GA4944@thunk.org> <20130422143846.GA2675@suse.de>
Date: Mon, 22 Apr 2013 18:42:23 -0400
In-Reply-To: <20130422143846.GA2675@suse.de> (Mel Gorman's message of "Mon, 22
	Apr 2013 15:38:46 +0100")
Message-ID: <x49a9oqmblc.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

Mel Gorman <mgorman@suse.de> writes:

> (Adding Jeff Moyer to the cc as I'm told he is interested in the blktrace)

Thanks.  I've got a few comments and corrections for you below.

> TLDR: Flusher writes pages very quickly after processes dirty a buffer. Reads
> starve flusher writes.
[snip]

> 3. The blktrace indicates that reads can starve writes from flusher
>
>    While there are people that can look at a blktrace and find problems
>    like they are rain man, I'm more like an ADHD squirrel when looking at
>    a trace.  I wrote a script to look for what unrelated requests completed
>    while an request got stalled for over a second. It seemed like something
>    that a tool shoudl already exist for but I didn't find one unless btt
>    can give the information somehow.

Care to share that script?

[snip]

> I recognise that the output will have a WTF reaction but the key
> observations to me are
>
> a) a single write request from flusher took over a second to complete
> b) at the time it was queued, it was mostly other writes that were in
>    the queue at the same time
> c) The write request and the parallel writes were all asynchronous write
>    requests
> D) at the time the request completed, there were a LARGE number of
>    other requested queued and completed at the same time.
>
> Of the requests queued and completed in the meantime the breakdown was
>
>      22 RM
>      31 RA
>      82 W
>     445 R
>
> If I'm reading this correctly, it is saying that 22 reads were merged (RM),
> 31 reads were remapped to another device (RA) which is probably reads from
> the dm-crypt partition, 82 were writes (W) which is not far off the number
> of writes that were in the queue and 445 were other reads. The delay was
> dominated by reads that were queued after the write request and completed
> before it.

RM == Read Meta
RA == Read Ahead  (remapping, by the way, does not happen across
                   devices, just into partitions)
W and R you understood correctly.

> That's saying that the 27128th request in the trace took over 7 seconds
> to complete and was an asynchronous write from flusher. The contents of
> the queue are displayed at that time and the breakdown of requests is
>
>      23 WS  [JEM: write sync]
>      86 RM  [JEM: Read Meta]
>     124 RA  [JEM: Read Ahead]
>     442 W
>    1931 R
>
> 7 seconds later when it was completed the breakdown of completed
> requests was
>
>      25 WS
>     114 RM
>     155 RA
>     408 W
>    2457 R
>
> In combination, that confirms for me that asynchronous writes from flush
> are being starved by reads. When a process requires a buffer that is locked
> by that asynchronous write from flusher, it stalls.
>
>> The thing is, we do want to make ext4 work well with cfq, and
>> prioritizing non-readahead read requests ahead of data writeback does
>> make sense.  The issue is with is that metadata writes going through
>> the block device could in some cases effectively cause a priority
>> inversion when what had previously been an asynchronous writeback
>> starts blocking a foreground, user-visible process.
>> 
>> At least, that's the theory;
>
> I *think* the data more or less confirms the theory but it'd be nice if
> someone else double checked in case I'm seeing what I want to see
> instead of what is actually there.

Looks sane.  You can also see a lot of "preempt"s in the blkparse
output, which indicates exactly what you're saying.  Any sync request
gets priority over the async requests.

I'll also note that even though your I/O is going all over the place
(D2C is pretty bad, 14ms), most of the time is spent waiting for a
struct request allocation or between Queue and Merge:

==================== All Devices ====================

            ALL           MIN           AVG           MAX           N
--------------- ------------- ------------- ------------- -----------

Q2Q               0.000000001   0.000992259   8.898375882     2300861
Q2G               0.000000843  10.193261239 2064.079501935     1016463 <====
G2I               0.000000461   0.000044702   3.237065090     1015803
Q2M               0.000000101   8.203147238 2064.079367557     1311662
I2D               0.000002012   1.476824812 2064.089774419     1014890
M2D               0.000003283   6.994306138 283.573348664     1284872
D2C               0.000061889   0.014438316   0.857811758     2291996
Q2C               0.000072284  13.363007244 2064.092228625     2292191

==================== Device Overhead ====================

       DEV |       Q2G       G2I       Q2M       I2D       D2C
---------- | --------- --------- --------- --------- ---------
 (  8,  0) |  33.8259%   0.0001%  35.1275%   4.8932%   0.1080%
---------- | --------- --------- --------- --------- ---------
   Overall |  33.8259%   0.0001%  35.1275%   4.8932%   0.1080%

I'm not sure I believe that max value.  2064 seconds seems a bit high.
Also, Q2M should not be anywhere near that big, so more investigation is
required there.  A quick look over the data doesn't show any such delays
(making me question the tools), but I'll write some code tomorrow to
verify the btt output.

Jan, if I were to come up with a way of promoting a particular async
queue to the front of the line, where would I put such a call in the
ext4/jbd2 code to be effective?

Mel, can you reproduce this at will?  Do you have a reproducer that I
could run so I'm not constantly bugging you?

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
