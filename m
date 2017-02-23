Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3802A6B0038
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 12:19:37 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id e4so31080783uae.4
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 09:19:37 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id o4si5310887iti.126.2017.02.23.09.19.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 09:19:36 -0800 (PST)
Date: Thu, 23 Feb 2017 09:19:01 -0800
From: Shaohua Li <shli@fb.com>
Subject: Re: [PATCH V4 4/6] mm: reclaim MADV_FREE pages
Message-ID: <20170223171901.GA20444@shli-mbp.local>
References: <cover.1487788131.git.shli@fb.com>
 <94eccf0fcf927f31377a60d7a9f900b7e743fb06.1487788131.git.shli@fb.com>
 <20170223161342.GC4031@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170223161342.GC4031@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Thu, Feb 23, 2017 at 11:13:42AM -0500, Johannes Weiner wrote:
> On Wed, Feb 22, 2017 at 10:50:42AM -0800, Shaohua Li wrote:
> > @@ -1424,6 +1424,12 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> >  				dec_mm_counter(mm, MM_ANONPAGES);
> >  				rp->lazyfreed++;
> >  				goto discard;
> > +			} else if (!PageSwapBacked(page)) {
> > +				/* dirty MADV_FREE page */
> > +				set_pte_at(mm, address, pvmw.pte, pteval);
> > +				ret = SWAP_DIRTY;
> > +				page_vma_mapped_walk_done(&pvmw);
> > +				break;
> >  			}
> >  
> >  			if (swap_duplicate(entry) < 0) {
> > @@ -1525,8 +1531,8 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
> >  
> >  	if (ret != SWAP_MLOCK && !page_mapcount(page)) {
> >  		ret = SWAP_SUCCESS;
> > -		if (rp.lazyfreed && !PageDirty(page))
> > -			ret = SWAP_LZFREE;
> > +		if (rp.lazyfreed && PageDirty(page))
> > +			ret = SWAP_DIRTY;
> 
> Can this actually happen? If the page is dirty, ret should already be
> SWAP_DIRTY, right? How would a dirty page get fully unmapped?
> 
> It seems to me rp.lazyfreed can be removed entirely now that we don't
> have to identify the lazyfree case anymore. The failure case is much
> easier to identify - all it takes is a single pte to be dirty.

ok, I get mixed up. Yes, this couldn't happen any more since we changed the
behavior of try_to_unmap_one. Will delete this in next post.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
