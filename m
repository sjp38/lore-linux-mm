Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id F3C0F6B0036
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 02:16:05 -0400 (EDT)
Date: Thu, 1 Aug 2013 15:16:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch 1/2] [PATCH] mm: Save soft-dirty bits on swapped pages
Message-ID: <20130801061632.GE19540@bbox>
References: <20130730204154.407090410@gmail.com>
 <20130730204654.844299768@gmail.com>
 <20130801005132.GB19540@bbox>
 <20130801055303.GA1764@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130801055303.GA1764@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, luto@amacapital.net, xemul@parallels.com, akpm@linux-foundation.org, mpm@selenic.com, xiaoguangrong@linux.vnet.ibm.com, mtosatti@redhat.com, kosaki.motohiro@gmail.com, sfr@canb.auug.org.au, peterz@infradead.org, aneesh.kumar@linux.vnet.ibm.com

On Thu, Aug 01, 2013 at 09:53:03AM +0400, Cyrill Gorcunov wrote:
> On Thu, Aug 01, 2013 at 09:51:32AM +0900, Minchan Kim wrote:
> > > Index: linux-2.6.git/include/linux/swapops.h
> > > ===================================================================
> > > --- linux-2.6.git.orig/include/linux/swapops.h
> > > +++ linux-2.6.git/include/linux/swapops.h
> > > @@ -67,6 +67,8 @@ static inline swp_entry_t pte_to_swp_ent
> > >  	swp_entry_t arch_entry;
> > >  
> > >  	BUG_ON(pte_file(pte));
> > > +	if (pte_swp_soft_dirty(pte))
> > > +		pte = pte_swp_clear_soft_dirty(pte);
> > 
> > Why do you remove soft-dirty flag whenever pte_to_swp_entry is called?
> > Isn't there any problem if we use mincore?
> 
> No, there is no problem. pte_to_swp_entry caller when we know that pte
> we're decoding is having swap format (except the case in swap code which
> figures out the number of bits allowed for offset). Still since this bit
> is set on "higher" level than __swp_type/__swp_offset helpers it should
> be cleaned before the value from pte comes to "one level down" helpers
> function.

I don't get it. Could you correct me with below example?

Process A context
        try_to_unmap
                swp_pte = swp_entry_to_pte /* change generic swp into arch swap */
                swp_pte = pte_swp_mksoft_dirty(swp_pte);
                set_pte_at(, swp_pte);

Process A context
        ..
        mincore_pte_range
                pte_to_swp_entry
                        pte = pte_swp_clear_soft_dirty  <=== 1)
                        change arch swp with generic swp
                mincore_page 

Process B want to know dirty state of the page
        ..
        pagemap_read
        pte_to_pagemap_entry
        is_swap_pte
                if (pte_swap_soft_dirty(pte)) <=== but failed by 1)

So, Process B can't get the dirty status from process A's the page.

> 
> > > +static inline int maybe_same_pte(pte_t pte, pte_t swp_pte)
> > 
> > Nitpick.
> > If maybe_same_pte is used widely, it looks good to me
> > but it's used for only swapoff at the moment so I think pte_swap_same
> > would be better name.
> 
> I don't see much difference, but sure, lets rename it on top once series
> in -mm tree, sounds good?
> 
> 	Cyrill
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
