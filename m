Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA12939
	for <linux-mm@kvack.org>; Fri, 27 Feb 1998 16:43:04 -0500
Date: Fri, 27 Feb 1998 19:52:10 GMT
Message-Id: <199802271952.TAA01195@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [2x PATCH] page map aging & improved kswap logic
In-Reply-To: <Pine.LNX.3.91.980227105614.17899A-100000@mirkwood.dummy.home>
References: <199802270929.KAA28081@boole.fs100.suse.de>
	<Pine.LNX.3.91.980227105614.17899A-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: "Dr. Werner Fink" <werner@suse.de>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 27 Feb 1998 10:58:34 +0100 (MET), Rik van Riel
<H.H.vanRiel@fys.ruu.nl> said:

> What I wanted kswapd to do, was to select SWAP_CLUSTER_MAX pages and
> swap them out in _one_ I/O operation. Because this should save head
> movement, it might give us an improvement over syncing each swapped
> page seperately.

I'm working towards it, and yes, this is a very important thing to have.
It's more than just head movement --- disk requests, especially on SCSI,
simply go much faster if you can amalgamate a number of physically
adjacent IO requests into a single operation (scatter-gather allows you
to do this even if the memory for the data is not physically
contiguous).  

The biggest problem is avoiding blocking while we do the work in
try_to_swap_out().  That is a rather tricky piece of code, since it has
to deal with the fact that the process it is swapping can actually be
killed if we sleep for any reason, so it will not necessarily still be
there when we wake up again.  We've really got to do the entire
custering operation for write within try_to_swap_out() and then start up
the IO for those pages.

However, at least with the new swap cache stuff we can make things
easier, since it is now possible to set up swap cache associations
atomically on all the pages we want to swapout, and then take as much
time as we want performing the actual writes.  All we need to do is make
sure that we lock all the pages for IO without the risk of blocking.

Cheers,
 Stephen.
