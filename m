Date: Tue, 24 Feb 1998 10:42:48 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: PATCH: Swap shared pages (was: How to read-protect a vm_area?)
In-Reply-To: <199802232317.XAA06136@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.91.980224102818.1909A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, Linus Torvalds <torvalds@transmeta.com>, Itai Nahshon <nahshon@actcom.co.il>, Alan Cox <alan@lxorguk.ukuu.org.uk>, paubert@iram.es, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[linux-kernel trimmed from f-ups]

On Mon, 23 Feb 1998, Stephen C. Tweedie wrote:

> The patch below, against 2.1.88, adds a bunch of new functionality to
> the swapper.  The main changes are:
> 
> * All swapping goes through the swap cache (aka. page cache) now.

Does this mean that _after_ the pages are properly aged
as user-pages, they'll be aged again as page-cache pages?
(when proper aging is added to the page cache, by eg. my patch)

I think it might be far better to:
- put user-pages in the swap cache after they haven't been used
  for two aging rounds
- free swap-cache pages and page-cache pages after they haven't
  been used for eight aging rounds (so the real aging and waiting
  takes place here)
- use right-shift aging here {age << 1; if(touched) age |= 0x80}
- adapt the get_free_pages so it can allocate clean page-cache and
  swap-cache pages when:
  - a bigorder area can't be found
  - there are no free pages left (and kswapd hasn't found new ones)
- keep the ratio user-page:swap-cache-page at about 2:1 so that
  swap-cache pages get a proper chance for aging, instead of being
  discarded immediately (hmm, why not put untouched user-pages in
  the swap cache immediately?)

For more improvements, we could use Ben's pte_list <name?>
patch so we could force-free bigorder areas and run somewhat
more efficiently.

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
