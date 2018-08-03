Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3897C6B026F
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 05:08:02 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g11-v6so1542222edi.8
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 02:08:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n38-v6si108232edn.443.2018.08.03.02.08.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 02:08:00 -0700 (PDT)
Date: Fri, 3 Aug 2018 11:07:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v6 PATCH 2/2] mm: mmap: zap pages with read mmap_sem in
 munmap
Message-ID: <20180803090759.GI27245@dhcp22.suse.cz>
References: <1532628614-111702-1-git-send-email-yang.shi@linux.alibaba.com>
 <1532628614-111702-3-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1532628614-111702-3-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 27-07-18 02:10:14, Yang Shi wrote:
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
> It is because munmap holds mmap_sem exclusively from very beginning to
> all the way down to the end, and doesn't release it in the middle. When
> unmapping large mapping, it may take long time (take ~18 seconds to
> unmap 320GB mapping with every single page mapped on an idle machine).
> 
> Zapping pages is the most time consuming part, according to the
> suggestion from Michal Hocko [1], zapping pages can be done with holding
> read mmap_sem, like what MADV_DONTNEED does. Then re-acquire write
> mmap_sem to cleanup vmas.
> 
> But, some part may need write mmap_sem, for example, vma splitting. So,
> the design is as follows:
>         acquire write mmap_sem
>         lookup vmas (find and split vmas)
> 	detach vmas
>         deal with special mappings
>         downgrade_write
> 
>         zap pages
> 	free page tables
>         release mmap_sem
> 
> The vm events with read mmap_sem may come in during page zapping, but
> since vmas have been detached before, they, i.e. page fault, gup, etc,
> will not be able to find valid vma, then just return SIGSEGV or -EFAULT
> as expected.
> 
> If the vma has VM_LOCKED | VM_HUGETLB | VM_PFNMAP or uprobe, they are
> considered as special mappings. They will be dealt with before zapping
> pages with write mmap_sem held. Basically, just update vm_flags.

Well, I think it would be safer to simply fallback to the current
implementation with these mappings and deal with them on top. This would
make potential issues easier to bisect and partial reverts as well.

> And, since they are also manipulated by unmap_single_vma() which is
> called by unmap_vma() with read mmap_sem held in this case, to
> prevent from updating vm_flags in read critical section, a new
> parameter, called "skip_flags" is added to unmap_region(), unmap_vmas()
> and unmap_single_vma(). If it is true, then just skip unmap those
> special mappings. Currently, the only place which pass true to this
> parameter is us.

skip parameters are usually ugly and lead to more mess later on. Can we
do without them?

> With this approach we don't have to re-acquire mmap_sem again to clean
> up vmas to avoid race window which might get the address space changed.

By with this approach you mean detaching right?

> And, since the lock acquire/release cost is managed to the minimum and
> almost as same as before, the optimization could be extended to any size
> of mapping without incurring significant penalty to small mappings.

I guess you mean to say that lock downgrade approach doesn't lead to
regressions because the overal time mmap_sem is taken is not longer?

> For the time being, just do this in munmap syscall path. Other
> vm_munmap() or do_munmap() call sites (i.e mmap, mremap, etc) remain
> intact for stability reason.

You have used this argument previously and several people have asked.
I think it is just wrong. Either the concept is safe and all callers can
use it or it is not and then those subtle differences should be called
out. Your previous response was that you simply haven't tested other
paths. Well, that is not an argument, I am afraid. The whole thing
should be done at a proper layer. If there are some difficulties to
achieve that for all callers then OK just be explicit about that. I can
imagine some callers really require the exclusive look when munmap
returns for example.

> With the patches, exclusive mmap_sem hold time when munmap a 80GB
> address space on a machine with 32 cores of E5-2680 @ 2.70GHz dropped to
> us level from second.
> 
> munmap_test-15002 [008]   594.380138: funcgraph_entry: |  vm_munmap_zap_rlock() {
> munmap_test-15002 [008]   594.380146: funcgraph_entry:      !2485684 us |    unmap_region();
> munmap_test-15002 [008]   596.865836: funcgraph_exit:       !2485692 us |  }
> 
> Here the excution time of unmap_region() is used to evaluate the time of
> holding read mmap_sem, then the remaining time is used with holding
> exclusive lock.

I will be reading through the patch and follow up on that separately.
-- 
Michal Hocko
SUSE Labs
