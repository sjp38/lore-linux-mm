Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id AAA12900
	for <linux-mm@kvack.org>; Mon, 23 Sep 2002 00:43:31 -0700 (PDT)
Message-ID: <3D8EC621.9ACEF459@digeo.com>
Date: Mon, 23 Sep 2002 00:43:29 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.38-mm2
References: <3D8E96AA.C2FA7D8@digeo.com> <20020923071633.GA15479@suse.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <axboe@suse.de>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Jens Axboe wrote:
> 
> On Sun, Sep 22 2002, Andrew Morton wrote:
> > +read-latency.patch
> >
> >  Fix the writer-starves-reader elevator problem.  This is basically
> >  the read_latency2 patch from -ac kernels.
> >
> >  On IDE it provides a 100x improvement in read throughput when there
> >  is heavy writeback happening.  40x on SCSI.  You need to disable
> 
> Ah interesting. I do still think that it is worth to investigate _why_
> both elevator_linus and deadline does not prevent the read starvation.

I did.  See below.

> The read-latency is a hack, not a solution imo.

Well it clearly _is_ a solution.  To a grave problem.  But hopefully not
the best solution.  Really, this is just me saying "ouch".  This is
your stuff ;)

> >  tagged command queueing on scsi - it appears to be quite stupidly
> >  implemented.
> 
> Ahem I think you are being excessively harsh, or maybe passing judgement
> on something you haven't even looked at. Did you consider that you
> _drive_ may be the broken component? Excessive turn-around times for
> request when using deep tcq is not unusual, by far.

It's a Fujitsu SCA-2 thing.  Could be that other drive manufacturers
have a slight clue, but I doubt it.  I bet they just went and designed
the queueing for optimum throughput, with the assumption that reads 
and writes are muchly the same thing.

But they're not.  They are vastly different things.  Your fancy 2GHz
processor twiddles thumbs waiting for reads.  But not for writes.
The "hack" _recognises_ this fact - that reads are very different
things from writes.


Let's run the numbers.  128 slot write request queue.  512k writes.
30 mbyte/sec bandwidth.  That's two seconds worth of writes in the
request queue.

The reads have basically no chance of getting inserted between those
writes, so the first read has a two second latency, and that's before
adding in any of the passovers which additional writes will enjoy.

It works out that the latency per read is about three seconds.  I
have all the traces of this.

Now think about what userspace wants to do.  It reads a block from
the directory.  Three seconds.  Parse the directory, go read an
inode block.  Three seconds.  Go read the file.  Three seconds
if it's less than 56k.  Six seconds otherwise.

That's nine seconds since we read the directory block.  I'm running
with mem=192m.  So by now, the directory block has been reclaimed.

Move onto the next file.


So there is no bug or coding error present in the elevator.  Everything
is working as it is designed to. But a streaming write slows read
performance by a factor of 4000.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
