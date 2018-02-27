Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7A5BD6B0005
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 20:02:54 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id w194so8357208itc.1
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 17:02:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n3sor5788357ite.114.2018.02.26.17.02.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Feb 2018 17:02:53 -0800 (PST)
Date: Mon, 26 Feb 2018 17:02:51 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 0/4 v2] Define killable version for access_remote_vm()
 and use it in fs/proc
In-Reply-To: <1519691151-101999-1-git-send-email-yang.shi@linux.alibaba.com>
Message-ID: <alpine.DEB.2.20.1802261656490.16999@chino.kir.corp.google.com>
References: <1519691151-101999-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: akpm@linux-foundation.org, mingo@kernel.org, adobriyan@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 27 Feb 2018, Yang Shi wrote:

> 
> Background:
> When running vm-scalability with large memory (> 300GB), the below hung
> task issue happens occasionally.
> 
> INFO: task ps:14018 blocked for more than 120 seconds.
>        Tainted: G            E 4.9.79-009.ali3000.alios7.x86_64 #1
>  "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
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
> When manipulating a large mapping, the process may hold the mmap_sem for
> long time, so reading /proc/<pid>/cmdline may be blocked in
> uninterruptible state for long time.
> We already have killable version APIs for semaphore, here use down_read_killable()
> to improve the responsiveness.
> 

Rather than killable, we have patches that introduce down_read_unfair() 
variants for the files you've modified (cmdline and environ) as well as 
others (maps, numa_maps, smaps).

When another thread is holding down_read() and there are queued 
down_write()'s, down_read_unfair() allows for grabbing the rwsem without 
queueing for it.  Additionally, when another thread is holding 
down_write(), down_read_unfair() allows for queueing in front of other 
threads trying to grab it for write as well.

Ingo would know more about whether a variant like that in upstream Linux 
would be acceptable.

Would you be interested in unfair variants instead of only addressing 
killable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
