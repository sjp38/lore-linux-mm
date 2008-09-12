Date: Fri, 12 Sep 2008 13:10:05 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC PATCH] discarding swap
In-Reply-To: <1221082117.13621.25.camel@macbook.infradead.org>
Message-ID: <Pine.LNX.4.64.0809121154430.12812@blonde.site>
References: <Pine.LNX.4.64.0809092222110.25727@blonde.site>
 <20080910173518.GD20055@kernel.dk>  <Pine.LNX.4.64.0809102015230.16131@blonde.site>
 <1221082117.13621.25.camel@macbook.infradead.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-1647284174-1221221405=:12812"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--8323584-1647284174-1221221405=:12812
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Wed, 10 Sep 2008, David Woodhouse wrote:
> On Wed, 2008-09-10 at 20:51 +0100, Hugh Dickins wrote:
>=20
> blkdev_issue_discard() is for na=C3=AFve callers who don't want to have t=
o
> think about barriers. You might benefit from issuing discard requests
> without an implicit softbarrier, for swap.

Whilst I'd certainly categorize myself as a na=C3=AFve caller, swap should
not be, and I now believe you're right that it would be better for
swap not to be using DISCARD_BARRIER there - thanks for noticing.

For that I think we'd want blk-barrier.c's blkdev_issue_discard() to
become __blkdev_issue_discard() with a fourth arg (either a boolean,
or DISCARD_BARRIER versus DISCARD_NOBARRIER), with blkdev_issue_discard()
and blkdev_issue_discard_nobarrier() functions inlined in blkdev.h.

I don't think it would be wise for mm/swapfile.c to duplicate
blkdev_issue_discard() without the _BARRIER: I expect that function
to go through a few changes as experience gathers with devices coming
onstream, changes we'd rather not track in mm; and I don't think mm
(beyond bounce.c) should get into request_queues and max_hw_sectors.

> Of course, you then have to ensure that a discard can't still be
> in-flight and actually happen _after_ a subsequent write to that page.

I was certainly terrified of a write sneaking down before the discard
when it was supposed to come after, and therefore took comfort from
the DISCARD_BARRIER - but was, I think, failing to understand that
it's for a filesystem which needs guarantees on the ordering
between data and metadata *in different areas* of the partition,
not an issue for swap at all.

Looking at what I ended up with, I had to put "wait_for_discard"
serialization in at the swap end anyway; and though I thought at the
time that the _BARRIER was saving me from waiting for completion
(only having to wait for completed submission), now I don't see
the _BARRIER as playing any part at all.

So long as the I/O schedulers guarantee that a WRITE bio submitted
to an area already covered by a DISCARD_NOBARRIER bio cannot pass that
DISCARD_NOBARRIER - where "already" means the submit_bio(WRITE, bio2)
is issued after the submit_bio(DISCARD_NOBARRIER, bio1) has returned
to caller (but its "I/O" of course not necessarily completed).

That seems a reasonable guarantee to me, and perhaps it's trivially
obvious to those who know their I/O schedulers; but I don't, so I'd
like to hear such assurance given.

(If there's a problem giving that assurance for WRITE, but it can be
given for WRITE_SYNC, that would suit me quite nicely too, because I'm
looking for a justification for WRITE_SYNC in swap_writepage(): Jens,
it makes those x86_64-tmpfs-swapping-on-CFQ cases a lot better.)

Hugh
--8323584-1647284174-1221221405=:12812--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
