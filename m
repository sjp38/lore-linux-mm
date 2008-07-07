In-reply-to: <200807072101.58963.nickpiggin@yahoo.com.au> (message from Nick
	Piggin on Mon, 7 Jul 2008 21:01:58 +1000)
Subject: Re: [patch 1/2] mm: dont clear PG_uptodate in invalidate_complete_page2()
References: <20080625124038.103406301@szeredi.hu> <E1KFmuc-0001VS-RS@pomaz-ex.szeredi.hu> <E1KFniG-0001cS-Rb@pomaz-ex.szeredi.hu> <200807072101.58963.nickpiggin@yahoo.com.au>
Message-Id: <E1KFpRL-0001pA-Aq@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 07 Jul 2008 14:03:31 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nickpiggin@yahoo.com.au
Cc: miklos@szeredi.hu, jamie@shareable.org, torvalds@linux-foundation.org, jens.axboe@oracle.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Mon, 7 Jul 2008, Nick Piggin wrote:
> And it isn't just a fuse problem is it? Other places can invalidate
> and truncate pages which might be spliced into a pipe, can't they?

Yes.  There are several different problems here actually, and it's not
completely clear how splice should handle them:

Case 1: page is completely truncated while in the pipe

  Currently splice() will detect this and return a short read count on
  the splice-out.  Which sounds sane, and consistent with the fact
  that a zero return value can happen on EOF.

Case 2: page is partially truncated while in the pipe

  Splice doesn't detect this, and returns the contents of the whole
  page on splice-out, which will contain the zeroed-out part as well.
  This is not so nice, but other than some elaborate COW schemes, I
  don't see how this could be fixed.

Case 3: page is invalidated while in the pipe

  This can happen on pages in the middle of the file, and splice-out
  can return a zero count.  This is *BAD*, callers of splice really
  should be able to assume, that a zero return means EOF.

Page invalidation (the invalidate_inode_pages2 kind) is done by only a
few filesystems (FUSE, NFS, AFS, 9P), and by O_DIRECT hackery.  So
case 3 only affects these, and only fuse can be re-exported by nfsd
(and that's only in -mm yet), hence this is very unlikely to be hit
for any of the others.

But it's bad despite being rare, because once it hits it can cause
data corruption (like with fuse/nfsd) and could be very hard to debug.
OK, case 2 could also cause corruption if caller is not expecting it.

Splice is a cool concept, but it isn't easy to get the implementation
right...

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
