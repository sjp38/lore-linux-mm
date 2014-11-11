Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 33382900014
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 09:59:31 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id p10so10152198pdj.5
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 06:59:30 -0800 (PST)
Received: from mail-pd0-x234.google.com (mail-pd0-x234.google.com. [2607:f8b0:400e:c02::234])
        by mx.google.com with ESMTPS id cc14si20218880pac.137.2014.11.11.06.59.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 06:59:29 -0800 (PST)
Received: by mail-pd0-f180.google.com with SMTP id ft15so10241811pdb.11
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 06:59:29 -0800 (PST)
From: SeongJae Park <sj38.park@gmail.com>
Subject: [RFC v1 0/6] introduce gcma
Date: Wed, 12 Nov 2014 00:00:04 +0900
Message-Id: <1415718010-18663-1-git-send-email-sj38.park@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: lauraa@codeaurora.org, minchan@kernel.org, sergey.senozhatsky@gmail.com, linux-mm@kvack.org, SeongJae Park <sj38.park@gmail.com>

Abstract
========

Current cma(contiguous memory allocator) could not guarantee success and fast
latency of contiguous allocation.
This coverletter explains about the problem in detail and suggest new
contiguous memory allocator, gcma(guaranteed contiguous allocator).



CMA: Contiguous Memory Allocator
================================


Basic idea of cma
-----------------

Basic idea of cma is as follows. It focuses on memory efficiency while keeping
contiguous allocation could be done without serious penalty.

 - Reserves large contiguous memory area during boot and let the area could be
   used by contiguous allocation.
 - Because system memory could be inefficient if the reserved memory is not
   fully utilized by contiguous allocation, let the area could be allocated for
   2nd-class clients
 - If pages being allocated for 2nd-class clients are necessary for contiguous
   allocation(doubtless 1st class client), migrates or discard the page and use
   them for contiguous allocation.

In cma, _2nd-class client_ is movable page. The reserved area could be
allocated for movable pages and the movable pages be migrated or discarded if
contiguous allocation needs them.


Problem of cma
--------------

This cma mechanism imposes following weaknesses.

1. Allocation failure
CMA could fail to allocate contiguous memory due to following reasons.
1-1. Direct pinning
Any kernel thread could pin any movable pages for a long time. If a movable
page which needs to be migrated for a contiguous memory allocation is already
pinned by someone, migration could not be completed. In consequence, contiguous
allocation could be fail if the page is not be unpinned longtime.
1-2. Indirect pin
If a movable page have dependency with an object, the object would increase
reference count of the movable page to assert it is safe to use the page. If a
movable page which is needs to be migrated for a contiguous memory allocation
is in the case, the page could not be free to be used by contiguous allocation.
In consequence, contiguous allocation could be failed.

2. High cost
Contiguous memory allocation of CMA could be expensive by following reasons.
2-1. Function overhead
Most of all, migration itself is not so simple. It should manipulate rmap and
copy content of the pages into another pages. It could require relatively long
time.
After migration, migrated pages be inserted in head of LRU page list again
though it was not be used, just migrated. In that case, the pages on LRU list
is not ordered in LRU degree. In consequence, system performance could be
degraded because working set pages could be swapped-out by the abnormal LRU
list.
2-2. Writeback cost
If the page which needs to be discarded for contiguous memory allocation was
dirty, it should be written-back to mapped file. Latency of write-back is
usually not predictably high because it depends on not only memory management,
but also block layer, file system and block device h/w characteristic.

In short, cma doesn't guarantee success and fast latency of contiguous
memory allocation. And, the core cause is the fact that cma chosen 2nd-class
client(movable pages) were not nice(hard to migrate / discard) enough.

The problem was discussed in detail from [1] and [2].



GCMA: Guaranteed contiguous memory allocator
============================================

Goal of gcma is to solve those two weaknesses of cma discussed above.
In other words, gcma aims to guarantee success and fast latency of contiguous
memory allocation.


Basic idea
----------

Basic idea of gcma is as same as cma's. It reserves large contiguous memory
area during boot and use it for contiguous memory allocator while let it be
allocated for 2nd-class clients to keep memory efficiency. If the pages
allocated for 2nd-class clients necessary for contiguous allocation(doubtless
1st-class client), discard or migrate them.

Difference with cma is choice and operation of 2nd-class client. In gcma,
2nd-class client should allocate pages from the reserved area only if the
allocated pages mets following conditions.

1. Out of Kernel
If a page is out of kernel scope, the page could be handled by the 2nd-class
client only and no others could see, touch or hold it. Those pages could be
discarded anytime. In consequence, contiguous allocation could not be fail if
2nd-class client cooperates well.
2. Quickly discardable or migratable
The pages being used by 2nd-class client should be Quickly discardable of
migratable. If so, the contiguous allocation could guarantee fast latency.

With above conditions, we picked 2 candidates for gcma 2nd-class clients.
Frontswap and cleancache are them.


Frontswap backend
-----------------

1. Out of Kernel
Pages inside frontswap backend is swapped-out pages, which are out of kernel.

2. Quickly discardable or migratable
Pages inside frontswap backend could be discarded using following policies.
2.1. Write-back
After the pages written-back containing data to backed real swap device, the
page could be free without any interference.
In this policy, latency of write-back operation could be bounded to swap device
write speed.
2.2. Write-through
Frontswap could be run with write-through mode. In this case, any pages in
frontswap backend could be free immediately because the data is already in swap
device.
This policy could show very fast speed but could make whole system slow due to
frequent write-through. In flash storage based system, it could cause the
storage system failure unless it do wear-leveling on swap device.
2.3. Put-back
When pages inside frontswap backend need to be discarded, gcma could allocates
pages from system memroy(not reserved memory) and copy content of discarding
pages into newly allocated page. After that, put those newly-allocated, data
copied pages inside swap cache to let them in frontswap backend again. After
that, the discarding pages are free.
Because it do only memory-operation, speed would not be too slow. We call the
operation as _put-back_.


Cleancache
----------

1. Out of Kernel
Pages inside clean cache is clean pages evicted from page cache, which means
out of kernel.

2. Quickly discardable or migratable
Because pages inside clean cache is clean, it could be free immediately without
any additional operation.



Current RFC implementation
==========================

Though we suggested 2 candidates and various policy for fast discarding,
current RFC implements gcma using only frontswap / write-through policy naively
because this is a prototype of prototype for various opinions of reviewers.

At the moment, current naive implementation is as follows:
1) Reserves large amount of memory during boot.
2) Allow the memory to write-through mode frontswap and contiguous memory
   allocation.
3) Drain pages being used for the frontswap if contiguous memroy allocation
   needs.

As discussed above, this implementation could introduces clear trade-off:
1) System performance could be degraded due to write-through mode
2) Flash storage using system should worry about wear-leveling

Configuring swap device using zram could be helpful to alleviate those problems
though the trade-off still exist.

Basic concept, implementation, and performance evaluation result were presented
in detail at [2].



Disclaimer
==========

Because cma and gcma has clear merits and demerits, gcma aims to be coexists
with cma rather than alternates it. Users could operate cma and gcma on a
system concurrently and could use them as they need.



Performance Evaluation
======================


Machine Setting
---------------

CuBox i4 Pro
 - ARM v7, 4 * 1 GHz cores
 - 800 MiB DDR3 RAM (Originally 2 GiB equipped.)
 - Class 10 SanDisk 16 GiB microSD card


Evaluation Variants
-------------------

 - Baseline:	Linux v3.17, 128 MiB swap
 - cma:		Baseline + 256 MiB CMA area
 - gcma:	Baseline + 256 MiB GCMA area
 - gcma.zram:	GCMA + 128 MiB zram swap device


Workloads
---------

 - Background workload: `make defconfig && time make -j 16` with Linux v3.12.6
 - Foreground workload: Request 1-32000 contiguous page allocation 32 times


Evaluation Result
-----------------

[ Latency (u-seconds) ]
Results below shows gcma's latency is significantly lower than cma's. Note that
cma max latency reaches more than 4 seconds easily.

		cma			gcma			gcma.zram
nr_pages	min	max	avg	min	max	avg	min	max	avg
1		383	53397	15737	13	43	13	13	34	13
512		578	3909212	135736	384	588	411	384	3326385	104419
1024		3074	4277142	386083	763	15580	1433	766	42521	3548
2048		3862	3334665	246806	1564	41844	3158	1536	11930	2379
4096		2502	3813997	266966	3122	10491	3608	3081	13155	3793
8192		12244	4196931	656029	6152	10682	6903	6154	37543	8406
16384		5447	4071272	853303	12544	50947	15647	12499	16819	13522
32000		18505	4293604	1102669	25427	62671	29331	25354	65421	28721


[ Background workload performance ]
Background workload(kernel build) result measured to evaluate system
performance degradation cma / gcma affects.
original means background workload result on CMA configuration without
foreground(contiguous allocation) workload.

cma and gcma degraded system performance due to page migration / write-through
and affected kernel build workload performance while gcma with zram swap device
shows alleviated performance degradation.

		user		system		elapsed		cpu
original	1702.98		169.41		08:32.13	365
cma		1723.13		187.21		09:25.46	337
gcma		1720.95		174.23		09:27.91	333
gcma.zram	1736.61		171.6		08:50.72	359


[ Evaluation result summary ]
With performance evaluation results above, we can say,
1. latency of gcma is significantly lower then cma's.
2. gcma degrade system performance though zram swap device configuration can
   abbreviate the effect a little.


NOTE: Appreciates any feedback to this simple idea and implementation though
this RFC is not yet matured and ugly a lot.



[1] https://lkml.org/lkml/2013/10/30/16
[2] http://sched.co/1qZcBAO

Really appreciate Minchan who suggested main idea and have helped a lot
during development with code fix/review.


SeongJae Park (6):
  gcma: introduce contiguous memory allocator
  gcma: utilize reserved memory as swap cache
  gcma: evict frontswap pages in LRU order when memory is full
  gcma: discard swap cache pages to meet successful GCMA allocation
  gcma: export statistical data on debugfs
  gcma: integrate gcma under cma interface

 include/linux/cma.h  |   4 +
 include/linux/gcma.h |  46 +++
 mm/Kconfig           |  15 +
 mm/Makefile          |   2 +
 mm/cma.c             | 110 +++++--
 mm/gcma.c            | 799 +++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 953 insertions(+), 23 deletions(-)
 create mode 100644 include/linux/gcma.h
 create mode 100644 mm/gcma.c

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
