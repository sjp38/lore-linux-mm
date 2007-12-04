Date: Tue, 4 Dec 2007 16:59:06 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [patch 01/19] Define functions for page cache handling
Message-ID: <20071204055905.GW115527101@sgi.com>
References: <20071130173448.951783014@sgi.com> <20071130173506.366983341@sgi.com> <20071203141020.c8119197.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071203141020.c8119197.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hch@lst.de, mel@skynet.ie, wli@holomorphy.com, dgc@sgi.com, jens.axboe@oracle.com, pbadari@gmail.com, maximlevitsky@gmail.com, fengguang.wu@gmail.com, wangswin@gmail.com, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

On Mon, Dec 03, 2007 at 02:10:20PM -0800, Andrew Morton wrote:
> On Fri, 30 Nov 2007 09:34:49 -0800
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > We use the macros PAGE_CACHE_SIZE PAGE_CACHE_SHIFT PAGE_CACHE_MASK
> > and PAGE_CACHE_ALIGN in various places in the kernel. Many times
> > common operations like calculating the offset or the index are coded
> > using shifts and adds. This patch provides inline functions to
> > get the calculations accomplished without having to explicitly
> > shift and add constants.
> > 
> > All functions take an address_space pointer. The address space pointer
> > will be used in the future to eventually support a variable size
> > page cache. Information reachable via the mapping may then determine
> > page size.
> > 
> > New function                    Related base page constant
> > ====================================================================
> > page_cache_shift(a)             PAGE_CACHE_SHIFT
> > page_cache_size(a)              PAGE_CACHE_SIZE
> > page_cache_mask(a)              PAGE_CACHE_MASK
> > page_cache_index(a, pos)        Calculate page number from position
> > page_cache_next(addr, pos)      Page number of next page
> > page_cache_offset(a, pos)       Calculate offset into a page
> > page_cache_pos(a, index, offset)
> >                                 Form position based on page number
> >                                 and an offset.
> > 
> > This provides a basis that would allow the conversion of all page cache
> > handling in the kernel and ultimately allow the removal of the PAGE_CACHE_*
> > constants.
> > 
> > ...
> >
> > +/*
> > + * Functions that are currently setup for a fixed PAGE_SIZEd. The use of
> > + * these will allow the user of largere page sizes in the future.
> > + */
> > +static inline int mapping_order(struct address_space *a)
> > +{
> > +	return 0;
> > +}
> > +
> > +static inline int page_cache_shift(struct address_space *a)
> > +{
> > +	return PAGE_SHIFT;
> > +}
> > +
> > +static inline unsigned int page_cache_size(struct address_space *a)
> > +{
> > +	return PAGE_SIZE;
> > +}
> > +
> > +static inline unsigned int page_cache_offset(struct address_space *a,
> > +		loff_t pos)
> > +{
> > +	return pos & ~PAGE_MASK;
> > +}
> > +
> > +static inline pgoff_t page_cache_index(struct address_space *a,
> > +		loff_t pos)
> > +{
> > +	return pos >> page_cache_shift(a);
> > +}
> 
> These will of course all work OK as they are presently implemented.
> 
> But you have callsites doing things like
> 
> 	page_cache_size(page_mapping(page));
> 
> which is a whole different thing.  Once page_cache_size() is changed to
> look inside the address_space we need to handle races against truncation
> and we need to handle the address_space getting reclaimed, etc.
> 
> So I think it would be misleading to merge these changes at present - they
> make it _look_ like we can have variable PAGE_CACHE_SIZE just by tweaking a
> bit of core code, but we in fact cannot do that without a careful review of
> all callsites and perhaps the addition of new locking and null-checking.
> 
> Now, one possible way around this is to rework all these functions so they
> take only a page*, and to create (and assert) the requirement that the caller
> has locked the page.  That's a little bit inefficient (additional calls to
> page_mapping()) but it does mean that we can now confidently change the
> implementation of these functions as you intend.

Hmmmm. Many of the places where these functions are called will have
the page locked and the mapping protected against truncate.

A quick pass through the patches indicates the changes to rmap.c,
migrate.c, alloc_page_buffers(), and drivers/block/rd.c seem to be
the only ones that are suspect. Almost everywhere else we either
use the inode->i_mapping or the page comes in locked (i.e. would
crash on struct inode * inode = page->mapping->host; at function entry
otherwise).

It seems the exposure here is not that great. I'm ambivalent, though; I
don'tmind what interface there is just so long as it cleans up this mess ;)

> And a coding nit: when you implement the out-of-line versions of these
> functions you're going to stick with VFS conventions and use the identifier
> `mapping' to identify the address_space*.  So I think it would be better to
> also call in `mapping' in these inlined stubbed functions, rather than `a'.
> No?

Definitely an improvement.

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
