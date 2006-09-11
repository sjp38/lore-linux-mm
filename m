Received: from imr2.americas.sgi.com (imr2.americas.sgi.com [198.149.16.18])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k8BMU2nx007936
	for <linux-mm@kvack.org>; Mon, 11 Sep 2006 17:30:02 -0500
Date: Mon, 11 Sep 2006 15:30:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060911223001.5032.24593.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 0/8] Optional ZONE_DMA V1
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Optional ZONE_DMA

This patch follows up on the earlier work in Andrew's tree to reduce
the number of zones. The patches allow to go to a minimum of 2 zones.
This one allows also to make ZONE_DMA optional and therefore the
number of zones can be reduced to one.

ZONE_DMA is usually used for ISA DMA devices. Typically modern hardware
does not have any of these anymore. So we frequently do not need
the zone anymore. The presence of an additional zone unnecessarily
complicates VM operations. It must be scanned and balancing logic
must operate in it etc etc. If one has a 1-1 correspondence between
zones and nodes in a NUMA system then various other optimizations
become possible.

Many systems today (especially 64 bit but also 32 bit machines with less
than 4G of memory) can therefore operate just fine with a single zone.
With a single zone various loops can be optimized away by the
compiler. Many system currently do not place anything in ZONE_DMA. On
most of my systems ZONE_DMA is completely empty. Why constantly look
at an empty zone in /proc/zoneinfo and empty slab in /proc/slabinfo?
Non i386 also frequently have no need for ZONE_DMA and zones stay
empty.

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
