Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AE0BA8D003A
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 12:21:09 -0500 (EST)
Date: Tue, 18 Jan 2011 09:18:50 -0800
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V1 0/3] drivers/staging: kztmem: dynamic page cache/swap
	compression
Message-ID: <20110118171850.GA20439@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: gregkh@suse.de, chris.mason@oracle.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, matthew@wil.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, kurt.hackel@oracle.com, npiggin@kernel.dk, riel@redhat.com, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, mel@csn.ul.ie, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, sfr@canb.auug.org.au, wfg@mail.ustc.edu.cn, tytso@mit.edu, viro@ZenIV.linux.org.uk, hughd@google.com, hannes@cmpxchg.org
List-ID: <linux-mm.kvack.org>

[PATCH V1 0/3] drivers/staging: kztmem: dynamic page cache/swap compression

HIGH_LEVEL OVERVIEW

Kztmem doubles RAM efficiency while providing a significant
performance boost on many workloads.

Summary for kernel DEVELOPERS: Kztmem uses lzo1x compression to increase
RAM efficiency for both page cache and swap resulting in a significant
performance increase (3-4% or more) on memory-pressured workloads
due to a large reduction in disk I/O.  To do this, kztmem uses an
in-kernel (no virtualization required) implementation of transcendent
memory ("tmem"), which has other proven uses and intriguing future uses
as well.

Summary for kernel MAINTAINERS: Kztmem is a fully-functional,
in-kernel (non-virtualization) implementation of transcendent memory
("tmem"), providing an in-kernel user for cleancache and frontswap.
The patch is based on 2.6.37 and requires either the cleancache patch
or the frontswap patch or both.  The patch is proposed as a staging
driver to obtain broader exposure for further evolution and,
GregKH-willing, is merge-able at the next opportunity. Kztmem will
hopefully also, Linus-and-akpm-willing, remove the barrier to merge-ability
for cleancache and frontswap.  Please note that there is a dependency
on xvmalloc.[ch], currently in drivers/staging/zram.

Want to try it out?  A complete monolithic patch for 2.6.37 including
kztmem, cleancache, and frontswap can be downloaded at:
http://oss.oracle.com/projects/tmem/dist/files/kztmem/kztmem-linux-2.6.37-110117.patch
IMPORTANT NOTE: kztmem must be specified as a kernel boot parameter

This version (V1) has changed considerably from V0, thanks to some
excellent feedback from Jeremy Fitzhardinge.  Feedback from others would
be greatly appreciated.  See "SPECIFIC AREAS FOR HELP/FEEDBACK" below.


"ACADEMIC" OVERVIEW

The objective of all of this code (including previously posted
cleancache and frontswap patches) is to provide a mechanism
by which the kernel can store a potentially huge amount of
certain kinds of page-oriented data so that it (the kernel)
can be more flexible, dynamic, and/or efficient in the amount
of directly-addressable RAM that it uses with little or no loss
of performance and, on some workloads and configuration, even a
substantial increase in performance.

The data store for this page-oriented data, called "page-
addressable memory", or "PAM", is assumed to be 
cheaper, slower, more plentiful, and/or more idiosyncratic
than RAM, but faster, more-expensive, and/or scarcer than disk.
Data in this store is page-addressable only, not byte-addressable,
which increases flexibility for the methods by which the
data can be stored, for example allowing for compression and
efficient deduplication.  Further, the number of pages that
can be stored is entirely dynamic, which allows for multiple
independent data sources to share PAM resources effectively
and securely.

Cleancache and frontswap are data sources for two types of this
page-oriented data: "ephemeral pages" such as clean page cache
pages that can be recovered elsewhere if necessary (e.g. from
disk); and "persistent" pages which are dirty pages that need
a short-term home to survive a brief RAM utilization spike but
need not be permanently saved to survive a reboot (e.g. swap).
The data source "puts" and "gets" pages and is also responsible
for directing coherency, via explicit "flushes" of pages and
related-groups of pages called "objects".

Transcendent memory, or "tmem", is a clean API/ABI that provides
for an efficient address translation layer and a set of highly
concurrent access methods to copy data between the data source
and the PAM data store.  The first tmem implementation is in Xen.
This second tmem implementation is in-kernel (no virtualization
required) but is designed to be easily extensible for KVM or
possibly for cgroups.

A PAM data store must be fast enough to be accessed synchronously
since, when a put/get/flush is invoked by a data source, the
data transfer or invalidation is assumed to be completed on return.
The first PAM is implemented as a secure pool of Xen hypervisor memory
to allow highly-dynamic memory load balancing between guests.
This second PAM implementation uses in-kernel compression to roughly
halve RAM requirements for some workloads.  Future proposed PAM
possibilities include:  fast NVRAM, memory blades, far-far NUMA.
The clean layering provided here should simplify the implementation
of these future PAM data stores for Linux.

THIS PATCHSET

(NOTE: use requires cleancache and/or frontswap patches!)

This patchset provides an in-kernel implementation of transcendent
memory ("tmem") [1] and a PAM implementation where pages are compressed
and kept in kernel space (i.e. no virtualization, neither Xen nor KVM,
is required).

This patch is fully functional, but will benefit from some tuning and
some "policy" implementation.  It demonstrates an in-kernel user for
the cleancache and frontswap patches [2,3] and, in many ways,
supplements/replaces the zram/zcache patches [4,5] with a more
dynamic mechanism.  Though some or all of this code may eventually
belong in mm or lib, this patch places it with staging drivers
so it can obtain exposure as its usage evolves.

The in-kernel transcendent memory implementation (see tmem.c)
conforms to the same ABI as the Xen tmem shim [6] but also provides
a generic interface to be used by one or more page-addressable
memory ("PAM") [7] implementations.  This generic tmem code is
also designed to support multiple "clients", so should be easily
adaptable for KVM or possibly cgroups, allowing multiple guests
to more efficiently "timeshare" physical memory.

Kztmem (see kztmem.c) provides both "host" services (setup and
core memory allocation) for a single client for the generic tmem
code plus two different PAM implementations:

A. "compression buddies" ("zbud") which mates compression with a
   shrinker interface to store ephemeral pages so they can be
   easily reclaimed; compressed pages are paired and stored in
   a physical page, resulting in higher internal fragmentation
B. a shim to xvMalloc [8] which is more space-efficient but
   less receptive to page reclamation, so is fine for persistent
   pages

Both of these use lzo1x compression (see linux/lib/lzo/*).

IMHO, it should be relatively easy to plug in other PAM implementations,
such as: PRAM [9], disaggregated memory [10], or far-far NUMA.

References:
[1] http://oss.oracle.com/projects/tmem 
[2] http://lkml.org/lkml/2010/9/3/383 
[3] https://lkml.org/lkml/2010/9/22/337 
[4] http://lkml.org/lkml/2010/8/9/226 
[5] http://lkml.org/lkml/2010/7/16/161 
[6] http://lkml.org/lkml/2010/9/3/405 
[7] http://marc.info/?l=linux-mm&m=127811271605009 
[8] http://code.google.com/p/compcache/wiki/xvMalloc 
[9] http://www.linuxsymposium.org/2010/view_abstract.php?content_kty=35
[10] http://www.eecs.umich.edu/~tnm/trev_test/dissertationsPDF/kevinL.pdf

SPECIFIC REQUESTED AREAS FOR ADVICE/FEEDBACK

1. Some debugging code and extensive sysfs entries have been left in
   place for this patch so its activity can be easily monitored. I welcome
   other developers to play with it.
2. Little policy is in place (yet) to limit kztmem from eventually
   absorbing all free memory for compressed frontswap pages or
   (if the shrinker isn't "fast enough") compressed cleancache
   pages.  On some workloads and some memory sizes, this eventually
   results in OOMs.  (In my testing, the OOM'ing is not worse, just
   different.)  I'd appreciate feedback on or patches that try
   out various policies.
3. I've studied the GFP flags but am still not fully clear on the best
   combination to use with kztmem memory allocation.  In particular,
   I think "timid" GFP choices result in lower hit rate, while using
   GFP_ATOMIC might be considered rude, but results in a higher hit
   rate and may ve fine for this usage.  I'd appreciate guidance on this.
4. I think I have the irq/softirq/premption code correct but I'm
   definitely a kernel novice in this area, so review would be
   appreciated.
5. Cleancache works best when the "clean working set" is larger
   than the active file cache, but smaller than the memory available
   for cleancache store.  This scenario can be difficult to duplicate
   in a kernel with fixed RAM size. For best results, kztmem may benefit
   from tuning changes to file cache parameters.
6. Benchmarking: Theoretically, kztmem should have a negligible
   worst case performance loss and a substantial best case performance
   gain.  Older processors may show a bigger worst case hit.  I'd
   appreciate any help running workloads on different boxes to better
   characterize worst case and best case performance.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

 drivers/staging/Kconfig         |    2 
 drivers/staging/Makefile        |    1 
 drivers/staging/kztmem/Kconfig  |    8 
 drivers/staging/kztmem/Makefile |    1 
 drivers/staging/kztmem/kztmem.c | 1653 ++++++++++++++++++++++++++++++++++++++++
 drivers/staging/kztmem/tmem.c   |  710 +++++++++++++++++
 drivers/staging/kztmem/tmem.h   |  195 ++++
 7 files changed, 2570 insertions(+)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
