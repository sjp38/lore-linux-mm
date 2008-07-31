From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch v3] splice: fix race with page invalidation
Date: Thu, 31 Jul 2008 12:16:16 +1000
References: <E1KO8DV-0004E4-6H@pomaz-ex.szeredi.hu> <E1KOFUi-0000EU-0p@pomaz-ex.szeredi.hu> <20080730175406.GN20055@kernel.dk>
In-Reply-To: <20080730175406.GN20055@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807311216.16335.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 31 July 2008 03:54, Jens Axboe wrote:
> On Wed, Jul 30 2008, Miklos Szeredi wrote:
> > On Wed, 30 Jul 2008, Linus Torvalds wrote:
> > > On Wed, 30 Jul 2008, Miklos Szeredi wrote:
> > > > There are no real disadvantages: splice() from a file was
> > > > originally meant to be asynchronous, but in reality it only did
> > > > that for non-readahead pages, which happen rarely.
> > >
> > > I still don't like this. I still don't see the point, and I still
> > > think there is something fundamentally wrong elsewhere.
>
> You snipped the part where Linus objected to dismissing the async
> nature, I fully agree with that part.
>
> > We discussed the possible solutions with Nick, and came to the
> > conclusion, that short term (i.e. 2.6.27) this is probably the best
> > solution.
>
> Ehm where? Nick also said that he didn't like removing the ->confirm()
> bits as they are completely related to the async nature of splice. You
> already submitted this exact patch earlier and it was nak'ed.
>
> > Long term sure, I have no problem with implementing async splice.
> >
> > In fact, I may even have personal interest in looking at splice,
> > because people are asking for a zero-copy interface for fuse.
> >
> > But that is definitely not 2.6.27, so I think you should reconsider
> > taking this patch, which is obviously correct due to its simplicity,
> > and won't cause any performance regressions either.
>
> Then please just fix the issue, instead of removing the bits that make
> this possible.

The only "real" objection I had to avoiding the ClearPageUptodate there
I guess is that it would weaken some assertions. I was more concerned
about the unidentified problems... but there probably shouldn't be
too many places in the VM that really care that much anymore (and those
that do might already be racy).

Now it seems to be perfectly fine to use the actual page itself that may
have been truncated, and we have been doing that for a long time (see
get_user_pages). So I'm not so worried about a bad data corruption or
anything but just the VM getting confused, which we could fix anyway.

I guess that kind of patch could sit in -mm for a while then get merged.
Linus probably wouldn't think highly of a post-rc1 merge, but if it
really is a bugfix, maybe?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
