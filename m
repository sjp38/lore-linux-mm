Date: Mon, 23 Oct 2000 23:32:53 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Another wish item for your TODO list...
Message-ID: <20001023233253.E3749@redhat.com>
References: <20001023175402.B2772@redhat.com> <Pine.LNX.4.21.0010231501210.13115-100000@duckman.distro.conectiva> <20001023183649.H2772@redhat.com> <20001024002851.G727@nightmaster.csn.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20001024002851.G727@nightmaster.csn.tu-chemnitz.de>; from ingo.oeser@informatik.tu-chemnitz.de on Tue, Oct 24, 2000 at 12:28:51AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Oct 24, 2000 at 12:28:51AM +0200, Ingo Oeser wrote:
> On Mon, Oct 23, 2000 at 06:36:49PM +0100, Stephen C. Tweedie wrote:
> > On Mon, Oct 23, 2000 at 03:02:06PM -0200, Rik van Riel wrote:
> > > I take it you mean "move all the pages from before the
> > > currently read page to the inactive list", so we preserve
> > > the pages we just read in with readahead ?
> > No, I mean that once we actually remove a page, we should also remove
> > all the other pages IF the file has never been accessed in a
> > non-sequential manner.  The inactive management is separate.
> 
> *.h files, which are read in by the GCC are always accessed
> sequentielly (at least from the kernel POV) and while unmapping
> them is ok, they should at least remain in cache to speed up
> compiling. That's just one example for a workload which will
> suffer from this idea.

No.  If they stay in cache, then that's fine: we won't change the
caching behaviour at all.

All we do is change what happens _after_ the kernel has already
decided to start moving pages of the file out of cache because they
are old.  For small sequential files like header files, there's
absolutely no point in having just a few of the pages in cache --- you
know, for sure, that if you need one of the pages, you'll need all of
them.  So, once one of the pages is old enough to be evicted from the
cache, there's no point in keeping any of the other pages around.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
