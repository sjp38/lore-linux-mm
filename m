Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 498426B0292
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 13:04:21 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id s3-v6so10341452plp.21
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 10:04:21 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m12-v6si1914465pll.461.2018.06.26.10.04.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jun 2018 10:04:18 -0700 (PDT)
Date: Tue, 26 Jun 2018 10:04:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: drop VM_BUG_ON from __get_free_pages
Message-Id: <20180626100416.a3ff53f5c4aac9fae954e3f6@linux-foundation.org>
In-Reply-To: <6886dee0-3ac4-ef5d-3597-073196c81d88@suse.cz>
References: <20180622162841.25114-1-mhocko@kernel.org>
	<6886dee0-3ac4-ef5d-3597-073196c81d88@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, JianKang Chen <chenjiankang1@huawei.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xieyisheng1@huawei.com, guohanjun@huawei.com, wangkefeng.wang@huawei.com, Michal Hocko <mhocko@suse.com>

On Tue, 26 Jun 2018 15:57:39 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

> On 06/22/2018 06:28 PM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > There is no real reason to blow up just because the caller doesn't know
> > that __get_free_pages cannot return highmem pages. Simply fix that up
> > silently. Even if we have some confused users such a fixup will not be
> > harmful.
> > 
>
> ...
>
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
> 

This reminds me what is irritating about the patch.  We're adding
additional code to a somewhat fast path to handle something which we
know never happens, thanks to the now-removed check.

This newly-added code might become functional in the future, if people
add incorrect callers.  Callers whose incorrectness would have been
revealed by the now-removed check!

So.. argh.

Really, the changelog isn't right.  There *is* a real reason to blow
up.  Effectively the caller is attempting to obtain the virtual address
of a highmem page without having kmapped it first.  That's an outright
bug.


An alternative might be to just accept the bogus __GFP_HIGHMEM, let
page_to_virt() return a crap address and wait for the user bug reports
to come in when someone tries to run the offending code on a highmem
machine.  That shouldn't take too long - the page allocator will prefer
to return a highmem page in this case.

And adding a rule to the various static checkers should catch most
offenders.

Or just leave the ode as it is now.
