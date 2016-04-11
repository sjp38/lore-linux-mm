Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 50DF36B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 12:20:55 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id zm5so124259513pac.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 09:20:55 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ur6si4403838pac.226.2016.04.11.09.20.54
        for <linux-mm@kvack.org>;
        Mon, 11 Apr 2016 09:20:54 -0700 (PDT)
Date: Mon, 11 Apr 2016 12:20:47 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle facility?
Message-ID: <20160411162047.GJ2781@linux.intel.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
 <20160407161715.52635cac@redhat.com>
 <20160411085819.GE21128@suse.de>
 <20160411142639.1c5e520b@redhat.com>
 <20160411130826.GB32073@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160411130826.GB32073@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Brenden Blanco <bblanco@plumgrid.com>, lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Tom Herbert <tom@herbertland.com>, lsf-pc@lists.linux-foundation.org, Alexei Starovoitov <alexei.starovoitov@gmail.com>

On Mon, Apr 11, 2016 at 02:08:27PM +0100, Mel Gorman wrote:
> On Mon, Apr 11, 2016 at 02:26:39PM +0200, Jesper Dangaard Brouer wrote:
> > On arch's like PowerPC, the DMA API is the bottleneck.  To workaround
> > the cost of DMA calls, NIC driver alloc large order (compound) pages.
> > (dma_map compound page, handout page-fragments for RX ring, and later
> > dma_unmap when last RX page-fragments is seen).
> 
> So, IMO only holding onto the DMA pages is all that is justified but not a
> recycle of order-0 pages built on top of the core allocator. For DMA pages,
> it would take a bit of legwork but the per-cpu allocator could be split
> and converted to hold arbitrary sized pages with a constructer/destructor
> to do the DMA coherency step when pages are taken from or handed back to
> the core allocator. I'm not volunteering to do that unfortunately but I
> estimate it'd be a few days work unless it needs to be per-CPU and NUMA
> aware in which case the memory footprint will be high.

Have "we" tried to accelerate the DMA calls in PowerPC?  For example, it
could hold onto a cache of recently used mappings and recycle them if that
still works.  It trades off a bit of security (a device can continue to DMA
after the memory should no longer be accessible to it) for speed, but then
so does the per-driver hack of keeping pages around still mapped.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
