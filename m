Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id DA8109000BD
	for <linux-mm@kvack.org>; Sun, 25 Sep 2011 04:55:44 -0400 (EDT)
Received: by yia25 with SMTP id 25so4842409yia.14
        for <linux-mm@kvack.org>; Sun, 25 Sep 2011 01:55:44 -0700 (PDT)
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH 0/5] Reduce cross CPU IPI interference
Date: Sun, 25 Sep 2011 11:54:45 +0300
Message-Id: <1316940890-24138-1-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

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
The purpose of the patch set is to get  feedback if this is the right way to 
go for dealing with this issue and indeed, if the issue is even worth dealing 
with at all.

This first version creates an on_each_cpu_mask infrastructure API (derived from 
existing arch specific versions in Tile and Arm) and uses it to turn two global 
IPI invocation to per CPU group invocations.

The patch is against 3.1-rc4 and was compiled for x86 and arm in both UP and 
SMP mode (I could not get Tile to build, regardless of this patch) and was 
further tested by running hackbench on x86 in SMP mode in a 4 CPUs VM. No
obvious regression where noted, but I obviously did not test this quite enough.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Frederic Weisbecker <fweisbec@gmail.com>
CC: Russell King <linux@arm.linux.org.uk>
CC: Chris Metcalf <cmetcalf@tilera.com>
CC: linux-mm@kvack.org
CC: Christoph Lameter <cl@linux-foundation.org>
CC: Pekka Enberg <penberg@kernel.org>
CC: Matt Mackall <mpm@selenic.com>

 Ben-Yossef (5):
  Introduce a generic on_each_cpu_mask function
  Move arm over to generic on_each_cpu_mask
  Move tile to use generic on_each_cpu_mask
  Only IPI CPUs to drain local pages if they exist
  slub: only IPI CPUs that have per cpu obj to flush

 arch/arm/kernel/smp_tlb.c   |   20 ++++------------
 arch/tile/include/asm/smp.h |    7 -----
 arch/tile/kernel/smp.c      |   19 ---------------
 include/linux/smp.h         |   14 +++++++++++
 kernel/smp.c                |   20 ++++++++++++++++
 mm/page_alloc.c             |   53 +++++++++++++++++++++++++++++++++++-------
 mm/slub.c                   |   15 +++++++++++-
 7 files changed, 97 insertions(+), 51 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
