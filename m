Date: Mon, 2 Apr 2001 14:40:14 -0400 (EDT)
From: Richard Jerrell <jerrell@missioncriticallinux.com>
Subject: Re: [PATCH] Reclaim orphaned swap pages 
In-Reply-To: <Pine.LNX.4.30.0104021952000.406-100000@fs131-224.f-secure.com>
Message-ID: <Pine.LNX.4.21.0104021430160.12558-100000@jerrell.lowell.mclinux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szabolcs Szakacsits <szaka@f-secure.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Actually if vm_enough_memory fails that prevents oom, apps get ENOMEM
> instead of killed by oom_kill later. Moreover vm_enough_memory is long
> different and apparently it's just overestimating free pages that makes
> people unhappy with the resulted higher oom_kill/ENOMEM rate. If you

That's not really what I'm getting at.  Currently if you run a memory
intensive application, quit after it's pages are on an lru, and try to
restart, you won't be able to get the memory.  This is because pages which
are sitting around in the swap cache are not counted as free, and they
should be, because they are freeable.  So the patch isn't to prevent the
oom killer from terminating your processes, it's to prevent the temporary
memory leak from making your system think it is low on memory when it
really isn't.  When vm_enough_memory says you can get the amount you
request, when you fault on those pages you can trigger the swapper,
launder, and reclaimer.  That will free up the pages bound to the swap
cache that no one cares about and you will get your memory.  If you don't
modify vm_enough_memory, you aren't going to get those pages back until
you happen to trigger the swapping code again.

Rich

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
