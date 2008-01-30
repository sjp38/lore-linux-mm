Date: Wed, 30 Jan 2008 15:32:22 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: SLUB patches in mm
Message-Id: <20080130153222.e60442de.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0801291947420.22779@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0801291947420.22779@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, penberg@cs.helsinki.fi, matthew@wil.cx
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jan 2008 20:25:15 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> We still have not settled how much and if the performance improvement 
> patches help. The cycle measurements seem only to go so far. I have found 
> some minor regressions and would like to hold most of the performance 
> patches for now. It seems that Intel has an environment in which more 
> detailed performance tests could be run with individual patches.
> 
> Some of them also would be much better with upcoming patchsets 
> (cpu_alloc f.e.) and may not be needed at all if we first go via 
> cpu_alloc.
> 
> Most of the performance patches are only small scale improvements (0.5 - 
> 2%). Test like tbench typically run in an pretty unstable environment 
> (seems that recompiling the kernel with some unrelated patches can cause 
> larger changes than caused by these) and I really do not want to get 
> patches in that needlessly complicate the allocator or cause slight 
> regressions.
> 
> 
> slub-move-count_partial.patch
> slub-rename-numa-defrag_ratio-to-remote_node_defrag_ratio.patch
> slub-consolidate-add_partial-and-add_partial_tail-to-one-function.patch
> 
> Merge (The consolidate-add-partial seems to improve speed by 1-2%. This 
>        was intended for cleanup only but it has a similar effect as the 
>        hackbench fix. It changes the handling of partial slabs slightly 
>        and allows slabs to gather more objects before being used for 
>        allocs again.
>        From that I think we can conclude that work on the 
>        partial list handling could yield some performance gains)
> 
> slub-use-non-atomic-bit-unlock.patch
> 
> Do not merge. Surprisingly removing the atomic operation on unlock seems 
> to cause slight regressions in tbench. I guess it influence the speed with 
> which a cacheline is dropping out of the cpu caches. It improves 
> performance if a single thread is running.
> 
> 
> slub-fix-coding-style-violations.patch
> slub-fix-coding-style-violations-checkpatch-fixes.patch
> 
> Merge (obviously)
> 
> 
> slub-noinline-some-functions-to-avoid-them-being-folded-into-alloc-free.patch
> slub-move-kmem_cache_node-determination-into-add_full-and-add_partial.patch
> 
> Do not merge
> 
> 
> slub-move-kmem_cache_node-determination-into-add_full-and-add_partial-slub-workaround-for-lockdep-confusion.patch
> 
> Merge (this is just a lockdep fix)
> 
> 
> slub-avoid-checking-for-a-valid-object-before-zeroing-on-the-fast-path.patch
> slub-__slab_alloc-exit-path-consolidation.patch
> slub-provide-unique-end-marker-for-each-slab.patch
> slub-provide-unique-end-marker-for-each-slab-fix.patch
> slub-avoid-referencing-kmem_cache-structure-in-__slab_alloc.patch
> slub-optional-fast-path-using-cmpxchg_local.patch
> slub-do-our-own-locking-via-slab_lock-and-slab_unlock.patch
> slub-do-our-own-locking-via-slab_lock-and-slab_unlock-checkpatch-fixes.patch
> slub-do-our-own-locking-via-slab_lock-and-slab_unlock-fix.patch
> slub-restructure-slab-alloc.patch
> 
> Do not merge. cmpxchg_local work still requires preemption 
> disable/enable without cpu_alloc and Intel's tests so far do not show a 
> convincing gain. And the do-our-own-locking series also removes the atomic 
> unlock operation thus causing similar troubles as 
> slub-use-non-atomic-bit-unlock.patch
> 
> 
> slub-comment-kmem_cache_cpu-structure.patch
> 
> Merge
> 
> 
> I have sorted the patches and put them into a git archive on 
> git.kernel.org
> 
> 
> patches to be merged for 2.6.25:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/christoph/vm.git slub-2.6.25
> 
> 
> Performance patches on hold for testing:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/christoph/vm.git performance

I'm inclined to just drop every patch which you've mentioned, let you merge
slub-2.6.25 into Linus's tree and then add git-slub.patch to the -mm
lineup.  OK?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
