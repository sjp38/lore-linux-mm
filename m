Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 86A1A6B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 13:46:35 -0400 (EDT)
Received: by mail-qg0-f54.google.com with SMTP id j35so150674826qge.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 10:46:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a74si21092875qhb.80.2016.04.11.10.46.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 10:46:34 -0700 (PDT)
Date: Mon, 11 Apr 2016 14:46:25 -0300
From: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle facility?
Message-ID: <20160411174625.GH1845@indiana.gru.redhat.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
 <20160407161715.52635cac@redhat.com>
 <20160411085819.GE21128@suse.de>
 <20160411142639.1c5e520b@redhat.com>
 <20160411130826.GB32073@techsingularity.net>
 <20160411162047.GJ2781@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160411162047.GJ2781@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Jesper Dangaard Brouer <brouer@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Brenden Blanco <bblanco@plumgrid.com>, lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Tom Herbert <tom@herbertland.com>, lsf-pc@lists.linux-foundation.org, Alexei Starovoitov <alexei.starovoitov@gmail.com>

On Mon, Apr 11, 2016 at 12:20:47PM -0400, Matthew Wilcox wrote:
> On Mon, Apr 11, 2016 at 02:08:27PM +0100, Mel Gorman wrote:
> > On Mon, Apr 11, 2016 at 02:26:39PM +0200, Jesper Dangaard Brouer wrote:
> > > On arch's like PowerPC, the DMA API is the bottleneck.  To workaround
> > > the cost of DMA calls, NIC driver alloc large order (compound) pages.
> > > (dma_map compound page, handout page-fragments for RX ring, and later
> > > dma_unmap when last RX page-fragments is seen).
> > 
> > So, IMO only holding onto the DMA pages is all that is justified but not a
> > recycle of order-0 pages built on top of the core allocator. For DMA pages,
> > it would take a bit of legwork but the per-cpu allocator could be split
> > and converted to hold arbitrary sized pages with a constructer/destructor
> > to do the DMA coherency step when pages are taken from or handed back to
> > the core allocator. I'm not volunteering to do that unfortunately but I
> > estimate it'd be a few days work unless it needs to be per-CPU and NUMA
> > aware in which case the memory footprint will be high.
> 
> Have "we" tried to accelerate the DMA calls in PowerPC?  For example, it
> could hold onto a cache of recently used mappings and recycle them if that
> still works.  It trades off a bit of security (a device can continue to DMA
> after the memory should no longer be accessible to it) for speed, but then
> so does the per-driver hack of keeping pages around still mapped.
> 

There are two problems on the DMA calls on Power servers. One is scalability. A
new allocation method for the address space would be necessary to fix it.

The other one is the latency or the cost of updating the TCE tables. The only
number I have is that I could push around 1M updates per second. So, we could
guess 1us per operation, which is pretty much a no-no for Jesper use case.

Your solution could address both. But I am concerned about the security problem.
Here is why I think this problem should be ignored if we go this way. IOMMU can
be used for three problems: virtualization, paranoia security and debuggability.

For virtualization, there is a solution already, and it's in place for Power and
x86. Power servers have the ability to enlarge the DMA window, allowing the
entire VM memory to be mapped during PCI driver probe time. After that, dma_map
is a simple sum and dma_unmap is a nop. x86 KVM maps the entire VM memory even
before booting the guest. Unless we want to fix this for old Power servers, I
see no point in fixing it.

Now, if you are using IOMMU on the host with no passthrough or linear system
memory mapping, you are paranoid. It's not just a matter of security, in fact.
It's also a matter of stability. Hardware, firmware and drivers can be buggy,
and they are. When I worked with drivers on Power servers, I found and fixed a
lot of driver bugs that caused the device to write to memory it was not supposed
to. Good thing is that IOMMU prevented that memory write to happen and the
driver would be reset by EEH. If we can make this scenario faster, and if we
want it to be the default we need to, then your solution might not be desired.
Otherwise, just turn your IOMMU off or put it into passthrough.

Now, the driver keeps pages mapped, but those pages belong to the driver. They
are not pages we decide to give to a userspace process because it's no longer in
use by the driver. So, I don't quite agree this would be a good tradeoff.
Certainly not if we can do it in a way that does not require this.

So, Jesper, please take into consideration that this pool design would rather be
per device. Otherwise, we allow some device to write into another's
device/driver memory.

Cascardo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
