Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1DDFD8E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 11:08:53 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id o21so16824790edq.4
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 08:08:53 -0800 (PST)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.106])
        by mx.google.com with ESMTPS id q10-v6si6487414ejf.1.2018.12.19.08.08.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 08:08:51 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 357691C2815
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 16:08:51 +0000 (GMT)
Date: Wed, 19 Dec 2018 16:04:01 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 08/14] mm, compaction: Use the page allocator bulk-free
 helper for lists of pages
Message-ID: <20181219160401.GA31517@techsingularity.net>
References: <20181214230310.572-1-mgorman@techsingularity.net>
 <20181214230310.572-9-mgorman@techsingularity.net>
 <e5a93476-c31d-5c5e-7649-2b23188aaaac@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <e5a93476-c31d-5c5e-7649-2b23188aaaac@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On Tue, Dec 18, 2018 at 10:55:31AM +0100, Vlastimil Babka wrote:
> On 12/15/18 12:03 AM, Mel Gorman wrote:
> > release_pages() is a simpler version of free_unref_page_list() but it
> > tracks the highest PFN for caching the restart point of the compaction
> > free scanner. This patch optionally tracks the highest PFN in the core
> > helper and converts compaction to use it.
> > 
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> Nit below:
> 
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2961,18 +2961,26 @@ void free_unref_page(struct page *page)
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
> That will warn just once, but then page will remain with elevated count
> and free_unref_page_prepare() will warn either immediately or later
> depending on DEBUG_VM, for each page.
> Also IIRC it's legal for basically anyone to do get_page_unless_zero()
> and later put_page(), and this would now cause warning. Maybe just test
> for put_page_testzero() result without warning, and continue? Hm but
> then we should still do a list_del() and that becomes racy after
> dropping our ref...
> 

While there are cases where such a pattern is legal, this function
simply does not expect it and the callers do not violate the rule. If it
ever gets a new user that makes mistakes, they'll get the warning. Sure,
the page leaks but it'll be in a state where it's unsafe to do anything
else with it.

-- 
Mel Gorman
SUSE Labs
