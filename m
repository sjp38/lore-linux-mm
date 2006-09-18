Date: Mon, 18 Sep 2006 11:36:14 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060918183614.19679.50359.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 0/8] Optional ZONE_DMA V2
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-arch@vger.kernel.org
Cc: Paul Mundt <lethal@linux-sh.org>, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@SteelEye.com>, Arjan van de Ven <arjan@infradead.org>, linux-mm@kvack.org, Russell King <rmk@arm.linux.org.uk>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

Optional ZONE_DMA V2

V1->V2
- Sh sh64 and parisc do not need ZONE_DMA so do not define
  CONFIG_ZONE_DMA for those zones. Add patches for those
  arches to remove the use of ZONE_DMA (untested since
  I do not have those arches).
- Update documentation after feedback from V1.

This patch follows up on the earlier work in Andrew's tree to reduce
the number of zones. The patches allow to go to a minimum of 2 zones.
This one allows also to make ZONE_DMA optional and therefore the
number of zones can be reduced to one.

ZONE_DMA is usually used for ISA DMA devices. There are a number
of reasons why we would not want to have ZONE_DMA

1. Some arches do not need ZONE_DMA at all.

2. With the advent of IOMMUs DMA zones are no longer needed.
   The necessity of DMA zones may drastically be reduced
   in the future. This patchset allows a compilation of
   a kernel without that overhead.

3. Devices that require ISA DMA get rare these days. All
   my systems do not have any need for ISA DMA.

4. The presence of an additional zone unecessarily complicates
   VM operations because it must be scanned and balancing
   logic must operate on its.

5. With only ZONE_NORMAL one can reach the situation where
   we have only one zone. This will allow the unrolling of many
   loops in the VM and allows the optimization of varous
   code paths in the VM.

6. Having only a single zone in a NUMA system results in a
   1-1 correspondence between nodes and zones. Various additional
   optimizations to critical VM paths become possible.

Many systems today can operate just fine with a single zone.
If you look at what is in ZONE_DMA then one usually sees that nothing
uses it. The DMA slabs are empty (Some arches use ZONE_DMA instead
of ZONE_NORMAL, then ZONE_NORMAL will be empty instead).

On all of my systems (i386, x86_64, ia64) ZONE_DMA is completely empty.
Why constantly look at an empty zone in /proc/zoneinfo and empty slab
in /proc/slabinfo?  Non i386 also frequently have no need for ZONE_DMA
and zones stay empty.

The patchset was tested on i386 (UP / SMP), x86_64 (UP, NUMA) and
ia64 (NUMA).

The RFC posted earlier (see
http://marc.theaimsgroup.com/?l=linux-kernel&m=115231723513008&w=2)
had lots of #ifdefs in them. An effort has been made to minize the number
of #ifdefs and make this as compact as possible. The job was made much easier
by the ongoing efforts of others to extract common arch specific functionality.

I have been running this for awhile now on my desktop and finally Linux is
using all my available RAM instead of leaving the 16MB in ZONE_DMA untouched:

christoph@pentium940:~$ cat /proc/zoneinfo
Node 0, zone   Normal
  pages free     4435
        min      1448
        low      1810
        high     2172
        active   241786
        inactive 210170
        scanned  0 (a: 0 i: 0)
        spanned  524224
        present  524224
    nr_anon_pages 61680
    nr_mapped    14271
    nr_file_pages 390264
    nr_slab_reclaimable 27564
    nr_slab_unreclaimable 1793
    nr_page_table_pages 449
    nr_dirty     39
    nr_writeback 0
    nr_unstable  0
    nr_bounce    0
    cpu: 0 pcp: 0
              count: 156
              high:  186
              batch: 31
    cpu: 0 pcp: 1
              count: 9
              high:  62
              batch: 15
  vm stats threshold: 20
    cpu: 1 pcp: 0
              count: 177
              high:  186
              batch: 31
    cpu: 1 pcp: 1
              count: 12
              high:  62
              batch: 15
  vm stats threshold: 20
  all_unreclaimable: 0
  prev_priority:     12
  temp_priority:     12
  start_pfn:         0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
