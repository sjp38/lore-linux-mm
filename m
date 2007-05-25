Date: Fri, 25 May 2007 09:36:26 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 3/8] mm: merge nopfn into fault
In-Reply-To: <20070525111818.GA3881@wotan.suse.de>
Message-ID: <alpine.LFD.0.98.0705250924320.26602@woody.linux-foundation.org>
References: <200705180737.l4I7b6cg010758@shell0.pdx.osdl.net>
 <alpine.LFD.0.98.0705180817550.3890@woody.linux-foundation.org>
 <1179963619.32247.991.camel@localhost.localdomain> <20070524014223.GA22998@wotan.suse.de>
 <alpine.LFD.0.98.0705231857090.3890@woody.linux-foundation.org>
 <1179976659.32247.1026.camel@localhost.localdomain>
 <1179977184.32247.1032.camel@localhost.localdomain>
 <alpine.LFD.0.98.0705232028510.3890@woody.linux-foundation.org>
 <20070525111818.GA3881@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>


On Fri, 25 May 2007, Nick Piggin wrote:
> 
> What do you think? Any better?

Yes, I think this is getting there. It made the error returns generally 
much simpler.

That said, I think it has room for more improvement. Why not make the 
return value just be a bitmask, rather than having two separate "bytes" of 
data.

For example, you now do:

> +
> +/*
> + * VM_FAULT_ERROR is set for the error cases, to make some tests simpler.
> + */
> +#define VM_FAULT_ERROR	0x20
> +
> +#define VM_FAULT_OOM	(0x00 | VM_FAULT_ERROR)
> +#define VM_FAULT_SIGBUS	(0x01 | VM_FAULT_ERROR)
>  #define VM_FAULT_MINOR	0x02
>  #define VM_FAULT_MAJOR	0x03

And it would be so much cleaner (I think) to just realize:

 - successful VM faults are always either major or minor, so having two 
   different values for them is silly (it comes from the fact that we did 
   _not_ have a bitmask). JUst make a "MAJOR" bit, and if it's clear, then 
   it's not major, of course!

 - rather than have one bit to say "we had an error", just make each error 
   be a bit of its own. We don't have that many (two, to be exact), so you 
   actually don't even use any more bits, but it means that you can do:

	#define VM_FAULT_OOM		0x0001
	#define VM_FAULT_SIGBUS		0x0002
	#define VM_FAULT_MAJOR		0x0004
	#define VM_FAULT_WRITE		0x0008

	#define VM_FAULT_NONLINEAR	0x0010
	#define VM_FAULT_NOPAGE		0x0020	/* We did our own pfn map */
	#define VM_FAULT_LOCKED		0x0040	/* Returned a locked page */

	/* Helper defines: */
	#define VM_FAULT_ERROR	(VM_FAULT_OOM | VM_FAULT_SIGBUS)

   and you're done. No magic semantics: you just always return a set of 
   result flags.

So now the _user_ would simply do something like

	unsigned int flags;

	flags = vma->vm_ops->fault(...);
	if (flags & VM_FAULT_ERROR)
		return flags;

	if (flags & VM_FAULT_MAJOR)
		increment_major_faults();
	else
		increment_minor_faults();

	/* Did the fault handler do it all already? All done! */
	if (flags & VM_FAULT_NOPAGE)
		return 0;

	page = fault->page;
	.. install page ..

	/*
	 * If the fault handler returned a locked page, we should now 
	 * unlock it
	 */
	if (flags & VM_FAULT_LOCKED)
		unlock_page(page);

	/* All done! */
	return 0;

or something like that. Yeah, the above is simplified, but it's not 
*overly* so. And it never worries about "high bytes" and "low bytes", and 
it never worries about a certain set of bits meaning one thing, and 
another set meaning somethign else. Isn't that just much simpler for 
everybody?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
