Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B031D6B010C
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 08:45:41 -0400 (EDT)
Date: Wed, 22 Jul 2009 13:45:15 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 06/10] ksm: identify PageKsm pages
In-Reply-To: <20090721175139.GE2239@random.random>
Message-ID: <Pine.LNX.4.64.0907221313370.529@sister.anvils>
References: <1247851850-4298-1-git-send-email-ieidus@redhat.com>
 <1247851850-4298-2-git-send-email-ieidus@redhat.com>
 <1247851850-4298-3-git-send-email-ieidus@redhat.com>
 <1247851850-4298-4-git-send-email-ieidus@redhat.com>
 <1247851850-4298-5-git-send-email-ieidus@redhat.com>
 <1247851850-4298-6-git-send-email-ieidus@redhat.com>
 <1247851850-4298-7-git-send-email-ieidus@redhat.com> <20090721175139.GE2239@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, chrisw@redhat.com, avi@redhat.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Jul 2009, Andrea Arcangeli wrote:
> On Fri, Jul 17, 2009 at 08:30:46PM +0300, Izik Eidus wrote:
> > +static inline int PageKsm(struct page *page)
> > +{
> > +	return ((unsigned long)page->mapping == PAGE_MAPPING_ANON);
> > +}
> 
> I'm unconvinced it's sane to have PageAnon return 1 on Ksm pages.

If they're to be vm_normal_page pages (I think we'll agree they are),
then for now they have to be counted either as file pages or as anon
pages.  We could trawl through mm/ adding the third category for KSM
pages, but I don't think that would be sensible - KSM is mostly
keeping out of everybody's way, and I want to preserve that.

They're not file pages in any sense, and they're clearly anon pages:
I got quite alarmed by the original /dev/ksm KSM, when I found my
task's anon rss going down and its file rss going up - there used
to be a special transfer from anon to file rss in replace_page().

I certainly agree they're a _special_ case of anon page,
and I think that's reflected by the NULL anon_vma.

I think you're getting sidetracked by the knowledge that they're
not just ordinary anon pages: yes, but they're certainly not file
pages, they are anonymous pages.

> 
> The above will also have short lifetime so not sure it's worth it,
> if we want to swap we'll have to move to something that to:
> 
> PageExternal()
> {
> 	return (unsigned long)page->mapping & PAGE_MAPPING_EXTERNAL != 0;
> }

I don't know about "External" (sounds like you have plans beyond KSM
that Izik is aware of but I'm not); but yes, I was imagining that for
swapping these pages we will use a PAGE_MAPPING_KSM bit 2 (set in
addition to PAGE_MAPPING_ANON), so that the pointer in page->mapping
needn't be NULL, but point somewhere useful into the stable tree,
to enable rmap.c operations on these pages.

But I'd still expect them to be PageAnon: even more so, really -
once they're swapping, they're even more ordinary anonymous pages.

> 
> > +static inline void page_add_ksm_rmap(struct page *page)
> > +{
> > +	if (atomic_inc_and_test(&page->_mapcount)) {
> > +		page->mapping = (void *) PAGE_MAPPING_ANON;
> > +		__inc_zone_page_state(page, NR_ANON_PAGES);
> > +	}
> > +}
> 
> Is it correct to account them as anon pages?

Yes: surely, they're not file pages, and that is the alternative.

Leave them out of such accounting completely, or give them their
own stats: yes, that can be done, but not without changes elsewhere;
which I think we'd prefer not to press until KSM is a more accepted
part of regular mm operation.

> 
> > -	if (PageAnon(old_page)) {
> > +	if (PageAnon(old_page) && !PageKsm(old_page)) {
> >  		if (!trylock_page(old_page)) {
> >  			page_cache_get(old_page);
> >  			pte_unmap_unlock(page_table, ptl);
> 
> What exactly does it buy to have PageAnon return 1 on ksm pages,
> besides requiring the above additional check (that if we stick to the
> above code, I would find safer to move inside reuse_swap_page).

That's certainly the ugliest part of accepting PageKsm pages as
PageAnon, and I wept when I realized we needed that check (well,
I exaggerate a little ;).

It didn't cross my mind to move it into reuse_swap_page(): yes,
we could do that.  I don't see how it's safer; and to be honest,
its main appeal to me is that it would hide this wart away more,
where fewer eyes would notice it.  Which may not be the best
argument for making the move!  Technically, I think it would
just increase the overhead of COWing a KSM page (getting that
page lock, maybe having to drop ptlock etc.), but that may not
matter much: please persuade me it's safer in reuse_swap_page()
and I'll move it there.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
