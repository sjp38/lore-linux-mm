Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9A94B6B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 17:47:23 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id ma3so9352262pbc.21
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 14:47:23 -0700 (PDT)
Received: by mail-oa0-f46.google.com with SMTP id g12so1827791oah.5
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 14:47:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1381800678-16515-2-git-send-email-ccross@android.com>
References: <1381800678-16515-1-git-send-email-ccross@android.com>
	<1381800678-16515-2-git-send-email-ccross@android.com>
Date: Tue, 15 Oct 2013 14:47:19 -0700
Message-ID: <CAMbhsRTvxgoXBDkXQhxHnmZpXE3Atz3d9xAs8a7k1wj-+br5+g@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: add a field to store names for private anonymous memory
From: Colin Cross <ccross@android.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lkml <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Jan Glauber <jan.glauber@gmail.com>, John Stultz <john.stultz@linaro.org>
Cc: Colin Cross <ccross@android.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Kees Cook <keescook@chromium.org>, "Serge E. Hallyn" <serge.hallyn@ubuntu.com>, David Rientjes <rientjes@google.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Tang Chen <tangchen@cn.fujitsu.com>, Robin Holt <holt@sgi.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Mon, Oct 14, 2013 at 6:31 PM, Colin Cross <ccross@android.com> wrote:
> In many userspace applications, and especially in VM based
> applications like Android uses heavily, there are multiple different
> allocators in use.  At a minimum there is libc malloc and the stack,
> and in many cases there are libc malloc, the stack, direct syscalls to
> mmap anonymous memory, and multiple VM heaps (one for small objects,
> one for big objects, etc.).  Each of these layers usually has its own
> tools to inspect its usage; malloc by compiling a debug version, the
> VM through heap inspection tools, and for direct syscalls there is
> usually no way to track them.
>
> On Android we heavily use a set of tools that use an extended version
> of the logic covered in Documentation/vm/pagemap.txt to walk all pages
> mapped in userspace and slice their usage by process, shared (COW) vs.
> unique mappings, backing, etc.  This can account for real physical
> memory usage even in cases like fork without exec (which Android uses
> heavily to share as many private COW pages as possible between
> processes), Kernel SamePage Merging, and clean zero pages.  It
> produces a measurement of the pages that only exist in that process
> (USS, for unique), and a measurement of the physical memory usage of
> that process with the cost of shared pages being evenly split between
> processes that share them (PSS).
>
> If all anonymous memory is indistinguishable then figuring out the
> real physical memory usage (PSS) of each heap requires either a pagemap
> walking tool that can understand the heap debugging of every layer, or
> for every layer's heap debugging tools to implement the pagemap
> walking logic, in which case it is hard to get a consistent view of
> memory across the whole system.
>
> This patch adds a field to /proc/pid/maps and /proc/pid/smaps to
> show a userspace-provided name for anonymous vmas.  The names of
> named anonymous vmas are shown in /proc/pid/maps and /proc/pid/smaps
> as [anon:<name>].
>
> Userspace can set the name for a region of memory by calling
> prctl(PR_SET_VMA, PR_SET_VMA_ANON_NAME, start, len, (unsigned long)name);
> Setting the name to NULL clears it.
>
> The name is stored in a user pointer in the shared union in
> vm_area_struct that points to a null terminated string inside
> the user process.  vmas that point to the same address and are
> otherwise mergeable will be merged, but vmas that point to
> equivalent strings at different addresses will not be merged.
>
> The idea to store a userspace pointer to reduce the complexity
> within mm (at the expense of the complexity of reading
> /proc/pid/mem) came from Dave Hansen.  This results in no
> runtime overhead in the mm subsystem other than comparing
> the anon_name pointers when considering vma merging.  The pointer
> is stored in a union with fields that are only used on file-backed
> mappings, so it does not increase memory usage.
>
> Signed-off-by: Colin Cross <ccross@android.com>
> ---
>
> v2: updates the commit message to explain in more detail why the
>     patch is useful.
> v3: renames vma_get_anon_name to vma_anon_name
>     replaces logic in seq_print_vma_name with access_process_vm
>     removes Name: entry from smaps, it's already on the header line
>     changes the prctl option number to match what is currently in
>        use on Android
>
>  Documentation/filesystems/proc.txt |  2 ++
>  fs/proc/task_mmu.c                 | 22 +++++++++++++++
>  include/linux/mm.h                 |  5 +++-
>  include/linux/mm_types.h           | 15 +++++++++++
>  include/uapi/linux/prctl.h         |  3 +++
>  kernel/sys.c                       | 24 +++++++++++++++++
>  mm/madvise.c                       | 55 +++++++++++++++++++++++++++++++++++---
>  mm/mempolicy.c                     |  2 +-
>  mm/mlock.c                         |  3 ++-
>  mm/mmap.c                          | 44 +++++++++++++++++-------------
>  mm/mprotect.c                      |  3 ++-
>  11 files changed, 152 insertions(+), 26 deletions(-)
>

<snip>

> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 7431001..7cca5e6 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -728,7 +728,7 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
>                         ((vmstart - vma->vm_start) >> PAGE_SHIFT);
>                 prev = vma_merge(mm, prev, vmstart, vmend, vma->vm_flags,
>                                   vma->anon_vma, vma->vm_file, pgoff,
> -                                 new_pol);
> +                                 new_pol, vma_anon_name(name));

Dumb typo here that snuck back in, this should be vma_anon_name(vma).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
