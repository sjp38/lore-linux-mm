Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 702F56B026B
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 13:35:25 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id i64-v6so12736036qtb.21
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 10:35:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b5-v6si1714965qkb.241.2018.10.12.10.35.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 10:35:24 -0700 (PDT)
Date: Fri, 12 Oct 2018 13:35:19 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH] mm/thp: fix call to mmu_notifier in
 set_pmd_migration_entry()
Message-ID: <20181012173518.GD6593@redhat.com>
References: <20181012160953.5841-1-jglisse@redhat.com>
 <DB07F115-B404-4AB0-9D54-BC20C3A3F2B0@cs.rutgers.edu>
 <20181012172422.GA7395@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181012172422.GA7395@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, David Nellans <dnellans@nvidia.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>

On Fri, Oct 12, 2018 at 01:24:22PM -0400, Andrea Arcangeli wrote:
> Hello,
> 
> On Fri, Oct 12, 2018 at 12:20:54PM -0400, Zi Yan wrote:
> > On 12 Oct 2018, at 12:09, jglisse@redhat.com wrote:
> > 
> > > From: Jerome Glisse <jglisse@redhat.com>
> > >
> > > Inside set_pmd_migration_entry() we are holding page table locks and
> > > thus we can not sleep so we can not call invalidate_range_start/end()
> > >
> > > So remove call to mmu_notifier_invalidate_range_start/end() and add
> > > call to mmu_notifier_invalidate_range(). Note that we are already
> 
> Why the call to mmu_notifier_invalidate_range if we're under
> range_start and followed by range_end? (it's not _range_only_end, if
> it was _range_only_end the above would be needed)

I wanted to be extra safe and accept to over invalidate. You are right
that it is not strictly necessary. I am fine with removing it.

> 
> > > calling mmu_notifier_invalidate_range_start/end() inside the function
> > > calling set_pmd_migration_entry() (see try_to_unmap_one()).
> > >
> > > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > > Reported-by: Andrea Arcangeli <aarcange@redhat.com>
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > > Cc: Zi Yan <zi.yan@cs.rutgers.edu>
> > > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > Cc: "H. Peter Anvin" <hpa@zytor.com>
> > > Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> > > Cc: Dave Hansen <dave.hansen@intel.com>
> > > Cc: David Nellans <dnellans@nvidia.com>
> > > Cc: Ingo Molnar <mingo@elte.hu>
> > > Cc: Mel Gorman <mgorman@techsingularity.net>
> > > Cc: Minchan Kim <minchan@kernel.org>
> > > Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > > Cc: Thomas Gleixner <tglx@linutronix.de>
> > > Cc: Vlastimil Babka <vbabka@suse.cz>
> > > Cc: Michal Hocko <mhocko@kernel.org>
> > > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > > ---
> > >  mm/huge_memory.c | 7 +------
> > >  1 file changed, 1 insertion(+), 6 deletions(-)
> > >
> > > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > > index 533f9b00147d..93cb80fe12cb 100644
> > > --- a/mm/huge_memory.c
> > > +++ b/mm/huge_memory.c
> > > @@ -2885,9 +2885,6 @@ void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
> > >  	if (!(pvmw->pmd && !pvmw->pte))
> > >  		return;
> > >
> > > -	mmu_notifier_invalidate_range_start(mm, address,
> > > -			address + HPAGE_PMD_SIZE);
> > > -
> > >  	flush_cache_range(vma, address, address + HPAGE_PMD_SIZE);
> > >  	pmdval = *pvmw->pmd;
> > >  	pmdp_invalidate(vma, address, pvmw->pmd);
> > > @@ -2898,11 +2895,9 @@ void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
> > >  	if (pmd_soft_dirty(pmdval))
> > >  		pmdswp = pmd_swp_mksoft_dirty(pmdswp);
> > >  	set_pmd_at(mm, address, pvmw->pmd, pmdswp);
> > > +	mmu_notifier_invalidate_range(mm, address, address + HPAGE_PMD_SIZE);
> 
> It's not obvious why it's needed, if it's needed maybe a comment can
> be added.

We can remove it. Should i post a v2 without it ?

Cheers,
Jerome
