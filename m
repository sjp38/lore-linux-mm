Message-ID: <3D41A54D.408FA357@zip.com.au>
Date: Fri, 26 Jul 2002 12:38:53 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] start_aggressive_readahead
References: <3D405428.7EC4B715@zip.com.au> <DA306A6C-A0B7-11D6-8C60-000393829FA4@cs.amherst.edu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Scott Kaplan <sfkaplan@cs.amherst.edu>
Cc: Rik van Riel <riel@conectiva.com.br>, Christoph Hellwig <hch@lst.de>, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Scott Kaplan wrote:
> 
> ..
> > What it boils down to is:  which pages are we, in the immediate future,
> > more likely to use?  Pages which are at the tail of the inactive list,
> > or pages which are in the file's readahead window?
> 
> That is the right question to ask...
> 
> > I'd say the latter, so readahead should just go and do reclaim.
> 
> ...but the answer's not that simple, I'm afraid.  You've got two groups of
> logical pages competing for physical page frames.  Which is more valuable
> depends entirely on the reference behavior of workload.  I'll point you to
> a recent paper of mine on exactly this problem (in two formats):
> 
>    http://www.cs.amherst.edu/~sfkaplan/papers/prepaging.pdf

readahead was rewritten for 2.5.

I think it covers most of the things you discuss there.

- It adaptively grows the window size in response to "hits":
  each time userspace requests a page, and that page is found
  to be inside the previously-requested readahead window, we
  grow the window by 2 pages (up to a configurable limit)
  because readahead is being beneficial.

- It shrinks the window size in response to "misses" - if
  userspace requests a page which is *not* inside the previously-requested
  window, the future window size is shrunk by 25%

- It detects eviction:  if userspace requests a page which *should*
  have been inside the readahead window, but it's actually not there,
  then we know it was evicted prior to being used.  We shrink the
  window by 3 pages.  (This almost never happens, in my testing).

- It behaves differently for page faults:  for read(2), readahead is
  strictly ahead of the requested page.  For mmap pagefaults, 
  the readaround window is positioned 25% behind the requested page and
  75% ahead of it.

All these numbers were engineered by the time-honoured practice of
guess-and-giggle.

On IDE disks, you can fiddle extensively with readahead and make
virtually no difference at all, because the disk does it as well.
On older SCSI disks, readahead makes a lot of difference.  Because,
presumably, the disk isn't being as smart.  To some extent, this
device-level caching makes the whole readahead thing of historical
interest only, I suspect.

- For CPU efficiency against an already-fully-cached file: If readahead
  finds that all pages inside a readahead request are already in core,
  it shrinks the readahead window by a page, and ultimately turns
  readahead off completely.  It is resumed when there is a miss.

- We no longer put readahead pages on the active list.  They are placed
  on the head of the inactive list.  If nobody subsequently uses the
  page, it proceeds to the tail of the inactive list and is evicted.

  Sort of.  This code needs some checking.  When the readahead page
  is accessed, we set PageReferenced and leave it on the inactive
  list.  It will still be evicted when it reaches the tail of the
  inactive list.  It will only be moved to the active list if it
  is referenced (faulted in or read() from) a second time.  I guess
  this is the "use-once" feature, and it is designed to detect
  the common case of a once-off streaming read.

I'd be interested in your assessment of the 2.5 readahead/readaround
implementation.

It still has one nasty problem, which is not VM-related.  It is to
do with the interaction with request merging.  When performing 
streaming reads from two large files, we tend to seek between the
two files at the readahead window size granularity.  But we *should*
be alternating between the files at a coarser granularity: the
request queue's read latency.   2.4 does this - somehow it manages
to get its new readahead requests merged with its old ones, so
this has the effect of "capturing" the disk head until the request
latency of a request from the other file expires.

I still need to get down and fix this - it's a very subtle interaction
between readahead and request queueing and I suspect it'll need to
be formalised in some manner, rather than just fiddling the code
so it happens to work out right.

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
