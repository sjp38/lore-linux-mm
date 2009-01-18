Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C9C466B009D
	for <linux-mm@kvack.org>; Sat, 17 Jan 2009 21:36:24 -0500 (EST)
Date: Sun, 18 Jan 2009 03:32:11 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v3] wait: prevent waiter starvation in
	__wait_on_bit_lock
Message-ID: <20090118023211.GA14539@redhat.com>
References: <20090117215110.GA3300@redhat.com> <20090118013802.GA12214@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090118013802.GA12214@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Matthew Wilcox <matthew@wil.cx>, Chuck Lever <cel@citi.umich.edu>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 01/18, Johannes Weiner wrote:
>
> On Sat, Jan 17, 2009 at 10:51:10PM +0100, Oleg Nesterov wrote:
> >
> > 	if ((ret = (*action)(q->key.flags))) {
> > 		__wake_up_bit(wq, q->key.flags, q->key.bit_nr);
> > 		// or just __wake_up(wq, TASK_NORMAL, 1, &q->key);
> > 		break;
> > 	}
> >
> > IOW, imho __wait_on_bit_lock() is buggy, not __lock_page_killable(),
> > no?
>
> I agree with you, already replied with a patch to linux-mm where Chris
> posted it originally.
>
> Peter noted that we have a spurious wake up in the case where A holds
> the page lock, B and C wait, B gets killed and does a wake up, then A
> unlocks and does a wake up.  Your proposal has this problem too,
> right?

Yes sure. But I can't see how it is possible to avoid the false
wakeup for sure, please see below.

> @@ -182,8 +182,20 @@ __wait_on_bit_lock(wait_queue_head_t *wq
>  	do {
>  		prepare_to_wait_exclusive(wq, &q->wait, mode);
>  		if (test_bit(q->key.bit_nr, q->key.flags)) {
> -			if ((ret = (*action)(q->key.flags)))
> +			ret = action(q->key.flags);
> +			if (ret) {
> +				/*
> +				 * Contenders are woken exclusively.  If
> +				 * we do not take the lock when woken up
> +				 * from an unlock, we have to make sure to
> +				 * wake the next waiter in line or noone
> +				 * will and shkle will wait forever.
> +				 */
> +				if (!test_bit(q->key.bit_nr, q->key.flags))
> +					__wake_up_bit(wq, q->key.flags,

Afaics, the spurious wake up is still possible if SIGKILL and
unlock_page() happen "at the same time".

	__wait_on_bit_lock:			unlock_page:

						clear_bit_unlock()
	test_bit() == T

	__wake_up_bit()				wake_up_page()

Note that sync_page_killable() returns with ->state == TASK_RUNNING,
__wake_up() will "ignore" us.

But, more importantly, I'm afraid we can also have the false negative,
this "if (!test_bit())" test lacks the barriers. This can't happen with
sync_page_killable() because it always calls schedule(). But let's
suppose we modify it to check signal_pending() first:

	static int sync_page_killable(void *word)
	{
		if (fatal_signal_pending(current))
			return -EINTR;
		return sync_page(word);
	}

It is still correct, but unless I missed something now __wait_on_bit_lock()
has problems again.

But don't get me wrong, I think you are right and it is better to minimize
the possibility of the false wakeup.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
