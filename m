Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7D04F6B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 05:37:04 -0500 (EST)
Received: by mail-oi0-f45.google.com with SMTP id i138so14870384oig.4
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 02:37:04 -0800 (PST)
Received: from mail-oi0-x229.google.com (mail-oi0-x229.google.com. [2607:f8b0:4003:c06::229])
        by mx.google.com with ESMTPS id rf10si1915934obc.33.2015.02.27.02.37.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Feb 2015 02:37:03 -0800 (PST)
Received: by mail-oi0-f41.google.com with SMTP id z81so14870632oif.0
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 02:37:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1424958666-18241-1-git-send-email-vbabka@suse.cz>
References: <1424958666-18241-1-git-send-email-vbabka@suse.cz>
From: Michael Kerrisk <mtk.manpages@gmail.com>
Date: Fri, 27 Feb 2015 11:36:43 +0100
Message-ID: <CAHO5Pa0xmquUbzkZvow_PxRGZpA7MVEPFcRL2LPXv7hU41uxDw@mail.gmail.com>
Subject: Re: [PATCH 0/4] enhance shmem process and swap accounting
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm <linux-mm@kvack.org>, Jerome Marchand <jmarchan@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>

[CC += linux-api@]

Hello Vlastimil,

Since this is a kernel-user-space API change, please CC linux-api@.
The kernel source file Documentation/SubmitChecklist notes that all
Linux kernel patches that change userspace interfaces should be CCed
to linux-api@vger.kernel.org, so that the various parties who are
interested in API changes are informed. For further information, see
https://www.kernel.org/doc/man-pages/linux-api-ml.html

Cheers,

Michael


On Thu, Feb 26, 2015 at 2:51 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> This series is based on Jerome Marchand's [1] so let me quote the first
> paragraph from there:
>
> There are several shortcomings with the accounting of shared memory
> (sysV shm, shared anonymous mapping, mapping to a tmpfs file). The
> values in /proc/<pid>/status and statm don't allow to distinguish
> between shmem memory and a shared mapping to a regular file, even
> though theirs implication on memory usage are quite different: at
> reclaim, file mapping can be dropped or write back on disk while shmem
> needs a place in swap. As for shmem pages that are swapped-out or in
> swap cache, they aren't accounted at all.
>
> The original motivation for myself is that a customer found (IMHO rightfully)
> confusing that e.g. top output for process swap usage is unreliable with
> respect to swapped out shmem pages, which are not accounted for.
>
> The fundamental difference between private anonymous and shmem pages is that
> the latter has PTE's converted to pte_none, and not swapents. As such, they are
> not accounted to the number of swapents visible e.g. in /proc/pid/status VmSwap
> row. It might be theoretically possible to use swapents when swapping out shmem
> (without extra cost, as one has to change all mappers anyway), and on swap in
> only convert the swapent for the faulting process, leaving swapents in other
> processes until they also fault (so again no extra cost). But I don't know how
> many assumptions this would break, and it would be too disruptive change for a
> relatively small benefit.
>
> Instead, my approach is to document the limitation of VmSwap, and provide means
> to determine the swap usage for shmem areas for those who are interested and
> willing to pay the price, using /proc/pid/smaps. Because outside of ipcs, I
> don't think it's possible to currently to determine the usage at all.  The
> previous patchset [1] did introduce new shmem-specific fields into smaps
> output, and functions to determine the values. I take a simpler approach,
> noting that smaps output already has a "Swap: X kB" line, where currently X ==
> 0 always for shmem areas. I think we can just consider this a bug and provide
> the proper value by consulting the radix tree, as e.g. mincore_page() does. In the
> patch changelog I explain why this is also not perfect (and cannot be without
> swapents), but still arguably much better than showing a 0.
>
> The last two patches are adapted from Jerome's patchset and provide a VmRSS
> breakdown to VmAnon, VmFile and VmShm in /proc/pid/status. Hugh noted that
> this is a welcome addition, and I agree that it might help e.g. debugging
> process memory usage at albeit non-zero, but still rather low cost of extra
> per-mm counter and some page flag checks. I updated these patches to 4.0-rc1,
> made them respect !CONFIG_SHMEM so that tiny systems don't pay the cost, and
> optimized the page flag checking somewhat.
>
> [1] http://lwn.net/Articles/611966/
>
> Jerome Marchand (2):
>   mm, shmem: Add shmem resident memory accounting
>   mm, procfs: Display VmAnon, VmFile and VmShm in /proc/pid/status
>
> Vlastimil Babka (2):
>   mm, documentation: clarify /proc/pid/status VmSwap limitations
>   mm, proc: account for shmem swap in /proc/pid/smaps
>
>  Documentation/filesystems/proc.txt | 15 +++++++++++++--
>  arch/s390/mm/pgtable.c             |  5 +----
>  fs/proc/task_mmu.c                 | 35 +++++++++++++++++++++++++++++++++--
>  include/linux/mm.h                 | 28 ++++++++++++++++++++++++++++
>  include/linux/mm_types.h           |  9 ++++++---
>  kernel/events/uprobes.c            |  2 +-
>  mm/memory.c                        | 30 ++++++++++--------------------
>  mm/oom_kill.c                      |  5 +++--
>  mm/rmap.c                          | 15 ++++-----------
>  9 files changed, 99 insertions(+), 45 deletions(-)
>
> --
> 2.1.4
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



-- 
Michael Kerrisk Linux man-pages maintainer;
http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface", http://blog.man7.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
