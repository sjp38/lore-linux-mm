Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 5C1E06B005A
	for <linux-mm@kvack.org>; Sun,  8 Jan 2012 11:27:53 -0500 (EST)
Received: by eekc41 with SMTP id c41so2165247eek.14
        for <linux-mm@kvack.org>; Sun, 08 Jan 2012 08:27:51 -0800 (PST)
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v6 0/8] Reduce cross CPU IPI interference
Date: Sun,  8 Jan 2012 18:26:58 +0200
Message-Id: <1326040026-7285-1-git-send-email-gilad@benyossef.com>
In-Reply-To: <y>
References: <y>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.org>, Kosaki Motohiro <kosaki.motohiro@gmail.com>

We have lots of infrastructure in place to partition a multi-core systems
such that we have a group of CPUs that are dedicated to specific task:
cgroups, scheduler and interrupt affinity and cpuisol boot parameter.
Still, kernel code will some time interrupt all CPUs in the system via IPIs
for various needs. These IPIs are useful and cannot be avoided altogether,
but in certain cases it is possible to interrupt only specific CPUs that
have useful work to do and not the entire system.

This patch set, inspired by discussions with Peter Zijlstra and Frederic
Weisbecker when testing the nohz task patch set, is a first stab at trying
to explore doing this by locating the places where such global IPI calls
are being made and turning a global IPI into an IPI for a specific group
of CPUs.  The purpose of the patch set is to get feedback if this is the
right way to go for dealing with this issue and indeed, if the issue is
even worth dealing with at all. Based on the feedback from this patch set
I plan to offer further patches that address similar issue in other code
paths.

The patch creates an on_each_cpu_mask and on_each_cpu_conf infrastructure 
API (the former derived from existing arch specific versions in Tile and 
Arm) and and uses them to turn several global IPI invocation to per CPU 
group invocations.

This 6th iteration includes the following changes:

- In case of cpumask allocation failure, have on_each_cpu_cond
  send an IPI to each needed CPU seperately via 
  smp_call_function_single so no cpumask var is needed, as 
  suggested by Andrew Morton.
- Document why on_each_cpu_mask need to check the mask even on
  UP in a code comment, as suggested by Andrew Morton.
- Various typo cleanup in patch descriptions

The patch set also available from the ipi_noise_v6 branch at
git://github.com/gby/linux.git

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
CC: Christoph Lameter <cl@linux.com>
CC: Chris Metcalf <cmetcalf@tilera.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Frederic Weisbecker <fweisbec@gmail.com>
CC: linux-mm@kvack.org
CC: Pekka Enberg <penberg@kernel.org>
CC: Matt Mackall <mpm@selenic.com>
CC: Sasha Levin <levinsasha928@gmail.com>
CC: Rik van Riel <riel@redhat.com>
CC: Andi Kleen <andi@firstfloor.org>
CC: Mel Gorman <mel@csn.ul.ie>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Alexander Viro <viro@zeniv.linux.org.uk>
CC: Avi Kivity <avi@redhat.com>
CC: Michal Nazarewicz <mina86@mina86.org>
CC: Kosaki Motohiro <kosaki.motohiro@gmail.com>

Gilad Ben-Yossef (8):
  smp: Introduce a generic on_each_cpu_mask function
  arm: move arm over to generic on_each_cpu_mask
  tile: move tile to use generic on_each_cpu_mask
  smp: add func to IPI cpus based on parameter func
  slub: only IPI CPUs that have per cpu obj to flush
  fs: only send IPI to invalidate LRU BH when needed
  mm: only IPI CPUs to drain local pages if they exist
  mm: add vmstat counters for tracking PCP drains

 arch/arm/kernel/smp_tlb.c     |   20 +++----------
 arch/tile/include/asm/smp.h   |    7 -----
 arch/tile/kernel/smp.c        |   19 -------------
 fs/buffer.c                   |   15 ++++++++++-
 include/linux/smp.h           |   38 ++++++++++++++++++++++++++
 include/linux/vm_event_item.h |    1 +
 kernel/smp.c                  |   58 +++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c               |   31 +++++++++++++++++++++-
 mm/slub.c                     |   10 ++++++-
 mm/vmstat.c                   |    2 +
 10 files changed, 157 insertions(+), 44 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
