Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D72576B004D
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 06:20:23 -0400 (EDT)
Subject: Re: update_mmu_cache() when write protecting pte.
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.64.0909241310350.9528@sister.anvils>
References: <20090923232221.1d566a5c@woof.woof>
	 <Pine.LNX.4.64.0909241310350.9528@sister.anvils>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 06 Oct 2009 21:20:16 +1100
Message-Id: <1254824416.6035.7.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Izik Eidus <ieidus@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, davem@redhat.com, aarcange@redhat.com, gleb@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, 2009-09-24 at 13:39 +0100, Hugh Dickins wrote:
> Added linux-arch to Cc list.
> 
> On Wed, 23 Sep 2009, Izik Eidus wrote:
> 
> > Hi, Hugh just found out that ksm was not calling to update_mmu_cache()
> > after it set new pte when it changed ptes mapping to point into the new
> > shared-readonly page (ksmpage).
> > 
> > It is understandable that it is a bug and ksm have to call it right
> > after set_pte_at_notify() get called, but the question is: does ksm
> > have to call it only there or should it call it even when it
> > write-protect pte (while not changing the physical address the pte is
> > pointing to).
> 
> I'm currently inclining to the view that it's only necessary to call
> update_mmu_cache() in faulting paths (as cachetlb.txt says), and would
> just be a waste of time and cache to call it from KSM (which, like
> mprotect, has no reason to suppose that the pte will soon be faulted).

I tend to agree.

The way we use update_mmu_cache() on ppc for example is to pre-fault in
the hash table or the TLB. Typically this is used to avoid a second
fault (TLB miss or hash miss) after a page fault.

I think it would be detrimental to have it called more often in cases
that aren't very likely to be accessed right away.

> Documentation/cachetlb.txt is specific when it says:
> 	At the end of every page fault, this routine is invoked...
> But less so when it says:
> 	A port may use this information in any way it so chooses.
> 
> In private mail, I was worrying about how mprotect does not call
> update_mmu_cache, and thinking of the race when mprotect makes a pte
> writable while a write access is coming down through handle_pte_fault:
> such that handle_pte_fault skips its update_mmu_cache: but hadn't
> noticed the "else" there, which will flush_tlb_page to reset the
> condition, so we don't have repeated faults on those architectures
> which are liable to that if the update_mmu_cache() is missed.
> 
> I think now that neither replace_page() nor write_protect_page() should
> update_mmu_cache(); but my mind may change in a few moments time ;)

Heh. That's VM for you :-)

Cheers,
Ben.

> Hugh
> 
> > 
> > I am asking this question because it seems that fork() dont call it...
> > 
> > (below a patch that fix the problem in case we need it just when we
> > change the physical mapping, if we need it even when we write protect
> > the pages, then we need to add another update_mmu_cache()  call)
> > 
> > Thanks.
> > 
> > From 82d27f67a8b20767dc6119422189f73b52168c8d Mon Sep 17 00:00:00 2001
> > From: Izik Eidus <ieidus@redhat.com>
> > Date: Wed, 23 Sep 2009 22:37:34 +0300
> > Subject: [PATCH] ksm: add update_mmu_cache() when changing pte mapping.
> > 
> > This patch add update_mmu_cache() call right after set_pte_at_notify()
> > Without this function ksm is probably broken for powerpc and sparc archs.
> > 
> > (Noticed by Hugh Dickins)
> > 
> > Signed-off-by: Izik Eidus <ieidus@redhat.com>
> > ---
> >  mm/ksm.c |    1 +
> >  1 files changed, 1 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/ksm.c b/mm/ksm.c
> > index f7edac3..e8d16eb 100644
> > --- a/mm/ksm.c
> > +++ b/mm/ksm.c
> > @@ -719,6 +719,7 @@ static int replace_page(struct vm_area_struct *vma, struct page *oldpage,
> >  	flush_cache_page(vma, addr, pte_pfn(*ptep));
> >  	ptep_clear_flush(vma, addr, ptep);
> >  	set_pte_at_notify(mm, addr, ptep, mk_pte(newpage, prot));
> > +	update_mmu_cache(vma, addr, pte);
> >  
> >  	page_remove_rmap(oldpage);
> >  	put_page(oldpage);
> > -- 
> > 1.5.6.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
