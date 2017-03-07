Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 59DD66B0388
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 09:04:58 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id v190so1715501wme.0
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 06:04:58 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id l135si685099wma.19.2017.03.07.06.04.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 06:04:57 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id u132so1166655wmg.1
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 06:04:56 -0800 (PST)
Date: Tue, 7 Mar 2017 17:04:53 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 3/4] thp: fix MADV_DONTNEED vs. MADV_FREE race
Message-ID: <20170307140453.GB2412@node>
References: <20170302151034.27829-1-kirill.shutemov@linux.intel.com>
 <20170302151034.27829-4-kirill.shutemov@linux.intel.com>
 <07b101d293df$ed8c9850$c8a5c8f0$@alibaba-inc.com>
 <20170303102636.bhd2zhtpds4mt62a@black.fi.intel.com>
 <20170306014446.GB8779@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170306014446.GB8779@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Mar 06, 2017 at 10:44:46AM +0900, Minchan Kim wrote:
> Hello, Kirill,
> 
> On Fri, Mar 03, 2017 at 01:26:36PM +0300, Kirill A. Shutemov wrote:
> > On Fri, Mar 03, 2017 at 01:35:11PM +0800, Hillf Danton wrote:
> > > 
> > > On March 02, 2017 11:11 PM Kirill A. Shutemov wrote: 
> > > > 
> > > > Basically the same race as with numa balancing in change_huge_pmd(), but
> > > > a bit simpler to mitigate: we don't need to preserve dirty/young flags
> > > > here due to MADV_FREE functionality.
> > > > 
> > > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > > Cc: Minchan Kim <minchan@kernel.org>
> > > > ---
> > > >  mm/huge_memory.c | 2 --
> > > >  1 file changed, 2 deletions(-)
> > > > 
> > > > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > > > index bb2b3646bd78..324217c31ec9 100644
> > > > --- a/mm/huge_memory.c
> > > > +++ b/mm/huge_memory.c
> > > > @@ -1566,8 +1566,6 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
> > > >  		deactivate_page(page);
> > > > 
> > > >  	if (pmd_young(orig_pmd) || pmd_dirty(orig_pmd)) {
> > > > -		orig_pmd = pmdp_huge_get_and_clear_full(tlb->mm, addr, pmd,
> > > > -			tlb->fullmm);
> > > >  		orig_pmd = pmd_mkold(orig_pmd);
> > > >  		orig_pmd = pmd_mkclean(orig_pmd);
> > > > 
> > > $ grep -n set_pmd_at  linux-4.10/arch/powerpc/mm/pgtable-book3s64.c
> > > 
> > > /*
> > >  * set a new huge pmd. We should not be called for updating
> > >  * an existing pmd entry. That should go via pmd_hugepage_update.
> > >  */
> > > void set_pmd_at(struct mm_struct *mm, unsigned long addr,
> > 
> > +Aneesh.
> > 
> > Urgh... Power is special again.
> > 
> > I think this should work fine.
> > 
> > From 056914fa025992c0a2212aee057c26307ce60238 Mon Sep 17 00:00:00 2001
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > Date: Thu, 2 Mar 2017 16:47:45 +0300
> > Subject: [PATCH] thp: fix MADV_DONTNEED vs. MADV_FREE race
> > 
> > Basically the same race as with numa balancing in change_huge_pmd(), but
> > a bit simpler to mitigate: we don't need to preserve dirty/young flags
> > here due to MADV_FREE functionality.
> 
> Could you elaborate a bit more here rather than relying on other
> patch's description?

Okay, updated patch is below.

> And could you say what happens to the userspace if that race
> happens? When I guess from title "MADV_DONTNEED vs MADV_FREE",
> a page cannot be zapped but marked lazyfree or vise versa? Right?

"Vise versa" part should be fine. The case I'm worry about is that
MADV_DONTNEED would skip the pmd and it will not be cleared.
Userspace expects the area of memory to be clean after MADV_DONTNEED, but
it's not. It can lead to userspace misbehaviour.
