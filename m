Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id C96A96B002B
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 05:48:28 -0400 (EDT)
Date: Fri, 10 Aug 2012 11:48:25 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] hugetlb: correct page offset index for sharing pmd
Message-ID: <20120810094825.GA1440@dhcp22.suse.cz>
References: <CAJd=RBB=jKD+9JcuBmBGC8R8pAQ-QoWHexMNMsXpb9zV548h5g@mail.gmail.com>
 <20120803133235.GA8434@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120803133235.GA8434@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 03-08-12 15:32:35, Michal Hocko wrote:
> On Fri 03-08-12 20:56:45, Hillf Danton wrote:
> > The computation of page offset index is open coded, and incorrect, to
> > be used in scanning prio tree, as huge page offset is required, and is
> > fixed with the well defined routine.
> 
> I guess that nobody reported this because if someone really wants to
> share he will use aligned address for mmap/shmat and so the index is 0.
> Anyway it is worth fixing. Thanks for pointing out!

I have looked at the code again and I don't think there is any problem
at all. vma_prio_tree_foreach understands page units so it will find
appropriate svmas.
Or am I missing something?

> 
> > 
> > Signed-off-by: Hillf Danton <dhillf@gmail.com>
> > ---
> > 
> > --- a/arch/x86/mm/hugetlbpage.c	Fri Aug  3 20:34:58 2012
> > +++ b/arch/x86/mm/hugetlbpage.c	Fri Aug  3 20:40:16 2012
> > @@ -72,12 +72,15 @@ static void huge_pmd_share(struct mm_str
> >  	if (!vma_shareable(vma, addr))
> >  		return;
> > 
> > +	idx = linear_page_index(vma, addr);
> > +
> 
> You can use linear_hugepage_index directly and remove the idx
> initialization as well.
> 
> >  	mutex_lock(&mapping->i_mmap_mutex);
> >  	vma_prio_tree_foreach(svma, &iter, &mapping->i_mmap, idx, idx) {
> >  		if (svma == vma)
> >  			continue;
> > 
> > -		saddr = page_table_shareable(svma, vma, addr, idx);
> > +		saddr = page_table_shareable(svma, vma, addr,
> > +						idx * (PMD_SIZE/PAGE_SIZE));
> 
> Why not just fixing page_table_shareable as well rather than playing
> tricks like this?
> 
> >  		if (saddr) {
> >  			spte = huge_pte_offset(svma->vm_mm, saddr);
> >  			if (spte) {
> > --
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
