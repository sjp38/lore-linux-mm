Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0179044060D
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 11:11:13 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id ez4so9065132wjd.2
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 08:11:12 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id d83si2188654wmc.151.2017.02.17.08.11.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 08:11:11 -0800 (PST)
Date: Fri, 17 Feb 2017 11:11:05 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V3 3/7] mm: reclaim MADV_FREE pages
Message-ID: <20170217161105.GB23735@cmpxchg.org>
References: <cover.1487100204.git.shli@fb.com>
 <cd6a477063c40ad899ad8f4e964c347525ea23a3.1487100204.git.shli@fb.com>
 <20170216184018.GC20791@cmpxchg.org>
 <20170217002717.GA93163@shli-mbp.local>
 <20170217054555.GB3653@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170217054555.GB3653@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

Hi Minchan,

On Fri, Feb 17, 2017 at 02:45:55PM +0900, Minchan Kim wrote:
> On Thu, Feb 16, 2017 at 04:27:18PM -0800, Shaohua Li wrote:
> > On Thu, Feb 16, 2017 at 01:40:18PM -0500, Johannes Weiner wrote:
> > > On Tue, Feb 14, 2017 at 11:36:09AM -0800, Shaohua Li wrote:
> > > > @@ -1419,11 +1419,18 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> > > >  			VM_BUG_ON_PAGE(!PageSwapCache(page) && PageSwapBacked(page),
> > > >  				page);
> > > >  
> > > > -			if (!PageDirty(page) && (flags & TTU_LZFREE)) {
> > > > -				/* It's a freeable page by MADV_FREE */
> > > > -				dec_mm_counter(mm, MM_ANONPAGES);
> > > > -				rp->lazyfreed++;
> > > > -				goto discard;
> > > > +			if (flags & TTU_LZFREE) {
> > > > +				if (!PageDirty(page)) {
> > > > +					/* It's a freeable page by MADV_FREE */
> > > > +					dec_mm_counter(mm, MM_ANONPAGES);
> > > > +					rp->lazyfreed++;
> > > > +					goto discard;
> > > > +				} else {
> > > > +					set_pte_at(mm, address, pvmw.pte, pteval);
> > > > +					ret = SWAP_FAIL;
> > > > +					page_vma_mapped_walk_done(&pvmw);
> > > > +					break;
> > > > +				}
> > > 
> > > I don't understand why we need the TTU_LZFREE bit in general. More on
> > > that below at the callsite.
> > 
> > Sounds useless flag, don't see any reason we shouldn't free the MADV_FREE page
> > in places other than reclaim. Looks TTU_UNMAP is useless too..
> 
> Agree on TTU_UNMAP but for example, THP split doesn't mean free lazyfree pages,
> I think.

Anon THP splitting uses the migration branch, so we should be fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
