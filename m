Date: Thu, 5 Jun 2008 10:12:20 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: Two questions on VFS/mm
Message-ID: <20080605081220.GA27370@duck.suse.cz>
References: <20080604163412.GL16572@duck.suse.cz> <E1K3wVW-0001Hv-QD@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1K3wVW-0001Hv-QD@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed 04-06-08 19:10:42, Miklos Szeredi wrote:
> (Added some CCs)
> 
> >   could some kind soul knowledgable in VFS/mm help me with the following
> > two questions? I've spotted them when testing some ext4 for patches...
> >   1) In write_cache_pages() we do:
> > ...
> > 	lock_page(page);
> > 	...
> > 	if (!wbc->range_cyclic && page->index > end) {
> >                    done = 1;
> >                    unlock_page(page);
> >                    continue;
> >         }
> > 	...
> > 	ret = (*writepage)(page, wbc, data);
> > 
> >   Now the problem is that if range_cyclic is set, it can happen that the
> > page we give to the filesystem is beyond the current end of file (and can
> > be already processed by invalidatepage()). Is the filesystem supposed to
> > handle this (what would it be good for to give such a page to the fs?) or
> > is it just a bug in write_cache_pages()?
> 
> There may be a bug somewhere, but write_cache_pages() looks correct.
> It locks the page then checks for page->mapping to make sure the page
> wasn't truncated.  And truncation (including invalidatepage()) happens
> with the page locked, so that can't race with page writeback.
  You are right, write_cache_pages() is correct - I've wrongly undrestood
what 'end' means.

> However the do_invalidatepage() in block_write_full_page() looks
> suspicious.  It calls invalidatepage(), but doesn't perform all the
> other things needed for truncation.  Maybe there's a valid reason for
> that, but I really don't have any idea what.
  Hmm, the fact is I've seen in my tests writepage() being called on a page
which had its buffers removed. And because we attach buffers to a page in
page_mkwrite() and in write_begin() I think we should not see such page.
I've added more debug printings to the code to verify that the page has
indeed been truncated but so far I did not reproduce the problem again.

> >   2) I have the following problem with page_mkwrite() when blocksize <
> > pagesize. What we want to do is to fill in a potential hole under a page
> > somebody wants to write to. But consider following scenario with a
> > filesystem with 1k blocksize:
> >   truncate("file", 1024);
> >   ptr = mmap("file");
> >   *ptr = 'a'
> >      -> page_mkwrite() is called.
> >         but "file" is only 1k large and we cannot really allocate blocks
> >         beyond end of file. So we allocate just one 1k block.
> >   truncate("file", 4096);
> >   *(ptr + 2048) = 'a'
> >      - nothing is called and later during writepage() time we are surprised
> >        we have a dirty page which is not backed by a filesystem block.
> > 
> >   How to solve this? One idea I have here is that when we handle truncate(),
> > we mark the original last page (if it is partial) as read-only again so
> > that page_mkwrite() is called on the next write to it. Is something like
> > this possible? Pointers to code doing something similar are welcome, I don't
> > really know these things ;).

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
