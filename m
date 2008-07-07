From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 1/2] mm: dont clear PG_uptodate in invalidate_complete_page2()
Date: Mon, 7 Jul 2008 22:17:57 +1000
References: <20080625124038.103406301@szeredi.hu> <200807072101.58963.nickpiggin@yahoo.com.au> <E1KFpRL-0001pA-Aq@pomaz-ex.szeredi.hu>
In-Reply-To: <E1KFpRL-0001pA-Aq@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807072217.57509.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: jamie@shareable.org, torvalds@linux-foundation.org, jens.axboe@oracle.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Monday 07 July 2008 22:03, Miklos Szeredi wrote:
> On Mon, 7 Jul 2008, Nick Piggin wrote:
> > And it isn't just a fuse problem is it? Other places can invalidate
> > and truncate pages which might be spliced into a pipe, can't they?
>
> Yes.  There are several different problems here actually, and it's not
> completely clear how splice should handle them:
>
> Case 1: page is completely truncated while in the pipe
>
>   Currently splice() will detect this and return a short read count on
>   the splice-out.  Which sounds sane, and consistent with the fact
>   that a zero return value can happen on EOF.

OK.


> Case 2: page is partially truncated while in the pipe
>
>   Splice doesn't detect this, and returns the contents of the whole
>   page on splice-out, which will contain the zeroed-out part as well.
>   This is not so nice, but other than some elaborate COW schemes, I
>   don't see how this could be fixed.

There is a race window in the read(2) path where this can happen too.
The window for splice is larger, but I don't know if it is worth a
song and dance about if we're not bothering with the read(2) problem.

Maybe a note in the man page.


> Case 3: page is invalidated while in the pipe
>
>   This can happen on pages in the middle of the file, and splice-out
>   can return a zero count.  This is *BAD*, callers of splice really
>   should be able to assume, that a zero return means EOF.
>
> Page invalidation (the invalidate_inode_pages2 kind) is done by only a
> few filesystems (FUSE, NFS, AFS, 9P), and by O_DIRECT hackery.  So
> case 3 only affects these, and only fuse can be re-exported by nfsd
> (and that's only in -mm yet), hence this is very unlikely to be hit
> for any of the others.

Things that are using invalidate_complete_page2 are probably
also subtly broken if they allow mmap of the same pages, BTW.
It is easy to get wrong. If they have to handle the case of
invalidation failure _anyway_, then we really should have them
just use the safe invalidate...

That would "solve" the splice issue... Although if they handle
failure with a wait/retry loop, then it probably opens a window
to DoS by leaving your pipe filled. In theory one could have a
slowpath function triggered when invalidate fails which copies
the page data and then replaces them with copies in the pipe.
The hard part I suspect is to walk through everybodies pipes and
going through all pages. Probably not realistically solveable.


> But it's bad despite being rare, because once it hits it can cause
> data corruption (like with fuse/nfsd) and could be very hard to debug.
> OK, case 2 could also cause corruption if caller is not expecting it.
>
> Splice is a cool concept, but it isn't easy to get the implementation
> right...

Indeed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
