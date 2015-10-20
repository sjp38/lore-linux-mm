Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id A16F282F64
	for <linux-mm@kvack.org>; Tue, 20 Oct 2015 03:28:03 -0400 (EDT)
Received: by pabrc13 with SMTP id rc13so13070803pab.0
        for <linux-mm@kvack.org>; Tue, 20 Oct 2015 00:28:03 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id y12si3116486pbt.182.2015.10.20.00.28.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Oct 2015 00:28:02 -0700 (PDT)
Received: by pasz6 with SMTP id z6so13053183pas.2
        for <linux-mm@kvack.org>; Tue, 20 Oct 2015 00:28:02 -0700 (PDT)
Date: Tue, 20 Oct 2015 16:27:56 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/5] MADV_FREE refactoring and fix KSM page
Message-ID: <20151020072756.GE2941@bbox>
References: <1445236307-895-1-git-send-email-minchan@kernel.org>
 <20151019100150.GA5194@bbox>
 <20151020072109.GD2941@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151020072109.GD2941@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

On Tue, Oct 20, 2015 at 04:21:09PM +0900, Minchan Kim wrote:
> On Mon, Oct 19, 2015 at 07:01:50PM +0900, Minchan Kim wrote:
> > On Mon, Oct 19, 2015 at 03:31:42PM +0900, Minchan Kim wrote:
> > > Hello, it's too late since I sent previos patch.
> > > https://lkml.org/lkml/2015/6/3/37
> > > 
> > > This patch is alomost new compared to previos approach.
> > > I think this is more simple, clear and easy to review.
> > > 
> > > One thing I should notice is that I have tested this patch
> > > and couldn't find any critical problem so I rebased patchset
> > > onto recent mmotm(ie, mmotm-2015-10-15-15-20) to send formal
> > > patchset. Unfortunately, I start to see sudden discarding of
> > > the page we shouldn't do. IOW, application's valid anonymous page
> > > was disappeared suddenly.
> > > 
> > > When I look through THP changes, I think we could lose
> > > dirty bit of pte between freeze_page and unfreeze_page
> > > when we mark it as migration entry and restore it.
> > > So, I added below simple code without enough considering
> > > and cannot see the problem any more.
> > > I hope it's good hint to find right fix this problem.
> > > 
> > > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > > index d5ea516ffb54..e881c04f5950 100644
> > > --- a/mm/huge_memory.c
> > > +++ b/mm/huge_memory.c
> > > @@ -3138,6 +3138,9 @@ static void unfreeze_page_vma(struct vm_area_struct *vma, struct page *page,
> > >  		if (is_write_migration_entry(swp_entry))
> > >  			entry = maybe_mkwrite(entry, vma);
> > >  
> > > +		if (PageDirty(page))
> > > +			SetPageDirty(page);
> > 
> > The condition of PageDirty was typo. I didn't add the condition.
> > Just added.
> > 
> >                 SetPageDirty(page);
> 
> I reviewed THP refcount redesign patch and It seems below patch fixes
> MADV_FREE problem. It works well for hours.
> 
> From 104a0940b4c0f97e61de9fee0fd602926ff28312 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Tue, 20 Oct 2015 16:00:52 +0900
> Subject: [PATCH] mm: mark head page dirty in split_huge_page
> 
> In thp split in old THP refcount, we mappped all of pages
> (ie, head + tails) to pte_mkdirty and mark PG_flags to every
> tail pages.
> 
> But with THP refcount redesign, we can lose dirty bit in page table
> and PG_dirty for head page if we want to free the THP page using
 
typo.
                                           freeze

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
