Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id CAE476B0035
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 21:51:14 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id v10so12882341pde.12
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 18:51:14 -0700 (PDT)
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
        by mx.google.com with ESMTPS id gg7si31647193pac.123.2014.07.02.18.51.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Jul 2014 18:51:12 -0700 (PDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so13488461pad.7
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 18:51:11 -0700 (PDT)
From: Andy Lutomirski <luto@amacapital.net>
Message-ID: <53B4B70B.5050904@mit.edu>
Date: Wed, 02 Jul 2014 18:51:07 -0700
MIME-Version: 1.0
Subject: Re: [PATCH 00/10] RFC: userfault
References: <1404319816-30229-1-git-send-email-aarcange@redhat.com>
In-Reply-To: <1404319816-30229-1-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "\"Dr. David Alan Gilbert\"" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Linux API <linux-api@vger.kernel.org>

On 07/02/2014 09:50 AM, Andrea Arcangeli wrote:
> Hello everyone,
> 
> There's a large CC list for this RFC because this adds two new
> syscalls (userfaultfd and remap_anon_pages) and
> MADV_USERFAULT/MADV_NOUSERFAULT, so suggestions on changes to the API
> or on a completely different API if somebody has better ideas are
> welcome now.

cc:linux-api -- this is certainly worthy of linux-api discussion.

> 
> The combination of these features are what I would propose to
> implement postcopy live migration in qemu, and in general demand
> paging of remote memory, hosted in different cloud nodes.
> 
> The MADV_USERFAULT feature should be generic enough that it can
> provide the userfaults to the Android volatile range feature too, on
> access of reclaimed volatile pages.
> 
> If the access could ever happen in kernel context through syscalls
> (not not just from userland context), then userfaultfd has to be used
> to make the userfault unnoticeable to the syscall (no error will be
> returned). This latter feature is more advanced than what volatile
> ranges alone could do with SIGBUS so far (but it's optional, if the
> process doesn't call userfaultfd, the regular SIGBUS will fire, if the
> fd is closed SIGBUS will also fire for any blocked userfault that was
> waiting a userfaultfd_write ack).
> 
> userfaultfd is also a generic enough feature, that it allows KVM to
> implement postcopy live migration without having to modify a single
> line of KVM kernel code. Guest async page faults, FOLL_NOWAIT and all
> other GUP features works just fine in combination with userfaults
> (userfaults trigger async page faults in the guest scheduler so those
> guest processes that aren't waiting for userfaults can keep running in
> the guest vcpus).
> 
> remap_anon_pages is the syscall to use to resolve the userfaults (it's
> not mandatory, vmsplice will likely still be used in the case of local
> postcopy live migration just to upgrade the qemu binary, but
> remap_anon_pages is faster and ideal for transferring memory across
> the network, it's zerocopy and doesn't touch the vma: it only holds
> the mmap_sem for reading).
> 
> The current behavior of remap_anon_pages is very strict to avoid any
> chance of memory corruption going unnoticed. mremap is not strict like
> that: if there's a synchronization bug it would drop the destination
> range silently resulting in subtle memory corruption for
> example. remap_anon_pages would return -EEXIST in that case. If there
> are holes in the source range remap_anon_pages will return -ENOENT.
> 
> If remap_anon_pages is used always with 2M naturally aligned
> addresses, transparent hugepages will not be splitted. In there could
> be 4k (or any size) holes in the 2M (or any size) source range,
> remap_anon_pages should be used with the RAP_ALLOW_SRC_HOLES flag to
> relax some of its strict checks (-ENOENT won't be returned if
> RAP_ALLOW_SRC_HOLES is set, remap_anon_pages then will just behave as
> a noop on any hole in the source range). This flag is generally useful
> when implementing userfaults with THP granularity, but it shouldn't be
> set if doing the userfaults with PAGE_SIZE granularity if the
> developer wants to benefit from the strict -ENOENT behavior.
> 
> The remap_anon_pages syscall API is not vectored, as I expect it to be
> used mainly for demand paging (where there can be just one faulting
> range per userfault) or for large ranges (with the THP model as an
> alternative to zapping re-dirtied pages with MADV_DONTNEED with 4k
> granularity before starting the guest in the destination node) where
> vectoring isn't going to provide much performance advantages (thanks
> to the THP coarser granularity).
> 
> On the rmap side remap_anon_pages doesn't add much complexity: there's
> no need of nonlinear anon vmas to support it because I added the
> constraint that it will fail if the mapcount is more than 1. So in
> general the source range of remap_anon_pages should be marked
> MADV_DONTFORK to prevent any risk of failure if the process ever
> forks (like qemu can in some case).
> 
> One part that hasn't been tested is the poll() syscall on the
> userfaultfd because the postcopy migration thread currently is more
> efficient waiting on blocking read()s (I'll write some code to test
> poll() too). I also appended below a patch to trinity to exercise
> remap_anon_pages and userfaultfd and it completes trinity
> successfully.
> 
> The code can be found here:
> 
> git clone --reference linux git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git -b userfault 
> 
> The branch is rebased so you can get updates for example with:
> 
> git fetch && git checkout -f origin/userfault
> 
> Comments welcome, thanks!
> Andrea
> 
> From cbe940e13b4cead41e0f862b3abfa3814f235ec3 Mon Sep 17 00:00:00 2001
> From: Andrea Arcangeli <aarcange@redhat.com>
> Date: Wed, 2 Jul 2014 18:32:35 +0200
> Subject: [PATCH] add remap_anon_pages and userfaultfd
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  include/syscalls-x86_64.h   |   2 +
>  syscalls/remap_anon_pages.c | 100 ++++++++++++++++++++++++++++++++++++++++++++
>  syscalls/syscalls.h         |   2 +
>  syscalls/userfaultfd.c      |  12 ++++++
>  4 files changed, 116 insertions(+)
>  create mode 100644 syscalls/remap_anon_pages.c
>  create mode 100644 syscalls/userfaultfd.c
> 
> diff --git a/include/syscalls-x86_64.h b/include/syscalls-x86_64.h
> index e09df43..a5b3a88 100644
> --- a/include/syscalls-x86_64.h
> +++ b/include/syscalls-x86_64.h
> @@ -324,4 +324,6 @@ struct syscalltable syscalls_x86_64[] = {
>  	{ .entry = &syscall_sched_setattr },
>  	{ .entry = &syscall_sched_getattr },
>  	{ .entry = &syscall_renameat2 },
> +	{ .entry = &syscall_remap_anon_pages },
> +	{ .entry = &syscall_userfaultfd },
>  };
> diff --git a/syscalls/remap_anon_pages.c b/syscalls/remap_anon_pages.c
> new file mode 100644
> index 0000000..b1e9d3c
> --- /dev/null
> +++ b/syscalls/remap_anon_pages.c
> @@ -0,0 +1,100 @@
> +/*
> + * SYSCALL_DEFINE3(remap_anon_pages,
> +		unsigned long, dst_start, unsigned long, src_start,
> +		unsigned long, len)
> + */
> +#include <stdlib.h>
> +#include <asm/mman.h>
> +#include <assert.h>
> +#include "arch.h"
> +#include "maps.h"
> +#include "random.h"
> +#include "sanitise.h"
> +#include "shm.h"
> +#include "syscall.h"
> +#include "tables.h"
> +#include "trinity.h"
> +#include "utils.h"
> +
> +static const unsigned long alignments[] = {
> +	1 * MB, 2 * MB, 4 * MB, 8 * MB,
> +	10 * MB, 100 * MB,
> +};
> +
> +static unsigned char *g_src, *g_dst;
> +static unsigned long g_size;
> +static int g_check;
> +
> +#define RAP_ALLOW_SRC_HOLES (1UL<<0)
> +
> +static void sanitise_remap_anon_pages(struct syscallrecord *rec)
> +{
> +	unsigned long size = alignments[rand() % ARRAY_SIZE(alignments)];
> +	unsigned long max_rand;
> +	if (rand_bool()) {
> +		g_src = mmap(NULL, size, PROT_READ|PROT_WRITE,
> +			     MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
> +	} else
> +		g_src = MAP_FAILED;
> +	if (rand_bool()) {
> +		g_dst = mmap(NULL, size, PROT_READ|PROT_WRITE,
> +			     MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
> +	} else
> +		g_dst = MAP_FAILED;
> +	g_size = size;
> +	g_check = 1;
> +
> +	rec->a1 = (unsigned long) g_dst;
> +	rec->a2 = (unsigned long) g_src;
> +	rec->a3 = g_size;
> +	rec->a4 = 0;
> +
> +	if (rand_bool())
> +		max_rand = -1UL;
> +	else
> +		max_rand = g_size << 1;
> +	if (rand_bool()) {
> +		rec->a3 += (rand() % max_rand) - g_size;
> +		g_check = 0;
> +	}
> +	if (rand_bool()) {
> +		rec->a1 += (rand() % max_rand) - g_size;
> +		g_check = 0;
> +	}
> +	if (rand_bool()) {
> +		rec->a2 += (rand() % max_rand) - g_size;
> +		g_check = 0;
> +	}
> +	if (rand_bool()) {
> +		if (rand_bool()) {
> +			rec->a4 = rand();
> +		} else
> +			rec->a4 = RAP_ALLOW_SRC_HOLES;
> +	}
> +	if (g_src != MAP_FAILED)
> +		memset(g_src, 0xaa, size);
> +}
> +
> +static void post_remap_anon_pages(struct syscallrecord *rec)
> +{
> +	if (g_check && !rec->retval) {
> +		unsigned long size = g_size;
> +		unsigned char *dst = g_dst;
> +		while (size--)
> +			assert(dst[size] == 0xaaU);
> +	}
> +	munmap(g_src, g_size);
> +	munmap(g_dst, g_size);
> +}
> +
> +struct syscallentry syscall_remap_anon_pages = {
> +	.name = "remap_anon_pages",
> +	.num_args = 4,
> +	.arg1name = "dst_start",
> +	.arg2name = "src_start",
> +	.arg3name = "len",
> +	.arg4name = "flags",
> +	.group = GROUP_VM,
> +	.sanitise = sanitise_remap_anon_pages,
> +	.post = post_remap_anon_pages,
> +};
> diff --git a/syscalls/syscalls.h b/syscalls/syscalls.h
> index 114500c..b8eaa63 100644
> --- a/syscalls/syscalls.h
> +++ b/syscalls/syscalls.h
> @@ -370,3 +370,5 @@ extern struct syscallentry syscall_sched_setattr;
>  extern struct syscallentry syscall_sched_getattr;
>  extern struct syscallentry syscall_renameat2;
>  extern struct syscallentry syscall_kern_features;
> +extern struct syscallentry syscall_remap_anon_pages;
> +extern struct syscallentry syscall_userfaultfd;
> diff --git a/syscalls/userfaultfd.c b/syscalls/userfaultfd.c
> new file mode 100644
> index 0000000..769fe78
> --- /dev/null
> +++ b/syscalls/userfaultfd.c
> @@ -0,0 +1,12 @@
> +/*
> + * SYSCALL_DEFINE1(userfaultfd, int, flags)
> + */
> +#include "sanitise.h"
> +
> +struct syscallentry syscall_userfaultfd = {
> +	.name = "userfaultfd",
> +	.num_args = 1,
> +	.arg1name = "flags",
> +	.arg1type = ARG_LEN,
> +	.rettype = RET_FD,
> +};
> 
> 
> Andrea Arcangeli (10):
>   mm: madvise MADV_USERFAULT: prepare vm_flags to allow more than 32bits
>   mm: madvise MADV_USERFAULT
>   mm: PT lock: export double_pt_lock/unlock
>   mm: rmap preparation for remap_anon_pages
>   mm: swp_entry_swapcount
>   mm: sys_remap_anon_pages
>   waitqueue: add nr wake parameter to __wake_up_locked_key
>   userfaultfd: add new syscall to provide memory externalization
>   userfaultfd: make userfaultfd_write non blocking
>   userfaultfd: use VM_FAULT_RETRY in handle_userfault()
> 
>  arch/alpha/include/uapi/asm/mman.h     |   3 +
>  arch/mips/include/uapi/asm/mman.h      |   3 +
>  arch/parisc/include/uapi/asm/mman.h    |   3 +
>  arch/x86/syscalls/syscall_32.tbl       |   2 +
>  arch/x86/syscalls/syscall_64.tbl       |   2 +
>  arch/xtensa/include/uapi/asm/mman.h    |   3 +
>  fs/Makefile                            |   1 +
>  fs/proc/task_mmu.c                     |   5 +-
>  fs/userfaultfd.c                       | 593 +++++++++++++++++++++++++++++++++
>  include/linux/huge_mm.h                |  11 +-
>  include/linux/ksm.h                    |   4 +-
>  include/linux/mm.h                     |   5 +
>  include/linux/mm_types.h               |   2 +-
>  include/linux/swap.h                   |   6 +
>  include/linux/syscalls.h               |   5 +
>  include/linux/userfaultfd.h            |  42 +++
>  include/linux/wait.h                   |   5 +-
>  include/uapi/asm-generic/mman-common.h |   3 +
>  init/Kconfig                           |  10 +
>  kernel/sched/wait.c                    |   7 +-
>  kernel/sys_ni.c                        |   2 +
>  mm/fremap.c                            | 506 ++++++++++++++++++++++++++++
>  mm/huge_memory.c                       | 209 ++++++++++--
>  mm/ksm.c                               |   2 +-
>  mm/madvise.c                           |  19 +-
>  mm/memory.c                            |  14 +
>  mm/mremap.c                            |   2 +-
>  mm/rmap.c                              |   9 +
>  mm/swapfile.c                          |  13 +
>  net/sunrpc/sched.c                     |   2 +-
>  30 files changed, 1447 insertions(+), 46 deletions(-)
>  create mode 100644 fs/userfaultfd.c
>  create mode 100644 include/linux/userfaultfd.h
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
