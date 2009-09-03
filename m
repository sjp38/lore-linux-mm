Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 165AD6B005C
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 17:28:59 -0400 (EDT)
Date: Thu, 3 Sep 2009 14:28:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm][BUG] lockdep warning block I/O (Was Re: mmotm
 2009-08-27-16-51 uploaded
Message-Id: <20090903142836.fef35b23.akpm@linux-foundation.org>
In-Reply-To: <20090901180717.f707c58f.kamezawa.hiroyu@jp.fujitsu.com>
References: <200908272355.n7RNtghC019990@imap1.linux-foundation.org>
	<20090901180717.f707c58f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, jens.axboe@oracle.com, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, 1 Sep 2009 18:07:17 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> 
> Here is mmont-Aug27's lockdep wanring. This was printed out when oom-kill happens.
> I'm sorry if already fixed.

My life's project is to hunt down the guy who invented mail client
wordwrapping, set him on fire then dance on his ashes.

> =
> Sep  1 18:01:16 localhost kernel: [ 3012.503035] ======================================================
> Sep  1 18:01:16 localhost kernel: [ 3012.503039] [ INFO: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected ]
> Sep  1 18:01:16 localhost kernel: [ 3012.503042] 2.6.31-rc7-mm1 #3
> Sep  1 18:01:16 localhost kernel: [ 3012.503049] ------------------------------------------------------
> Sep  1 18:01:16 localhost kernel: [ 3012.503052] kblockd/7/350 [HC0[0]:SC0[0]:HE0:SE1] is trying to acquire:
> Sep  1 18:01:16 localhost kernel: [ 3012.503058]  (bdev_lock){+.+...}, at: [<ffffffff811458c7>] nr_blockdev_pages+0x1
> 7/0x80
> Sep  1 18:01:16 localhost kernel: [ 3012.503069]
> Sep  1 18:01:16 localhost kernel: [ 3012.503070] and this task is already holding:
> Sep  1 18:01:16 localhost kernel: [ 3012.503075]  (&q->__queue_lock){..-.-.}, at: [<ffffffff811e9ff8>] cfq_kick_queue
> +0x28/0x50
> Sep  1 18:01:16 localhost kernel: [ 3012.503083] which would create a new lock dependency:
> Sep  1 18:01:16 localhost kernel: [ 3012.503087]  (&q->__queue_lock){..-.-.} -> (bdev_lock){+.+...}
> Sep  1 18:01:16 localhost kernel: [ 3012.503100]

I'd say the core problem here is that __alloc_pages_slowpath() is
calling show_mem().  Because show_mem() is a "high level" function which
takes "high level" locks.  ie: bdev_lock.

It's inappropriate that alloc_pages() is assuming that it is safe to
call show_mem() from all contexts in which alloc_pages() might be
called.

That show_mem() call has been there since 2005, so I don't know what
caused this to be revealed now.

It's not at all a serious bug and the chances of us deadlocking the
kernel here are close to zero.  An appropriate fix would be to replace
that show_mem() call with something which can be safely called from all
contexts in which the page allocator can be called.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
