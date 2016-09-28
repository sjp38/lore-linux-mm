Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E288E28024E
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 06:45:03 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b130so36220648wmc.2
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 03:45:03 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id jd5si7870850wjb.63.2016.09.28.03.45.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Sep 2016 03:45:02 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 395EF98FD4
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 10:45:02 +0000 (UTC)
Date: Wed, 28 Sep 2016 11:45:00 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: page_waitqueue() considered harmful
Message-ID: <20160928104500.GC3903@techsingularity.net>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
 <20160927083104.GC2838@techsingularity.net>
 <20160927143426.GP2794@worktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160927143426.GP2794@worktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On Tue, Sep 27, 2016 at 04:34:26PM +0200, Peter Zijlstra wrote:
> On Tue, Sep 27, 2016 at 09:31:04AM +0100, Mel Gorman wrote:
> > page_waitqueue() has been a hazard for years. I think the last attempt to
> > fix it was back in 2014 http://www.spinics.net/lists/linux-mm/msg73207.html
> > 
> > The patch is heavily derived from work by Nick Piggin who noticed the years
> > before that. I think that was the last version I posted and the changelog
> > includes profile data. I don't have an exact reference why it was rejected
> > but a consistent piece of feedback was that it was very complex for the
> > level of impact it had.
> 
> Right, I never really liked that patch. In any case, the below seems to
> boot, although the lock_page_wait() thing did get my brain in a bit of a
> twist. Doing explicit loops with PG_contended inside wq->lock would be
> more obvious but results in much more code.
> 
> We could muck about with PG_contended naming/placement if any of this
> shows benefit.
> 
> It does boot on my x86_64 and builds a kernel, so it must be perfect ;-)
> 

Heh.

tldr: Other than 32-bit vs 64-bit, I could not find anything obviously wrong.

> ---
>  include/linux/page-flags.h     |  2 ++
>  include/linux/pagemap.h        | 21 +++++++++----
>  include/linux/wait.h           |  2 +-
>  include/trace/events/mmflags.h |  1 +
>  kernel/sched/wait.c            | 17 ++++++----
>  mm/filemap.c                   | 71 ++++++++++++++++++++++++++++++++++++------
>  6 files changed, 92 insertions(+), 22 deletions(-)
> 
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 74e4dda..0ed3900 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -73,6 +73,7 @@
>   */
>  enum pageflags {
>  	PG_locked,		/* Page is locked. Don't touch. */
> +	PG_contended,		/* Page lock is contended. */
>  	PG_error,
>  	PG_referenced,
>  	PG_uptodate,

Naming has been covered by Nick. You may run into the same problem with
32-bit and available page flags. I didn't work out the remaining number
of flags but did you check 32-bit is ok? If not, you may need to take a
similar approach that I did that says "there are always waiters and use
the slow path on 32-bit".

> @@ -253,6 +254,7 @@ static inline int TestClearPage##uname(struct page *page) { return 0; }
>  	TESTSETFLAG_FALSE(uname) TESTCLEARFLAG_FALSE(uname)
>  
>  __PAGEFLAG(Locked, locked, PF_NO_TAIL)
> +PAGEFLAG(Contended, contended, PF_NO_TAIL)
>  PAGEFLAG(Error, error, PF_NO_COMPOUND) TESTCLEARFLAG(Error, error, PF_NO_COMPOUND)
>  PAGEFLAG(Referenced, referenced, PF_HEAD)
>  	TESTCLEARFLAG(Referenced, referenced, PF_HEAD)
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 66a1260..3b38a96 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -417,7 +417,7 @@ extern void __lock_page(struct page *page);
>  extern int __lock_page_killable(struct page *page);
>  extern int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
>  				unsigned int flags);
> -extern void unlock_page(struct page *page);
> +extern void __unlock_page(struct page *page);
>  
>  static inline int trylock_page(struct page *page)
>  {
> @@ -448,6 +448,16 @@ static inline int lock_page_killable(struct page *page)
>  	return 0;
>  }
>  
> +static inline void unlock_page(struct page *page)
> +{
> +	page = compound_head(page);
> +	VM_BUG_ON_PAGE(!PageLocked(page), page);
> +	clear_bit_unlock(PG_locked, &page->flags);
> +	smp_mb__after_atomic();
> +	if (PageContended(page))
> +		__unlock_page(page);
> +}
> +

The main race to be concerned with is PageContended being set after the
page is unlocked and missing a wakeup here. While you explain the protocol
later, it's worth referencing it here.

>  /*
>   * lock_page_or_retry - Lock the page, unless this would block and the
>   * caller indicated that it can handle a retry.
> @@ -472,11 +482,11 @@ extern int wait_on_page_bit_killable(struct page *page, int bit_nr);
>  extern int wait_on_page_bit_killable_timeout(struct page *page,
>  					     int bit_nr, unsigned long timeout);
>  
> +extern int wait_on_page_lock(struct page *page, int mode);
> +
>  static inline int wait_on_page_locked_killable(struct page *page)
>  {
> -	if (!PageLocked(page))
> -		return 0;
> -	return wait_on_page_bit_killable(compound_head(page), PG_locked);
> +	return wait_on_page_lock(page, TASK_KILLABLE);
>  }
>  

Ok, I raised an eyebrow at compound_head but it's covered in the helper.

>  extern wait_queue_head_t *page_waitqueue(struct page *page);
> @@ -494,8 +504,7 @@ static inline void wake_up_page(struct page *page, int bit)
>   */
>  static inline void wait_on_page_locked(struct page *page)
>  {
> -	if (PageLocked(page))
> -		wait_on_page_bit(compound_head(page), PG_locked);
> +	wait_on_page_lock(page, TASK_UNINTERRUPTIBLE);
>  }
>  
>  /* 
> diff --git a/include/linux/wait.h b/include/linux/wait.h
> index c3ff74d..524cd54 100644
> --- a/include/linux/wait.h
> +++ b/include/linux/wait.h
> @@ -198,7 +198,7 @@ __remove_wait_queue(wait_queue_head_t *head, wait_queue_t *old)
>  
>  typedef int wait_bit_action_f(struct wait_bit_key *, int mode);
>  void __wake_up(wait_queue_head_t *q, unsigned int mode, int nr, void *key);
> -void __wake_up_locked_key(wait_queue_head_t *q, unsigned int mode, void *key);
> +int __wake_up_locked_key(wait_queue_head_t *q, unsigned int mode, void *key);
>  void __wake_up_sync_key(wait_queue_head_t *q, unsigned int mode, int nr, void *key);
>  void __wake_up_locked(wait_queue_head_t *q, unsigned int mode, int nr);
>  void __wake_up_sync(wait_queue_head_t *q, unsigned int mode, int nr);
> diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
> index 5a81ab4..18b8398 100644
> --- a/include/trace/events/mmflags.h
> +++ b/include/trace/events/mmflags.h
> @@ -81,6 +81,7 @@
>  
>  #define __def_pageflag_names						\
>  	{1UL << PG_locked,		"locked"	},		\
> +	{1UL << PG_contended,		"contended"	},		\
>  	{1UL << PG_error,		"error"		},		\
>  	{1UL << PG_referenced,		"referenced"	},		\
>  	{1UL << PG_uptodate,		"uptodate"	},		\
> diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
> index f15d6b6..46dcc42 100644
> --- a/kernel/sched/wait.c
> +++ b/kernel/sched/wait.c
> @@ -62,18 +62,23 @@ EXPORT_SYMBOL(remove_wait_queue);
>   * started to run but is not in state TASK_RUNNING. try_to_wake_up() returns
>   * zero in this (rare) case, and we handle it by continuing to scan the queue.
>   */
> -static void __wake_up_common(wait_queue_head_t *q, unsigned int mode,
> +static int __wake_up_common(wait_queue_head_t *q, unsigned int mode,
>  			int nr_exclusive, int wake_flags, void *key)
>  {
>  	wait_queue_t *curr, *next;
> +	int woken = 0;
>  
>  	list_for_each_entry_safe(curr, next, &q->task_list, task_list) {
>  		unsigned flags = curr->flags;
>  
> -		if (curr->func(curr, mode, wake_flags, key) &&
> -				(flags & WQ_FLAG_EXCLUSIVE) && !--nr_exclusive)
> -			break;
> +		if (curr->func(curr, mode, wake_flags, key)) {
> +			woken++;
> +			if ((flags & WQ_FLAG_EXCLUSIVE) && !--nr_exclusive)
> +				break;
> +		}
>  	}
> +
> +	return woken;
>  }
>  

ok.

>  /**
> @@ -106,9 +111,9 @@ void __wake_up_locked(wait_queue_head_t *q, unsigned int mode, int nr)
>  }
>  EXPORT_SYMBOL_GPL(__wake_up_locked);
>  
> -void __wake_up_locked_key(wait_queue_head_t *q, unsigned int mode, void *key)
> +int __wake_up_locked_key(wait_queue_head_t *q, unsigned int mode, void *key)
>  {
> -	__wake_up_common(q, mode, 1, 0, key);
> +	return __wake_up_common(q, mode, 1, 0, key);
>  }
>  EXPORT_SYMBOL_GPL(__wake_up_locked_key);
>  
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 8a287df..d3e3203 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -847,15 +847,18 @@ EXPORT_SYMBOL_GPL(add_page_wait_queue);
>   * The mb is necessary to enforce ordering between the clear_bit and the read
>   * of the waitqueue (to avoid SMP races with a parallel wait_on_page_locked()).
>   */
> -void unlock_page(struct page *page)
> +void __unlock_page(struct page *page)
>  {
> -	page = compound_head(page);
> -	VM_BUG_ON_PAGE(!PageLocked(page), page);
> -	clear_bit_unlock(PG_locked, &page->flags);
> -	smp_mb__after_atomic();
> -	wake_up_page(page, PG_locked);
> +	struct wait_bit_key key = __WAIT_BIT_KEY_INITIALIZER(&page->flags, PG_locked);
> +	wait_queue_head_t *wq = page_waitqueue(page);
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&wq->lock, flags);
> +	if (!__wake_up_locked_key(wq, TASK_NORMAL, &key))
> +		ClearPageContended(page);
> +	spin_unlock_irqrestore(&wq->lock, flags);
>  }
> -EXPORT_SYMBOL(unlock_page);
> +EXPORT_SYMBOL(__unlock_page);
>  

The function name is questionable. It used to unlock_page but now it's
handling the wakeup of waiters.

That aside, the wq->lock in itself does not protect the PageContended
bit but I couldn't see a case where we lost a wakeup in the following
sequence either.

unlock_page
					lock_page
					prepare_wait
lock_wq
wake
ClearPageContended
unlock_wq
					SetPageContended

Otherwise the page_waitqueue deferrals to the slowpath look ok.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
