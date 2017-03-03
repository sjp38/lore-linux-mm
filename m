Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7C39E6B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 05:26:40 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id b2so121822648pgc.6
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 02:26:40 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id g11si10209281pln.0.2017.03.03.02.26.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 02:26:39 -0800 (PST)
Date: Fri, 3 Mar 2017 13:26:36 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 3/4] thp: fix MADV_DONTNEED vs. MADV_FREE race
Message-ID: <20170303102636.bhd2zhtpds4mt62a@black.fi.intel.com>
References: <20170302151034.27829-1-kirill.shutemov@linux.intel.com>
 <20170302151034.27829-4-kirill.shutemov@linux.intel.com>
 <07b101d293df$ed8c9850$c8a5c8f0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <07b101d293df$ed8c9850$c8a5c8f0$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: 'Andrea Arcangeli' <aarcange@redhat.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Minchan Kim' <minchan@kernel.org>

On Fri, Mar 03, 2017 at 01:35:11PM +0800, Hillf Danton wrote:
> 
> On March 02, 2017 11:11 PM Kirill A. Shutemov wrote: 
> > 
> > Basically the same race as with numa balancing in change_huge_pmd(), but
> > a bit simpler to mitigate: we don't need to preserve dirty/young flags
> > here due to MADV_FREE functionality.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: Minchan Kim <minchan@kernel.org>
> > ---
> >  mm/huge_memory.c | 2 --
> >  1 file changed, 2 deletions(-)
> > 
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index bb2b3646bd78..324217c31ec9 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -1566,8 +1566,6 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
> >  		deactivate_page(page);
> > 
> >  	if (pmd_young(orig_pmd) || pmd_dirty(orig_pmd)) {
> > -		orig_pmd = pmdp_huge_get_and_clear_full(tlb->mm, addr, pmd,
> > -			tlb->fullmm);
> >  		orig_pmd = pmd_mkold(orig_pmd);
> >  		orig_pmd = pmd_mkclean(orig_pmd);
> > 
> $ grep -n set_pmd_at  linux-4.10/arch/powerpc/mm/pgtable-book3s64.c
> 
> /*
>  * set a new huge pmd. We should not be called for updating
>  * an existing pmd entry. That should go via pmd_hugepage_update.
>  */
> void set_pmd_at(struct mm_struct *mm, unsigned long addr,

+Aneesh.

Urgh... Power is special again.

I think this should work fine.
