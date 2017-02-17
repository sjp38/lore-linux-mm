Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CB0B3681021
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 00:46:00 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id e4so50279721pfg.4
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 21:46:00 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id x11si9220437pff.76.2017.02.16.21.45.59
        for <linux-mm@kvack.org>;
        Thu, 16 Feb 2017 21:46:00 -0800 (PST)
Date: Fri, 17 Feb 2017 14:45:55 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH V3 3/7] mm: reclaim MADV_FREE pages
Message-ID: <20170217054555.GB3653@bbox>
References: <cover.1487100204.git.shli@fb.com>
 <cd6a477063c40ad899ad8f4e964c347525ea23a3.1487100204.git.shli@fb.com>
 <20170216184018.GC20791@cmpxchg.org>
 <20170217002717.GA93163@shli-mbp.local>
MIME-Version: 1.0
In-Reply-To: <20170217002717.GA93163@shli-mbp.local>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

Hi Shaohua,

On Thu, Feb 16, 2017 at 04:27:18PM -0800, Shaohua Li wrote:
> On Thu, Feb 16, 2017 at 01:40:18PM -0500, Johannes Weiner wrote:
> > On Tue, Feb 14, 2017 at 11:36:09AM -0800, Shaohua Li wrote:
> > > @@ -1419,11 +1419,18 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> > >  			VM_BUG_ON_PAGE(!PageSwapCache(page) && PageSwapBacked(page),
> > >  				page);
> > >  
> > > -			if (!PageDirty(page) && (flags & TTU_LZFREE)) {
> > > -				/* It's a freeable page by MADV_FREE */
> > > -				dec_mm_counter(mm, MM_ANONPAGES);
> > > -				rp->lazyfreed++;
> > > -				goto discard;
> > > +			if (flags & TTU_LZFREE) {
> > > +				if (!PageDirty(page)) {
> > > +					/* It's a freeable page by MADV_FREE */
> > > +					dec_mm_counter(mm, MM_ANONPAGES);
> > > +					rp->lazyfreed++;
> > > +					goto discard;
> > > +				} else {
> > > +					set_pte_at(mm, address, pvmw.pte, pteval);
> > > +					ret = SWAP_FAIL;
> > > +					page_vma_mapped_walk_done(&pvmw);
> > > +					break;
> > > +				}
> > 
> > I don't understand why we need the TTU_LZFREE bit in general. More on
> > that below at the callsite.
> 
> Sounds useless flag, don't see any reason we shouldn't free the MADV_FREE page
> in places other than reclaim. Looks TTU_UNMAP is useless too..

Agree on TTU_UNMAP but for example, THP split doesn't mean free lazyfree pages,
I think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
