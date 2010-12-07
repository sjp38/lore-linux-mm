Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DF0A06B0087
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 13:07:01 -0500 (EST)
Date: Tue, 7 Dec 2010 10:06:23 -0800
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V0 0/4] kztmem: page cache/swap compression via in-kernel
	transcendent memory and page-accessible memory
Message-ID: <20101207180623.GA28097@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: chris.mason@oracle.com, akpm@linux-foundation.org, matthew@wil.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, kurt.hackel@oracle.com, npiggin@kernel.dk, riel@redhat.com, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, mel@csn.ul.ie, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

[PATCH V0 0/4] kztmem: page cache/swap compression via in-kernel transcendent memory and page-accessible memory

(Several people have asked about the status of this so I decided
to post it in its (sadly) unfinished state.  It is beyond the RFC stage
but I have no illusion that it is fully ready yet, so have compromised
by posting it as a "version 0" patch.  Note that if you want
to try it for yourself and help get it into a final state, you need
the cleanache and/or frontswap patch to drive data to it. --djm)

MOTIVATION AND OVERVIEW

The objective of all of this code (including previously posted
cleancache and frontswap patches) is to provide a mechanism
by which the kernel can store a potentially huge amount of
certain kinds of page-oriented data so that it (the kernel)
can be more flexible, dynamic, and/or efficient in the amount
of directly-addressable RAM that it uses with little or no loss
(and even possibly some increase) of performance.

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
for directing coherency, via explicit "flushes" of pages.

Transcendent memory, or "tmem", is a clean API/ABI that provides
for an efficient address translation layer and a set of highly
concurrent access methods to copy data between the data source
and the PAM data store.  The first tmem implementation is in Xen.
This second tmem implementation is in-kernel and is designed to
be easily extensible for KVM or possibly for cgroups.

A PAM data store must be fast enough to be accessed synchronously
since, when a put/get/flush is invoked by a data source, the
data transfer or invalidation is assumed to be complete.
The first PAM is implemented as a pool of Xen hypervisor memory
to allow highly-dynamic memory load balancing between guests.
This second PAM implementation uses in-kernel compression to roughly
halve RAM requirements for some workloads.  Future proposed PAM
possibilities include:  fast NVRAM, memory blades, far-far NUMA.

THIS PATCHSET

(NOTE: build/use requires cleancache and/or frontswap patches!)

This patchset provides an in-kernel implementation for transcendent
memory ("tmem") [1] and a PAM implementation where pages are compressed
and kept in kernel space (i.e. no virtualization, neither Xen nor KVM,
is required).

This first draft works, but will require some tuning and some
"policy" implementation.  It demonstrates an in-kernel user for
the cleancache and frontswap patches [2,3] and, in many ways,
supplements/replaces the zram/zcache patches [4,5] with a more
dynamic mechanism.  Though some or all of this code may eventually
belong in mm or lib, this patch places it with staging drivers.

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

Both of these use lzo1x compression (see lib/lzo/*.*).

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

Known flame-attractants:
1. The tmem implementation relies on a simplified version of the
   radix tree code in lib.  Though this risks a lecture from akpm
   on code reuse, IMHO the existing radix tree code has become over-
   specialized, so to avoid interminable discussion on how to genericize
   radix-tree.c and the probable resultant bug tail, tmem uses its
   own version, called sadix-tree.c.  A high-level diff list is
   included in that file.
2. The tmem code is designed for high concurrency, but shrinking
   interactions cause a severe challenge for locking.  After fighting
   with this for a long time, I fell back to a solution where
   the shrinking code locks out all other processors trying to do
   tmem accesses.  This is a bit ugly, but works, and since
   shrinker calls are relatively infrequent, may be a fine solution.
3. Extensive debugging code and sysfs entries have been left in place
   for this draft as it is still a work-in-progress and I welcome
   other developers to play with it.
4. Little policy is in place (yet) to limit kztmem from eventually
   absorbing all free memory for compressed frontswap pages or
   (if the shrinker isn't "fast enough") compressed cleancache
   pages.  On some workloads and some memory sizes, this eventually
   results in OOMs.  I'd appreciate feedback on or patches that try
   out some policies.
5. Cleancache works best when the "clean working set" is larger
   than the active file cache, but smaller than the memory available
   for cleancache store.  This scenario can be difficult to duplicate
   in a kernel with fixed RAM size. For best results, kztmem may require
   tuning changes to file cache parameters.
6. I've had trouble tracking down a one or more remaining heisenbugs where
   some data (even local variables!) seem to get randomly trashed, resulting
   in crashes.  I'm suspecting a compiler bug (gcc 4.1.2), but have managed
   to sometimes get around it with "-fno-inline-functions-called-once"
   *IF YOUR* kztmem-enabled kernel fails to boot, try adding this parameter
   to the KBUILD_CFLAGS in your kernel Makefile.  If you see this
   and your debugging skills are better than mine (likely), I've left some
   debug markers (c.f. ifdef WEIRD_BUG) that might help.  There is a possibly
   related bug involving rbtrees marked with BROKEN_OID_COMPARE.
   
Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

 drivers/staging/Kconfig             |    2 
 drivers/staging/Makefile            |    1 
 drivers/staging/kztmem/Kconfig      |    8 
 drivers/staging/kztmem/Makefile     |    1 
 drivers/staging/kztmem/kztmem.c     | 1318 ++++++++++++++++++++++++++++++++++
 drivers/staging/kztmem/sadix-tree.c |  349 +++++++++
 drivers/staging/kztmem/sadix-tree.h |   82 ++
 drivers/staging/kztmem/tmem.c       | 1375 ++++++++++++++++++++++++++++++++++++
 drivers/staging/kztmem/tmem.h       |  135 +++
 9 files changed, 3271 insertions(+)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
