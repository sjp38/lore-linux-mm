Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2AB8D6B0047
	for <linux-mm@kvack.org>; Tue, 27 Jan 2009 15:10:53 -0500 (EST)
Date: Tue, 27 Jan 2009 21:05:44 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC v6] wait: prevent exclusive waiter starvation
Message-ID: <20090127200544.GA28843@redhat.com>
References: <20090120203131.GA20985@cmpxchg.org> <20090121143602.GA16584@redhat.com> <20090121213813.GB23270@cmpxchg.org> <20090122202550.GA5726@redhat.com> <20090123095904.GA22890@cmpxchg.org> <20090123113541.GB12684@redhat.com> <20090123133050.GA19226@redhat.com> <20090126215957.GA3889@cmpxchg.org> <20090127032359.GA17359@redhat.com> <20090127193434.GA19673@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090127193434.GA19673@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Matthew Wilcox <matthew@wil.cx>, Chuck Lever <cel@citi.umich.edu>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On 01/27, Johannes Weiner wrote:
>
> +void abort_exclusive_wait(wait_queue_head_t *q, wait_queue_t *wait)
> +{
> +	unsigned long flags;
> +
> +	__set_current_state(TASK_RUNNING);
> +	spin_lock_irqsave(&q->lock, flags);
> +	if (list_empty(&wait->task_list))

Hmm... it should be !list_empty() ?

> +		list_del_init(&wait->task_list);
> +	/*
> +	 * If we were woken through the waitqueue (waker removed
> +	 * us from the list) we must ensure the next waiter down
> +	 * the line is woken up.  The callsite will not do it as
> +	 * it didn't finish waiting successfully.
> +	 */
> +	else if (waitqueue_active(q))
> +		__wake_up_locked(q, TASK_INTERRUPTIBLE);
> +	spin_unlock_irqrestore(&q->lock, flags);
> +}

Well, personally I don't care, but this is against CodingStyle rules ;)

>  int autoremove_wake_function(wait_queue_t *wait, unsigned mode, int sync, void *key)
>  {
>  	int ret = default_wake_function(wait, mode, sync, key);
> @@ -177,17 +218,19 @@ int __sched
>  __wait_on_bit_lock(wait_queue_head_t *wq, struct wait_bit_queue *q,
>  			int (*action)(void *), unsigned mode)
>  {
> -	int ret = 0;
> -
>  	do {
> +		int ret;
> +
>  		prepare_to_wait_exclusive(wq, &q->wait, mode);
> -		if (test_bit(q->key.bit_nr, q->key.flags)) {
> -			if ((ret = (*action)(q->key.flags)))
> -				break;
> -		}
> +		if (!test_bit(q->key.bit_nr, q->key.flags))
> +			continue;
> +		if (!(ret = action(q->key.flags)))
> +			continue;
> +		abort_exclusive_wait(wq, &q->wait);

No, no. We should use the same key in abort_exclusive_wait().
Otherwise, how can we wakeup the next waiter which needs this
bit in the same page->flags?

That is why I suggested finish_wait_exclusive(..., void *key)
which should we passed to __wake_up_common().

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
