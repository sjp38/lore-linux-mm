Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7E6826B0791
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 10:19:12 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id s123-v6so11412239qkf.12
        for <linux-mm@kvack.org>; Sat, 10 Nov 2018 07:19:12 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t7si8020782qtd.217.2018.11.10.07.19.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Nov 2018 07:19:11 -0800 (PST)
Date: Sat, 10 Nov 2018 10:19:07 -0500
From: Brian Foster <bfoster@redhat.com>
Subject: Re: [PATCH] mm: don't break integrity writeback on ->writepage()
 error
Message-ID: <20181110151907.GA10691@bfoster>
References: <20181105163613.7542-1-bfoster@redhat.com>
 <20181109154251.d35772bb1cdc314a70aa90a1@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181109154251.d35772bb1cdc314a70aa90a1@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, Dave Chinner <david@fromorbit.com>

On Fri, Nov 09, 2018 at 03:42:51PM -0800, Andrew Morton wrote:
> On Mon,  5 Nov 2018 11:36:13 -0500 Brian Foster <bfoster@redhat.com> wrote:
> 
> > write_cache_pages() currently breaks out of the writepage loop in
> > the event of a ->writepage() error. This causes problems for
> > integrity writeback on XFS
> 
> For the uninitiated, please define the term "integrity writeback". 
> Quite carefully ;) I'm not sure what it actually means.  grepping
> fs/xfs for "integrity" doesn't reveal anything.
> 
> <reads the code>
> 
> OK, it appears the term means "to sync data to disk" as opposed to
> "periodic dirty memory cleaning".  I guess we don't have particularly
> well-established terms for the two concepts.
> 

Indeed. The intent is basically to describe any writeback that is
intended to persist data and so so before returning (i.e., fsync(),
etc.). That was the best term I came across to describe it ("integrity
sync" is used in some of the existing comments), but I can try to be
more descriptive in the commit log.

> > in the event of a persistent error as XFS
> > expects to process every dirty+delalloc page such that it can
> > discard delalloc blocks when real block allocation fails.  Failure
> > to handle all delalloc pages leaves the filesystem in an
> > inconsistent state if the integrity writeback happens to be due to
> > an unmount, for example.
> > 
> > Update write_cache_pages() to continue processing pages for
> > integrity writeback regardless of ->writepage() errors. Save the
> > first encountered error and return it once complete. This
> > facilitates XFS or any other fs that expects integrity writeback to
> > process the entire set of dirty pages regardless of errors.
> > Background writeback continues to exit on the first error
> > encountered.
> > 
> > ...
> >
> > --- a/mm/page-writeback.c
> > +++ b/mm/page-writeback.c
> > @@ -2156,6 +2156,7 @@ int write_cache_pages(struct address_space *mapping,
> >  {
> >  	int ret = 0;
> >  	int done = 0;
> > +	int error;
> >  	struct pagevec pvec;
> >  	int nr_pages;
> >  	pgoff_t uninitialized_var(writeback_index);
> > @@ -2236,25 +2237,29 @@ int write_cache_pages(struct address_space *mapping,
> >  				goto continue_unlock;
> >  
> >  			trace_wbc_writepage(wbc, inode_to_bdi(mapping->host));
> > -			ret = (*writepage)(page, wbc, data);
> > -			if (unlikely(ret)) {
> > -				if (ret == AOP_WRITEPAGE_ACTIVATE) {
> > +			error = (*writepage)(page, wbc, data);
> > +			if (unlikely(error)) {
> > +				if (error == AOP_WRITEPAGE_ACTIVATE) {
> >  					unlock_page(page);
> > -					ret = 0;
> > -				} else {
> > +					error = 0;
> > +				} else if (wbc->sync_mode != WB_SYNC_ALL &&
> > +					   !wbc->for_sync) {
> 
> And here we're determining that it is not a sync-data-to-disk
> operation, hence it must be a clean-dirty-pages operation.
> 
> This isn't very well-controlled, is it?  It's an inference which was
> put together by examining current callers, I assume?
> 

Yeah, sort of. Some of the comments do already explain how WB_SYNC_ALL
refers to "integrity" writeback/sync (above write_cache_pages(), for
example). The ->for_sync thing is more of an inference based on its use
in __writeback_single_inode() and the comment where it is defined.

> It would be good if we could force callers to be explicit about their
> intent here.  But I'm not sure that adding a new writeback_sync_mode is
> the way to do this.
> 

The more I look at it, however, I think I could probably drop the
for_sync bit here. It appears only be used for a special case of
WB_SYNC_ALL that isn't relevant to this patch, so it only serves to
complicate in this context.

I'm not sure if you had more in mind beyond that..? There are a lot of
knobs on the wbc in general. It might be interesting to see if some of
that could be cleaned up to factor out some of those seemingly bolt-on
knobs, but I'd have to stare at the code more and think about it. Even
still, any such change is probably better as a follow on patch to this
one, which is intended to be an isolated bug fix. Thoughts on any of
that is appreciated.

> At a minimum it would be good to have careful comments in here
> explaining what is going on, justifying the above inference, explaining
> the xfs requirement (hopefully in a way which isn't xfs-specific).
> 

Ok, I can add a comment here that covers such details. Thanks for the
feedback.

Brian

> >  					/*
> > -					 * done_index is set past this page,
> > -					 * so media errors will not choke
> > +					 * done_index is set past this page, so
> > +					 * media errors will not choke
> >  					 * background writeout for the entire
> >  					 * file. This has consequences for
> >  					 * range_cyclic semantics (ie. it may
> >  					 * not be suitable for data integrity
> >  					 * writeout).
> >  					 */
> 
