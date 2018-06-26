Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9BF176B0269
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 10:45:01 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n2-v6so513018edr.5
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 07:45:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k15-v6si851965edr.290.2018.06.26.07.44.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jun 2018 07:44:59 -0700 (PDT)
Date: Tue, 26 Jun 2018 16:44:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: drop VM_BUG_ON from __get_free_pages
Message-ID: <20180626144456.GZ28965@dhcp22.suse.cz>
References: <20180622162841.25114-1-mhocko@kernel.org>
 <6886dee0-3ac4-ef5d-3597-073196c81d88@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6886dee0-3ac4-ef5d-3597-073196c81d88@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, JianKang Chen <chenjiankang1@huawei.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xieyisheng1@huawei.com, guohanjun@huawei.com, wangkefeng.wang@huawei.com

On Tue 26-06-18 15:57:39, Vlastimil Babka wrote:
> On 06/22/2018 06:28 PM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > There is no real reason to blow up just because the caller doesn't know
> > that __get_free_pages cannot return highmem pages. Simply fix that up
> > silently. Even if we have some confused users such a fixup will not be
> > harmful.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> > Hi Andrew,
> > previously posted [1] but it fell through cracks. Can we merge it now?
> > 
> > [1] http://lkml.kernel.org/r/20171129160446.jluzpv3n6mjc3fwv@dhcp22.suse.cz
> > 
> >  mm/page_alloc.c | 10 +++-------
> >  1 file changed, 3 insertions(+), 7 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 1521100f1e63..5f56f662a52d 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -4402,18 +4402,14 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
> >  EXPORT_SYMBOL(__alloc_pages_nodemask);
> >  
> >  /*
> > - * Common helper functions.
> > + * Common helper functions. Never use with __GFP_HIGHMEM because the returned
> > + * address cannot represent highmem pages. Use alloc_pages and then kmap if
> > + * you need to access high mem.
> >   */
> >  unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order)
> >  {
> >  	struct page *page;
> >  
> > -	/*
> > -	 * __get_free_pages() returns a virtual address, which cannot represent
> > -	 * a highmem page
> > -	 */
> > -	VM_BUG_ON((gfp_mask & __GFP_HIGHMEM) != 0);
> > -
> >  	page = alloc_pages(gfp_mask, order);
> 
> The previous version had also replaced the line above with:
> 
> +	page = alloc_pages(gfp_mask & ~__GFP_HIGHMEM, order);
> 
> This one doesn't, yet you say "fix that up silently". Bug?

got lost somewhere on the way during the discussion. Thanks for spotting
that.

Andrew, could you add gfp_mask & ~__GFP_HIGHMEM please? Or should I
resubmit?

-- 
Michal Hocko
SUSE Labs
