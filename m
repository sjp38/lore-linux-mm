Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75B096B0277
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 13:05:51 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id v198-v6so12235944qka.16
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 10:05:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t16-v6si345300qvh.46.2018.10.12.10.05.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 10:05:50 -0700 (PDT)
Date: Fri, 12 Oct 2018 13:05:44 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH] mm/thp: fix call to mmu_notifier in
 set_pmd_migration_entry()
Message-ID: <20181012170544.GA6593@redhat.com>
References: <20181012160953.5841-1-jglisse@redhat.com>
 <20181012165548.GZ5873@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181012165548.GZ5873@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Zi Yan <zi.yan@cs.rutgers.edu>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, David Nellans <dnellans@nvidia.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>

On Fri, Oct 12, 2018 at 06:55:48PM +0200, Michal Hocko wrote:
> On Fri 12-10-18 12:09:53, jglisse@redhat.com wrote:
> > From: Jerome Glisse <jglisse@redhat.com>
> > 
> > Inside set_pmd_migration_entry() we are holding page table locks and
> > thus we can not sleep so we can not call invalidate_range_start/end()
> > 
> > So remove call to mmu_notifier_invalidate_range_start/end() and add
> > call to mmu_notifier_invalidate_range(). Note that we are already
> > calling mmu_notifier_invalidate_range_start/end() inside the function
> > calling set_pmd_migration_entry() (see try_to_unmap_one()).
> > 
> > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > Reported-by: Andrea Arcangeli <aarcange@redhat.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > Cc: Zi Yan <zi.yan@cs.rutgers.edu>
> > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: "H. Peter Anvin" <hpa@zytor.com>
> > Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> > Cc: Dave Hansen <dave.hansen@intel.com>
> > Cc: David Nellans <dnellans@nvidia.com>
> > Cc: Ingo Molnar <mingo@elte.hu>
> > Cc: Mel Gorman <mgorman@techsingularity.net>
> > Cc: Minchan Kim <minchan@kernel.org>
> > Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Cc: Thomas Gleixner <tglx@linutronix.de>
> > Cc: Vlastimil Babka <vbabka@suse.cz>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Andrea Arcangeli <aarcange@redhat.com>
> 
> Is this worth backporting to stable trees?

Yes it is i forgot to cc stable :(


> 
> The patch looks good to me
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> > ---
> >  mm/huge_memory.c | 7 +------
> >  1 file changed, 1 insertion(+), 6 deletions(-)
> > 
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index 533f9b00147d..93cb80fe12cb 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -2885,9 +2885,6 @@ void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
> >  	if (!(pvmw->pmd && !pvmw->pte))
> >  		return;
> >  
> > -	mmu_notifier_invalidate_range_start(mm, address,
> > -			address + HPAGE_PMD_SIZE);
> > -
> >  	flush_cache_range(vma, address, address + HPAGE_PMD_SIZE);
> >  	pmdval = *pvmw->pmd;
> >  	pmdp_invalidate(vma, address, pvmw->pmd);
> > @@ -2898,11 +2895,9 @@ void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
> >  	if (pmd_soft_dirty(pmdval))
> >  		pmdswp = pmd_swp_mksoft_dirty(pmdswp);
> >  	set_pmd_at(mm, address, pvmw->pmd, pmdswp);
> > +	mmu_notifier_invalidate_range(mm, address, address + HPAGE_PMD_SIZE);
> >  	page_remove_rmap(page, true);
> >  	put_page(page);
> > -
> > -	mmu_notifier_invalidate_range_end(mm, address,
> > -			address + HPAGE_PMD_SIZE);
> >  }
> >  
> >  void remove_migration_pmd(struct page_vma_mapped_walk *pvmw, struct page *new)
> > -- 
> > 2.17.2
> 
> -- 
> Michal Hocko
> SUSE Labs
