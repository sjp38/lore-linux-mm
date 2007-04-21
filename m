Date: Sat, 21 Apr 2007 03:54:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 10/10] mm: per device dirty threshold
Message-Id: <20070421035444.f7a42fad.akpm@linux-foundation.org>
In-Reply-To: <E1HfCzN-0002dZ-00@dorka.pomaz.szeredi.hu>
References: <20070420155154.898600123@chello.nl>
	<20070420155503.608300342@chello.nl>
	<20070421025532.916b1e2e.akpm@linux-foundation.org>
	<E1HfCzN-0002dZ-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: a.p.zijlstra@chello.nl, linux-mm@kvack.org, linux-kernel@vger.kernel.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

On Sat, 21 Apr 2007 12:38:45 +0200 Miklos Szeredi <miklos@szeredi.hu> wrote:

> The other deadlock, in throttle_vm_writeout() is still to be solved.

Let's go back to the original changelog:

Author: marcelo.tosatti <marcelo.tosatti>
Date:   Tue Mar 8 17:25:19 2005 +0000

    [PATCH] vm: pageout throttling
    
    With silly pageout testcases it is possible to place huge amounts of memory
    under I/O.  With a large request queue (CFQ uses 8192 requests) it is
    possible to place _all_ memory under I/O at the same time.
    
    This means that all memory is pinned and unreclaimable and the VM gets
    upset and goes oom.
    
    The patch limits the amount of memory which is under pageout writeout to be
    a little more than the amount of memory at which balance_dirty_pages()
    callers will synchronously throttle.
    
    This means that heavy pageout activity can starve heavy writeback activity
    completely, but heavy writeback activity will not cause starvation of
    pageout.  Because we don't want a simple `dd' to be causing excessive
    latencies in page reclaim.
    
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Linus Torvalds <torvalds@osdl.org>

(A good one!  I wrote it ;))


I believe that the combination of dirty-page-tracking and its calls to
balance_dirty_pages() mean that we can now never get more than dirty_ratio
of memory into the dirty-or-writeback condition.

The vm scanner can convert dirty pages into clean, under-writeback pages,
but it cannot increase the total of dirty+writeback.

Hence I assert that the problem which throttle_vm_writeout() was designed
to address can no longer happen, so we can simply remove it.

(There might be problems with ZONE_DMA or ZONE_NORMAL 100% full of
dirty+writeback pages, but throttle_vm_writeout() wont help in this case
anyway)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
