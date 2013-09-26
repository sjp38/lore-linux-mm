Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6C3D86B0037
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 02:53:50 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so719905pbb.19
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 23:53:50 -0700 (PDT)
Received: by mail-ee0-f51.google.com with SMTP id c1so301945eek.10
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 23:53:46 -0700 (PDT)
Date: Thu, 26 Sep 2013 08:53:35 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v6 6/6] rwsem: do optimistic spinning for writer lock
 acquisition
Message-ID: <20130926065335.GC19090@gmail.com>
References: <cover.1380144003.git.tim.c.chen@linux.intel.com>
 <1380147051.3467.68.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1380147051.3467.68.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>


* Tim Chen <tim.c.chen@linux.intel.com> wrote:

> We want to add optimistic spinning to rwsems because
> the writer rwsem does not perform as well as mutexes. Tim noticed that
> for exim (mail server) workloads, when reverting commit 4fc3f1d6 and
> Davidlohr noticed it when converting the i_mmap_mutex to a rwsem in some
> aim7 workloads. We've noticed that the biggest difference
> is when we fail to acquire a mutex in the fastpath, optimistic spinning
> comes in to play and we can avoid a large amount of unnecessary sleeping
> and overhead of moving tasks in and out of wait queue.
> 
> Allowing optimistic spinning before putting the writer on the wait queue
> reduces wait queue contention and provided greater chance for the rwsem
> to get acquired. With these changes, rwsem is on par with mutex.
> 
> Reviewed-by: Ingo Molnar <mingo@elte.hu>
> Reviewed-by: Peter Zijlstra <peterz@infradead.org>
> Reviewed-by: Peter Hurley <peter@hurleysoftware.com>
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> ---
>  include/linux/rwsem.h |    6 +-
>  kernel/rwsem.c        |   19 +++++-
>  lib/rwsem.c           |  203 ++++++++++++++++++++++++++++++++++++++++++++-----
>  3 files changed, 207 insertions(+), 21 deletions(-)
> 
> diff --git a/include/linux/rwsem.h b/include/linux/rwsem.h
> index 0616ffe..ef5a83a 100644
> --- a/include/linux/rwsem.h
> +++ b/include/linux/rwsem.h
> @@ -26,6 +26,8 @@ struct rw_semaphore {
>  	long			count;
>  	raw_spinlock_t		wait_lock;
>  	struct list_head	wait_list;
> +	struct task_struct	*owner; /* write owner */
> +	void			*spin_mlock;

> +#define MLOCK(rwsem)    ((struct mcs_spin_node **)&((rwsem)->spin_mlock))

> +		mcs_spin_lock(MLOCK(sem), &node);

> +			mcs_spin_unlock(MLOCK(sem), &node);

> +			mcs_spin_unlock(MLOCK(sem), &node);

> +		mcs_spin_unlock(MLOCK(sem), &node);

That forced type casting is ugly and fragile.

To avoid having to include mcslock.h into rwsem.h just add a forward 
struct declaration, before the struct rw_semaphore definition:

struct mcs_spin_node;

Then define spin_mlock with the right type:

	struct mcs_spin_node		*spin_mlock;

I'd also suggest renaming 'spin_mlock', to reduce unnecessary variants. If 
the lock type name is 'struct mcs_spin_node' then 'mcs_lock' would be a 
perfect field name, right?

While at it, renaming mcs_spin_node to mcs_spinlock might be wise as well, 
and the include file would be named mcs_spinlock.h.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
