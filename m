Message-ID: <01BFD78B.22578410@lando.optronic.se>
From: Roger Larsson <roger.larsson@optronic.se>
Subject: Re: kswapd eating too much CPU on ac16/ac18
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Date: Fri, 16 Jun 2000 11:56:20 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "'mikeg@weiden.de'" <mikeg@weiden.de>
Cc: "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Ohh,

This code was new at that time...

I have found out that most pages are not freed due to this check.
See "instrumentation patch for shrink_mmap to find cause of failures - it did :-)"

Please try to remove only this test to get a comparable result.
It might lead to infinite loops...

/RogerL

@@ -317,28 +326,34 @@
                        goto cache_unlock_continue;
 
                /*
+                * Page is from a zone we don't care about.
+                * Don't drop page cache entries in vain.
+                */
+               if (page->zone->free_pages > page->zone->pages_high)
+                       goto cache_unlock_continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
