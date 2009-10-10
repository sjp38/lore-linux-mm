Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B97216B004D
	for <linux-mm@kvack.org>; Sat, 10 Oct 2009 08:40:57 -0400 (EDT)
Date: Sat, 10 Oct 2009 20:40:42 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] mm: make VM_MAX_READAHEAD configurable
Message-ID: <20091010124042.GA9179@localhost>
References: <1255087175-21200-1-git-send-email-ehrhardt@linux.vnet.ibm.com> <1255090830.8802.60.camel@laptop> <20091009122952.GI9228@kernel.dk> <20091009143124.1241a6bc.akpm@linux-foundation.org> <20091010105333.GR9228@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091010105333.GR9228@kernel.dk>
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ehrhardt Christian <ehrhardt@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sat, Oct 10, 2009 at 06:53:33PM +0800, Jens Axboe wrote:
> On Fri, Oct 09 2009, Andrew Morton wrote:
> > On Fri, 9 Oct 2009 14:29:52 +0200
> > Jens Axboe <jens.axboe@oracle.com> wrote:
> > 
> > > On Fri, Oct 09 2009, Peter Zijlstra wrote:
> > > > On Fri, 2009-10-09 at 13:19 +0200, Ehrhardt Christian wrote:
> > > > > From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
> > > > > 
> > > > > On one hand the define VM_MAX_READAHEAD in include/linux/mm.h is just a default
> > > > > and can be configured per block device queue.
> > > > > On the other hand a lot of admins do not use it, therefore it is reasonable to
> > > > > set a wise default.
> > > > > 
> > > > > This path allows to configure the value via Kconfig mechanisms and therefore
> > > > > allow the assignment of different defaults dependent on other Kconfig symbols.
> > > > > 
> > > > > Using this, the patch increases the default max readahead for s390 improving
> > > > > sequential throughput in a lot of scenarios with almost no drawbacks (only
> > > > > theoretical workloads with a lot concurrent sequential read patterns on a very
> > > > > low memory system suffer due to page cache trashing as expected).
> > > > 
> > > > Why can't this be solved in userspace?
> > > > 
> > > > Also, can't we simply raise this number if appropriate? Wu did some
> > > > read-ahead trashing detection bits a long while back which should scale
> > > > the read-ahead window back when we're low on memory, not sure that ever
> > > > made it in, but that sounds like a better option than having different
> > > > magic numbers for each platform.
> > > 
> > > Agree, making this a config option (and even defaulting to a different
> > > number because of an arch setting) is crazy.
> > 
> > Given the (increasing) level of disparity between different kinds of
> > storage devices, having _any_ default is crazy.
> 
> You have to start somewhere :-). 0 is a default, too.

Yes, an obvious and viable way is to start with a default size, and to
back off in runtime if experienced thrashing.

Ideally we use 4MB readahead size per disk, however there are several
constraints:
- readahead thrashing
  can be detected and handled very well if necessary :)
- mmap readaround size
  currently one single size is used for both sequential readahead and
  mmap readaround, and a larger readaround size risks more prefetch
  misses (comparing to the pretty accurate readahead). I guess in
  despite of the increased readaound misses, a large readaround size
  would still help application startup time in a 4GB desktop. However
  it does risk working-set thrashings for memory tight desktops. Maybe
  we can try to detect working-set thrashings too.
- IO latency
  Some workloads may be sensitive to IO latencies. The max_sectors_kb
  may help keep IO latency under control with a large readahead size,
  but there may be some tradeoffs in the IO scheduler.

In summary, towards the runtime dynamic prefetching size, we
- can reliably adapt readahead size to readahead thrashings
- may reliably adapt readaround size to working set thrashings
- don't know in general whether workload is IO latency sensitive

> > Would be better to make some sort of vaguely informed guess at
> > runtime, based upon the characteristics of the device.
> 
> I'm pretty sure the readahead logic already does respond to eg memory
> pressure,

Yes, it's much better than before. Once thrashed, old kernels are
basically reduced to do 1-page (random) IOs, which is disastrous.

Current kernel does this. Given

        default_readahead_size > thrashing_readahead_size

The readahead sequence would be

        read_size, 2*read_size, 4*read_size, ..., (until > thrashing_readahead_size)
        read_size, 2*read_size, 4*read_size, ..., (until > thrashing_readahead_size)
        read_size, 2*read_size, 4*read_size, ..., (until > thrashing_readahead_size)
        ...

So if read_size=1, it roughly holds that

        average_readahead_size = thrashing_readahead_size/log2(thrashing_readahead_size)
        thrashed_pages = total_read_pages/2

And if read_size=LONG_MAX (eg. sendfile(large_file))

        average_readahead_size = default_readahead_size
        thrashed_pages = default_readahead_size - thrashing_readahead_size

In summary, readahead for sendfile() is not adaptive at all.  Normal
reads are somehow adaptive, but not optimal.

But anyway, optimal thrashing readahead is approachable if it's a
desirable goal :).

> not sure if it attempts to do anything based on how quickly
> the device is doing IO. Wu?

Not for current kernel.  But in fact it's possible to estimate the
read speed for each individual sequential stream, and possibly drop
some hint to the IO scheduler: someone will block on this IO after 3
seconds. But it may not deserve the complexity.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
