Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7DAAD6B0047
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 15:20:30 -0500 (EST)
Subject: Re: [PATCH 03/11] readahead: bump up the default readahead size
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20100212135949.GA22686@localhost>
References: <20100207041013.891441102@intel.com>
	 <20100207041043.147345346@intel.com> <4B6FBB3F.4010701@linux.vnet.ibm.com>
	 <20100208134634.GA3024@localhost> <1265924254.15603.79.camel@calx>
	 <20100211234249.GE407@shareable.org>  <20100212135949.GA22686@localhost>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 12 Feb 2010 14:20:23 -0600
Message-ID: <1266006023.15603.661.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jamie Lokier <jamie@shareable.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, David Woodhouse <dwmw2@infradead.org>, "linux-embedded@vger.kernel.org" <linux-embedded@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2010-02-12 at 21:59 +0800, Wu Fengguang wrote:
> On Fri, Feb 12, 2010 at 07:42:49AM +0800, Jamie Lokier wrote:
> > Matt Mackall wrote:
> > > On Mon, 2010-02-08 at 21:46 +0800, Wu Fengguang wrote:
> > > > Chris,
> > > > 
> > > > Firstly inform the linux-embedded maintainers :)
> > > > 
> > > > I think it's a good suggestion to add a config option
> > > > (CONFIG_READAHEAD_SIZE). Will update the patch..
> > > 
> > > I don't have a strong opinion here beyond the nagging feeling that we
> > > should be using a per-bdev scaling window scheme rather than something
> > > static.
> 
> It's good to do dynamic scaling -- in fact this patchset has code to do
> - scale down readahead size (per-bdev) for small devices

I'm not sure device size is a great metric. It's only weakly correlated
with the things we actually care about: memory pressure (small devices
are often attached to systems with small and therefore full memory) and
latency (small devices are often old and slow and attached to slow
CPUs). I think we should instead use hints about latency (large request
queues) and memory pressure (reclaim passes) directly.

> - scale down readahead size (per-stream) to thrashing threshold

Yeah, I'm happy to call that part orthogonal to this discussion.

> At the same time, I'd prefer
> - to _only_ do scale down (below the default size) for low end
> - and have a uniform default readahead size for the mainstream

I don't think that's important, given that we're dynamically fiddling
with related things.

> IMHO scaling up automatically
> - would be risky

What, explicitly, are the risks? If we bound the window with memory
pressure and latency, I don't think it can get too far out of hand.
There are also some other bounds in here: we have other limits on how
big I/O requests can be.

I'm happy to worry about only scaling down for now, but it's only a
matter of time before we have to bump the number up again.
We've got an IOPS range from < 1 (mp3 player with power-saving
spin-down) to > 1M (high-end SSD). And the one that needs the most
readahead is the former! 

> I would guess most embedded systems put executables on MTD devices
> (anyone to confirm this?).

It's hard to generalize here. Even on flash devices, interleaving with
writes can result in high latencies that make it behave more like
spinning media, but there's no way to generalize about what the write
mix is going to be.

>  And I wonder if MTDs have general
> characteristics that are suitable for smaller readahead/readaround
> size (the two sizes are bundled for simplicity)?

Perhaps, but the trend is definitely towards larger blocks here.

> We could add new adjustments based on throughput (estimation is the
> problem) and memory size.

Note that throughput is not enough information here. More interesting is
the "bandwidth delay product" of the I/O path. If latency (of the whole
I/O stack) is zero, it's basically always better to read on demand. But
if every request takes 100ms whether it's for 4k or 4M (see optical
media), then you might want to consider reading 4M every time. And
latency is of course generally not independent of usage pattern. Which
is why I think TCP-like feedback scaling is the right approach.

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
