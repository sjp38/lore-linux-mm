Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7BECF6B0035
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 22:47:21 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id y13so1935529pdi.40
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 19:47:21 -0700 (PDT)
Date: Thu, 17 Oct 2013 11:47:27 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2] mm: add a field to store names for private anonymous
 memory
Message-ID: <20131017024727.GB20943@bbox>
References: <1381800678-16515-1-git-send-email-ccross@android.com>
 <1381800678-16515-2-git-send-email-ccross@android.com>
 <20131016003347.GC13007@bbox>
 <CAMbhsRTe9Vwa-zrebuKeJKpy-AhsSeiFD5nKU_-sNd2G2D-+og@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMbhsRTe9Vwa-zrebuKeJKpy-AhsSeiFD5nKU_-sNd2G2D-+og@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@android.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Jan Glauber <jan.glauber@gmail.com>, John Stultz <john.stultz@linaro.org>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Kees Cook <keescook@chromium.org>, "Serge E. Hallyn" <serge.hallyn@ubuntu.com>, David Rientjes <rientjes@google.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Tang Chen <tangchen@cn.fujitsu.com>, Robin Holt <holt@sgi.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Wed, Oct 16, 2013 at 01:00:03PM -0700, Colin Cross wrote:
> On Tue, Oct 15, 2013 at 5:33 PM, Minchan Kim <minchan@kernel.org> wrote:
> > Hello,
> >
> > On Mon, Oct 14, 2013 at 06:31:17PM -0700, Colin Cross wrote:
> >> In many userspace applications, and especially in VM based
> >> applications like Android uses heavily, there are multiple different
> >> allocators in use.  At a minimum there is libc malloc and the stack,
> >> and in many cases there are libc malloc, the stack, direct syscalls to
> >> mmap anonymous memory, and multiple VM heaps (one for small objects,
> >> one for big objects, etc.).  Each of these layers usually has its own
> >> tools to inspect its usage; malloc by compiling a debug version, the
> >> VM through heap inspection tools, and for direct syscalls there is
> >> usually no way to track them.
> >>
> >> On Android we heavily use a set of tools that use an extended version
> >> of the logic covered in Documentation/vm/pagemap.txt to walk all pages
> >> mapped in userspace and slice their usage by process, shared (COW) vs.
> >> unique mappings, backing, etc.  This can account for real physical
> >> memory usage even in cases like fork without exec (which Android uses
> >> heavily to share as many private COW pages as possible between
> >> processes), Kernel SamePage Merging, and clean zero pages.  It
> >> produces a measurement of the pages that only exist in that process
> >> (USS, for unique), and a measurement of the physical memory usage of
> >> that process with the cost of shared pages being evenly split between
> >> processes that share them (PSS).
> >>
> >> If all anonymous memory is indistinguishable then figuring out the
> >> real physical memory usage (PSS) of each heap requires either a pagemap
> >> walking tool that can understand the heap debugging of every layer, or
> >> for every layer's heap debugging tools to implement the pagemap
> >> walking logic, in which case it is hard to get a consistent view of
> >> memory across the whole system.
> >>
> >> This patch adds a field to /proc/pid/maps and /proc/pid/smaps to
> >> show a userspace-provided name for anonymous vmas.  The names of
> >> named anonymous vmas are shown in /proc/pid/maps and /proc/pid/smaps
> >> as [anon:<name>].
> >>
> >> Userspace can set the name for a region of memory by calling
> >> prctl(PR_SET_VMA, PR_SET_VMA_ANON_NAME, start, len, (unsigned long)name);
> >> Setting the name to NULL clears it.
> >>
> >> The name is stored in a user pointer in the shared union in
> >> vm_area_struct that points to a null terminated string inside
> >> the user process.  vmas that point to the same address and are
> >> otherwise mergeable will be merged, but vmas that point to
> >> equivalent strings at different addresses will not be merged.
> >>
> >> The idea to store a userspace pointer to reduce the complexity
> >> within mm (at the expense of the complexity of reading
> >> /proc/pid/mem) came from Dave Hansen.  This results in no
> >> runtime overhead in the mm subsystem other than comparing
> >> the anon_name pointers when considering vma merging.  The pointer
> >> is stored in a union with fields that are only used on file-backed
> >> mappings, so it does not increase memory usage.
> >
> > I'm not against this idea although I don't have review it in detail
> > but we need description to convince why it's hard to be done in
> > userspace.
> 
> I covered the reasoning in more detail at
> http://permalink.gmane.org/gmane.linux.kernel.mm/103228.  The short
> version is that this is useful for a system-wide look at memory,
> combining all processes with the kernel's knowledge of map counts and
> page flags to produce a measurement of what a process' actual impact
> on physical memory usage is.  Doing it in userspace would require
> collating data from every allocator in every process on the system,
> requiring every process to export it somehow, and then reading the
> kernel information anyways to get the mapping info.

I agree that kernel approach would be performance win and make it easy
to collect system-wide information. That's why I am not against the idea
because I think it would be very useful on comtemporary platforms.
But I doubt vma opeartion is proper.

BTW, as Peter and I already asked, maybe other developer in future
will have a question about that so let's remain it in git log.
"Tacking infomrationin userspace leads to all sorts of problems.
...
...
"

> 
> > I guess this feature would be used with allocators tightly
> > so my concern of kernel approach like this that it needs mmap_sem
> > write-side lock to split/merge vmas which is really thing
> > allocators(ex, tcmalloc, jemalloc) want to avoid for performance win
> > that allocators have lots of complicated logic to avoid munmap which
> > needs mmap_sem write-side lock but this feature would make it invalid.
> 
> My expected use case is that the allocator will mmap a new large chunk
> of anonymous memory, and then immediately name it, resulting in taking

It makes new system call very limited.
You are assuming that this new system call should be used very carefully
inside new invented allocator which is aware of naming? So, it allocates
large chunk per name and user have to request memory with naming tag to
allocate object from chunk reserved for the name? Otherwise, large chunk
would be separated per every different name objct and allocator performance
will be drop.

Why couldn't we use it in application layer, not allocator itself?
I mean we can use this following as.

struct js_object *alloc_js_object(void) {
        if (pool_is_empty) {
                struct js_object *obj_pool = malloc(sizeof(obj) * POOL_SIZE);
                prctl(PR_SET_VMA, PR_SET_VMA_ANON_NAME, obj_pool, SIZE, js_name);
        }

        return get_a_object_from_pool(obj_pool);
}

It could work with any allocators which are not aware of naming.
And If pool size is bigger than a chunk, performance lose would be small.

Other some insane user might want to call it per object frequently, even it's
small size under 4K. Why not? The result is that vma scheme couldn't work.

> the mmap_sem twice in a row.  This is the same pattern required for
> example by KSM to mark malloc'd memory as mergeable.  The avoid-munmap

I guess KSM usecase would be very rare compared to naming API because
I dare to expect this feature will be very useful and be popular for lots of
platforms. Actually, our platform is considering such features and some of stack
in our platform already have owned such profiling although it's not system-wide.

Why should we bind the feature into vma? At a glance, vma binding looks good
but the result is 

1) We couldn't avoid write mmap_sem
2) We couldn't represent small size object under 4K.

Couldn't we use another data structure which represent range like
vrange interval tree I and John are implementing?

So the result would be /proc/<pid>/named_anon

It could solve above both problem all but it needs one more system call
to see /proc/<pid>/maps if you need maps information but I imagine that
gathering isn't frequent so it's not a big concern.

> optimization is actually even more important if the allocator names
> memory, creating a new mapping + name would require the mmap_sem
> twice, although the total number of mmap_sem write locks is still
> increased with naming.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
