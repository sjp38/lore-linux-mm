Date: Tue, 23 Dec 2003 17:14:07 +0100
From: Roger Luethi <rl@hellgate.ch>
Subject: Re: load control demotion/promotion policy
Message-ID: <20031223161407.GC6082@k3.hellgate.ch>
References: <Pine.LNX.4.44.0312202125580.26393-100000@chimarrao.boston.redhat.com> <20031221235541.GA22896@k3.hellgate.ch> <20031221225611.5421b522.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20031221225611.5421b522.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: riel@redhat.com, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 21 Dec 2003 22:56:11 -0800, Andrew Morton wrote:
> But I have vague memories of being dazed and confused when last you tried
> to describe the causes.  I was hoping that things would firm up a bit.
> 
> Please, take the time to describe it to us again, exhaustively.

Sorry, I wouldn't do anyone a favor if I added more speculation. I'm
progressing slowly due to other tasks, but the benchmark data is
rather solid and can serve as a map for others to determine the cause
of regressions.

Here's one thing that might be interesting, though:

I explained recently on LKML that the kswap throttling patch of
2.6.0-test3 I reverted makes kswapd do virtually all the paging,
while previous (faster) kernels relied heavily on the path through the
page allocator to free memory. Remember the tiny patch I circulated in
early October, before I started systematically benchmarking the whole
devel series?

It looked like this (against test6):

+++ ./mm/vmscan.c	2003-10-02 23:30:59.423106182 +0200
@@ -1037,7 +1037,7 @@ int kswapd(void *p)
 		if (current->flags & PF_FREEZE)
 			refrigerator(PF_IOTHREAD);
 		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
-		schedule();
+		sys_sched_yield();
 		finish_wait(&pgdat->kswapd_wait, &wait);
 		get_page_state(&ps);
 		balance_pgdat(pgdat, 0, &ps);

This patch did pretty well with kbuild, but not with qsbench. Back then
I dropped the patch because of that. In the meantime I realized that
qsbench and the compile benchmarks are separate and rarely agree on
what's good. In fact, usually the best you can get is an improvement
for one type of benchmarks and no regression with the other. Check the
graph I posted, you'll see what I mean.

The kswapd/priority patch I posted (and the one above IIRC, I'd have
to repeat those benchmarks as well to be sure) accomplishes that
pretty much.

The reason I mention this old patch: If you compare the old patch above
with the kswapd/priority reversal patches I posted and discussed on
LKML, you'll notice that they have something in common: Slow down kswapd
freeing in favor of freeing by allocator. Seems to be a common theme.
I could speculate about the reasons, but I didn't have the time to test
any theories.

Roger
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
