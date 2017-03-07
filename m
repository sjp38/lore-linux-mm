Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id BBE1B6B0387
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 08:53:02 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id n11so1440786wma.5
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 05:53:02 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id j62si87528wrj.264.2017.03.07.05.53.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 05:53:01 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id u132so1108283wmg.1
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 05:53:01 -0800 (PST)
Date: Tue, 7 Mar 2017 16:52:58 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 3/4] thp: fix MADV_DONTNEED vs. MADV_FREE race
Message-ID: <20170307135258.GA2412@node>
References: <20170302151034.27829-1-kirill.shutemov@linux.intel.com>
 <20170302151034.27829-4-kirill.shutemov@linux.intel.com>
 <871subdsrk.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <871subdsrk.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

On Mon, Mar 06, 2017 at 08:19:03AM +0530, Aneesh Kumar K.V wrote:
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
> 
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
> 
> Instead can we do a new interface that does something like
> 
> pmdp_huge_update(tlb->mm, addr, pmd, new_pmd);
> 
> We do have a variant already in ptep_set_access_flags. What we need is
> something that can be used to update THP pmd, without converting it to
> pmd_none and one which doens't loose reference and change bit ?

Sounds like a good idea. Would you volunteer to implement it?
I don't have time for this right now.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
