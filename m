Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7D5218E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 04:46:42 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e17so2145958edr.7
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 01:46:42 -0800 (PST)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.106])
        by mx.google.com with ESMTPS id d8si1271edo.400.2019.01.16.01.46.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 01:46:41 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id A6E351C1FEF
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 09:46:40 +0000 (GMT)
Date: Wed, 16 Jan 2019 09:46:39 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 09/25] mm, compaction: Use the page allocator bulk-free
 helper for lists of pages
Message-ID: <20190116094639.GC27437@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190104125011.16071-10-mgorman@techsingularity.net>
 <a61312d7-8235-fe4d-6411-d3143d965f81@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <a61312d7-8235-fe4d-6411-d3143d965f81@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On Tue, Jan 15, 2019 at 01:39:28PM +0100, Vlastimil Babka wrote:
> On 1/4/19 1:49 PM, Mel Gorman wrote:
> > release_pages() is a simpler version of free_unref_page_list() but it
> > tracks the highest PFN for caching the restart point of the compaction
> > free scanner. This patch optionally tracks the highest PFN in the core
> > helper and converts compaction to use it. The performance impact is
> > limited but it should reduce lock contention slightly in some cases.
> > The main benefit is removing some partially duplicated code.
> > 
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> 
> ...
> 
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2876,18 +2876,26 @@ void free_unref_page(struct page *page)
> >  /*
> >   * Free a list of 0-order pages
> >   */
> > -void free_unref_page_list(struct list_head *list)
> > +void __free_page_list(struct list_head *list, bool dropref,
> > +				unsigned long *highest_pfn)
> >  {
> >  	struct page *page, *next;
> >  	unsigned long flags, pfn;
> >  	int batch_count = 0;
> >  
> > +	if (highest_pfn)
> > +		*highest_pfn = 0;
> > +
> >  	/* Prepare pages for freeing */
> >  	list_for_each_entry_safe(page, next, list, lru) {
> > +		if (dropref)
> > +			WARN_ON_ONCE(!put_page_testzero(page));
> 
> I've thought about it again and still think it can cause spurious
> warnings. We enter this function with one page pin, which means somebody
> else might be doing pfn scanning and get_page_unless_zero() with
> success, so there are two pins. Then we do the put_page_testzero() above
> and go back to one pin, and warn. You said "this function simply does
> not expect it and the callers do not violate the rule", but this is
> rather about potential parallel pfn scanning activity and not about this
> function's callers. Maybe there really is no parallel pfn scanner that
> would try to pin a page with a state the page has when it's processed by
> this function, but I wouldn't bet on it (any state checks preceding the
> pin might also be racy etc.).
> 

Ok, I'll drop this patch because in theory you're right. I wouldn't think
that parallel PFN scanning is likely to trigger it but gup is a potential
issue. While this also will increase CPU usage slightly again, it'll be
no worse than it was before and again, I don't want to stall the entire
series over a relatively small optimisation.

Thanks Vlastimil!

-- 
Mel Gorman
SUSE Labs
