Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DC8CD6B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 22:13:11 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 80so20302441pfy.2
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 19:13:11 -0800 (PST)
Received: from out0-137.mail.aliyun.com (out0-137.mail.aliyun.com. [140.205.0.137])
        by mx.google.com with ESMTP id b189si7708309pgc.242.2017.01.11.19.13.10
        for <linux-mm@kvack.org>;
        Wed, 11 Jan 2017 19:13:10 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170111005535.13832-1-aarcange@redhat.com> <20170111005535.13832-2-aarcange@redhat.com>
In-Reply-To: <20170111005535.13832-2-aarcange@redhat.com>
Subject: Re: [PATCH 1/1] userfaultfd: fix SIGBUS resulting from false rwsem wakeups
Date: Thu, 12 Jan 2017 11:13:03 +0800
Message-ID: <022401d26c81$c9fce1e0$5df6a5a0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andrea Arcangeli' <aarcange@redhat.com>, linux-mm@kvack.org, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Michael Rapoport' <RAPOPORT@il.ibm.com>, "'Dr. David Alan Gilbert'" <dgilbert@redhat.com>, 'Mike Kravetz' <mike.kravetz@oracle.com>, 'Pavel Emelyanov' <xemul@parallels.com>

On Wednesday, January 11, 2017 8:56 AM Andrea Arcangeli wrote: 
> 
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
> bounces: 99998, mode: racing ver poll, userfaults: 32 35 90 232 30 138 69 82 34 30 139 40 40 31 20 19 43 13 15 28 27 38 21 43 56
22 1 17 31
> 8 4 2
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
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
