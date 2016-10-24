Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 473186B025E
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:42:41 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id y138so24113674wme.7
        for <linux-mm@kvack.org>; Sun, 23 Oct 2016 21:42:41 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v83si10132603wmv.63.2016.10.23.21.42.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Oct 2016 21:42:40 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9O4d6ql044839
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:42:38 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2692jqfyr1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:42:38 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 24 Oct 2016 14:42:34 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 3D67A3578056
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:42:32 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9O4gW3X196946
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:42:32 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9O4gVXN030245
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:42:32 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [DEBUG 00/10] Test and debug patches for coherent device memory
Date: Mon, 24 Oct 2016 10:12:19 +0530
In-Reply-To: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
Message-Id: <1477284149-2976-1-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

	Coherent device memory support has been experimented around on
POWER platform with simulations and QEMU changes. This series contains
patches which can be classified into three categories.

(1) Memory less node hot plug support
(2) Identifying coherent device nodes during NUMA init
(3) Debug patches to observe zonelists information
(4) Test drivers and scripts

	Patch (2) could have been part of the RFC series but because of the
dependency on patch (1), it goes here. Now lets look at the how all these
components work.

Before Hotplug
==============
NUMACTL Information:
--------------------
available: 5 nodes (0-4)
node 0 cpus: 0 1 2 5 6 20 21 23 27 28 31 32 37 38 39 43 44 48 49 50 51 52
53 54 55 56 57 58 59 60 61 62
node 0 size: 4059 MB
node 0 free: 2956 MB
node 1 cpus: 3 4 7 8 9 10 11 12 13 14 15 16 17 18 19 22 24 25 26 29 30 33
34 35 36 40 41 42 45 46 47 63
node 1 size: 4091 MB
node 1 free: 3920 MB
node 2 cpus:
node 2 size: 0 MB
node 2 free: 0 MB
node 3 cpus:
node 3 size: 0 MB
node 3 free: 0 MB
node 4 cpus:
node 4 size: 0 MB
node 4 free: 0 MB
node distances:
node   0   1   2   3   4 
  0:  10  40  40  40  40 
  1:  40  10  40  40  40 
  2:  40  40  10  40  40 
  3:  40  40  40  10  40 
  4:  40  40  40  40  10 

ZONELIST Information
--------------------
[NODE (0)]
        ZONELIST_FALLBACK (0xc00000000140da00)
                (0) (node 0) (DMA     0xc00000000140c000)
                (1) (node 1) (DMA     0xc000000100000000)
        ZONELIST_NOFALLBACK (0xc000000001411a10)
                (0) (node 0) (DMA     0xc00000000140c000)
[NODE (1)]
        ZONELIST_FALLBACK (0xc000000100001a00)
                (0) (node 1) (DMA     0xc000000100000000)
                (1) (node 0) (DMA     0xc00000000140c000)
        ZONELIST_NOFALLBACK (0xc000000100005a10)
                (0) (node 1) (DMA     0xc000000100000000)
[NODE (2)]
        ZONELIST_FALLBACK (0xc000000001427700)
                (0) (node 0) (DMA     0xc00000000140c000)
                (1) (node 1) (DMA     0xc000000100000000)
        ZONELIST_NOFALLBACK (0xc00000000142b710)
[NODE (3)]
        ZONELIST_FALLBACK (0xc000000001431400)
                (0) (node 0) (DMA     0xc00000000140c000)
                (1) (node 1) (DMA     0xc000000100000000)
        ZONELIST_NOFALLBACK (0xc000000001435410)
[NODE (4)]
        ZONELIST_FALLBACK (0xc00000000143b100)
                (0) (node 0) (DMA     0xc00000000140c000)
                (1) (node 1) (DMA     0xc000000100000000)
        ZONELIST_NOFALLBACK (0xc00000000143f110)

After Hotplug
=============
NUMACTL Information:
--------------------
available: 5 nodes (0-4)
node 0 cpus: 0 1 2 5 6 20 21 23 27 28 31 32 37 38 39 43 44 48 49 50 51 52
53 54 55 56 57 58 59 60 61 62
node 0 size: 4059 MB
node 0 free: 2804 MB
node 1 cpus: 3 4 7 8 9 10 11 12 13 14 15 16 17 18 19 22 24 25 26 29 30 33
34 35 36 40 41 42 45 46 47 63
node 1 size: 4091 MB
node 1 free: 3860 MB
node 2 cpus:
node 2 size: 4096 MB
node 2 free: 4095 MB
node 3 cpus:
node 3 size: 4096 MB
node 3 free: 4095 MB
node 4 cpus:
node 4 size: 4096 MB
node 4 free: 4095 MB
node distances:
node   0   1   2   3   4 
  0:  10  40  40  40  40 
  1:  40  10  40  40  40 
  2:  40  40  10  40  40 
  3:  40  40  40  10  40 
  4:  40  40  40  40  10 

ZONELIST Information:
---------------------
[NODE (0)]
        ZONELIST_FALLBACK (0xc00000000140da00)
                (0) (node 0) (DMA     0xc00000000140c000)
                (1) (node 1) (DMA     0xc000000100000000)
        ZONELIST_NOFALLBACK (0xc000000001411a10)
                (0) (node 0) (DMA     0xc00000000140c000)
[NODE (1)]
        ZONELIST_FALLBACK (0xc000000100001a00)
                (0) (node 1) (DMA     0xc000000100000000)
                (1) (node 0) (DMA     0xc00000000140c000)
        ZONELIST_NOFALLBACK (0xc000000100005a10)
                (0) (node 1) (DMA     0xc000000100000000)
[NODE (2)]
        ZONELIST_FALLBACK (0xc000000001427700)
                (0) (node 2) (Movable 0xc000000001427080)
                (1) (node 0) (DMA     0xc00000000140c000)
                (2) (node 1) (DMA     0xc000000100000000)
        ZONELIST_NOFALLBACK (0xc00000000142b710)
                (0) (node 2) (Movable 0xc000000001427080)
[NODE (3)]
        ZONELIST_FALLBACK (0xc000000001431400)
                (0) (node 3) (Movable 0xc000000001430d80)
                (1) (node 0) (DMA     0xc00000000140c000)
                (2) (node 1) (DMA     0xc000000100000000)
        ZONELIST_NOFALLBACK (0xc000000001435410)
                (0) (node 3) (Movable 0xc000000001430d80)
[NODE (4)]
        ZONELIST_FALLBACK (0xc00000000143b100)
                (0) (node 4) (Movable 0xc00000000143aa80)
                (1) (node 0) (DMA     0xc00000000140c000)
                (2) (node 1) (DMA     0xc000000100000000)
        ZONELIST_NOFALLBACK (0xc00000000143f110)
                (0) (node 4) (Movable 0xc00000000143aa80)

	After the coherent device memory nodes have been hot plugged into
the kernel, did some simple VMA migration tests to verify it's stability.
cdm_migration.sh does the actual test of moving VMAs of ebizzy workload
which results in the following stats and traces.

Results:
-------
passed 13
failed 0
queuef 0
empty 3
missing 0

Traces:
-------
migrate_virtual_range: 55094 10000000 10010000 0: migration_passed
migrate_virtual_range: 55094 10010000 10020000 0: migration_passed
migrate_virtual_range: 55094 10020000 10030000 3: migration_passed
migrate_virtual_range: 55094 3fff3b6a0000 3fff8b3c0000 0: list_empty
migrate_virtual_range: 55094 3fff8b3c0000 3fff8b580000 1: migration_passed
migrate_virtual_range: 55094 3fff8b580000 3fff8b590000 2: migration_passed
migrate_virtual_range: 55094 3fff8b590000 3fff8b5a0000 0: migration_passed
migrate_virtual_range: 55094 3fff8b5a0000 3fff8b5c0000 2: migration_passed
migrate_virtual_range: 55094 3fff8b5c0000 3fff8b5d0000 2: migration_passed
migrate_virtual_range: 55094 3fff8b5d0000 3fff8b5e0000 0: migration_passed
migrate_virtual_range: 55094 3fff8b5e0000 3fff8b5f0000 0: list_empty
migrate_virtual_range: 55094 3fff8b5f0000 3fff8b610000 3: list_empty
migrate_virtual_range: 55094 3fff8b610000 3fff8b640000 3: migration_passed
migrate_virtual_range: 55094 3fff8b640000 3fff8b650000 2: migration_passed
migrate_virtual_range: 55094 3fff8b650000 3fff8b660000 1: migration_passed
migrate_virtual_range: 55094 3ffff25e0000 3ffff2610000 1: migration_passed

Anshuman Khandual (6):
  powerpc/mm: Identify isolation seeking coherent memory nodes during boot
  mm: Export definition of 'zone_names' array through mmzone.h
  mm: Add debugfs interface to dump each node's zonelist information
  powerpc: Enable CONFIG_MOVABLE_NODE for PPC64 platform
  drivers: Add two drivers for coherent device memory tests
  test: Add a script to perform random VMA migrations across nodes

Reza Arbab (4):
  dt-bindings: Add doc for ibm,hotplug-aperture
  powerpc/mm: Create numa nodes for hotplug memory
  powerpc/mm: Allow memory hotplug into a memory less node
  mm: Enable CONFIG_MOVABLE_NODE on powerpc

 .../bindings/powerpc/opal/hotplug-aperture.txt     |  26 ++
 Documentation/kernel-parameters.txt                |   2 +-
 arch/powerpc/Kconfig                               |   4 +
 arch/powerpc/mm/numa.c                             |  43 ++-
 drivers/char/Kconfig                               |  23 ++
 drivers/char/Makefile                              |   2 +
 drivers/char/coherent_hotplug_demo.c               | 133 ++++++++
 drivers/char/coherent_memory_demo.c                | 337 +++++++++++++++++++++
 drivers/char/memory_online_sysfs.h                 | 148 +++++++++
 include/linux/mmzone.h                             |   1 +
 mm/Kconfig                                         |   2 +-
 mm/memory.c                                        |  63 ++++
 mm/migrate.c                                       |  10 +
 mm/page_alloc.c                                    |   2 +-
 tools/testing/selftests/vm/cdm_migration.sh        |  76 +++++
 15 files changed, 855 insertions(+), 17 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/powerpc/opal/hotplug-aperture.txt
 create mode 100644 drivers/char/coherent_hotplug_demo.c
 create mode 100644 drivers/char/coherent_memory_demo.c
 create mode 100644 drivers/char/memory_online_sysfs.h
 create mode 100755 tools/testing/selftests/vm/cdm_migration.sh

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
