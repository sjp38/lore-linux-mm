Date: Wed, 7 Mar 2007 07:57:27 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 3/6] mm: fix fault vs invalidate race for linear mappings
Message-ID: <20070307065727.GA15877@wotan.suse.de>
References: <20070221023656.6306.246.sendpatchset@linux.site> <20070221023724.6306.53097.sendpatchset@linux.site> <20070306223641.505db0e0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070306223641.505db0e0.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 06, 2007 at 10:36:41PM -0800, Andrew Morton wrote:
> On Wed, 21 Feb 2007 05:50:05 +0100 (CET) Nick Piggin <npiggin@suse.de> wrote:
> 
> > Fix the race between invalidate_inode_pages and do_no_page.
> > 
> > Andrea Arcangeli identified a subtle race between invalidation of
> > pages from pagecache with userspace mappings, and do_no_page.
> > 
> > The issue is that invalidation has to shoot down all mappings to the
> > page, before it can be discarded from the pagecache. Between shooting
> > down ptes to a particular page, and actually dropping the struct page
> > from the pagecache, do_no_page from any process might fault on that
> > page and establish a new mapping to the page just before it gets
> > discarded from the pagecache.
> > 
> > The most common case where such invalidation is used is in file
> > truncation. This case was catered for by doing a sort of open-coded
> > seqlock between the file's i_size, and its truncate_count.
> > 
> > Truncation will decrease i_size, then increment truncate_count before
> > unmapping userspace pages; do_no_page will read truncate_count, then
> > find the page if it is within i_size, and then check truncate_count
> > under the page table lock and back out and retry if it had
> > subsequently been changed (ptl will serialise against unmapping, and
> > ensure a potentially updated truncate_count is actually visible).
> > 
> > Complexity and documentation issues aside, the locking protocol fails
> > in the case where we would like to invalidate pagecache inside i_size.
> > do_no_page can come in anytime and filemap_nopage is not aware of the
> > invalidation in progress (as it is when it is outside i_size). The
> > end result is that dangling (->mapping == NULL) pages that appear to
> > be from a particular file may be mapped into userspace with nonsense
> > data. Valid mappings to the same place will see a different page.
> > 
> > Andrea implemented two working fixes, one using a real seqlock,
> > another using a page->flags bit. He also proposed using the page lock
> > in do_no_page, but that was initially considered too heavyweight.
> > However, it is not a global or per-file lock, and the page cacheline
> > is modified in do_no_page to increment _count and _mapcount anyway, so
> > a further modification should not be a large performance hit.
> > Scalability is not an issue.
> > 
> > This patch implements this latter approach. ->nopage implementations
> > return with the page locked if it is possible for their underlying
> > file to be invalidated (in that case, they must set a special vm_flags
> > bit to indicate so). do_no_page only unlocks the page after setting
> > up the mapping completely. invalidation is excluded because it holds
> > the page lock during invalidation of each page (and ensures that the
> > page is not mapped while holding the lock).
> > 
> > This also allows significant simplifications in do_no_page, because
> > we have the page locked in the right place in the pagecache from the
> > start.
> > 
> 
> Why was truncate_inode_pages_range() altered to unmap the page if it got
> mapped again?
> 
> Oh.  Because the unmap_mapping_range() call got removed from vmtruncate(). 
> Why?  (Please send suitable updates to the changelog).

We have to ensure it is unmapped, and be prepared to unmap it while under
the page lock.

> I guess truncate of a mmapped area isn't sufficiently common to worry about
> the inefficiency of this change.

Yeah, and it should be more efficient for files that aren't mmapped,
because we don't have to take i_mmap_lock for them.

> Lots of memory barriers got removed in memory.c, unchangeloggedly.

Yeah they were all for the lockless truncate_count checks. Now that
we use the page lock, we don't need barriers.

> Gratuitous renaming of locals in do_no_page() makes the change hard to
> review.  Should have been a separate patch.
> 
> In fact, the patch would have been heaps clearer if that renaming had been
> a separate patch.

Shall I?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
