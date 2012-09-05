Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id D6EDE6B0069
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 10:36:04 -0400 (EDT)
Date: Wed, 5 Sep 2012 10:36:00 -0400 (EDT)
From: =?ISO-8859-15?Q?Luk=E1=A8_Czerner?= <lczerner@redhat.com>
Subject: Re: [PATCH 01/15 v2] mm: add invalidatepage_range address space
 operation
In-Reply-To: <20120904164316.6e058cbe.akpm@linux-foundation.org>
Message-ID: <alpine.LFD.2.00.1209051002310.509@new-host-2>
References: <1346451711-1931-1-git-send-email-lczerner@redhat.com> <1346451711-1931-2-git-send-email-lczerner@redhat.com> <20120904164316.6e058cbe.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lukas Czerner <lczerner@redhat.com>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, tytso@mit.edu, hughd@google.com, linux-mm@kvack.org

On Tue, 4 Sep 2012, Andrew Morton wrote:

> Date: Tue, 4 Sep 2012 16:43:16 -0700
> From: Andrew Morton <akpm@linux-foundation.org>
> To: Lukas Czerner <lczerner@redhat.com>
> Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, tytso@mit.edu,
>     hughd@google.com, linux-mm@kvack.org
> Subject: Re: [PATCH 01/15 v2] mm: add invalidatepage_range address space
>     operation
> 
> On Fri, 31 Aug 2012 18:21:37 -0400
> Lukas Czerner <lczerner@redhat.com> wrote:
> 
> > Currently there is no way to truncate partial page where the end
> > truncate point is not at the end of the page. This is because it was not
> > needed and the functionality was enough for file system truncate
> > operation to work properly. However more file systems now support punch
> > hole feature and it can benefit from mm supporting truncating page just
> > up to the certain point.
> > 
> > Specifically, with this functionality truncate_inode_pages_range() can
> > be changed so it supports truncating partial page at the end of the
> > range (currently it will BUG_ON() if 'end' is not at the end of the
> > page).
> > 
> > This commit add new address space operation invalidatepage_range which
> > allows specifying length of bytes to invalidate, rather than assuming
> > truncate to the end of the page. It also introduce
> > block_invalidatepage_range() and do_invalidatepage)range() functions for
> > exactly the same reason.
> > 
> > The caller does not have to implement both aops (invalidatepage and
> > invalidatepage_range) and the latter is preferred. The old method will be
> > used only if invalidatepage_range is not implemented by the caller.
> > 
> > ...
> >
> > +/**
> > + * do_invalidatepage_range - invalidate range of the page
> > + *
> > + * @page: the page which is affected
> > + * @offset: start of the range to invalidate
> > + * @length: length of the range to invalidate
> > +  */
> > +void do_invalidatepage_range(struct page *page, unsigned int offset,
> > +			     unsigned int length)
> > +{
> > +	void (*invalidatepage_range)(struct page *, unsigned int,
> > +				     unsigned int);
> >  	void (*invalidatepage)(struct page *, unsigned long);
> > +
> > +	/*
> > +	 * Try invalidatepage_range first
> > +	 */
> > +	invalidatepage_range = page->mapping->a_ops->invalidatepage_range;
> > +	if (invalidatepage_range) {
> > +		(*invalidatepage_range)(page, offset, length);
> > +		return;
> > +	}
> > +
> > +	/*
> > +	 * When only invalidatepage is registered length + offset must be
> > +	 * PAGE_CACHE_SIZE
> > +	 */
> >  	invalidatepage = page->mapping->a_ops->invalidatepage;
> > +	if (invalidatepage) {
> > +		BUG_ON(length + offset != PAGE_CACHE_SIZE);
> > +		(*invalidatepage)(page, offset);
> > +	}
> >  #ifdef CONFIG_BLOCK
> > -	if (!invalidatepage)
> > -		invalidatepage = block_invalidatepage;
> > +	if (!invalidatepage_range && !invalidatepage)
> > +		block_invalidatepage_range(page, offset, length);
> >  #endif
> > -	if (invalidatepage)
> > -		(*invalidatepage)(page, offset);
> >  }
> 
> This interface is ...  strange.  If the caller requests a
> non-page-aligned invalidateion against an fs which doesn't implement
> ->invalidatepage_range then the kernel goes BUG.  So the caller must
> know beforehand that the underlying fs _does_ implement
> ->invalidatepage_range.
> 
> For practical purposes, this implies that invalidation of a
> non-page-aligned region will only be performed by fs code, because the
> fs implicitly knows that it implements ->invalidatepage_range.
> 
> However this function isn't exported to modules, so scratch that.
> 
> So how is calling code supposed to determine whether it can actually
> _use_ this interface?

Right now the only place we use ->invalidatepage_range is
do_invalidatepage_range() which is only used in
truncate_inode_pages_range(). Without these patches
truncate_inode_pages_range() throw a BUG() if it gets unaligned
range, so it is file system responsibility to take case about the
alignment, which is currently happening in all file systems unless
there is a bug (like in ocfs2).

So currently callers of truncate_inode_pages_range() know that the
range has to be aligned and with these patches they should know (it
is documented in the function comment after all) that when they want
to pass unaligned range the underlying file system has to implement
->invalidatepage_range().

Now I agree that the only one who will have this information will be
the file system itself. But both truncate_pagecache_range() and
truncate_inode_pages_range() are used from within the file system as
you pointed out earlier, so it does not look like a real problem to
me. But I have to admit that it is a bit strange.

However if we would want to keep ->invalidatepage_range() and
->invalidatepage() completely separate then we would have to have
separate truncate_inode_pages_range() and truncate_pagecache_range()
as well for the separation to actually matter. And IMO this would be
much worse...

As it is now the caller is forced to implement
->invalidatepage_range() if he wants to invalidate unaligned range
by the use of BUG_ON() in the kind of same way we would force him to
implement it if he would like to use the 'new'
truncate_inode_pages_range(), or truncate_pagecache_range().

I am intentionally not mentioning do_invalidatepage_range() since it
currently does not have other users than truncate_inode_pages_range() where
the range may be unaligned.

Thanks!
-Lukas

> 
> 
> Also...  one would obviously like to see the old ->invalidatepage() get
> removed entirely.  But about 20 filesystems implement
> ->invalidatepage() and implementation of ->invalidatepage_range() is
> non-trivial and actually unnecessary.
> 
> So I dunno.  Perhaps we should keep ->invalidatepage() and
> ->invalidatepage_range() completely separate.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
