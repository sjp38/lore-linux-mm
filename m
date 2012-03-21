Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id D68CF6B004D
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 06:06:10 -0400 (EDT)
Received: by yhr47 with SMTP id 47so945079yhr.14
        for <linux-mm@kvack.org>; Wed, 21 Mar 2012 03:06:10 -0700 (PDT)
Date: Wed, 21 Mar 2012 19:06:02 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 00/16] mm: prepare for converting vm->vm_flags to 64-bit
Message-ID: <20120321100602.GA5522@barrios>
References: <20120321065140.13852.52315.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120321065140.13852.52315.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ben Herrenschmidt <benh@kernel.crashing.org>, linux@arm.linux.org.uk

Hi Konstantin,

It seems to be nice clean up to me and you are a volunteer we have been wanted
for a long time. Thanks!
I am one of people who really want to expand vm_flags to 64 bit but when KOSAKI
tried it, Linus said his concerning, I guess you already saw that.

He want to tidy vm_flags's usage up rather than expanding it.
Without the discussion about that, just expanding vm_flags would make us use 
it up easily so that we might need more space. 

Readahead flags are good candidate to move into another space and arch-specific flags, I guess.
Another candidate I think of is THP flag. It's just for only anonymous vma now
(But I am not sure we have a plan to support it for file-backed pages in future)
so we can move it to anon_vma or somewhere.
I think other guys might find more somethings

The point is that at least, we have to discuss about clean up current vm_flags's
use cases before expanding it unconditionally.

On Wed, Mar 21, 2012 at 10:56:07AM +0400, Konstantin Khlebnikov wrote:
> There is good old tradition: every year somebody submit patches for extending
> vma->vm_flags upto 64-bits, because there no free bits left on 32-bit systems.
> 
> previous attempts:
> https://lkml.org/lkml/2011/4/12/24	(KOSAKI Motohiro)
> https://lkml.org/lkml/2010/4/27/23	(Benjamin Herrenschmidt)
> https://lkml.org/lkml/2009/10/1/202	(Hugh Dickins)
> 
> Here already exist special type for this: vm_flags_t, but not all code uses it.
> So, before switching vm_flags_t from unsinged long to u64 we must spread
> vm_flags_t everywhere and fix all possible type-casting problems.
> 
> There is no functional changes in this patch set,
> it only prepares code for vma->vm_flags converting.
> 
> ---
> 
> Konstantin Khlebnikov (16):
>       mm: introduce NR_VMA_FLAGS
>       mm: use vm_flags_t for vma flags
>       mm/shmem: use vm_flags_t for vma flags
>       mm/nommu: use vm_flags_t for vma flags
>       mm/drivers: use vm_flags_t for vma flags
>       mm/x86: use vm_flags_t for vma flags
>       mm/arm: use vm_flags_t for vma flags
>       mm/unicore32: use vm_flags_t for vma flags
>       mm/ia64: use vm_flags_t for vma flags
>       mm/powerpc: use vm_flags_t for vma flags
>       mm/s390: use vm_flags_t for vma flags
>       mm/mips: use vm_flags_t for vma flags
>       mm/parisc: use vm_flags_t for vma flags
>       mm/score: use vm_flags_t for vma flags
>       mm: cast vm_flags_t to u64 before printing
>       mm: vm_flags_t strict type checking
> 
> 
>  arch/arm/include/asm/cacheflush.h                |    5 -
>  arch/arm/kernel/asm-offsets.c                    |    6 +
>  arch/arm/mm/fault.c                              |    2 
>  arch/ia64/mm/fault.c                             |    9 +
>  arch/mips/mm/c-r3k.c                             |    2 
>  arch/mips/mm/c-r4k.c                             |    6 -
>  arch/mips/mm/c-tx39.c                            |    2 
>  arch/parisc/mm/fault.c                           |    4 -
>  arch/powerpc/include/asm/mman.h                  |    2 
>  arch/s390/mm/fault.c                             |    8 +
>  arch/score/mm/cache.c                            |    6 -
>  arch/sh/mm/tlbflush_64.c                         |    2 
>  arch/unicore32/kernel/asm-offsets.c              |    6 +
>  arch/unicore32/mm/fault.c                        |    2 
>  arch/x86/mm/hugetlbpage.c                        |    4 -
>  drivers/char/mem.c                               |    2 
>  drivers/infiniband/hw/ipath/ipath_file_ops.c     |    6 +
>  drivers/infiniband/hw/qib/qib_file_ops.c         |    6 +
>  drivers/media/video/omap3isp/ispqueue.h          |    2 
>  drivers/staging/android/ashmem.c                 |    2 
>  drivers/staging/android/binder.c                 |   15 +-
>  drivers/staging/tidspbridge/core/tiomap3430.c    |   13 +-
>  drivers/staging/tidspbridge/rmgr/drv_interface.c |    4 -
>  fs/binfmt_elf.c                                  |    2 
>  fs/binfmt_elf_fdpic.c                            |   24 ++-
>  fs/exec.c                                        |    2 
>  fs/proc/nommu.c                                  |    3 
>  fs/proc/task_nommu.c                             |   14 +-
>  include/linux/backing-dev.h                      |    7 -
>  include/linux/huge_mm.h                          |    4 -
>  include/linux/ksm.h                              |    8 +
>  include/linux/mm.h                               |  163 +++++++++++++++-------
>  include/linux/mm_types.h                         |   11 +
>  include/linux/mman.h                             |    4 -
>  include/linux/rmap.h                             |    8 +
>  include/linux/shmem_fs.h                         |    5 -
>  kernel/bounds.c                                  |    2 
>  kernel/events/core.c                             |    4 -
>  kernel/fork.c                                    |    2 
>  kernel/sys.c                                     |    4 -
>  mm/backing-dev.c                                 |    4 +
>  mm/huge_memory.c                                 |    2 
>  mm/ksm.c                                         |    4 -
>  mm/madvise.c                                     |    2 
>  mm/memory.c                                      |    9 +
>  mm/mlock.c                                       |    2 
>  mm/mmap.c                                        |   36 ++---
>  mm/mprotect.c                                    |    9 +
>  mm/mremap.c                                      |    2 
>  mm/nommu.c                                       |   19 +--
>  mm/rmap.c                                        |   16 +-
>  mm/shmem.c                                       |   54 ++++---
>  mm/vmscan.c                                      |    4 -
>  53 files changed, 322 insertions(+), 224 deletions(-)
> 
> -- 
> Signature
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
