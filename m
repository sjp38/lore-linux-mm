Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id E635A6B0009
	for <linux-mm@kvack.org>; Sat, 30 Jan 2016 14:53:49 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id p63so21410706wmp.1
        for <linux-mm@kvack.org>; Sat, 30 Jan 2016 11:53:49 -0800 (PST)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id v2si29722727wjz.107.2016.01.30.11.53.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jan 2016 11:53:48 -0800 (PST)
Received: by mail-wm0-x231.google.com with SMTP id 128so22745554wmz.1
        for <linux-mm@kvack.org>; Sat, 30 Jan 2016 11:53:48 -0800 (PST)
Date: Sat, 30 Jan 2016 21:53:46 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: 4.5-rc1: mm/gup.c warning when writing to /proc/self/mem
Message-ID: <20160130195346.GA19437@node.shutemov.name>
References: <20160130175831.GA30571@codemonkey.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160130175831.GA30571@codemonkey.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@codemonkey.org.uk>, linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Sat, Jan 30, 2016 at 12:58:31PM -0500, Dave Jones wrote:
> Hit this overnight. Just started seeing this after I added "create mmap's
> of fd's we open()'d" to trinity.

The WARN_ON_ONCE() came form Hugh's patch:
 cda540ace6a1 ("mm: get_user_pages(write,force) refuse to COW in shared areas")

This warning is expected if you try to write via /proc/<pid>/mem into
write-protected shared mapping without FMODE_WRITE on the underlying file.
You're not supposed to do that and -EFAULT is right answer for an attempt.

The WARN_ON_ONCE() was added almost two years ago to catch other not
expected users of get_user_pages(write=1,force=1). IIUC, none were found.

Probably we should consider removing the warning.

> 
> 	Dave
> 
> WARNING: CPU: 1 PID: 16733 at mm/gup.c:434 __get_user_pages+0x5f9/0x990()
> CPU: 1 PID: 16733 Comm: trinity-c30 Tainted: G        W       4.5.0-rc1-think+ #12
>  0000000000000009 000000006648ff5c ffff88000f0779a0 ffffffff99565971
> ------------[ cut here ]------------
> WARNING: CPU: 0 PID: 16731 at mm/gup.c:434 __get_user_pages+0x5f9/0x990()
>  0000000000000000 ffff88000f0779e0 ffffffff990b168f ffffffff992aba69
>  ffff880450cf1000 0000000000000000 ffff88023780e600 0000000000000017
> Call Trace:
>  [<ffffffff99565971>] dump_stack+0x4e/0x7d
>  [<ffffffff990b168f>] warn_slowpath_common+0x9f/0xe0
>  [<ffffffff992aba69>] ? __get_user_pages+0x5f9/0x990
>  [<ffffffff990b18aa>] warn_slowpath_null+0x1a/0x20
>  [<ffffffff992aba69>] __get_user_pages+0x5f9/0x990
>  [<ffffffff992ab470>] ? follow_page_mask+0x530/0x530
>  [<ffffffff992ad54a>] ? __access_remote_vm+0xca/0x340
>  [<ffffffff992ac2e2>] get_user_pages+0x52/0x60
>  [<ffffffff992ad610>] __access_remote_vm+0x190/0x340
>  [<ffffffff990f2531>] ? preempt_count_sub+0xc1/0x120
>  [<ffffffff992ad480>] ? __might_fault+0xf0/0xf0
>  [<ffffffff992ad417>] ? __might_fault+0x87/0xf0
>  [<ffffffff992b607f>] access_remote_vm+0x1f/0x30
>  [<ffffffff993c5703>] mem_rw.isra.15+0xe3/0x1d0
>  [<ffffffff993c5833>] mem_write+0x43/0x50
>  [<ffffffff9930a6ed>] __vfs_write+0xdd/0x260
>  [<ffffffff9930a610>] ? __vfs_read+0x260/0x260
>  [<ffffffff99d136cb>] ? mutex_lock_nested+0x38b/0x590
>  [<ffffffff99133152>] ? __lock_is_held+0x92/0xd0
>  [<ffffffff990f2531>] ? preempt_count_sub+0xc1/0x120
>  [<ffffffff99131035>] ? update_fast_ctr+0x65/0x90
>  [<ffffffff991310e7>] ? percpu_down_read+0x57/0xa0
>  [<ffffffff99310bc4>] ? __sb_start_write+0xb4/0xf0
>  [<ffffffff9930bec6>] vfs_write+0xf6/0x260
>  [<ffffffff9930d84f>] SyS_write+0xbf/0x160
>  [<ffffffff9930d790>] ? SyS_read+0x160/0x160
>  [<ffffffff99002017>] ? trace_hardirqs_on_thunk+0x17/0x19
>  [<ffffffff99d19557>] entry_SYSCALL_64_fastpath+0x12/0x6b
> CPU: 0 PID: 16731 Comm: trinity-c28 Tainted: G        W       4.5.0-rc1-think+ #12
>  0000000000000009 000000002962eec9 ffff8802e7b7f8d8 ffffffff99565971
>  0000000000000000 ffff8802e7b7f918 ffffffff990b168f ffffffff992aba69
>  ffff8803ed6f1000 00000000000000a0 ffff88023780e600 0000000000000017
> Call Trace:
>  [<ffffffff99565971>] dump_stack+0x4e/0x7d
>  [<ffffffff990b168f>] warn_slowpath_common+0x9f/0xe0
>  [<ffffffff992aba69>] ? __get_user_pages+0x5f9/0x990
>  [<ffffffff990b18aa>] warn_slowpath_null+0x1a/0x20
>  [<ffffffff992aba69>] __get_user_pages+0x5f9/0x990
>  [<ffffffff99015979>] ? native_sched_clock+0x69/0x160
>  [<ffffffff992ab470>] ? follow_page_mask+0x530/0x530
>  [<ffffffff992ad54a>] ? __access_remote_vm+0xca/0x340
>  [<ffffffff992ac2e2>] get_user_pages+0x52/0x60
>  [<ffffffff992ad610>] __access_remote_vm+0x190/0x340
>  [<ffffffff990f2531>] ? preempt_count_sub+0xc1/0x120
>  [<ffffffff992ad480>] ? __might_fault+0xf0/0xf0
>  [<ffffffff992ad417>] ? __might_fault+0x87/0xf0
>  [<ffffffff992b607f>] access_remote_vm+0x1f/0x30
>  [<ffffffff993c5703>] mem_rw.isra.15+0xe3/0x1d0
>  [<ffffffff993c5833>] mem_write+0x43/0x50
>  [<ffffffff9930a950>] do_loop_readv_writev+0xe0/0x110
>  [<ffffffff993c57f0>] ? mem_rw.isra.15+0x1d0/0x1d0
>  [<ffffffff9930c3bb>] do_readv_writev+0x38b/0x3c0
>  [<ffffffff99132960>] ? trace_hardirqs_off_caller+0x70/0x110
>  [<ffffffff993c57f0>] ? mem_rw.isra.15+0x1d0/0x1d0
>  [<ffffffff9930c030>] ? vfs_write+0x260/0x260
>  [<ffffffff99595e17>] ? debug_smp_processor_id+0x17/0x20
>  [<ffffffff990f2531>] ? preempt_count_sub+0xc1/0x120
>  [<ffffffff991330e5>] ? __lock_is_held+0x25/0xd0
>  [<ffffffff991381e3>] ? mark_held_locks+0x23/0xc0
>  [<ffffffff9926080a>] ? context_tracking_exit.part.5+0x2a/0x50
>  [<ffffffff99138406>] ? trace_hardirqs_on_caller+0x186/0x280
>  [<ffffffff9913850d>] ? trace_hardirqs_on+0xd/0x10
>  [<ffffffff9930c4b9>] vfs_writev+0x59/0x70
>  [<ffffffff9930e2fd>] SyS_pwritev+0x15d/0x180
>  [<ffffffff9930e1a0>] ? SyS_preadv+0x180/0x180
>  [<ffffffff99002017>] ? trace_hardirqs_on_thunk+0x17/0x19
>  [<ffffffff99d19557>] entry_SYSCALL_64_fastpath+0x12/0x6b
> ---[ end trace 96115a52264cceaf ]---
> ---[ end trace 96115a52264cceb0 ]---
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
