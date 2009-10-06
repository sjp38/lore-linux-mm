Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 31FDE6B004D
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 05:08:46 -0400 (EDT)
Subject: Re: [PATCH 2/2] mlock use lru_add_drain_all_async()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20091006114052.5FAA.A69D9226@jp.fujitsu.com>
References: <20091006112803.5FA5.A69D9226@jp.fujitsu.com>
	 <20091006114052.5FAA.A69D9226@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 06 Oct 2009 11:08:51 +0200
Message-Id: <1254820131.21044.126.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-10-06 at 11:41 +0900, KOSAKI Motohiro wrote:
> Recently, Peter Zijlstra reported RT-task can lead to prevent mlock
> very long time.
> 
>   Suppose you have 2 cpus, cpu1 is busy doing a SCHED_FIFO-99 while(1),
>   cpu0 does mlock()->lru_add_drain_all(), which does
>   schedule_on_each_cpu(), which then waits for all cpus to complete the
>   work. Except that cpu1, which is busy with the RT task, will never run
>   keventd until the RT load goes away.
> 
>   This is not so much an actual deadlock as a serious starvation case.
> 
> Actually, mlock() doesn't need to wait to finish lru_add_drain_all().
> Thus, this patch replace it with lru_add_drain_all_async().
> 
> Cc: Oleg Nesterov <onestero@redhat.com>
> Reported-by: Peter Zijlstra <a.p.zijlstra@chello.nl> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

It was actually Mike Galbraith who brought it to my attention.

Patch looks sane enough, altough I'm not sure I'd have split it in two
like you did (leaves the first without a real changelog too).



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
