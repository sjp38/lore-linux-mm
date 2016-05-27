Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 18E546B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 04:40:33 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g64so121401180pfb.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 01:40:33 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id w63si12947998pfb.135.2016.05.27.01.40.31
        for <linux-mm@kvack.org>;
        Fri, 27 May 2016 01:40:32 -0700 (PDT)
Date: Fri, 27 May 2016 17:40:39 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 2/3] mm, thp: fix possible circular locking dependency
 caused by sum_vm_event()
Message-ID: <20160527084039.GI2322@bbox>
References: <1464335964-6510-1-git-send-email-ebru.akagunduz@gmail.com>
 <1464335964-6510-3-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
In-Reply-To: <1464335964-6510-3-git-send-email-ebru.akagunduz@gmail.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com

Hi Ebru,

On Fri, May 27, 2016 at 10:59:23AM +0300, Ebru Akagunduz wrote:
> Nested circular locking dependency detected by kernel robot (udevadm).
> 
>   udevadm/221 is trying to acquire lock:
>    (&mm->mmap_sem){++++++}, at: [<ffffffff81262543>] __might_fault+0x83/0x150
>   but task is already holding lock:
>    (s_active#12){++++.+}, at: [<ffffffff813315ee>] kernfs_fop_write+0x8e/0x250
>   which lock already depends on the new lock.
> 
>  Possible unsafe locking scenario:
> 
>  CPU0                    CPU1
>  ----                    ----
>  lock(s_active);
>                          lock(cpu_hotplug.lock);
>                          lock(s_active);
>  lock(&mm->mmap_sem);
> 
>  the existing dependency chain (in reverse order) is:
>  -> #2 (s_active#12){++++.+}:
>         [<ffffffff8117da2c>] lock_acquire+0xac/0x180
>         [<ffffffff8132f50a>] __kernfs_remove+0x2da/0x410
>         [<ffffffff81330630>] kernfs_remove_by_name_ns+0x40/0x90
>         [<ffffffff813339fb>] sysfs_remove_file_ns+0x2b/0x70
>         [<ffffffff81ba8a16>] device_del+0x166/0x320
>         [<ffffffff81ba943c>] device_destroy+0x3c/0x50
>         [<ffffffff8105aa61>] cpuid_class_cpu_callback+0x51/0x70
>         [<ffffffff81131ce9>] notifier_call_chain+0x59/0x190
>         [<ffffffff81132749>] __raw_notifier_call_chain+0x9/0x10
>         [<ffffffff810fe6b0>] __cpu_notify+0x40/0x90
>         [<ffffffff810fe890>] cpu_notify_nofail+0x10/0x30
>         [<ffffffff810fe8d7>] notify_dead+0x27/0x1e0
>         [<ffffffff810fe273>] cpuhp_down_callbacks+0x93/0x190
>         [<ffffffff82096062>] _cpu_down+0xc2/0x1e0
>         [<ffffffff810ff727>] do_cpu_down+0x37/0x50
>         [<ffffffff8110003b>] cpu_down+0xb/0x10
>         [<ffffffff81038e4d>] _debug_hotplug_cpu+0x7d/0xd0
>         [<ffffffff8435d6bb>] debug_hotplug_cpu+0xd/0x11
>         [<ffffffff84352426>] do_one_initcall+0x138/0x1cf
>         [<ffffffff8435270a>] kernel_init_freeable+0x24d/0x2de
>         [<ffffffff8209533a>] kernel_init+0xa/0x120
>         [<ffffffff820a7972>] ret_from_fork+0x22/0x50
> 
>  -> #1 (cpu_hotplug.lock#2){+.+.+.}:
>         [<ffffffff8117da2c>] lock_acquire+0xac/0x180
>         [<ffffffff820a20d1>] mutex_lock_nested+0x71/0x4c0
>         [<ffffffff810ff526>] get_online_cpus+0x66/0x80
>         [<ffffffff81246fb3>] sum_vm_event+0x23/0x1b0
>         [<ffffffff81293768>] collapse_huge_page+0x118/0x10b0
>         [<ffffffff81294c5d>] khugepaged+0x55d/0xe80
>         [<ffffffff81130304>] kthread+0x134/0x1a0
>         [<ffffffff820a7972>] ret_from_fork+0x22/0x50
> 
>  -> #0 (&mm->mmap_sem){++++++}:
>         [<ffffffff8117bf61>] __lock_acquire+0x2861/0x31f0
>         [<ffffffff8117da2c>] lock_acquire+0xac/0x180
>         [<ffffffff8126257e>] __might_fault+0xbe/0x150
>         [<ffffffff8133160f>] kernfs_fop_write+0xaf/0x250
>         [<ffffffff812a8933>] __vfs_write+0x43/0x1a0
>         [<ffffffff812a8d3a>] vfs_write+0xda/0x240
>         [<ffffffff812a8f84>] SyS_write+0x44/0xa0
>         [<ffffffff820a773c>] entry_SYSCALL_64_fastpath+0x1f/0xbd
> 
> This patch moves sum_vm_event() before taking down_write(&mm->mmap_sem)
> to solve dependency lock.

sum_vm_event works with CONFIG_VM_EVENT_COUNTERS so if a system doesn't
enable the config, THP swapin throttling logic is void in that case.
Right? If so, shouldn't we approach another way?

If it was already discussed, sorry for bothering you.

> 
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> ---
> Changes in v2:
>  - Nothing changed
> 
>  mm/huge_memory.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 5e71d7a..9adf1c7 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2452,6 +2452,9 @@ static void collapse_huge_page(struct mm_struct *mm,
>  		goto out_nolock;
>  	}
>  
> +	swap = get_mm_counter(mm, MM_SWAPENTS);
> +	curr_allocstall = sum_vm_event(ALLOCSTALL);
> +
>  	/*
>  	 * Prevent all access to pagetables with the exception of
>  	 * gup_fast later hanlded by the ptep_clear_flush and the VM
> @@ -2484,8 +2487,6 @@ static void collapse_huge_page(struct mm_struct *mm,
>  		goto out;
>  	}
>  
> -	swap = get_mm_counter(mm, MM_SWAPENTS);
> -	curr_allocstall = sum_vm_event(ALLOCSTALL);
>  	/*
>  	 * Don't perform swapin readahead when the system is under pressure,
>  	 * to avoid unnecessary resource consumption.
> -- 
> 1.9.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
