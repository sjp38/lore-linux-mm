Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id AB33E681021
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 19:35:47 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id d185so43661292pgc.2
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 16:35:47 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id f84si2897860pfe.14.2017.02.16.16.35.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Feb 2017 16:35:46 -0800 (PST)
Date: Thu, 16 Feb 2017 16:35:25 -0800
From: Shaohua Li <shli@fb.com>
Subject: Re: [PATCH V3 2/7] mm: move MADV_FREE pages into LRU_INACTIVE_FILE
 list
Message-ID: <20170217003524.GA95440@shli-mbp.local>
References: <cover.1487100204.git.shli@fb.com>
 <5c38c5f4d91e92ce86ee4f253e49c78708094632.1487100204.git.shli@fb.com>
 <20170216175253.GB20791@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170216175253.GB20791@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Thu, Feb 16, 2017 at 12:52:53PM -0500, Johannes Weiner wrote:
> On Tue, Feb 14, 2017 at 11:36:08AM -0800, Shaohua Li wrote:
> > @@ -126,4 +126,24 @@ static __always_inline enum lru_list page_lru(struct page *page)
> >  
> >  #define lru_to_page(head) (list_entry((head)->prev, struct page, lru))
> >  
> > +/*
> > + * lazyfree pages are clean anonymous pages. They have SwapBacked flag cleared
> > + * to destinguish normal anonymous pages.
> > + */
> > +static inline void set_page_lazyfree(struct page *page)
> > +{
> > +	VM_BUG_ON_PAGE(!PageAnon(page) || !PageSwapBacked(page), page);
> > +	ClearPageSwapBacked(page);
> > +}
> > +
> > +static inline void clear_page_lazyfree(struct page *page)
> > +{
> > +	VM_BUG_ON_PAGE(!PageAnon(page) || PageSwapBacked(page), page);
> > +	SetPageSwapBacked(page);
> > +}
> > +
> > +static inline bool page_is_lazyfree(struct page *page)
> > +{
> > +	return PageAnon(page) && !PageSwapBacked(page);
> > +}
> 
> Sorry for not getting to v2 in time, but I have to say I strongly
> agree with your first iterations and would much prefer this to be
> open-coded.
> 
> IMO this needlessly introduces a new state opaquely called "lazyfree",
> when really that's just anonymous pages that don't need to be swapped
> before reclaim - PageAnon && !PageSwapBacked. Very simple MM concept.
> 
> That especially shows when we later combine it with page_is_file_cache
> checks like the next patch does.
> 
> The rest of the patch looks good to me.

Thanks! I do agree checking PageSwapBacked is clearer, but Minchan convinced me
because of the accounting issue. Where do you suggest we should put the
accounting to?

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
