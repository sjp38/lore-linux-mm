Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA23197
	for <linux-mm@kvack.org>; Tue, 30 Jun 1998 15:10:01 -0400
Date: Tue, 30 Jun 1998 14:10:52 +0100
Message-Id: <199806301310.OAA00911@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Thread implementations...
In-Reply-To: <m1vhpj8l95.fsf@flinx.npwt.net>
References: <199806240915.TAA09504@vindaloo.atnf.CSIRO.AU>
	<Pine.LNX.3.96dg4.980624025515.26983E-100000@twinlark.arctic.org>
	<199806241213.WAA10661@vindaloo.atnf.CSIRO.AU>
	<m1u35a4fz8.fsf@flinx.npwt.net>
	<199806242341.JAA15101@vindaloo.atnf.CSIRO.AU>
	<m1pvfy3x8f.fsf@flinx.npwt.net>
	<qww4sx8r44b.fsf@p21491.wdf.sap-ag.de>
	<m1k964fdu9.fsf@flinx.npwt.net>
	<199806291019.LAA00726@dax.dcs.ed.ac.uk>
	<m1vhpj8l95.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, Christoph Rohland <hans-christoph.rohland@sap-ag.de>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 30 Jun 1998 01:19:18 -0500, ebiederm+eric@npwt.net (Eric
W. Biederman) said:

> Again the case was: I have a multithreaded web server serving up
> files.  The web server mmaps each file, and calls madvise(file_start,
> file_len, MADV_SEQUENTIAL).  The trick is that it may be serving the
> say file to two different clients simultaneously.

The actual sharing is not a problem; the cache is already safe against
that even when doing readahead.

> MADV_SEQUENTIAL implies readahead, and forget behind, but for a simple
> process.

Yep, the forget behind is the important stuff to get right, but all we
need to do there is to unmap the pages from the process's address space:
we don't need to actually flush the page cache.  As long as the page
cache can find these pages quickly if it needs to reuse the memory for
something else, then there's no reason to actually forget the data there
and then.

> The forget behind is tricky and difficult to get right, but if we
> concentrate on aggressive readahead (in this  we will probably be
> o.k.)

Not for very large files: the forget-behind is absolutely critical in
that case.

--Stephen
