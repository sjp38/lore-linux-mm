In-reply-to: <20070421035444.f7a42fad.akpm@linux-foundation.org> (message from
	Andrew Morton on Sat, 21 Apr 2007 03:54:44 -0700)
Subject: Re: [PATCH 10/10] mm: per device dirty threshold
References: <20070420155154.898600123@chello.nl>
	<20070420155503.608300342@chello.nl>
	<20070421025532.916b1e2e.akpm@linux-foundation.org>
	<E1HfCzN-0002dZ-00@dorka.pomaz.szeredi.hu> <20070421035444.f7a42fad.akpm@linux-foundation.org>
Message-Id: <E1HfM9K-0003OA-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Sat, 21 Apr 2007 22:25:38 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: miklos@szeredi.hu, a.p.zijlstra@chello.nl, linux-mm@kvack.org, linux-kernel@vger.kernel.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

> > The other deadlock, in throttle_vm_writeout() is still to be solved.
> 
> Let's go back to the original changelog:
> 
> Author: marcelo.tosatti <marcelo.tosatti>
> Date:   Tue Mar 8 17:25:19 2005 +0000
> 
>     [PATCH] vm: pageout throttling
>     
>     With silly pageout testcases it is possible to place huge amounts of memory
>     under I/O.  With a large request queue (CFQ uses 8192 requests) it is
>     possible to place _all_ memory under I/O at the same time.
>     
>     This means that all memory is pinned and unreclaimable and the VM gets
>     upset and goes oom.
>     
>     The patch limits the amount of memory which is under pageout writeout to be
>     a little more than the amount of memory at which balance_dirty_pages()
>     callers will synchronously throttle.
>     
>     This means that heavy pageout activity can starve heavy writeback activity
>     completely, but heavy writeback activity will not cause starvation of
>     pageout.  Because we don't want a simple `dd' to be causing excessive
>     latencies in page reclaim.
>     
>     Signed-off-by: Andrew Morton <akpm@osdl.org>
>     Signed-off-by: Linus Torvalds <torvalds@osdl.org>
> 
> (A good one!  I wrote it ;))
> 
> 
> I believe that the combination of dirty-page-tracking and its calls to
> balance_dirty_pages() mean that we can now never get more than dirty_ratio
> of memory into the dirty-or-writeback condition.
> 
> The vm scanner can convert dirty pages into clean, under-writeback pages,
> but it cannot increase the total of dirty+writeback.

What about swapout?  That can increase the number of writeback pages,
without decreasing the number of dirty pages, no?

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
