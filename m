Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 9CEC96B00E5
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 11:52:11 -0400 (EDT)
Date: Wed, 12 Sep 2012 16:51:35 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 2/3] mm: thp: Fix the update_mmu_cache() last argument
 passing in mm/huge_memory.c
Message-ID: <20120912155135.GD10698@arm.com>
References: <1347382036-18455-1-git-send-email-will.deacon@arm.com>
 <1347382036-18455-3-git-send-email-will.deacon@arm.com>
 <20120912154037.GU21579@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120912154037.GU21579@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Will Deacon <Will.Deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Steve Capper <Steve.Capper@arm.com>

On Wed, Sep 12, 2012 at 04:40:37PM +0100, Michal Hocko wrote:
> On Tue 11-09-12 17:47:15, Will Deacon wrote:
> > From: Catalin Marinas <catalin.marinas@arm.com>
> > 
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
> I am not sure but shouldn't we use the new entry rather than the given
> pmd?

The pmd pointer is the new pmd and 'entry' is the new value derived from
orig_pmd. update_mmu_cache() expects a pointer to pte_t or pmd_t rather
than it's value.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
