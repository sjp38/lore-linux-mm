Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 73CCF6B01B2
	for <linux-mm@kvack.org>; Sun, 27 Jun 2010 22:22:04 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5S2M1KY020366
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 28 Jun 2010 11:22:01 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F268F45DE5F
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 11:22:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7356145DE54
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 11:22:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D4E311DB8054
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 11:21:59 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 49B471DB805B
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 11:21:59 +0900 (JST)
Date: Mon, 28 Jun 2010 11:17:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [S+Q 01/16] [PATCH] ipc/sem.c: Bugfix for semop() not reporting
 successful operation
Message-Id: <20100628111731.18f1f858.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100625212101.622422748@quilx.com>
References: <20100625212026.810557229@quilx.com>
	<20100625212101.622422748@quilx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Manfred Spraul <manfred@colorfullife.com>, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Fri, 25 Jun 2010 16:20:27 -0500
Christoph Lameter <cl@linux-foundation.org> wrote:

> [Necessary to make 2.6.35-rc3 not deadlock. Not sure if this is the "right"(tm)
> fix]
> 
> The last change to improve the scalability moved the actual wake-up out of
> the section that is protected by spin_lock(sma->sem_perm.lock).
> 
> This means that IN_WAKEUP can be in queue.status even when the spinlock is
> acquired by the current task. Thus the same loop that is performed when
> queue.status is read without the spinlock acquired must be performed when
> the spinlock is acquired.
> 
> Signed-off-by: Manfred Spraul <manfred@colorfullife.com>
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>


Hmm, I'm sorry if I don't understand the code...

> 
> ---
>  ipc/sem.c |   36 ++++++++++++++++++++++++++++++------
>  1 files changed, 30 insertions(+), 6 deletions(-)
> 
> diff --git a/ipc/sem.c b/ipc/sem.c
> index 506c849..523665f 100644
> --- a/ipc/sem.c
> +++ b/ipc/sem.c
> @@ -1256,6 +1256,32 @@ out:
>  	return un;
>  }
>  
> +
> +/** get_queue_result - Retrieve the result code from sem_queue
> + * @q: Pointer to queue structure
> + *
> + * The function retrieve the return code from the pending queue. If 
> + * IN_WAKEUP is found in q->status, then we must loop until the value
> + * is replaced with the final value: This may happen if a task is
> + * woken up by an unrelated event (e.g. signal) and in parallel the task
> + * is woken up by another task because it got the requested semaphores.
> + *
> + * The function can be called with or without holding the semaphore spinlock.
> + */
> +static int get_queue_result(struct sem_queue *q)
> +{
> +	int error;
> +
> +	error = q->status;
> +	while(unlikely(error == IN_WAKEUP)) {
> +		cpu_relax();
> +		error = q->status;
> +	}
> +
> +	return error;
> +}

no memory barrier is required ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
