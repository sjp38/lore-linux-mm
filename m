In-reply-to: <20081021112137.GB12329@wotan.suse.de> (message from Nick Piggin
	on Tue, 21 Oct 2008 13:21:37 +0200)
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
References: <20081021112137.GB12329@wotan.suse.de>
Message-Id: <E1KsGj7-0005sK-Uq@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 21 Oct 2008 14:52:45 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 Oct 2008, Nick Piggin wrote:
> IO error handling in the core mm/fs still doesn't seem perfect, but with
> the recent round of patches and this one, it should be getting on the
> right track.
> 
> I kind of get the feeling some people would rather forget about all this
> and brush it under the carpet. Hopefully I'm mistaken, but if anybody
> disagrees with my assertion that error handling, and data integrity
> semantics are first-class correctness issues, and therefore are more
> important than all other non-correctness problems... speak now and let's
> discuss that, please.

I agree that error handling is important.  But careful: some
filesystems (NFS I know) don't set PG_error on async read errors, and
changing the semantics of ->readpage() from returning EIO to retrying
will potentially cause infinite loops.  And no casual testing will
reveal those because peristent read errors are extremely rare.

So I think a better aproach would be to do

			error = lock_page_killable(page);
			if (unlikely(error))
				goto readpage_error;
			if (PageError(page) || !PageUptodate(page)) {
				unlock_page(page);
				shrink_readahead_size_eio(filp, ra);
				error = -EIO;
				goto readpage_error;
			}
			if (!page->mapping) {
				unlock_page(page);
				page_cache_release(page);
				goto find_page;
			}

etc...

Is there a case where retrying in case of !PageUptodate() makes any
sense?

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
