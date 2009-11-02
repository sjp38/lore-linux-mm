Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 596BA6B0044
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 17:19:37 -0500 (EST)
Subject: Re: Filtering bits in set_pte_at()
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.64.0911021256330.32400@sister.anvils>
References: <1256957081.6372.344.camel@pasglop>
	 <Pine.LNX.4.64.0911021256330.32400@sister.anvils>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 03 Nov 2009 09:19:27 +1100
Message-ID: <1257200367.7907.50.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org
List-ID: <linux-mm.kvack.org>

On Mon, 2009-11-02 at 13:27 +0000, Hugh Dickins wrote:
> On Sat, 31 Oct 2009, Benjamin Herrenschmidt wrote:
> 
> > Hi folks !
> > 
> > So I have a little problem on powerpc ... :-)
> 
> Thanks a lot for running this by us.

Heh, I though you may have been bored :-)

> I've not looked to see if there are more such issues in arch/powerpc
> itself, but those instances you mention are the only ones I managed
> to find: uses of update_mmu_cache() and that hugetlb_cow() one.

Right, that's all I spotted so far

> The hugetlb_cow() one involves not set_pte_at() but set_huge_pte_at(),
> so you'd want to change that too?  And presumably set_pte_at_notify()?
> It all seems a lot of tedium, when so very few places are interested
> in the pte after they've set it.

We need to change set_huge_pte_at() too. Currently, David fixed the
problem in a local tree by making hugetlb_cow() re-read the PTE . 

set_pte_at_notify() would probably be similar, I'm not too familiar with
its usage scenario yet to be honest.

> > What do you suggest we do here ? Among the options at hand:
> > 
> >  - Ugly but would probably "just work" with the last amount of changes:
> > we could make set_pte_at() be a macro on powerpc that modifies it's PTE
> > value argument :-) (I -did- warn it was ugly !)
> 
> I'm not keen on that one :)

Yeah. Me neither :-)

> >  - Another one slightly less bad that would require more work but mostly
> > mechanical arch header updates would be to make set_pte_at() return the
> > new value of the PTE, and thus change the callsites to something like:
> > 
> > 	entry = set_pte_at(mm, addr, ptep, entry)
> 
> I prefer that, but it still seems more trouble than it's worth.

Right. I was hoping you might have a better idea :-)

> And though I prefer it to set_pte_at(mm, addr, ptep, &entry)
> (which would anyway complicate many of the callsites), it might
> unnecessarily increase the codesize for all architectures (depends
> on whether gcc notices entry isn't used afterwards anyway).

Macro or static inlines back to __set_pte_at(..., entry) in those archs
would probably take care of avoiding the bloat but still a lot of churn.
> >
> >  - Any other idea ? We could use another PTE bit (_PAGE_HWEXEC), in
> > fact, we used to, but we are really short on PTE bits nowadays and I
> > freed that one up to get _PAGE_SPECIAL... _PAGE_EXEC is trivial to
> > "recover" from ptep_set_access_flags() on an exec fault or from the VM
> > prot.
> 
> No, please don't go ransacking your PTE for a sparish bit.

Yeah, the whole exercise for me was initially to -save- PTE bits :-)

> You're being a very good citizen to want to bring this so forcefully
> to the attention of any user of set_pte_at(); but given how few care,
> and the other such functions you'd want to change too, am I being
> disgracefully lazy to suggest that you simply change the occasional
> 
> 		update_mmu_cache(vma, address, pte);
> to
> 		/* powerpc's set_pte_at might have adjusted the pte */
> 		update_mmu_cache(vma, address, *ptep);
> 
> ?  Which would make no difference to those architectures whose
> update_mmu_cache() is an empty macro.  And fix the mm/hugetlb.c
> instance in a similar way?

That would do fine. In fact, I've always been slightly annoyed by
set_pte_at() not taking the PTE pointer for other reasons such as on
64-K pages, we have a "hidden" part of the PTE that is at PTE address +
32K, or we may want to get to the PTE page for some reason (some arch
store things there) etc...

IE. update_mmu_cache() would be more generally useful if it took the
ptep instead of the pte. Of course, I'm sure some embedded archs are
going to cry for the added load here ... 

I like your idea. I'll look into doing a patch converting it and will
post it here.

Thanks !

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
