In-reply-to: <20071004145640.18ced770.akpm@linux-foundation.org> (message from
	Andrew Morton on Thu, 4 Oct 2007 14:56:40 -0700)
Subject: Re: [PATCH] remove throttle_vm_writeout()
References: <E1IdPla-0002Bd-00@dorka.pomaz.szeredi.hu> <20071004145640.18ced770.akpm@linux-foundation.org>
Message-Id: <E1IdZLg-0002Wr-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Fri, 05 Oct 2007 00:39:16 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: miklos@szeredi.hu, wfg@mail.ustc.edu.cn, a.p.zijlstra@chello.nl, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> None of the above.
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
> afaict that problem is still there.  It is possible to get all of
> ZONE_NORMAL dirty on a highmem machine.  With a large queue (or lots of
> queues), vmscan can them place all of ZONE_NORMAL under IO.
> 
> It could be that we've fixed this problem via other means in the interrim,
> but from a quick peek to seems to me that the scanner will still do a 100%
> CPU burn when all of a zone's pages are under writeback.

Ah, OK.

I did read the changelog, but you added quite a bit of translation ;)

> throttle_vm_writeout() should be a per-zone thing, I guess.  Perhaps fixing
> that would fix your deadlock.  That's doubtful, but I don't know anything
> about your deadlock so I cannot say.

No, doing the throttling per-zone won't in itself fix the deadlock.

Here's a deadlock example:

Total memory = 32M
/proc/sys/vm/dirty_ratio = 10
dirty_threshold = 3M
ratelimit_pages = 1M

Some program dirties 4M (dirty_threshold + ratelimit_pages) of mmap on
a fuse fs.  Page balancing is called which turns all these into
writeback pages.

Then userspace filesystem gets a write request, and tries to allocate
memory needed to complete the writeout.

That will possibly trigger direct reclaim, and throttle_vm_writeout()
will be called.  That will block until nr_writeback goes below 3.3M
(dirty_threshold + 10%).  But since all 4M of writeback is from the
fuse fs, that will never happen.

Does that explain it better?

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
