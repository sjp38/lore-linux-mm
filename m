Subject: Re: [PATCH] Inconsistent mmap()/mremap() flags
From: Thayne Harbaugh <thayne@c2.net>
Reply-To: thayne@c2.net
In-Reply-To: <20071002051526.GA29615@one.firstfloor.org>
References: <1190958393.5128.85.camel@phantasm.home.enterpriseandprosperity.com>
	 <200710011313.30171.andi@firstfloor.org>
	 <1191293830.5200.22.camel@phantasm.home.enterpriseandprosperity.com>
	 <20071002051526.GA29615@one.firstfloor.org>
Content-Type: text/plain
Date: Tue, 02 Oct 2007 01:06:12 -0600
Message-Id: <1191308772.5200.66.camel@phantasm.home.enterpriseandprosperity.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, discuss@x86-64.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-10-02 at 07:15 +0200, Andi Kleen wrote:
> On Mon, Oct 01, 2007 at 08:57:10PM -0600, Thayne Harbaugh wrote:

> For mmap you can emulate it by passing a low hint != 0 (e.g. getpagesize()) 
> in address but without MAP_FIXED and checking if the result is not beyond
> your range.

Cool.  That's a much better solution for multiple reasons - like you
mention, MAP_32BIT is only 2GB as well as it's only available on x86_64.

> > > Given for mremap() it is not that easy because there is no "hint" argument
> > > without MREMAP_FIXED; but unless someone really needs it i would prefer
> > > to not propagate the hack. If it's really needed it's probably better
> > > to implement a start search hint for mremap()
> > 
> > It came up for user-mode Qemu for the case of emulating 32bit archs on
> > x86_64 using mmap.  At the moment it calls mmap with MAP_32BIT and then
> 
> That would limit the 32bit architectures to 2GB; but their real limit
> is 4GB. Losing half of the address space definitely would make users unhappy
> (e.g. at least normal Linux kernels wouldn't run at all) 

Keeping a kernel happy isn't necessary since it's user-space emulation
rather than full emulation.  It is, however, useful to have 4GB rather
than 2GB.

> Does qemu actually need mremap() ?  It would surprise me because
> a lot of other OS don't implement it.

Qemu has two modes: full hardware emulation and user-mode emulation.
User-mode emulation translates the user-mode code and then remaps the
system calls directly into the native kernel (that way all the kernel
and all the I/O runs natively and faster).  As far as mremap(), I'm
trying to get a 32bit arm mremap() emulated syscall mapped onto a 64bit
x86_64 mremap().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
