Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 07C6F6B0038
	for <linux-mm@kvack.org>; Sun, 16 Oct 2016 18:07:15 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id d186so88010541lfg.7
        for <linux-mm@kvack.org>; Sun, 16 Oct 2016 15:07:14 -0700 (PDT)
Received: from mail-lf0-x22a.google.com (mail-lf0-x22a.google.com. [2a00:1450:4010:c07::22a])
        by mx.google.com with ESMTPS id g39si16770968ljg.38.2016.10.16.15.07.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Oct 2016 15:07:13 -0700 (PDT)
Received: by mail-lf0-x22a.google.com with SMTP id x79so259590863lff.0
        for <linux-mm@kvack.org>; Sun, 16 Oct 2016 15:07:12 -0700 (PDT)
From: Joel Fernandes <joelaf@google.com>
Subject: Re: [PATCH v3] mm: vmalloc: Replace purge_lock spinlock with atomic refcount
Date: Sun, 16 Oct 2016 15:06:15 -0700
Message-Id: <1476655575-6588-1-git-send-email-joelaf@google.com>
In-Reply-To: <20161016061057.GA26990@infradead.org>
References: <20161016061057.GA26990@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, Joel Fernandes <joelaf@google.com>, Chris Wilson <chris@chris-wilson.co.uk>, Jisheng Zhang <jszhang@marvell.com>, John Dias <joaodias@google.com>, Andrew Morton <akpm@linux-foundation.org>


On Sat, Oct 15, 2016 at 11:10 PM, Christoph Hellwig <hch@infradead.org> wrote:
> On Sat, Oct 15, 2016 at 03:59:34PM -0700, Joel Fernandes wrote:
>> Your patch changes the behavior of the original code I think.
>
> It does.  And it does so as I don't think the existing behavior makes
> sense, as mentioned in the changelog.
>
>> With the
>> patch, for the case where you have 2 concurrent tasks executing
>> alloc_vmap_area function, say both hit the overflow label and enter
>> the __purge_vmap_area_lazy at the same time. The first task empties
>> the purge list and sets nr to the total number of pages of all the
>> vmap areas in the list. Say the first task has just emptied the list
>> but hasn't started freeing the vmap areas and is preempted at this
>> point. Now the second task runs and since the purge list is empty, the
>> second task doesn't have anything to do and immediately returns to
>> alloc_vmap_area. Once it returns, it sets purged to 1 in
>> alloc_vmap_area and retries. Say it hits overflow label again in the
>> retry path. Now because purged was set to 1, it goes to err_free.
>> Without your patch, it would have waited on the spin_lock (sync = 1)
>> instead of just erroring out, so your patch does change the behavior
>> of the original code by not using the purge_lock. I realize my patch
>> also changes the behavior, but in mine I think we can make it behave
>> like the original code by spinning until purging=0 (if sync = 1)
>> because I still have the purging variable..
>
> But for sync = 1 you don't spin on it in any way.  This is the logic
> in your patch:
>
>         if (!sync && !force_flush) {
>                 if (atomic_cmpxchg(&purging, 0, 1))
>                         return;
>         } else
>                 atomic_inc(&purging);

I agree my patch doesn't spin too, I mentioned this above: "I realize my patch
also changes the behavior". However if you dont have too much of a problem with
my use of atomics, then my below new patch handles the case for sync=1 and is
identical in behavior to the original code while still fixing the preempt off
latency issues.

Your patch just got rid of sync completely, I'm not sure if that's Ok to do?
the alloc_vmap_area overflow case was assuming sync=1. The original
alloc_vmap_area code calls purge with sync=1 and waits for pending purges to
complete, instead of erroring out. I wanted to preserve this behavior.

>> Also, could you share your concerns about use of atomic_t in my patch?
>> I believe that since this is not a contented variable, the question of
>> lock fairness is not a concern. It is also not a lock really the way
>> I'm using it, it just keeps track of how many purges are in progress..
>
> atomic_t doesn't have any acquire/release semantics, and will require
> off memory barrier dances to actually get the behavior you intended.
> And from looking at the code I can't really see why we even would
> want synchronization behavior - for the sort of problems where we
> don't want multiple threads to run the same code at the same time
> for effiency but not correctness reasons it's usually better to have
> batch thresholds and/or splicing into local data structures before
> operations.  Both are techniques used in this code, and I'd rather
> rely on them and if required improve on them then using very odd
> hoc synchronization methods.

Thanks for the explanation. If you know of a better way to handle the sync=1
case, let me know. In defense of atomics, even vmap_lazy_nr in the same code is
atomic_t :) I am also not using it as a lock really, but just to count how many
times something is in progress that's all - I added some more comments to my
last patch to make this clearer in the code and now I'm also handling the case
for sync=1.

-----------------8<------------
From: Joel Fernandes <joelaf@google.com>
Date: Sat, 15 Oct 2016 01:04:14 -0700
Subject: [PATCH v4] mm: vmalloc: Replace purge_lock spinlock with atomic refcount

The purge_lock spinlock causes high latencies with non RT kernel. This has been
reported multiple times on lkml [1] [2] and affects applications like audio.

In this patch, I replace the spinlock with an atomic refcount so that
preemption is kept turned on during purge. This Ok to do since [3] builds the
lazy free list in advance and atomically retrieves the list so any instance of
purge will have its own list it is purging. Since the individual vmap area
frees are themselves protected by a lock, this is Ok.

The only thing left is the fact that previously it had trylock behavior, so
preserve that by using the refcount to keep track of in-progress purges and
abort like previously if there is an ongoing purge. Lastly, decrement
vmap_lazy_nr as the vmap areas are freed, and not in advance, so that the
vmap_lazy_nr is not reduced too soon as suggested in [2].

Tests:
x86_64 quad core machine on kernel 4.8, run: cyclictest -p 99 -n
Concurrently in a kernel module, run vmalloc and vfree 8K buffer in a loop.
Preemption configuration: CONFIG_PREEMPT__LL=y (low-latency desktop)

Without patch, cyclictest output:
policy: fifo: loadavg: 0.05 0.01 0.00 1/85 1272          Avg:  128 Max:    1177
policy: fifo: loadavg: 0.11 0.03 0.01 2/87 1447          Avg:  122 Max:    1897
policy: fifo: loadavg: 0.10 0.03 0.01 1/89 1656          Avg:   93 Max:    2886

With patch, cyclictest output:
policy: fifo: loadavg: 1.15 0.68 0.30 1/162 8399         Avg:   92 Max:     284
policy: fifo: loadavg: 1.21 0.71 0.32 2/164 9840         Avg:   94 Max:     296
policy: fifo: loadavg: 1.18 0.72 0.32 2/166 11253        Avg:  107 Max:     321

[1] http://lists.openwall.net/linux-kernel/2016/03/23/29
[2] https://lkml.org/lkml/2016/10/9/59
[3] https://lkml.org/lkml/2016/4/15/287

[thanks Chris for the cond_resched_lock ideas]
Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Jisheng Zhang <jszhang@marvell.com>
Cc: John Dias <joaodias@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Joel Fernandes <joelaf@google.com>
---
v4 changes:
Handle case for when sync=1

Earlier changes:
Fixed ordering of va pointer access and __free_vmap_area
Updated test description in commit message, and typos.

 mm/vmalloc.c | 35 +++++++++++++++++++++++------------
 1 file changed, 23 insertions(+), 12 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 613d1d9..db2791a 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -626,11 +626,11 @@ void set_iounmap_nonlazy(void)
 static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
 					int sync, int force_flush)
 {
-	static DEFINE_SPINLOCK(purge_lock);
+	static atomic_t purging;
 	struct llist_node *valist;
 	struct vmap_area *va;
 	struct vmap_area *n_va;
-	int nr = 0;
+	int dofree = 0;
 
 	/*
 	 * If sync is 0 but force_flush is 1, we'll go sync anyway but callers
@@ -638,10 +638,13 @@ static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
 	 * the case that isn't actually used at the moment anyway.
 	 */
 	if (!sync && !force_flush) {
-		if (!spin_trylock(&purge_lock))
+		/*
+		 * Incase a purge is already in progress, just return.
+		 */
+		if (atomic_cmpxchg(&purging, 0, 1))
 			return;
 	} else
-		spin_lock(&purge_lock);
+		atomic_inc(&purging);
 
 	if (sync)
 		purge_fragmented_blocks_allcpus();
@@ -652,22 +655,30 @@ static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
 			*start = va->va_start;
 		if (va->va_end > *end)
 			*end = va->va_end;
-		nr += (va->va_end - va->va_start) >> PAGE_SHIFT;
+		dofree = 1;
 	}
 
-	if (nr)
-		atomic_sub(nr, &vmap_lazy_nr);
-
-	if (nr || force_flush)
+	if (dofree || force_flush)
 		flush_tlb_kernel_range(*start, *end);
 
-	if (nr) {
+	if (dofree) {
 		spin_lock(&vmap_area_lock);
-		llist_for_each_entry_safe(va, n_va, valist, purge_list)
+		llist_for_each_entry_safe(va, n_va, valist, purge_list) {
+			int nrfree = ((va->va_end - va->va_start) >> PAGE_SHIFT);
 			__free_vmap_area(va);
+			atomic_sub(nrfree, &vmap_lazy_nr);
+			cond_resched_lock(&vmap_area_lock);
+		}
 		spin_unlock(&vmap_area_lock);
 	}
-	spin_unlock(&purge_lock);
+
+	atomic_dec(&purging);
+
+	/*
+	 * If sync is 1, wait for pending purges to be completed.
+	 */
+	while(sync && atomic_read(&purging))
+		cpu_relax();
 }
 
 /*
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
