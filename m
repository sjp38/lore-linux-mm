Date: Fri, 18 Aug 2000 14:49:38 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: filemap.c SMP bug in 2.4.0-test* (fwd)
In-Reply-To: <Pine.LNX.4.21.0008172017450.16454-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0008181443560.18597-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>Proc A                                Proc B
>page faults
>...
>read_swap_cache_async
>  lookup_swap_cache fails twice       page faults (same page)
>                                      ...
>                                      read_swap_cache_async
>  init of page info (insert in
>  hash tables...)

as first on proc B read_swap_cache_async can't be started in between the
second fail of the lookup and the init of the page info and insert
hashtables on proc A, because of the big kernel lock.

>                                      lookup_swap_cache
>	                                 __find_page_nolock
>                                         (succeeds, page not active
>                                          activate)
>

The page is inserted locked into the hashtable and lookup_swap_cache uses
find_lock_page so it can't race.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
