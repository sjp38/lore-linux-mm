Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CD2236B005A
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 11:25:59 -0400 (EDT)
Date: Mon, 15 Jun 2009 23:26:12 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 09/22] HWPOISON: Handle hardware poisoned pages in
	try_to_unmap
Message-ID: <20090615152612.GA11700@localhost>
References: <20090615024520.786814520@intel.com> <20090615031253.530308256@intel.com> <28c262360906150609gd736bf7p7a57de1b81cedd97@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <28c262360906150609gd736bf7p7a57de1b81cedd97@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 15, 2009 at 09:09:03PM +0800, Minchan Kim wrote:
> On Mon, Jun 15, 2009 at 11:45 AM, Wu Fengguang<fengguang.wu@intel.com> wrote:
> > From: Andi Kleen <ak@linux.intel.com>
> >
> > When a page has the poison bit set replace the PTE with a poison entry.
> > This causes the right error handling to be done later when a process runs
> > into it.
> >
> > Also add a new flag to not do that (needed for the memory-failure handler
> > later)
> >
> > Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
> > Signed-off-by: Andi Kleen <ak@linux.intel.com>
> >
> > ---
> > A include/linux/rmap.h | A  A 1 +
> > A mm/rmap.c A  A  A  A  A  A | A  A 9 ++++++++-
> > A 2 files changed, 9 insertions(+), 1 deletion(-)
> >
> > --- sound-2.6.orig/mm/rmap.c
> > +++ sound-2.6/mm/rmap.c
> > @@ -958,7 +958,14 @@ static int try_to_unmap_one(struct page
> > A  A  A  A /* Update high watermark before we lower rss */
> > A  A  A  A update_hiwater_rss(mm);
> >
> > - A  A  A  if (PageAnon(page)) {
> > + A  A  A  if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
> > + A  A  A  A  A  A  A  if (PageAnon(page))
> > + A  A  A  A  A  A  A  A  A  A  A  dec_mm_counter(mm, anon_rss);
> > + A  A  A  A  A  A  A  else if (!is_migration_entry(pte_to_swp_entry(*pte)))
> 
> Isn't it straightforward to use !is_hwpoison_entry ?

Good catch!  It looks like a redundant check: the
page_check_address() at the beginning of the function guarantees that 
!is_migration_entry() or !is_migration_entry() tests will all be TRUE.

So let's do this?

- A  A  A  A  A  A  A  else if (!is_migration_entry(pte_to_swp_entry(*pte)))
+ A  A  A  A  A  A  A  else


Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
