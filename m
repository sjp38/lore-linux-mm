From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] Initial alpha-0 for new page allocator API
Date: Fri, 22 Sep 2006 21:10:25 +0200
References: <Pine.LNX.4.64.0609212052280.4736@schroedinger.engr.sgi.com> <200609220817.59801.ak@suse.de> <Pine.LNX.4.64.0609220934040.7083@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609220934040.7083@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200609222110.25118.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Martin Bligh <mbligh@mbligh.org>, akpm@google.com, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@steeleye.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 22 September 2006 18:35, Christoph Lameter wrote:
> On Fri, 22 Sep 2006, Andi Kleen wrote:
> 
> > On Friday 22 September 2006 06:02, Christoph Lameter wrote:
> > > We have repeatedly discussed the problems of devices having varying 
> > > address range requirements for doing DMA.
> > 
> > We already have such an API. dma_alloc_coherent(). Device drivers
> > are not supposed to mess with GFP_DMA* directly anymore for quite
> > some time. 
> 
> Device drivers need to be able to indicate ranges of addresses that may be 
> different from ZONE_DMA. This is an attempt to come up with a future 
> scheme that does no longer rely on device drivers referring to zoies.

We already have that scheme. Any existing driver should be already converted
away from GFP_DMA towards dma_*/pci_*. dma_* knows all the magic
how to get memory for the various ranges. No need to mess up the 
main allocator.

Anyways, i suppose what could be added as a fallback would be a 
really_slow_brute_force_try_to_get_something_in_this_range() allocator
that basically goes through the buddy lists freeing in >O(1) 
and does some directed reclaim, but that would likely be a separate
path anyways and not need your new structure to impact the O(1)
allocator.

I am still unconvinced of the real need. The only gaping hole was 
GFP_DMA32, which we fixed already.

Ok there is aacraid with its weird 2GB limit, but in case there are
really enough users running into this broken then then the really_slow_*
thing above would be likely fine. And those cards are slowly going
away too.  

If we managed to resist for too long now is the wrong time.

> > I actually have my doubts it is a good idea to add that now. The devices
> > with weird requirements are steadily going away

> Hmm.... Martin?

Think of it this way: all the weird slow devices of 5-10 years ago have USB
interfaces today and that does 32bit just fine (=GFP_DMA32). And old 5-10 years old weird
devices are usually fine with 16MB of playground only.

Ok now I'm sure someone will come up with a counter example (hi Alan), but:
- Does the device really need more than 16MB?
- How often is it used on systems with >1/2GB with a 64bit kernel?
[consider that 64bit kernels don't support ISA]
- How many users of that particular thing around?


I think my point stands.

-And

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
