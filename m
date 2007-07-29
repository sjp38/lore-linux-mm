Message-ID: <46AC3642.6C60A0EF@earthlink.net>
Date: Sat, 28 Jul 2007 23:40:02 -0700
From: Erblichs <erblichs@earthlink.net>
MIME-Version: 1.0
Subject: Re: How can we make page replacement smarter (was: swap-prefetch)
References: <200707272243.02336.a1426z@gawab.com> <200707280717.41250.a1426z@gawab.com> <46AAEFC4.8000006@redhat.com> <200707281411.57823.a1426z@gawab.com> <46AC1297.9030009@redhat.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Al Boldi <a1426z@gawab.com>, Chris Snook <csnook@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Inline..

	Mitchell Erblich

Rik van Riel wrote:
> 
> Al Boldi wrote:
> > Chris Snook wrote:
> 
> >> At best, reads can be read-ahead and cached, which is why
> >> sequential swap-in sucks less.  On-demand reads are as expensive as I/O
> >> can get.
> >
> > Which means that it should be at least as fast as swap-out, even faster
> > because write to disk is usually slower than read on modern disks.  But
> > linux currently shows a distinct 2x slowdown for sequential swap-in wrt
> > swap-out.
> 

> That's because writes are faster than reads in moderate
> quantities.

	Assuming that the write is not a partial write based
	on first doing a read..

	Yes, a COW FS minimes this condition (ex: ZFS)

	However, since writes are mostly asynch in nature
	most writers shouldn't care when the write is
	actually commited, just that the data is stable
	at some point in the future..

	Thus, who would care (as long as we are not waiting
	for the write to complete) if the write was slower.
	IMO, it would make sense to ALMOST always generate
	a certain amount of writable data before the write
	is completed to attempt for the write to be as
	"sequential" on the disk, so any later reads would
	have minimal seeks..
	
> 
> The disk caches writes, allowing the OS to write a whole
> bunch of data into the disk cache and the disk can optimize
> the IO a bit internally.
> 
> The same optimization is not possible for reads.
> 
> --
> Politics is the struggle between those who want to make their country
> the best in the world, and those who believe it already is.  Each group
> calls the other unpatriotic.
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
