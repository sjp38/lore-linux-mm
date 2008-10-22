Date: Wed, 22 Oct 2008 15:23:16 -0700
From: Mark Fasheh <mfasheh@suse.com>
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
Message-ID: <20081022222316.GI15154@wotan.suse.de>
Reply-To: Mark Fasheh <mfasheh@suse.com>
References: <20081021112137.GB12329@wotan.suse.de> <E1KsGj7-0005sK-Uq@pomaz-ex.szeredi.hu> <20081021125915.GA26697@fogou.chygwyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081021125915.GA26697@fogou.chygwyn.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: steve@chygwyn.com
Cc: Miklos Szeredi <miklos@szeredi.hu>, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 21, 2008 at 01:59:15PM +0100, steve@chygwyn.com wrote:
> Hi,
> 
> On Tue, Oct 21, 2008 at 02:52:45PM +0200, Miklos Szeredi wrote:
> > On Tue, 21 Oct 2008, Nick Piggin wrote:
> > > IO error handling in the core mm/fs still doesn't seem perfect, but with
> > > the recent round of patches and this one, it should be getting on the
> > > right track.
> > > 
> > > I kind of get the feeling some people would rather forget about all this
> > > and brush it under the carpet. Hopefully I'm mistaken, but if anybody
> > > disagrees with my assertion that error handling, and data integrity
> > > semantics are first-class correctness issues, and therefore are more
> > > important than all other non-correctness problems... speak now and let's
> > > discuss that, please.
> > 
> > I agree that error handling is important.  But careful: some
> > filesystems (NFS I know) don't set PG_error on async read errors, and
> > changing the semantics of ->readpage() from returning EIO to retrying
> > will potentially cause infinite loops.  And no casual testing will
> > reveal those because peristent read errors are extremely rare.
> > 
> > So I think a better aproach would be to do
> > 
> > 			error = lock_page_killable(page);
> > 			if (unlikely(error))
> > 				goto readpage_error;
> > 			if (PageError(page) || !PageUptodate(page)) {
> > 				unlock_page(page);
> > 				shrink_readahead_size_eio(filp, ra);
> > 				error = -EIO;
> > 				goto readpage_error;
> > 			}
> > 			if (!page->mapping) {
> > 				unlock_page(page);
> > 				page_cache_release(page);
> > 				goto find_page;
> > 			}
> > 
> > etc...
> > 
> > Is there a case where retrying in case of !PageUptodate() makes any
> > sense?
> >
> Yes... cluster filesystems. Its very important in case a readpage
> races with a lock demotion. Since the introduction of page_mkwrite
> that hasn't worked quite right, but by retrying when the page is
> not uptodate, that should fix the problem,

Btw, at least for the readpage case, a return of AOP_TRUNCATED_PAGE should
be checked for, which would indicate (along with !PageUptodate()) whether we
need to retry the read. page_mkwrite though, as you point out, is a
different story.
	--Mark

--
Mark Fasheh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
