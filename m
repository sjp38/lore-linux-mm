Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7BE97681021
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 04:27:28 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 204so57512680pfx.1
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 01:27:28 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id c184si9724628pfg.185.2017.02.17.01.27.25
        for <linux-mm@kvack.org>;
        Fri, 17 Feb 2017 01:27:27 -0800 (PST)
Date: Fri, 17 Feb 2017 18:27:24 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH V3 3/7] mm: reclaim MADV_FREE pages
Message-ID: <20170217092724.GA23524@bbox>
References: <cover.1487100204.git.shli@fb.com>
 <cd6a477063c40ad899ad8f4e964c347525ea23a3.1487100204.git.shli@fb.com>
 <20170216184018.GC20791@cmpxchg.org>
 <20170217054108.GA3653@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170217054108.GA3653@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Fri, Feb 17, 2017 at 02:41:08PM +0900, Minchan Kim wrote:
> Hi Johannes,
> 
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
> The reason I introduced it was ttu is used for migration/THP split path
> as well as reclaim. It's clear to discard them in reclaim path because
> it means surely memory pressure now but not sure with other path.
> 
> If you guys think it's always win to discard them in try_to_unmap
> unconditionally, I think it would be better to be separate patch.

I was totally wrong.

Anon page with THP split/migration/HWPoison will not reach to discard path
in try_to_unmap_one so Johannes is right. We don't need TTU_LZFREE.

Sorry for the noise.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
