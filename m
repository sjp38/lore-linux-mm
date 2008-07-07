From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 1/2] mm: dont clear PG_uptodate in invalidate_complete_page2()
Date: Mon, 7 Jul 2008 21:01:58 +1000
References: <20080625124038.103406301@szeredi.hu> <E1KFmuc-0001VS-RS@pomaz-ex.szeredi.hu> <E1KFniG-0001cS-Rb@pomaz-ex.szeredi.hu>
In-Reply-To: <E1KFniG-0001cS-Rb@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807072101.58963.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: jamie@shareable.org, torvalds@linux-foundation.org, jens.axboe@oracle.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Monday 07 July 2008 20:12, Miklos Szeredi wrote:
> On Mon, 07 Jul 2008, Miklos Szeredi wrote:
> > On Mon, 7 Jul 2008, Nick Piggin wrote:
> > > I don't know what became of this thread, but I agree with everyone else
> > > you should not skip clearing PG_uptodate here. If nothing else, it
> > > weakens some important assertions in the VM. But I agree that splice
> > > should really try harder to work with it and we should be a little
> > > careful about just changing things like this.
> >
> > Sure, that's why I rfc'ed.
> >
> > But I'd still like to know, what *are* those assumptions in the VM
> > that would be weakened by this?
>
> For one, currently some of the generic VM code assumes that after
> synchronously reading in a page (i.e. ->readpage() then lock_page())
> !PageUptodate() necessarily means an I/O error:

Yes, the error paths in the vm/fs layer can be pretty crappy.


> /**
>  * read_cache_page - read into page cache, fill it if needed
> ...
>  * If the page does not get brought uptodate, return -EIO.
>  */
>
> Which is wrong, the page could be invalidated between being broough
> uptodate and being examined for being uptodate.  Then we'd be
> returning EIO, which is definitely wrong.
>
> AFAICS this could be a real (albeit rare) bug in NFS's readdir().

Actually this bug is known for a long time and exists in the
generic mapping read code too. And it doesn't even need to be
invalidated as such, but even truncated. It can be hard to get
people excited about "theoretical" bugs :(


> This is easily fixable in read_cache_page(), but what I'm trying to
> say is that assumptions about PG_uptodate aren't all that clear to
> begin with, so it would perhaps be useful to first think about this a
> bit more.

PG_uptodate should be set if we can return data to userspace
from it. I wouldn't worry about the error path bugs like this:
they should all be testing PG_error for -EIOness rather than
!PageUptodate. However I don't want to skip clearing PG_uptodate
in invalidate just yet if possible.

It seems to be a documented and known issue from day 0, so if
we can't see a really easy way to fix it without leave PG_uptodate
hanging around, can we put the burden on the callers to handle
the case correctly rather than put it on the VM to handle it?
(which we will then have to support for T < infinity)

And it isn't just a fuse problem is it? Other places can invalidate
and truncate pages which might be spliced into a pipe, can't they?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
