Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8E7216B0033
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 08:47:49 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 196so8080662wma.6
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 05:47:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a69sor67732wme.83.2017.10.24.05.47.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Oct 2017 05:47:44 -0700 (PDT)
Date: Tue, 24 Oct 2017 14:47:41 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/6] Boot-time switching between 4- and 5-level paging
 for 4.15, Part 1
Message-ID: <20171024124741.ux74rtbu2vqaf6zt@gmail.com>
References: <20171020081853.lmnvaiydxhy5c63t@gmail.com>
 <20171020094152.skx5sh5ramq2a3vu@black.fi.intel.com>
 <20171020152346.f6tjybt7i5kzbhld@gmail.com>
 <20171020162349.3kwhdgv7qo45w4lh@node.shutemov.name>
 <20171023115658.geccs22o2t733np3@gmail.com>
 <20171023122159.wyztmsbgt5k2d4tb@node.shutemov.name>
 <20171023124014.mtklgmydspnvfcvg@gmail.com>
 <20171023124811.4i73242s5dotnn5k@node.shutemov.name>
 <20171024094039.4lonzocjt5kras7m@gmail.com>
 <20171024113819.pli7ifesp2u2rexi@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171024113819.pli7ifesp2u2rexi@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill@shutemov.name> wrote:

> On Tue, Oct 24, 2017 at 11:40:40AM +0200, Ingo Molnar wrote:
> > 
> > * Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > 
> > > On Mon, Oct 23, 2017 at 02:40:14PM +0200, Ingo Molnar wrote:
> > > > 
> > > > * Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > > > 
> > > > > > Making a variable that 'looks' like a constant macro dynamic in a rare Kconfig 
> > > > > > scenario is asking for trouble.
> > > > > 
> > > > > We expect boot-time page mode switching to be enabled in kernel of next
> > > > > generation enterprise distros. It shoudn't be that rare.
> > > > 
> > > > My point remains even with not-so-rare Kconfig dependency.
> > > 
> > > I don't follow how introducing new variable that depends on Kconfig option
> > > would help with the situation.
> > 
> > A new, properly named variable or function (max_physmem_bits or 
> > max_physmem_bits()) that is not all uppercase would make it abundantly clear that 
> > it is not a constant but a runtime value.
> 
> Would we need to rename every uppercase macros that would depend on
> max_physmem_bits()? Like MAXMEM.

MAXMEM isn't used in too many places either - what's the total impact of it?

> > > We would end up with inverse situation: people would use MAX_PHYSMEM_BITS
> > > where the new variable need to be used and we will in the same situation.
> > 
> > It should result in sub-optimal resource allocations worst-case, right?
> 
> I don't think it's the worst case.
> 
> For instance, virt_addr_valid() depends indirectly on it:
> 
>   virt_addr_valid()
>     __virt_addr_valid()
>       phys_addr_valid()
>         boot_cpu_data.x86_phys_bits (initialized with MAX_PHYSMEM_BITS)
> 
> virt_addr_valid() is used in things like implementation /dev/kmem.
> 
> To me it's far more risky than occasional build breakage for
> CONFIG_X86_5LEVEL=y.

So why do we have two variables here, one boot_cpu_data.x86_phys_bits and the 
other MAX_PHYSMEM_BITS - both set once during boot?

I'm trying to find a clean solution for this all - hiding a boot time dependency 
into a constant-looking value doesn't feel clean.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
