Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 99C348296B
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 01:18:01 -0400 (EDT)
Received: by labto5 with SMTP id to5so17771560lab.0
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 22:18:00 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id i6si8431684laf.48.2015.03.22.22.17.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 22 Mar 2015 22:17:59 -0700 (PDT)
Date: Sun, 22 Mar 2015 22:17:32 -0700
From: Shaohua Li <shli@fb.com>
Subject: Re: [PATCH] mremap: add MREMAP_NOHOLE flag --resend
Message-ID: <20150323051731.GA2616341@devbig257.prn2.facebook.com>
References: <deaa4139de6e6422a0cec1e3282553aed3495e94.1426626497.git.shli@fb.com>
 <20150318153100.5658b741277f3717b52e42d9@linux-foundation.org>
 <550A5FF8.90504@gmail.com>
 <CADpJO7zBLhjecbiQeTubnTReiicVLr0-K43KbB4uCL5w_dyqJg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CADpJO7zBLhjecbiQeTubnTReiicVLr0-K43KbB4uCL5w_dyqJg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aliaksey Kandratsenka <alkondratenko@gmail.com>
Cc: Daniel Micay <danielmicay@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-api@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andy Lutomirski <luto@amacapital.net>, "google-perftools@googlegroups.com" <google-perftools@googlegroups.com>

On Sat, Mar 21, 2015 at 11:06:14PM -0700, Aliaksey Kandratsenka wrote:
> On Wed, Mar 18, 2015 at 10:34 PM, Daniel Micay <danielmicay@gmail.com>
> wrote:
> >
> > On 18/03/15 06:31 PM, Andrew Morton wrote:
> > > On Tue, 17 Mar 2015 14:09:39 -0700 Shaohua Li <shli@fb.com> wrote:
> > >
> > >> There was a similar patch posted before, but it doesn't get merged.
> I'd like
> > >> to try again if there are more discussions.
> > >> http://marc.info/?l=linux-mm&m=141230769431688&w=2
> > >>
> > >> mremap can be used to accelerate realloc. The problem is mremap will
> > >> punch a hole in original VMA, which makes specific memory allocator
> > >> unable to utilize it. Jemalloc is an example. It manages memory in 4M
> > >> chunks. mremap a range of the chunk will punch a hole, which other
> > >> mmap() syscall can fill into. The 4M chunk is then fragmented, jemalloc
> > >> can't handle it.
> > >
> > > Daniel's changelog had additional details regarding the userspace
> > > allocators' behaviour.  It would be best to incorporate that into your
> > > changelog.
> > >
> > > Daniel also had microbenchmark testing results for glibc and jemalloc.
> > > Can you please do this?
> > >
> > > I'm not seeing any testing results for tcmalloc and I'm not seeing
> > > confirmation that this patch will be useful for tcmalloc.  Has anyone
> > > tried it, or sought input from tcmalloc developers?
> >
> > TCMalloc and jemalloc are currently equally slow in this benchmark, as
> > neither makes use of mremap. They're ~2-3x slower than glibc. I CC'ed
> > the currently most active TCMalloc developer so they can give input
> > into whether this patch would let them use it.
> 
> 
> Hi.
> 
> Thanks for looping us in for feedback (I'm CC-ing gperftools mailing list).
> 
> Yes, that might be useful feature. (Assuming I understood it correctly) I
> believe
> tcmalloc would likely use:
> 
> mremap(old_ptr, move_size, move_size,
>        MREMAP_MAYMOVE | MREMAP_FIXED | MREMAP_NOHOLE,
>        new_ptr);
> 
> as optimized equivalent of:
> 
> memcpy(new_ptr, old_ptr, move_size);
> madvise(old_ptr, move_size, MADV_DONTNEED);
> 
> And btw I find MREMAP_RETAIN name from original patch to be slightly more
> intuitive than MREMAP_NOHOLE. In my humble opinion the later name does not
> reflect semantic of this feature at all (assuming of course I correctly
> understood what the patch does).
> 
> I do have a couple of questions about this approach however. Please feel
> free to
> educate me on them.
> 
> a) what is the smallest size where mremap is going to be faster ?
> 
> My initial thinking was that we'd likely use mremap in all cases where we
> know
> that touching destination would cause minor page faults (i.e. when
> destination
> chunk was MADV_DONTNEED-ed or is brand new mapping). And then also always
> when
> size is large enough, i.e. because "teleporting" large count of pages is
> likely
> to be faster than copying them.
> 
> But now I realize that it is more interesting than that. I.e. because as
> Daniel
> pointed out, mremap holds mmap_sem exclusively, while page faults are
> holding it
> for read. That could be optimized of course. Either by separate "teleport
> ptes"
> syscall (again, as noted by Daniel), or by having mremap drop mmap_sem for
> write
> and retaking it for read for "moving pages" part of work. Being not really
> familiar with kernel code I have no idea if that's doable or not. But it
> looks
> like it might be quite important.

Does mmap_sem contend in your workload? Otherwise, there is no big
difference of read or write lock. memcpy to new allocation could trigger
page fault, new page allocation overhead and etc.
 
> Another aspect where I am similarly illiterate is performance effect of tlb
> flushes needed for such operation.

MADV_DONTNEED does tlb flush too.

> We can certainly experiment and find that limit. But if mremap threshold is
> going to be large, then perhaps this kernel feature is not as useful as we
> may
> hope.

There are a lot of factors here:
For mremap, the overhead:
-mmap sem write lock
-tlb flush

For memcpy + madvise, the overhead:
-memcpy
-new address triggers page fault (allocate new pages, handle page fault)
-is old address MADV_DONTNEED? (tlb flush)

I thought unless allocator only uses memcpy (without madvise, then
allocator will use more memory as necessary) for small size memory
(while memcpy for small size memory is faster than tlb flush), mremap
is a win. We probably can measure the size of memcpy which has smaller
overhead than tlb flush

> b) is that optimization worth having at all ?
> 
> After all, memcpy is actually known to be fast. I understand that copying
> memory
> in user space can be slowed down by minor page faults (results below seem to
> confirm that). But this is something where either allocator may retain
> populated
> pages a bit longer or where kernel could help. E.g. maybe by exposing
> something
> similar to MAP_POPULATE in madvise, or even doing some safe combination of
> madvise and MAP_UNINITIALIZED.

This option will make allocator use more memory than expected.
Eventually the memory must be reclaimed, which has big overhead too.
 
> I've played with Daniel's original benchmark (copied from
> http://marc.info/?l=linux-mm&m=141230769431688&w=2) with some tiny
> modifications:
> 
> #include <string.h>
> #include <stdlib.h>
> #include <stdio.h>
> #include <sys/mman.h>
> 
> int main(int argc, char **argv)
> {
>         if (argc > 1 && strcmp(argv[1], "--mlock") == 0) {
>                 int rv = mlockall(MCL_CURRENT | MCL_FUTURE);
>                 if (rv) {
>                         perror("mlockall");
>                         abort();
>                 }
>                 puts("mlocked!");
>         }
> 
>         for (size_t i = 0; i < 64; i++) {
>                 void *ptr = NULL;
>                 size_t old_size = 0;
>                 for (size_t size = 4; size < (1 << 30); size *= 2) {
>                         /*
>                          * void *hole = malloc(1 << 20);
>                          * if (!hole) {
>                          *      perror("malloc");
>                          *      abort();
>                          * }
>                          */
>                         ptr = realloc(ptr, size);
>                         if (!ptr) {
>                                 perror("realloc");
>                                 abort();
>                         }
>                         /* free(hole); */
>                         memset(ptr + old_size, 0xff, size - old_size);
>                         old_size = size;
>                 }
>                 free(ptr);
>         }
> }
> 
> I cannot say if this benchmark's vectors of up to 0.5 gigs are common in
> important applications or not. It can be argued that apps that care about
> such
> large vectors can do mremap themselves.
> 
> On the other hand, I believe that this micro benchmark could be plausibly
> changed to grow vector by smaller factor (i.e. see
> https://github.com/facebook/folly/blob/master/folly/docs/FBVector.md#memory-handling).
> And
> with smaller growth factor, is seems reasonable to expect larger overhead
> from
> memcpy and smaller overhead from mremap. And thus favor mremap more.
> 
> And I confirm that with all default settings tcmalloc and jemalloc lose to
> glibc. Also, notably, recent dev build of jemalloc (what is going to be 4.0
> AFAIK) actually matches or exceeds glibc speed, despite still not doing
> mremap. Apparently it is smarter about avoiding moving allocation for those
> realloc-s. And it was even able to resist my attempt to force it to move
> allocation. I haven't investigated why. Note that I built it couple weeks
> or so
> ago from dev branch, so it might simply have bugs.
> 
> Results also vary greatly depending in transparent huge pages setting.
> Here's
> what I've got:
> 
> allocator |   mode    | time  | sys time | pgfaults |             extra
> ----------+-----------+-------+----------+----------+-------------------------------
> glibc     |           | 10.75 |     8.44 |  8388770 |
> glibc     |    thp    |  5.67 |     3.44 |   310882 |
> glibc     |   mlock   | 13.22 |     9.41 |  8388821 |
> glibc     | thp+mlock |  8.43 |     4.63 |   310933 |
> tcmalloc  |           | 11.46 |     2.00 |  2104826 |
> TCMALLOC_AGGRESSIVE_DECOMMIT=f
> tcmalloc  |    thp    | 10.61 |     0.89 |   386206 |
> TCMALLOC_AGGRESSIVE_DECOMMIT=f
> tcmalloc  |   mlock   | 10.11 |     0.27 |   264721 |
> TCMALLOC_AGGRESSIVE_DECOMMIT=f
> tcmalloc  | thp+mlock | 10.28 |     0.17 |    46011 |
> TCMALLOC_AGGRESSIVE_DECOMMIT=f
> tcmalloc  |           | 23.63 |    17.16 | 16770107 |
> TCMALLOC_AGGRESSIVE_DECOMMIT=t
> tcmalloc  |    thp    | 11.82 |     5.14 |   352477 |
> TCMALLOC_AGGRESSIVE_DECOMMIT=t
> tcmalloc  |   mlock   | 10.10 |     0.28 |   264724 |
> TCMALLOC_AGGRESSIVE_DECOMMIT=t
> tcmalloc  | thp+mlock | 10.30 |     0.17 |    49168 |
> TCMALLOC_AGGRESSIVE_DECOMMIT=t
> jemalloc1 |           | 23.71 |    17.33 | 16744572 |
> jemalloc1 |    thp    | 11.65 |     4.68 |    64988 |
> jemalloc1 |   mlock   | 10.13 |     0.29 |   263305 |
> jemalloc1 | thp+mlock | 10.05 |     0.17 |    50217 |
> jemalloc2 |           | 10.87 |     8.64 |  8521796 |
> jemalloc2 |    thp    |  4.64 |     2.32 |    56060 |
> jemalloc2 |   mlock   |  4.22 |     0.28 |   263181 |
> jemalloc2 | thp+mlock |  4.12 |     0.19 |    50411 |
> ----------+-----------+-------+----------+----------+-------------------------------
> 
> NOTE: usual disclaimer applies about possibility of screwing something up
> and
> getting invalid benchmark results without being able to see it. I apologize
> in
> advance.
> 
> NOTE: jemalloc1 is 3.6 as shipped by up-to-date Debian Sid. jemalloc2 is
> home-built snapshot of upcoming jemalloc 4.0.
> 
> NOTE: TCMALLOC_AGGRESSIVE_DECOMMIT=t (and default since 2.4) makes tcmalloc
> MADV_DONTNEED large free blocks immediately. As opposed to less rare with
> setting of "false". And it makes big difference on page faults counts and
> thus
> on runtime.
> 
> Another notable thing is how mlock effectively disables MADV_DONTNEED for
> jemalloc{1,2} and tcmalloc, lowers page faults count and thus improves
> runtime. It can be seen that tcmalloc+mlock on thp-less configuration is
> slightly better on runtime to glibc. The later spends a ton of time in
> kernel,
> probably handling minor page faults, and the former burns cpu in user space
> doing memcpy-s. So "tons of memcpys" seems to be competitive to what glibc
> is
> doing in this benchmark.

mlock disables MADV_DONTNEED, so this is an unfair comparsion. With it,
allocator will use more memory than expected.

I'm kind of confused why we talk about THP, mlock here. When application
uses allocator, it doesn't need to be forced to use THP or mlock. Can we
forcus on normal case?

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
