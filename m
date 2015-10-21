Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 524286B0038
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 03:50:11 -0400 (EDT)
Received: by wijp11 with SMTP id p11so81578026wij.0
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 00:50:10 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id p5si10457390wif.44.2015.10.21.00.50.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 00:50:10 -0700 (PDT)
Received: by wicfx6 with SMTP id fx6so78448110wic.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 00:50:09 -0700 (PDT)
Date: Wed, 21 Oct 2015 10:50:07 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/5] MADV_FREE refactoring and fix KSM page
Message-ID: <20151021075007.GB10597@node.shutemov.name>
References: <1445236307-895-1-git-send-email-minchan@kernel.org>
 <20151019100150.GA5194@bbox>
 <20151020072109.GD2941@bbox>
 <20151020143651.64ce2c459cda168c714caf93@linux-foundation.org>
 <20151020224353.GA10597@node.shutemov.name>
 <20151021051131.GA6024@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151021051131.GA6024@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

On Wed, Oct 21, 2015 at 02:11:39PM +0900, Minchan Kim wrote:
> On Wed, Oct 21, 2015 at 01:43:53AM +0300, Kirill A. Shutemov wrote:
> > On Tue, Oct 20, 2015 at 02:36:51PM -0700, Andrew Morton wrote:
> > > On Tue, 20 Oct 2015 16:21:09 +0900 Minchan Kim <minchan@kernel.org> wrote:
> > > 
> > > > 
> > > > I reviewed THP refcount redesign patch and It seems below patch fixes
> > > > MADV_FREE problem. It works well for hours.
> > > > 
> > > > >From 104a0940b4c0f97e61de9fee0fd602926ff28312 Mon Sep 17 00:00:00 2001
> > > > From: Minchan Kim <minchan@kernel.org>
> > > > Date: Tue, 20 Oct 2015 16:00:52 +0900
> > > > Subject: [PATCH] mm: mark head page dirty in split_huge_page
> > > > 
> > > > In thp split in old THP refcount, we mappped all of pages
> > > > (ie, head + tails) to pte_mkdirty and mark PG_flags to every
> > > > tail pages.
> > > > 
> > > > But with THP refcount redesign, we can lose dirty bit in page table
> > > > and PG_dirty for head page if we want to free the THP page using
> > > > migration_entry.
> > > > 
> > > > It ends up discarding head page by madvise_free suddenly.
> > > > This patch fixes it by mark the head page PG_dirty when VM splits
> > > > the THP page.
> > > > 
> > > > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > > > ---
> > > >  mm/huge_memory.c | 1 +
> > > >  1 file changed, 1 insertion(+)
> > > > 
> > > > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > > > index adccfb48ce57..7fbbd42554a1 100644
> > > > --- a/mm/huge_memory.c
> > > > +++ b/mm/huge_memory.c
> > > > @@ -3258,6 +3258,7 @@ static void __split_huge_page(struct page *page, struct list_head *list)
> > > >  	atomic_sub(tail_mapcount, &head->_count);
> > > >  
> > > >  	ClearPageCompound(head);
> > > > +	SetPageDirty(head);
> > > >  	spin_unlock_irq(&zone->lru_lock);
> > > >  
> > > >  	unfreeze_page(page_anon_vma(head), head);
> >  
> > Sorry, I've missed the email at first.
> > 
> > > This appears to be a bugfix against Kirill's "thp: reintroduce
> > > split_huge_page()"?
> > > 
> > > Yes, __split_huge_page() is marking the tail pages dirty but forgot
> > > about the head page
> > > 
> > > You say "we can lose dirty bit in page table" but I don't see how the
> > > above patch fixes that?
> > 
> > I think the problem is in unfreeze_page_vma(), where I missed dirtying
> > pte.
> > 
> > > Why does __split_huge_page() unconditionally mark the pages dirty, btw?
> > > Is it because the THP page was known to be dirty?
> > 
> > THP doesn't have backing storage and cannot be swapped out without
> > splitting, therefore always dirty. (huge zero page is exception, I guess).
> 
> It's right until now but I think we need more(e.g. is_dirty_migration_entry,
> make_migration_entry(struct page *page, int write, int dirty) in terms of
> MADV_FREE to keep dirty bit of pte rather than making pages dirty
> unconditionally.

That means you need to find one more bit in swap entries. I'm not sure
it's possible on all architectures.

> 
> For example, we could call madvise_free to THP page so madvise_free clears
> dirty bit of pmd without split THP pages(ie, lazy split, maybe you suggest
> it, thanks!) instantly. Then, when VM tries to reclaim the THP page and
> splits it, every page will be marked PG_dirty or pte_mkdirty even if
> there is no write ever since then so madvise_free can never discard it
> although we could.
> 
> Anyway it shouldn't be party-pooper. It could be enhanced and I will check
> it.
> 
> 
> > 
> > > If so, the head page already had PG_dirty, so this patch doesn't do
> > > anything.
> > 
> > PG_dirty appears on struct page as result of transferring from dirty bit
> > in page tables. There's no guarantee that it's happened.
> > 
> > > freeze_page(), unfreeze_page() and their callees desperately need some
> > > description of what they're doing.  Kirill, could you cook somethnig up
> > > please?
> > 
> > Minchan, could you test patch below instead?
> 
> I think it will definitely work and more right fix than mine because
> it covers split_huge_page_to_list's error path(ie,
> 
>                 unfreeze_page(anon_vma, head);
>                 ret = -EBUSY;
>         }
> 
> 
> I will queue it to test machine.
> 
> ..
> Zzzz
> ..
> 
> After 2 hours, I don't see any problemso far but I have a question below.
> 
> > 
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index 86924cc34bac..ea1f3805afa3 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -3115,7 +3115,7 @@ static void unfreeze_page_vma(struct vm_area_struct *vma, struct page *page,
> >  
> >                 entry = pte_mkold(mk_pte(page, vma->vm_page_prot));
> >                 if (is_write_migration_entry(swp_entry))
> > -                       entry = maybe_mkwrite(entry, vma);
> > +                       entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> 
> Why should we do pte_mkdiry only if is_write_migration_entry is true?
> Doesn't it lose a dirty bit again if someone changes protection
> from RW to R?

2 a.m. is not ideal time for patches. You are right. It need to be
unconditionally.

Andrew, could you fold the patch below into "thp: reintroduce
split_huge_page()" instead of patch from Minchan?

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 86924cc34bac..f297baf8e793 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3114,6 +3114,7 @@ static void unfreeze_page_vma(struct vm_area_struct *vma, struct page *page,
 			continue;
 
 		entry = pte_mkold(mk_pte(page, vma->vm_page_prot));
+		entry = pte_mkdirty(entry);
 		if (is_write_migration_entry(swp_entry))
 			entry = maybe_mkwrite(entry, vma);
 
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
