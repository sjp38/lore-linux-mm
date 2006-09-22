From: Jesse Barnes <jesse.barnes@intel.com>
Subject: Re: [RFC] Initial alpha-0 for new page allocator API
Date: Fri, 22 Sep 2006 14:14:00 -0700
References: <Pine.LNX.4.64.0609212052280.4736@schroedinger.engr.sgi.com> <200609221341.44354.jesse.barnes@intel.com> <Pine.LNX.4.64.0609221400230.9370@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609221400230.9370@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200609221414.00667.jesse.barnes@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Martin Bligh <mbligh@mbligh.org>, Andi Kleen <ak@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, akpm@google.com, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@steeleye.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday, September 22, 2006 2:01 pm, Christoph Lameter wrote:
> On Fri, 22 Sep 2006, Jesse Barnes wrote:
> > > +	if (dev->coherent_dma_mask < 0xffffffff)
> > > +		high = dev->coherent_dma_mask;
> >
> > With your alloc_pages_range this check can go away.  I think only the
> > dev == NULL check is needed with this scheme since it looks like
> > there's no way (currently) for ISA devices to store their masks for
> > later consultation by arch code?
>
> This check is necessary to set up the correct high boundary for
> alloc_page_range.

I was suggesting something like:

	high = dev ? dev->coherent_dma_mask : 16*1024*1024;

instead.  May as well combine your NULL check and your assignment.  It'll 
also do the right thing for 64 bit devices so we don't put unnecessary 
pressure on the 32 bit range.  Or am I spacing out and reading the code 
wrong?

> > There's max_pfn, but on machines with large memory holes using it
> > might not help much.
>
> I found node_start_pfn and node_spanned_pages in the node structure.
> That gives me the boundaries for a node and I think I can work with
> that.

Even better.

Jesse

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
