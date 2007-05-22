Subject: Re: [PATCH/RFC] Rework ptep_set_access_flags and fix sun4c
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.64.0705221738020.22822@blonde.wat.veritas.com>
References: <Pine.LNX.4.61.0705012354290.12808@mtfhpc.demon.co.uk>
	 <20070509231937.ea254c26.akpm@linux-foundation.org>
	 <1178778583.14928.210.camel@localhost.localdomain>
	 <20070510.001234.126579706.davem@davemloft.net>
	 <Pine.LNX.4.64.0705142018090.18453@blonde.wat.veritas.com>
	 <1179176845.32247.107.camel@localhost.localdomain>
	 <1179212184.32247.163.camel@localhost.localdomain>
	 <1179757647.6254.235.camel@localhost.localdomain>
	 <1179815339.32247.799.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0705221738020.22822@blonde.wat.veritas.com>
Content-Type: text/plain
Date: Wed, 23 May 2007 08:59:08 +1000
Message-Id: <1179874748.32247.868.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: "Tom \"spot\" Callaway" <tcallawa@redhat.com>, David Miller <davem@davemloft.net>, akpm@linux-foundation.org, mark@mtfhpc.demon.co.uk, linuxppc-dev@ozlabs.org, wli@holomorphy.com, linux-mm@kvack.org, andrea@suse.de, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Looks pretty good to me.
> 
> There was a minor build error in x86 (see below), and ia64 is missing
> (again see below).  I've now built and am running this on x86, x86_64
> and powerpc64; but I'm very unlikely to be doing anything which
> actually tickles these changes, or Andrea's original handle_pte_fault
> optimization.

Ok.

> Would the "__changed && __dirty" architectures (x86, x86_64, ia64)
> be better off saying __changed = __dirty && pte_same?  I doubt it's
> worth bothering about.

I'd say let gcc figure it out :-)

> You've updated do_wp_page to do "if (ptep_set_access_flags(...",
> but not updated set_huge_ptep_writable in the same way: I'd have
> thought you'd either leave both alone, or update them both: any
> reason for one not the other?  But again, not really an issue.

Nah, I must have missed set_huge_ptep_writable(). I don't think the wp
code path matters much anyway, it's likely to always be different.

> These changes came about because the sun4c needs to update_mmu_cache
> even in the pte_same case: might it also need to flush_tlb_page then?

Well, I don't know which is why I'm waiting for Tom Callaway to test.
Davem mentioned update_mmu_cache only though when we discussed the
problem initially.

> >  #define  __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
> >  #define ptep_set_access_flags(vma, address, ptep, entry, dirty)		\
> > -do {									\
> > -	if (dirty) {							\
> > +({									\
> > +	int __changed = !pte_same(*(__ptep), __entry);			\
> 
> That just needs to be:
> 
>   +	int __changed = !pte_same(*(ptep), entry);			\

Ah yes, sorry about that. I need to setup an x86 toolchain somewhere :-)

> Here's what I think the ia64 hunk would be, unbuilt and untested.

Ok.

I'll respin a patch later today.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
