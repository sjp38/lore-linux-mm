Message-ID: <01BFD09A.CC430AF0@lando.optronic.se>
From: Roger Larsson <roger.larsson@optronic.se>
Subject: Re: reduce shrink_mmap rate of failure (initial attempt)
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Date: Wed, 7 Jun 2000 16:04:54 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "'quintela@fi.udc.es'" <quintela@fi.udc.es>
Cc: "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>That patch hangs my machine here when I run mmap002.  The machine is
>in shrink_mmap.  It hangs trying to get the pagmap_lru_lock.
>
>I think that the idea is good, but it doesn't work here :(.
>
>Later, Juan.


Ouch...

The only possible explaination is that we are searching for pages on a zone.
But no such pages are possible to free from LRU...
And we LOOP the list, holding the lru lock...
Note: without this patch you may end up in another bad situation where
shrink_mmap always fails and swapping will start until it swaps out a page
of that specific zone.
And without the test? We would free all other LRU pages without finding one
that we want :-(

This will be interesting to fix...

May the allocation of pages play a part? Filling zone after zone will give no
mix between the zones.

/RogerL
(from work)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
