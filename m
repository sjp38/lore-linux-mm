Date: Mon, 23 Feb 1998 23:17:35 GMT
Message-Id: <199802232317.XAA06136@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: PATCH: Swap shared pages (was: How to read-protect a vm_area?)
In-Reply-To: <Pine.LNX.3.95.980220001508.8311A-100000@as200.spellcast.com>
References: <Pine.LNX.3.95.980220001508.8311A-100000@as200.spellcast.com>
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, Rik van Riel <H.H.vanRiel@fys.ruu.nl>, Linus Torvalds <torvalds@transmeta.com>, Itai Nahshon <nahshon@actcom.co.il>, Alan Cox <alan@lxorguk.ukuu.org.uk>, paubert@iram.es, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 20 Feb 1998 00:41:19 -0500 (EST), "Benjamin C.R. LaHaise"
<blah@kvack.org> said:

> As Rik mentioned, please feel free to make use of linux-mm@kvack.org for
> discussion purposes. (echo subscribe | mail majordomo@kvack.org)  It's
> been quite, but then it's Febuary.

OK.  I'm CC:ing there.

The patch below, against 2.1.88, adds a bunch of new functionality to
the swapper.  The main changes are:

* All swapping goes through the swap cache (aka. page cache) now.

* There is no longer a swap lock map.  Because we need to atomically
  test and create a new swap-cache page in order to do swap IO, it is
  sufficient just to lock the struct page itself.  Having only one
  layer of locking to deal with removes a number of races concerning 
  swapping shared pages.

* We can swap shared pages, and still keep them shared when they are
  swapped back in!!!  Currently, only private shared pages (as in pages
  shared after a fork()) benefit from this, but the basic mechanism will
  be appropriate for MAP_ANONYMOUS | MAP_SHARED pages too
  (implementation to follow).  Pages will remain shared after a swapoff.

* The page cache is now quite happy dealing with swap-cache pages too.
  In particular, write-ahead and read-ahead of swap through the page
  cache will work fine (and in fact, write-ahead does get done already
  under certain circumstances with this patch --- that's essentially how
  the swapping of shared pages gets done).  Support code to perform
  asynchronous readahead of swap is included, but is not actually used
  anywhere yet.

I've tested with a number of forked processes running with a shared
working set larger than physical memory, and with SysV shared memory.
I haven't found any problems with it so far.

Enjoy.

Cheers,
 Stephen.

----------------------------------------------------------------
begin 644 swapdiff-2.1.88.gz
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
,HIK^?\EED1Z'DP``
`
end
