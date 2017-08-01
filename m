Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9CA706B0523
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 07:16:39 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id k14so6199516qkl.7
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 04:16:39 -0700 (PDT)
Received: from mail-qt0-f170.google.com (mail-qt0-f170.google.com. [209.85.216.170])
        by mx.google.com with ESMTPS id g11si25424771qtc.112.2017.08.01.04.16.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 04:16:38 -0700 (PDT)
Received: by mail-qt0-f170.google.com with SMTP id a18so6947819qta.0
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 04:16:38 -0700 (PDT)
Message-ID: <1501586197.4702.5.camel@redhat.com>
Subject: Re: [PATCH] mm: remove optimizations based on i_size in mapping
 writeback waits
From: Jeff Layton <jlayton@redhat.com>
Date: Tue, 01 Aug 2017 07:16:37 -0400
In-Reply-To: <20170801090404.GA4215@quack2.suse.cz>
References: <20170731152946.13976-1-jlayton@kernel.org>
	 <20170801090404.GA4215@quack2.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>

On Tue, 2017-08-01 at 11:04 +0200, Jan Kara wrote:
> On Mon 31-07-17 11:29:46, Jeff Layton wrote:
> > From: Jeff Layton <jlayton@redhat.com>
> > 
> > Marcelo added this i_size based optimization with a patch in 2004
> > (commit 765dad09b4ac in the linux-history tree):
> > 
> >     commit 765dad09b4ac101a32d87af2bb793c3060497d3c
> >     Author: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
> >     Date:   Tue Sep 7 17:51:17 2004 -0700
> > 
> > 	small wait_on_page_writeback_range() optimization
> > 
> > 	filemap_fdatawait() calls wait_on_page_writeback_range() with -1
> > 	as "end" parameter.  This is not needed since we know the EOF
> > 	from the inode.  Use that instead.
> > 
> > There may be races here, particularly with clustered or network
> > filesystems. Block devices always have an i_size of 0 as well, which
> > makes using this with a blockdev inode sort of pointless.
> 
> Well, you are not quite right here. You are correct that
> file_inode(file)->i_size is 0, however file->f_mapping->host->i_size is the
> device size and that's what will be used for filemap_fdatawait(). So that
> function works fine for block devices.
> 

Got it. I'll fix up the description, but I won't bother re-posting for
that.

> > It also seems like a bit of a layering violation since we're operating
> > on an address_space here, not an inode.
> > 
> > Finally, it's also questionable whether this optimization really helps
> > on workloads that we care about. Should we be optimizing for writeback
> > vs. truncate races in a codepath where we expect to wait anyway? It
> > doesn't seem worth the risk.
> > 
> > Remove this optimization from the filemap_fdatawait codepaths. This
> > means that filemap_fdatawait becomes a trivial wrapper around
> > filemap_fdatawait_range.
> 
> Agreed for all the other reasons so feel free to add:
> 
> Reviewed-by: Jan Kara <jack@suse.cz>
> 
> 								Honza
> 
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  include/linux/fs.h |  9 +++++++--
> >  mm/filemap.c       | 30 +-----------------------------
> >  2 files changed, 8 insertions(+), 31 deletions(-)
> > 
> > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > index af592ca3d509..656e04c6983e 100644
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -2538,10 +2538,15 @@ extern int invalidate_inode_pages2_range(struct address_space *mapping,
> >  extern int write_inode_now(struct inode *, int);
> >  extern int filemap_fdatawrite(struct address_space *);
> >  extern int filemap_flush(struct address_space *);
> > -extern int filemap_fdatawait(struct address_space *);
> > -extern int filemap_fdatawait_keep_errors(struct address_space *mapping);
> >  extern int filemap_fdatawait_range(struct address_space *, loff_t lstart,
> >  				   loff_t lend);
> > +extern int filemap_fdatawait_keep_errors(struct address_space *mapping);
> > +
> > +static inline int filemap_fdatawait(struct address_space *mapping)
> > +{
> > +	return filemap_fdatawait_range(mapping, 0, LLONG_MAX);
> > +}
> > +
> >  extern bool filemap_range_has_page(struct address_space *, loff_t lstart,
> >  				  loff_t lend);
> >  extern int __must_check file_fdatawait_range(struct file *file, loff_t lstart,
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index 394bb5e96f87..85dfe3bee324 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -512,39 +512,11 @@ EXPORT_SYMBOL(file_fdatawait_range);
> >   */
> >  int filemap_fdatawait_keep_errors(struct address_space *mapping)
> >  {
> > -	loff_t i_size = i_size_read(mapping->host);
> > -
> > -	if (i_size == 0)
> > -		return 0;
> > -
> > -	__filemap_fdatawait_range(mapping, 0, i_size - 1);
> > +	__filemap_fdatawait_range(mapping, 0, LLONG_MAX);
> >  	return filemap_check_and_keep_errors(mapping);
> >  }
> >  EXPORT_SYMBOL(filemap_fdatawait_keep_errors);
> >  
> > -/**
> > - * filemap_fdatawait - wait for all under-writeback pages to complete
> > - * @mapping: address space structure to wait for
> > - *
> > - * Walk the list of under-writeback pages of the given address space
> > - * and wait for all of them.  Check error status of the address space
> > - * and return it.
> > - *
> > - * Since the error status of the address space is cleared by this function,
> > - * callers are responsible for checking the return value and handling and/or
> > - * reporting the error.
> > - */
> > -int filemap_fdatawait(struct address_space *mapping)
> > -{
> > -	loff_t i_size = i_size_read(mapping->host);
> > -
> > -	if (i_size == 0)
> > -		return 0;
> > -
> > -	return filemap_fdatawait_range(mapping, 0, i_size - 1);
> > -}
> > -EXPORT_SYMBOL(filemap_fdatawait);
> > -
> >  static bool mapping_needs_writeback(struct address_space *mapping)
> >  {
> >  	return (!dax_mapping(mapping) && mapping->nrpages) ||
> > -- 
> > 2.13.3
> > 

Thanks!
-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
