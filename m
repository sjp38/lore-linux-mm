Message-ID: <39CCCC15.DB052A65@norran.net>
Date: Sat, 23 Sep 2000 17:28:21 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: test9-pre6 and GFP_BUFFER allocations
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

Hi,

What will happen in this scenario:
a process
* grabs a fs semaphore
* needs some buffers to do IO, calls __alloc_pages(GFP_BUFFER)
Suppose the system is MIN on free mem, has no inactive_clean pages.
We will end up around line 446 in pages_alloc.c and issue a
try_to_free_pages(...). Then goto try_again.
* In our case this is unlikely to work - not allowed to do IO.
* Will we sleep? Probably not, not even in refill_inactive (no GFP_IO)
  BTW, Why can't we schedule if GFP_IO is not set???
* Will we free any page, to get above MIN - only if there are enough
  clean pages in active list.
* Won't we end up in an infinite loop?
Suppose it does sleep. Will kswapd then be able to free any page
assuming we are holding a critical fs semaphore...

Or am I missing something, again?


One approach could be: only goto try_again if GFP_IO is set.
And alloc one page from the critical memory pool.
I will try this.

/RogerL

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
