Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B16966B004F
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 09:48:32 -0400 (EDT)
Date: Tue, 16 Jun 2009 21:49:44 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 09/22] HWPOISON: Handle hardware poisoned pages in
	try_to_unmap
Message-ID: <20090616134944.GB7524@localhost>
References: <20090615024520.786814520@intel.com> <20090615031253.530308256@intel.com> <28c262360906150609gd736bf7p7a57de1b81cedd97@mail.gmail.com> <20090615152612.GA11700@localhost> <20090616090308.bac3b1f7.minchan.kim@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20090616090308.bac3b1f7.minchan.kim@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 16, 2009 at 08:03:08AM +0800, Minchan Kim wrote:
> On Mon, 15 Jun 2009 23:26:12 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > On Mon, Jun 15, 2009 at 09:09:03PM +0800, Minchan Kim wrote:
> > > On Mon, Jun 15, 2009 at 11:45 AM, Wu Fengguang<fengguang.wu@intel.com> wrote:
> > > > From: Andi Kleen <ak@linux.intel.com>
> > > >
> > > > When a page has the poison bit set replace the PTE with a poison entry.
> > > > This causes the right error handling to be done later when a process runs
> > > > into it.
> > > >
> > > > Also add a new flag to not do that (needed for the memory-failure handler
> > > > later)
> > > >
> > > > Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
> > > > Signed-off-by: Andi Kleen <ak@linux.intel.com>
> > > >
> > > > ---
> > > > A include/linux/rmap.h | A  A 1 +
> > > > A mm/rmap.c A  A  A  A  A  A | A  A 9 ++++++++-
> > > > A 2 files changed, 9 insertions(+), 1 deletion(-)
> > > >
> > > > --- sound-2.6.orig/mm/rmap.c
> > > > +++ sound-2.6/mm/rmap.c
> > > > @@ -958,7 +958,14 @@ static int try_to_unmap_one(struct page
> > > > A  A  A  A /* Update high watermark before we lower rss */
> > > > A  A  A  A update_hiwater_rss(mm);
> > > >
> > > > - A  A  A  if (PageAnon(page)) {
> > > > + A  A  A  if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
> > > > + A  A  A  A  A  A  A  if (PageAnon(page))
> > > > + A  A  A  A  A  A  A  A  A  A  A  dec_mm_counter(mm, anon_rss);
> > > > + A  A  A  A  A  A  A  else if (!is_migration_entry(pte_to_swp_entry(*pte)))
> > > 
> > > Isn't it straightforward to use !is_hwpoison_entry ?
> > 
> > Good catch!  It looks like a redundant check: the
> > page_check_address() at the beginning of the function guarantees that 
> > !is_migration_entry() or !is_migration_entry() tests will all be TRUE.
> > So let's do this?
> It seems you expand my sight :)
> 
> I don't know migration well.
> How page_check_address guarantee it's not migration entry ? 

page_check_address() calls pte_present() which returns the
(_PAGE_PRESENT | _PAGE_PROTNONE) bits. While x86-64 defines

#define __swp_entry(type, offset)       ((swp_entry_t) { \
                                         ((type) << (_PAGE_BIT_PRESENT + 1)) \
                                         | ((offset) << SWP_OFFSET_SHIFT) })

where SWP_OFFSET_SHIFT is defined to the bigger one of
max(_PAGE_BIT_PROTNONE + 1, _PAGE_BIT_FILE + 1) = max(8+1, 6+1) = 9.

So __swp_entry(type, offset) := (type << 1) | (offset << 9)

We know that the swap type is 5 bits. So the bit 0 _PAGE_PRESENT and bit 8
_PAGE_PROTNONE will all be zero for swap entries.
 

> In addtion, If the page is poison while we are going to
> migration((PAGE_MIGRATION && migration) == TRUE), we should decrease
> file_rss ?

It will die on trying to migrate the poisoned page so we don't care
the accounting. But normally the poisoned page shall already be
isolated so we don't care that die either.

Thanks,
Fengguang

> > 
> > - A  A  A  A  A  A  A  else if (!is_migration_entry(pte_to_swp_entry(*pte)))
> > + A  A  A  A  A  A  A  else
> > 
> > 
> > Thanks,
> > Fengguang
> 
> 
> -- 
> Kinds Regards
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
