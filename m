Date: Wed, 7 Mar 2007 08:25:46 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 3/6] mm: fix fault vs invalidate race for linear mappings
Message-ID: <20070307072545.GC15877@wotan.suse.de>
References: <20070221023656.6306.246.sendpatchset@linux.site> <20070221023724.6306.53097.sendpatchset@linux.site> <20070306223641.505db0e0.akpm@linux-foundation.org> <20070307065727.GA15877@wotan.suse.de> <20070306230841.69409ffc.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070306230841.69409ffc.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 06, 2007 at 11:08:41PM -0800, Andrew Morton wrote:
> On Wed, 7 Mar 2007 07:57:27 +0100 Nick Piggin <npiggin@suse.de> wrote:
> 
> > > 
> > > Why was truncate_inode_pages_range() altered to unmap the page if it got
> > > mapped again?
> > > 
> > > Oh.  Because the unmap_mapping_range() call got removed from vmtruncate(). 
> > > Why?  (Please send suitable updates to the changelog).
> > 
> > We have to ensure it is unmapped, and be prepared to unmap it while under
> > the page lock.
> 
> But vmtruncate() dropped i_size, so nobody will map this page into
> pagetables from then on.

But there could be a fault in progress... the only way to know is
locking the page.

> > > I guess truncate of a mmapped area isn't sufficiently common to worry about
> > > the inefficiency of this change.
> > 
> > Yeah, and it should be more efficient for files that aren't mmapped,
> > because we don't have to take i_mmap_lock for them.
> > 
> > > Lots of memory barriers got removed in memory.c, unchangeloggedly.
> > 
> > Yeah they were all for the lockless truncate_count checks. Now that
> > we use the page lock, we don't need barriers.
> > 
> > > Gratuitous renaming of locals in do_no_page() makes the change hard to
> > > review.  Should have been a separate patch.
> > > 
> > > In fact, the patch would have been heaps clearer if that renaming had been
> > > a separate patch.
> > 
> > Shall I?
> 
> If you don't have anything better to do, yes please ;)

OK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
