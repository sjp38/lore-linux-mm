Date: Thu, 24 May 2007 05:45:57 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 3/8] mm: merge nopfn into fault
Message-ID: <20070524034557.GA20252@wotan.suse.de>
References: <200705180737.l4I7b6cg010758@shell0.pdx.osdl.net> <alpine.LFD.0.98.0705180817550.3890@woody.linux-foundation.org> <1179963619.32247.991.camel@localhost.localdomain> <20070524014223.GA22998@wotan.suse.de> <alpine.LFD.0.98.0705231857090.3890@woody.linux-foundation.org> <1179976659.32247.1026.camel@localhost.localdomain> <1179977184.32247.1032.camel@localhost.localdomain> <alpine.LFD.0.98.0705232028510.3890@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.98.0705232028510.3890@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 23, 2007 at 08:37:28PM -0700, Linus Torvalds wrote:
> 
> 
> On Thu, 24 May 2007, Benjamin Herrenschmidt wrote:
> > 
> > Note that I culd just modify the address/page index in the struct
> > vm_fault... doesn't make much difference in this case.
> > 
> > Might even create an arch helper prepare_special_pgsize_fault() or
> > something like that that takes the VM fault struct, whack it the right
> > way, and returns it to the driver for passing to vm_insert_pfn() so that
> > all of the logic is actually hidden from the driver.
> 
> I don't think we really need that, but what I'd like to avoid is people 
> using "address" when they don't actually need to (especially if it's just 
> a quick-and-lazy conversion, and they use "address" to do the page index 
> calculation with the "pgoff + ((address - vma->start) >> PAGE_SHIFT)" kind 
> of thing.
> 
> So exactly _because_ the "nopage()" interface takes "address", I'd like to 
> avoid it in that form in the "vm_fault" structure, just so that people 
> don't do stupid things with it.
> 
> (And yes, I'm not proud of the "nopage()" interface, but it evolved from 
> historical behaviour which did everything at the low level, so "address" 
> _used_ to make sense for the same reason you want it now).

Yes, the goal was always to use pgoff to locate the page, because that
is the correct abstraction to pass through this interface.

 
> So just about any "hiding" would do it as far as I'm concerned. Ranging 
> from the odd (making it a "virtual page number") to just using an 
> inconvenient name that just makes it obvious that it shouldn't be used 
> lightly ("virtual_page_fault_address"), to making it a type that cannot 
> easily be used for that kind of arithmetic ("void __user *" would make 
> sense, no?).

'void __user *' seems reasonable, I think. Good idea.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
