Date: Tue, 6 Mar 2007 23:08:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 3/6] mm: fix fault vs invalidate race for linear
 mappings
Message-Id: <20070306230841.69409ffc.akpm@linux-foundation.org>
In-Reply-To: <20070307065727.GA15877@wotan.suse.de>
References: <20070221023656.6306.246.sendpatchset@linux.site>
	<20070221023724.6306.53097.sendpatchset@linux.site>
	<20070306223641.505db0e0.akpm@linux-foundation.org>
	<20070307065727.GA15877@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Mar 2007 07:57:27 +0100 Nick Piggin <npiggin@suse.de> wrote:

> > 
> > Why was truncate_inode_pages_range() altered to unmap the page if it got
> > mapped again?
> > 
> > Oh.  Because the unmap_mapping_range() call got removed from vmtruncate(). 
> > Why?  (Please send suitable updates to the changelog).
> 
> We have to ensure it is unmapped, and be prepared to unmap it while under
> the page lock.

But vmtruncate() dropped i_size, so nobody will map this page into
pagetables from then on.

> > I guess truncate of a mmapped area isn't sufficiently common to worry about
> > the inefficiency of this change.
> 
> Yeah, and it should be more efficient for files that aren't mmapped,
> because we don't have to take i_mmap_lock for them.
> 
> > Lots of memory barriers got removed in memory.c, unchangeloggedly.
> 
> Yeah they were all for the lockless truncate_count checks. Now that
> we use the page lock, we don't need barriers.
> 
> > Gratuitous renaming of locals in do_no_page() makes the change hard to
> > review.  Should have been a separate patch.
> > 
> > In fact, the patch would have been heaps clearer if that renaming had been
> > a separate patch.
> 
> Shall I?

If you don't have anything better to do, yes please ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
