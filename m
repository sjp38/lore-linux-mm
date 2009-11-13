Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 80FEE6B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 10:24:06 -0500 (EST)
Date: Fri, 13 Nov 2009 10:22:54 -0500
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [PATCH 3/5] page allocator: Wait on both sync and async
 congestion after direct reclaim
Message-ID: <20091113152254.GC7891@think>
References: <1258054235-3208-1-git-send-email-mel@csn.ul.ie>
 <1258054235-3208-4-git-send-email-mel@csn.ul.ie>
 <20091113142526.33B3.A69D9226@jp.fujitsu.com>
 <20091113115558.GY8742@kernel.dk>
 <20091113122821.GC29804@csn.ul.ie>
 <20091113133211.GA8742@kernel.dk>
 <84144f020911130541p42c0b3d5lc307f97f22e2d356@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f020911130541p42c0b3d5lc307f97f22e2d356@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Jens Axboe <jens.axboe@oracle.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 13, 2009 at 03:41:46PM +0200, Pekka Enberg wrote:
> Hi Jens,
> 
> On Fri, Nov 13, 2009 at 3:32 PM, Jens Axboe <jens.axboe@oracle.com> wrote:
> >> Suggest an alternative that brings congestion_wait() more in line with
> >> 2.6.30 behaviour then.
> >
> > I don't have a good explanation as to why the delays have changed,
> > unfortunately. Are we sure that they have between .30 and .31? The
> > dm-crypt case is overly complex and lots of changes could have broken
> > that house of cards.
> 
> Hand-waving or not, we have end user reports stating that reverting
> commit 8aa7e847d834ed937a9ad37a0f2ad5b8584c1ab0 ("Fix
> congestion_wait() sync/async vs read/write confusion") fixes their
> (rather serious) OOM regression. The commit in question _does_
> introduce a functional change and if this was your average regression,
> people would be kicking and screaming to get it reverted.
> 
> So is there a reason we shouldn't send a partial revert of the commit
> (switching to BLK_RW_SYNC) to Linus until the "real" issue gets
> resolved? Yes, I realize it's ugly voodoo magic but dammit, it used to
> work!

If the workload didn't involve dm-crypt everything would make more sense.
With dm-crypt, things look like this:

VM:
Someone submits a write (sync or not) to clean a page
out of pages, I'll wait for the disk

dm-crypt:
Async threads wakeup and start encrypting submitted writes

Async threads finish and hand off to other async threads to submit new writes
or
dm encryption thread submits the write directly (without my patch)

The problem with all of this is that waiting for congestion doesn't
actually have very much to do with waiting for dm-crypt IO.  We might
be checking congestion long before dm-cryptd actually gets around to
sending the IO to the disk (so we'll just wait for the full timeout),
or the congestion check could be waiting for entirely unrelated IO.

Because dm-crypt uses the same queue for encrypting and decrypting reads
and writes, if writepage needs to read a block (say a metadata mapping
block), waiting for that block to become unencrypted will have to wait
for the entire queue of both encrypted and decrypted blocks to finish.

[ Unless I completely misread dm-crypt, which is always possible ]

So, cleaning pages can take an arbitrary amount of time, based on how
much CPU time is available, how many other pages are in the worker
threads and how fast the disk is once we finally hand the pages over to
it.

Tuning the VM timeouts based on this seems like a bad idea to me.  If
the VM is waiting for pages to leave writeback, we should just add a
sequence counter and wait queue that gets bumped as pages leave
writeback (or something that wouldn't do horrible things to cachelines).

Otherwise we're going to end up waiting way too long for the sync
congestion on configs that don't intermix sync and async in such complex
ways.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
