Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id A52206B0082
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 17:28:19 -0500 (EST)
Date: Fri, 15 Feb 2013 17:28:03 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/2] mm: fincore()
Message-ID: <20130215222803.GA23930@cmpxchg.org>
References: <87a9rbh7b4.fsf@rustcorp.com.au>
 <20130211162701.GB13218@cmpxchg.org>
 <20130211141239.f4decf03.akpm@linux-foundation.org>
 <20130215063450.GA24047@cmpxchg.org>
 <20130215131451.138e83ce.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130215131451.138e83ce.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Stewart Smith <stewart@flamingspork.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org

On Fri, Feb 15, 2013 at 01:14:51PM -0800, Andrew Morton wrote:
> On Fri, 15 Feb 2013 01:34:50 -0500
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > On Mon, Feb 11, 2013 at 02:12:39PM -0800, Andrew Morton wrote:
> > > Also, having to mmap the file to be able to query pagecache state is a
> > > hack.  Whatever happened to the fincore() patch?
> > 
> > I don't know, but how about this one:
> 
> This appears to be remotely derived from Chris's original
> (http://lwn.net/Articles/371540/).  The comments, at least ;) Some
> mention in the changelog would be appropriate.

It's actually copy-pasted from mm/mincore.c, but we both had the same
idea of sorting the error codes by numeric value.  Funny.  I'll
mention him.

> > Provide a syscall to determine whether a given file's pages are cached
> > in memory.  This is more elegant than mmapping the file for the sole
> > purpose of using mincore(), and also works on NOMMU.
> > 
> 
> Obviously we'll be needing more than this at the appropriate time so
> Michael can write the manpage.
> 
> Please provide a nice tools/testing/selftests/fincore/ along with this
> code?

Will do.

> > --- /dev/null
> > +++ b/mm/fincore.c
> > @@ -0,0 +1,128 @@
> > +#include <linux/syscalls.h>
> > +#include <linux/pagemap.h>
> > +#include <linux/file.h>
> > +#include <linux/fs.h>
> > +#include <linux/mm.h>
> > +
> > +static long do_fincore(struct address_space *mapping, pgoff_t pgstart,
> > +		       unsigned long nr_pages, unsigned char *vec)
> > +{
> > +	pgoff_t pgend = pgstart + nr_pages;
> > +	struct radix_tree_iter iter;
> > +	void **slot;
> > +	long nr = 0;
> > +
> > +	rcu_read_lock();
> > +restart:
> > +	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, pgstart) {
> > +		unsigned char present;
> > +		struct page *page;
> > +
> > +		/* Handle holes */
> > +		if (iter.index != pgstart + nr) {
> > +			if (iter.index < pgend)
> > +				nr_pages = iter.index - pgstart;
> > +			break;
> 
> This break looks odd - it terminates the entire function.  Am too lazy
> to work out why ;)

"Hole" and "no more pages in that file" share the same code to zero
out the vector.

> > +		}
> > +repeat:
> > +		page = radix_tree_deref_slot(slot);
> > +		if (unlikely(!page))
> > +			continue;
> 
> Is a bug, isn't it?  Need to zero vec[nr].

It works but I'll make it less awkward.  The continue will not
increase nr, so the next page lookup will trigger the hole detection
above and zero vec[nr].

> > +		if (radix_tree_exception(page)) {
> > +			if (radix_tree_deref_retry(page)) {
> > +				/*
> > +				 * Transient condition which can only trigger
> > +				 * when entry at index 0 moves out of or back
> > +				 * to root: none yet gotten, safe to restart.
> > +				 */
> > +				WARN_ON(iter.index);
> > +				goto restart;
> > +			}
> > +			present = 0;
> > +		} else {
> > +			if (!page_cache_get_speculative(page))
> > +				goto repeat;
> > +
> > +			/* Has the page moved? */
> > +			if (unlikely(page != *slot)) {
> > +				page_cache_release(page);
> > +				goto repeat;
> > +			}
> > +
> > +			present = PageUptodate(page);
> 
> hm, OK, so we assume that test_bit() returns 1 or 0 and not just
> "true".  That's OK, iirc.

Metoo.

> Why does it have to be uptodate?  It could be present and under read()
> IO.  That's "in core"?

I always thought of this as data-residency, i.e. the presence of
pages, not page frames, so I wouldn't consider pages in-core when they
are still in-flight.  mincore has the same notion.

> > +			page_cache_release(page);
> > +		}
> > +		vec[nr] = present;
> > +
> > +		if (++nr == nr_pages)
> > +			break;
> > +	}
> > +	rcu_read_unlock();
> > +
> > +	if (nr < nr_pages)
> > +		memset(vec + nr, 0, nr_pages - nr);
> > +
> > +	return nr_pages;
> > +}
> > +
> > +/*
> > + * The fincore(2) system call.
> > + *
> > + * fincore() returns the memory residency status of the given file's
> > + * pages, in the range [start, start + len].
> > + * The status is returned in a vector of bytes.  The least significant
> > + * bit of each byte is 1 if the referenced page is in memory, otherwise
> > + * it is zero.
> 
> Yes, and there will be immediate calmour to add more goodies to the
> other seven bits.  PageDirty, referenced state, etc.  We should think
> about this now, at the design stage rather than grafting things on
> later.

I'm interested in your "etc.".  PG_error, PG_active, PG_writeback,
page huge?

> > + * Because the status of a page can change after fincore() checks it
> > + * but before it returns to the application, the returned vector may
> > + * contain stale information.
> > + *
> > + * return values:
> > + *  zero    - success
> > + *  -EBADF  - fd isn't a valid open file descriptor
> > + *  -EFAULT - vec points to an illegal address
> > + *  -EINVAL - start is not a multiple of PAGE_CACHE_SIZE
> > + */
> > +SYSCALL_DEFINE4(fincore, unsigned int, fd, loff_t, start, loff_t, len,
> > +		unsigned char __user *, vec)
> > +{
> > +	unsigned long nr_pages;
> > +	pgoff_t pgstart;
> > +	struct fd f;
> > +	long ret;
> > +
> > +	if (start & ~PAGE_CACHE_MASK)
> > +		return -EINVAL;
> 
> This restriction appears to be unnecessary?

I thought about it too, but whether the kernel rounds or not, you need
to know the page size and do the rounding in userspace in order to
supply an appropriately sized vector.  And then I just copied mincore
semantics for consistency ;-)

> > +	f = fdget(fd);
> > +	if (!f.file)
> > +		return -EBADF;
> 
> I fear what happens if we run this syscall against a random fd from
> /dev/some-gizmo.  Suggest adding tests for S_ISREG and non-null ->mapping.

Good idea, I'll add this.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
