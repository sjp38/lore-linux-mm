In-reply-to: <E1KFmuc-0001VS-RS@pomaz-ex.szeredi.hu> (message from Miklos
	Szeredi on Mon, 07 Jul 2008 11:21:34 +0200)
Subject: Re: [patch 1/2] mm: dont clear PG_uptodate in invalidate_complete_page2()
References: <20080625124038.103406301@szeredi.hu> <20080625173837.GA10005@shareable.org> <E1KBZqG-0008OZ-Pw@pomaz-ex.szeredi.hu> <200807071638.32955.nickpiggin@yahoo.com.au> <E1KFmuc-0001VS-RS@pomaz-ex.szeredi.hu>
Message-Id: <E1KFniG-0001cS-Rb@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 07 Jul 2008 12:12:52 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nickpiggin@yahoo.com.au
Cc: miklos@szeredi.hu, jamie@shareable.org, torvalds@linux-foundation.org, jens.axboe@oracle.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Mon, 07 Jul 2008, Miklos Szeredi wrote:
> On Mon, 7 Jul 2008, Nick Piggin wrote:
> > I don't know what became of this thread, but I agree with everyone else
> > you should not skip clearing PG_uptodate here. If nothing else, it
> > weakens some important assertions in the VM. But I agree that splice
> > should really try harder to work with it and we should be a little
> > careful about just changing things like this.
> 
> Sure, that's why I rfc'ed.
> 
> But I'd still like to know, what *are* those assumptions in the VM
> that would be weakened by this?

For one, currently some of the generic VM code assumes that after
synchronously reading in a page (i.e. ->readpage() then lock_page())
!PageUptodate() necessarily means an I/O error:

/**
 * read_cache_page - read into page cache, fill it if needed
...
 * If the page does not get brought uptodate, return -EIO.
 */

Which is wrong, the page could be invalidated between being broough
uptodate and being examined for being uptodate.  Then we'd be
returning EIO, which is definitely wrong.

AFAICS this could be a real (albeit rare) bug in NFS's readdir().

This is easily fixable in read_cache_page(), but what I'm trying to
say is that assumptions about PG_uptodate aren't all that clear to
begin with, so it would perhaps be useful to first think about this a
bit more.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
