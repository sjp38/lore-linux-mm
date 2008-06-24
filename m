In-reply-to: <200806242216.41548.nickpiggin@yahoo.com.au> (message from Nick
	Piggin on Tue, 24 Jun 2008 22:16:41 +1000)
Subject: Re: [rfc patch 3/4] splice: remove confirm from pipe_buf_operations
References: <20080621154607.154640724@szeredi.hu> <20080624111913.GP20851@kernel.dk> <E1KB6p9-0001Gq-Fd@pomaz-ex.szeredi.hu> <200806242216.41548.nickpiggin@yahoo.com.au>
Message-Id: <E1KB88B-0001Ts-Ht@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 24 Jun 2008 15:00:19 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nickpiggin@yahoo.com.au
Cc: miklos@szeredi.hu, jens.axboe@oracle.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> > > It's an unfortunate side effect of the read-ahead, I'd much rather just
> > > get rid of that. It _should_ behave like the non-ra case, when a page is
> > > added it merely has IO started on it. So we want to have that be
> > > something like
> > >
> > >         if (!PageUptodate(page) && !PageInFlight(page))
> > >                 ...
> > >
> > > basically like PageWriteback(), but for read-in.
> >
> > OK it could be done, possibly at great pain.  But why is it important?
> 
> It has been considered, but adding atomic operations on these paths
> always really hurts. Adding something like this would basically be
> another at least 2 atomic operations that can never be removed again...
> 
> Provided that you've done the sync readahead earlier, it presumably
> should be a very rare case to have to start new IO in the loop
> below, right? In which case, I wonder if we couldn't move that 2nd
> loop out of generic_file_splice_read and into
> page_cache_pipe_buf_confirm. 

The problem with that second loop (which started this thing) is that
if a page is invalidated by the filesystem, then it doesn't redo the
lookup/read like the plain cached read does.

And that can't be done in page_cache_pipe_buf_confirm() at all.

> > What's the use case where it matters that splice-in should not block
> > on the read?
> 
> It just makes it generally less able to pipeline IO and computation,
> doesn't it?

Maybe.  I don't really see how splice might be used that would be
helped by this.  Do you have a concrete example?

In fact I don't really know at all what splice is being used for
(other than the in kernel uses: nfsd, sendfile).  

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
