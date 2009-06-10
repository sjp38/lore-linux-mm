Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 303846B0062
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 22:26:50 -0400 (EDT)
Date: Wed, 10 Jun 2009 10:27:36 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [8/16] HWPOISON: Use bitmask/action code for
	try_to_unmap behaviour
Message-ID: <20090610022736.GC6597@localhost>
References: <20090603846.816684333@firstfloor.org> <20090603184641.868D31D0282@basil.firstfloor.org> <20090609095725.GC14820@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090609095725.GC14820@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, "Lee.Schermerhorn@hp.com" <Lee.Schermerhorn@hp.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 09, 2009 at 05:57:25PM +0800, Nick Piggin wrote:
> On Wed, Jun 03, 2009 at 08:46:41PM +0200, Andi Kleen wrote:
> > 
> > try_to_unmap currently has multiple modi (migration, munlock, normal unmap)
> > which are selected by magic flag variables. The logic is not very straight
> > forward, because each of these flag change multiple behaviours (e.g.
> > migration turns off aging, not only sets up migration ptes etc.)
> > Also the different flags interact in magic ways.
> > 
> > A later patch in this series adds another mode to try_to_unmap, so 
> > this becomes quickly unmanageable.
> > 
> > Replace the different flags with a action code (migration, munlock, munmap)
> > and some additional flags as modifiers (ignore mlock, ignore aging).
> > This makes the logic more straight forward and allows easier extension
> > to new behaviours. Change all the caller to declare what they want to 
> > do.
> > 
> > This patch is supposed to be a nop in behaviour. If anyone can prove 
> > it is not that would be a bug.
> > 
> > Cc: Lee.Schermerhorn@hp.com
> > Cc: npiggin@suse.de
> > 
> > Signed-off-by: Andi Kleen <ak@linux.intel.com>
> > 
> > ---
> >  include/linux/rmap.h |   14 +++++++++++++-
> >  mm/migrate.c         |    2 +-
> >  mm/rmap.c            |   40 ++++++++++++++++++++++------------------
> >  mm/vmscan.c          |    2 +-
> >  4 files changed, 37 insertions(+), 21 deletions(-)
> > 
> > Index: linux/include/linux/rmap.h
> > ===================================================================
> > --- linux.orig/include/linux/rmap.h	2009-06-03 19:36:23.000000000 +0200
> > +++ linux/include/linux/rmap.h	2009-06-03 20:39:50.000000000 +0200
> > @@ -84,7 +84,19 @@
> >   * Called from mm/vmscan.c to handle paging out
> >   */
> >  int page_referenced(struct page *, int is_locked, struct mem_cgroup *cnt);
> > -int try_to_unmap(struct page *, int ignore_refs);
> > +
> > +enum ttu_flags {
> > +	TTU_UNMAP = 0,			/* unmap mode */
> > +	TTU_MIGRATION = 1,		/* migration mode */
> > +	TTU_MUNLOCK = 2,		/* munlock mode */
> > +	TTU_ACTION_MASK = 0xff,
> > +
> > +	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
> > +	TTU_IGNORE_ACCESS = (1 << 9),	/* don't age */
> > +};
> > +#define TTU_ACTION(x) ((x) & TTU_ACTION_MASK)
> 
> I still think this is nasty and should work like Gfp flags.

I don't see big problems here.

We have page_zone() and gfp_zone(), so why not TTU_ACTION()? We could
allocate one bit for each action code, but in principle they are exclusive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
