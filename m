Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id B16AA6B0038
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 05:38:07 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so135217921wgb.3
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 02:38:07 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fx12si10349689wjc.192.2015.06.02.02.38.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Jun 2015 02:38:06 -0700 (PDT)
Date: Tue, 2 Jun 2015 11:38:05 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] hugetlb: Do not account hugetlb pages as NR_FILE_PAGES
Message-ID: <20150602093805.GC4440@dhcp22.suse.cz>
References: <1432214842-22730-1-git-send-email-mhocko@suse.cz>
 <20150521170909.GA12800@cmpxchg.org>
 <20150522142143.GF5109@dhcp22.suse.cz>
 <20150522143558.GA2462@suse.de>
 <55633EAC.8060702@suse.cz>
 <20150602092535.GB4440@dhcp22.suse.cz>
 <556D7851.1020107@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <556D7851.1020107@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 02-06-15 11:33:05, Vlastimil Babka wrote:
> On 06/02/2015 11:25 AM, Michal Hocko wrote:
> >On Mon 25-05-15 17:24:28, Vlastimil Babka wrote:
> >>On 05/22/2015 04:35 PM, Mel Gorman wrote:
> >>>>
> >>>>Thanks!
> >>>>
> >>>>>This makes a lot of sense to me.  The only thing I worry about is the
> >>>>>proliferation of PageHuge(), a function call, in relatively hot paths.
> >>>>
> >>>>I've tried that (see the patch below) but it enlarged the code by almost
> >>>>1k
> >>>>    text    data     bss     dec     hex filename
> >>>>  510323   74273   44440  629036   9992c mm/built-in.o.before
> >>>>  511248   74273   44440  629961   99cc9 mm/built-in.o.after
> >>>>
> >>>>I am not sure the code size increase is worth it. Maybe we can reduce
> >>>>the check to only PageCompound(page) as huge pages are no in the page
> >>>>cache (yet).
> >>>>
> >>>
> >>>That would be a more sensible route because it also avoids exposing the
> >>>hugetlbfs destructor unnecessarily.
> >>
> >>You could maybe do test such as (PageCompound(page) && PageHuge(page)) to
> >>short-circuit the call while remaining future-proof.
> >
> >How about this?
> 
> Yeah (see below)
> 
> >---
> >diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> >index 91b7f9b2b774..bb8a70e8fc77 100644
> >--- a/include/linux/page-flags.h
> >+++ b/include/linux/page-flags.h
> >@@ -547,7 +547,13 @@ static inline void ClearPageCompound(struct page *page)
> >  #endif /* !PAGEFLAGS_EXTENDED */
> >
> >  #ifdef CONFIG_HUGETLB_PAGE
> >-int PageHuge(struct page *page);
> >+int __PageHuge(struct page *page);
> >+static inline int PageHuge(struct page *page)
> >+{
> >+	if (!PageCompound(page))
> 
> Perhaps the above as likely()?

I have added it already when writing the changelog.

> [...]
> 
> >-EXPORT_SYMBOL_GPL(PageHuge);
> >+EXPORT_SYMBOL_GPL(__PageHuge);
> >
> >  /*
> >   * PageHeadHuge() only returns true for hugetlbfs head page, but not for
> >
> 
> Do the same thing here by inlining the PageHead() test?
> I guess the page_to_pgoff and __compound_tail_refcounted callers are rather
> hot?

Yes, that sounds like a good idea.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
