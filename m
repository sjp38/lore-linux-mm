Message-ID: <3D263E70.7B8F5307@zip.com.au>
Date: Fri, 05 Jul 2002 17:48:48 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: vm lock contention reduction
References: <3D26304C.51FAE560@zip.com.au> <Pine.LNX.4.44L.0207052110590.8346-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: William Lee Irwin III <wli@holomorphy.com>, Andrea Arcangeli <andrea@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Fri, 5 Jul 2002, Andrew Morton wrote:
> > William Lee Irwin III wrote:
> > > On Thu, Jul 04, 2002 at 07:18:34PM -0700, Andrew Morton wrote:
> > > > Of course, that change means that we wouldn't be able to throttle
> > > > page allocators against IO any more, and we'd have to do something
> > > > smarter.  What a shame ;)
> > >
> > > This is actually necessary IMHO. Some testing I've been able to do seems
> > > to reveal the current throttling mechanism as inadequate.
> >
> > I don't think so.  If you're referring to the situation where your
> > 4G machine had 3.5G dirty pages without triggering writeback.
> >
> > That's not a generic problem.
> 
> But it is, mmap() and anonymous memory don't trigger writeback.
> 

That's different.  Bill hit a problem just running tiobench.

We can run balance_dirty_pages() when a COW copyout is performed,
which will approximately improve things.

But the whole idea of the dirty memory thresholds just seems bust,
really.  Because how do you pick the thresholds?  40%.  Bah.

One idea we kicked around a while back was to remove the throttling
from the write(2) path altogether, and to perform the throttling
inside the page allocator instead, where we have more information.
And perhaps set PF_WRITER before doing so, so the VM can penalise
the caller more heavily.

But this doesn't work if the write(2) caller is redirtying existing
pagecache, just like writes to anon pages, mmap pages, etc.

Alternatively: the VM can periodically reach over and twiddle the
dirty memory thresholds which balance_dirty_pages() uses.  I don't
like our chances of getting that right though ;)

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
