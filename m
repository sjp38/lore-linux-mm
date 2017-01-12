Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B44F06B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 16:19:52 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id y196so36357557ity.1
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 13:19:52 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id c67si2999312ite.76.2017.01.12.13.19.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 13:19:51 -0800 (PST)
Subject: Re: [PATCH 1/1] userfaultfd: fix SIGBUS resulting from false rwsem
 wakeups
References: <20170111005535.13832-1-aarcange@redhat.com>
 <20170111005535.13832-2-aarcange@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <7e106d9f-bffb-280d-eb40-4877746eaddb@oracle.com>
Date: Thu, 12 Jan 2017 13:19:38 -0800
MIME-Version: 1.0
In-Reply-To: <20170111005535.13832-2-aarcange@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

On 01/10/2017 04:55 PM, Andrea Arcangeli wrote:
> With >=32 CPUs the userfaultfd selftest triggered a graceful but
> unexpected SIGBUS because VM_FAULT_RETRY was returned by
> handle_userfault() despite the UFFDIO_COPY wasn't completed.
> 
> This seems caused by rwsem waking the thread blocked in
> handle_userfault() and we can't run up_read() before the wait_event
> sequence is complete.
> 
> Keeping the wait_even sequence identical to the first one, would
> require running userfaultfd_must_wait() again to know if the loop
> should be repeated, and it would also require retaking the rwsem and
> revalidating the whole vma status.
> 
> It seems simpler to wait the targeted wakeup so that if false wakeups
> materialize we still wait for our specific wakeup event, unless of
> course there are signals or the uffd was released.
> 
> Debug code collecting the stack trace of the wakeup showed this:
> 
> $ ./userfaultfd 100 99999
> nr_pages: 25600, nr_pages_per_cpu: 800
> bounces: 99998, mode: racing ver poll, userfaults: 32 35 90 232 30 138 69 82 34 30 139 40 40 31 20 19 43 13 15 28 27 38 21 43 56 22 1 17 31 8 4 2
> bounces: 99997, mode: rnd ver poll, Bus error (core dumped)
> 
>    [<ffffffff8102e19b>] save_stack_trace+0x2b/0x50
>    [<ffffffff8110b1d6>] try_to_wake_up+0x2a6/0x580
>    [<ffffffff8110b502>] wake_up_q+0x32/0x70
>    [<ffffffff8113d7a0>] rwsem_wake+0xe0/0x120
>    [<ffffffff8148361b>] call_rwsem_wake+0x1b/0x30
>    [<ffffffff81131d5b>] up_write+0x3b/0x40
>    [<ffffffff812280fc>] vm_mmap_pgoff+0x9c/0xc0
>    [<ffffffff81244b79>] SyS_mmap_pgoff+0x1a9/0x240
>    [<ffffffff810228f2>] SyS_mmap+0x22/0x30
>    [<ffffffff81842dfc>] entry_SYSCALL_64_fastpath+0x1f/0xbd
>    [<ffffffffffffffff>] 0xffffffffffffffff
> FAULT_FLAG_ALLOW_RETRY missing 70
> CPU: 24 PID: 1054 Comm: userfaultfd Tainted: G        W       4.8.0+ #30
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.9.3-0-ge2fc41e-prebuilt.qemu-project.org 04/01/2014
>  0000000000000000 ffff880218027d40 ffffffff814749f6 ffff8802180c4a80
>  ffff880231ead4c0 ffff880218027e18 ffffffff812e0102 ffffffff81842b1c
>  ffff880218027dd0 ffff880218082960 0000000000000000 0000000000000000
> Call Trace:
>  [<ffffffff814749f6>] dump_stack+0xb8/0x112
>  [<ffffffff812e0102>] handle_userfault+0x572/0x650
>  [<ffffffff81842b1c>] ? _raw_spin_unlock_irq+0x2c/0x50
>  [<ffffffff812407b4>] ? handle_mm_fault+0xcf4/0x1520
>  [<ffffffff81240d7e>] ? handle_mm_fault+0x12be/0x1520
>  [<ffffffff81240d8b>] handle_mm_fault+0x12cb/0x1520
>  [<ffffffff81483588>] ? call_rwsem_down_read_failed+0x18/0x30
>  [<ffffffff810572c5>] __do_page_fault+0x175/0x500
>  [<ffffffff810576f1>] trace_do_page_fault+0x61/0x270
>  [<ffffffff81050739>] do_async_page_fault+0x19/0x90
>  [<ffffffff81843ef5>] async_page_fault+0x25/0x30
> 
> This always happens when the main userfault selftest thread is running
> clone() while glibc runs either mprotect or mmap (both taking mmap_sem
> down_write()) to allocate the thread stack of the background threads,
> while locking/userfault threads already run at full throttle and are
> susceptible to false wakeups that may cause handle_userfault() to
> return before than expected (which results in graceful SIGBUS at the
> next attempt).
> 
> This was reproduced only with >=32 CPUs because the loop to start the
> thread where clone() is too quick with fewer CPUs, while with 32 CPUs
> there's already significant activity on ~32 locking and userfault
> threads when the last background threads are started with clone().
> 
> This >=32 CPUs SMP race condition is likely reproducible only with the
> selftest because of the much heavier userfault load it generates if
> compared to real apps.
> 
> We'll have to allow "one more" VM_FAULT_RETRY for the WP support and a
> patch floating around that provides it also hidden this problem but in
> reality only is successfully at hiding the problem. False wakeups
> could still happen again the second time handle_userfault() is
> invoked, even if it's a so rare race condition that getting false
> wakeups twice in a row is impossible to reproduce. This full fix is
> needed for correctness, the only alternative would be to allow
> VM_FAULT_RETRY to be returned infinitely. With this fix the WP support
> can stick to a strict "one more" VM_FAULT_RETRY logic (no need of
> returning it infinite times to avoid the SIGBUS).
> 
> Reported-by: Mike Kravetz <mike.kravetz@oracle.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Tests are now successful

Tested-by: Mike Kravetz <mike.kravetz@oracle.com>

If anyone is going to the trouble of adding the Tested-by, please
change the Reported-by to,

Reported-by: Shubham Kumar Sharma <shubham.kumar.sharma@oracle.com>

Shubham is the one who originally discovered the issue.
-- 
Mike Kravetz

> ---
>  fs/userfaultfd.c | 37 +++++++++++++++++++++++++++++++++++--
>  1 file changed, 35 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index d96e2f3..43953e0 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -63,6 +63,7 @@ struct userfaultfd_wait_queue {
>  	struct uffd_msg msg;
>  	wait_queue_t wq;
>  	struct userfaultfd_ctx *ctx;
> +	bool waken;
>  };
>  
>  struct userfaultfd_wake_range {
> @@ -86,6 +87,12 @@ static int userfaultfd_wake_function(wait_queue_t *wq, unsigned mode,
>  	if (len && (start > uwq->msg.arg.pagefault.address ||
>  		    start + len <= uwq->msg.arg.pagefault.address))
>  		goto out;
> +	WRITE_ONCE(uwq->waken, true);
> +	/*
> +	 * The implicit smp_mb__before_spinlock in try_to_wake_up()
> +	 * renders uwq->waken visible to other CPUs before the task is
> +	 * waken.
> +	 */
>  	ret = wake_up_state(wq->private, mode);
>  	if (ret)
>  		/*
> @@ -264,6 +271,7 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
>  	struct userfaultfd_wait_queue uwq;
>  	int ret;
>  	bool must_wait, return_to_userland;
> +	long blocking_state;
>  
>  	BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
>  
> @@ -334,10 +342,13 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
>  	uwq.wq.private = current;
>  	uwq.msg = userfault_msg(vmf->address, vmf->flags, reason);
>  	uwq.ctx = ctx;
> +	uwq.waken = false;
>  
>  	return_to_userland =
>  		(vmf->flags & (FAULT_FLAG_USER|FAULT_FLAG_KILLABLE)) ==
>  		(FAULT_FLAG_USER|FAULT_FLAG_KILLABLE);
> +	blocking_state = return_to_userland ? TASK_INTERRUPTIBLE :
> +			 TASK_KILLABLE;
>  
>  	spin_lock(&ctx->fault_pending_wqh.lock);
>  	/*
> @@ -350,8 +361,7 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
>  	 * following the spin_unlock to happen before the list_add in
>  	 * __add_wait_queue.
>  	 */
> -	set_current_state(return_to_userland ? TASK_INTERRUPTIBLE :
> -			  TASK_KILLABLE);
> +	set_current_state(blocking_state);
>  	spin_unlock(&ctx->fault_pending_wqh.lock);
>  
>  	must_wait = userfaultfd_must_wait(ctx, vmf->address, vmf->flags,
> @@ -364,6 +374,29 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
>  		wake_up_poll(&ctx->fd_wqh, POLLIN);
>  		schedule();
>  		ret |= VM_FAULT_MAJOR;
> +
> +		/*
> +		 * False wakeups can orginate even from rwsem before
> +		 * up_read() however userfaults will wait either for a
> +		 * targeted wakeup on the specific uwq waitqueue from
> +		 * wake_userfault() or for signals or for uffd
> +		 * release.
> +		 */
> +		while (!READ_ONCE(uwq.waken)) {
> +			/*
> +			 * This needs the full smp_store_mb()
> +			 * guarantee as the state write must be
> +			 * visible to other CPUs before reading
> +			 * uwq.waken from other CPUs.
> +			 */
> +			set_current_state(blocking_state);
> +			if (READ_ONCE(uwq.waken) ||
> +			    READ_ONCE(ctx->released) ||
> +			    (return_to_userland ? signal_pending(current) :
> +			     fatal_signal_pending(current)))
> +				break;
> +			schedule();
> +		}
>  	}
>  
>  	__set_current_state(TASK_RUNNING);
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
