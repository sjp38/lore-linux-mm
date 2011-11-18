Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 444896B0069
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 12:30:19 -0500 (EST)
Date: Fri, 18 Nov 2011 09:30:14 -0800
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [RFC]numa: improve I/O performance by optimizing numa
 interleave allocation
Message-ID: <20111118173013.GB25022@alboin.amr.corp.intel.com>
References: <1321600332.22361.309.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1321600332.22361.309.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Christoph Lameter <cl@linux.com>, lee.schermerhorn@hp.com

On Fri, Nov 18, 2011 at 03:12:12PM +0800, Shaohua Li wrote:
> If mem plicy is interleaves, we will allocated pages from nodes in a round
> robin way. This surely can do interleave fairly, but not optimal.
> 
> Say the pages will be used for I/O later. Interleave allocation for two pages
> are allocated from two nodes, so the pages are not physically continuous. Later
> each page needs one segment for DMA scatter-gathering. But maxium hardware
> segment number is limited. The non-continuous pages will use up maxium
> hardware segment number soon and we can't merge I/O to bigger DMA. Allocating
> pages from one node hasn't such issue. The memory allocator pcp list makes
> we can get physically continuous pages in several alloc quite likely.

FWIW it depends a lot on the IO hardware if the SG limitation
really makes a measurable difference for IO performance. I saw some wins from 
clustering using the IOMMU before, but that was a long time ago. I wouldn't 
consider it a truth without strong numbers, and then also only
for that particular device measured.

My understanding is that modern IO devices like NHM Express will
be faster at large SG lists.

> So can we make both interleave fairness and continuous allocation happy?
> Simplily we can adjust the round robin algorithm. We switch to another node
> after several (N) allocation happens. If N isn't too big, we can still get
> fair allocation. And we get N continuous pages. I use N=8 in below patch.
> I thought 8 isn't too big for modern NUMA machine. Applications which use
> interleave are unlikely run short time, so I thought fairness still works.

It depends a lot on the CPU access pattern.

Some workloads seem to do reasonable well with 2MB huge page interleaving.
But others actually prefer the cache line interleaving supplied by 
the BIOS.

So you can have a trade off between IO and CPU performance.
When in doubt I usually opt for CPU performance by default.

I definitely wouldn't make it default, but if there are workloads
that benefits a lot it could be an additional parameter to the
interleave policy.

> Run a sequential read workload which accesses disk sdc - sdf,

What IO device is that?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
