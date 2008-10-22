Date: Wed, 22 Oct 2008 15:16:48 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
Message-ID: <20081022131648.GA20625@wotan.suse.de>
References: <20081021112137.GB12329@wotan.suse.de> <E1KsGj7-0005sK-Uq@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1KsGj7-0005sK-Uq@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 21, 2008 at 02:52:45PM +0200, Miklos Szeredi wrote:
> On Tue, 21 Oct 2008, Nick Piggin wrote:
> > IO error handling in the core mm/fs still doesn't seem perfect, but with
> > the recent round of patches and this one, it should be getting on the
> > right track.
> > 
> > I kind of get the feeling some people would rather forget about all this
> > and brush it under the carpet. Hopefully I'm mistaken, but if anybody
> > disagrees with my assertion that error handling, and data integrity
> > semantics are first-class correctness issues, and therefore are more
> > important than all other non-correctness problems... speak now and let's
> > discuss that, please.
> 
> I agree that error handling is important.  But careful: some
> filesystems (NFS I know) don't set PG_error on async read errors, and
> changing the semantics of ->readpage() from returning EIO to retrying
> will potentially cause infinite loops.  And no casual testing will

OK, they'll just need to be fixed.


> reveal those because peristent read errors are extremely rare.

Same as other read errors I guess. We need to be doing more testing
of error cases. I've been doing it a little bit recently for a couple
of block based filesystems... but the hardest code I think is actually
ensuring each filesystem actually does sane things.
  

> So I think a better aproach would be to do
> 
> 			error = lock_page_killable(page);
> 			if (unlikely(error))
> 				goto readpage_error;
> 			if (PageError(page) || !PageUptodate(page)) {
> 				unlock_page(page);
> 				shrink_readahead_size_eio(filp, ra);
> 				error = -EIO;
> 				goto readpage_error;
> 			}
> 			if (!page->mapping) {
> 				unlock_page(page);
> 				page_cache_release(page);
> 				goto find_page;
> 			}
> 
> etc...
> 
> Is there a case where retrying in case of !PageUptodate() makes any
> sense?

Invalidate I guess is covered now (I don't exactly like the solution,
but it's what we have for now). Truncate hmm, I thought that still
clears PageUptodate, but it doesn't seem to either?

Maybe we can use !PageUptodate, with care, for read errors. It might 
actually be a bit preferable in the sense that PageError can just be
used for write errors only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
