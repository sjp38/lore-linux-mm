Message-ID: <39C91CC8.F8D27899@norran.net>
Date: Wed, 20 Sep 2000 22:23:36 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: 2.4.0-test9-pre4: __alloc_pages(...) try_again:
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@conectiva.com.br>, "Juan J. Quintela" <quintela@fi.udc.es>
List-ID: <linux-mm.kvack.org>

Hi,


Trying to find out why test9-pre4 freezes with mmap002
I added a counter for try_again loops.

... __alloc_pages(...)

        int direct_reclaim = 0;
        unsigned int gfp_mask = zonelist->gfp_mask;
        struct page * page = NULL;
+       int try_again_loops = 0;

- - -

+         printk("VM: sync kswapd (direct_reclaim: %d) try_again #
%d\n",
+                direct_reclaim, ++try_again_loops);
                        wakeup_kswapd(1);
                        goto try_again;


Result was surprising:
  direct_reclaim was 1.
  try_again_loops did never stop increasing (note: it is not static,
  and should restart from zero after each success)

Why does this happen?
a) kswapd did not succeed in freeing a suitable page?
b) __alloc_pages did not succeed in grabbing the page?

/RogerL

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
