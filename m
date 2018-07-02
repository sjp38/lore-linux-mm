Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5920E6B0003
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 09:53:15 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r15-v6so1041142edq.22
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 06:53:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a64-v6si4213950ede.410.2018.07.02.06.53.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 06:53:13 -0700 (PDT)
Date: Mon, 2 Jul 2018 15:53:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v3 PATCH 4/5] mm: mmap: zap pages with read mmap_sem for
 large mapping
Message-ID: <20180702135311.GY19043@dhcp22.suse.cz>
References: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
 <1530311985-31251-5-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1530311985-31251-5-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Sat 30-06-18 06:39:44, Yang Shi wrote:
> When running some mmap/munmap scalability tests with large memory (i.e.
> > 300GB), the below hung task issue may happen occasionally.
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
> It is because munmap holds mmap_sem from very beginning to all the way
> down to the end, and doesn't release it in the middle. When unmapping
> large mapping, it may take long time (take ~18 seconds to unmap 320GB
> mapping with every single page mapped on an idle machine).
> 
> It is because munmap holds mmap_sem from very beginning to all the way
> down to the end, and doesn't release it in the middle. When unmapping
> large mapping, it may take long time (take ~18 seconds to unmap 320GB
> mapping with every single page mapped on an idle machine).
> 
> Zapping pages is the most time consuming part, according to the
> suggestion from Michal Hock [1], zapping pages can be done with holding

s@Hock@Hocko@

> read mmap_sem, like what MADV_DONTNEED does. Then re-acquire write
> mmap_sem to cleanup vmas. All zapped vmas will have VM_DEAD flag set,
> the page fault to VM_DEAD vma will trigger SIGSEGV.

This really deserves an explanation why the all dance is really needed.

It would be also good to mention how do you achieve the overal
consistency. E.g. you are dropping mmap_sem and then re-taking it for
write. What if any pending write lock succeeds and modify the address
space? Does it matter, why if not? 

> Define large mapping size thresh as PUD size or 1GB, just zap pages with
> read mmap_sem for mappings which are >= thresh value.
> 
> If the vma has VM_LOCKED | VM_HUGETLB | VM_PFNMAP or uprobe, then just
> fallback to regular path since unmapping those mappings need acquire
> write mmap_sem.
> 
> For the time being, just do this in munmap syscall path. Other
> vm_munmap() or do_munmap() call sites remain intact for stability
> reason.

What are those stability reasons?

> The below is some regression and performance data collected on a machine
> with 32 cores of E5-2680 @ 2.70GHz and 384GB memory.
> 
> With the patched kernel, write mmap_sem hold time is dropped to us level
> from second.

I haven't read through the implemenation carefuly TBH but the changelog
needs quite some work to explain the solution and resulting semantic of
munmap after the change.
-- 
Michal Hocko
SUSE Labs
