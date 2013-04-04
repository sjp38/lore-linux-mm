Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id BD7676B0006
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 18:10:57 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 4 Apr 2013 18:10:56 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 23588C90029
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 18:10:54 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r34MAsam308798
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 18:10:54 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r34MAo5i014736
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 19:10:53 -0300
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCHv8 0/8] zswap: compressed swap caching
Date: Thu,  4 Apr 2013 17:10:38 -0500
Message-Id: <1365113446-25647-1-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

This is a refresh for the zswap patchset.  I am submitting this as a
candidate for merging in the v3.10 window. Just a few changes vs v7
and rebase to v3.9-rc5 (see Changelog section for details).

zswap greatly improves performance and reduces swap I/O on systems
in a state of VM thrashing (see details below).  While this might not
seem a likely scenario to those that have full control over the
workloads that run on their systems, it can be very valuable to IaaS
providers that have workloads running in customer managed guests with
undersized RAM allocations.  It is also beneficial in virtualized
environments where the hypervisor either can't do or is not configured
to do I/O QoS and heavy paging by a single guest can drastically increase
I/O latency for all users of the shared I/O.  zswap also helps the
overcommitted guest as well by avoiding throttled swap I/O.

I'll be attending the LSF/MM summit where there (hopefully) will be a
discussion this patchset and memory compression in general.

Zswap Overview:

Zswap is a lightweight compressed cache for swap pages. It takes
pages that are in the process of being swapped out and attempts to
compress them into a dynamically allocated RAM-based memory pool.
If this process is successful, the writeback to the swap device is
deferred and, in many cases, avoided completely.  This results in
a significant I/O reduction and performance gains for systems that
are swapping.

The results of a kernel building benchmark indicate a
runtime reduction of 53% and an I/O reduction 76% with zswap vs normal
swapping with a kernel build under heavy memory pressure (see
Performance section for more).

Some addition performance metrics regarding the performance
improvements and I/O reductions that can be achieved using zswap as
measured by SPECjbb are provided here:
http://ibm.co/VCgHvM

These results include runs on x86 and new results on Power7+ with
hardware compression acceleration.

Of particular note is that zswap is able to evict pages from the compressed
cache, on an LRU basis, to the backing swap device when the compressed pool
reaches it size limit or the pool is unable to obtain additional pages
from the buddy allocator.  This eviction functionality had been identified
as a requirement in prior community discussions.

Patchset Structure:
1-2: add zsmalloc and documentation
3:   add atomic_t get/set to debugfs
4:   add basic zswap functionality
4,5: changes to existing swap code for zswap
6,7: add zswap writeback support
8:   add zswap documentation

Rationale:

Zswap provides compressed swap caching that basically trades CPU cycles
for reduced swap I/O.  This trade-off can result in a significant
performance improvement as reads to/writes from to the compressed
cache almost always faster that reading from a swap device
which incurs the latency of an asynchronous block I/O read.

Some potential benefits:
* Desktop/laptop users with limited RAM capacities can mitigate the
    performance impact of swapping.
* Overcommitted guests that share a common I/O resource can
    dramatically reduce their swap I/O pressure, avoiding heavy
    handed I/O throttling by the hypervisor.  This allows more work
    to get done with less impact to the guest workload and guests
    sharing the I/O subsystem
* Users with SSDs as swap devices can extend the life of the device by
    drastically reducing life-shortening writes.

Compressed swap is also provided in zcache, along with page cache
compression and RAM clustering through RAMSter. Zswap seeks to deliver
the benefit of swap  compression to users in a discrete function.
This design decision is akin to Unix design philosophy of doing one
thing well, it leaves file cache compression and other features
for separate code.

Design:

Zswap receives pages for compression through the Frontswap API and
is able to evict pages from its own compressed pool on an LRU basis
and write them back to the backing swap device in the case that the
compressed pool is full or unable to secure additional pages from
the buddy allocator.

Zswap makes use of zsmalloc for the managing the compressed memory
pool.  This is because zsmalloc is specifically designed to minimize
fragmentation on large (> PAGE_SIZE/2) allocation sizes.  Each
allocation in zsmalloc is not directly accessible by address.
Rather, a handle is return by the allocation routine and that handle
must be mapped before being accessed.  The compressed memory pool grows
on demand and shrinks as compressed pages are freed.  The pool is
not preallocated.

When a swap page is passed from frontswap to zswap, zswap maintains
a mapping of the swap entry, a combination of the swap type and swap
offset, to the zsmalloc handle that references that compressed swap
page.  This mapping is achieved with a red-black tree per swap type.
The swap offset is the search key for the tree nodes.

Zswap seeks to be simple in its policies.  Sysfs attributes allow for
two user controlled policies:
* max_compression_ratio - Maximum compression ratio, as as percentage,
    for an acceptable compressed page. Any page that does not compress
    by at least this ratio will be rejected.
* max_pool_percent - The maximum percentage of memory that the compressed
    pool can occupy.

To enabled zswap, the "enabled" attribute must be set to 1 at boot time.

Zswap allows the compressor to be selected at kernel boot time by
setting the a??compressora?? attribute.  The default compressor is lzo.

A debugfs interface is provided for various statistic about pool size,
number of pages stored, and various counters for the reasons pages
are rejected.

Changelog:

v8:
* Move type field from struct zswap_entry to struct zswap_tree; shrinks per-entry metadata
* Fix load-during-writeback race; double lru add
* checkpatch fixups
* s/NOWAIT/ATOMIC for tree allocation (Dave)
* Check __swap_writepage() for error before incr outstanding write count (Rob)
* Convert pcpu compression buffer alloc from alloc_page() to kmalloc() (Dave)

v7:
* Decrease zswap_stored_pages during tree cleanup (Joonsoo)
* Move zswap_entry_cache_alloc() earlier during store (Joonsoo)
* Move type field from struct zswap_entry to struct zswap_tree
* Change to swapper_space array (-rc1 change)
* s/reset_page_mapcount/page_mapcount_reset in zsmalloc (-rc1 change)
* Rebase to v3.9-rc1

v6:
* fix access-after-free regression introduced in v5
  (rb_erase() outside the lock)
* fix improper freeing of rbtree (Cody)
* fix comment typo (Ric)
* add comments about ZS_MM_WO usage and page mapping mode (Joonsoo)
* don't use page->object (Joonsoo)
* remove DEBUG (Joonsoo)
* rebase to v3.8

v5:
* zsmalloc patch converted from promotion to "new code" (for review only,
  see note in [1/8])
* promote zsmalloc to mm/ instead of /lib
* add more documentation everywhere
* convert USE_PGTABLE_MAPPING to kconfig option, thanks to Minchan
* s/flush/writeback/
* #define pr_fmt() for formatting messages (Joe)
* checkpatch fixups
* lots of changes suggested Minchan

v4:
* Added Acks (Minchan)
* Separated flushing functionality into standalone patch
  for easier review (Minchan)
* fix comment on zswap enabled attribute (Minchan)
* add TODO for dynamic mempool size (Minchan)
* and check for NULL in zswap_free_page() (Minchan)
* add missing zs_free() in error path (Minchan)
* TODO: add comments for flushing/refcounting (Minchan)

v3:
* Dropped the zsmalloc patches from the set, except the promotion patch
  which has be converted to a rename patch (vs full diff).  The dropped
  patches have been Acked and are going into Greg's staging tree soon.
* Separated [PATCHv2 7/9] into two patches since it makes changes for two
  different reasons (Minchan)
* Moved ZSWAP_MAX_OUTSTANDING_FLUSHES near the top in zswap.c (Rik)
* Rebase to v3.8-rc5. linux-next is a little volatile with the
  swapper_space per type changes which will effect this patchset.
* TODO: Move some stats from debugfs to sysfs. Which ones? (Rik)

v2:
* Rename zswap_fs_* functions to zswap_frontswap_* to avoid
  confusion with "filesystem"
* Add comment about what the tree lock protects
* Remove "#if 0" code (should have been done before)
* Break out changes to existing swap code into separate patch
* Fix blank line EOF warning on documentation file
* Rebase to next-20130107

Performance, Kernel Building:

Setup
========
Gentoo w/ kernel v3.7-rc7
Quad-core i5-2500 @ 3.3GHz
512MB DDR3 1600MHz (limited with mem=512m on boot)
Filesystem and swap on 80GB HDD (about 58MB/s with hdparm -t)
majflt are major page faults reported by the time command
pswpin/out is the delta of pswpin/out from /proc/vmstat before and after
the make -jN

Summary
========
* Zswap reduces I/O and improves performance at all swap pressure levels.

* Under heavy swaping at 24 threads, zswap reduced I/O by 76%, saving
  over 1.5GB of I/O, and cut runtime in half.

Details
========
I/O (in pages)
        base                                zswap                                change        change
N        pswpin        pswpout        majflt        I/O sum        pswpin        pswpout        majflt        I/O sum        %I/O        MB
8        1        335        291        627        0        0        249        249        -60%        1
12        3688        14315        5290        23293        123        860        5954        6937        -70%        64
16        12711        46179        16803        75693        2936        7390        46092        56418        -25%        75
20        42178        133781        49898        225857        9460        28382        92951        130793        -42%        371
24        96079        357280        105242        558601        7719        18484        109309        135512        -76%        1653

Runtime (in seconds)
N        base        zswap        %change
8        107        107        0%
12        128        110        -14%
16        191        179        -6%
20        371        240        -35%
24        570        267        -53%

%CPU utilization (out of 400% on 4 cpus)
N        base        zswap        %change
8        317        319        1%
12        267        311        16%
16        179        191        7%
20        94        143        52%
24        60        128        113%


Seth Jennings (8):
  zsmalloc: add to mm/
  zsmalloc: add documentation
  debugfs: add get/set for atomic types
  zswap: add to mm/
  mm: break up swap_writepage() for frontswap backends
  mm: allow for outstanding swap writeback accounting
  zswap: add swap page writeback support
  zswap: add documentation

 Documentation/vm/zsmalloc.txt |   68 +++
 Documentation/vm/zswap.txt    |   82 +++
 fs/debugfs/file.c             |   42 ++
 include/linux/debugfs.h       |    2 +
 include/linux/swap.h          |    4 +
 include/linux/zsmalloc.h      |   56 ++
 mm/Kconfig                    |   39 ++
 mm/Makefile                   |    2 +
 mm/page_io.c                  |   22 +-
 mm/swap_state.c               |    2 +-
 mm/zsmalloc.c                 | 1117 +++++++++++++++++++++++++++++++++++++++
 mm/zswap.c                    | 1153 +++++++++++++++++++++++++++++++++++++++++
 12 files changed, 2583 insertions(+), 6 deletions(-)
 create mode 100644 Documentation/vm/zsmalloc.txt
 create mode 100644 Documentation/vm/zswap.txt
 create mode 100644 include/linux/zsmalloc.h
 create mode 100644 mm/zsmalloc.c
 create mode 100644 mm/zswap.c

-- 
1.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
