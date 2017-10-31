Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B3FF46B025F
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 05:47:32 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id s66so7468754wmf.14
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 02:47:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o42sor469078wrf.15.2017.10.31.02.47.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Oct 2017 02:47:30 -0700 (PDT)
Date: Tue, 31 Oct 2017 10:47:27 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/6] Boot-time switching between 4- and 5-level paging
 for 4.15, Part 1
Message-ID: <20171031094727.cvipkxzo2zhrxst3@gmail.com>
References: <20171023115658.geccs22o2t733np3@gmail.com>
 <20171023122159.wyztmsbgt5k2d4tb@node.shutemov.name>
 <20171023124014.mtklgmydspnvfcvg@gmail.com>
 <20171023124811.4i73242s5dotnn5k@node.shutemov.name>
 <20171024094039.4lonzocjt5kras7m@gmail.com>
 <20171024113819.pli7ifesp2u2rexi@node.shutemov.name>
 <20171024124741.ux74rtbu2vqaf6zt@gmail.com>
 <20171024131227.nchrzazuk4c6r75i@node.shutemov.name>
 <20171026073752.fl4eicn4x7wudpop@gmail.com>
 <20171026144040.hjm45civpm74gafx@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171026144040.hjm45civpm74gafx@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill@shutemov.name> wrote:

> On Thu, Oct 26, 2017 at 09:37:52AM +0200, Ingo Molnar wrote:
> > 
> > * Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > 
> > > On Tue, Oct 24, 2017 at 02:47:41PM +0200, Ingo Molnar wrote:
> > > > > > > > > > Making a variable that 'looks' like a constant macro dynamic in a rare Kconfig 
> > > > > > > > > > scenario is asking for trouble.
> > > > > > > > > 
> > > > > > > > > We expect boot-time page mode switching to be enabled in kernel of next
> > > > > > > > > generation enterprise distros. It shoudn't be that rare.
> > > > > > > > 
> > > > > > > > My point remains even with not-so-rare Kconfig dependency.
> > > > > > > 
> > > > > > > I don't follow how introducing new variable that depends on Kconfig option
> > > > > > > would help with the situation.
> > > > > > 
> > > > > > A new, properly named variable or function (max_physmem_bits or 
> > > > > > max_physmem_bits()) that is not all uppercase would make it abundantly clear that 
> > > > > > it is not a constant but a runtime value.
> > > > > 
> > > > > Would we need to rename every uppercase macros that would depend on
> > > > > max_physmem_bits()? Like MAXMEM.
> > > > 
> > > > MAXMEM isn't used in too many places either - what's the total impact of it?
> > > 
> > > The impact is not very small. The tree of macros dependent on
> > > MAX_PHYSMEM_BITS:
> > > 
> > > MAX_PHYSMEM_BITS
> > >   MAXMEM
> > >     KEXEC_SOURCE_MEMORY_LIMIT
> > >     KEXEC_DESTINATION_MEMORY_LIMIT
> > >     KEXEC_CONTROL_MEMORY_LIMIT
> > >   SECTIONS_SHIFT
> > >     ZONEID_SHIFT
> > >       ZONEID_PGSHIFT
> > >       ZONEID_MASK
> > > 
> > > The total number of users of them is not large. It's doable. But I expect
> > > it to be somewhat ugly, since we're partly in generic code and it would
> > > require some kind of compatibility layer for other archtectures.
> > > 
> > > Do you want me to rename them all?
> > 
> > Yeah, I think these former constants should be organized better.
> > 
> > Here's their usage frequency:
> > 
> >  triton:~/tip> for N in MAX_PHYSMEM_BITS MAXMEM KEXEC_SOURCE_MEMORY_LIMIT \
> >  KEXEC_DESTINATION_MEMORY_LIMIT KEXEC_CONTROL_MEMORY_LIMIT SECTIONS_SHIFT \
> >  ZONEID_SHIFT ZONEID_PGSHIFT ZONEID_MASK; do printf "  %-40s: " $N; git grep -w $N  | grep -vE 'define| \* ' | wc -l; done
> > 
> >    MAX_PHYSMEM_BITS                        : 10
> >    MAXMEM                                  : 5
> >    KEXEC_SOURCE_MEMORY_LIMIT               : 2
> >    KEXEC_DESTINATION_MEMORY_LIMIT          : 2
> >    KEXEC_CONTROL_MEMORY_LIMIT              : 2
> >    SECTIONS_SHIFT                          : 2
> >    ZONEID_SHIFT                            : 1
> >    ZONEID_PGSHIFT                          : 1
> >    ZONEID_MASK                             : 1
> > 
> > So it's not too bad to clean up, I think.
> > 
> > How about something like this:
> > 
> > 	machine.physmem.max_bytes		/* ex MAXMEM */
> > 	machine.physmem.max_bits		/* bit count of the highest in-use physical address */
> > 	machine.physmem.zones.id_shift		/* ZONEID_SHIFT */
> > 	machine.physmem.zones.pg_shift		/* ZONEID_PGSHIFT */
> > 	machine.physmem.zones.id_mask		/* ZONEID_MASK */
> > 
> > 	machine.kexec.physmem_bytes_src		/* KEXEC_SOURCE_MEMORY_LIMIT */
> > 	machine.kexec.physmem_bytes_dst		/* KEXEC_DESTINATION_MEMORY_LIMIT */
> > 
> > ( With perhaps 'physmem' being an alias to '&machine->physmem', so that 
> >   physmem->max_bytes and physmem->max_bits would be a natural thing to write. )
> > 
> > I'd suggest doing this in a finegrained fashion, one step at a time, introducing 
> > 'struct machine' and 'struct physmem' and extending it gradually with new fields.
> 
> I don't think this design is reasonable.
> 
>   - It introduces memory references where we haven't had them before.
> 
>     At this point all variable would fit a cache line, which is not that
>     bad. But I don't see what would stop the list from growing in the
>     future.

Is any of these actually in a hotpath?

Also, note the context: your changes turn some of these into variables. Yes, I 
suggest structuring them all and turning them all into variables, exactly because 
the majority are now dynamic, yet their _naming_ suggests that they are constants.

>   - We loose ability to optimize out change with static branches
>     (cpu_feature_enabled() instead of pgtable_l5_enabled variable).
> 
>     It's probably, not that big of an issue here, but if we are going to
>     use the same approach for other dynamic macros in the patchset, it
>     might be.

Here too I think the (vast) majority of the uses here are for bootup/setup/init 
purposes, where clarity and maintainability of code matters a lot.

>   - AFAICS, it requires changes to all architectures to provide such
>     structures as we now partly in generic code.
> 
>     Or to introduce some kind of compatibility layer, but it would make
>     the kernel as a whole uglier than cleaner. Especially, given that
>     nobody beyond x86 need this.

Yes, all the uses should be harmonized (no compatibility layer) - but as you can 
see it from the histogram I generated it's a few dozen uses, i.e. not too bad.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
