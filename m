Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4ECE56B0044
	for <linux-mm@kvack.org>; Mon, 26 Jan 2009 22:29:57 -0500 (EST)
Date: Tue, 27 Jan 2009 04:23:59 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC v5] wait: prevent exclusive waiter starvation
Message-ID: <20090127032359.GA17359@redhat.com>
References: <20090118013802.GA12214@cmpxchg.org> <20090118023211.GA14539@redhat.com> <20090120203131.GA20985@cmpxchg.org> <20090121143602.GA16584@redhat.com> <20090121213813.GB23270@cmpxchg.org> <20090122202550.GA5726@redhat.com> <20090123095904.GA22890@cmpxchg.org> <20090123113541.GB12684@redhat.com> <20090123133050.GA19226@redhat.com> <20090126215957.GA3889@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090126215957.GA3889@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Matthew Wilcox <matthew@wil.cx>, Chuck Lever <cel@citi.umich.edu>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On 01/26, Johannes Weiner wrote:
>
> Another iteration.  I didn't use a general finish_wait_exclusive() but
> a version of this function that just returns whether we were woken
> through the queue or not.

But if your helper (finish_wait_woken) returns true, we always need
to wakeup the next waiter, or we don't need to use it. So why not
place the wakeup in the helper itself?

> --- a/include/linux/wait.h
> +++ b/include/linux/wait.h
> @@ -333,16 +333,20 @@ do {									\
>  	for (;;) {							\
>  		prepare_to_wait_exclusive(&wq, &__wait,			\
>  					TASK_INTERRUPTIBLE);		\
> -		if (condition)						\
> +		if (condition) {					\
> +			finish_wait(&wq, &__wait);			\
>  			break;						\
> +		}							\
>  		if (!signal_pending(current)) {				\
>  			schedule();					\
>  			continue;					\
>  		}							\
>  		ret = -ERESTARTSYS;					\
> +		if (finish_wait_woken(&wq, &__wait))			\
> +			__wake_up_common(&wq, TASK_INTERRUPTIBLE,	\

No, we can't use __wake_up_common() without wq->lock.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
