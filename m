Message-ID: <39147CB9.256D1EEA@norran.net>
Date: Sat, 06 May 2000 22:12:41 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: PG_referenced and lru_cache (cpu%)...
References: <8evk0f$7jote$1@fido.engr.sgi.com> <39145287.D8F1F0C1@sgi.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

When _add_to_page_cache adds a page to the lru_cache
it forces it to be referenced.

In addition it will be added as youngest in list.

When a page is needed it is very likely that a lot of
the youngest pages are marked as referenced.

In other cases when a pages is moved to front the
PG_referenced is cleared.

order=0 is the only that tries to search the full list.

When the shrink_mmap finds PG_referenced pages they are
moved to local list young and will not be inserted before
shink_mmap returns, again does not matter...

With "all" possible pages in young, the list is searched
maxloop (256) times... (with a lot of CPU usage)

Conclusion:

I think PG_reference should be cleared in lru_cache_add
and that shrink_mmap should place referenced pages on top
not on an separate list.

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
