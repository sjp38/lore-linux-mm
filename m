Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5832D6B0007
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 04:48:15 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id g13-v6so2244074lfl.15
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 01:48:15 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a10-v6sor594370lfc.54.2018.04.10.01.48.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Apr 2018 01:48:13 -0700 (PDT)
Date: Tue, 10 Apr 2018 11:48:10 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [v3 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
Message-ID: <20180410084810.GA2041@uranus.lan>
References: <1523310774-40300-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1523310774-40300-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: adobriyan@gmail.com, mhocko@kernel.org, willy@infradead.org, mguzik@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Apr 10, 2018 at 05:52:54AM +0800, Yang Shi wrote:
> mmap_sem is on the hot path of kernel, and it very contended, but it is
> abused too. It is used to protect arg_start|end and evn_start|end when
> reading /proc/$PID/cmdline and /proc/$PID/environ, but it doesn't make
> sense since those proc files just expect to read 4 values atomically and
> not related to VM, they could be set to arbitrary values by C/R.
> 
> And, the mmap_sem contention may cause unexpected issue like below:
> 
> INFO: task ps:14018 blocked for more than 120 seconds.
>        Tainted: G            E 4.9.79-009.ali3000.alios7.x86_64 #1
>  "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
> message.
>  ps              D    0 14018      1 0x00000004
>   ffff885582f84000 ffff885e8682f000 ffff880972943000 ffff885ebf499bc0
>   ffff8828ee120000 ffffc900349bfca8 ffffffff817154d0 0000000000000040
>   00ffffff812f872a ffff885ebf499bc0 024000d000948300 ffff880972943000
>  Call Trace:
>   [<ffffffff817154d0>] ? __schedule+0x250/0x730
>   [<ffffffff817159e6>] schedule+0x36/0x80
>   [<ffffffff81718560>] rwsem_down_read_failed+0xf0/0x150
>   [<ffffffff81390a28>] call_rwsem_down_read_failed+0x18/0x30
>   [<ffffffff81717db0>] down_read+0x20/0x40
>   [<ffffffff812b9439>] proc_pid_cmdline_read+0xd9/0x4e0
>   [<ffffffff81253c95>] ? do_filp_open+0xa5/0x100
>   [<ffffffff81241d87>] __vfs_read+0x37/0x150
>   [<ffffffff812f824b>] ? security_file_permission+0x9b/0xc0
>   [<ffffffff81242266>] vfs_read+0x96/0x130
>   [<ffffffff812437b5>] SyS_read+0x55/0xc0
>   [<ffffffff8171a6da>] entry_SYSCALL_64_fastpath+0x1a/0xc5
> 
> Both Alexey Dobriyan and Michal Hocko suggested to use dedicated lock
> for them to mitigate the abuse of mmap_sem.
> 
> So, introduce a new spinlock in mm_struct to protect the concurrent
> access to arg_start|end, env_start|end and others except start_brk and
> brk, which are still protected by mmap_sem to avoid concurrent access
> from do_brk().
> 
> This patch just eliminates the abuse of mmap_sem, but it can't resolve the
> above hung task warning completely since the later access_remote_vm() call
> needs acquire mmap_sem. The mmap_sem scalability issue will be solved in the
> future.
> 
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> Cc: Alexey Dobriyan <adobriyan@gmail.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Mateusz Guzik <mguzik@redhat.com>
> Cc: Cyrill Gorcunov <gorcunov@gmail.com>
> ---
> v2 --> v3:
> * Restored down_write in prctl syscall
> * Elaborate the limitation of this patch suggested by Michal
> * Protect those fields by the new lock except brk and start_brk per Michal's
>   suggestion
> * Based off Cyrill's non PR_SET_MM_MAP oprations deprecation patch
>   (https://lkml.org/lkml/2018/4/5/541)

For prctl part

Acked-by: Cyrill Gorcunov <gorcunov@openvz.org>

thanks!
