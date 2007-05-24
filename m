Date: Thu, 24 May 2007 11:07:29 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 3/8] mm: merge nopfn into fault
Message-ID: <20070524100729.GB28305@infradead.org>
References: <200705180737.l4I7b6cg010758@shell0.pdx.osdl.net> <alpine.LFD.0.98.0705180817550.3890@woody.linux-foundation.org> <1179963619.32247.991.camel@localhost.localdomain> <20070524014223.GA22998@wotan.suse.de> <alpine.LFD.0.98.0705231857090.3890@woody.linux-foundation.org> <1179976659.32247.1026.camel@localhost.localdomain> <1179977184.32247.1032.camel@localhost.localdomain> <alpine.LFD.0.98.0705232028510.3890@woody.linux-foundation.org> <20070524034557.GA20252@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070524034557.GA20252@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 24, 2007 at 05:45:57AM +0200, Nick Piggin wrote:
> On Wed, May 23, 2007 at 08:37:28PM -0700, Linus Torvalds wrote:
> > 
> > 
> > On Thu, 24 May 2007, Benjamin Herrenschmidt wrote:
> > > 
> > > Note that I culd just modify the address/page index in the struct
> > > vm_fault... doesn't make much difference in this case.
> > > 
> > > Might even create an arch helper prepare_special_pgsize_fault() or
> > > something like that that takes the VM fault struct, whack it the right
> > > way, and returns it to the driver for passing to vm_insert_pfn() so that
> > > all of the logic is actually hidden from the driver.
> > 
> > I don't think we really need that, but what I'd like to avoid is people 
> > using "address" when they don't actually need to (especially if it's just 
> > a quick-and-lazy conversion, and they use "address" to do the page index 
> > calculation with the "pgoff + ((address - vma->start) >> PAGE_SHIFT)" kind 
> > of thing.
> > 
> > So exactly _because_ the "nopage()" interface takes "address", I'd like to 
> > avoid it in that form in the "vm_fault" structure, just so that people 
> > don't do stupid things with it.
> > 
> > (And yes, I'm not proud of the "nopage()" interface, but it evolved from 
> > historical behaviour which did everything at the low level, so "address" 
> > _used_ to make sense for the same reason you want it now).
> 
> Yes, the goal was always to use pgoff to locate the page, because that
> is the correct abstraction to pass through this interface.
> 
>  
> > So just about any "hiding" would do it as far as I'm concerned. Ranging 
> > from the odd (making it a "virtual page number") to just using an 
> > inconvenient name that just makes it obvious that it shouldn't be used 
> > lightly ("virtual_page_fault_address"), to making it a type that cannot 
> > easily be used for that kind of arithmetic ("void __user *" would make 
> > sense, no?).
> 
> 'void __user *' seems reasonable, I think. Good idea.N

Abusing __user for something entirely different is really dumb,
just use the same __attribute__((noderef, address_space(N)) annotation
that __user and __iomem use. but please use a different address_space

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
