Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 72B976B004D
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 08:28:09 -0500 (EST)
Date: Mon, 2 Nov 2009 13:27:59 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: Filtering bits in set_pte_at()
In-Reply-To: <1256957081.6372.344.camel@pasglop>
Message-ID: <Pine.LNX.4.64.0911021256330.32400@sister.anvils>
References: <1256957081.6372.344.camel@pasglop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org
List-ID: <linux-mm.kvack.org>

On Sat, 31 Oct 2009, Benjamin Herrenschmidt wrote:

> Hi folks !
> 
> So I have a little problem on powerpc ... :-)

Thanks a lot for running this by us.

> 
> Due to the way I'm attempting to do my I$/D$ coherency on embedded
> processors, I basically need to "filter out" _PAGE_EXEC in set_pte_at()
> if the page isn't clean (PG_arch_1) and the set_pte_at() isn't caused by
> an exec fault. etc...
> 
> The problem with that approach (current upstream) is that the generic
> code tends not to read back the PTE, and thus still carries around a PTE
> value that doesn't match what was actually written.
> 
> For example, we end up with update_mmu_cache() called with an "entry"
> argument that has _PAGE_EXEC set while we really didn't write it into
> the page tables. This will be problematic when we finally add preloading
> directly into the TLB on those processors. There's at least one other
> fishy case where huetlbfs would carry the PTE value around and later do
> the wrong thing because pte_same() with the loaded one failed.

I've not looked to see if there are more such issues in arch/powerpc
itself, but those instances you mention are the only ones I managed
to find: uses of update_mmu_cache() and that hugetlb_cow() one.

The hugetlb_cow() one involves not set_pte_at() but set_huge_pte_at(),
so you'd want to change that too?  And presumably set_pte_at_notify()?
It all seems a lot of tedium, when so very few places are interested
in the pte after they've set it.

> 
> What do you suggest we do here ? Among the options at hand:
> 
>  - Ugly but would probably "just work" with the last amount of changes:
> we could make set_pte_at() be a macro on powerpc that modifies it's PTE
> value argument :-) (I -did- warn it was ugly !)

I'm not keen on that one :)

> 
>  - Another one slightly less bad that would require more work but mostly
> mechanical arch header updates would be to make set_pte_at() return the
> new value of the PTE, and thus change the callsites to something like:
> 
> 	entry = set_pte_at(mm, addr, ptep, entry)

I prefer that, but it still seems more trouble than it's worth.

And though I prefer it to set_pte_at(mm, addr, ptep, &entry)
(which would anyway complicate many of the callsites), it might
unnecessarily increase the codesize for all architectures (depends
on whether gcc notices entry isn't used afterwards anyway).

> 
>  - Any other idea ? We could use another PTE bit (_PAGE_HWEXEC), in
> fact, we used to, but we are really short on PTE bits nowadays and I
> freed that one up to get _PAGE_SPECIAL... _PAGE_EXEC is trivial to
> "recover" from ptep_set_access_flags() on an exec fault or from the VM
> prot.

No, please don't go ransacking your PTE for a sparish bit.

You're being a very good citizen to want to bring this so forcefully
to the attention of any user of set_pte_at(); but given how few care,
and the other such functions you'd want to change too, am I being
disgracefully lazy to suggest that you simply change the occasional

		update_mmu_cache(vma, address, pte);
to
		/* powerpc's set_pte_at might have adjusted the pte */
		update_mmu_cache(vma, address, *ptep);

?  Which would make no difference to those architectures whose
update_mmu_cache() is an empty macro.  And fix the mm/hugetlb.c
instance in a similar way?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
