Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 779976B0032
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 14:52:04 -0500 (EST)
Received: by padfa1 with SMTP id fa1so30057690pad.2
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 11:52:04 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id xr9si10435087pbc.134.2015.02.23.11.52.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Feb 2015 11:52:02 -0800 (PST)
Received: by padhz1 with SMTP id hz1so29957745pad.9
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 11:52:02 -0800 (PST)
From: SeongJae Park <sj38.park@gmail.com>
Subject: [RFC v2 0/5] introduce gcma
Date: Tue, 24 Feb 2015 04:54:18 +0900
Message-Id: <1424721263-25314-1-git-send-email-sj38.park@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: lauraa@codeaurora.org, minchan@kernel.org, sergey.senozhatsky@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, SeongJae Park <sj38.park@gmail.com>

This RFC patchset is based on linux v3.18 and available on git:
git://github.com/sjp38/linux.gcma -b gcma/rfc/v2

Abstract
========

Current cma(contiguous memory allocator) could not guarantee success and fast
latency of contiguous allocation.
This coverletter explains about the problem in detail and proposes new
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
   2nd-class clients.
 - If pages being allocated for 2nd-class clients are necessary for contiguous
   allocation(doubtless 1st class client), migrates or discard the page and use
   them for contiguous allocation.

In cma, _2nd-class client_ is movable page. The reserved area could be
allocated for movable pages and the movable pages be migrated or discarded if
contiguous allocation needs them.


Problem of cma
--------------

The cma mechanism imposes following weaknesses.

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
memory allocation. And, the main reason is the fact that cma chosen 2nd-class
client(movable pages) was not nice(hard to migrate / discard) enough.

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
allocated for 2nd-class clients are need for contiguous allocation(doubtless
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
Cleancache and Frontswap are them.


Cleancache
----------

1. Out of Kernel
Pages inside clean cache is clean pages evicted from page cache, which means
out of kernel.

2. Quickly discardable or migratable
Because pages inside clean cache is clean, it could be free immediately without
any additional operation.


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



Current RFC implementation
==========================

Though we suggested various policies for frontswap pages discarding,
current RFC implementation uses only write-through policy frontswap naively 
because this is a prototype for various comments from reviewers.

At the moment, current naive implementation is as follows:
1) Reserves large amount of memory during boot.
2) Allow the memory to cleancache, write-through mode frontswap and
   contiguous memory allocation.
3) Drain pages being used for the cleancache, frontswap if contiguous memroy
   allocation needs.

As discussed above, this implementation could introduces clear trade-off:
1) System performance could be degraded due to write-through mode
2) Flash storage using system should worry about wear-leveling

Configuring swap device using zram could be helpful to alleviate those problems
though the trade-off still exists.

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
1		381	2853	684	13	279	26	14	274	101
512		818	2382	1162	512	10140	2002	510	648	600
1024		3113	184703	12303	1016	17426	3495	1014	1284	1192
2048		2545	790727	33084	2029	27027	5983	2142	3781	2829
4096		2899	2768349	298640	4087	86887	13091	4101	6046	4780
8192		4476	3496211	407076	8254	75976	17519	9888	11386	10580
16384		7266	4132546	657603	16398	98087	30474	21079	23641	22491
32000		8612	3910423	641340	32328	92502	44675	44859	654966	249453


[ System performance ]
Background workload(kernel build) result measured to evaluate system
performance degradation cma / gcma affects.
original means background workload result on CMA configuration without
foreground(contiguous allocation) workload.

Ran workload 5 times and measured average of user / system / elapsed time and
cpu utilization percentage. Result are as below:

		user		system		elapsed		cpu
original	1675.388	167.702		507.738		362.4
cma		1707.902	172.184		523.738		358.4
gcma		1677.492	170.016		515.042		358.2
gcma.zram	1678.104	166.992		513.622		358.6


cma and gcma degraded system performance due to page migration / write-through
and affected kernel build workload performance while gcma with zram swap device
shows alleviated performance degradation.


[ Evaluation result summary ]
With performance evaluation results above, we can say,
1. latency of gcma is significantly lower then cma's.
2. gcma degrade system performance though zram swap device configuration can
   abbreviate the effect a little.



Acknowledgement
===============

Really appreciate Minchan who suggested main idea and have helped a lot
during development with code fix/review.


[1] https://lkml.org/lkml/2013/10/30/16
[2] http://sched.co/1qZcBAO


Changes in v2:
 - Discardable memory abstraction
 - Cleancache implementation


SeongJae Park (5):
  gcma: introduce contiguous memory allocator
  gcma: utilize reserved memory as discardable memory
  gcma: adopt cleancache and frontswap as second-class clients
  gcma: export statistical data on debugfs
  gcma: integrate gcma under cma interface

 include/linux/cma.h  |    4 +
 include/linux/gcma.h |   64 +++
 mm/Kconfig           |   24 +
 mm/Makefile          |    1 +
 mm/cma.c             |  113 ++++-
 mm/gcma.c            | 1321 ++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 1508 insertions(+), 19 deletions(-)
 create mode 100644 include/linux/gcma.h
 create mode 100644 mm/gcma.c

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
