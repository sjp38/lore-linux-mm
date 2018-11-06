Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 994A96B02DA
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 03:47:51 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 190-v6so3461207pfd.7
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 00:47:51 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id z3-v6si45177065pgh.250.2018.11.06.00.47.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 00:47:50 -0800 (PST)
Date: Tue, 6 Nov 2018 16:47:46 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH v2 2/2] mm/page_alloc: use a single function to free page
Message-ID: <20181106084746.GA24198@intel.com>
References: <20181105085820.6341-1-aaron.lu@intel.com>
 <20181105085820.6341-2-aaron.lu@intel.com>
 <20181106053037.GD6203@intel.com>
 <d6b4890c-0def-6114-2dcf-3ed120dea82c@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d6b4890c-0def-6114-2dcf-3ed120dea82c@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, =?utf-8?B?UGF3ZcWC?= Staszewski <pstaszewski@itcare.pl>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, Yoel Caspersen <yoel@kviknet.dk>, Mel Gorman <mgorman@techsingularity.net>, Saeed Mahameed <saeedm@mellanox.com>, Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>

On Tue, Nov 06, 2018 at 09:16:20AM +0100, Vlastimil Babka wrote:
> On 11/6/18 6:30 AM, Aaron Lu wrote:
> > We have multiple places of freeing a page, most of them doing similar
> > things and a common function can be used to reduce code duplicate.
> > 
> > It also avoids bug fixed in one function but left in another.
> > 
> > Signed-off-by: Aaron Lu <aaron.lu@intel.com>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks.

> I assume there's no arch that would run page_ref_sub_and_test(1) slower
> than put_page_testzero(), for the critical __free_pages() case?

Good question.

I followed the non-arch specific calls and found that:
page_ref_sub_and_test() ends up calling atomic_sub_return(i, v) while
put_page_testzero() ends up calling atomic_sub_return(1, v). So they
should be same for archs that do not have their own implementations.

Back to your question: I don't know either.
If this is deemed unsafe, we can probably keep the ref modify part in
their original functions and only take the free part into a common
function.

Regards,
Aaron

> > ---
> > v2: move comments close to code as suggested by Dave.
> > 
> >  mm/page_alloc.c | 36 ++++++++++++++++--------------------
> >  1 file changed, 16 insertions(+), 20 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 91a9a6af41a2..4faf6b7bf225 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -4425,9 +4425,17 @@ unsigned long get_zeroed_page(gfp_t gfp_mask)
> >  }
> >  EXPORT_SYMBOL(get_zeroed_page);
> >  
> > -void __free_pages(struct page *page, unsigned int order)
> > +static inline void free_the_page(struct page *page, unsigned int order, int nr)
> >  {
> > -	if (put_page_testzero(page)) {
> > +	VM_BUG_ON_PAGE(page_ref_count(page) == 0, page);
> > +
> > +	/*
> > +	 * Free a page by reducing its ref count by @nr.
> > +	 * If its refcount reaches 0, then according to its order:
> > +	 * order0: send to PCP;
> > +	 * high order: directly send to Buddy.
> > +	 */
> > +	if (page_ref_sub_and_test(page, nr)) {
> >  		if (order == 0)
> >  			free_unref_page(page);
> >  		else
> > @@ -4435,6 +4443,10 @@ void __free_pages(struct page *page, unsigned int order)
> >  	}
> >  }
> >  
> > +void __free_pages(struct page *page, unsigned int order)
> > +{
> > +	free_the_page(page, order, 1);
> > +}
> >  EXPORT_SYMBOL(__free_pages);
> >  
> >  void free_pages(unsigned long addr, unsigned int order)
> > @@ -4481,16 +4493,7 @@ static struct page *__page_frag_cache_refill(struct page_frag_cache *nc,
> >  
> >  void __page_frag_cache_drain(struct page *page, unsigned int count)
> >  {
> > -	VM_BUG_ON_PAGE(page_ref_count(page) == 0, page);
> > -
> > -	if (page_ref_sub_and_test(page, count)) {
> > -		unsigned int order = compound_order(page);
> > -
> > -		if (order == 0)
> > -			free_unref_page(page);
> > -		else
> > -			__free_pages_ok(page, order);
> > -	}
> > +	free_the_page(page, compound_order(page), count);
> >  }
> >  EXPORT_SYMBOL(__page_frag_cache_drain);
> >  
> > @@ -4555,14 +4558,7 @@ void page_frag_free(void *addr)
> >  {
> >  	struct page *page = virt_to_head_page(addr);
> >  
> > -	if (unlikely(put_page_testzero(page))) {
> > -		unsigned int order = compound_order(page);
> > -
> > -		if (order == 0)
> > -			free_unref_page(page);
> > -		else
> > -			__free_pages_ok(page, order);
> > -	}
> > +	free_the_page(page, compound_order(page), 1);
> >  }
> >  EXPORT_SYMBOL(page_frag_free);
> >  
> > 
> 
