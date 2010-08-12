Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A58716B02A5
	for <linux-mm@kvack.org>; Thu, 12 Aug 2010 03:54:58 -0400 (EDT)
Date: Thu, 12 Aug 2010 16:53:23 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 0/9] Hugepage migration (v2)
Message-ID: <20100812075323.GA6112@spritzera.linux.bs1.fc.nec.co.jp>
References: <1281432464-14833-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.DEB.2.00.1008110806070.673@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1008110806070.673@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 11, 2010 at 08:09:59AM -0500, Christoph Lameter wrote:
> On Tue, 10 Aug 2010, Naoya Horiguchi wrote:
> 
> > There were two points of issue.
> >
> > * Dividing hugepage migration functions from original migration code.
> >   This is to avoid complexity.
> >   In present version, some high level migration routines are defined to handle
> >   hugepage, but some low level routines (such as migrate_copy_page() etc.)
> >   are shared with original migration code in order not to increase duplication.
> 
> I hoped that we can avoid the branching for taking stuff off the lru and
> put pages back later to the lru. Seems that we still do that. Can be
> refactor the code in such a way that the lru handling cleanly isolates?
> There are now multiple use cases for migration that could avoid LRU
> handling even for PAGE_SIZE pages.

OK.
I'll rewrite isolation_lru_page() and putback_lru_page() like this:

   isolation_lru_page()
      for PAGE_SIZE page : delete from LRU list and get count
      for hugepage       : just get count

   putback_lru_page()
      for PAGE_SIZE page : add to LRU list and put count
      for hugepage       : just put count

By doing this, we can avoid ugly code in individual migration callers.


> > * Locking problem between direct I/O and hugepage migration
> >   As a result of digging the race between hugepage I/O and hugepage migration,
> >   (where hugepage I/O can be seen only in direct I/O,)
> >   I noticed that without additional locking we can avoid this race condition
> >   because in direct I/O we can get whether some subpages are under I/O or not
> >   from reference count of the head page and hugepage migration safely fails
> >   if some references remain.  So no data lost should occurs on the migration
> >   concurrent with direct I/O.
> 
> Can you also avoid refcounts being increased during migration?

Yes. I think this will be done in above-mentioned refactoring.

> The page
> lock is taken for the PAGE_SIZEd migration case. Can direct I/O be stopped
> by taking the page lock on the head page? If not then races can still
> occur.

Ah. I missed it.
This patch only handles migration under direct I/O.
For the opposite (direct I/O under migration) it's not true.
I wrote additional patches (later I'll reply to this email)
for solving locking problem. Could you review them?

(Maybe these patches are beyond the scope of hugepage migration patch,
so is it better to propose them separately?)

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
