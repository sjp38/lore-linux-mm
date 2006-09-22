Date: Fri, 22 Sep 2006 12:17:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Initial alpha-0 for new page allocator API
In-Reply-To: <200609222110.25118.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0609221212150.8764@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609212052280.4736@schroedinger.engr.sgi.com>
 <200609220817.59801.ak@suse.de> <Pine.LNX.4.64.0609220934040.7083@schroedinger.engr.sgi.com>
 <200609222110.25118.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Martin Bligh <mbligh@mbligh.org>, akpm@google.com, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@steeleye.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 22 Sep 2006, Andi Kleen wrote:

> We already have that scheme. Any existing driver should be already converted
> away from GFP_DMA towards dma_*/pci_*. dma_* knows all the magic
> how to get memory for the various ranges. No need to mess up the 
> main allocator.

That is not the case. The "magic" ends in arch specific 
*_alloc_dma_coherent function tinkering around with __GFP_DMA and in 
x86_64 in addition GFP_DMA32.
> 
> Anyways, i suppose what could be added as a fallback would be a 
> really_slow_brute_force_try_to_get_something_in_this_range() allocator
> that basically goes through the buddy lists freeing in >O(1) 
> and does some directed reclaim, but that would likely be a separate
> path anyways and not need your new structure to impact the O(1)
> allocator.

Right.

> I am still unconvinced of the real need. The only gaping hole was 
> GFP_DMA32, which we fixed already.

And then about DMA zones being associated with arch independent memory 
ranges which is not the case. GFP_DMA32 just happens to be defined by a
single arch and thus is has only one interpretation.

> Ok there is aacraid with its weird 2GB limit, but in case there are
> really enough users running into this broken then then the really_slow_*
> thing above would be likely fine. And those cards are slowly going
> away too.  

I agree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
