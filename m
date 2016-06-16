Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id DC8F56B025E
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 06:08:58 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id k184so24493807wme.3
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 03:08:58 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id pp4si2683021lbc.178.2016.06.16.03.08.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 03:08:57 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id l188so4854522lfe.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 03:08:57 -0700 (PDT)
Date: Thu, 16 Jun 2016 13:08:54 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv9-rebased2 01/37] mm, thp: make swapin readahead under
 down_read of mmap_sem
Message-ID: <20160616100854.GB18137@node.shutemov.name>
References: <04f701d1c797$1ebe6b80$5c3b4280$@alibaba-inc.com>
 <04f801d1c79b$b46744a0$1d35cde0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <04f801d1c79b$b46744a0$1d35cde0$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Ebru Akagunduz' <ebru.akagunduz@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, Jun 16, 2016 at 02:52:52PM +0800, Hillf Danton wrote:
> > 
> > From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> > 
> > Currently khugepaged makes swapin readahead under down_write.  This patch
> > supplies to make swapin readahead under down_read instead of down_write.
> > 
> > The patch was tested with a test program that allocates 800MB of memory,
> > writes to it, and then sleeps.  The system was forced to swap out all.
> > Afterwards, the test program touches the area by writing, it skips a page
> > in each 20 pages of the area.
> > 
> > Link: http://lkml.kernel.org/r/1464335964-6510-4-git-send-email-ebru.akagunduz@gmail.com
> > Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > Cc: Cyrill Gorcunov <gorcunov@openvz.org>
> > Cc: Mel Gorman <mgorman@suse.de>
> > Cc: David Rientjes <rientjes@google.com>
> > Cc: Vlastimil Babka <vbabka@suse.cz>
> > Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Michal Hocko <mhocko@suse.cz>
> > Cc: Minchan Kim <minchan.kim@gmail.com>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > ---
> >  mm/huge_memory.c | 92 ++++++++++++++++++++++++++++++++++++++------------------
> >  1 file changed, 63 insertions(+), 29 deletions(-)
> > 
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index f2bc57c45d2f..96dfe3f09bf6 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -2378,6 +2378,35 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
> >  }
> > 
> >  /*
> > + * If mmap_sem temporarily dropped, revalidate vma
> > + * before taking mmap_sem.
> 
> See below

> > @@ -2401,11 +2430,18 @@ static void __collapse_huge_page_swapin(struct mm_struct *mm,
> >  			continue;
> >  		swapped_in++;
> >  		ret = do_swap_page(mm, vma, _address, pte, pmd,
> > -				   FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_RETRY_NOWAIT,
> > +				   FAULT_FLAG_ALLOW_RETRY,
> 
> Add a description in change log for it please.

Ebru, would you address it?

> >  				   pteval);
> > +		/* do_swap_page returns VM_FAULT_RETRY with released mmap_sem */
> > +		if (ret & VM_FAULT_RETRY) {
> > +			down_read(&mm->mmap_sem);
> > +			/* vma is no longer available, don't continue to swapin */
> > +			if (hugepage_vma_revalidate(mm, vma, address))
> > +				return false;
> 
> Revalidate vma _after_ acquiring mmap_sem, but the above comment says _before_.

Ditto.

> > +	if (!__collapse_huge_page_swapin(mm, vma, address, pmd)) {
> > +		up_read(&mm->mmap_sem);
> > +		goto out;
> 
> Jump out with mmap_sem released, 
> 
> > +	result = hugepage_vma_revalidate(mm, vma, address);
> > +	if (result)
> > +		goto out;
> 
> but jump out again with mmap_sem held.
> 
> They are cleaned up in subsequent darns?

I didn't fold fixups for these
> 

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
