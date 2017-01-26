Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EF4696B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 00:50:51 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y143so296665812pfb.6
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 21:50:51 -0800 (PST)
Received: from out4441.biz.mail.alibaba.com (out4441.biz.mail.alibaba.com. [47.88.44.41])
        by mx.google.com with ESMTP id i64si474352pfk.182.2017.01.25.21.50.49
        for <linux-mm@kvack.org>;
        Wed, 25 Jan 2017 21:50:51 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1485265923-20256-1-git-send-email-rppt@linux.vnet.ibm.com>
In-Reply-To: <1485265923-20256-1-git-send-email-rppt@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 0/5] userfaultfd: non-cooperative: better tracking for mapping changes
Date: Thu, 26 Jan 2017 13:50:27 +0800
Message-ID: <008001d27798$1dd18390$59748ab0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mike Rapoport' <rppt@linux.vnet.ibm.com>, 'Linux-MM' <linux-mm@kvack.org>
Cc: 'Andrea Arcangeli' <aarcange@redhat.com>, 'Andrew Morton' <akpm@linux-foundation.org>, "'Dr. David Alan Gilbert'" <dgilbert@redhat.com>, 'Mike Kravetz' <mike.kravetz@oracle.com>, 'Pavel Emelyanov' <xemul@virtuozzo.com>, 'LKML' <linux-kernel@vger.kernel.org>


On January 24, 2017 9:52 PM Mike Rapoport wrote: 
> Hi,
> 
> These patches try to address issues I've encountered during integration of
> userfaultfd with CRIU.
> Previously added userfaultfd events for fork(), madvise() and mremap()
> unfortunately do not cover all possible changes to a process virtual memory
> layout required for uffd monitor.
> When one or more VMAs is removed from the process mm, the external uffd
> monitor has no way to detect those changes and will attempt to fill the
> removed regions with userfaultfd_copy.
> Another problematic event is the exit() of the process. Here again, the
> external uffd monitor will try to use userfaultfd_copy, although mm owning
> the memory has already gone.
> 
> The first patch in the series is a minor cleanup and it's not strictly
> related to the rest of the series.
> 
> The patches 2 and 3 below add UFFD_EVENT_UNMAP and UFFD_EVENT_EXIT to allow
> the uffd monitor track changes in the memory layout of a process.
> 
> The patches 4 and 5 amend error codes returned by userfaultfd_copy to make
> the uffd monitor able to cope with races that might occur between delivery
> of unmap and exit events and outstanding userfaultfd_copy's.
> 
> The patches are agains current -mm tree.
> 
> Mike Rapoport (5):
>   mm: call vm_munmap in munmap syscall instead of using open coded version
>   userfaultfd: non-cooperative: add event for memory unmaps
>   userfaultfd: non-cooperative: add event for exit() notification
>   userfaultfd: mcopy_atomic: return -ENOENT when no compatible VMA found
>   userfaultfd_copy: return -ENOSPC in case mm has gone
> 
>  arch/tile/mm/elf.c               |  2 +-
>  arch/x86/entry/vdso/vma.c        |  2 +-
>  arch/x86/mm/mpx.c                |  2 +-
>  fs/aio.c                         |  2 +-
>  fs/proc/vmcore.c                 |  4 +-
>  fs/userfaultfd.c                 | 91 ++++++++++++++++++++++++++++++++++++++++
>  include/linux/mm.h               | 14 ++++---
>  include/linux/userfaultfd_k.h    | 25 +++++++++++
>  include/uapi/linux/userfaultfd.h |  8 +++-
>  ipc/shm.c                        |  6 +--
>  kernel/exit.c                    |  2 +
>  mm/mmap.c                        | 55 ++++++++++++++----------
>  mm/mremap.c                      | 23 ++++++----
>  mm/userfaultfd.c                 | 42 ++++++++++---------
>  mm/util.c                        |  5 ++-
>  15 files changed, 215 insertions(+), 68 deletions(-)
> 
> --
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
