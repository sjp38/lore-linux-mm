Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id E49366B02E7
	for <linux-mm@kvack.org>; Sun, 24 Jun 2012 15:52:42 -0400 (EDT)
Date: Sun, 24 Jun 2012 15:52:36 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [patch v2] mm, thp: print useful information when mmap_sem is
 unlocked in zap_pmd_range
Message-ID: <20120624195236.GA2153@redhat.com>
References: <20120606165330.GA27744@redhat.com>
 <alpine.DEB.2.00.1206091904030.7832@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1206110214150.6843@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1206221405430.20954@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206221405430.20954@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <levinsasha928@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jun 22, 2012 at 02:06:40PM -0700, David Rientjes wrote:
 > On Mon, 11 Jun 2012, David Rientjes wrote:
 > 
 > > diff --git a/mm/memory.c b/mm/memory.c
 > > --- a/mm/memory.c
 > > +++ b/mm/memory.c
 > > @@ -1225,7 +1225,15 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 > >  		next = pmd_addr_end(addr, end);
 > >  		if (pmd_trans_huge(*pmd)) {
 > >  			if (next - addr != HPAGE_PMD_SIZE) {
 > > -				VM_BUG_ON(!rwsem_is_locked(&tlb->mm->mmap_sem));
 > > +#ifdef CONFIG_DEBUG_VM
 > > +				if (!rwsem_is_locked(&tlb->mm->mmap_sem)) {
 > > +					pr_err("%s: mmap_sem is unlocked! addr=0x%lx end=0x%lx vma->vm_start=0x%lx vma->vm_end=0x%lx\n",
 > > +						__func__, addr, end,
 > > +						vma->vm_start,
 > > +						vma->vm_end);
 > > +					BUG();
 > > +				}
 > > +#endif
 > >  				split_huge_page_pmd(vma->vm_mm, pmd);
 > >  			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
 > >  				goto next;
 > 
 > This patch is now in Linus' tree so if you are able to hit this issue and 
 > capture it again, we should be able to get much more useful information.

I've had it applied in my local builds for a while, but haven't managed
to hit it again recently.  Though I've not been doing as many overnight runs
this last week or two because temperatures at home have been icky enough
without computers belching out hot air (no ac)

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
