Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA32365
	for <linux-mm@kvack.org>; Thu, 26 Feb 1998 17:53:25 -0500
Date: Thu, 26 Feb 1998 22:53:17 GMT
Message-Id: <199802262253.WAA03955@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: memory limitation test kit (tm) :-)
In-Reply-To: <Pine.LNX.3.91.980226135506.30101A-100000@mirkwood.dummy.home>
References: <Pine.LNX.3.91.980226135506.30101A-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: linux-mm <linux-mm@kvack.org>, "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, werner@suse.de
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 26 Feb 1998 13:58:05 +0100 (MET), Rik van Riel
<H.H.vanRiel@fys.ruu.nl> said:

> Hi there,
> I've made a 'very preliminary' test patch to test
> whether memory limitation / quotation might work.
> It's untested, untunable and plain wrong, but nevertheless
> I'd like you all to take a look at it and point out things
> that I've forgotten in the limitation code...

Running a single task which has a perfectly reasonable resident set
larger than num_physpages/2 will thrash unnecessarily.

What I'm aiming for with the RSS limits is to swap stuff out of the
process's ptes if it exceeds its RSS limit (btw, struct rusage already
defines a perfectly good RSS limit we can use here --- ru_maxrss), but
to keep the pages in memory in the swap cache until the memory is needed
for something else.  That way, a process exceeding RSS will run more
slowly due to soft page faults, but won't necessarily incur any extra
disk IO unless either there is genuine contention for memory or the
process is actively writing to a lot of its working set (doing the
swapout on unmodified pages is cheap, since we just keep the old copy on
disk anyway).

The new swap cache code was designed to support this stuff, and I'm
currently working on the code necessary to manage fast reclamation (even
from within interrupts) of swap pages which are disconnected from all
page tables but are still in cache.

Cheers,
 Stephen.
