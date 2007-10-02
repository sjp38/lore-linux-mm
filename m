Date: Tue, 2 Oct 2007 07:15:26 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Inconsistent mmap()/mremap() flags
Message-ID: <20071002051526.GA29615@one.firstfloor.org>
References: <1190958393.5128.85.camel@phantasm.home.enterpriseandprosperity.com> <200710011313.30171.andi@firstfloor.org> <1191293830.5200.22.camel@phantasm.home.enterpriseandprosperity.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1191293830.5200.22.camel@phantasm.home.enterpriseandprosperity.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thayne Harbaugh <thayne@c2.net>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, discuss@x86-64.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 01, 2007 at 08:57:10PM -0600, Thayne Harbaugh wrote:
> Yeah, after I sent the email I realized that it was a bit more involved.
> As far as the 32/31 bit, it just depends on the perspective.  I can see
> that 32 bits are needed to represent all possible return values from
> mmap() - possible address and error value of -1.  From that perspective
> I think that MAP_32BIT is appropriate.

Your perspective seems quite narrow. Only using 2GB instead of 4GB 
is a major functional difference.

Negative error values are used in all system calls, so it would
hardly seem necessary to encode the use of the 32th bit for that
in the option name.

> > But that would be ugly to implement without a new architecture wrapper
> > or better changing arch_get_unmapped_area()
> > 
> > It might be better to just not bother. MAP_32BIT is a kind of hack anyways
> > that at least for mmap can be easily emulated in user space anyways.
> 
> Care to give me some hints as to how that would be easily emulated in
> user space?  That might be a better solution for the case I want to
> solve.

For mmap you can emulate it by passing a low hint != 0 (e.g. getpagesize()) 
in address but without MAP_FIXED and checking if the result is not beyond
your range.

> 
> > Given for mremap() it is not that easy because there is no "hint" argument
> > without MREMAP_FIXED; but unless someone really needs it i would prefer
> > to not propagate the hack. If it's really needed it's probably better
> > to implement a start search hint for mremap()
> 
> It came up for user-mode Qemu for the case of emulating 32bit archs on
> x86_64 using mmap.  At the moment it calls mmap with MAP_32BIT and then

That would limit the 32bit architectures to 2GB; but their real limit
is 4GB. Losing half of the address space definitely would make users unhappy
(e.g. at least normal Linux kernels wouldn't run at all) 

The reason it's only 2GB is that the flag was added to support the small
code model of x86-64, which is limited to 2GB (31bit). Yes it's misnamed. 
But it's not used for the 32bit compat code.

> uses the returned address directly in the emulator.  Without MAP_32BIT
> there's the possibility of having an address that would be too large to
> pass to what a 32bit arch would expect.  Since the MAP_32BIT flag solves
> the problem for mmap()

It doesn't really for that case

> I was expecting something similar for mremap() -
> unfortunately the MAP_32BIT feature is consistent throughout.

I guess you mean inconsistent. 

Does qemu actually need mremap() ?  It would surprise me because
a lot of other OS don't implement it.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
