Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8589E6B0038
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 01:16:51 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so90274781pab.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 22:16:51 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id rz10si25153979pab.205.2015.11.12.22.16.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Nov 2015 22:16:50 -0800 (PST)
Date: Fri, 13 Nov 2015 15:17:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 01/17] mm: support madvise(MADV_FREE)
Message-ID: <20151113061719.GC5235@bbox>
References: <1447302793-5376-1-git-send-email-minchan@kernel.org>
 <1447302793-5376-2-git-send-email-minchan@kernel.org>
 <20151112112620.GB22481@node.shutemov.name>
MIME-Version: 1.0
In-Reply-To: <20151112112620.GB22481@node.shutemov.name>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com

On Thu, Nov 12, 2015 at 01:26:20PM +0200, Kirill A. Shutemov wrote:
> On Thu, Nov 12, 2015 at 01:32:57PM +0900, Minchan Kim wrote:
> > @@ -256,6 +260,125 @@ static long madvise_willneed(struct vm_area_struct *vma,
> >  	return 0;
> >  }
> >  
> > +static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
> > +				unsigned long end, struct mm_walk *walk)
> > +
> > +{
> > +	struct mmu_gather *tlb = walk->private;
> > +	struct mm_struct *mm = tlb->mm;
> > +	struct vm_area_struct *vma = walk->vma;
> > +	spinlock_t *ptl;
> > +	pte_t *pte, ptent;
> > +	struct page *page;
> > +
> > +	split_huge_page_pmd(vma, addr, pmd);
> > +	if (pmd_trans_unstable(pmd))
> > +		return 0;
> > +
> > +	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
> > +	arch_enter_lazy_mmu_mode();
> > +	for (; addr != end; pte++, addr += PAGE_SIZE) {
> > +		ptent = *pte;
> > +
> > +		if (!pte_present(ptent))
> > +			continue;
> > +
> > +		page = vm_normal_page(vma, addr, ptent);
> > +		if (!page)
> > +			continue;
> > +
> > +		if (PageSwapCache(page)) {
> 
> Could you put VM_BUG_ON_PAGE(PageTransCompound(page), page) here?
> Just in case.

No problem.

> 
> > +			if (!trylock_page(page))
> > +				continue;
> > +
> > +			if (!try_to_free_swap(page)) {
> > +				unlock_page(page);
> > +				continue;
> > +			}
> > +
> > +			ClearPageDirty(page);
> > +			unlock_page(page);
> 
> Hm. Do we handle pages shared over fork() here?
> Souldn't we ignore pages with mapcount > 0?

It was handled later patch by historical reason but it's better
to fold the patch to this.

Thanks for review!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
