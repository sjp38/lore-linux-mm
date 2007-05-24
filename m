Date: Wed, 23 May 2007 20:37:28 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 3/8] mm: merge nopfn into fault
In-Reply-To: <1179977184.32247.1032.camel@localhost.localdomain>
Message-ID: <alpine.LFD.0.98.0705232028510.3890@woody.linux-foundation.org>
References: <200705180737.l4I7b6cg010758@shell0.pdx.osdl.net>
 <alpine.LFD.0.98.0705180817550.3890@woody.linux-foundation.org>
 <1179963619.32247.991.camel@localhost.localdomain>  <20070524014223.GA22998@wotan.suse.de>
  <alpine.LFD.0.98.0705231857090.3890@woody.linux-foundation.org>
 <1179976659.32247.1026.camel@localhost.localdomain>
 <1179977184.32247.1032.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 24 May 2007, Benjamin Herrenschmidt wrote:
> 
> Note that I culd just modify the address/page index in the struct
> vm_fault... doesn't make much difference in this case.
> 
> Might even create an arch helper prepare_special_pgsize_fault() or
> something like that that takes the VM fault struct, whack it the right
> way, and returns it to the driver for passing to vm_insert_pfn() so that
> all of the logic is actually hidden from the driver.

I don't think we really need that, but what I'd like to avoid is people 
using "address" when they don't actually need to (especially if it's just 
a quick-and-lazy conversion, and they use "address" to do the page index 
calculation with the "pgoff + ((address - vma->start) >> PAGE_SHIFT)" kind 
of thing.

So exactly _because_ the "nopage()" interface takes "address", I'd like to 
avoid it in that form in the "vm_fault" structure, just so that people 
don't do stupid things with it.

(And yes, I'm not proud of the "nopage()" interface, but it evolved from 
historical behaviour which did everything at the low level, so "address" 
_used_ to make sense for the same reason you want it now).

So just about any "hiding" would do it as far as I'm concerned. Ranging 
from the odd (making it a "virtual page number") to just using an 
inconvenient name that just makes it obvious that it shouldn't be used 
lightly ("virtual_page_fault_address"), to making it a type that cannot 
easily be used for that kind of arithmetic ("void __user *" would make 
sense, no?).

We literally have code like

	offset = area->vm_pgoff << PAGE_SHIFT;
	offset += address - area->vm_start;
	vaddr = (char*)((struct usX2Ydev *)area->vm_private_data)->hwdep_pcm_shm + offset:
	page = virt_to_page(vaddr);

and the "easy" way to convert it would be to just continue to do the 
insane thing, without realizing that the "offset" calculation should now 
be just something like

	offset = fault->pgindex << PAGE_SHIFT;

instead.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
