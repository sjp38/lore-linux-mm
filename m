Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0F2B1600794
	for <linux-mm@kvack.org>; Mon,  3 May 2010 11:33:35 -0400 (EDT)
Date: Mon, 3 May 2010 17:33:01 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/2] Fix migration races in rmap_walk() V3
Message-ID: <20100503153301.GD19891@random.random>
References: <1272529930-29505-1-git-send-email-mel@csn.ul.ie>
 <20100430182853.GK22108@random.random>
 <20100501135110.GP20640@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100501135110.GP20640@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sat, May 01, 2010 at 03:51:10PM +0200, Johannes Weiner wrote:
> On Fri, Apr 30, 2010 at 08:28:53PM +0200, Andrea Arcangeli wrote:
> > Subject: adapt mprotect to anon_vma chain semantics
> > 
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > wait_split_huge_page interface changed.
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > ---
> > 
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -929,7 +929,7 @@ int change_huge_pmd(struct vm_area_struc
> >  	if (likely(pmd_trans_huge(*pmd))) {
> >  		if (unlikely(pmd_trans_splitting(*pmd))) {
> >  			spin_unlock(&mm->page_table_lock);
> > -			wait_split_huge_page(vma->anon_vma, pmd);
> > +			wait_split_huge_page(mm, pmd);
> 
> That makes mprotect-vma-arg obsolete, I guess.

Well it's needed for flush_tlb_range. Also normally we could run a
single invlpg on x86 to invalidate huge pmd tlbs, but I read some
errata for some x86, and I didn't want to take risks plus this is
common code so I can't just run a common code flush_tlb_page. In
mincore_huge_pmd probably we could pass vma->vm_mm instead of vma (as
there is not flush_tlb_range), I can change it if you prefer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
