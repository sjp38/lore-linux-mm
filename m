Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA29501
	for <linux-mm@kvack.org>; Wed, 25 Nov 1998 17:29:20 -0500
Date: Wed, 25 Nov 1998 22:29:09 GMT
Message-Id: <199811252229.WAA05737@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Two naive questions and a suggestion
In-Reply-To: <Pine.LNX.3.96.981125220910.15920A-100000@mirkwood.dummy.home>
References: <199811252102.VAA05466@dax.scot.redhat.com>
	<Pine.LNX.3.96.981125220910.15920A-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, jfm2@club-internet.fr, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 25 Nov 1998 22:21:43 +0100 (CET), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> Then I think it's time to do swapin readahead on the
> entire SWAP_CLUSTER (or just from the point where we
> faulted) on a dumb-and-dumber basis, awaiting a good
> readahead scheme. Of course it will need to be sysctl
> tuneable :)

Yep, although I'm not sure that reading a whole SWAP_CLUSTER would be a
good idea.  Contrary to popular belief, disks are still quite slow at
sequential data transfer.  Non-sequential IO is obviously enormously
slower still, but doing readahead on a whole SWAP_CLUSTER (128k) is
definitely _not_ free.  It will increase the VM latency enormously if we
start reading in a lot of unnecessary data.

On the other hand, swap readahead is sufficiently trivial to code that
experimenting with good values is not hard.  Normal pagein already does
a one-block readahead, and doing this in swap would be pretty easy.  

The biggest problem with swap readahead is that there is very little
guarantee that the next page in any one swap partition is related to the
current page: the way we select pages for swapout makes it quite likely
that bits of different processes may intermix, and swap partitions can
also get fragmented over time.  To really benefit from swap readahead,
we would also want improved swap clustering which tried to keep a
logical association between adjacent physical pages, in the same way
that the filesystem does.  Right now, the swap clustering is great for
output performance but doesn't necessarily lead to disk layouts which
are good for swaping.

> Plus Linus might actually accept a change like this :)

If it is tunable, then it is so easy that he might well, yes.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
