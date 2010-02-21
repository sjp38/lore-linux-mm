Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 063E66B0047
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 21:26:31 -0500 (EST)
Date: Sun, 21 Feb 2010 10:25:25 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 03/11] readahead: bump up the default readahead size
Message-ID: <20100221022525.GA6448@localhost>
References: <20100207041013.891441102@intel.com> <20100207041043.147345346@intel.com> <4B6FBB3F.4010701@linux.vnet.ibm.com> <20100208134634.GA3024@localhost> <1265924254.15603.79.camel@calx> <20100211234249.GE407@shareable.org> <20100212135949.GA22686@localhost> <1266006023.15603.661.camel@calx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1266006023.15603.661.camel@calx>
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: Jamie Lokier <jamie@shareable.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, David Woodhouse <dwmw2@infradead.org>, "linux-embedded@vger.kernel.org" <linux-embedded@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Matt,

On Sat, Feb 13, 2010 at 04:20:23AM +0800, Matt Mackall wrote:
> On Fri, 2010-02-12 at 21:59 +0800, Wu Fengguang wrote:
> > On Fri, Feb 12, 2010 at 07:42:49AM +0800, Jamie Lokier wrote:
> > > Matt Mackall wrote:
> > > > On Mon, 2010-02-08 at 21:46 +0800, Wu Fengguang wrote:
> > > > > Chris,
> > > > > 
> > > > > Firstly inform the linux-embedded maintainers :)
> > > > > 
> > > > > I think it's a good suggestion to add a config option
> > > > > (CONFIG_READAHEAD_SIZE). Will update the patch..
> > > > 
> > > > I don't have a strong opinion here beyond the nagging feeling that we
> > > > should be using a per-bdev scaling window scheme rather than something
> > > > static.
> > 
> > It's good to do dynamic scaling -- in fact this patchset has code to do
> > - scale down readahead size (per-bdev) for small devices
> 
> I'm not sure device size is a great metric. It's only weakly correlated

Yes, it's only weakly correlated. However device size is a good metric
in itself -- when it's small, ie. Linus' 500KB sized USB device.

> with the things we actually care about: memory pressure (small devices
> are often attached to systems with small and therefore full memory) and
> latency (small devices are often old and slow and attached to slow
> CPUs). I think we should instead use hints about latency (large request
> queues) and memory pressure (reclaim passes) directly.

In principle I think it's OK to use memory pressure and IO latency as hints.

1) memory pressure

For read-ahead, the memory pressure is mainly readahead buffers
consumed by too many concurrent streams. The context readahead in this
patchset can adapt readahead size to thrashing threshold well.  So in
principle we don't need to adapt the default _max_ read-ahead size to
memory pressure.

For read-around, the memory pressure is mainly read-around misses on
executables/libraries. Which could be reduced by scaling down
read-around size on fast "reclaim passes".

The more straightforward solution could be to limit default
read-around size proportional to available system memory, ie.
                512MB mem => 512KB read-around size
                128MB mem => 128KB read-around size
                 32MB mem =>  32KB read-around size (minimal)

2) IO latency

We might estimate the average service time and throughput for IOs of
different size, and choose the default readahead size based on
- good throughput
- low service time
- reasonable size bounds

IMHO the estimation should reflect the nature of the device, and do
not depend on specific workloads. Some points:

- in most cases, reducing readahead size on large request queues
  (which is typical in large file servers) only hurts performance
- we don't know whether the application is latency-sensitive (and to
  what degree), hence no need to be over-zealous to optimize for latency
- a dynamic changing readahead size is nightmare to benchmarks

That means to avoid estimation when there are any concurrent
reads/writes.  It also means that the estimation can be turned off for
this boot after enough data have been collected and the averages go
stable.

> > - scale down readahead size (per-stream) to thrashing threshold
> 
> Yeah, I'm happy to call that part orthogonal to this discussion.
> 
> > At the same time, I'd prefer
> > - to _only_ do scale down (below the default size) for low end
> > - and have a uniform default readahead size for the mainstream
> 
> I don't think that's important, given that we're dynamically fiddling
> with related things.

Before we can dynamically tune things and do it smart enough, it would
be good to have clear rules :)

> > IMHO scaling up automatically
> > - would be risky
> 
> What, explicitly, are the risks? If we bound the window with memory

Risks could be readahead misses and higher latency. 
Generally the risk:perf_gain ratio goes up for larger readahead size.

> pressure and latency, I don't think it can get too far out of hand.
> There are also some other bounds in here: we have other limits on how
> big I/O requests can be.

OK, if we do some bounds based mainly on foreseeable single device
performance needs.. 16MB?

> I'm happy to worry about only scaling down for now, but it's only a
> matter of time before we have to bump the number up again.

Agreed.

> We've got an IOPS range from < 1 (mp3 player with power-saving
> spin-down) to > 1M (high-end SSD). And the one that needs the most
> readahead is the former! 

We have laptop mode for the former, which will elevate readahead size
and (legitimately) disregard IO performance impacts.

> > I would guess most embedded systems put executables on MTD devices
> > (anyone to confirm this?).
> 
> It's hard to generalize here. Even on flash devices, interleaving with
> writes can result in high latencies that make it behave more like
> spinning media, but there's no way to generalize about what the write
> mix is going to be.

I'd prefer to not consider impact of writes when choosing default
readahead size.

> >  And I wonder if MTDs have general
> > characteristics that are suitable for smaller readahead/readaround
> > size (the two sizes are bundled for simplicity)?
> 
> Perhaps, but the trend is definitely towards larger blocks here.

OK.

> > We could add new adjustments based on throughput (estimation is the
> > problem) and memory size.
> 
> Note that throughput is not enough information here. More interesting is
> the "bandwidth delay product" of the I/O path. If latency (of the whole
> I/O stack) is zero, it's basically always better to read on demand. But
> if every request takes 100ms whether it's for 4k or 4M (see optical
> media), then you might want to consider reading 4M every time. And
> latency is of course generally not independent of usage pattern. Which
> is why I think TCP-like feedback scaling is the right approach.

OK.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
