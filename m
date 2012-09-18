Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id CCE546B0072
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 15:33:33 -0400 (EDT)
Date: Tue, 18 Sep 2012 12:33:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] mm: thp: Fix the update_mmu_cache() last argument
 passing in mm/huge_memory.c
Message-Id: <20120918123331.6ca5833c.akpm@linux-foundation.org>
In-Reply-To: <20120915133833.GA32398@linux-mips.org>
References: <1347382036-18455-1-git-send-email-will.deacon@arm.com>
	<1347382036-18455-3-git-send-email-will.deacon@arm.com>
	<20120915133833.GA32398@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ralf Baechle <ralf@linux-mips.org>
Cc: Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, mhocko@suse.cz, Catalin Marinas <catalin.marinas@arm.com>, Steve Capper <steve.capper@arm.com>

On Sat, 15 Sep 2012 15:38:33 +0200
Ralf Baechle <ralf@linux-mips.org> wrote:

> On Tue, Sep 11, 2012 at 05:47:15PM +0100, Will Deacon wrote:
> 
> > The update_mmu_cache() takes a pointer (to pte_t by default) as the last
> > argument but the huge_memory.c passes a pmd_t value. The patch changes
> > the argument to the pmd_t * pointer.
> > 
> > Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> > Signed-off-by: Steve Capper <steve.capper@arm.com>
> > Signed-off-by: Will Deacon <will.deacon@arm.com>
> > ---
> >  mm/huge_memory.c |    6 +++---
> >  1 files changed, 3 insertions(+), 3 deletions(-)
> > 
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index 57c4b93..4aa6d02 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -934,7 +934,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
> >  		entry = pmd_mkyoung(orig_pmd);
> >  		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
> >  		if (pmdp_set_access_flags(vma, haddr, pmd, entry,  1))
> > -			update_mmu_cache(vma, address, entry);
> > +			update_mmu_cache(vma, address, pmd);
> 
> Documentation/cachetlb.txt will need an update as well.  Currently it says:
> 
> 5) void update_mmu_cache(struct vm_area_struct *vma,
>                          unsigned long address, pte_t *ptep)

Yes please.

> I would prefer we introduce something like update_mmu_cache_huge_page(vma,
> address, pmd) and leave the classic update_mmu_cache() unchanged.

Why?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
