Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id B03D48E0002
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 09:39:44 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id s22so1663631pgv.8
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 06:39:44 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q19si2010363pfh.138.2018.12.20.06.39.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 06:39:43 -0800 (PST)
Date: Thu, 20 Dec 2018 15:39:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm, page_alloc: Fix has_unmovable_pages for HugePages
Message-ID: <20181220143939.GA6210@dhcp22.suse.cz>
References: <20181217225113.17864-1-osalvador@suse.de>
 <20181219142528.yx6ravdyzcqp5wtd@master>
 <20181219233914.2fxe26pih26ifvmt@d104.suse.de>
 <20181220091228.GB14234@dhcp22.suse.cz>
 <20181220124925.itwuuacgztpgsk7s@d104.suse.de>
 <20181220130606.GG9104@dhcp22.suse.cz>
 <20181220134132.6ynretwlndmyupml@d104.suse.de>
 <20181220142124.r34fnuv6b33luj5a@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181220142124.r34fnuv6b33luj5a@d104.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, vbabka@suse.cz, pavel.tatashin@microsoft.com, rppt@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 20-12-18 15:21:27, Oscar Salvador wrote:
> On Thu, Dec 20, 2018 at 02:41:32PM +0100, Oscar Salvador wrote:
> > On Thu, Dec 20, 2018 at 02:06:06PM +0100, Michal Hocko wrote:
> > > You did want iter += skip_pages - 1 here right?
> > 
> > Bleh, yeah.
> > I am taking vacation today so my brain has left me hours ago, sorry.
> > Should be:
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 4812287e56a0..0634fbdef078 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -8094,7 +8094,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
> >                                 goto unmovable;
> >  
> >                         skip_pages = (1 << compound_order(head)) - (page - head);
> > -                       iter = round_up(iter + 1, skip_pages) - 1;
> > +                       iter += skip_pages - 1;
> >                         continue;
> >                 }
> 
> On a second thought, I think it should not really matter.
> 
> AFAICS, we can have these scenarios:
> 
> 1) the head page is the first page in the pabeblock
> 2) first page in the pageblock is not a head but part of a hugepage
> 3) the head is somewhere within the pageblock
> 
> For cases 1) and 3), iter will just get the right value and we will
> break the loop afterwards.
> 
> In case 2), iter will be set to a value to skip over the remaining pages.
> 
> I am assuming that hugepages are allocated and packed together.
> 
> Note that I am not against the change, but I just wanted to see if there is
> something I am missing.

Yes, you are missing that this code should be as sane as possible ;) You
are right that we are only processing one pageorder worth of pfns and
that the page order is bound to HUGETLB_PAGE_ORDER _right_now_. But
there is absolutely zero reason to hardcode that assumption into a
simple loop, right?
-- 
Michal Hocko
SUSE Labs
