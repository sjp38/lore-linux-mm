Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1AE636B010E
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 08:54:15 -0400 (EDT)
Date: Wed, 22 Jul 2009 13:54:06 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 06/10] ksm: identify PageKsm pages
In-Reply-To: <4A660101.3000307@redhat.com>
Message-ID: <Pine.LNX.4.64.0907221346040.529@sister.anvils>
References: <1247851850-4298-1-git-send-email-ieidus@redhat.com>
 <1247851850-4298-2-git-send-email-ieidus@redhat.com>
 <1247851850-4298-3-git-send-email-ieidus@redhat.com>
 <1247851850-4298-4-git-send-email-ieidus@redhat.com>
 <1247851850-4298-5-git-send-email-ieidus@redhat.com>
 <1247851850-4298-6-git-send-email-ieidus@redhat.com>
 <1247851850-4298-7-git-send-email-ieidus@redhat.com> <20090721175139.GE2239@random.random>
 <4A660101.3000307@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, chrisw@redhat.com, avi@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Jul 2009, Rik van Riel wrote:
> Andrea Arcangeli wrote:
> > > -	if (PageAnon(old_page)) {
> > > +	if (PageAnon(old_page) && !PageKsm(old_page)) {
> > >    if (!trylock_page(old_page)) {
> > >     page_cache_get(old_page);
> > >     pte_unmap_unlock(page_table, ptl);
> > 
> > What exactly does it buy to have PageAnon return 1 on ksm pages,
> > besides requiring the above additional check (that if we stick to the
> > above code, I would find safer to move inside reuse_swap_page).
> 
> I guess that if they are to remain unswappable, they
> should go onto the unevictable list.

The KSM pages are not put on any LRU, so wouldn't be slowing vmscan
down with futile scans: isn't the unevictable list for pages which
belong to another LRU once they become evictable again?

(At this instant I've forgotten why there's an unevictable list at
all - somewhere in vmscan.c which is accustomed to dealing with
pages on lists, so easier to have them on a list than not?)

> 
> Then again, I'm guessing this is all about to change
> in not too much time :)

Yes, I'd much rather put the effort into making them swappable,
than fiddling with counts here and there to highlight their
current unswappability.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
