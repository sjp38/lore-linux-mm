Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA08606
	for <linux-mm@kvack.org>; Tue, 17 Nov 1998 02:12:16 -0500
Date: Tue, 17 Nov 1998 07:42:12 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: unexpected paging during large file reads in 2.1.127
In-Reply-To: <199811162305.XAA07996@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.981117073807.2352A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, "David J. Fred" <djf@ic.net>, linux-kernel@vger.rutgers.edu, Linux-MM List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Nov 1998, Stephen C. Tweedie wrote:
> On Mon, 16 Nov 1998 21:48:35 +0100 (CET), Rik van Riel
> <H.H.vanRiel@phys.uu.nl> said:
> > On Mon, 16 Nov 1998, Stephen C. Tweedie wrote:
> >> The real cure is to disable page aging in the page cache completely.
> >> Now that we have disabled it for swap, it makes absolutely no sense at
> >> all to keep it in the page cache.
> 
> > This is not entirely true. There is a major difference
> > between pages in the page cache and pages that can go
> > into swap. The latter kind will always be mapped inside
> > the address space of a program (where it gets proper
> > aging and stuff)
> 
> No it doesn't, that's what I'm saying.  Linus removed swap page aging in
> the recent kernels.  That throws the balance between swap and cache
> completely out of the window: removing the page cache aging is necessary
> to restore balance.  There are many many reports of massive cache growth
> on the latest kernels as a result of this.

I meant the page aging that occurs in vmscan.c, where we
decide on which page to unmap from a program's address
space. There we do aging while we don't age pages from
files that are read().

> > Now we can get severe problems with readahead when we
> > are evicting just read-in data because it isn't mapped,
> 
> No, we don't.  We don't evict just-read-in data, because we mark such
> pages as PG_Referenced.  It takes two complete shrink_mmap() passes
> before we can evict such pages.

OK, I can (and have for quite a while) agree with this.
Kernels with this feature and enough memory will run great,
maybe small machines (<16M) will have a bit of trouble
keeping up readahead performance (since kswapd will have
made it's round a bit fast) but those machines will have
sucky performance anyway :)

Rik -- slowly getting used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
