Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 642F06B004D
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 16:10:45 -0400 (EDT)
Subject: [PATCH] mmap:  avoid unnecessary anon_vma lock acquisition in
 vma_adjust()
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Wed, 09 Sep 2009 16:10:46 -0400
Message-Id: <1252527046.4102.162.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, stable <stable@kernel.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>


Against:  2.6.31-rc6

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
However, we apparently DO need to take the anon_vma lock when
we're inserting a vma ['insert' non-NULL] even when we have no
overlap [NULL "importer"], so we need to check for 'insert', as well.

I have tested with and without the 'file || ' test in the patch.
This does not seem to matter for stability nor performance.  I
left this check/filter in, so we only optimize away the
anon_vma lock acquisition when adjusting the end of a non-
importing, non-inserting, anon vma.

If accepted, this patch may benefit the stable tree as well.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/mmap.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6.31-rc6/mm/mmap.c
===================================================================
--- linux-2.6.31-rc6.orig/mm/mmap.c	2009-08-19 14:34:13.000000000 -0400
+++ linux-2.6.31-rc6/mm/mmap.c	2009-08-19 14:53:24.000000000 -0400
@@ -573,9 +573,9 @@ again:			remove_next = 1 + (end > next->
 
 	/*
 	 * When changing only vma->vm_end, we don't really need
-	 * anon_vma lock: but is that case worth optimizing out?
+	 * anon_vma lock.
 	 */
-	if (vma->anon_vma)
+	if ((file || insert || importer) && vma->anon_vma)
 		anon_vma = vma->anon_vma;
 	if (anon_vma) {
 		spin_lock(&anon_vma->lock);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
