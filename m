Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA13460
	for <linux-mm@kvack.org>; Wed, 11 Mar 1998 17:45:47 -0500
Date: Wed, 11 Mar 1998 22:37:50 GMT
Message-Id: <199803112237.WAA04217@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: 2.1.89 broken?
In-Reply-To: <Pine.LNX.3.91.980310093615.12682A-100000@mirkwood.dummy.home>
References: <m3vhtnzc9g.fsf@s9412a.steinan.ntnu.no>
	<Pine.LNX.3.91.980310093615.12682A-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: Trond Eivind Glomsrod <teg@pvv.ntnu.no>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 10 Mar 1998 09:38:41 +0100 (MET), Rik van Riel
<H.H.vanRiel@fys.ruu.nl> said:

> On 10 Mar 1998, Trond Eivind =?ISO-8859-1?Q?Glomsr=F8d?= wrote:
>> That is my experience as well... I've got 80 MB. It was happy with
>> about 56 MB for caches, 4 MB free and a little less than 20 MB
>> used. Oh - and 75 MB used swap.

> You both seem to be ignoring the fact that sticking
> unused stuff in swap is better than freeing disk
> cache pages. In 2.1.89 we age disk cache pages in
> much the same way we age private (in-swap) pages.
> Because the aging is the same, you can be quite sure
> that Linux is doing the right thing...

Rik, 

No, it's not necessarily doing the Right Thing.  The trouble is that
there is no balancing between swapping and emptying the page cache.
The current balancing heuristic just about works with the old page
cache aging, but if we change that aging, then we just force the
kernel to keep trying to free pages from one source for as long as
there are freeable pages on that source.  Note that this doesn't mean
that it is _cheap_ to free these pages; just that the kernel can,
within the bounds of a single pass through try_to_free_page(), find at
least one swappable page.

Now, once we've got a single pass which can scavenge BOTH page cache
and swap pages, then we're really going to be cooking on gas. :)  For
now, however, all we're doing is tweaking what is a very very delicate
balance, and as we proved in the 1.2.4 and 1.2.5 swapping disasters,
getting such a change done in a way which doesn't make at least
somebody's performance very much worse is really quite hard to do in
the current way of managing memory.  When I was doing the first round
of work on kswap, it was this balance between cache and swap which was
the biggest problem, not the aging of individual pages from either
source.

Cheers,
 Stephen.
