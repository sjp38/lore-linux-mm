Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D3DD86B0394
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 01:17:30 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id b2so41894285pgc.6
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 22:17:30 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id c11si2272307pgn.188.2017.03.07.22.17.29
        for <linux-mm@kvack.org>;
        Tue, 07 Mar 2017 22:17:30 -0800 (PST)
Date: Wed, 8 Mar 2017 15:17:26 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/4] thp: fix MADV_DONTNEED vs. MADV_FREE race
Message-ID: <20170308061726.GD11206@bbox>
References: <20170302151034.27829-1-kirill.shutemov@linux.intel.com>
 <20170302151034.27829-4-kirill.shutemov@linux.intel.com>
 <07b101d293df$ed8c9850$c8a5c8f0$@alibaba-inc.com>
 <20170303102636.bhd2zhtpds4mt62a@black.fi.intel.com>
 <20170306014446.GB8779@bbox>
 <20170307140453.GB2412@node>
MIME-Version: 1.0
In-Reply-To: <20170307140453.GB2412@node>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 07, 2017 at 05:04:53PM +0300, Kirill A. Shutemov wrote:
> On Mon, Mar 06, 2017 at 10:44:46AM +0900, Minchan Kim wrote:
> > Hello, Kirill,
> > 
> > On Fri, Mar 03, 2017 at 01:26:36PM +0300, Kirill A. Shutemov wrote:
> > > On Fri, Mar 03, 2017 at 01:35:11PM +0800, Hillf Danton wrote:
> > > > 
> > > > On March 02, 2017 11:11 PM Kirill A. Shutemov wrote: 
> > > > > 
> > > > > Basically the same race as with numa balancing in change_huge_pmd(), but
> > > > > a bit simpler to mitigate: we don't need to preserve dirty/young flags
> > > > > here due to MADV_FREE functionality.
> > > > > 
> > > > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > > > Cc: Minchan Kim <minchan@kernel.org>
> > > > > ---
> > > > >  mm/huge_memory.c | 2 --
> > > > >  1 file changed, 2 deletions(-)
> > > > > 
> > > > > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > > > > index bb2b3646bd78..324217c31ec9 100644
> > > > > --- a/mm/huge_memory.c
> > > > > +++ b/mm/huge_memory.c
> > > > > @@ -1566,8 +1566,6 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
> > > > >  		deactivate_page(page);
> > > > > 
> > > > >  	if (pmd_young(orig_pmd) || pmd_dirty(orig_pmd)) {
> > > > > -		orig_pmd = pmdp_huge_get_and_clear_full(tlb->mm, addr, pmd,
> > > > > -			tlb->fullmm);
> > > > >  		orig_pmd = pmd_mkold(orig_pmd);
> > > > >  		orig_pmd = pmd_mkclean(orig_pmd);
> > > > > 
> > > > $ grep -n set_pmd_at  linux-4.10/arch/powerpc/mm/pgtable-book3s64.c
> > > > 
> > > > /*
> > > >  * set a new huge pmd. We should not be called for updating
> > > >  * an existing pmd entry. That should go via pmd_hugepage_update.
> > > >  */
> > > > void set_pmd_at(struct mm_struct *mm, unsigned long addr,
> > > 
> > > +Aneesh.
> > > 
> > > Urgh... Power is special again.
> > > 
> > > I think this should work fine.
> > > 
> > > From 056914fa025992c0a2212aee057c26307ce60238 Mon Sep 17 00:00:00 2001
> > > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > > Date: Thu, 2 Mar 2017 16:47:45 +0300
> > > Subject: [PATCH] thp: fix MADV_DONTNEED vs. MADV_FREE race
> > > 
> > > Basically the same race as with numa balancing in change_huge_pmd(), but
> > > a bit simpler to mitigate: we don't need to preserve dirty/young flags
> > > here due to MADV_FREE functionality.
> > 
> > Could you elaborate a bit more here rather than relying on other
> > patch's description?
> 
> Okay, updated patch is below.

Thanks. It looks much better.

> 
> > And could you say what happens to the userspace if that race
> > happens? When I guess from title "MADV_DONTNEED vs MADV_FREE",
> > a page cannot be zapped but marked lazyfree or vise versa? Right?
> 
> "Vise versa" part should be fine. The case I'm worry about is that
> MADV_DONTNEED would skip the pmd and it will not be cleared.
> Userspace expects the area of memory to be clean after MADV_DONTNEED, but
> it's not. It can lead to userspace misbehaviour.

Yeb.

> 
> From a0967b0293a6f8053d85785c4d6340e550e849ea Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Thu, 2 Mar 2017 16:47:45 +0300
> Subject: [PATCH] thp: fix MADV_DONTNEED vs. MADV_FREE race
> 
> Both MADV_DONTNEED and MADV_FREE handled with down_read(mmap_sem).
> It's critical to not clear pmd intermittently while handling MADV_FREE to
> avoid race with MADV_DONTNEED:
> 
> 	CPU0:				CPU1:
> 				madvise_free_huge_pmd()
> 				 pmdp_huge_get_and_clear_full()
> madvise_dontneed()
>  zap_pmd_range()
>   pmd_trans_huge(*pmd) == 0 (without ptl)
>   // skip the pmd
> 				 set_pmd_at();
> 				 // pmd is re-established
> 
> It results in MADV_DONTNEED skipping the pmd, leaving it not cleared. It
> violates MADV_DONTNEED interface and can result is userspace misbehaviour.
> 
> Basically it's the same race as with numa balancing in change_huge_pmd(),
> but a bit simpler to mitigate: we don't need to preserve dirty/young flags
> here due to MADV_FREE functionality.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Minchan Kim <minchan@kernel.org>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
