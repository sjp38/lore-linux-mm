Message-ID: <3B218BA8.6A8C2EB0@uow.edu.au>
Date: Sat, 09 Jun 2001 12:36:24 +1000
From: Andrew Morton <andrewm@uow.edu.au>
MIME-Version: 1.0
Subject: Re: VM Report was:Re: Break 2.4 VM in five easy steps
References: <Pine.LNX.4.21.0106081701300.2422-100000@freak.distro.conectiva>,
		<15137.15472.264539.290588@gargle.gargle.HOWL> <l0313032bb7471092da13@[192.168.239.105]>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jonathan Morton wrote:
> 
> [ Re-entering discussion after too long a day and a long sleep... ]
> 
> >> There is the problem in terms of some people want pure interactive
> >> performance, while others are looking for throughput over all else,
> >> but those are both extremes of the spectrum.  Though I suspect
> >> raw throughput is the less wanted (in terms of numbers of systems)
> >> than keeping interactive response good during VM pressure.
> >
> >And this raises a very very important point: raw throughtput wins
> >enterprise-like benchmarks, and the enterprise people are the ones who pay
> >most of hackers here. (including me and Rik)
> 
> Very true.  As well as the fact that interactivity is much harder to
> measure.  The question is, what is interactivity (from the kernel's
> perspective)?  It usually means small(ish) processes with intermittent
> working-set and CPU requirements.  These types of process can safely be
> swapped out when not immediately in use, but the kernel has to be able to
> page them in quite quickly when needed.  Doing that under heavy load is
> very non-trivial.

For the low-latency stuff, latency can be defined as
the worst-case time to schedule a userspace process in
response to an interrupt.

That metric is also appropriate in this case, (latency equals
interactivity), although here you don't need to be so fanatical
about the *worst case*.  A few scheduling blips here are less
fatal.

I have tools to measure latency (aka interactivity).  At
http://www.uow.edu.au/~andrewm/linux/schedlat.html#downloads
there is a kernel patch called `rtc-debug' which causes
the PC RTC to generate a stream of interrupts.  A user-space
task called `amlat' responds to those interrupts and
reads the RTC device.  The patched RTC driver can then
measure the elapsed time between the interrupt and the
read from userspace.  Voila: latency.

When you close the RTC device (by killing amlat), the RTC
driver will print out a histogram of the latencies.

`amlat' at present gives itself SCHED_RR policy and
runs under mlockall() - for your testing you'll need
to delete those lines.

So.  Simple apply rtc-debug, run `amlat' and kill it
when you've finished the workload.

The challenge will be to relate the latency histogram
to human-perceived interactivity.   I'm not sure of
the best way of doing that.  Perhaps monitor the 90th
percentile, and aim to keep it below 100 milliseconds.
Also, `amlat' should do a bit of disk I/O as well.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
