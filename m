Date: Thu, 23 Oct 2008 10:59:49 +0100
From: steve@chygwyn.com
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
Message-ID: <20081023095949.GB6640@fogou.chygwyn.com>
References: <20081021112137.GB12329@wotan.suse.de> <E1KsGj7-0005sK-Uq@pomaz-ex.szeredi.hu> <20081021125915.GA26697@fogou.chygwyn.com> <20081022222316.GI15154@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081022222316.GI15154@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Fasheh <mfasheh@suse.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Oct 22, 2008 at 03:23:16PM -0700, Mark Fasheh wrote:
> On Tue, Oct 21, 2008 at 01:59:15PM +0100, steve@chygwyn.com wrote:
> > Hi,
> > 
> > On Tue, Oct 21, 2008 at 02:52:45PM +0200, Miklos Szeredi wrote:
> > > On Tue, 21 Oct 2008, Nick Piggin wrote:
> > > > IO error handling in the core mm/fs still doesn't seem perfect, but with
> > > > the recent round of patches and this one, it should be getting on the
> > > > right track.
> > > > 
> > > > I kind of get the feeling some people would rather forget about all this
> > > > and brush it under the carpet. Hopefully I'm mistaken, but if anybody
> > > > disagrees with my assertion that error handling, and data integrity
> > > > semantics are first-class correctness issues, and therefore are more
> > > > important than all other non-correctness problems... speak now and let's
> > > > discuss that, please.
> > > 
> > > I agree that error handling is important.  But careful: some
> > > filesystems (NFS I know) don't set PG_error on async read errors, and
> > > changing the semantics of ->readpage() from returning EIO to retrying
> > > will potentially cause infinite loops.  And no casual testing will
> > > reveal those because peristent read errors are extremely rare.
> > > 
> > > So I think a better aproach would be to do
> > > 
> > > 			error = lock_page_killable(page);
> > > 			if (unlikely(error))
> > > 				goto readpage_error;
> > > 			if (PageError(page) || !PageUptodate(page)) {
> > > 				unlock_page(page);
> > > 				shrink_readahead_size_eio(filp, ra);
> > > 				error = -EIO;
> > > 				goto readpage_error;
> > > 			}
> > > 			if (!page->mapping) {
> > > 				unlock_page(page);
> > > 				page_cache_release(page);
> > > 				goto find_page;
> > > 			}
> > > 
> > > etc...
> > > 
> > > Is there a case where retrying in case of !PageUptodate() makes any
> > > sense?
> > >
> > Yes... cluster filesystems. Its very important in case a readpage
> > races with a lock demotion. Since the introduction of page_mkwrite
> > that hasn't worked quite right, but by retrying when the page is
> > not uptodate, that should fix the problem,
> 
> Btw, at least for the readpage case, a return of AOP_TRUNCATED_PAGE should
> be checked for, which would indicate (along with !PageUptodate()) whether we
> need to retry the read. page_mkwrite though, as you point out, is a
> different story.
> 	--Mark
>
Yes, and although I probably didn't make it clear I was thinking
specifically of the page fault path there where both readpage and
page_mkwrite hang out.

Also, I've looked through all the current GFS2 code and it seems to
be correct in relation to Miklos' point on PageUptodate() vs
page->mapping == NULL so I don't think any changes are required there,
but obviously that needs to be taken into account in filemap_fault wrt
to retrying in the lock demotion case. In other words we should be
testing for page->mapping == NULL rather than !PageUptodate() in that
case,

Steve.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
