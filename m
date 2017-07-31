Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8FDEB6B05E7
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 08:07:47 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i187so20944928wma.15
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 05:07:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y23si19536940wra.384.2017.07.31.05.07.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 31 Jul 2017 05:07:46 -0700 (PDT)
Date: Mon, 31 Jul 2017 14:07:44 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 2/4] mm: add file_fdatawait_range and
 file_write_and_wait
Message-ID: <20170731120744.GA25458@quack2.suse.cz>
References: <20170726175538.13885-1-jlayton@kernel.org>
 <20170726175538.13885-3-jlayton@kernel.org>
 <20170727084914.GC21100@quack2.suse.cz>
 <1501159710.6279.1.camel@redhat.com>
 <1501500421.4663.4.camel@redhat.com>
 <8d46c4c6-76b5-9726-7d85-249cd9a899f1@redhat.com>
 <1501501456.4663.6.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1501501456.4663.6.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Steven Whitehouse <swhiteho@redhat.com>, Jan Kara <jack@suse.cz>, Marcelo Tosatti <mtosatti@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, "J . Bruce Fields" <bfields@fieldses.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Mon 31-07-17 07:44:16, Jeff Layton wrote:
> On Mon, 2017-07-31 at 12:32 +0100, Steven Whitehouse wrote:
> > On 31/07/17 12:27, Jeff Layton wrote:
> > > On Thu, 2017-07-27 at 08:48 -0400, Jeff Layton wrote:
> > > > On Thu, 2017-07-27 at 10:49 +0200, Jan Kara wrote:
> > > > > On Wed 26-07-17 13:55:36, Jeff Layton wrote:
> > > > > > +int file_write_and_wait(struct file *file)
> > > > > > +{
> > > > > > +	int err = 0, err2;
> > > > > > +	struct address_space *mapping = file->f_mapping;
> > > > > > +
> > > > > > +	if ((!dax_mapping(mapping) && mapping->nrpages) ||
> > > > > > +	    (dax_mapping(mapping) && mapping->nrexceptional)) {
> > > > > > +		err = filemap_fdatawrite(mapping);
> > > > > > +		/* See comment of filemap_write_and_wait() */
> > > > > > +		if (err != -EIO) {
> > > > > > +			loff_t i_size = i_size_read(mapping->host);
> > > > > > +
> > > > > > +			if (i_size != 0)
> > > > > > +				__filemap_fdatawait_range(mapping, 0,
> > > > > > +							  i_size - 1);
> > > > > > +		}
> > > > > > +	}
> > > > > 
> > > > > Err, what's the i_size check doing here? I'd just pass ~0 as the end of the
> > > > > range and ignore i_size. It is much easier than trying to wrap your head
> > > > > around possible races with file operations modifying i_size.
> > > > > 
> > > > > 								Honza
> > > > 
> > > > I'm basically emulating _exactly_ what filemap_write_and_wait does here,
> > > > as I'm leery of making subtle behavior changes in the actual writeback
> > > > behavior. For example:
> > > > 
> > > > -----------------8<----------------
> > > > static inline int __filemap_fdatawrite(struct address_space *mapping,
> > > >          int sync_mode)
> > > > {
> > > >          return __filemap_fdatawrite_range(mapping, 0, LLONG_MAX, sync_mode);
> > > > }
> > > > 
> > > > int filemap_fdatawrite(struct address_space *mapping)
> > > > {
> > > >          return __filemap_fdatawrite(mapping, WB_SYNC_ALL);
> > > > }
> > > > EXPORT_SYMBOL(filemap_fdatawrite);
> > > > -----------------8<----------------
> > > > 
> > > > ...which then sets up the wbc with the right ranges and sync mode and
> > > > kicks off writepages. But then, it does the i_size_read to figure out
> > > > what range it should wait on (with the shortcut for the size == 0 case).
> > > > 
> > > > My assumption was that it was intentionally designed that way, but I'm
> > > > guessing from your comments that it wasn't? If so, then we can turn
> > > > file_write_and_wait a static inline wrapper around
> > > > file_write_and_wait_range.
> > > 
> > > FWIW, I did a bit of archaeology in the linux-history tree and found
> > > this patch from Marcelo in 2004. Is this optimization still helpful? If
> > > not, then that does simplify the code a bit.
> > > 
> > > -------------------8<--------------------
> > > 
> > > [PATCH] small wait_on_page_writeback_range() optimization
> > > 
> > > filemap_fdatawait() calls wait_on_page_writeback_range() with -1 as "end"
> > > parameter.  This is not needed since we know the EOF from the inode.  Use
> > > that instead.
> > > 
> > > Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
> > > Signed-off-by: Andrew Morton <akpm@osdl.org>
> > > Signed-off-by: Linus Torvalds <torvalds@osdl.org>
> > > ---
> > >   mm/filemap.c | 8 +++++++-
> > >   1 file changed, 7 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/mm/filemap.c b/mm/filemap.c
> > > index 78e18b7639b6..55fb7b4141e4 100644
> > > --- a/mm/filemap.c
> > > +++ b/mm/filemap.c
> > > @@ -287,7 +287,13 @@ EXPORT_SYMBOL(sync_page_range);
> > >    */
> > >   int filemap_fdatawait(struct address_space *mapping)
> > >   {
> > > -	return wait_on_page_writeback_range(mapping, 0, -1);
> > > +	loff_t i_size = i_size_read(mapping->host);
> > > +
> > > +	if (i_size == 0)
> > > +		return 0;
> > > +
> > > +	return wait_on_page_writeback_range(mapping, 0,
> > > +				(i_size - 1) >> PAGE_CACHE_SHIFT);
> > >   }
> > >   EXPORT_SYMBOL(filemap_fdatawait);
> > > 
> > 
> > Does this ever get called in cases where we would not hold fs locks? In 
> > that case we definitely don't want to be relying on i_size,
> > 
> > Steve.
> > 
> 
> Yes. We can initiate and wait on writeback from any context where you
> can sleep, really.
> 
> We're just waiting on whole file writeback here, so I don't think
> there's anything wrong. As long as the i_size was valid at some point in
> time prior to waiting then you're ok.
> 
> The question I have is more whether this optimization is still useful. 
> 
> What we do now is just walk the radix tree and wait_on_page_writeback
> for each page. Do we gain anything by avoiding ranges beyond the current
> EOF with the pagecache infrastructure of 2017?

FWIW I'm not aware of any significant benefit of using i_size in
filemap_fdatawait() - we iterate to the end of the radix tree node anyway
since pagevec_lookup_tag() does not support range searches anyway (I'm
working on fixing that however even after that the benefit would be still
rather marginal).

What Marcello might have meant even back in 2004 was that if we are in the
middle of truncate, i_size is already reduced but page cache not truncated
yet, then filemap_fdatawait() does not have to wait for writeback of
truncated pages. That might be a noticeable benefit even today if such race
happens however I'm not sure it's worth optimizing for and surprises
arising from randomly snapshotting i_size (which especially for clustered
filesystems may be out of date) IMHO overweight the possible advantage.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
