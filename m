Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A4D886B0253
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 03:37:57 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 136so1405575wmu.10
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 00:37:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x63sor200709wmf.19.2017.10.26.00.37.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Oct 2017 00:37:56 -0700 (PDT)
Date: Thu, 26 Oct 2017 09:37:52 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/6] Boot-time switching between 4- and 5-level paging
 for 4.15, Part 1
Message-ID: <20171026073752.fl4eicn4x7wudpop@gmail.com>
References: <20171020152346.f6tjybt7i5kzbhld@gmail.com>
 <20171020162349.3kwhdgv7qo45w4lh@node.shutemov.name>
 <20171023115658.geccs22o2t733np3@gmail.com>
 <20171023122159.wyztmsbgt5k2d4tb@node.shutemov.name>
 <20171023124014.mtklgmydspnvfcvg@gmail.com>
 <20171023124811.4i73242s5dotnn5k@node.shutemov.name>
 <20171024094039.4lonzocjt5kras7m@gmail.com>
 <20171024113819.pli7ifesp2u2rexi@node.shutemov.name>
 <20171024124741.ux74rtbu2vqaf6zt@gmail.com>
 <20171024131227.nchrzazuk4c6r75i@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171024131227.nchrzazuk4c6r75i@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill@shutemov.name> wrote:

> On Tue, Oct 24, 2017 at 02:47:41PM +0200, Ingo Molnar wrote:
> > > > > > > > Making a variable that 'looks' like a constant macro dynamic in a rare Kconfig 
> > > > > > > > scenario is asking for trouble.
> > > > > > > 
> > > > > > > We expect boot-time page mode switching to be enabled in kernel of next
> > > > > > > generation enterprise distros. It shoudn't be that rare.
> > > > > > 
> > > > > > My point remains even with not-so-rare Kconfig dependency.
> > > > > 
> > > > > I don't follow how introducing new variable that depends on Kconfig option
> > > > > would help with the situation.
> > > > 
> > > > A new, properly named variable or function (max_physmem_bits or 
> > > > max_physmem_bits()) that is not all uppercase would make it abundantly clear that 
> > > > it is not a constant but a runtime value.
> > > 
> > > Would we need to rename every uppercase macros that would depend on
> > > max_physmem_bits()? Like MAXMEM.
> > 
> > MAXMEM isn't used in too many places either - what's the total impact of it?
> 
> The impact is not very small. The tree of macros dependent on
> MAX_PHYSMEM_BITS:
> 
> MAX_PHYSMEM_BITS
>   MAXMEM
>     KEXEC_SOURCE_MEMORY_LIMIT
>     KEXEC_DESTINATION_MEMORY_LIMIT
>     KEXEC_CONTROL_MEMORY_LIMIT
>   SECTIONS_SHIFT
>     ZONEID_SHIFT
>       ZONEID_PGSHIFT
>       ZONEID_MASK
> 
> The total number of users of them is not large. It's doable. But I expect
> it to be somewhat ugly, since we're partly in generic code and it would
> require some kind of compatibility layer for other archtectures.
> 
> Do you want me to rename them all?

Yeah, I think these former constants should be organized better.

Here's their usage frequency:

 triton:~/tip> for N in MAX_PHYSMEM_BITS MAXMEM KEXEC_SOURCE_MEMORY_LIMIT \
 KEXEC_DESTINATION_MEMORY_LIMIT KEXEC_CONTROL_MEMORY_LIMIT SECTIONS_SHIFT \
 ZONEID_SHIFT ZONEID_PGSHIFT ZONEID_MASK; do printf "  %-40s: " $N; git grep -w $N  | grep -vE 'define| \* ' | wc -l; done

   MAX_PHYSMEM_BITS                        : 10
   MAXMEM                                  : 5
   KEXEC_SOURCE_MEMORY_LIMIT               : 2
   KEXEC_DESTINATION_MEMORY_LIMIT          : 2
   KEXEC_CONTROL_MEMORY_LIMIT              : 2
   SECTIONS_SHIFT                          : 2
   ZONEID_SHIFT                            : 1
   ZONEID_PGSHIFT                          : 1
   ZONEID_MASK                             : 1

So it's not too bad to clean up, I think.

How about something like this:

	machine.physmem.max_bytes		/* ex MAXMEM */
	machine.physmem.max_bits		/* bit count of the highest in-use physical address */
	machine.physmem.zones.id_shift		/* ZONEID_SHIFT */
	machine.physmem.zones.pg_shift		/* ZONEID_PGSHIFT */
	machine.physmem.zones.id_mask		/* ZONEID_MASK */

	machine.kexec.physmem_bytes_src		/* KEXEC_SOURCE_MEMORY_LIMIT */
	machine.kexec.physmem_bytes_dst		/* KEXEC_DESTINATION_MEMORY_LIMIT */

( With perhaps 'physmem' being an alias to '&machine->physmem', so that 
  physmem->max_bytes and physmem->max_bits would be a natural thing to write. )

I'd suggest doing this in a finegrained fashion, one step at a time, introducing 
'struct machine' and 'struct physmem' and extending it gradually with new fields.

To re-discuss the virt_addr_valid() concern you raised:

> > For instance, virt_addr_valid() depends indirectly on it:
> > 
> >   virt_addr_valid()
> >     __virt_addr_valid()
> >       phys_addr_valid()
> >         boot_cpu_data.x86_phys_bits (initialized with MAX_PHYSMEM_BITS)
> > 
> > virt_addr_valid() is used in things like implementation /dev/kmem.
> > 
> > To me it's far more risky than occasional build breakage for
> > CONFIG_X86_5LEVEL=y.
> 
> So why do we have two variables here, one boot_cpu_data.x86_phys_bits and the
> other MAX_PHYSMEM_BITS - both set once during boot?

So it's still unclear to me why virt_addr_valid() would be a problem: this 
function could probably (in a separate patch) use physmem->max_bits, which would 
make it more secure than using even a dynamic MAX_PHYSMEM_BITS: it would detect 
any physical addresses that are beyond the recognized maximum range.

I.e. all this would result in further improvements.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
