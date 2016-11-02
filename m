Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id DDDD86B02A1
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 04:34:26 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id rt15so4600635pab.5
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 01:34:26 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id t5si1683086pgj.143.2016.11.02.01.34.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Nov 2016 01:34:25 -0700 (PDT)
Date: Wed, 2 Nov 2016 11:33:51 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 2/2] mm: add PageWaiters bit to indicate waitqueue should
 be checked
Message-ID: <20161102083351.bwl744znpacfkk52@black.fi.intel.com>
References: <20161102070346.12489-1-npiggin@gmail.com>
 <20161102070346.12489-3-npiggin@gmail.com>
 <20161102073156.GA13949@node.shutemov.name>
 <20161102185035.03f282c0@roar.ozlabs.ibm.com>
 <20161102075855.lt3323biol4cbfin@black.fi.intel.com>
 <20161102191248.5b1dd6cd@roar.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161102191248.5b1dd6cd@roar.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>

On Wed, Nov 02, 2016 at 07:12:48PM +1100, Nicholas Piggin wrote:
> On Wed, 2 Nov 2016 10:58:55 +0300
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > On Wed, Nov 02, 2016 at 06:50:35PM +1100, Nicholas Piggin wrote:
> > > On Wed, 2 Nov 2016 10:31:57 +0300
> > > "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> > >   
> > > > On Wed, Nov 02, 2016 at 06:03:46PM +1100, Nicholas Piggin wrote:  
> > > > > Add a new page flag, PageWaiters. This bit is always set when the
> > > > > page has waiters on page_waitqueue(page), within the same synchronization
> > > > > scope as waitqueue_active(page) (i.e., it is manipulated under waitqueue
> > > > > lock). It may be set in some cases where that condition is not true
> > > > > (e.g., some scenarios of hash collisions or signals waking page waiters).
> > > > > 
> > > > > This bit can be used to avoid the costly waitqueue_active test for most
> > > > > cases where the page has no waiters (the hashed address effectively adds
> > > > > another line of cache footprint for most page operations). In cases where
> > > > > the bit is set when the page has no waiters, the slower wakeup path will
> > > > > end up clearing up the bit.
> > > > > 
> > > > > The generic bit-waitqueue infrastructure is no longer used for pages, and
> > > > > instead waitqueues are used directly with a custom key type. The generic
> > > > > code was not flexible enough to do PageWaiters manipulation under waitqueue
> > > > > lock, or always allow danging bits to be cleared when no waiters for this
> > > > > page on the waitqueue.
> > > > > 
> > > > > The upshot is that the page wait is much more flexible now, and could be
> > > > > easily extended to wait on other properties of the page (by carrying that
> > > > > data in the wait key).
> > > > > 
> > > > > This improves the performance of a streaming write into a preallocated
> > > > > tmpfs file by 2.2% on a POWER8 system with 64K pages (which is pretty
> > > > > significant if there is only a single unlock_page per 64K of copy_from_user).
> > > > > 
> > > > > Idea seems to have been around for a while, https://lwn.net/Articles/233391/
> > > > > 
> > > > > ---
> > > > >  include/linux/page-flags.h     |   2 +
> > > > >  include/linux/pagemap.h        |  23 +++---
> > > > >  include/trace/events/mmflags.h |   1 +
> > > > >  mm/filemap.c                   | 157 ++++++++++++++++++++++++++++++++---------
> > > > >  mm/swap.c                      |   2 +
> > > > >  5 files changed, 138 insertions(+), 47 deletions(-)
> > > > > 
> > > > > diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> > > > > index 58d30b8..da40a1d 100644
> > > > > --- a/include/linux/page-flags.h
> > > > > +++ b/include/linux/page-flags.h
> > > > > @@ -73,6 +73,7 @@
> > > > >   */
> > > > >  enum pageflags {
> > > > >  	PG_locked,		/* Page is locked. Don't touch. */
> > > > > +	PG_waiters,		/* Page has waiters, check its waitqueue */
> > > > >  	PG_error,
> > > > >  	PG_referenced,
> > > > >  	PG_uptodate,
> > > > > @@ -255,6 +256,7 @@ static inline int TestClearPage##uname(struct page *page) { return 0; }
> > > > >  	TESTSETFLAG_FALSE(uname) TESTCLEARFLAG_FALSE(uname)
> > > > >  
> > > > >  __PAGEFLAG(Locked, locked, PF_NO_TAIL)
> > > > > +PAGEFLAG(Waiters, waiters, PF_NO_COMPOUND) __CLEARPAGEFLAG(Waiters, waiters, PF_NO_COMPOUND)    
> > > > 
> > > > This should be at least PF_NO_TAIL to work with shmem/tmpfs huge pages.  
> > > 
> > > I thought all paths using it already took the head page, but I'll double
> > > check. Did you see a specific problem?  
> > 
> > PF_NO_COMPOUND doesn't allow both head and tail pages.
> > CONFIG_DEBUG_VM_PGFLAGS=y will make it expode.
> > 
> 
> Oh my mistake, that should be something like PF_ONLY_HEAD, where
> 
> #define PF_ONLY_HEAD(page, enforce) ({                                    \
>                 VM_BUG_ON_PGFLAGS(PageTail(page), page);                  \
>                 page; })

Feel free to rename PF_NO_TAIL :)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
