Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 19E606B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 15:04:12 -0400 (EDT)
Date: Wed, 16 Sep 2009 21:04:31 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: use-once mapped file pages
Message-ID: <20090916190431.GA20897@cmpxchg.org>
References: <1252971975-15218-1-git-send-email-hannes@cmpxchg.org> <28c262360909150826s2a0f5f0dpd111640f92d0f5ff@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <28c262360909150826s2a0f5f0dpd111640f92d0f5ff@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hello Minchan,

On Wed, Sep 16, 2009 at 12:26:27AM +0900, Minchan Kim wrote:
> Hi, Hannes.

[snapped stuff Rik answered already]

> > When dropping into reclaim, the VM has a hard time making progress
> > with these pages dominating. A And since all mapped pages are treated
> > equally (i.e. anon pages as well), a major part of the anon working
> > set is swapped out before the hashing completes as well.
> >
> > Failing reclaim and swapping show up pretty quickly in decreasing
> > overall system interactivity, but also in the throughput of the
> > hashing process itself.
> >
> > This patch implements a use-once strategy for mapped file pages.
> >
> > For this purpose, mapped file pages with page table references are not
> > directly activated at the end of the inactive list anymore but marked
> > with PG_referenced and sent on another roundtrip on the inactive list.
> > If such a page comes in again, another page table reference activates
> > it while the lack thereof leads to its eviction.
> >
> > The deactivation path does not clear this mark so that a subsequent
> > page table reference for a page coming from the active list means
> > reactivation as well.
> 
> It seems to be good idea. but I have a concern about embedded.
> AFAIK, some CPUs don't have accessed bit by hardware.
> maybe ARM series.
> (Nowadays, Some kinds of CPU series just supports access bit.
> but there are still CPUs that doesn't support it)
> 
> I am not sure there are others architecture.
> Your idea makes mapped page reclaim depend on access bit more tightly.
>  :(

ARM seems to emulate the accessed bit by ensuring a subsequent access
will fault when the young bit is cleared, so we should get one extra
minor fault per finally activated mapped file page as a trade-off.

I am not too concerned about that because it should be a rather rare
event.  Only fresh pages go through that.  PG_referenced is remembered
over activation/deactivation and once it's set, a page is treated just
like it is now: activated if referenced, reclaimed if not.

So yeah, there is a bit more overhead for ARM to approximate the
working set initially.  But the results are more trustworthy and we
get rid of a badly performing corner case in the VM.

> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index 28aafe2..0c88813 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -508,9 +508,6 @@ int page_referenced(struct page *page,
> > A {
> > A  A  A  A int referenced = 0;
> >
> > - A  A  A  if (TestClearPageReferenced(page))
> > - A  A  A  A  A  A  A  referenced++;
> > -

This hunk should also get removed from the !CONFIG_MMU dummy function.
I'll wait a bit for more feedback and send a fixed revision.

Thanks,
	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
