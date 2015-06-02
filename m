Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 89AA86B006E
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 06:00:41 -0400 (EDT)
Received: by laei3 with SMTP id i3so33556078lae.3
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 03:00:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dk3si23529448wib.13.2015.06.02.03.00.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Jun 2015 03:00:39 -0700 (PDT)
Date: Tue, 2 Jun 2015 12:00:37 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] hugetlb: Do not account hugetlb pages as NR_FILE_PAGES
Message-ID: <20150602100037.GD4440@dhcp22.suse.cz>
References: <1432214842-22730-1-git-send-email-mhocko@suse.cz>
 <20150521170909.GA12800@cmpxchg.org>
 <20150522142143.GF5109@dhcp22.suse.cz>
 <20150522143558.GA2462@suse.de>
 <55633EAC.8060702@suse.cz>
 <20150602092535.GB4440@dhcp22.suse.cz>
 <556D7851.1020107@suse.cz>
 <20150602093805.GC4440@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150602093805.GC4440@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 02-06-15 11:38:05, Michal Hocko wrote:
> On Tue 02-06-15 11:33:05, Vlastimil Babka wrote:
> > On 06/02/2015 11:25 AM, Michal Hocko wrote:
[...]
> > >diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> > >index 91b7f9b2b774..bb8a70e8fc77 100644
> > >--- a/include/linux/page-flags.h
> > >+++ b/include/linux/page-flags.h
> > >@@ -547,7 +547,13 @@ static inline void ClearPageCompound(struct page *page)
> > >  #endif /* !PAGEFLAGS_EXTENDED */
> > >
> > >  #ifdef CONFIG_HUGETLB_PAGE
> > >-int PageHuge(struct page *page);
> > >+int __PageHuge(struct page *page);
> > >+static inline int PageHuge(struct page *page)
> > >+{
> > >+	if (!PageCompound(page))
> > 
> > Perhaps the above as likely()?
> 
> I have added it already when writing the changelog.
> 
> > [...]
> > 
> > >-EXPORT_SYMBOL_GPL(PageHuge);
> > >+EXPORT_SYMBOL_GPL(__PageHuge);
> > >
> > >  /*
> > >   * PageHeadHuge() only returns true for hugetlbfs head page, but not for
> > >
> > 
> > Do the same thing here by inlining the PageHead() test?
> > I guess the page_to_pgoff and __compound_tail_refcounted callers are rather
> > hot?
> 
> Yes, that sounds like a good idea.

So the overal codesize (with defconfig) has still grown with the patch:
   text    data     bss     dec     hex filename
 443075   59217   25604  527896   80e18 mm/built-in.o.before
 443477   59217   25604  528298   80faa mm/built-in.o.PageHuge
 443653   59217   25604  528474   8105a mm/built-in.o.both

It is still not ~1K with the full inline but quite large on its own.
So I am not sure it makes sense to fiddle with this without actually
seeing some penalty in profiles.

Here is what I have if somebody wants to play with it:
---
