Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9CCB16B003D
	for <linux-mm@kvack.org>; Mon,  9 Feb 2009 22:56:26 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] mm fix page writeback accounting to fix oom condition under heavy I/O
Date: Tue, 10 Feb 2009 14:55:55 +1100
References: <20090120122855.GF30821@kernel.dk> <20090123220009.34DF.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090210033652.GA28435@Krystal>
In-Reply-To: <20090210033652.GA28435@Krystal>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902101455.56789.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jens Axboe <jens.axboe@oracle.com>, akpm@linux-foundation.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, thomas.pi@arcor.dea, Yuriy Lalym <ylalym@gmail.com>, ltt-dev@lists.casi.polymtl.ca, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 10 February 2009 14:36:53 Mathieu Desnoyers wrote:
> Related to :
> http://bugzilla.kernel.org/show_bug.cgi?id=12309
>
> Very annoying I/O latencies (20-30 seconds) are occuring under heavy I/O
> since ~2.6.18.
>
> Yuriy Lalym noticed that the oom killer was eventually called. So I took a
> look at /proc/meminfo and noticed that under my test case (fio job created
> from a LTTng block I/O trace, reproducing dd writing to a 20GB file and ssh
> sessions being opened), the Inactive(file) value increased, and the total
> memory consumed increased until only 80kB (out of 16GB) were left.
>
> So I first used cgroups to limit the memory usable by fio (or dd). This
> seems to fix the problem.
>
> Thomas noted that there seems to be a problem with pages being passed to
> the block I/O elevator not being counted as dirty. I looked at
> clear_page_dirty_for_io and noticed that page_mkclean clears the dirty bit
> and then set_page_dirty(page) is called on the page. This calls
> mm/page-writeback.c:set_page_dirty(). I assume that the
> mapping->a_ops->set_page_dirty is NULL, so it calls
> buffer.c:__set_page_dirty_buffers(). This calls set_buffer_dirty(bh).
>
> So we come back in clear_page_dirty_for_io where we decrement the dirty
> accounting. This is a problem, because we assume that the block layer will
> re-increment it when it gets the page, but because the buffer is marked as
> dirty, this won't happen.
>
> So this patch fixes this behavior by only decrementing the page accounting
> _after_ the block I/O writepage has been done.
>
> The effect on my workload is that the memory stops being completely filled
> by page cache under heavy I/O. The vfs_cache_pressure value seems to work
> again.

I don't think we're supposed to assume the block layer will re-increment
the dirty count? It should be all in the VM. And the VM should increment
writeback count before sending it to the block device, and dirty page
throttling also takes into account the number of writeback pages, so it
should not be allowed to fill up memory with dirty pages even if the
block device queue size is unlimited.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
