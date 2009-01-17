Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7E5696B008C
	for <linux-mm@kvack.org>; Sat, 17 Jan 2009 04:01:14 -0500 (EST)
Subject: Re: [PATCH] Avoid lost wakeups in lock_page_killable()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1232116107.21473.14.camel@think.oraclecorp.com>
References: <1232116107.21473.14.camel@think.oraclecorp.com>
Content-Type: text/plain
Date: Sat, 17 Jan 2009 10:01:17 +0100
Message-Id: <1232182877.7141.39.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: linux-mm@kvack.org, Matthew Wilcox <matthew@wil.cx>, "chuck.lever" <chuck.lever@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2009-01-16 at 09:28 -0500, Chris Mason wrote:
> lock_page and lock_page_killable both call __wait_on_bit_lock, and
> both end up using prepare_to_wait_exclusive().  This means that when
> someone does finally unlock the page, only one process is going to get
> woken up.
> 
> But lock_page_killable can exit without taking the lock.  If nobody
> else comes in and locks the page, any other waiters will wait forever.
> 
> For example, procA holding the page lock, procB and procC are waiting on
> the lock.
> 
> procA: lock_page() // success
> procB: lock_page_killable(), sync_page_killable(), io_schedule()
> procC: lock_page_killable(), sync_page_killable(), io_schedule()
> 
> procA: unlock, wake_up_page(page, PG_locked)
> procA: wake up procB
> 
> happy admin: kill procB
> 
> procB: wakes into sync_page_killable(), notices the signal and returns
> -EINTR
> 
> procB: __wait_on_bit_lock sees the action() func returns < 0 and does
> not take the page lock
> 
> procB: lock_page_killable() returns < 0 and exits happily.
> 
> procC: sleeping in io_schedule() forever unless someone else locks the
> page.
> 
> This was seen in production on systems where the database was shutting
> down.  Testing shows the patch fixes things.
> 
> Chuck Lever did all the hard work here, with a page lock debugging
> patch that proved we were missing a wakeup.  
> 
> Every version of lock_page_killable() should need this.
> 
> Signed-off-by: Chris Mason <chris.mason@oracle.com>

Right, so at worst this creates a spurious wakeup, but avoids the must
more serious issue of a lost wakeup.

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

> diff --git a/mm/filemap.c b/mm/filemap.c
> index ceba0bd..e1184fa 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -623,9 +623,20 @@ EXPORT_SYMBOL(__lock_page);
>  int __lock_page_killable(struct page *page)
>  {
>  	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
> +	int ret;
>  
> -	return __wait_on_bit_lock(page_waitqueue(page), &wait,
> +	ret = __wait_on_bit_lock(page_waitqueue(page), &wait,
>  					sync_page_killable, TASK_KILLABLE);
> +	/*
> +	 * wait_on_bit_lock uses prepare_to_wait_exclusive, so if multiple
> +	 * procs were waiting on this page, we were the only proc woken up.
> +	 *
> +	 * if ret != 0, we didn't actually get the lock.  We need to
> +	 * make sure any other waiters don't sleep forever.
> +	 */
> +	if (ret)
> +		wake_up_page(page, PG_locked);
> +	return ret;
>  }
>  
>  /**
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
