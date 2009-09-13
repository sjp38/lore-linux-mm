Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id AE7DC6B004F
	for <linux-mm@kvack.org>; Sun, 13 Sep 2009 09:25:39 -0400 (EDT)
Date: Sun, 13 Sep 2009 14:24:58 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] mmap:  avoid unnecessary anon_vma lock acquisition in
 vma_adjust()
In-Reply-To: <1252527046.4102.162.camel@useless.americas.hpqcorp.net>
Message-ID: <Pine.LNX.4.64.0909131332280.22041@sister.anvils>
References: <1252527046.4102.162.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Eric Whitney <eric.whitney@hp.com>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

[I've kept stable@kernel.org in the Cc list only to put on record
that I don't think that this patch is really suitable for -stable]

On Wed, 9 Sep 2009, Lee Schermerhorn wrote:
> 
Thanks for this.  Interesting stuff snipped and repeated below.

> 
> A comment in mm/mmap.c:vma_adjust() suggests that we don't really
> need the anon_vma lock when we're only adjusting the end of a vma,

I feel a warm smugness from having foreseen the possibility that we
might want to optimize that away.  I didn't do so, because it needs
more thought (and more branches) than seemed worthwhile at the time:
you've found similar difficulty, but now it does seem worthwhile.

> We can detect this condition--no overlap with next vma--by noting
> a NULL "importer".  The anon_vma pointer will also be NULL in this
> case, so simply avoid loading vma->anon_vma to avoid the lock.
> However, we apparently DO need to take the anon_vma lock when
> we're inserting a vma ['insert' non-NULL] even when we have no
> overlap [NULL "importer"], so we need to check for 'insert', as well.

Those importer and insert checks are good and relevant, but not
quite enough.  The anon_vma lock should also be guaranteeing the
integrity of the relationship between vm_start and vm_pgoff for
all the vmas attached to the anon_vma, so that rmap.c can rely
upon vma_address() to work correctly while it holds anon_vma lock.

That's a considerably less important consideration than the integrity
of the list threading itself.  Anything BUGging on a wrong page->index
is holding mmap_sem, which would keep vma_adjust off.  So it's just a
matter of whether rmap.c can be expected to find all instances of a
page at all times, which nothing absolutely requires (and in checking
this patch, I notice fs/exec.c's shift_arg_pages() use of vma_adjust()
a little violatory in that respect).

But it is something the anon_vma lock has protected in the past,
and it shouldn't affect your sbrk() case at all, so I'd like to
check we're not changing vm_start too (vm_pgoff should be changing
with it, but shift_arg_pages() deals with that in a different way,
keeping vm_pgoff unchanged but shifting the pages).

(Compare with how stack's expand_downwards() has anon_vma_lock()
when it adjusts vm_start and vm_pgoff - though that's also because
it has only down_read of mmap_sem, not the down_write we'd usually
require for such adjustments.)

> 
> I have tested with and without the 'file || ' test in the patch.
> This does not seem to matter for stability nor performance.  I
> left this check/filter in, so we only optimize away the
> anon_vma lock acquisition when adjusting the end of a non-
> importing, non-inserting, anon vma.

I dislike that: the "file" test just has no relevance at all
(beyond that you've no interest in the case when there is a file),
and two years down the line will make people like me worry for
hours on end what it's there for.  I've removed it below.

> 
> If accepted, this patch may benefit the stable tree as well.

We seem to have a different perception of what the stable tree is for!
But I'm not against any distro picking up this patch if it chooses.
Here's a version with my signoff:


[PATCH] mmap: avoid unnecessary anon_vma lock acquisition in vma_adjust()

From: Lee Schermerhorn <lee.schermerhorn@hp.com>

We noticed very erratic behavior [throughput] with the AIM7 shared
workload running on recent distro [SLES11] and mainline kernels on
an 8-socket, 32-core, 256GB x86_64 platform.  On the SLES11 kernel
[2.6.27.19+] with Barcelona processors, as we increased the load
[10s of thousands of tasks], the throughput would vary between two
"plateaus"--one at ~65K jobs per minute and one at ~130K jpm.  The
simple patch below causes the results to smooth out at the ~130k
plateau.

But wait, there's more:

We do not see this behavior on smaller platforms--e.g., 4 socket/8
core.  This could be the result of the larger number of cpus on
the larger platform--a scalability issue--or it could be the result
of the larger number of interconnect "hops" between some nodes in
this platform and how the tasks for a given load end up distributed
over the nodes' cpus and memories--a stochastic NUMA effect.

The variability in the results are less pronounced [on the same
platform] with Shanghai processors and with mainline kernels.  With
31-rc6 on Shanghai processors and 288 file systems on 288 fibre
attached storage volumes, the curves [jpm vs load] are both quite
flat with the patched kernel consistently producing ~3.9% better
throughput [~80K jpm vs ~77K jpm] than the unpatched kernel.

Profiling indicated that the "slow" runs were incurring high[er]
contention on an anon_vma lock in vma_adjust(), apparently called
from the sbrk() system call.

The patch:

A comment in mm/mmap.c:vma_adjust() suggests that we don't really
need the anon_vma lock when we're only adjusting the end of a vma,
as is the case for brk().  The comment questions whether it's worth
while to optimize for this case.  Apparently, on the newer, larger
x86_64 platforms, with interesting NUMA topologies, it is worth
while--especially considering that the patch [if correct!] is 
quite simple.

We can detect this condition--no overlap with next vma--by noting
a NULL "importer".  The anon_vma pointer will also be NULL in this
case, so simply avoid loading vma->anon_vma to avoid the lock.

However, we DO need to take the anon_vma lock when we're inserting a
vma ['insert' non-NULL] even when we have no overlap [NULL "importer"],
so we need to check for 'insert', as well.  And Hugh points out that
we should also take it when adjusting vm_start (so that rmap.c can
rely upon vma_address() while it holds the anon_vma lock).

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Nick Piggin <npiggin@suse.de>
Cc: Eric Whitney <eric.whitney@hp.com>
---

 mm/mmap.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- 2.6.31/mm/mmap.c	2009-09-09 23:13:59.000000000 +0100
+++ linux/mm/mmap.c	2009-09-13 13:08:40.000000000 +0100
@@ -570,9 +570,9 @@ again:			remove_next = 1 + (end > next->
 
 	/*
 	 * When changing only vma->vm_end, we don't really need
-	 * anon_vma lock: but is that case worth optimizing out?
+	 * anon_vma lock.
 	 */
-	if (vma->anon_vma)
+	if (vma->anon_vma && (insert || importer || start != vma->vm_start))
 		anon_vma = vma->anon_vma;
 	if (anon_vma) {
 		spin_lock(&anon_vma->lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
