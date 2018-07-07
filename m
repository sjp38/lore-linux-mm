Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 806746B0003
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 20:35:29 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j8-v6so7998986pfn.6
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 17:35:29 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 1-v6si9618339pla.509.2018.07.06.17.35.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 17:35:28 -0700 (PDT)
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH RFC V2 0/3] KASLR feature to randomize each loadable module
Date: Fri,  6 Jul 2018 17:35:41 -0700
Message-Id: <1530923744-25687-1-git-send-email-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com
Cc: kristen@linux.intel.com, dave.hansen@intel.com, arjan@linux.intel.com, Rick Edgecombe <rick.p.edgecombe@intel.com>

Hi,

This is v2 of the "KASLR feature to randomize each loadable module" patchset.
The purpose is to increase the randomization and makes the modules randomized
in relation to each other instead of just the base, so that if one module leaks,
the location of the others can't be inferred.

This code needs some refactoring and simplification, but I was hoping to get
some feedback on the benchmarks and provide an update.

V2 brings the TLB flushes down to close to the existing algorithm and increases
the modules that get high randomness based on the concerns raised by Jann Horn
about the BPF JIT use case. It also tries to address Kees Cook's comments about
possible minimal boot time regression by measuring the average allocation time
to be below the existing allocator. It also addresses Mathew Wilcox's comment
on the GFP_NOWARN not being needed. There is also some data on PTE memory use
which is higher than the original algorithm, as suggested by Jann.

This is off of 4.18-RC3.

Changes since v1:
 - New implementation of __vmalloc_node_try_addr based on the
   __vmalloc_node_range implementation, that only flushes TLB when needed.
 - Modified module loading algorithm to try to reduce the TLB flushes further.
 - Increase "random area" tries in order to increase the number of modules that
   can get high randomness.
 - Increase "random area" size to 2/3 of module area in order to increase the
   number of modules that can get high randomness.
 - Fix for 0day failures on other architectures.
 - Fix for wrong debugfs permissions. (thanks to Jann)
 - Spelling fix .(thanks to Jann)
 - Data on module_alloc performance and TLB flushes. (brought up by Kees and
   Jann)
 - Data on memory usage. (suggested by Jann)
 
Todo:
 - Refactor __vmalloc_node_try_addr to be smaller and share more code with the
   normal vmalloc path, and misc cleanup
 - More real world testing other than the synthetic micro benchmarks described
   below. BPF kselftest brought up by Daniel Borkman.

New Algorithm
=============
In addition to __vmalloc_node_try_addr only purging the lazy free areas when it
needs to, it also now supports a mode where it will fail to allocate instead of
doing any purge. In this case it reports when the allocation would have
succeeded if it was allowed to purge. It returns this information via an
ERR_PTR.

The logic for the selection of a location in the random ara is changed as well.
The number of tries is increased from 10 to 10000, which actually still gives
good performance. At a high level, the vmalloc algorithm quickly traverses an
RB-Tree to find a start position and then more slowly traverses a link list to
look for an open spot. Since this new algorithm randomly picks a spot, it
mostly just needs to traverse the RB-Tree, and as a result the "tries" are fast
enough that the number can be high and still be faster than traversing the
linked list. In the data below you can see that the random algorithm is on
average actually faster than the existing one.

The increase in number of tries is also to support the BPF JIT use case, by
increasing the number of modules that can get high randomness.

Since the __vmalloc_node_try_addr now can optionally fail instead of purging,
for the first half of the tries, the algorithm tries to find a spot where it
doesn't need to do a purge. For the second half it allows purges. The 50:50
split is to try to be a happy medium between reducing TLB flushes and reducing
average allocation time.

Randomness
==========
In the last patchset the size of the random area used in the calculations was
incorrect. The entropy should have been closer to 17 bits, not 18, which is why
its lower here even though the number of random area tries is cranked up. 17.3
bits is likely maintained to much higher number of allocations than shown here
in reality, since it seems that the BPF JIT allocations are usually smaller than
modules. If you assume the majority of allocations are 1 page, 17 bits is
maintained to 8000 modules.

Modules		Min Info
1000		17.3
2000		17.3
3000		17.3
4000		17.3
5000		17.08
6000		16.30
7000		15.67
8000		14.92

Allocation Time
===============
The average module_alloc time over N modules was actually always faster with the
random algorithm:

Modules	Existing(ns)	New(ns)
1000	4,761		1,134
2000	9,730		1,149
3000	15,572		1,396
4000	20,723		2,161
5000	26,206		4,349
6000	31,374		8,615
7000	36,123		14,009
8000	40,174		23,396

Average Nth Allocation time was usually better than the existing algorithm,
until the modules get very high.

Module	Original(ns)	New(ns)
1000	8,800		1,288
2000	20,949		1,477
3000	31,980		2,583
4000	44,539		9,250
5000	55,212		25,986
6000	65,968		39,540
7000	74,883		57,798
8000	85,392		97,319

TLB Flushes Per Allocation
==========================
The new algorithm flushes the TLB a little bit more than the existing algorithm.
For the sake of comparison to the old simpler __vmalloc_node_try_addr
implementation, this is about a 238x improvement in some cases.

Modules	Existing	New
1000	0.0014		0.001407
2000	0.001746	0.0018155
3000	0.0018186667	0.0021186667
4000	0.00187525	0.00249675
5000	0.001897	0.0025334
6000	0.0019066667	0.0025228333
7000	0.001925	0.0025315714
8000	0.0019325	0.002553

Memory Usage
============
A downside is that since the random area is fragmented, it uses extra PTE pages.
It first approaches 1.3 MB of PTEs as the random area fills. After that it
increases more slowly. I am not sure this can be improved without reducing
randomness.

Modules	Existing(pages)	New(pages)
100	6		159
200	11		240
300	15		285
400	20		307
500	23		315
1000	41		330
2000	80		335
3000	118		338

Module Capacity
===============
The estimate of module capacity also now goes back up to ~17000, so the real
value should be close to the existing algorithm.


Rick Edgecombe (3):
  vmalloc: Add __vmalloc_node_try_addr function
  x86/modules: Increase randomization for modules
  vmalloc: Add debugfs modfraginfo

 arch/x86/include/asm/pgtable_64_types.h |   1 +
 arch/x86/kernel/module.c                | 103 +++++++++++-
 include/linux/vmalloc.h                 |   3 +
 mm/vmalloc.c                            | 275 +++++++++++++++++++++++++++++++-
 4 files changed, 375 insertions(+), 7 deletions(-)

-- 
2.7.4
