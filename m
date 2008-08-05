From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch v3] splice: fix race with page invalidation
Date: Tue, 5 Aug 2008 12:57:12 +1000
References: <E1KO8DV-0004E4-6H@pomaz-ex.szeredi.hu> <200808021426.50436.nickpiggin@yahoo.com.au> <20080804152949.GH18868@shareable.org>
In-Reply-To: <20080804152949.GH18868@shareable.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200808051257.12801.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie@shareable.org>, mtk.manpages@gmail.com
Cc: Miklos Szeredi <miklos@szeredi.hu>, torvalds@linux-foundation.org, jens.axboe@oracle.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 05 August 2008 01:29, Jamie Lokier wrote:
> Nick Piggin wrote:
> > On Saturday 02 August 2008 04:28, Miklos Szeredi wrote:
> > > On Fri, 1 Aug 2008, Nick Piggin wrote:
> > > > Well, a) it probably makes sense in that case to provide another mode
> > > > of operation which fills the data synchronously from the sender and
> > > > copys it to the pipe (although the sender might just use read/write)
> > > > And b) we could *also* look at clearing PG_uptodate as an
> > > > optimisation iff that is found to help.
> > >
> > > IMO it's not worth it to complicate the API just for the sake of
> > > correctness in the so-very-rare read error case.  Users of the splice
> > > API will simply ignore this requirement, because things will work fine
> > > on ext3 and friends, and will break only rarely on NFS and FUSE.
> > >
> > > So I think it's much better to make the API simple: invalid pages are
> > > OK, and for I/O errors we return -EIO on the pipe.  It's not 100%
> > > correct, but all in all it will result in less buggy programs.
> >
> > That's true, but I hate how we always (in the VM, at least) just brush
> > error handling under the carpet because it is too hard :(
> >
> > I guess your patch is OK, though. I don't see any reasons it could cause
> > problems...
>
> At least, if there are situations where the data received is not what
> a common sense programmer would expect (e.g. blocks of zeros, data
> from an unexpected time in syscall sequence, or something, or just
> "reliable except with FUSE and NFS"), please ensure it's documented in
> splice.txt or wherever.

Not quite true. Many filesystems can return -EIO, and truncate can
partially zero pages.

Basically the man page should note that until the splice API is
improved, then a) -EIO errors will be seen at the receiever, b)
the pages can see transient zeroes (this is the case with read(2)
as well, but splice has a much bigger window), and c) the sender
does not send a snapshot of data because it can still be modified
until it is recieved.

c is not too surprising for an asynchronous interface, but it is
nice to document in case people are expecting COw or something.
b and c can more or less be worked around by not doing silly things
like truncating or scribbling on data until reciever really has it.
a, I argue, should be fixed in API.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
