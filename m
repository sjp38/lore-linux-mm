Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 7E8A56B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 01:53:21 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id u10so1080192lbi.28
        for <linux-mm@kvack.org>; Wed, 31 Jul 2013 22:53:19 -0700 (PDT)
Date: Thu, 1 Aug 2013 09:53:03 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 1/2] [PATCH] mm: Save soft-dirty bits on swapped pages
Message-ID: <20130801055303.GA1764@moon>
References: <20130730204154.407090410@gmail.com>
 <20130730204654.844299768@gmail.com>
 <20130801005132.GB19540@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130801005132.GB19540@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, luto@amacapital.net, xemul@parallels.com, akpm@linux-foundation.org, mpm@selenic.com, xiaoguangrong@linux.vnet.ibm.com, mtosatti@redhat.com, kosaki.motohiro@gmail.com, sfr@canb.auug.org.au, peterz@infradead.org, aneesh.kumar@linux.vnet.ibm.com

On Thu, Aug 01, 2013 at 09:51:32AM +0900, Minchan Kim wrote:
> > Index: linux-2.6.git/include/linux/swapops.h
> > ===================================================================
> > --- linux-2.6.git.orig/include/linux/swapops.h
> > +++ linux-2.6.git/include/linux/swapops.h
> > @@ -67,6 +67,8 @@ static inline swp_entry_t pte_to_swp_ent
> >  	swp_entry_t arch_entry;
> >  
> >  	BUG_ON(pte_file(pte));
> > +	if (pte_swp_soft_dirty(pte))
> > +		pte = pte_swp_clear_soft_dirty(pte);
> 
> Why do you remove soft-dirty flag whenever pte_to_swp_entry is called?
> Isn't there any problem if we use mincore?

No, there is no problem. pte_to_swp_entry caller when we know that pte
we're decoding is having swap format (except the case in swap code which
figures out the number of bits allowed for offset). Still since this bit
is set on "higher" level than __swp_type/__swp_offset helpers it should
be cleaned before the value from pte comes to "one level down" helpers
function.

> > +static inline int maybe_same_pte(pte_t pte, pte_t swp_pte)
> 
> Nitpick.
> If maybe_same_pte is used widely, it looks good to me
> but it's used for only swapoff at the moment so I think pte_swap_same
> would be better name.

I don't see much difference, but sure, lets rename it on top once series
in -mm tree, sounds good?

	Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
