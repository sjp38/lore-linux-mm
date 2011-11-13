Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 23BB26B002D
	for <linux-mm@kvack.org>; Sun, 13 Nov 2011 05:18:22 -0500 (EST)
Received: by bke17 with SMTP id 17so5188133bke.14
        for <linux-mm@kvack.org>; Sun, 13 Nov 2011 02:18:18 -0800 (PST)
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v3 0/5] Reduce cross CPU IPI interference
Date: Sun, 13 Nov 2011 12:17:24 +0200
Message-Id: <1321179449-6675-1-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>

We have lots of infrastructure in place to partition a multi-core system such
that we have a group of CPUs that are dedicated to specific task: cgroups,
scheduler and interrupt affinity and cpuisol boot parameter. Still, kernel
code will some time interrupt all CPUs in the system via IPIs for various
needs. These IPIs are useful and cannot be avoided altogether, but in certain
cases it is possible to interrupt only specific CPUs that have useful work to
do and not the entire system.

This patch set, inspired by discussions with Peter Zijlstra and Frederic
Weisbecker when testing the nohz task patch set, is a first stab at trying to
explore doing this by locating the places where such global IPI calls are
being made and turning a global IPI into an IPI for a specific group of CPUs.
The purpose of the patch set is to get feedback if this is the right way to
go for dealing with this issue and indeed, if the issue is even worth dealing
with at all. Based on the feedback from this patch set I plan to offer further
patches that address similar issue in other code paths.

The patch creates an on_each_cpu_mask infrastructure API (derived from
existing arch specific versions in Tile and Arm) and uses it to turn two global
IPI invocation to per CPU group invocations.

This 3rd version incorporates changes due to reviewers feedback.
The major changes from the previous version of the patch are:

- Reverted to the much simpler way of handling cpumask allocation in slub.c
  flush_all() that was used in the first iteration of the patch at the 
  suggestion of Andi K, Christoph L. and Pekka E. after testing with fault 
  injection of memory failure show that this is safe even for CPUMASK_OFFSTACK=y 
  case.

- Rewrote the patch that handles per cpu page caches flush to only try and
  calculate which cpu to IPI when a drain is requested instead of tracking
  the cpus as allocations and deallocation progress, in similar fashion to
  what was done in the other patch for the slub cache at the suggestion of
  Christoph L. and Rik V. The code is now much smaller and touches
  only none fast path code.

The patch was compiled for arm and boot tested on x86 in UP, SMP, with and without 
CONFIG_CPUMASK_OFFSTACK and was further tested by running hackbench on x86 in 
SMP mode in a 4 CPUs VM with no obvious regressions.

I also artificially exercised SLUB flush_all via the debug interface and observed 
the difference in IPI count across processors with and without the patch - from 
an IPI on all processors but one without the patch to a subset (and often no IPI 
at all) with the patch.

I further used fault injection framework to force cpumask alloction failures for
CPUMASK_OFFSTACK=y cases and triggering the code using slub sys debug interface
and running ./hackbench 1000 for page_alloc, with no critical failures.

I believe it's as good as this patch set is going to get :-)

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
Acked-by: Chris Metcalf <cmetcalf@tilera.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Frederic Weisbecker <fweisbec@gmail.com>
CC: Russell King <linux@arm.linux.org.uk>
CC: linux-mm@kvack.org
CC: Christoph Lameter <cl@linux-foundation.org>
CC: Pekka Enberg <penberg@kernel.org>
CC: Matt Mackall <mpm@selenic.com>
CC: Sasha Levin <levinsasha928@gmail.com>
CC: Rik van Riel <riel@redhat.com>
CC: Andi Kleen <andi@firstfloor.org>

Gilad Ben-Yossef (5):
  smp: Introduce a generic on_each_cpu_mask function
  arm: Move arm over to generic on_each_cpu_mask
  tile: Move tile to use generic on_each_cpu_mask
  slub: Only IPI CPUs that have per cpu obj to flush
  mm: Only IPI CPUs to drain local pages if they exist

 arch/arm/kernel/smp_tlb.c   |   20 +++++---------------
 arch/tile/include/asm/smp.h |    7 -------
 arch/tile/kernel/smp.c      |   19 -------------------
 include/linux/smp.h         |   16 ++++++++++++++++
 kernel/smp.c                |   20 ++++++++++++++++++++
 mm/page_alloc.c             |   18 +++++++++++++++++-
 mm/slub.c                   |   15 ++++++++++++++-
 7 files changed, 72 insertions(+), 43 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
