Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id DAB86828E2
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 07:24:40 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id na2so38524016lbb.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 04:24:40 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id cf5si16578694wjc.150.2016.06.22.04.24.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 04:24:39 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id a66so265541wme.2
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 04:24:39 -0700 (PDT)
Date: Wed, 22 Jun 2016 14:24:26 +0300
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: Re: [PATCHv9-rebased2 01/37] mm, thp: make swapin readahead under
 down_read of mmap_sem
Message-ID: <20160622112426.GA2028@gmail.com>
References: <04f701d1c797$1ebe6b80$5c3b4280$@alibaba-inc.com>
 <04f801d1c79b$b46744a0$1d35cde0$@alibaba-inc.com>
 <20160616100854.GB18137@node.shutemov.name>
 <20160618190951.GA11151@debian>
 <05f001d1ca9e$a3ac5a00$eb050e00$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <05f001d1ca9e$a3ac5a00$eb050e00$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org

On Mon, Jun 20, 2016 at 10:51:25AM +0800, Hillf Danton wrote:
> > > > > @@ -2401,11 +2430,18 @@ static void __collapse_huge_page_swapin(struct mm_struct *mm,
> > > > >  			continue;
> > > > >  		swapped_in++;
> > > > >  		ret = do_swap_page(mm, vma, _address, pte, pmd,
> > > > > -				   FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_RETRY_NOWAIT,
> > > > > +				   FAULT_FLAG_ALLOW_RETRY,
> > > >
> > > > Add a description in change log for it please.
> > >
> > > Ebru, would you address it?
> > >
> > This changelog really seems poor.
> > Is there a way to update only changelog of the commit?
> > I tried to use git rebase to amend commit, however
> > I could not rebase. This patch only needs better changelog.
> > 
> > I would like to update it as follows, if you would like to too:
> > 
> > "
> > Currently khugepaged makes swapin readahead under down_write.  This patch
> > supplies to make swapin readahead under down_read instead of down_write.
> > 
> > Along swapin, we can need to drop and re-take mmap_sem. Therefore we
> > have to be sure vma is consistent. This patch adds a helper function
> > to validate vma and also supplies that async swapin should not be
> > performed without waiting.
> > 
> > The patch was tested with a test program that allocates 800MB of memory,
> > writes to it, and then sleeps.  The system was forced to swap out all.
> > Afterwards, the test program touches the area by writing, it skips a page
> > in each 20 pages of the area.
> > "
> > 
> I like to ask again, why is FAULT_FLAG_RETRY_NOWAIT dropped?
> 
I dropped it regarding to Hugh's concern. If I understood correctly,
he said async swapin without waiting can cause waste. When I looked the
code path, it seemed subtle to me. There was a large discussion,
below is Hugh's concern:

"
Doesn't this imply that __collapse_huge_page_swapin() will initiate all
the necessary swapins for a THP, then (given the FAULT_FLAG_ALLOW_RETRY)
not wait for them to complete, so khugepaged will give up on that extent
and move on to another; then after another full circuit of all the mms
it needs to examine, it will arrive back at this extent and build a THP
from the swapins it arranged last time.

Which may work well when a system transitions from busy+swappingout
to idle+swappingin, but isn't that rather a special case?  It feels
(meaning, I've not measured at all) as if the inbetween busyish case
will waste a lot of I/O and memory on swapins that have to be discarded
again before khugepaged has made its sedate way back to slotting them in.
"

Cc'ed Hugh. Maybe I misunderstood him.

> > Could you please suggest me a way to replace above changelog with the old?
> > 
> We can ask Andrew for some advices.
> 
> > > >
> > > > They are cleaned up in subsequent darns?
> > >
> > Yes, that is reported and fixed here:
> > http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=fc7038a69cee6b817261f7cd805e9663fdc1075c
> > 
> > However, the above comment inconsistency still there.
> > I've added a fix patch:
> > 
> > From 404438ff1b0617cbf7434cba0c5a08f79ccb8a5d Mon Sep 17 00:00:00 2001
> > From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> > Date: Sat, 18 Jun 2016 21:07:22 +0300
> > Subject: [PATCH] mm, thp: fix comment inconsistency for swapin readahead
> >  functions
> >
> Fill in change log please.
> 
I filled it and sent as part of a series.
Cc'ed you in that patch.
> thanks
> Hillf
>  
> > Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> > ---
> >  mm/huge_memory.c | 9 +++++----
> >  1 file changed, 5 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index acd374e..f0d528e 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -2436,9 +2436,10 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
> >  		/* do_swap_page returns VM_FAULT_RETRY with released mmap_sem */
> >  		if (ret & VM_FAULT_RETRY) {
> >  			down_read(&mm->mmap_sem);
> > -			/* vma is no longer available, don't continue to swapin */
> > -			if (hugepage_vma_revalidate(mm, address))
> > +			if (hugepage_vma_revalidate(mm, address)) {
> > +				/* vma is no longer available, don't continue to swapin */
> >  				return false;
> > +			}
> >  		}
> >  		if (ret & VM_FAULT_ERROR) {
> >  			trace_mm_collapse_huge_page_swapin(mm, swapped_in, 0);
> > @@ -2513,8 +2514,8 @@ static void collapse_huge_page(struct mm_struct *mm,
> >  	if (allocstall == curr_allocstall && swap != 0) {
> >  		/*
> >  		 * __collapse_huge_page_swapin always returns with mmap_sem
> > -		 * locked.  If it fails, release mmap_sem and jump directly
> > -		 * out.  Continuing to collapse causes inconsistency.
> > +		 * locked. If it fails, we release mmap_sem and jump out_nolock.
> > +		 * Continuing to collapse causes inconsistency.
> >  		 */
> >  		if (!__collapse_huge_page_swapin(mm, vma, address, pmd)) {
> >  			mem_cgroup_cancel_charge(new_page, memcg, true);
> > --
> > 1.9.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
