Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA06198
	for <linux-mm@kvack.org>; Mon, 16 Nov 1998 18:01:03 -0500
Date: Mon, 16 Nov 1998 21:48:35 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: unexpected paging during large file reads in 2.1.127
In-Reply-To: <199811161959.TAA07259@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.981116214348.26465A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, "David J. Fred" <djf@ic.net>, linux-kernel@vger.rutgers.edu, Linux-MM List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Nov 1998, Stephen C. Tweedie wrote:
> On 12 Nov 1998 23:45:42 +0100, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
> said:
> 
> >> Agreed, we should do something about that.
> >> 
> >> > +			age_page(page);
> >> > +			age_page(page);
> >> >  			age_page(page);
> 
> The real cure is to disable page aging in the page cache completely.
> Now that we have disabled it for swap, it makes absolutely no sense at
> all to keep it in the page cache.

This is not entirely true. There is a major difference
between pages in the page cache and pages that can go
into swap. The latter kind will always be mapped inside
the address space of a program (where it gets proper
aging and stuff), while file data could be used by
doing a read() where the data never gets mapped into
the processes address space.

Now we can get severe problems with readahead when we
are evicting just read-in data because it isn't mapped,
resulting in us having to read it again and doing double
I/O with a badly performing program.

The only reason why it's better than the alternative is
because we don't do swap readahead yet...

cheers,

Rik -- slowly getting used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
