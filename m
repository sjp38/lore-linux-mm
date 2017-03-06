Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 080DB6B0388
	for <linux-mm@kvack.org>; Sun,  5 Mar 2017 20:44:53 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 187so36678214pgb.3
        for <linux-mm@kvack.org>; Sun, 05 Mar 2017 17:44:52 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id p6si17508978pfp.204.2017.03.05.17.44.51
        for <linux-mm@kvack.org>;
        Sun, 05 Mar 2017 17:44:52 -0800 (PST)
Date: Mon, 6 Mar 2017 10:44:46 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/4] thp: fix MADV_DONTNEED vs. MADV_FREE race
Message-ID: <20170306014446.GB8779@bbox>
References: <20170302151034.27829-1-kirill.shutemov@linux.intel.com>
 <20170302151034.27829-4-kirill.shutemov@linux.intel.com>
 <07b101d293df$ed8c9850$c8a5c8f0$@alibaba-inc.com>
 <20170303102636.bhd2zhtpds4mt62a@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170303102636.bhd2zhtpds4mt62a@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello, Kirill,

On Fri, Mar 03, 2017 at 01:26:36PM +0300, Kirill A. Shutemov wrote:
> On Fri, Mar 03, 2017 at 01:35:11PM +0800, Hillf Danton wrote:
> > 
> > On March 02, 2017 11:11 PM Kirill A. Shutemov wrote: 
> > > 
> > > Basically the same race as with numa balancing in change_huge_pmd(), but
> > > a bit simpler to mitigate: we don't need to preserve dirty/young flags
> > > here due to MADV_FREE functionality.
> > > 
> > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > Cc: Minchan Kim <minchan@kernel.org>
> > > ---
> > >  mm/huge_memory.c | 2 --
> > >  1 file changed, 2 deletions(-)
> > > 
> > > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > > index bb2b3646bd78..324217c31ec9 100644
> > > --- a/mm/huge_memory.c
> > > +++ b/mm/huge_memory.c
> > > @@ -1566,8 +1566,6 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
> > >  		deactivate_page(page);
> > > 
> > >  	if (pmd_young(orig_pmd) || pmd_dirty(orig_pmd)) {
> > > -		orig_pmd = pmdp_huge_get_and_clear_full(tlb->mm, addr, pmd,
> > > -			tlb->fullmm);
> > >  		orig_pmd = pmd_mkold(orig_pmd);
> > >  		orig_pmd = pmd_mkclean(orig_pmd);
> > > 
> > $ grep -n set_pmd_at  linux-4.10/arch/powerpc/mm/pgtable-book3s64.c
> > 
> > /*
> >  * set a new huge pmd. We should not be called for updating
> >  * an existing pmd entry. That should go via pmd_hugepage_update.
> >  */
> > void set_pmd_at(struct mm_struct *mm, unsigned long addr,
> 
> +Aneesh.
> 
> Urgh... Power is special again.
> 
> I think this should work fine.
> 
> From 056914fa025992c0a2212aee057c26307ce60238 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Thu, 2 Mar 2017 16:47:45 +0300
> Subject: [PATCH] thp: fix MADV_DONTNEED vs. MADV_FREE race
> 
> Basically the same race as with numa balancing in change_huge_pmd(), but
> a bit simpler to mitigate: we don't need to preserve dirty/young flags
> here due to MADV_FREE functionality.

Could you elaborate a bit more here rather than relying on other
patch's description?

And could you say what happens to the userspace if that race
happens? When I guess from title "MADV_DONTNEED vs MADV_FREE",
a page cannot be zapped but marked lazyfree or vise versa? Right?

Thanks.

> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Minchan Kim <minchan@kernel.org>
> ---
>  mm/huge_memory.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index bb2b3646bd78..23c1b3d58cf4 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1566,8 +1566,7 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  		deactivate_page(page);
>  
>  	if (pmd_young(orig_pmd) || pmd_dirty(orig_pmd)) {
> -		orig_pmd = pmdp_huge_get_and_clear_full(tlb->mm, addr, pmd,
> -			tlb->fullmm);
> +		pmdp_invalidate(vma, addr, pmd);
>  		orig_pmd = pmd_mkold(orig_pmd);
>  		orig_pmd = pmd_mkclean(orig_pmd);
>  
> -- 
>  Kirill A. Shutemov
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
