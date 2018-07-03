Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5357D6B0003
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 03:36:49 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u130-v6so630242pgc.0
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 00:36:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z10-v6si535231plo.303.2018.07.03.00.36.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 00:36:47 -0700 (PDT)
Subject: Re: [REGRESSION] "Locked" and "Pss" in /proc/*/smaps are the same
References: <69eb77f7-c8cc-fdee-b44f-ad7e522b8467@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ebf6c7fb-fec3-6a26-544f-710ed193c154@suse.cz>
Date: Tue, 3 Jul 2018 09:36:45 +0200
MIME-Version: 1.0
In-Reply-To: <69eb77f7-c8cc-fdee-b44f-ad7e522b8467@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Lindroth <thomas.lindroth@gmail.com>, dancol@google.com, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

+CC

On 07/01/2018 08:31 PM, Thomas Lindroth wrote:
> While looking around in /proc on my v4.14.52 system I noticed that
> all processes got a lot of "Locked" memory in /proc/*/smaps. A lot
> more memory than a regular user can usually lock with mlock().
> 
> commit 493b0e9d945fa9dfe96be93ae41b4ca4b6fdb317 (v4.14-rc1) seems
> to have changed the behavior of "Locked".
> 
> commit 493b0e9d945fa9dfe96be93ae41b4ca4b6fdb317
> Author: Daniel Colascione <dancol@google.com>
> Date:   Wed Sep 6 16:25:08 2017 -0700
> 
>     mm: add /proc/pid/smaps_rollup
> 
> Before that commit the code was like this. Notice the VM_LOCKED
> check.
> 
> seq_printf(m,
>            "Size:           %8lu kB\n"
>            "Rss:            %8lu kB\n"
>            "Pss:            %8lu kB\n"
>            "Shared_Clean:   %8lu kB\n"
>            "Shared_Dirty:   %8lu kB\n"
>            "Private_Clean:  %8lu kB\n"
>            "Private_Dirty:  %8lu kB\n"
>            "Referenced:     %8lu kB\n"
>            "Anonymous:      %8lu kB\n"
>            "LazyFree:       %8lu kB\n"
>            "AnonHugePages:  %8lu kB\n"
>            "ShmemPmdMapped: %8lu kB\n"
>            "Shared_Hugetlb: %8lu kB\n"
>            "Private_Hugetlb: %7lu kB\n"
>            "Swap:           %8lu kB\n"
>            "SwapPss:        %8lu kB\n"
>            "KernelPageSize: %8lu kB\n"
>            "MMUPageSize:    %8lu kB\n"
>            "Locked:         %8lu kB\n",
>            (vma->vm_end - vma->vm_start) >> 10,
>            mss.resident >> 10,
>            (unsigned long)(mss.pss >> (10 + PSS_SHIFT)),
>            mss.shared_clean  >> 10,
>            mss.shared_dirty  >> 10,
>            mss.private_clean >> 10,
>            mss.private_dirty >> 10,
>            mss.referenced >> 10,
>            mss.anonymous >> 10,
>            mss.lazyfree >> 10,
>            mss.anonymous_thp >> 10,
>            mss.shmem_thp >> 10,
>            mss.shared_hugetlb >> 10,
>            mss.private_hugetlb >> 10,
>            mss.swap >> 10,
>            (unsigned long)(mss.swap_pss >> (10 + PSS_SHIFT)),
>            vma_kernel_pagesize(vma) >> 10,
>            vma_mmu_pagesize(vma) >> 10,
>            (vma->vm_flags & VM_LOCKED) ?
>                 (unsigned long)(mss.pss >> (10 + PSS_SHIFT)) : 0);
> 
> After that commit Locked is now the same as Pss. This looks like a
> mistake.
> 
> seq_printf(m,
>            "Rss:            %8lu kB\n"
>            "Pss:            %8lu kB\n"
>            "Shared_Clean:   %8lu kB\n"
>            "Shared_Dirty:   %8lu kB\n"
>            "Private_Clean:  %8lu kB\n"
>            "Private_Dirty:  %8lu kB\n"
>            "Referenced:     %8lu kB\n"
>            "Anonymous:      %8lu kB\n"
>            "LazyFree:       %8lu kB\n"
>            "AnonHugePages:  %8lu kB\n"
>            "ShmemPmdMapped: %8lu kB\n"
>            "Shared_Hugetlb: %8lu kB\n"
>            "Private_Hugetlb: %7lu kB\n"
>            "Swap:           %8lu kB\n"
>            "SwapPss:        %8lu kB\n"
>            "Locked:         %8lu kB\n",
>            mss->resident >> 10,
>            (unsigned long)(mss->pss >> (10 + PSS_SHIFT)),
>            mss->shared_clean  >> 10,
>            mss->shared_dirty  >> 10,
>            mss->private_clean >> 10,
>            mss->private_dirty >> 10,
>            mss->referenced >> 10,
>            mss->anonymous >> 10,
>            mss->lazyfree >> 10,
>            mss->anonymous_thp >> 10,
>            mss->shmem_thp >> 10,
>            mss->shared_hugetlb >> 10,
>            mss->private_hugetlb >> 10,
>            mss->swap >> 10,
>            (unsigned long)(mss->swap_pss >> (10 + PSS_SHIFT)),
>            (unsigned long)(mss->pss >> (10 + PSS_SHIFT)));
> 
> The latest git has changed a bit but the functionality is the
> same.

----8<----
