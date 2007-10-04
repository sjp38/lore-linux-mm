Date: Thu, 4 Oct 2007 14:56:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] remove throttle_vm_writeout()
Message-Id: <20071004145640.18ced770.akpm@linux-foundation.org>
In-Reply-To: <E1IdPla-0002Bd-00@dorka.pomaz.szeredi.hu>
References: <E1IdPla-0002Bd-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: wfg@mail.ustc.edu.cn, a.p.zijlstra@chello.nl, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 04 Oct 2007 14:25:22 +0200
Miklos Szeredi <miklos@szeredi.hu> wrote:

> From: Miklos Szeredi <mszeredi@suse.cz>
> 
> By relying on the global diry limits, this can cause a deadlock when
> devices are stacked.
> 
> If the stacking is done through a fuse filesystem, the __GFP_FS,
> __GFP_IO tests won't help: the process doing the allocation doesn't
> have any special flag.

This description of the bug-which-is-being-fixed is nowhere near adequate
enough for a reviewer to understand the problem.  This makes it hard to
suggest alternative fixes.

> So why exactly does this function exist?

That's described in the changelog for the patch which added
throttle_vm_writeout().  Unsurprisingly ;)

> Direct reclaim does not _increase_ the number of dirty pages in the
> system, so rate limiting it seems somewhat pointless.
> 
> There are two cases:
> 
> 1) File backed pages -> file
> 
>   dirty + writeback count remains constant
> 
> 2) Anonymous pages -> swap
> 
>   writeback count increases, dirty balancing will hold back file
>   writeback in favor of swap
> 
> So the real question is: does case 2 need rate limiting, or is it OK
> to let the device queue fill with swap pages as fast as possible?

None of the above.

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

afaict that problem is still there.  It is possible to get all of
ZONE_NORMAL dirty on a highmem machine.  With a large queue (or lots of
queues), vmscan can them place all of ZONE_NORMAL under IO.

It could be that we've fixed this problem via other means in the interrim,
but from a quick peek to seems to me that the scanner will still do a 100%
CPU burn when all of a zone's pages are under writeback.

throttle_vm_writeout() should be a per-zone thing, I guess.  Perhaps fixing
that would fix your deadlock.  That's doubtful, but I don't know anything
about your deadlock so I cannot say.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
