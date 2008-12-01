Date: Mon, 1 Dec 2008 17:14:04 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] acpi: do not use kmem caches
Message-ID: <20081201161404.GE10790@wotan.suse.de>
References: <20081201083128.GB2529@wotan.suse.de> <84144f020812010318v205579ean57edecf7992ec7ef@mail.gmail.com> <20081201120002.GB10790@wotan.suse.de> <4933E2C3.4020400@gmail.com> <1228138641.14439.18.camel@penberg-laptop> <4933EE8A.2010007@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4933EE8A.2010007@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexey Starikovskiy <aystarik@gmail.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, lenb@kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Dec 01, 2008 at 05:02:50PM +0300, Alexey Starikovskiy wrote:
> Pekka Enberg wrote:
> >Hi,
> >
> >On Mon, 2008-12-01 at 16:12 +0300, Alexey Starikovskiy wrote:
> >  
> >>>Actually I think it is also somewhat of a bugfix (not to mention that it
> >>>seems like a good idea to share testing code with other operating 
> >>>systems).
> >>>      
> >>It is not "kind of a bugfix". Caches were used to allocate all frequenly
> >>created objects of fixed size. Removing native cache interface will
> >>increase memory consumption and increase code size, and will make it 
> >>harder
> >>to spot actual memory leaks.
> >>    
> >
> >Excuse me?
> >
> >Why do you think Nick's patch is going to _increase_ memory consumption?
> >SLUB _already_ merges the ACPI caches with kmalloc caches so you won't
> >see any difference there. For SLAB, it's a gain because there's not
> >enough activity going on which results in lots of unused space in the
> >slabs (which is, btw, the reason SLUB does slab merging in the first
> >place).
> >
> >  
> Because SLAB has standard memory wells of 2^x size. None of cached ACPI
> objects has exactly this size, so bigger block will be used. Plus, 
> internal ACPICA
> caching will add some overhead.

That's an insane looking caching thing now that I come to closely read
the code. There is so much stuff there that I thought it must have been
doing something useful which is why I didn't replace the Linux functions
with kmalloc/kfree directly.

There is really some operating system you support that has such a poor
allocator that you think ACPI can do better in 300 lines of code? Why
not just rip that whole thing out?


> >I'm also wondering why you think it's going to increase text size.
> >Unless the ACPI code is doing something weird, the kmalloc() and
> >kzalloc() shouldn't be a problem at all.
> >
> >  
> if you don't use ACPI_USE_LOCAL_CACHE
> ACPICA will enable it's own cache implementation, so it will increase
> code size.
> >For memory leaks, CONFIG_SLAB_LEAK has been in mainline for a long time
> >plus there are the kmemleak patches floating around. So I fail to see
> >how it's going to be harder to spot the memory leaks.
> It will give you a memory leak, not the kind of it, right?
> > After all, the
> >rest of the kernel manages fine without a special wrapper, so how is
> >ACPI any different here?
> >  
> Do you have another interpreter in kernel space?

So what makes it special?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
