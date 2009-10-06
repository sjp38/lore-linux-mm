Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id F0ED86B004D
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 12:33:32 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 889B682C3AD
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 12:37:11 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 48WWk-LKcBCK for <linux-mm@kvack.org>;
	Tue,  6 Oct 2009 12:37:11 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 42EB182C280
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 12:36:57 -0400 (EDT)
Date: Tue, 6 Oct 2009 12:27:27 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/2] mlock use lru_add_drain_all_async()
In-Reply-To: <20091006114052.5FAA.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0910061226300.18309@gentwo.org>
References: <20091006112803.5FA5.A69D9226@jp.fujitsu.com> <20091006114052.5FAA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Oleg Nesterov <oleg@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 6 Oct 2009, KOSAKI Motohiro wrote:

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

Ok so this will queue up lots of events for the cpu doing a RT task. If
the RT task is continuous then they will be queued there forever?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
