Date: Mon, 1 Dec 2008 17:58:52 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] acpi: do not use kmem caches
Message-ID: <20081201165852.GH10790@wotan.suse.de>
References: <20081201083128.GB2529@wotan.suse.de> <84144f020812010318v205579ean57edecf7992ec7ef@mail.gmail.com> <20081201120002.GB10790@wotan.suse.de> <4933E2C3.4020400@gmail.com> <1228138641.14439.18.camel@penberg-laptop> <4933EE8A.2010007@gmail.com> <20081201161404.GE10790@wotan.suse.de> <4934149A.4020604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4934149A.4020604@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexey Starikovskiy <aystarik@gmail.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, lenb@kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Dec 01, 2008 at 07:45:14PM +0300, Alexey Starikovskiy wrote:
> Nick Piggin wrote:
> >On Mon, Dec 01, 2008 at 05:02:50PM +0300, Alexey Starikovskiy wrote:
> >  
> >>Because SLAB has standard memory wells of 2^x size. None of cached ACPI
> >>objects has exactly this size, so bigger block will be used. Plus, 
> >>internal ACPICA caching will add some overhead.
> >>    
> >
> >That's an insane looking caching thing now that I come to closely read
> >the code. There is so much stuff there that I thought it must have been
> >doing something useful which is why I didn't replace the Linux functions
> >with kmalloc/kfree directly.
> >
> >There is really some operating system you support that has such a poor
> >allocator that you think ACPI can do better in 300 lines of code? Why
> >not just rip that whole thing out?
> >  
> You would laugh, this is due to Windows userspace debug library -- it 
> checks for
> memory leaks by default, and it takes ages to do this.

OK... circumvent the debug library? :) I won't argue. But I agree it is
wrong for Linux so my patch is not good. It needs to use kmalloc at least.


> And ACPICA maintainer is sitting on Windows, so he _cares_.
> >>Do you have another interpreter in kernel space?
> >>    
> >
> >So what makes it special?
> >
> >  
> You don't know what size of program you will end up with.
> DSDT could be almost empty, or you could have several thousand of SSDT 
> tables.

OK. And I guess the sizes of the objects seem to be variable as well.
I still think kmalloc would be fine, and would save memory in some
situations. On tiny systems it is less likely to because each slab
costs less memory.

On a big system, the caches can take some MB each in some configurations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
