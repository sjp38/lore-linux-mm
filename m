Subject: Re: [patch 17/20] non-reclaimable mlocked pages
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20071220103332.11c4bbd2@bree.surriel.com>
References: <20071218211539.250334036@redhat.com>
	 <20071218211550.186819416@redhat.com>
	 <200712191156.48507.nickpiggin@yahoo.com.au>
	 <Pine.LNX.4.64.0712192317420.13118@schroedinger.engr.sgi.com>
	 <20071220103332.11c4bbd2@bree.surriel.com>
Content-Type: text/plain
Date: Fri, 21 Dec 2007 12:13:43 -0500
Message-Id: <1198257223.5273.9.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-12-20 at 10:33 -0500, Rik van Riel wrote:
> On Wed, 19 Dec 2007 23:19:00 -0800 (PST)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > On Wed, 19 Dec 2007, Nick Piggin wrote:
> > 
> > > These mlocked pages don't need to be on a non-reclaimable list,
> > > because we can find them again via the ptes when they become
> > > unlocked, and there is no point background scanning them, because
> > > they're always going to be locked while they're mlocked.
> > 
> > But there is something to be said for having a consistent scheme. 
> 
> The code as called from .c files should indeed be consistent.
> 
> However, since we never need to scan the non-reclaimable list,
> we could use the inline functions in the .h files to have an
> mlock count instead of a .lru list head in the non-reclaimable
> pages.
> 
> At least, I think so.  I'm going to have to think about the
> details a lot more.  I have no idea yet if there will be any
> impact from batching the pages on pagevecs, vs. an atomic
> mlock count...

Just remember that page migration can migrate mlocked pages today, and
we'll want to continue to support this.  Migration uses the lru locks to
manage the pages selected for migration and uses isolation from lru list
under zone lru_lock to arbitrate any racing migrations.  Unless mlocked
pages are kept on an lru-like list, we'll need to put them back during
migration--possibly losing the mlock count or needing to save it
somewhere over [possibly lazy] migration.  

Note that having mlocked pages on the noreclaim lru list doesn't mean we
have to scan them to reclaim them.  It does however mean that we'd have
to skip over them to scan other types of non-reclaimable pages.  What
other types?  In my current implementation, SHM_LOCKed pages and
ramdisk/fs pages aren't mlocked.  Rather, they are culled to the
noreclaim list in vmscan when we detect a page on the [in]active list
that is in a nonreclaimable mapping.  This required minimal changes to
recognize and cull these nonreclaimable pages.  Currently PG_mlocked is
used only for pages mapped into a VM_LOCKED vma.  Since the noreclaim
list exists for the other types [and there could be more], it's little
additional work to keep mlocked pages there as well.  This makes them
play nice with migration.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
