Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 71CAE6B0038
	for <linux-mm@kvack.org>; Tue, 20 Oct 2015 03:21:17 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so12930746pad.1
        for <linux-mm@kvack.org>; Tue, 20 Oct 2015 00:21:17 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id t8si3047068pbs.231.2015.10.20.00.21.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Oct 2015 00:21:16 -0700 (PDT)
Received: by pasz6 with SMTP id z6so12865472pas.2
        for <linux-mm@kvack.org>; Tue, 20 Oct 2015 00:21:16 -0700 (PDT)
Date: Tue, 20 Oct 2015 16:21:09 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/5] MADV_FREE refactoring and fix KSM page
Message-ID: <20151020072109.GD2941@bbox>
References: <1445236307-895-1-git-send-email-minchan@kernel.org>
 <20151019100150.GA5194@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151019100150.GA5194@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

On Mon, Oct 19, 2015 at 07:01:50PM +0900, Minchan Kim wrote:
> On Mon, Oct 19, 2015 at 03:31:42PM +0900, Minchan Kim wrote:
> > Hello, it's too late since I sent previos patch.
> > https://lkml.org/lkml/2015/6/3/37
> > 
> > This patch is alomost new compared to previos approach.
> > I think this is more simple, clear and easy to review.
> > 
> > One thing I should notice is that I have tested this patch
> > and couldn't find any critical problem so I rebased patchset
> > onto recent mmotm(ie, mmotm-2015-10-15-15-20) to send formal
> > patchset. Unfortunately, I start to see sudden discarding of
> > the page we shouldn't do. IOW, application's valid anonymous page
> > was disappeared suddenly.
> > 
> > When I look through THP changes, I think we could lose
> > dirty bit of pte between freeze_page and unfreeze_page
> > when we mark it as migration entry and restore it.
> > So, I added below simple code without enough considering
> > and cannot see the problem any more.
> > I hope it's good hint to find right fix this problem.
> > 
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index d5ea516ffb54..e881c04f5950 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -3138,6 +3138,9 @@ static void unfreeze_page_vma(struct vm_area_struct *vma, struct page *page,
> >  		if (is_write_migration_entry(swp_entry))
> >  			entry = maybe_mkwrite(entry, vma);
> >  
> > +		if (PageDirty(page))
> > +			SetPageDirty(page);
> 
> The condition of PageDirty was typo. I didn't add the condition.
> Just added.
> 
>                 SetPageDirty(page);

I reviewed THP refcount redesign patch and It seems below patch fixes
MADV_FREE problem. It works well for hours.
