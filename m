Date: Fri, 22 Sep 2006 10:36:03 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Initial alpha-0 for new page allocator API
In-Reply-To: <200609220817.59801.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0609221028590.7816@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609212052280.4736@schroedinger.engr.sgi.com>
 <200609220817.59801.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Martin Bligh <mbligh@mbligh.org>, akpm@google.com, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@steeleye.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The problems to be solved are:

1. Have a means to allocate from a range of memory that is defined by the 
device driver and *not* by the architecture. Devices currently cannot rely 
on GFP_DMA because the range vary according to the architecture.

2. I wish we there would be some point in the future where we could get 
rid of GFP_DMAxx... As Andi notes most hardware these days is sane so 
there is less need to create VM overhead by managing additional zones.

3. There are issues with memory policies coming from the process 
environment that may redirect allocations. We also have additional calls
with xx_node like alloc_pages and alloc_pages_node. A new API could
fix these and allow a complete specification of how the allocation should 
proceeds without strange side effect from the process (which makes 
GFP_THISNODE necessary).

One easy alternate way to support allocating from a range of memory 
without reworking the API would be to simply add a new page allocator 
call:

struct page *alloc_pages_range(int order, gfp_t gfp_flags, unsigned long 
low, unsigned long high [ , node ? ]);

This would scan through the freelists for available memory in that range 
and if not found simply do page reclaim until such memory becomes 
available. We could get more sophisticated than that but this would allow 
allocating memory from the ranges needed by broken devices and it would 
penalize the device for the problem it has and would not impact the rest 
of the system.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
