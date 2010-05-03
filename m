Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A43136007B8
	for <linux-mm@kvack.org>; Mon,  3 May 2010 19:42:01 -0400 (EDT)
Date: Tue, 4 May 2010 01:41:32 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/2] Fix migration races in rmap_walk() V3
Message-ID: <20100503234132.GK5336@cmpxchg.org>
References: <1272529930-29505-1-git-send-email-mel@csn.ul.ie> <20100430182853.GK22108@random.random> <20100501135110.GP20640@cmpxchg.org> <20100503153301.GD19891@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100503153301.GD19891@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, May 03, 2010 at 05:33:01PM +0200, Andrea Arcangeli wrote:
> On Sat, May 01, 2010 at 03:51:10PM +0200, Johannes Weiner wrote:
> > On Fri, Apr 30, 2010 at 08:28:53PM +0200, Andrea Arcangeli wrote:
> > > Subject: adapt mprotect to anon_vma chain semantics
> > > 
> > > From: Andrea Arcangeli <aarcange@redhat.com>
> > > 
> > > wait_split_huge_page interface changed.
> > > 
> > > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > > ---
> > > 
> > > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > > --- a/mm/huge_memory.c
> > > +++ b/mm/huge_memory.c
> > > @@ -929,7 +929,7 @@ int change_huge_pmd(struct vm_area_struc
> > >  	if (likely(pmd_trans_huge(*pmd))) {
> > >  		if (unlikely(pmd_trans_splitting(*pmd))) {
> > >  			spin_unlock(&mm->page_table_lock);
> > > -			wait_split_huge_page(vma->anon_vma, pmd);
> > > +			wait_split_huge_page(mm, pmd);
> > 
> > That makes mprotect-vma-arg obsolete, I guess.
> 
> Well it's needed for flush_tlb_range.

I must have been blind, sorry for the noise.

> In mincore_huge_pmd probably we could pass vma->vm_mm instead of
> vma (as there is not flush_tlb_range), I can change it if you prefer.

Although not strictly required, it's probably nicer to keep the
function signatures in this code alike.  So everything fine with
me as it stands :)

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
