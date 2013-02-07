Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 1CAE86B0005
	for <linux-mm@kvack.org>; Thu,  7 Feb 2013 14:18:50 -0500 (EST)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Thu, 7 Feb 2013 19:17:18 -0000
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r17JIbUe21954688
	for <linux-mm@kvack.org>; Thu, 7 Feb 2013 19:18:37 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r17JIj37008438
	for <linux-mm@kvack.org>; Thu, 7 Feb 2013 12:18:45 -0700
Date: Thu, 7 Feb 2013 11:18:38 -0800
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] s390/mm: implement software dirty bits
Message-ID: <20130207111838.27fea18f@mschwide>
In-Reply-To: <alpine.LNX.2.00.1302061504340.7256@eggly.anvils>
References: <1360087925-8456-1-git-send-email-schwidefsky@de.ibm.com>
	<1360087925-8456-3-git-send-email-schwidefsky@de.ibm.com>
	<alpine.LNX.2.00.1302061504340.7256@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-s390@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>

On Wed, 6 Feb 2013 16:20:40 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> Martin, I'd like to say Applauded-by: Hugh Dickins <hughd@google.com>
> but I do have one reservation: the PageDirty business you helpfully
> draw attention to in your description above.
> 
> That makes me nervous, having a PageDirty test buried down there in
> one architecture's mk_pte().  Particularly since I know the PageDirty
> handling on anon/swap pages is rather odd: it works, but it's hard to
> justify some of the SetPageDirtys (when we add to swap, AND when we
> remove from swap): partly a leftover from 2.4 days, when vmscan worked
> differently, and we had to be more careful about freeing modified pages.

I tried to solved the whole thing with arch level code only. The PageDirty
check in mk_pte is essential to avoid additional protection faults for
tmpfs/shmem. 
 
> I did a patch a year or two ago, mainly for debugging some particular
> issue by announcing "Bad page state" if ever a dirty page is freed, in
> which I had to tidy that up.  Now, I don't have any immediate intention
> to resurrect that patch, but I'm afraid that if I did, I might interfere
> with your optimization in s390's mk_pte() without realizing it.
> 
> > --- a/arch/s390/include/asm/page.h
> > +++ b/arch/s390/include/asm/page.h
> > ...
> > @@ -1152,8 +1190,13
> >  static inline pte_t mk_pte(struct page *page, pgprot_t pgprot)
> >  {
> >  	unsigned long physpage = page_to_phys(page);
> > +	pte_t __pte = mk_pte_phys(physpage, pgprot);
> >  
> > -	return mk_pte_phys(physpage, pgprot);
> > +	if ((pte_val(__pte) & _PAGE_SWW) && PageDirty(page)) {
> > +		pte_val(__pte) |= _PAGE_SWC;
> > +		pte_val(__pte) &= ~_PAGE_RO;
> > +	}
> > +	return __pte;
> >  }
> 
> Am I right to think that, once you examine the mk_pte() callsites,
> this actually would not be affecting anon pages, nor accounted file
> pages, just tmpfs/shmem or ramfs pages read-faulted into a read-write
> shared vma?  (That fits with what you say above.)  That it amounts to
> the patch below - which I think I would prefer, because it's explicit?
> (There might be one or two other places it makes a difference e.g.
> replacing a writable migration entry, but those too uncommon to matter.)

Anon page and accounted file pages won't need the mk_pte optimization,
that is there for tmpfs/shmem. We could do that in common code as well,
to make the dependency on PageDirty more obvious.

> --- 3.8-rc6/mm/memory.c	2013-01-09 19:25:05.028321379 -0800
> +++ linux/mm/memory.c	2013-02-06 15:01:17.904387877 -0800
> @@ -3338,6 +3338,10 @@ static int __do_fault(struct mm_struct *
>  				dirty_page = page;
>  				get_page(dirty_page);
>  			}
> +#ifdef CONFIG_S390
> +			else if (pte_write(entry) && PageDirty(page))
> +				pte_mkdirty(entry);
> +#endif
>  		}
>  		set_pte_at(mm, address, page_table, entry);
> 
> And then I wonder, is that something we should do on all architectures?
> On the one hand, it would save a hardware fault when and if the pte is
> dirtied later; on the other hand, it seems wrong to claim pte dirty when
> not (though I didn't find anywhere that would care).

I don't like the fact that we are adding another CONFIG_S390, if we could
pre-dirty the pte for all architectures that would be nice. It has no
ill effects for s390 to make the pte dirty, I can think of no reason
why it should hurt for other architectures.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
