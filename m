Date: Fri, 26 Jul 2002 12:50:55 -0400
Subject: Re: [RFC] start_aggressive_readahead
Content-Type: text/plain; charset=US-ASCII; format=flowed
Mime-Version: 1.0 (Apple Message framework v482)
From: Scott Kaplan <sfkaplan@cs.amherst.edu>
In-Reply-To: <3D405428.7EC4B715@zip.com.au>
Message-Id: <DA306A6C-A0B7-11D6-8C60-000393829FA4@cs.amherst.edu>
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Rik van Riel <riel@conectiva.com.br>, Christoph Hellwig <hch@lst.de>, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Thursday, July 25, 2002, at 03:40 PM, Andrew Morton wrote:

> What it boils down to is:  which pages are we, in the immediate future,
> more likely to use?  Pages which are at the tail of the inactive list,
> or pages which are in the file's readahead window?

That is the right question to ask...

> I'd say the latter, so readahead should just go and do reclaim.

...but the answer's not that simple, I'm afraid.  You've got two groups of 
logical pages competing for physical page frames.  Which is more valuable 
depends entirely on the reference behavior of workload.  I'll point you to 
a recent paper of mine on exactly this problem (in two formats):

   http://www.cs.amherst.edu/~sfkaplan/papers/prepaging.pdf
   http://www.cs.amherst.edu/~sfkaplan/papers/prepaging.ps.bz2

The results presented are from uniprogrammed reference traces, but the 
principle still applies:  For some reference patterns, caching of some 
number of readahead pages is a great idea.  For other reference patterns, 
the pages at the tail end of the inactive list are *still* more valuable, 
and the readahead pages should be completely ignored.  There's also a lot 
of space in the middle:  Readahead pages should be cached, but only for a 
limited time, lest they displace too many pages on the tail end of the 
inactive list.

What you really want is some kind of adaptivity that allows you to compare 
the rates at which these two pools of pages are referenced, and then 
decides how many readahead pages (if any) to cache.

Scott
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (Darwin)
Comment: For info see http://www.gnupg.org

iD8DBQE9QX3y8eFdWQtoOmgRAplfAKCLrmURjCkuf6snOfwrFQFmqXlYoACgnvCa
IFEC/tDsVLY+isCC/qkxn5w=
=8Jx5
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
