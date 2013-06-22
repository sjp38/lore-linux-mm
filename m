Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id B6F9A6B0031
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 20:10:33 -0400 (EDT)
Message-ID: <51C4EB63.2000104@intel.com>
Date: Sat, 22 Jun 2013 08:10:11 +0800
From: Alex Shi <alex.shi@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] rwsem: check the lock before cpmxchg in down_write_trylock
 and rwsem_do_wake
References: <cover.1371855277.git.tim.c.chen@linux.intel.com> <1371858695.22432.4.camel@schen9-DESK>
In-Reply-To: <1371858695.22432.4.camel@schen9-DESK>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On 06/22/2013 07:51 AM, Tim Chen wrote:
> Doing cmpxchg will cause cache bouncing when checking
> sem->count. This could cause scalability issue
> in a large machine (e.g. a 80 cores box).
> 
> A pre-read of sem->count can mitigate this.
> 
> Signed-off-by: Alex Shi <alex.shi@intel.com>
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>

Hi Tim,
there is a technical error in this patch.
the "From: " line should be 'Alex Shi', since he made the most input of
this patch.

And I still think split this patch to 4 smaller will make it more simple
to review, that I had sent you and Davidlohr.

could you like to re-send with my 4 patch version? :)

> ---
>  include/asm-generic/rwsem.h |    8 ++++----
>  lib/rwsem.c                 |   21 +++++++++++++--------
>  2 files changed, 17 insertions(+), 12 deletions(-)
> 
> diff --git a/include/asm-generic/rwsem.h b/include/asm-generic/rwsem.h
> index bb1e2cd..052d973 100644
> --- a/include/asm-generic/rwsem.h
> +++ b/include/asm-generic/rwsem.h
> @@ -70,11 +70,11 @@ static inline void __down_write(struct rw_semaphore *sem)
>  
>  static inline int __down_write_trylock(struct rw_semaphore *sem)
>  {
> -	long tmp;
> +	if (unlikely(&sem->count != RWSEM_UNLOCKED_VALUE))
> +		return 0;
>  
> -	tmp = cmpxchg(&sem->count, RWSEM_UNLOCKED_VALUE,
> -		      RWSEM_ACTIVE_WRITE_BIAS);
> -	return tmp == RWSEM_UNLOCKED_VALUE;
> +	return cmpxchg(&sem->count, RWSEM_UNLOCKED_VALUE,
> +		RWSEM_ACTIVE_WRITE_BIAS) == RWSEM_UNLOCKED_VALUE;
>  }
>  
>  /*
> diff --git a/lib/rwsem.c b/lib/rwsem.c
> index 19c5fa9..2072af5 100644
> --- a/lib/rwsem.c
> +++ b/lib/rwsem.c
> @@ -75,7 +75,7 @@ __rwsem_do_wake(struct rw_semaphore *sem, enum rwsem_wake_type wake_type)
>  			 * will block as they will notice the queued writer.
>  			 */
>  			wake_up_process(waiter->task);
> -		goto out;
> +		return sem;
>  	}
>  
>  	/* Writers might steal the lock before we grant it to the next reader.
> @@ -85,15 +85,21 @@ __rwsem_do_wake(struct rw_semaphore *sem, enum rwsem_wake_type wake_type)
>  	adjustment = 0;
>  	if (wake_type != RWSEM_WAKE_READ_OWNED) {
>  		adjustment = RWSEM_ACTIVE_READ_BIAS;
> - try_reader_grant:
> -		oldcount = rwsem_atomic_update(adjustment, sem) - adjustment;
> -		if (unlikely(oldcount < RWSEM_WAITING_BIAS)) {
> -			/* A writer stole the lock. Undo our reader grant. */
> +		while (1) {
> +			/* A writer stole the lock. */
> +			if (sem->count < RWSEM_WAITING_BIAS)
> +				return sem;
> +
> +			oldcount = rwsem_atomic_update(adjustment, sem)
> +								- adjustment;
> +			if (likely(oldcount >= RWSEM_WAITING_BIAS))
> +				break;
> +
> +			 /* A writer stole the lock.  Undo our reader grant. */
>  			if (rwsem_atomic_update(-adjustment, sem) &
>  						RWSEM_ACTIVE_MASK)
> -				goto out;
> +				return sem;
>  			/* Last active locker left. Retry waking readers. */
> -			goto try_reader_grant;
>  		}
>  	}
>  
> @@ -136,7 +142,6 @@ __rwsem_do_wake(struct rw_semaphore *sem, enum rwsem_wake_type wake_type)
>  	sem->wait_list.next = next;
>  	next->prev = &sem->wait_list;
>  
> - out:
>  	return sem;
>  }
>  
> 


-- 
Thanks
    Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
