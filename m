Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA12376
	for <linux-mm@kvack.org>; Fri, 12 Jun 1998 19:13:57 -0400
Date: Fri, 12 Jun 1998 23:58:39 +0100
Message-Id: <199806122258.XAA02298@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: update re: fork() failures in 2.1.101
In-Reply-To: <Pine.LNX.3.95.980612063348.22741A-100000@localhost>
References: <19980611173940.51846@adore.lightlink.com>
	<Pine.LNX.3.95.980612063348.22741A-100000@localhost>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Paul Kimoto <kimoto@lightlink.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 12 Jun 1998 06:36:53 +0200 (MET DST), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> [Paul get's "cannot fork" errors after 60 or more hours of
>  uptime. This suggests fragmentation problems.]

Kernel version?

> Ahh, I think I see it now. The fragmentation on your system persists
> because of the swap cache. The swap cache 'caches' swap pages and
> kinda makes sure they are reloaded to the same physical address.

No.  As it stands right now, the "caching" component of the swap cache
is an *on disk* cache of resident pages.  Once the pages are swapped
out they are paged back in anywhere appropriate.  That part of the
fragmentation does not persist.

The real problem is not swapper, I suspect, but the various consumers of
slab cache (especially dcache).  The slab allocator has some really
nasty properties; just one single in-use object will pin an entire slab
(up to 32k) into memory.  If the slabs become small, then it will be 4k
pages which get so pinned, and at that point we cannot allocate any
stack pages.  There are a number of ways we may tackle this in 2.1, but
disabling the swap cache won't help at all.

--Stephen
