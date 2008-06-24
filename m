In-reply-to: <20080624080440.GJ20851@kernel.dk> (message from Jens Axboe on
	Tue, 24 Jun 2008 10:04:41 +0200)
Subject: Re: [rfc patch 3/4] splice: remove confirm from pipe_buf_operations
References: <20080621154607.154640724@szeredi.hu> <20080621154726.494538562@szeredi.hu> <20080624080440.GJ20851@kernel.dk>
Message-Id: <E1KB4Id-0000un-PV@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 24 Jun 2008 10:54:51 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jens.axboe@oracle.com
Cc: miklos@szeredi.hu, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> > The 'confirm' operation was only used for splicing from page cache, to
> > wait for read on a page to finish.  But generic_file_splice_read()
> > already blocks on readahead reads, so it seems logical to block on the
> > rare and slow single page reads too.
> > 
> > So wait for readpage to finish inside __generic_file_splice_read() and
> > remove the 'confirm' method.
> > 
> > This also fixes short return counts when the filesystem (e.g. fuse)
> > invalidates the page between insertation and removal.
> 
> One of the basic goals of splice is to allow the pipe buffer to only be
> consisten when a consumer asks for it, otherwise the filling will always
> be sync. There should be no blocking on reads in the splice-in path,
> only on consumption for splice-out.

What you are ignoring (and I've mentioned in the changelog) is that it
is *already* sync.  Look at the code: this starts I/O:

		page_cache_sync_readahead(mapping, &in->f_ra, in,
				index, req_pages - spd.nr_pages);

And this waits for it to finish:

		if (!PageUptodate(page)) {
			...
				lock_page(page);

The only way it will be async, is if there's no readahead.  But do we
want to optmize that case?

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
