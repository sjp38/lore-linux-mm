Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 29BAF6B0258
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 12:47:45 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id c200so226275089wme.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 09:47:45 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id o202si42223308wmd.33.2016.02.17.09.47.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 09:47:43 -0800 (PST)
Date: Wed, 17 Feb 2016 09:47:07 -0800
From: Shaohua Li <shli@fb.com>
Subject: Re: [PATCH V4][for-next]mm: add a new vector based madvise syscall
Message-ID: <20160217174654.GA3505386@devbig084.prn1.facebook.com>
References: <d01698140a51cf9b2ce233c7574c2ece9f6fa241.1449791762.git.shli@fb.com>
 <20160216160802.50ceaf10aa16588e18b3d2c5@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="4bRzO86E/ozDv8r1"
Content-Disposition: inline
In-Reply-To: <20160216160802.50ceaf10aa16588e18b3d2c5@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-api@vger.kernel.org, Kernel-team@fb.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Jason Evans <je@fb.com>

--4bRzO86E/ozDv8r1
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline

On Tue, Feb 16, 2016 at 04:08:02PM -0800, Andrew Morton wrote:
> On Thu, 10 Dec 2015 16:03:37 -0800 Shaohua Li <shli@fb.com> wrote:
> 
> > In jemalloc, a free(3) doesn't immediately free the memory to OS even
> > the memory is page aligned/size, and hope the memory can be reused soon.
> > Later the virtual address becomes fragmented, and more and more free
> > memory are aggregated. If the free memory size is large, jemalloc uses
> > madvise(DONT_NEED) to actually free the memory back to OS.
> > 
> > The madvise has significantly overhead paritcularly because of TLB
> > flush. jemalloc does madvise for several virtual address space ranges
> > one time. Instead of calling madvise for each of the ranges, we
> > introduce a new syscall to purge memory for several ranges one time. In
> > this way, we can merge several TLB flush for the ranges to one big TLB
> > flush. This also reduce mmap_sem locking and kernel/userspace switching.
> > 
> > I'm running a simple memory allocation benchmark. 32 threads do random
> > malloc/free/realloc.
> 
> CPU count?  (Does that matter much?)

32. It does. the tlb flush overhead depends on the cpu count. 
> > Corresponding jemalloc patch to utilize this API is
> > attached.
> 
> No it isn't ;)

Sorry, I attached it in first post, but not this one. Attached is the
one I tested against this patch.

> Who maintains jemalloc?  Are they signed up to actually apply the
> patch?  It would be bad to add the patch to the kernel and then find
> that the jemalloc maintainers choose not to use it!

Jason Evans (cced) is the author of jemalloc. I talked to him before, he
is very positive to this new syscall.

> > Without patch:
> > real    0m18.923s
> > user    1m11.819s
> > sys     7m44.626s
> > each cpu gets around 3000K/s TLB flush interrupt. Perf shows TLB flush
> > is hotest functions. mmap_sem read locking (because of page fault) is
> > also heavy.
> > 
> > with patch:
> > real    0m15.026s
> > user    0m48.548s
> > sys     6m41.153s
> > each cpu gets around 140k/s TLB flush interrupt. TLB flush isn't hot at
> > all. mmap_sem read locking (still because of page fault) becomes the
> > sole hot spot.
> 
> This is a somewhat underwhelming improvement, given that it's a
> synthetic microbenchmark.

Yes, this test does malloc, free, calloc, realloc, so it doesn't only
benchmark the madvisev.
> > Another test malloc a bunch of memory in 48 threads, then all threads
> > free the memory. I measure the time of the memory free.
> > Without patch: 34.332s
> > With patch:    17.429s
> 
> This is more whelming.
> 
> Do we have a feel for how much benefit this patch will have for
> real-world workloads?  That's pretty important.

Sure, we'll post some real-world data.
> > MADV_FREE does the same TLB flush as MADV_NEED, this also applies to
> 
> I'll do s/MADV_NEED/MADV_DONTNEED/
> 
> > MADV_FREE. Other madvise type can have small benefits too, like reduce
> > syscalls/mmap_sem locking.
> 
> Could we please get a testcase for the syscall(s) into
> tools/testing/selftests/vm?  For long-term maintenance reasons and as a
> service to arch maintainers - make it easy for them to check the
> functionality without having to roll their own (possibly incomplete)
> test app.
> 
> I'm not sure *how* we'd develop a test case.  Use mincore()?

Ok, I'll add this later.
> > --- a/mm/madvise.c
> > +++ b/mm/madvise.c
> > @@ -21,7 +21,10 @@
> >  #include <linux/swap.h>
> >  #include <linux/swapops.h>
> >  #include <linux/mmu_notifier.h>
> > -
> > +#include <linux/uio.h>
> > +#ifdef CONFIG_COMPAT
> > +#include <linux/compat.h>
> > +#endif
> 
> I'll nuke the ifdefs - compat.h already does that.
> 
> 
> It would be good for us to have a look at the manpage before going too
> far with the patch - this helps reviewers to think about the proposed
> interface and behaviour.
> 
> I'll queue this up for a bit of testing, although it won't get tested
> much.  The syscall fuzzers will presumably hit on it.

Thanks!

--4bRzO86E/ozDv8r1
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: attachment; filename="je.patch"

diff --git a/src/arena.c b/src/arena.c
index 43733cc..5c1a3b3 100644
--- a/src/arena.c
+++ b/src/arena.c
@@ -1266,6 +1266,7 @@ arena_dirty_count(arena_t *arena)
 	return (ndirty);
 }
 
+#define PURGE_VEC 1
 static size_t
 arena_compute_npurge(arena_t *arena, bool all)
 {
@@ -1280,6 +1281,10 @@ arena_compute_npurge(arena_t *arena, bool all)
 		threshold = threshold < chunk_npages ? chunk_npages : threshold;
 
 		npurge = arena->ndirty - threshold;
+#if PURGE_VEC
+		if (npurge < arena->ndirty / 2)
+			npurge = arena->ndirty / 2;
+#endif
 	} else
 		npurge = arena->ndirty;
 
@@ -1366,6 +1371,31 @@ arena_stash_dirty(arena_t *arena, chunk_hooks_t *chunk_hooks, bool all,
 	return (nstashed);
 }
 
+#if PURGE_VEC
+int mycomp(const void *a, const void *b)
+{
+	unsigned long a_b = (unsigned long)((struct iovec *)a)->iov_base;
+	unsigned long b_b = (unsigned long)((struct iovec *)b)->iov_base;
+
+	if (a_b < b_b)
+		return -1;
+	if (a_b > b_b)
+		return 1;
+	return 0;
+}
+
+#define MAX_IOVEC 32
+bool pages_purge_vec(struct iovec *iov, unsigned long nr_segs)
+{
+	int ret;
+
+	qsort(iov, nr_segs, sizeof(struct iovec), mycomp);
+	ret = syscall(327, iov, nr_segs, MADV_DONTNEED);
+
+	return !!ret;
+}
+#endif
+
 static size_t
 arena_purge_stashed(arena_t *arena, chunk_hooks_t *chunk_hooks,
     arena_runs_dirty_link_t *purge_runs_sentinel,
@@ -1374,6 +1404,10 @@ arena_purge_stashed(arena_t *arena, chunk_hooks_t *chunk_hooks,
 	size_t npurged, nmadvise;
 	arena_runs_dirty_link_t *rdelm;
 	extent_node_t *chunkselm;
+#if PURGE_VEC
+	struct iovec iovec[MAX_IOVEC];
+	int vec_index = 0;
+#endif
 
 	if (config_stats)
 		nmadvise = 0;
@@ -1418,9 +1452,21 @@ arena_purge_stashed(arena_t *arena, chunk_hooks_t *chunk_hooks,
 				flag_unzeroed = 0;
 				flags = CHUNK_MAP_DECOMMITTED;
 			} else {
+#if !PURGE_VEC
 				flag_unzeroed = chunk_purge_wrapper(arena,
 				    chunk_hooks, chunk, chunksize, pageind <<
 				    LG_PAGE, run_size) ? CHUNK_MAP_UNZEROED : 0;
+#else
+				flag_unzeroed = 0;
+				iovec[vec_index].iov_base = (void *)((uintptr_t)chunk +
+					(pageind << LG_PAGE));
+				iovec[vec_index].iov_len = run_size;
+				vec_index++;
+				if (vec_index >= MAX_IOVEC) {
+					pages_purge_vec(iovec, vec_index);
+					vec_index = 0;
+				}
+#endif
 				flags = flag_unzeroed;
 			}
 			arena_mapbits_large_set(chunk, pageind+npages-1, 0,
@@ -1449,6 +1495,10 @@ arena_purge_stashed(arena_t *arena, chunk_hooks_t *chunk_hooks,
 		if (config_stats)
 			nmadvise++;
 	}
+#if PURGE_VEC
+	if (vec_index > 0)
+		pages_purge_vec(iovec, vec_index);
+#endif
 	malloc_mutex_lock(&arena->lock);
 
 	if (config_stats) {

--4bRzO86E/ozDv8r1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
